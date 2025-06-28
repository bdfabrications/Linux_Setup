#!/bin/bash
#
# install_links.sh - Creates symlinks from the repository to the user's home directory,
# setting up the entire environment from this repository.
#

# Get the absolute path of the repository's root directory (Linux_Setup)
# This makes the script runnable from anywhere.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# This is the correct target directory we discovered for your system.
TARGET_BIN_DIR="$HOME/bin"

echo "Setting up symlinks..."
echo "Repository is at: $REPO_DIR"
echo "Target bin directory is: $TARGET_BIN_DIR"
echo ""

# Ensure the target bin directory exists for executables
mkdir -p "$TARGET_BIN_DIR"

# --- Link Executable Scripts ---
# For each project, link its main script(s) into the user's bin directory.
echo "Linking executable scripts..."
# remind_me project
ln -sfn "$REPO_DIR/remind_me/remind_me.sh" "$TARGET_BIN_DIR/remind_me"
ln -sfn "$REPO_DIR/remind_me/email_test.sh" "$TARGET_BIN_DIR/email_test"
# backup_system project
ln -sfn "$REPO_DIR/backup_system/backup_dir.sh" "$TARGET_BIN_DIR/backup_dir"
ln -sfn "$REPO_DIR/backup_system/sync_backup.sh" "$TARGET_BIN_DIR/sync_backup"
# system_manager project
ln -sfn "$REPO_DIR/system_manager/update_system.sh" "$TARGET_BIN_DIR/update_system"
# project_scaffolding project
ln -sfn "$REPO_DIR/project_scaffolding/new_pyproject.sh" "$TARGET_BIN_DIR/new_pyproject"
ln -sfn "$REPO_DIR/project_scaffolding/new_webproject.sh" "$TARGET_BIN_DIR/new_webproject"
# shell_helpers project
ln -sfn "$REPO_DIR/shell_helpers/rgf_helper/rgf.sh" "$TARGET_BIN_DIR/rgf"
ln -sfn "$REPO_DIR/shell_helpers/simple_server/serve_here.sh" "$TARGET_BIN_DIR/serve_here"
ln -sfn "$REPO_DIR/shell_helpers/ollama_chat/ollama_chat.sh" "$TARGET_BIN_DIR/ollama_chat"

# --- Link Shell Configs ---
echo "Linking shell configuration..."
ln -sfn "$REPO_DIR/shell_config/bash_aliases" "$HOME/.bash_aliases"
ln -sfn "$REPO_DIR/shell_config/bashrc_config" "$HOME/.bashrc_config"

# --- Link Neovim Config ---
echo "Linking Neovim configuration..."
# This command directly creates the symlink without making a directory first.
ln -sfn "$REPO_DIR/nvim_config" "$HOME/.config/nvim"

# --- Link Shell Theming ---
echo "Linking Oh My Posh themes..."
# This links the entire theme directory into the home folder
ln -sfn "$REPO_DIR/shell_theming/poshthemes" "$HOME/.poshthemes"

echo ""
echo "Symlink setup complete!"
echo "You may need to restart your shell for all changes to take effect."
