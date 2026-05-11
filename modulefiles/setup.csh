#!/bin/csh

# Resolve the directory of the script
set MODULEFILES_DIR=`dirname $0`
set MODULEFILES_DIR=`(cd $MODULEFILES_DIR && pwd)`
set VENV_DIR="$MODULEFILES_DIR/.pyenv"

# Check if the virtual environment directory exists
if ( ! -d "$VENV_DIR" ) then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR" >& /dev/null
    source "$VENV_DIR/bin/activate.csh" >& /dev/null
    echo "Virtual environment created and activated."
    echo "Installing lmodule..."
    pip install lmodule >& /dev/null
else
    echo "Virtual environment already exists. Activating..."
    source "$VENV_DIR/bin/activate.csh" >& /dev/null
endif

set mod_dir="$MODULEFILES_DIR/modules/rocky8/Other"
module use "$mod_dir"
set mod_template_dir="$MODULEFILES_DIR/modules/template"
module use "$mod_template_dir"

echo "Setting MODULEPATH to $mod_dir"
echo "Setting MODULEPATH to $mod_template_dir"

# set LMOD_CONFIG_DIRECTORY to root of modulefiles directory so we can source the script
# This line is commented in the original, so it remains commented.
# setenv LMOD_CONFIG_DIRECTORY "$MODULEFILES_DIR/lmod_config"
source "$MODULEFILES_DIR/lmod_config/lmod_setup.csh"

