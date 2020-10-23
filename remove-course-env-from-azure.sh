#!/bin/bash
#
# version: 1.2.0
# date: 2020-10-22

######### Default Values #################
DEF_REGION_LIST="westus"
DEF_IMAGE_SOURCE_RESOURCE_GROUP="Labmachine_Image"
DEF_IMAGE_SOURCE_STORAGE_ACCOUNT="labmachineimages"
DEF_IMAGE_SOURCE_CONTAINER_NAME="vhds"
DEF_SOURCE_FILESHARE_STORAGE_ACCOUNT="susecourseinstallers"
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
  echo "USAGE: ${0} <course_config_file> [delete-source-vhd] [delete-source-fileshare]"
  echo
  echo "        The \'delete-source-vhd\' option will delete the original copy of the"
  echo "        source vhd template."
  echo
  echo "        The \'delete-source-fileshare\' option will delete the azure file share"
  echo "        that was used to upload the course lab environment installer (if used)."
  echo
}

if [ -z ${1} ]
then
  echo -e "${RED}ERROR. You must supply a course config file. Exiting.${NC}"
  echo
  usage
  exit
else
  COURSE_CONFIG_FILE=${1}
  if ! [ -e ${COURSE_CONFIG_FILE} ]
  then
    echo -e "${RED}ERROR: The supplied course config file does not seem to exist. Exiting.${NC}"
    echo
    exit
  else
    source ${COURSE_CONFIG_FILE}
  fi
fi

#############################################################################

set_default_values() {
  if [ -z ${REGION_LIST} ]
  then
    REGION_LIST="${DEF_REGION_LIST}"
  fi

  if [ -z ${IMAGE_SOURCE_RESOURCE_GROUP} ]
  then
    IMAGE_SOURCE_RESOURCE_GROUP="${DEF_IMAGE_SOURCE_RESOURCE_GROUP}"
  fi

  if [ -z ${IMAGE_SOURCE_STORAGE_ACCOUNT} ]
  then
    IMAGE_SOURCE_STORAGE_ACCOUNT="${DEF_IMAGE_SOURCE_STORAGE_ACCOUNT}"
  fi

  if [ -z ${IMAGE_SOURCE_CONTAINER_NAME} ]
  then
    IMAGE_SOURCE_CONTAINER_NAME="${DEF_IMAGE_SOURCE_CONTAINER_NAME}"
  fi

  if [ -z ${SOURCE_FILESHARE_STORAGE_ACCOUNT} ]
  then
    SOURCE_FILESHARE_STORAGE_ACCOUNT="${DEF_SOURCE_FILESHARE_STORAGE_ACCOUNT}"
  fi
}

delete_resource_group() {
  echo -e "${LTBLUE}Deleteing the resource group named: ${GRAY}${COURSE_RESOURCE_GROUP_BASE_NAME}-${REGION}${NC}"
  az group create \
    -l ${REGION} \
    -n ${COURSE_RESOURCE_GROUP_BASE_NAME}-${REGION}
  echo
}

delete_source_disk_image() {
  echo -e "${LTBLUE}Deleting the source course disk ...${NC}"
  echo -e "${LTBLUE}(This will take a while, please be patient)${NC}"
  echo

  local IMAGE_SOURCE_STORAGE_KEY=$(az storage account keys list --resource-group ${IMAGE_SOURCE_RESOURCE_GROUP} --account-name ${IMAGE_SOURCE_STORAGE_ACCOUNT} --output table | grep key1 | sed '{ print $3 }')

  az storage blob delete \
    --container-name ${IMAGE_SOURCE_CONTAINER_NAME} \
    --name ${IMAGE_SOURCE_IMAGE_FILE} \
    --account-name ${IMAGE_SOURCE_STORAGE_ACCOUNT} \
    --account-key ${IMAGE_SOURCE_STORAGE_KEY} \
    --delete-snapshots include
    --query '{jobID:id}' --output table
}

delete_source_fileshare() {
  echo -e "${LTBLUE}Deleting the source file share with course installers ...${NC}"
  echo -e "${LTBLUE}(This will take a while, please be patient)${NC}"
  echo

  local IMAGE_SOURCE_STORAGE_KEY=$(az storage account keys list --resource-group ${IMAGE_SOURCE_RESOURCE_GROUP} --account-name ${IMAGE_SOURCE_STORAGE_ACCOUNT} --output table | grep key1 | sed '{ print $3 }')

  az storage share delete \
    --name ${SOURCE_FILESHARE_NAME} \
    --account-name ${SOURCE_FILESHARE_STORAGE_ACCOUNT} \
    --account-key ${SOURCE_FILESHARE_STORAGE_KEY} \
    --query '{jobID:id}' --output table
}

############################################################################

main() {
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo -e "${LTBLUE}               Creating new course environment in Azure${NC}"
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo

  set_default_values

  for REGION in ${REGION_LIST}
  do
    echo -e "${LTBLUE}---------------------${NC}"
    echo -e "${LTBLUE}Region: ${GRAY}${REGION}${NC}"
    echo -e "${LTBLUE}---------------------${NC}"
    echo

    delete_new_resource_group

    echo
    echo -e "${LTBLUE}---------------------------------------------------------------------------${NC}"
    echo
  done

  if echo ${*} | grep -q delete-source-vhd
  then
    delete_source_disk_image
  fi

  if echo ${*} | grep -q delete-source-fileshare
  then
    delete_source_fileshare
  fi
}

############################################################################

time main ${*}

