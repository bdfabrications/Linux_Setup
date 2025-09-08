#!/bin/bash
# install_routines/15_tmux.sh
# Installs tmux.

set -e # Exit immediately if a command fails.

echo "Installing tmux..."

if ! command -v tmux &>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y tmux
    echo "tmux installed successfully."
else
    echo "tmux is already installed."
fi
