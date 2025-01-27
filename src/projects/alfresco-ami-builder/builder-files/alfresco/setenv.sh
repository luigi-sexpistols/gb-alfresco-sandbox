#!/usr/bin/env bash

# static options
# (currently set in alfresco-global.properties, since they're just static values)
declare -a options=()

# ssm parameter options
path_prefix="/alfresco/java/"

result=$(aws ssm get-parameters-by-path --path="${path_prefix}" --recursive --with-decryption)

# check for valid json
echo "${result}" | jq empty 2> /dev/null

if [ "$?" != "0" ]; then
  echo "Failed to get parameters."
  echo "${result}"
  exit 1
fi

while read -r param; do
  name="$(echo "${param}" | jq -r '.Name' | sed "s|^${path_prefix}||" - | sed -E 's|/|.|g' -)"
  value=$(echo "${param}" | jq -r '.Value')
  # quote the options (db host wasn't picked up, unquoted)
  options+=("'${name}=${value}'")
done < <(echo "${result}" | jq -c '.Parameters[]')

out=""

for i in "${options[@]}"; do
  out="${out:+$out }-D${i}"
done

export "JAVA_TOOL_OPTIONS=${out}"
