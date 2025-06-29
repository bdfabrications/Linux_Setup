#!/bin/bash
# install_routines/10_oh_my_posh.sh
# Installs Oh My Posh.

set -e # Exit immediately if a command fails.

echo "Installing Oh My Posh..."

if ! command -v oh-my-posh &>/dev/null; then
	echo "Downloading Oh My Posh..."
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then POSH_ARCH="amd64"; elif [[ "$ARCH" == "aarch64" ]]; then POSH_ARCH="arm64"; else
		echo "[Error] Unsupported architecture: $ARCH for Oh My Posh auto-install." >&2
		exit 1
	fi

	POSH_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${POSH_ARCH}"

	if sudo curl -fLo /usr/local/bin/oh-my-posh "$POSH_URL"; then
		sudo chmod +x /usr/local/bin/oh-my-posh
		echo "Oh My Posh installed to /usr/local/bin."
	else
		echo "[Error] Failed to download Oh My Posh (curl error code $?)." >&2
		exit 1
	fi
else
	echo "Oh My Posh already installed."
fi

echo "Oh My Posh version: $(oh-my-posh --version)"
