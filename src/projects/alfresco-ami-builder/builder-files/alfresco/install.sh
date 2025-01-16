#!/usr/bin/env bash

# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'exit_code=$?; on_exit $exit_code $LINENO' EXIT

on_exit() {
  # write out an error on fail:
  [ $exit_code -ne 0 ] && echo "Failed command (code $1) on line $2: '${last_command}'"
}

install_dir_root="/tmp/installing"
install_dir_tomcat="${install_dir_root}/tomcat"
install_dir_alfresco="${install_dir_root}/alfresco"

for dir in "${install_dir_tomcat}" "${install_dir_alfresco}"; do
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
  fi
done

# extract distributions
tar -xz -f /tmp/apache-tomcat.tar.gz --wildcards -C "${install_dir_tomcat}" --strip=1 apache-tomcat-*
unzip -q /tmp/alfresco-content-services-distribution.zip -d "${install_dir_alfresco}"

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

unzip -q "${install_dir_tomcat}/webapps/alfresco.war" -d "${install_dir_tomcat}/webapps/alfresco"
unzip -q "${install_dir_tomcat}/webapps/share.war" -d "${install_dir_tomcat}/webapps/share"

mv "${install_dir_alfresco}/web-server/conf/Catalina/localhost/alfresco.xml" "${install_dir_tomcat}/conf/Catalina/localhost/"
mv "${install_dir_alfresco}/web-server/conf/Catalina/localhost/share.xml" "${install_dir_tomcat}/conf/Catalina/localhost/"

find "${install_dir_alfresco}/web-server/lib/" -maxdepth 0 -print0 | while IFS= read -r -d '' file; do
  if [[ "$(echo $file | grep -Eo '\.jar$')" = ".jar" ]]; then
    mv -- "${file}" "${install_dir_tomcat}/lib/"
  fi
done

mv /tmp/alfresco-global.properties "${install_dir_tomcat}/shared/classes/"
mv /tmp/setenv.sh "${install_dir_tomcat}/bin/"
mv /tmp/tomcat-users.xml "${install_dir_tomcat}/conf/"
mv /tmp/server.xml "${install_dir_tomcat}/conf"
mv /tmp/context.xml "${install_dir_tomcat}/webapps/manager/META-INF/"

# todo - amps

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

mv /tmp/tomcat.service /etc/systemd/system/tomcat.service
# todo - re-enable for startup at instance boot
#systemctl enable tomcat

# cleanup
rm -rf /tmp/apache-tomcat.tar.gz
rm -rf /tmp/alfresco-content-services-distribution.zip
rm -rf "${install_dir_root}"

#echo "============ LIST_ALF_DATA_START ============"
#echo "LIST /usr/local/tomcat10"
#ls -la /usr/local/tomcat10/
#echo "============================================="
#echo "LIST /usr/local/tomcat10/alf_data"
#ls -la /usr/local/tomcat10/alf_data
#echo "============  LIST_ALF_DATA_END  ============"
