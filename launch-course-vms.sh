#!/bin/bash
#
# Version: 2.0.0
# Date: 2022-04-28

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

if which create-azure-vm.sh > /dev/null
then
  CREATE_AZURE_VM_TOOLS_PATH="$(dirname $(which create-azure-vm.sh))/"
elif [ -e create-azure-vm.sh ]
then
  CREATE_AZURE_VM_TOOLS_PATH="./"
else
  CREATE_AZURE_VM_TOOLS_PATH="../$(ls ../ | grep "create-azure-vm")/"
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

case ${1} in
  help|-h|--help)
    usage
    exit 0
  ;;
  *)
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
  ;;
esac


#############################################################################

launch_course_vms() {
  for VM_FILE in ${VM_FILE_LIST}
  do
    ${CREATE_AZURE_VM_TOOLS_PATH}create-azure-vm.sh ${VM_FILE}
    echo
  done
}

launch_course_vms_tmux() {
  for VM_FILE in ${VM_FILE_LIST}
  do
    local THIS_VM_NAME=$(grep "^VM_NAME" ${VM_FILE} | cut -d = -f 2 | sed 's/"//g')
    echo -e "${LTBLUE}Creating:${NC} ${THIS_VM_NAME}"
    test -d ./logs || mkdir logs
    tmux new -s azvm_create-${THIS_VM_NAME} -d "${CREATE_AZURE_VM_TOOLS_PATH}create-azure-vm.sh ${VM_FILE}"\; pipe-pane "cat >> logs/azvm_create-${THIS_VM_NAME}.log"
    #tmux new -s azvm_create-${THIS_VM_NAME} -d "${CREATE_AZURE_VM_TOOLS_PATH}create-azure-vm.sh ${VM_FILE}"
  done

  echo
  echo -e "${PURPLE}========================================================${NC}"
  echo -e "${PURPLE}               VM Creation Sessions${NC}"
  echo -e "${PURPLE}========================================================${NC}"
  tmux list-sessions | grep "azvm_create-" | cut -d : -f 1
  echo -e "${PURPLE}========================================================${NC}"
  echo
  echo -e "${ORANGE}------------------------------------------------------------------------------${NC}"  
  echo
  echo -e "${ORANGE}To disply the current sessions enter:${NC} tmux list-sessions | grep \"azvm_create-\"${NC}"
  echo
  echo -e "${ORANGE}To connect to a specific session enter:${NC} tmux attach-session -t <session_name>${NC}"
  echo -e "${ORANGE} (to detach from the session press:${NC} Ctrl+b d)${NC}" 
  echo
  echo -e "${ORANGE}Live logging of VM creation is sent to the ./logs/ directory.${NC}"
  echo
  echo -e "${ORANGE}------------------------------------------------------------------------------${NC}"  
  echo
}

main() {
  echo 
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo -e "${LTBLUE}                         Launching Course VMs${NC}"
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo

  if which tmux > /dev/null
  then
    launch_course_vms_tmux
  else
    launch_course_vms
  fi

  echo 
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo -e "${LTBLUE}                              Finished ${GRAY}${VM_NAME}"
  echo -e "${LTBLUE}#######################################################################${NC}"
  echo
}

#############################################################################

main ${*}
