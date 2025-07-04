#!/bin/bash
# install_routines/20_neovim.sh
# Installs the LATEST STABLE version of Neovim by targeting the 'stable' tag.

set -e
echo "Starting Neovim installation..."

# --- Dependency Check for jq ---
if ! command -v jq &>/dev/null; then
    echo "jq command not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y jq
fi

# --- Cleanup: Remove distro-packaged neovim to avoid conflicts ---
echo "Checking for and removing any existing apt-managed neovim..."
if command -v nvim &>/dev/null; then
    sudo apt-get remove --purge neovim neovim-runtime -y || true
fi

# --- Installation ---
if command -v nvim &>/dev/null; then
    echo "Neovim already appears to be installed."
    exit 0
fi

# --- Dynamically find the AppImage download URL from the 'stable' release tag ---
API_URL="https://api.github.com/repos/neovim/neovim/releases/tags/stable"

echo "Finding latest stable Neovim AppImage release from the 'stable' tag..."
NVIM_DOWNLOAD_URL=$(curl -s $API_URL | jq -r '.assets[] | select(.name == "nvim.appimage") | .browser_download_url')

if [ -z "$NVIM_DOWNLOAD_URL" ] || [ "$NVIM_DOWNLOAD_URL" == "null" ]; then
    echo "[Error] Could not find the nvim.appimage download URL. The API might have changed." >&2
    exit 1
fi

echo "Found download URL: $NVIM_DOWNLOAD_URL"

# --- Download and Install ---
NVIM_APPIMAGE="nvim.appimage"

echo "Downloading latest stable Neovim AppImage..."
if ! curl -fLo "/tmp/${NVIM_APPIMAGE}" "${NVIM_DOWNLOAD_URL}"; then
    echo "[Error] Failed to download Neovim AppImage." >&2
    exit 1
fi

echo "Making the AppImage executable and moving it to /usr/local/bin/nvim"
sudo chmod +x "/tmp/${NVIM_APPIMAGE}"
sudo mv "/tmp/${NVIM_APPIMAGE}" "/usr/local/bin/nvim"

echo "Neovim installed successfully."
nvim --version | head -n 1
