#!/bin/bash
# install_routines/20_neovim.sh
# Installs Neovim using the direct AppImage download link - works across all distributions.

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

set -e

# Detect distribution if not already done
if [[ -z "$DISTRO_FAMILY" ]]; then
    run_distribution_detection
fi

echo "Starting Neovim installation for $DISTRO_NAME ($DISTRO_FAMILY)..."

# --- Cleanup: Remove any existing Neovim to avoid conflicts ---
echo "Checking for and removing any existing Neovim installations..."

# Remove package-managed Neovim installations (distribution-specific)
case "$DISTRO_FAMILY" in
    debian)
        sudo apt-get remove --purge neovim neovim-runtime -y > /dev/null 2>&1 || true
        ;;
    rhel|fedora)
        sudo $PKG_MANAGER remove -y neovim > /dev/null 2>&1 || true
        ;;
    suse)
        sudo zypper remove -y neovim > /dev/null 2>&1 || true
        ;;
esac

# Remove any manually installed nvim binary
sudo rm -f /usr/local/bin/nvim

# --- Installation ---
# This is the variable where you place your direct download link.
NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.appimage"
NVIM_APPIMAGE_DEST="/usr/local/bin/nvim"

echo "Downloading Neovim AppImage from:"
echo "$NVIM_DOWNLOAD_URL"

# Download the AppImage directly to its final destination
if ! sudo curl -fLo "${NVIM_APPIMAGE_DEST}" "${NVIM_DOWNLOAD_URL}"; then
    echo "[Error] Failed to download Neovim AppImage. Please check the URL or your network." >&2
    exit 1
fi

echo "Making the AppImage executable..."
sudo chmod +x "${NVIM_APPIMAGE_DEST}"

echo "Neovim installed successfully to ${NVIM_APPIMAGE_DEST}"
nvim --version | head -n 1
