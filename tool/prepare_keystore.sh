#!/bin/bash
set -eo pipefail

mode=${1:-create}

keystore_path="$RUNNER_TEMP/app.keystore"
key_properties_path=android/key.properties

if [[ "$mode" == "create" ]]; then
  echo "$KEYSTORE" | openssl base64 -d > "$keystore_path"

  cat << EOF > "$key_properties_path"
storeFile=$keystore_path
password=$KEYSTORE_PASSWORD
EOF
elif [[ "$mode" == "delete" ]]; then
  rm -f "$keystore_path"
  rm -f "$key_properties_path"
else
  echo "Invalid mode: $mode"
  exit 1
fi
