#!/bin/bash
# Setup script for WSL (Ubuntu/Debian-based) environments.
# Installs dependencies, Neovim, Oh My Posh, links dotfiles, and sets up Neovim plugins.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting WSL Development Environment Setup ---"

# --- Helper Functions ---
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# --- Ensure Script is Run from Repo Root ---
# Check if a known file/dir from the repo exists in the current dir
if [ ! -f "./dotfiles/install_links.sh" ]; then
	echo "[Error] Please run this script from the root directory of the cloned repository (e.g., ~/my_linux_setup/)." >&2
	exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"

# --- 1. Install System Dependencies (APT) ---
echo "[1/6] Updating package lists and installing system dependencies via apt..."
sudo apt update

# Core tools, build tools, Python, helpers
# Added libfuse2 for AppImage compatibility if needed on newer systems
sudo apt install -y git curl wget build-essential ca-certificates \
	python3 python3-pip python3-venv \
	figlet fzf ripgrep fd-find unzip libfuse2

# Check for fd symlink (Debian/Ubuntu often install as fdfind)
if command_exists fdfind && ! command_exists fd; then
	echo "[Info] Creating 'fd' symlink for 'fdfind'..."
	# Check if link already exists before creating
	if [ ! -L /usr/local/bin/fd ]; then
		sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
	else
		echo "[Info] Symlink /usr/local/bin/fd already exists."
	fi
fi
echo "System dependencies installed."
echo ""

# --- 2. Install Oh My Posh ---
echo "[2/6] Installing Oh My Posh..."
if ! command_exists oh-my-posh; then
	echo "Downloading Oh My Posh..."
	# Determine architecture
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then
		POSH_ARCH="amd64"
	elif [[ "$ARCH" == "aarch64" ]]; then
		POSH_ARCH="arm64"
	else
		echo "[Error] Unsupported architecture: $ARCH for Oh My Posh auto-install." >&2
		exit 1
	fi
	POSH_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${POSH_ARCH}"
	sudo wget "$POSH_URL" -O /usr/local/bin/oh-my-posh
	sudo chmod +x /usr/local/bin/oh-my-posh
	echo "Oh My Posh installed to /usr/local/bin."
else
	echo "Oh My Posh already installed."
fi
# Verify install
oh-my-posh --version
echo ""

# --- 3. Install Neovim (Latest Stable AppImage) ---
echo "[3/6] Installing Neovim (Latest Stable AppImage)..."
if ! command_exists nvim; then
	echo "Downloading Neovim AppImage..."
	# AppImage is typically x86_64 only. If ARM is needed, need .tar.gz method
	ARCH=$(uname -m)
	if [[ "$ARCH" != "x86_64" ]]; then
		echo "[Warning] Neovim AppImage might not be available for $ARCH. Attempting download anyway..."
		# Consider adding tar.gz fallback for ARM here later if needed
	fi

	NVIM_APPIMAGE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim.appimage"
	curl -Lo nvim.appimage "$NVIM_APPIMAGE_URL"
	if [ $? -ne 0 ]; then
		echo "Error downloading Neovim AppImage."
		exit 1
	fi

	echo "Making AppImage executable and linking to /usr/local/bin/nvim..."
	chmod u+x nvim.appimage
	# Use mv first, then check if linking is needed (less common for single binary)
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
# Verify install
nvim --version | head -n 1
echo ""

# --- 4. Install Ollama (Optional - TODO: Add flag/prompt later if needed) ---
echo "[4/6] Installing Ollama..."
if ! command_exists ollama; then
	echo "Downloading and running Ollama install script..."
	curl -fsSL https://ollama.com/install.sh | sh
	if [ $? -ne 0 ]; then
		echo "[Warning] Ollama installation failed. Continuing without it."
	else
		echo "Ollama installed. Pulling default models (this might take time)..."
		# Pull some default models in the background - ignore errors if they fail
		# Check if ollama server is running first (install script sometimes starts it)
		if ! pgrep -x ollama >/dev/null; then
			echo "Starting temporary Ollama server for model download..."
			ollama serve &
			# Give it a few seconds
			sleep 5
		fi
		(ollama pull llama3:8b && echo "Pulled llama3:8b") & # Run in subshell for background
		(ollama pull phi3 && echo "Pulled phi3") &           # Run in subshell for background
		echo "Default model downloads initiated in background. Check progress with 'ollama list'."
	fi
else
	echo "Ollama already installed."
fi
echo ""

# --- 5. Link Dotfiles ---
echo "[5/6] Linking dotfiles using install_links.sh..."
# Ensure install_links.sh is executable
chmod +x "$REPO_ROOT_DIR/dotfiles/install_links.sh"
# Execute the script located within the dotfiles directory
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
if [ $? -ne 0 ]; then echo "[Warning] Neovim Lazy sync failed. Plugins might not be installed. Run ':Lazy sync' manually inside nvim."; fi

echo "Attempting to install default Mason tools (LSPs, linters, etc.)..."
# Note: This might occasionally fail depending on network or Mason state.
nvim --headless "+MasonInstallAll" +qa
if [ $? -ne 0 ]; then echo "[Warning] Neovim MasonInstallAll command encountered issues. Some tools might not be installed. Run ':Mason' inside nvim to check/install tools manually."; fi

echo "Neovim setup complete."
echo ""

# --- Finish ---
echo "-------------------------------------------------"
echo "✅ WSL Setup Complete!"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. **RESTART YOUR WSL SESSION** for all changes (PATH, .bashrc, prompt) to take effect."
echo "2. Ensure you have installed a **Nerd Font** on your HOST Windows system and configured your terminal (e.g., Windows Terminal) to use it for this WSL profile."
echo "3. Run 'nvim'. If you see errors about missing tools, run ':Mason' to install them."
echo "-------------------------------------------------"

exit 0
