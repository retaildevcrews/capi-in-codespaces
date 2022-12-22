#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date)    post-create start" >> "$HOME/status"

# set az env variables
if [ "$AZURE_SUBSCRIPTION_ID" != "" ] && [ "$AZURE_CLIENT_ID" != "" ] && [ "$AZURE_CLIENT_SECRET" != "" ] && [ "$AZURE_TENANT_ID" != "" ]
then
  AZURE_SUBSCRIPTION_ID_B64="$(echo -n "$AZURE_SUBSCRIPTION_ID" | base64 | tr -d '\n')"
  AZURE_TENANT_ID_B64="$(echo -n "$AZURE_TENANT_ID" | base64 | tr -d '\n')"
  AZURE_CLIENT_ID_B64="$(echo -n "$AZURE_CLIENT_ID" | base64 | tr -d '\n')"
  AZURE_CLIENT_SECRET_B64="$(echo -n "$AZURE_CLIENT_SECRET" | base64 | tr -d '\n')"

  export AZURE_SUBSCRIPTION_ID_B64
  export AZURE_TENANT_ID_B64
  export AZURE_CLIENT_ID_B64
  export AZURE_CLIENT_SECRET_B64
fi
echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
