#!/bin/bash
# Setup script for WSL (Ubuntu/Debian-based) environments.

set -e
echo "--- Starting WSL Development Environment Setup ---"

# --- Helper Functions ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- Ensure Script is Run from Repo Root ---
# UPDATED PATH
if [ ! -f "./setup_scripts/install_links.sh" ]; then
	echo "[Error] Please run this script from the root directory of the repository." >&2
	exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"

# --- 1. Install System Dependencies ---
echo "[1/7] Updating and installing dependencies via apt..."
sudo apt update
sudo apt install -y git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip
echo "Removing old package manager Neovim..."
sudo apt remove --purge neovim neovim-runtime -y || true
if ! command_exists node; then
	echo "Installing Node.js and npm via NodeSource..."
	if ! command_exists curl; then sudo apt install -y curl; fi
	NODE_MAJOR=20
	curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | sudo -E bash -
	sudo apt install -y nodejs
fi
if command_exists fdfind && ! command_exists fd; then
	echo "Creating 'fd' symlink..."
	sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi
echo "System dependencies installed." && echo ""

# --- 2. Install Oh My Posh ---
echo "[2/7] Installing Oh My Posh..."
if ! command_exists oh-my-posh; then
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then POSH_ARCH="amd64"; elif [[ "$ARCH" == "aarch64" ]]; then POSH_ARCH="arm64"; else
		echo "[Error] Unsupported arch: $ARCH" >&2
		exit 1
	fi
	sudo curl -fLo /usr/local/bin/oh-my-posh "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${POSH_ARCH}"
	sudo chmod +x /usr/local/bin/oh-my-posh
fi
echo "Oh My Posh version: $(oh-my-posh --version)" && echo ""

# --- 3. Install Neovim v0.11.0 ---
echo "[3/7] Installing Neovim v0.11.0..."
NVIM_VERSION="v0.11.0"
if ! (command_exists nvim && [[ "$(nvim --version | head -n 1)" == *"${NVIM_VERSION#v}"* ]]); then
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then NVIM_FILENAME_ARCH="linux-x86_64"; elif [[ "$ARCH" == "aarch64" ]]; then NVIM_FILENAME_ARCH="linux-aarch64"; else
		echo "[Error] Unsupported arch: $ARCH" >&2
		exit 1
	fi
	NVIM_TARBALL="nvim-${NVIM_FILENAME_ARCH}.tar.gz"
	NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"
	echo "Downloading Neovim..."
	curl -fLo "${NVIM_TARBALL}" "${NVIM_DOWNLOAD_URL}"
	echo "Extracting Neovim..."
	sudo tar xzf "${NVIM_TARBALL}" -C /usr/local/
	sudo ln -sf "/usr/local/nvim-${NVIM_FILENAME_ARCH}/bin/nvim" /usr/local/bin/nvim
	rm -f "${NVIM_TARBALL}"
fi
echo "Neovim version: $(nvim --version | head -n 1)" && echo ""

# --- 4. Install Ollama ---
echo "[4/7] Installing Ollama..."
if ! command_exists ollama; then
	curl -fsSL https://ollama.com/install.sh | sh
fi
echo "Ollama installed." && echo ""

# --- 5. Link Dotfiles ---
echo "[5/7] Linking dotfiles..."
# UPDATED PATH
bash "$REPO_ROOT_DIR/setup_scripts/install_links.sh"
echo "Dotfiles linked." && echo ""

# --- 6. Setup Neovim Plugins ---
echo "[6/7] Setting up Neovim plugins (Lazy sync)..."
nvim --headless "+Lazy! sync" +qa || echo "[Warning] Lazy sync failed. Run ':Lazy sync' in nvim."
echo "Lazy sync complete." && echo ""

# --- 7. Install Mason Tools ---
echo "[7/7] Installing Neovim Mason tools..."
nvim --headless "+MasonInstallAll" +qa || echo "[Warning] MasonInstallAll failed. Run ':Mason' in nvim."
echo "Mason tool installation complete." && echo ""

# --- Finish ---
echo "✅ WSL Setup Complete! Please RESTART YOUR WSL SESSION."
exit 0
