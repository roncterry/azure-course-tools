# Introduction

The tools in this project help you to more easily manage training course lab environments in Azure.

Additional tools that are useful to use in conjunction with these tools (also defined in the **https://github.com/roncterry/create-azure-vm** git repository).




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


# Use the *delete-course-env-from-azure.sh* Script

## Intro:

This command is used to delete a course lab environment from Azure that was created by the `create-course-env-in-azure.sh` script. It requires you to provide `course-environment.dfg` config file. 



## Usage:
```
delete-course-env-from-azure.sh <COURSE_ENVIRONMENT_CONFIG_FILE> 
```

