#!/bin/bash
#
# Version: 1.0.1
# Date: 2020-10-22

usage() {
  echo
  echo "USAGE: ${0} <storage_account>"
}

get_storage_account() {
  if [ -z ${1} ]
  then
    echo
    echo "ERROR: You must provide a Storage Account name. Exiting."
    echo
    usage
    exit
  else
    export AZURE_STORAGE_ACCOUNT=${1}
  fi
}

get_storage_account_key() {
  az storage account keys list \
    --account-name ${AZURE_STORAGE_ACCOUNT} \
    --output table 2> /dev/null | grep "key1" | awk '{ print $3 }'
}

main() {
  get_storage_account $*

  get_storage_account_key
}

main $*
