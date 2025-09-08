#!/bin/bash
#
# switch_to.sh - Switches the environment between stable and experimental.
#

# --- Configuration ---
TARGET_DIR_NAME="$1"

if [ "$TARGET_DIR_NAME" != "Linux_Stable" ] && [ "$TARGET_DIR_NAME" != "Linux_Experimental" ]; then
    echo "Usage: switch_to.sh [Linux.Stable|Linux.Experimental]"
    exit 1
fi

SOURCE_DIR="/home/crustysamwich/projects/Linux_Setup/$TARGET_DIR_NAME"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Target directory '$SOURCE_DIR' not found."
    exit 1
fi

echo "Switching to the '$TARGET_DIR_NAME' configuration..."

# --- Link Shell Configs ---
echo "Linking shell configuration..."
ln -sfn "$SOURCE_DIR/shell_config/bash_aliases" "$HOME/.bash_aliases"
ln -sfn "$SOURCE_DIR/shell_config/bashrc_config" "$HOME/.bashrc_config"

# --- Link Neovim Config ---
echo "Linking Neovim configuration..."
ln -sfn "$SOURCE_DIR/astronvim" "$HOME/.config/nvim"

# --- Link Shell Theming ---
echo "Linking Oh My Posh themes..."
ln -sfn "$SOURCE_DIR/shell_theming/poshthemes" "$HOME/.poshthemes"

echo ""
echo "Successfully switched to the '$TARGET_DIR_NAME' environment."
echo "Please restart your shell for all changes to take effect."
