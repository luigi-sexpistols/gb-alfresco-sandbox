#!/usr/bin/env bash

options=(
  "encryption.keystore.type=JCEKS"
  "encryption.cipherAlgorithm=DESede/CBC/PKCS5Padding"
  "encryption.keyAlgorithm=DESede"
  "encryption.keystore.location=${dir.root}/keystore/metadata-keystore/keystore"
  "metadata-keystore.password=${keystore_password}"
  "metadata-keystore.aliases=metadata"
  "metadata-keystore.metadata.password=${metadata_password}"
  "metadata-keystore.metadata.algorithm=DESede"
)

out=""

for i in "$${options[@]}"; do out="$${out:+$out }-D$${i}"; done

export "JAVA_TOOL_OPTIONS=$${out}"
