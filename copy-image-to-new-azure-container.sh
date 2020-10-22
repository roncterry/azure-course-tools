#!/bin/bash
#
# Version: 1.0.0
# Date: 2020-10-22

usage() {
  echo
  echo "USAGE: ${0} <source_storage_container>:<container>:<file> <destination_storage_account>:<container>[:<file>]"
  echo
}

display_help() {
  echo
  echo "This command enables you to easily copy an file (blob) from one Azure Storage Container to another using the 'az storage' command."
  echo
  echo "You must provide the source file as the first argument in the format."
  echo " <source_storage_account>:<container>:<file>"
  echo
  echo "You must provide the destination as the second argument in the format:"
  echo " <destination_storage_account>:<file_share>"
  echo "Or "
  echo " <destination_storage_account>:<file_share>:<new_file_name>"
  echo "(If the destination file name is not provided it will be named the same as the source file.)"
  echo
  echo "Where the storage account name, the container name the file share name are separated by a colon (:)."
  echo
  echo "The Storage Account Access Key must either be stored in "
  echo "the environment variable: AZURE_STORAGE_KEY"
  echo " Or "
  echo "In a file in your current working directory named: azure_storage_key.txt"
  echo
}

check_cli_args() {
  if [ -z ${1} ]
  then
    echo
    echo "ERROR: No Storage Account, Countainer or File Share. Exiting."
    #echo "ERROR: No source files directory provided. Exiting."
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
          export SOURCE_STORAGE_ACCOUNT="$(echo ${1} | cut -d : -f 1)"
          export SOURCE_STORAGE_CONTAINER="$(echo ${1} | cut -d : -f 2)"
          export SOURCE_FILE="$(echo ${1} | cut -d : -f 3)"
        else
          echo 
          echo "ERROR: Source Storage Account, Container and File Share not provided in the correct format. Exiting."
          echo
          usage
          exit
        fi
      ;;
    esac
  fi

  if [ -z ${2} ]
  then
    echo
    echo "ERROR: No Destination Storage Account, Course and File Share provided. Exiting."
    echo
    usage
    echo
    exit
  else
    if echo ${2} | grep -q ":"
    then
      export DESTINATION_STORAGE_ACCOUNT="$(echo ${2} | cut -d : -f 1)"
      export DESTINATION_STORAGE_CONTAINER="$(echo ${2} | cut -d : -f 2)"
      export DESTINATION_FILE="$(echo ${2} | cut -d : -f 3)"
    else
      echo 
      echo "ERROR: Storage Account, Container and File Share not provided in the correct format. Exiting."
      echo
      usage
      exit
    fi
  fi

  if [ -z ${SOURCE_STORAGE_ACCOUNT} ]
  then
    echo
    echo "ERROR: No Source Storage Account provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${SOURCE_STORAGE_CONTAINER} ]
  then
    echo
    echo "ERROR: No Source Storage Container provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${SOURCE_FILE} ]
  then
    echo
    echo "ERROR: No Source File provided. Exiting."
    echo
    usage
    exit
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
    DESTINATION_FILE=${SOURCE_FILE}
  fi

  SOURCE_URI="https://${SOURCE_STORAGE_ACCOUNT}.blob.core.windows.net/${SOURCE_STORAGE_CONTAINER}/${SOURCE_FILE}"
}

check_storage_key() {
  if [ -z ${AZURE_STORAGE_KEY} ]
  then
    if [ -e ./azure_storage_key.txt ]
    then
      export AZURE_STORAGE_KEY="$(cat ./azure_storage_key.txt)"
      if [ -z ${AZURE_STORAGE_KEY} ]
      then
        echo
        echo "ERROR: The storage key file is empty."
        echo "       Make sure it contains a valid storage key."
        echo "       Exiting."
        echo
        usage
        exit
      fi
    else
      echo
      echo "ERROR: No storage key found."
      echo
      echo "       Either store the Azure storage key in the "
      echo "       environment variable: AZURE_STORAGE_KEY"
      echo
      echo "       Or "
      echo
      echo "       Save it in a file: ./azure_storage_key.txt"
      echo
 
      exit
    fi
  fi
}

copy_blob_to_new_container() {
  az storage blob copy start \
    --account-name ${DESTINATION_STORAGE_ACCOUNT} \
    --account-key ${AZURE_STORAGE_KEY} \
    --destination-container ${DESTINATION_CONTAINER} \
    --destination-blob ${DESTINATION_FILE} \
    --source-uri ${SOURCE_URI}
  echo
}

##############################################################################

main() {
  check_cli_args $*
  check_storage_key $*

  #az login
  
  copy_blob_to_new_container

  echo "To see the status of the copy, run the following command:"
  echo
  echo "show-image-copy-status.sh ${DESTINATION_STORAGE_ACCOUNT}:${DESTINATION_CONTAINER}:${DESTINATION_FILE}"
  echo
}

##############################################################################

main $*

