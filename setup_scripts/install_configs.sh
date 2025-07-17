#!/bin/bash
#
# install_configs.sh - Sets up default user configuration templates.
# Iterates through all project directories, finds `config.example` files,
# and copies them to the corresponding ~/.config/ directory if no user
# configuration already exists.

set -euo pipefail

# --- Configuration and Helper Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJECTS_ROOT="$(cd "$SCRIPT_DIR/.." &>/dev/null && pwd)"

# Define logging functions for clear user feedback.
log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_skip() { echo -e "\033[1;33m[SKIP]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }

# --- Main Logic ---
log_info "Searching for configuration templates to install..."

# Loop through all immediate subdirectories in the projects root.
# This is more robust than looping through '*/'.
find "$PROJECTS_ROOT" -mindepth 1 -maxdepth 1 -type d | while read -r project_path; do
    project_name=$(basename "$project_path")
    example_config_file="$project_path/config.example"

    # Check if a config.example file exists in the directory.
    if [ -f "$example_config_file" ]; then
        config_dir_name="$project_name"
        
        # Handle special directory names if necessary.
        # This makes the script more adaptable.
        if [ "$project_name" == "ollama_chat" ]; then
            config_dir_name="ollama_helper"
        fi

        user_config_dir="$HOME/.config/$config_dir_name"
        user_config_file="$user_config_dir/config"

        # Create the target directory in ~/.config if it doesn't exist.
        mkdir -p "$user_config_dir"

        # Copy the template ONLY if the user configuration does not already exist.
        if [ ! -f "$user_config_file" ]; then
            log_info "Installing template for '$project_name' to '$user_config_file'"
            cp "$example_config_file" "$user_config_file"
        else
            log_skip "User config for '$project_name' already exists at '$user_config_file'. Skipping."
        fi
    fi
done

log_success "Configuration template setup complete."
