#!/usr/bin/env bash

set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'on_exit $? $LINENO' EXIT
on_exit() { [ $1 -ne 0 ] && echo "Failed command (code $1) on line $2: '${last_command}'"; }

downloads_dir=/tmp/downloads
install_dir_root=/tmp/installing
install_dir_tomcat="${install_dir_root}/tomcat"
install_dir_alfresco="${install_dir_root}/alfresco"

for dir in "${install_dir_tomcat}" "${install_dir_alfresco}"; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

# extract distributions
tar -xz -f "${downloads_dir}/apache-tomcat.tar.gz" --wildcards -C "${install_dir_tomcat}" --strip=1 apache-tomcat-*
unzip -q "${downloads_dir}/alfresco-content-services-distribution.zip" -d "${install_dir_alfresco}"

# create required directories
for item in webapps/alfresco webapps/share modules/platform modules/share shared/classes conf/Catalina/localhost; do
  mkdir -p "${install_dir_tomcat}/${item}"
done

# move things around
ln -s /usr/share/java/mysql-connector-j.jar "${install_dir_tomcat}/lib/mysql-connector-j.jar"

for item in docs examples host-manager ROOT; do
  rm -rf "${install_dir_tomcat}/webapps/${item}"
done

for item in _vti_bin.war alfresco.war ROOT.war share.war; do
    mv "${install_dir_alfresco}/web-server/webapps/${item}" "${install_dir_tomcat}/webapps/"
done

# install amps
for amp_file in "${downloads_dir}"/*.amp; do
  java -jar "${install_dir_alfresco}/bin/alfresco-mmt.jar" install "${amp_file}" "${install_dir_tomcat}/webapps/alfresco.war" -nobackup
done

java -jar "${install_dir_alfresco}/bin/alfresco-mmt.jar" install "${install_dir_alfresco}/amps/alfresco-share-services.amp" "${install_dir_tomcat}/webapps/alfresco.war" -nobackup

unzip -q "${install_dir_tomcat}/webapps/alfresco.war" -d "${install_dir_tomcat}/webapps/alfresco"
unzip -q "${install_dir_tomcat}/webapps/share.war" -d "${install_dir_tomcat}/webapps/share"

mv "${install_dir_alfresco}/web-server/conf/Catalina/localhost/alfresco.xml" "${install_dir_tomcat}/conf/Catalina/localhost/"
mv "${install_dir_alfresco}/web-server/conf/Catalina/localhost/share.xml" "${install_dir_tomcat}/conf/Catalina/localhost/"

find "${install_dir_alfresco}/web-server/lib/" -maxdepth 0 -print0 | while IFS= read -r -d '' file; do
  if [[ "$(echo $file | grep -Eo '\.jar$')" = ".jar" ]]; then
    mv -- "${file}" "${install_dir_tomcat}/lib/"
  fi
done

mv "${downloads_dir}/alfresco-global.properties" "${install_dir_tomcat}/shared/classes/"
mv "${downloads_dir}/setenv.sh" "${install_dir_tomcat}/bin/"
mv "${downloads_dir}/tomcat-users.xml" "${install_dir_tomcat}/conf/"
mv "${downloads_dir}/server.xml" "${install_dir_tomcat}/conf"
mv "${downloads_dir}/context.xml" "${install_dir_tomcat}/webapps/manager/META-INF/"

# update logging config
sed -i 's|^shared\.loader=$|shared.loader=\$\{catalina.base\}/shared/classes,\$\{catalina.base\}/shared/lib/*.jar|g' "${install_dir_tomcat}/conf/catalina.properties"
sed -i 's|^appender.rolling.fileName=alfresco\.log$|appender.rolling.fileName=/usr/local/tomcat10/logs/alfresco.log|g' "${install_dir_tomcat}/webapps/alfresco/WEB-INF/classes/log4j2.properties"
sed -i 's|^appender.rolling.fileName=share\.log$|appender.rolling.fileName=/usr/local/tomcat10/logs/share.log|g' "${install_dir_tomcat}/webapps/share/WEB-INF/classes/log4j2.properties"

# update module locations
sed -i 's|base="${catalina.base}/../modules/platform"|base="${catalina.base}/modules/platform"|' "${install_dir_tomcat}/conf/Catalina/localhost/alfresco.xml"
sed -i 's|base="${catalina.base}/../modules/share"|base="${catalina.base}/modules/share"|' "${install_dir_tomcat}/conf/Catalina/localhost/share.xml"

# prep for EFS
mkdir -p /root/alf_data
mv "${install_dir_alfresco}/keystore" /root/alf_data/
ln -s /mnt/efs/alfresco "${install_dir_tomcat}/alf_data"

# move installation to final location
mv "${install_dir_tomcat}" /usr/local/tomcat10
chown --recursive tomcat:tomcat /usr/local/tomcat10

# install and enable tomcat service
mv "${downloads_dir}/tomcat.service" /etc/systemd/system/tomcat.service
systemctl enable tomcat

# cleanup
rm -rf "${downloads_dir}"
rm -rf "${install_dir_root}"
