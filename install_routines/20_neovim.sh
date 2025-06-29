#!/bin/bash
# install_routines/20_neovim.sh
# Installs a specific version of Neovim from its GitHub releases.

set -e
echo "Starting Neovim v0.11.0 installation..."

# --- Cleanup: Remove distro-packaged neovim to avoid conflicts ---
echo "Checking for and removing any existing apt-managed neovim..."
sudo apt remove --purge neovim neovim-runtime -y || true

# --- Installation ---
NVIM_VERSION="v0.11.0"

# Do nothing if the correct version is already installed.
if command -v nvim &>/dev/null && [[ "$(nvim --version | head -n 1)" == *"${NVIM_VERSION#v}"* ]]; then
	echo "Neovim ${NVIM_VERSION} already appears to be installed."
	exit 0
fi

echo "Cleaning up any potential old manual Neovim installations..."
sudo rm -f /usr/local/bin/nvim
sudo rm -rf /usr/local/lib/nvim* # Clean up old lib directories

# Set architecture for download URL
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
	NVIM_FILENAME_ARCH="linux64"
else
	echo "[Error] This script currently only supports x86_64 for Neovim download." >&2
	exit 1
fi

NVIM_TARBALL="nvim-${NVIM_FILENAME_ARCH}.tar.gz"
NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"

echo "Downloading ${NVIM_TARBALL} from GitHub..."
# Use /tmp for downloads to ensure it's cleaned up on reboot
curl -fLo "/tmp/${NVIM_TARBALL}" "${NVIM_DOWNLOAD_URL}"

echo "Extracting Neovim to /usr/local/lib"
sudo tar xzf "/tmp/${NVIM_TARBALL}" -C /usr/local/lib/

# The extracted folder is nvim-linux64, so we link from there
sudo ln -sfn "/usr/local/lib/nvim-linux64/bin/nvim" "/usr/local/bin/nvim"

echo "Cleaning up downloaded file..."
rm -f "/tmp/${NVIM_TARBALL}"

echo "Neovim ${NVIM_VERSION} installed successfully."
nvim --version | head -n 1
