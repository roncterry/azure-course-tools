#!/bin/bash
#
# Version: 1.0.0
# Date: 2020-09-18

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

STORAGE_ACCOUNT_NAME=labmachineimages
STORAGE_CONTAINER_NAME=vhds

copy_vhd_to_azure() {
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo -e "${LTBLUE}                  Copying VHD Disk Image To Azure${NC}"
  echo -e "${LTBLUE}===========================================================================${NC}"
  echo

  az storage blob upload \
    --query '{jobID:id}' --output table \
    -t page  \
    -a ${STORAGE_ACCOUNT_NAME} \
    -c ${STORGAE_CONTAINER_NAME} \
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
  echo -e "${GRAY}      --account-name ${STORAGE_ACCOUNT_NAME} \ ${NC}"
  echo -e "${GRAY}      -c ${STORAGE_CONTAINER_NAME} \ ${NC}"
  echo -e "${GRAY}      -n ${VHD_FILE} \ ${NC}"
  echo -e "${GRAY}      --query \'progress:properties.copy.progress}\' \ ${NC}"
  echo -e "${GRAY}      --output table${NC}"
  echo 
  echo -e "${LTPURPLE}     (Ctrl+c quits the command)${NC}"
  echo 
}

main() {
  copy_vhd_to_azure ${*}
  #how_to_show_progress
}

main ${*}
