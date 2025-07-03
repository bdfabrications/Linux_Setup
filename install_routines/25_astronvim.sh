#!/bin/bash
# install_routines/25_astronvim.sh
# Installs AstroNvim and deploys the user's custom configuration.

set -e
echo "Starting AstroNvim installation and configuration..."

# --- Get Repo Root ---
# This allows the script to find your user config regardless of where it's run from.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASTRO_USER_CONFIG_SOURCE="$REPO_DIR/astronvim/lua/user"

# --- Configuration Paths ---
NVIM_CONFIG_DIR="$HOME/.config/nvim"
ASTRO_USER_CONFIG_DEST="$NVIM_CONFIG_DIR/lua/user"

# --- Check for Neovim ---
if ! command -v nvim &>/dev/null; then
    echo "[Error] Neovim is not installed or not in PATH. Please run the Neovim installer first." >&2
    exit 1
fi

# --- Install AstroNvim ---
if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "Backing up existing Neovim configuration to $NVIM_CONFIG_DIR.bak..."
    mv "$NVIM_CONFIG_DIR" "$NVIM_CONFIG_DIR.bak_$(date +%s)"
fi

echo "Cloning AstroNvim starter template..."
git clone --depth 1 https://github.com/AstroNvim/template "$NVIM_CONFIG_DIR"

echo "AstroNvim template installed."

# --- Deploy Custom User Configuration ---
echo "Deploying custom AstroNvim user configuration..."
if [ -d "$ASTRO_USER_CONFIG_SOURCE" ]; then
    # Remove the placeholder user directory from the template
    rm -rf "$ASTRO_USER_CONFIG_DEST"
    # Create a symlink to your custom configuration
    ln -sfn "$ASTRO_USER_CONFIG_SOURCE" "$ASTRO_USER_CONFIG_DEST"
    echo "Successfully linked your custom user configuration."
else
    echo "[Warning] No custom user configuration found at $ASTRO_USER_CONFIG_SOURCE. Skipping deployment."
fi

echo "AstroNvim installation and configuration complete."
echo "Run 'nvim' and ':Lazy sync' to complete the setup."
