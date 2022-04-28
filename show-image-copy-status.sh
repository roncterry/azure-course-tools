#!/bin/bash
#
# Version: 1.0.3
# Date: 2022-04-27

usage() {
  echo
  echo "USAGE: ${0} <destination_storage_account>:<container>:<file> [simple]"
  echo
}

display_help() {
  echo
  echo "This command enables you to easily display the copy status of an image (blob) using the 'az storage' command."
  echo
  echo "You must provide the file as the first argument in the format."
  echo " <storage_account>:<container>:<file>"
  echo
  echo "Where the storage account name, the container name the file share name are separated by a colon (:)."
  echo
  echo "To have the progress returned on a single line of output supply as the second argument to the command: simple"
  echo
}

check_cli_args() {
  if [ -z ${1} ]
  then
    echo
    echo "ERROR: No Storage Account, Countainer or File Share. Exiting."
    echo
    usage
    echo
    exit
  else
    case ${1} in
      -h|-H|--help)
        display_help
        usage
        echo
        exit
      ;;
      *)
        if echo ${1} | grep -q ":"
        then
          export DESTINATION_STORAGE_ACCOUNT="$(echo ${1} | cut -d : -f 1)"
          export DESTINATION_STORAGE_CONTAINER="$(echo ${1} | cut -d : -f 2)"
          export DESTINATION_FILE="$(echo ${1} | cut -d : -f 3)"
        else
          echo 
          echo "ERROR: Storage Account, Container and File Share not provided in the correct format. Exiting."
          echo
          usage
          exit
        fi
      ;;
    esac
  fi

  if [ -z ${DESTINATION_STORAGE_ACCOUNT} ]
  then
    echo
    echo "ERROR: No Destination Storage Account provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${DESTINATION_STORAGE_CONTAINER} ]
  then
    echo
    echo "ERROR: No Destination Storage Container provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${DESTINATION_FILE} ]
  then
    echo
    echo "ERROR: No Destination File provided. Exiting."
    echo
    usage
    exit
  fi
}

check_azure_storage_key() {
  if [ -z ${AZURE_STORAGE_KEY} ]
  then
    if [ -e ./azure_storage_key.txt ]
    then
      export AZURE_STORAGE_KEY="$(cat ./azure_storage_key.txt)"
    fi
  fi

  if [ -z ${AZURE_STORAGE_KEY} ]
  then
    export AZURE_STORAGE_KEY="$(az storage account keys list --account-name ${DESTINATION_STORAGE_ACCOUNT} --output table 2> /dev/null | grep "key1" | awk '{ print $4 }')"
  fi
}

display_blob_copy_status() {
  az storage blob show \
    --account-name ${DESTINATION_STORAGE_ACCOUNT} \
    --account-key ${AZURE_STORAGE_KEY} \
    --container-name ${DESTINATION_STORAGE_CONTAINER} \
    --name ${DESTINATION_FILE} \
    --query '{progress:properties.copy.progress}' \
    --output table
  echo
}

display_blob_copy_status_one_line() {
  az storage blob show \
    --account-name ${DESTINATION_STORAGE_ACCOUNT} \
    --container-name ${DESTINATION_STORAGE_CONTAINER} \
    --name ${DESTINATION_FILE} 2> /dev/null | grep progress | cut -d \" -f 2,3,4 | sed 's/"//g'
}

##############################################################################

main() {
  check_cli_args $*
  check_azure_storage_key $*

  #az login
  
  case ${2} in
    simple)
      display_blob_copy_status_one_line
    ;;
    *)
      display_blob_copy_status
    ;;
  esac
}

##############################################################################

main $*

