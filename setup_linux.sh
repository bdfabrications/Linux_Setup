#!/bin/bash
# Setup script for Native Linux environments (Debian/Ubuntu, Fedora, Arch).
# Detects distro, installs dependencies, Neovim, Oh My Posh, links dotfiles,
# and sets up Neovim plugins.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Native Linux Development Environment Setup ---"

# --- Helper Functions ---
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

detect_distro() {
	if [ -f /etc/os-release ]; then
		# freedesktop.org and systemd
		. /etc/os-release
		OS=$ID
	elif type lsb_release >/dev/null 2>&1; then
		# linuxbase.org
		OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
	elif [ -f /etc/lsb-release ]; then
		# For some versions of Ubuntu/Debian without lsb_release command
		. /etc/lsb-release
		OS=$DISTRIB_ID | tr '[:upper:]' '[:lower:]'
	elif [ -f /etc/debian_version ]; then
		# Older Debian/Ubuntu/etc.
		OS=debian
	elif [ -f /etc/fedora-release ]; then
		# Older Fedora
		OS=fedora
	elif [ -f /etc/arch-release ]; then
		OS=arch
	else
		# Fallback mechanism
		OS=$(uname -s | tr '[:upper:]' '[:lower:]')
	fi
	echo "$OS"
}

# --- Ensure Script is Run from Repo Root ---
if [ ! -f "./dotfiles/install_links.sh" ]; then
	echo "[Error] Please run this script from the root directory of the cloned repository (e.g., ~/my_linux_setup/)." >&2
	exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"
echo "[Info] Detecting distribution..."
DISTRO=$(detect_distro)
echo "[Info] Detected distribution: $DISTRO"

# --- 1. Install System Dependencies (Distro Specific) ---
echo "[1/6] Installing system dependencies for $DISTRO..."

# Define core dependencies - adjust package names per distro as needed
CORE_DEPS_COMMON="git curl wget build-essential ca-certificates python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip"
CORE_DEPS_DEBIAN="libfuse2"  # For AppImage
CORE_DEPS_FEDORA="fuse-libs" # For AppImage (check exact name if issues)
CORE_DEPS_ARCH="fuse2"       # For AppImage

INSTALL_CMD=""
UPDATE_CMD=""
PACKAGES=""

case "$DISTRO" in
ubuntu | debian | pop)
	UPDATE_CMD="sudo apt update"
	INSTALL_CMD="sudo apt install -y"
	PACKAGES="$CORE_DEPS_COMMON $CORE_DEPS_DEBIAN"
	;;
fedora)
	UPDATE_CMD="sudo dnf check-update" # DNF usually doesn't need explicit update before install
	INSTALL_CMD="sudo dnf install -y"
	# Adjust package names for Fedora if different
	PACKAGES="git curl wget make automake gcc gcc-c++ kernel-devel python3 python3-pip python3-virtualenv figlet fzf ripgrep fd-find unzip ca-certificates $CORE_DEPS_FEDORA"
	;;
arch | manjaro)
	UPDATE_CMD="sudo pacman -Syu --noconfirm"         # Update and install in one typically
	INSTALL_CMD="sudo pacman -S --noconfirm --needed" # --needed prevents reinstalling
	PACKAGES="git curl wget base-devel python python-pip python-venv figlet fzf ripgrep fd unzip ca-certificates $CORE_DEPS_ARCH"
	;;
*)
	echo "[Error] Unsupported distribution: $DISTRO. Cannot install dependencies automatically." >&2
	echo "Please install the following manually: git, curl, wget, build tools (like build-essential/base-devel), python3, pip3, python3-venv, figlet, fzf, ripgrep, fd, unzip, libfuse2/fuse-libs." >&2
	exit 1
	;;
esac

# Update package manager cache (if applicable for distro)
if [ -n "$UPDATE_CMD" ]; then
	echo "Updating package manager..."
	$UPDATE_CMD
fi

# Install packages
echo "Installing core packages..."
$INSTALL_CMD $PACKAGES

# Handle fd symlink (common on Debian/Ubuntu)
if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ]; then
	if command_exists fdfind && ! command_exists fd; then
		echo "[Info] Creating 'fd' symlink for 'fdfind'..."
		if [ ! -L /usr/local/bin/fd ]; then
			sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
		else
			echo "[Info] Symlink /usr/local/bin/fd already exists."
		fi
	fi
fi
echo "System dependencies installed."
echo ""

