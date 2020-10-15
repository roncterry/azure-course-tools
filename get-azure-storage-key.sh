#!/bin/bash

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

main() {
  get_storage_account $*

  az storage account keys list --account-name ${AZURE_STORAGE_ACCOUNT} --output table | grep "key1" | awk '{ print $3 }'
}

main $*
