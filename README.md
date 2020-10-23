# Introduction

The tools in this project help you to more easily manage training course lab environments in Azure.

Additional tools that are useful to use in conjunction with these tools (also defined in the **https://github.com/roncterry/create-azure-vm** git repository).

## TL:DR
The assumed workflow for using these tools to create, launch and then remove a course is as follows:

1. You have created a template course vhd file (using the **create-azure-vm** tools)
2. You create a new course environment by making a copy of the **course-environment.cfg.template** file and edit it to match for your new course
3. You create the new course environment by running: `create-course-env-in-azure.sh <your_course_config_file>` 
4. You copy your template course vhd file from where it was created to your new course environment: `copy-image-to-new-azure-container.sh <source_storage_account>:<source_container>:<source_image> <destination_storage_account>:<destination_container>` (You can monitor the progress of the copy using: `show-image-copy-status.sh <destination_storage_account>:<destination_container>:<destination_image>`)
5. Create student VM definition .azvm files (from the **create-azure-vm** tools) for each student and place them all in a directory
6. Launch the course VMs by running: `launch-course-vms.sh <path_to_dir_containing_student_vm_defs>`
7. Teach the course
8. Remove the course VMs by running: `remove-course-vms.sh <path_to_dir_containing_student_vm_defs>`
9. If no longer needed, remove the course environment in Azure by running: `remove-course-environment-from-azure.sh <your_course_config_file>`


There are also tools that can aid you in creating the template vhd file. The could be used in the following order:

1. Create your initial VM for your template course vhd using the **create-azure-vm** tools
2. Create an Azure CIFS fileshare to upload your course installer into using: `create-azure-fileshare.sh <storage_account>:<file_share>`
3. Upload your course installer into the fileshare using: `upload-to-azure-fileshare.sh <upload_files_dir> <storage_account>:<file_share>`
4. Copy the `mount-azure-fileshare.sh` script into your template course VM and use it to mount the Azure CIFS fileshare: `mount-azure-fileshare.sh <storage_account>:<file_share> <mount_point`> 


# The course-environment.cfg Configuration File

A `course-environment.cfg` file is the file used to describe a training lab environment that is to be created in Azure. Each course that will be taught has a single lab environment configuration file. Each instance of the lab environment (i.e. each student's lab environment VM) will described by a `vm-config.azvm` file using the **create-azure-vm** (**https://github.com/roncterry/create-azure-vm**) tool set.

The configuration options are set as variable=value pairs. The following are the configuration options that must be set:

**REGION_LIST**

Space delimited list of regions in which the student lab environments for the course will be created.

Default: westus


**COURSE_RESOURCE_GROUP_BASE_NAME**

Resource Group Base Name in which to create the course

The Region name will be appended to this name to produce the actual Course Resource Group Name for that particular region.

Hint: Set this to something that matches the course and is unique

No default. This is a required value.


**COURSE_STORAGE_ACCOUNT_BASE_NAME**

Storage Account Base Name where new disks will be created

The Region name will be appended to this name to produce the actual Course Storage Account Name for that particular region.

This name must be a valid DNS name and therefore should be all lower case and contain no spaces and no dashes or underscores.

Hint: Set this to something that matches the Resource Group and is unique

No default. This is a required value.


**COURSE_STORAGE_CONTAINER_NAME**

The name of the storage container in which to create the new course disk images. 

This will be the same in each of the region specific course storage accounts created in each region.  

Hint: Set this to something descriptive like: course-disks

This is a required value. Default: course-disks


**IMAGE_SOURCE_RESOURCE_GROUP**

Resource Group from which the source course VM disk image file
will be copied. 

Default: Labmachine_Image


**IMAGE_SOURCE_STORAGE_ACCOUNT**

Storage account where the source course disk image file resides.

Default: labmachineimages


**IMAGE_SOURCE_CONTAINER_NAME**

Name of Storage Container that contains the source course disk image file.

Default: labmachine-images


**IMAGE_SOURCE_IMAGE_FILE**

Source course image file to copy into the course disk image container. This is the vhd image file used to create the lab environment/student VMs. 

No default. This is a required value.


**IMAGE_SOURCE_IMAGE_URI**

Source image URI for the source course image file

This is the URI to the image used to create the VM. 
This is constructed using the following variables from above:

 IMAGE_SOURCE_STORAGE_ACCOUNT

 IMAGE_SOURCE_STORAGE_CONTAINER_NAME
 
 IMAGE_SOURCE_IMAGE_FILE
 

FYI, This can also be found in the blobUri field of the source image.

There is no default value, however using the one that is pre-populated is suggested.


**SOURCE_FILESHARE_STORAGE_ACCOUNT**

File Share from which the course installer was installed into the course source disk image

No default value. This is a required value.


**SOURCE_FILESHARE_NAME**

File Share from which the course installer was installed into the course source disk image

No default value. This is a required value.


**SOURCE_FILESHARE_URI**

This is the URI to the file share used to install course lab environment. 

This is constructed using the following variables from above:

 SOURCE_FILESHARE_STORAGE_ACCOUNT
 
 SOURCE_FILESHARE_NAME
 
There is no default value, however using the one that is pre-populated is suggested.


**COURSE_INSTALLER_ARCHIVE_FILES_DIR**

Directory containing the course installer archive files to be uploaded 

No default value. This is a required value.





# Use the *create-course-env-in-azure.sh* Script

## Intro:

This command is used to create a course lab environment in Azure as defined by a `course-environment.cfg` file: 

## Usage:
```
create-course-in-azure.sh <COURSE_ENVIRONMENT_CONFIG_FILE> 
```



# Use the *remove-course-env-from-azure.sh* Script

## Intro:

This command is used to delete a course lab environment from Azure that was created by the `create-course-env-in-azure.sh` script. It requires you to provide `course-environment.dfg` config file. 

## Usage:
```
remove-course-env-from-azure.sh <COURSE_ENVIRONMENT_CONFIG_FILE> [delete-source-vhd] [delete-source-fileshare] 
```



# Use the *launch-course-vms.sh* Script

## Intro:

This command is used to launch all of the student course VMs for a course lab environment. The student specific VM config files (`vm-config.azvm`) files should all reside in a single directory using a directory structure like the following: 

```
<course>/
        |-student01.azvm
        |-student01.azvm
        |-student03.azvm
        |-...
```

## Usage:
```
launch-course-vms.sh <COURSE_VM_FILE_DIRECTORY> 
```



# Use the *remove-course-vms.sh* Script

## Intro:

This command is used to remove all of the student course VMs for a course lab environment that were launched using the launch-course-vms.sh script. Yo must provide the script with the same directory containing the VM config files as was used to launch the VM. 


## Usage:
```
remove-course-vms.sh <COURSE_VM_FILE_DIRECTORY> 
```



# Use the *get-azure-storage-key.sh* Script

## Intro:

This command is used to retrieve the storage key for an Azure Storage Account. The key can then be used to access file in the storage account such as mounting an Azure CIFS File Share. 


## Usage:
```
get-azure-storage-key.sh <STORAGE_ACCOUNT> 
```

Where `<STORAGE_ACCOUNT>` is the name of the Storage Account that's key you are retrieving.



# Use the *copy-image-to-new-azure-container.sh* Script

## Intro:

This command is used to copy an image (blob) from one storage container to another. The source and destination container can be in different storage accounts/resource groups/regions. 


## Usage:
```
copy-image-to-new-azure-container.sh <SOURCE_STORAGE_ACCOUNT>:<SOURCE_CONTAINER>:<SOURCE_FILE> <DESTINATION_STORAGE_ACCOUNT>:<DESTINATION_CONTAINER>[:<DESTINATION_FILE>] 
```

The DESTINATION_FILE is optional. If not supplied it will be named the same as the source file.



# Use the *show-image-copy-status.sh* Script

## Intro:

This command is used to display the status of an image (blob) copy job. 


## Usage:
```
show-image-copy-status.sh <DESTINATION_STORAGE_ACCOUNT>:<DESTINATION_CONTAINER>:<DESTINATION_FILE> 
```


# Use the *create-azure-fileshare.sh* Script

## Intro:

This command is used to create a CIFS File Share in an Azure Storage Account that will be used to contain the lab environment installer package archive files. This file share will later be mounted in the template VM to install the course lab environment. 


## Usage:
```
create-azure-fileshare.sh <STORAGE_ACCOUNT>:<FILE_SHARE> 
```

Where `<STORAGE_ACCOUNT>` is the Storage Account name that will contain the CIFS File Share and `<FILE_SHARE>` is the name of the File Share to be created.



# Use the *mount-azure-fileshare.sh* Script

## Intro:

This command is used to mount the Azure CIFS File Share on a Linux host. It is intended to be run from within the template VM when it is being configured but it could also theoretically be run on any Linux host that has Internet access to mount the Azure CIFS File Share. 


## Usage:
```
mount-azure-fileshare.sh <STORAGE_ACCOUNT>:<FILE_SHARE> <MOUNT_POINT> 
```

Where `<STORAGE_ACCOUNT>` is the Storage Account name that contains the CIFS File Share, `<FILE_SHARE>` is the name of the File Share to be mounted and `<MOUNT_POINT>` is the mount point on which to mount the share.



# Use the *upload-to-azure-fileshare.sh* Script

## Intro:

This command is used to upload file in a specified directory to an Azure CIFS File Share using the Azure API rather then the CIFS protocol. 


## Usage:
```
upload-to-azure-fileshare.sh <UPLOAD_FILES_DIR> <STORAGE_ACCOUNT>:<FILE_SHARE> 
```

Where `<UPLOAD_FILE_DIR>` is the directory containing the files you want to upload,  `<STORAGE_ACCOUNT>` is the Storage Account name that contains the CIFS File Share and `<FILE_SHARE>` is the name of the File Share to upload the files to.



# Use the *upload-vhd-to-azure.sh* Script

## Intro:

This command is used to upload a vhd disk image as a storage blob to a Container in an Azure Storage Account. 

Note: The vhd file must be of a specific size (30GB) and formatted as a fixed vhd file for it to be recognized as a disk image file.


## Usage:
```
upload-vhd-to-azure.sh <VHD_FILE> <STORAGE_ACCOUNT>:<CONTAINER> 
```

Where `<VHD_FILE>` is the VHD file you want to upload,  `<STORAGE_ACCOUNT>` is the Storage Account name that contains the Container and `<CONTAINER>` is the name of the Container to upload the VHD file to.



# Use the *step-01.sh* Script

## Intro:

This command is start of the process of creating a course lab environment in Azure. It is a wrapper around the `get-azure-storage-key.sh`, `create-azure-fileshare.sh` and `upload-to-azure-fileshare.sh` scripts that calls them in order using parameters that are defined in a `course-environment.cfg` file.

It covers the first steps required to create a course lab environment in Azure by creating a CIFS File Share and uploading the lab environment installer package archive files to the CIFS File Share. It is assumed that the lab machine vhd disk image file that will be used as the template for the course template disk image has already been uploaded.

When the script exits it displays the remaining steps required to finish creating/configuring the lab environment, teach the course and then clean up and remove the lab environment form Azure.


## Usage:
```
step-01.sh <COURSE_ENVIRONMENT_CONFIG_FILE> 
```
