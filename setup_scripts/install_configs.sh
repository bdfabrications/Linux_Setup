#!/bin/bash
#
# install_configs.sh - Sets up the user's private configuration files
# from the templates stored in the repository.

# Get the absolute path of the repository's root directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "--- Setting up User Configurations ---"

# --- Function to copy a config template if it doesn't already exist ---
setup_config() {
    local project_name="$1"
    local project_dir="$REPO_DIR/$2"
    local target_config_dir="$HOME/.config/$project_name"
    local target_config_file="$target_config_dir/config"
    local source_config_example="$project_dir/config.example"

    if [ ! -f "$source_config_example" ]; then
        # This project doesn't have a config file, so we skip it.
        return
    fi

    echo "Processing config for: $project_name"
    mkdir -p "$target_config_dir"

    if [ ! -f "$target_config_file" ]; then
        echo "  -> No user config found. Copying template..."
        cp "$source_config_example" "$target_config_file"
        chmod 600 "$target_config_file"
        echo "  -> Template copied to $target_config_file. Please edit it with your personal values."
    else
        echo "  -> User config already exists. Skipping."
    fi
}

# --- Define all projects that have a config.example file ---
setup_config "backup_system" "backup_system"
setup_config "ollama_helper" "shell_helpers/ollama_chat"
setup_config "project_scaffolding" "project_scaffolding"
setup_config "remind_me" "remind_me"
setup_config "rgf_helper" "shell_helpers/rgf_helper"
setup_config "simple_server" "shell_helpers/simple_server"

echo ""
echo "--- User Configuration Setup Complete ---"
