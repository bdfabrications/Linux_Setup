Setup Scripts

This directory contains the core installation and deployment scripts for the entire my_linux_setup environment. These scripts are designed to automate the setup of a new machine.

setup_linux.sh - Full Setup for Native Linux

When to Use: Use this script ONCE on a fresh, new native Linux installation (Debian, Ubuntu, Fedora, or Arch-based) to bootstrap your entire development environment from scratch.

What It Does:

    Detects your Linux distribution.

    Installs all necessary system packages and dependencies (git, curl, python, fzf, etc.) using the appropriate package manager.

    Installs specific versions of key tools like Neovim (from source), Oh My Posh, and Node.js to ensure consistency across machines.

    Installs Ollama for local AI models.

    Calls install_links.sh to deploy all your personal configurations.

    Bootstraps Neovim by installing all plugins via Lazy.nvim.

How to Run:

# 1. Clone the repository

# git clone https://github.com/bdfabrications/my_linux_setup.git

cd my_linux_setup

# 2. Make the script executable

chmod +x setup_scripts/setup_linux.sh

# 3. Run the setup

./setup_scripts/setup_linux.sh

    Warning: This script will install numerous packages and requires sudo privileges. Review its contents before running on a critical system.

setup_wsl.sh - Full Setup for WSL

When to Use: Use this script ONCE on a fresh WSL (Windows Subsystem for Linux) instance, specifically one based on Debian or Ubuntu.

What It Does:
This script is nearly identical to setup_linux.sh but is optimized specifically for a WSL environment. It performs all the same steps: dependency installation, tool setup, dotfile linking, and Neovim bootstrapping.

How to Run:
The process is the same as the native Linux script. From within the cloned repository root:
Bash

chmod +x setup_scripts/setup_wsl.sh
./setup_scripts/setup_wsl.sh

install_links.sh - Link Configurations

When to Use: Use this script on a machine where you have already installed all the dependencies manually, or after you have pulled changes from Git and want to simply update your configuration links. This script is the "heart" of the setup and is called automatically by the other two scripts.

What It Does:
This script's only job is to create symbolic links from the configuration files and scripts in this repository to the correct locations in your home directory (e.g., ~/.bashrc_config, ~/.config/nvim, ~/bin/).

How to Run:

chmod +x setup_scripts/install_links.sh
./setup_scripts/install_links.sh
