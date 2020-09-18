#!/bin/bash
#
# Version: 2.0.0
# Date: 2020-09-18

######### Default Values #################
DEF_AZURE_STORAGE_ACCOUNT="labmachineimages"
DEF_AZURE_SOURCE_CONTAINER_NAME="vhds"
##########################################

### Colors ###
RED='\e[0;31m'
LTRED='\e[1;31m'
BLUE='\e[0;34m'
LTBLUE='\e[1;34m'
GREEN='\e[0;32m'
LTGREEN='\e[1;32m'
ORANGE='\e[0;33m'
YELLOW='\e[1;33m'
CYAN='\e[0;36m'
LTCYAN='\e[1;36m'
PURPLE='\e[0;35m'
LTPURPLE='\e[1;35m'
GRAY='\e[1;30m'
LTGRAY='\e[0;37m'
WHITE='\e[1;37m'
NC='\e[0m'
##############

usage() {
  echo
  echo "USAGE: ${0} <vhd_file> <storage_account>:<container>"
  echo
}

display_help() {
  echo
  echo "This command enables you to easily upload a VHD disk image to an Azure Storage Container using the 'az storage' command."
  echo
  echo "You must provide the VHD file you want uploaded as the first argument."
  echo
  echo "You must provide the Azure Storage Account name and Storage Container as the second argument in the format:"
  echo " <storage_account>:<container>"
  echo
  echo "Where the storage account name and the container name are separated by a colon (:)."
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
    echo "ERROR: No VHD file, Storage Account or Storage Container. Exiting."
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
        export VHD_FILE="${1}"
        if ! [ -d ${VHD_FILE} ]
        then
          echo
          echo "ERROR: The provided VHD file does not seem to exist. Exiting."
          echo
          exit
        fi
      ;;
    esac
  fi

  if [ -z ${2} ]
  then
    echo
    echo "ERROR: No Storage Account, Storage Container provided. Exiting."
    echo
    usage
    echo
    exit
  else
    if echo ${2} | grep -q ":"
    then
      export AZURE_STORAGE_ACCOUNT="$(echo ${2} | cut -d : -f 1)"
      export AZURE_STORAGE_CONTAINER_NAME="$(echo ${2} | cut -d : -f 2)"
    else
      echo 
      echo "ERROR: Storage Account and Storage Container not provided in the correct format. Exiting."
      echo
      usage
      exit
    fi
  fi

  if [ -z ${AZURE_STORAGE_ACCOUNT} ]
  then
    echo
    echo "ERROR: No Azure Storage Account provided. Exiting."
    echo
    usage
    exit
  fi

  if [ -z ${AZURE_STORAGE_CONTAINER_NAME} ]
  then
    echo
    echo "ERROR: No Storage COntainer provided. Exiting."
    echo
    usage
    exit
  fi

}

set_default_values() {
  if [ -z ${AZURE_STORAGE_ACCOUNT} ]
  then
    AZURE_STORAGE_ACCOUNT="${DEF_AZURE_STORAGE_ACCOUNT}"
  fi

  if [ -z ${AZURE_STORAGE_CONTAINER_NAME} ]
  then
    AZURE_STORAGE_CONTAINER_NAME="${DEF_AZURE_STORAGE_CONTAINER_NAME}"
  fi
}


copy_vhd_to_azure() {
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo -e "${LTBLUE}                  Copying VHD Disk Image To Azure${NC}"
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo

  az storage blob upload \
    --query '{jobID:id}' --output table \
    -t page  \
    -a ${AZURE_STORAGE_ACCOUNT} \
    -c ${AZURE_STORAGE_CONTAINER_NAME} \
    -f ${VHD_FILE} \
    -n ${VHD_FILE} 
}

how_to_show_progress() {
  echo
  echo -e "${ORANGE}TIP: The image file copy is happening in the background.${NC}"
  echo
  echo -e "${ORANGE}     You can watch the progress of the image upload job by${NC}"
  echo -e "${ORANGE}     running the following command:${NC}"
  echo
  echo -e "${GRAY}    watch az storage blob show \ ${NC}"
  echo -e "${GRAY}      --account-name ${AZURE_STORAGE_ACCOUNT} \ ${NC}"
  echo -e "${GRAY}      -c ${AZURE_STORAGE_CONTAINER_NAME} \ ${NC}"
  echo -e "${GRAY}      -n ${VHD_FILE} \ ${NC}"
  echo -e "${GRAY}      --query \'progress:properties.copy.progress}\' \ ${NC}"
  echo -e "${GRAY}      --output table${NC}"
  echo 
  echo -e "${LTPURPLE}     (Ctrl+c quits the command)${NC}"
  echo 
}

main() {
  check_cli_args ${*}
  set_default_values
  copy_vhd_to_azure ${*}
  #how_to_show_progress
}

main ${*}
