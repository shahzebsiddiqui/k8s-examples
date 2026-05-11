#!/bin/bash

# Resolve the directory of the script
MODULEFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$MODULEFILES_DIR/.pyenv"

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR" 2>&1 1>/dev/null
    source "$VENV_DIR/bin/activate" 2>&1 1>/dev/null
    echo "Virtual environment created and activated."
    echo "Installing lmodule..."
    pip install lmodule 2>&1 1>/dev/null
else
    echo "Virtual environment already exists. Activating..."
    source "$VENV_DIR/bin/activate" 2>&1 1>/dev/null
fi

mod_dir=$MODULEFILES_DIR/modules/rocky8/Other
module use $mod_dir
mod_template_dir=$MODULEFILES_DIR/modules/template
module use $mod_template_dir
echo "Setting MODULEPATH to $mod_dir"
echo "Setting MODULEPATH to $mod_template_dir"

# set LMOD_CONFIG_DIRECTORY to root of modulefiles directory so we can source the script
#export LMOD_CONFIG_DIRECTORY=$MODULEFILES_DIR/lmod_config
source $MODULEFILES_DIR/lmod_config/lmod_setup.sh

