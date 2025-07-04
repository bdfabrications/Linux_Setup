#!/bin/bash
# install_routines/20_neovim.sh
# Installs the LATEST STABLE version of Neovim by finding the correct release.

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

# --- Dynamically find the correct AppImage download URL ---
API_URL="https://api.github.com/repos/neovim/neovim/releases"

echo "Finding latest stable Neovim AppImage release from GitHub API..."
# This command finds the first release that is NOT a pre-release and has the nvim.appimage asset
NVIM_DOWNLOAD_URL=$(curl -s $API_URL | jq -r '[.[] | select(.prerelease==false) | .assets[] | select(.name=="nvim.appimage") | .browser_download_url] | .[0]')

if [ -z "$NVIM_DOWNLOAD_URL" ] || [ "$NVIM_DOWNLOAD_URL" == "null" ]; then
    echo "[Error] Could not find a stable nvim.appimage download URL from the GitHub API." >&2
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
