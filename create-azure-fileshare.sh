#!/bin/bash
#
# Version: 1.0.1
# Date: 2020-10-22

usage() {
  echo
  echo "USAGE: ${0} <storage_account>:<file_share>"
  echo
}

display_help() {
  echo
  echo "This command enables you to easily create an Azure File Share using the 'az storage' command."
  echo
  echo "You must provide the Azure Storage Account name and File Share in the format:"
  echo " <storage_account>:<file_share>"
  echo
  echo "Where the storage account name and the file share name are separated by a colon (:)."
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
    echo "ERROR: No Storage Account:File Share provided. Exiting."
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
          export AZURE_STORAGE_ACCOUNT="$(echo ${2} | cut -d : -f 1)"
          export AZURE_FILE_SHARE="$(echo ${2} | cut -d : -f 2)"
        else
          echo 
          echo "ERROR: Storage Account and File Share not provided in the correct format. Exiting."
          echo
          usage
          exit
        fi
      ;;
    esac
  fi

  if [ -z ${AZURE_STORAGE_ACCOUNT} ]
  then
    echo
    echo "ERROR: No Azure Storage Account provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${AZURE_FILE_SHARE} ]
  then
    echo
    echo "ERROR: No file share provided. Exiting."
    echo
    usage
    exit
  fi

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

create_azure_fileshare() {
  az storage share create \
    --account-name ${AZURE_STORAGE_ACCOUNT} \
    --account-key ${AZURE_STORAGE_KEY} \
    --name ${AZURE_FILE_SHARE} \
    --quota 1024 \
    --output none
}
##############################################################################

main() {
  check_cli_args $*
  check_storage_key $*

  #az login
  
  create_azure_fileshare
  echo
}

##############################################################################

main $*

