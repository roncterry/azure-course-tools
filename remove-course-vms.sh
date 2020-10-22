#!/bin/bash
#
# Version: 1.0.1
# Date: 2020-10-22

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

if which delete-azure-vm.sh > /dev/null
then
  CREATE_AZURE_VM_TOOLS_PATH="$(dirname $(which delete-azure-vm.sh))/"
else
  CREATE_AZURE_VM_TOOLS_PATH="$(ls ../ | grep "delete-azure-vm")/"
fi

usage() {
  echo
  echo "USAGE: ${0} <directory_containing_course_vm_configs>"
  echo
}

if [ -z ${1} ]
then
  usage
  exit 0
fi

if ! [ -d ${1} ]
then
  echo -e "${RED}ERROR: The specified course VM config file directory does not exist. Exiting.${NC}"
  exit 1
else
  export COURSE_CONFIG_DIR="${1}"
fi

if ! ls ${1} | grep -q ".azvm"
then
  echo -e "${RED}ERROR: The course specified VM config file directory does not appear to contain VM config files. Exiting.${NC}"
  exit 1
else
  export VM_FILE_LIST="$(ls ${COURSE_CONFIG_DIR}/*.azvm)"
fi

#############################################################################

delete_course_vms() {
  for VM_FILE in ${VM_FILE_LIST}
  do
    ${CREATE_AZURE_VM_TOOLS_DIR}delete-azure-vm.sh ${VM_FILE} delete-vhd
    echo
  done
}

main() {
  echo 
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo -e "${LTBLUE}                         Deleting Course VMs${NC}"
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo

  delete_course_vms

  echo 
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo -e "${LTBLUE}                              Finished ${GRAY}${VM_NAME}"
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo
}

#############################################################################

main ${*}
