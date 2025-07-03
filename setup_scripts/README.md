Setup Scripts

This directory contains the core installation and deployment scripts for the entire my_linux_setup environment. These scripts are designed to automate the setup of a new machine.
setup_linux.sh & setup_wsl.sh - Full Setup

When to Use: Use these scripts ONCE on a fresh system to bootstrap your entire environment. They perform the following actions in order:

    Detect your Linux distribution.

    Install all necessary system packages and dependencies using install_routines. This includes Neovim, Docker, Oh My Posh, etc.

    Run install_configs.sh to automatically set up all necessary user configuration directories and templates in ~/.config/.

    Run install_links.sh to deploy all your personal configurations and scripts by creating symbolic links.

    Run finalize_neovim.sh to bootstrap AstroNvim plugins and tools.

install_configs.sh - Setup User Configs

When to Use: This script is called automatically by the main setup scripts. It can also be run manually if you ever need to restore the default configuration templates.
What It Does: It iterates through all the projects in the repository, checks for config.example files, and copies them to the correct location in ~/.config/ if a user configuration doesn't already exist.
install_links.sh - Link Configurations

When to Use: This script is called automatically by the main setup scripts. You can run it manually after pulling changes from Git to ensure all your symbolic links are up-to-date.
What It Does: This script is the "heart" of the setup. Its only job is to create symbolic links from the files and scripts in this repository to the correct locations in your home directory (e.g., ~/.bashrc_config, ~/.config/nvim, ~/bin/).
finalize_neovim.sh - Bootstrap Neovim

When to Use: Called automatically by the main setup scripts.
What It Does: Runs the final bootstrapping commands for Neovim (:Lazy sync, :MasonInstallAll) to ensure all plugins and language servers are installed and ready.
