#!/bin/csh

# production path
setenv LMOD_CONFIG_DIRECTORY "/software/lmod_config"

if ( $?MODULEFILES_DIR ) then
 	setenv LMOD_CONFIG_DIRECTORY "$MODULEFILES_DIR/lmod_config"
endif

setenv LMOD_CASE_INDEPENDENT_SORTING "yes"

# Currently not using unique modules for each cluster on shared filesystem. If we decide to go this route, we can enable this option
# setenv LMOD_SYSTEM_NAME `grep 'ClusterName=' /etc/slurm/slurm.conf | sed 's/ClusterName=//'`

# Define the path to the slurm.conf file
set SLURM_CONF_FILE = "/etc/slurm/slurm.conf"

# Check if the file exists and is a regular file
if ( -f "$SLURM_CONF_FILE" ) then
    # If the file exists, run the grep and sed command
    setenv LMOD_SYSHOST `grep 'ClusterName=' "$SLURM_CONF_FILE" | sed 's/ClusterName=//'`
else
    # If the file does not exist, set the variable to 'fsl'
    setenv LMOD_SYSHOST 'fsl'
endif


setenv LMOD_MODULERC "$LMOD_CONFIG_DIRECTORY/modulerc.lua"

setenv LMOD_ADMIN_FILE "$LMOD_CONFIG_DIRECTORY/admin.list"

setenv LMOD_AVAIL_STYLE "grouped:system"

setenv LMOD_RC "$LMOD_CONFIG_DIRECTORY/lmodrc.lua"

setenv LMOD_PACKAGE_PATH "$LMOD_CONFIG_DIRECTORY"
