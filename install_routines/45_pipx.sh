#!/bin/bash
# install_routines/45_pipx.sh
# Installs pipx, the recommended tool for Python CLI applications.

set -e
echo "Installing pipx..."

# The python3-pip package is a prerequisite for pipx
sudo apt-get update
sudo apt-get install -y python3-pip

if ! command -v pipx &>/dev/null; then
    echo "Installing pipx via pip..."
    # Install pipx for the current user
    python3 -m pip install --user pipx
    # Add pipx to the user's PATH
    python3 -m pipx ensurepath
    echo "pipx installed successfully."
else
    echo "pipx is already installed."
fi

pipx --version
