#!/bin/bash
# Script to create symlinks from the dotfiles repo to the home directory.
# Run this script from WITHIN the dotfiles repository directory.

DOTFILES_DIR=$(pwd) # Get the current directory (where the script is)
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory: $HOME"
echo "Old configs will be backed up to: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to create a symlink, backing up the original if it exists
link_file() {
    local source_file="$1" # File/dir inside dotfiles repo
    local target_link="$2" # Target location in $HOME

    # Check if the source file exists in the repo
    if [ ! -e "$source_file" ]; then
        echo "[Skip] Source $source_file does not exist in dotfiles repo."
        return
    fi

    # If target exists and is not already a symlink to the source
    if [ -e "$target_link" ] && [ "$(readlink "$target_link")" != "$source_file" ]; then
        echo "[Backup] Moving existing $target_link to $BACKUP_DIR"
        mv "$target_link" "$BACKUP_DIR/"
    fi

    # Remove existing symlink if it points elsewhere or is broken
    if [ -L "$target_link" ]; then
        rm "$target_link"
    fi

    # Create the directory for the target link if it doesn't exist (e.g., for .config/nvim)
    mkdir -p "$(dirname "$target_link")"

    # Create the symlink
    echo "[Link] Linking $target_link -> $source_file"
    ln -sf "$source_file" "$target_link"
}

# --- Link configuration files ---
link_file "$DOTFILES_DIR/bashrc_config"      "$HOME/.bashrc"
link_file "$DOTFILES_DIR/poshthemes"         "$HOME/.poshthemes"
link_file "$DOTFILES_DIR/config_nvim"        "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/bin"                "$HOME/bin"
# Add other files/dirs to link here if needed

echo "Symlinking complete. You may need to run 'source $HOME/.bashrc'."