# --- 2. Install Oh My Posh ---
echo "[2/6] Installing Oh My Posh..."
if ! command_exists oh-my-posh; then
	echo "Downloading Oh My Posh..."
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then POSH_ARCH="amd64"; elif [[ "$ARCH" == "aarch64" ]]; then POSH_ARCH="arm64"; else
		echo "[Error] Unsupported architecture: $ARCH"
		exit 1
	fi
	POSH_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${POSH_ARCH}"
	sudo wget "$POSH_URL" -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh
	echo "Oh My Posh installed to /usr/local/bin."
else
	echo "Oh My Posh already installed."
fi
oh-my-posh --version
echo ""

# --- 3. Install Neovim (Latest Stable AppImage) ---
echo "[3/6] Installing Neovim (Latest Stable AppImage)..."
if ! command_exists nvim; then
	echo "Downloading Neovim AppImage..."
	ARCH=$(uname -m)
	# Primarily for x86_64, might need tar.gz for others
	if [[ "$ARCH" != "x86_64" ]]; then echo "[Warning] Neovim AppImage might not be available for $ARCH. Consider manual install if this fails."; fi

	NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
	curl -Lo nvim.appimage "$NVIM_APPIMAGE_URL"
	if [ $? -ne 0 ]; then
		echo "Error downloading Neovim AppImage."
		exit 1
	fi

	echo "Making AppImage executable and linking to /usr/local/bin/nvim..."
	chmod u+x nvim.appimage
	if [ -f /usr/local/bin/nvim ]; then
		echo "[Info] /usr/local/bin/nvim already exists. Backing up and replacing."
		sudo mv /usr/local/bin/nvim "/usr/local/bin/nvim.bak.$(date +%s)"
	fi
	sudo mv nvim.appimage /usr/local/bin/nvim
	if [ $? -ne 0 ]; then
		echo "Error moving Neovim AppImage."
		exit 1
	fi
	echo "Neovim installed."
else
	echo "Neovim (nvim) already found in PATH."
fi
nvim --version | head -n 1
echo ""

# --- 4. Install Ollama (Optional - TODO: Add flag/prompt later) ---
echo "[4/6] Installing Ollama..."
if ! command_exists ollama; then
	echo "Downloading and running Ollama install script..."
	curl -fsSL https://ollama.com/install.sh | sh
	if [ $? -ne 0 ]; then echo "[Warning] Ollama installation failed. Continuing without it."; else
		echo "Ollama installed. Pulling default models (this might take time)..."
		if ! pgrep -x ollama >/dev/null; then
			echo "Starting temporary Ollama server..."
			ollama serve &
			sleep 5
		fi
		(ollama pull llama3:8b && echo "Pulled llama3:8b") &
		(ollama pull phi3 && echo "Pulled phi3") &
		echo "Default model downloads initiated in background."
	fi
else
	echo "Ollama already installed."
fi
echo ""

# --- 5. Link Dotfiles ---
echo "[5/6] Linking dotfiles using install_links.sh..."
chmod +x "$REPO_ROOT_DIR/dotfiles/install_links.sh"
bash "$REPO_ROOT_DIR/dotfiles/install_links.sh"
if [ $? -ne 0 ]; then
	echo "Error running install_links.sh."
	exit 1
fi
echo "Dotfiles linked."
echo ""

# --- 6. Setup Neovim Plugins and Tools ---
echo "[6/6] Setting up Neovim plugins (Lazy sync and Mason tools)..."
echo "Running Lazy plugin sync..."
nvim --headless "+Lazy! sync" +qa
if [ $? -ne 0 ]; then echo "[Warning] Neovim Lazy sync failed. Run ':Lazy sync' manually inside nvim."; fi

echo "Attempting to install default Mason tools (LSPs, linters, etc.)..."
nvim --headless "+MasonInstallAll" +qa
if [ $? -ne 0 ]; then echo "[Warning] Neovim MasonInstallAll command encountered issues. Run ':Mason' inside nvim to check/install tools manually."; fi

echo "Neovim setup complete."
echo ""

# --- Finish ---
echo "-------------------------------------------------"
echo "✅ Native Linux Setup Complete!"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. **RESTART YOUR TERMINAL** for all changes (PATH, .bashrc, prompt) to take effect."
echo "2. Ensure you have installed a **Nerd Font** on your Host OS / Desktop Environment and configured your terminal emulator to use it."
echo "3. Run 'nvim'. If you see errors about missing tools, run ':Mason' to install them."
echo "-------------------------------------------------"

exit 0
