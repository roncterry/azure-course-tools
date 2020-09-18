#!/bin/bash

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
  echo "USAGE: ${0} <course_environment_config_file>"
  echo
}

if ! [ -z ${1} ]
then
  if [ -e ${1} ]
  then
    source ${1}
  else
    echo
    echo "ERROR: The supplied course environment config file doesn't appear to exit. Exiting ..."
    usage
    exit
  fi
else
  echo
  echo "ERROR: You must supply a course environment config file. Exiting ..."
  usage
  exit
fi

###############################################################################

do_this_first() {
  echo
  echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
  echo
  echo -e "${RED}IMPORTANT:${NC}"
  echo -e "${RED}  -You must create a course environment config file before you${NC}"
  echo -e "${RED}   run this command.${NC}"
  echo -e "${RED}  and ${NC}"
  echo -e "${RED}  -You must log into Azure using the 'az login' command. ${NC}"
  echo
  echo -e "${RED}  If you haven't done these things yet, press [Ctrl+c]${NC}"
  echo -e "${RED}  to exit this script and create the file and/or login to Azure. ${NC}"
  echo
  echo -e "${RED}  If you have a completed course environment config file and${NC}"
  echo -e "${RED}  you have logged into Azure using the 'az login' command,${NC}"
  echo -e "${RED}  Press [Enter] to continue${NC}"
  echo
  echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
  echo
  read
}


retrieve_fileshare_storage_key() {
  echo -e "${LTBLUE}Retrieving the Storage Account Key ...${NC}"
  echo -e "${LTCYAN}(saved in ./azure_storage_key.txt)${NC}"
  ./get-azure-storage-key.sh ${SOURCE_FILESHARE_STORAGE_ACCOUNT} > ./azure_storage_key.txt
  echo
}

create_storage_fileshare() {
  echo -e "${LTBLUE}Creating the Azure File Share ...${NC}"
  ./create-azure-fileshare.sh ${SOURCE_FILESHARE_NAME}
  echo
}

upload_installer_archives_to_fileshare() {
  echo -e "${LTBLUE}Uploading Installer Archive Files to the Azure File Share ...${NC}"
  ./upload-to-azure-fileshare.sh ${COURSE_INSTALLER_ARCHIVE_FILES_DIR} ${SOURCE_FILESHARE_STORAGE_ACCOUNT}:${SOURCE_FILESHARE_NAME}
}

next_steps() {
  echo
  echo -e "${ORANGE}Next Steps:${NC}"
  echo -e "${ORANGE}------------------------------------------------------${NC}"
  echo -e "${ORANGE} Step 2: Create the VM disk image for the course${NC}"
  echo -e "${ORANGE}         (This must be done manually using the create-azure-vm tool set)${NC}"
  echo
  echo -e "${ORANGE} Step 3: Configure the template VM${NC}"
  echo -e "${ORANGE}         (This must be done manually following the steps in the HowTo)${NC}"
  echo
  echo -e "${ORANGE} Step 4: Create the course environment in Azure${NC}"
  echo -e "${ORANGE}         (./create-course-environment-in-azure.sh <course_env_config_file>)${NC}"
  echo
  echo -e "${ORANGE} Step 5: Create the student VMs${NC}"
  echo -e "${ORANGE}         (This must be done manually using the create-azure-vm tools)${NC}"
  echo
  echo -e "${ORANGE} Step 6: Launch the student VMs${NC}"
  echo -e "${ORANGE}         (./launch-course-vms.sh <course_vm_config_file_directory>)${NC}"
  echo
  echo -e "${ORANGE} Step 7: Teach the course${NC}"
  echo
  echo -e "${ORANGE} Step 8: Remove the course lab environment from Azure${NC}"
  echo -e "${ORANGE}         (./delete-course-env-from-azure.sh <course_env_config_file>)${NC}"
  echo
  echo -e "${ORANGE} Step 9: Check Azure to make sure the lab environment is gone${NC}"
  echo -e "${ORANGE}------------------------------------------------------${NC}"
  echo
}

###############################################################################

main() {
  echo
  echo -e "${LTBLUE}######################################################################${NC}"
  echo -e "${LTBLUE}  Performing Step 1 of the lab environment creation process in Azure${NC}"
  echo -e "${LTBLUE}######################################################################${NC}"
  echo

  do_this_first
  retrieve_fileshare_storage_key
  create_storage_fileshare
  upload_installer_archives_to_fileshare

  next_steps

  echo
}

main ${*}


