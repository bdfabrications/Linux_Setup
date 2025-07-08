#!/bin/bash
# install_routines/70_terminal_enhancements.sh
# Installs terminal workflow enhancements: eza and zoxide.

set -e
echo "Installing terminal enhancements..."

# --- Install eza ---
if ! command -v eza &>/dev/null; then
    echo "Installing eza (a modern ls replacement)..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
    echo "eza installed successfully."
else
    echo "eza is already installed."
fi

# --- Install zoxide ---
if ! command -v zoxide &>/dev/null; then
    echo "Installing zoxide (a smarter cd command)..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    echo "zoxide installed successfully."
else
    echo "zoxide is already installed."
fi
