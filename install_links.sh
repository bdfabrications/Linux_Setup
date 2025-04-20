#!/bin/bash
# Script to create symlinks from the dotfiles repo to the home directory.
# Run this script from WITHIN the dotfiles repository directory.

# Get the absolute path to the directory where this script resides
# This makes the script runnable from anywhere inside the repo, not just the root
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Define backup directory using HOME variable for portability
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "Dotfiles directory: $DOTFILES_DIR"
echo "Home directory:     $HOME"
echo "Backing up existing files (if any) to: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to create a symlink, backing up the original if it exists
link_file() {
    local source_file="$1" # File/dir inside dotfiles repo (absolute path)
    local target_link="$2" # Target location in $HOME (absolute path)

    # Ensure source path is absolute (it should be due to DOTFILES_DIR)
    if [[ "$source_file" != /* ]]; then
        echo "[Error] Source path '$source_file' must be absolute." >&2
        return 1
    fi

    # Ensure target path is absolute (it should be using $HOME)
    if [[ "$target_link" != /* ]]; then
        echo "[Error] Target path '$target_link' must be absolute." >&2
        return 1
    fi

    # Check if the source file/directory exists in the repo
    if [ ! -e "$source_file" ]; then
        echo "[Skip] Source '$source_file' does not exist."
        return # Skip if source doesn't exist
    fi

    # If target exists AND is not a symlink OR is a symlink pointing elsewhere
    if [ -e "$target_link" ] && [ ! -L "$target_link" ]; then
        echo "[Backup] Moving existing file/directory '$target_link' to '$BACKUP_DIR/'"
        mv "$target_link" "$BACKUP_DIR/"
    elif [ -L "$target_link" ] && [ "$(readlink "$target_link")" != "$source_file" ]; then
        echo "[Backup] Moving existing symlink '$target_link' to '$BACKUP_DIR/'"
        # Just remove incorrect links instead of backing them up? Let's remove.
        echo "[Remove] Removing incorrect symlink '$target_link'"
        rm "$target_link"
    fi

    # Remove broken symlink if it exists at target
    if [ -L "$target_link" ] && [ ! -e "$target_link" ]; then
        echo "[Remove] Removing broken symlink '$target_link'"
        rm "$target_link"
    fi

    # Create the parent directory for the target link if it doesn't exist
    # (e.g., ~/.config/ before linking ~/.config/nvim)
    mkdir -p "$(dirname "$target_link")"

    # Create the symlink if target doesn't exist (or was just removed)
    if [ ! -e "$target_link" ]; then
        echo "[Link] Linking '$target_link' -> '$source_file'"
        ln -s "$source_file" "$target_link"
        if [ $? -ne 0 ]; then
            echo "[Error] Failed to create link for '$target_link'." >&2
            return 1
        fi
        # else
        # If target exists and is already the correct symlink, do nothing.
        # echo "[Skip] Correct link already exists for '$target_link'"
    fi
}

# --- Link configuration files ---
# List all files/dirs to be linked from dotfiles repo to $HOME

echo "Linking core configuration files..."
link_file "$DOTFILES_DIR/bashrc_config" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/bash_aliases" "$HOME/.bash_aliases" # <-- Added this line
link_file "$DOTFILES_DIR/poshthemes" "$HOME/.poshthemes"
link_file "$DOTFILES_DIR/config_nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/bin" "$HOME/bin"

# Add other files/dirs to link here if needed
# Example: link_file "$DOTFILES_DIR/gitconfig_example" "$HOME/.gitconfig"

echo ""
echo "Symlinking complete."
echo "Run 'source ~/.bashrc' or restart your shell for changes to take effect."

exit 0
