#!/bin/bash
# Setup script for WSL (Ubuntu/Debian-based) environments.
# Installs dependencies, Neovim v0.11.0 (using .deb), Oh My Posh, links dotfiles,
# and sets up Neovim plugins.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting WSL Development Environment Setup ---"

# --- Helper Functions ---
command_exists() {
	command -v "$1" >/dev/null 2>&1
}

# --- Ensure Script is Run from Repo Root ---
if [ ! -f "./dotfiles/install_links.sh" ]; then
	echo "[Error] Please run this script from the root directory of the cloned repository." >&2
	exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"

# --- 1. Install System Dependencies (APT) ---
echo "[1/6] Updating package lists and installing system dependencies via apt..."
sudo apt update

# Core tools, build tools, Python, helpers, tar for extraction
sudo apt install -y git curl wget build-essential ca-certificates tar \
	python3 python3-pip python3-venv \
	figlet fzf ripgrep fd-find unzip

# Remove existing package manager Neovim FIRST
echo "Attempting to remove existing package manager Neovim (if any)..."
sudo apt remove --purge neovim neovim-runtime -y || true

# Handle fd symlink (Debian/Ubuntu often install as fdfind)
if command_exists fdfind && ! command_exists fd; then
	echo "[Info] Creating 'fd' symlink for 'fdfind'..."
	if [ ! -L /usr/local/bin/fd ]; then
		sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
	else
		echo "[Info] Symlink /usr/local/bin/fd already exists."
	fi
fi
echo "System dependencies installed."
echo ""

# --- 2. Install Oh My Posh ---
# (Keep this section as it was)
echo "[2/6] Installing Oh My Posh..."
if ! command_exists oh-my-posh; then
	echo "Downloading Oh My Posh..."
	ARCH=$(uname -m)
	if [[ "$ARCH" == "x86_64" ]]; then POSH_ARCH="amd64"; elif [[ "$ARCH" == "aarch64" ]]; then POSH_ARCH="arm64"; else
		echo "[Error] Unsupported architecture: $ARCH for Oh My Posh auto-install."
		exit 1
	fi
	POSH_URL="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${POSH_ARCH}"
	if sudo curl -fLo /usr/local/bin/oh-my-posh "$POSH_URL"; then
		sudo chmod +x /usr/local/bin/oh-my-posh
		echo "Oh My Posh installed to /usr/local/bin."
	else
		echo "[Error] Failed to download Oh My Posh (curl error code $?)."
		exit 1
	fi
else
	echo "Oh My Posh already installed."
fi
oh-my-posh --version
echo ""

# --- 3. Install Neovim v0.11.0 (.deb method) ---
NVIM_VERSION="v0.11.0"
echo "[3/6] Installing Neovim ${NVIM_VERSION} (.deb method)..."

# Check if correct version is already installed
CORRECT_VERSION_INSTALLED=false
if command_exists nvim && [[ "$(nvim --version | head -n 1)" == *"${NVIM_VERSION#v}"* ]]; then
	echo "Neovim ${NVIM_VERSION} already installed."
	CORRECT_VERSION_INSTALLED=true
fi

if [ "$CORRECT_VERSION_INSTALLED" = false ]; then
	# Determine architecture and corresponding filename suffix
	ARCH=$(uname -m)
	NVIM_FILENAME_ARCH="" # Suffix used in GitHub release asset names
	if [[ "$ARCH" == "x86_64" ]]; then
		NVIM_FILENAME_ARCH="linux-x86_64" # Corrected suffix
	elif [[ "$ARCH" == "aarch64" ]]; then
		NVIM_FILENAME_ARCH="linux-aarch64" # Assuming this is correct, verify on release page if needed
	else
		echo "[Error] Unsupported architecture: $ARCH for Neovim ${NVIM_VERSION} download." >&2
		exit 1
	fi

	NVIM_DEB="nvim-${NVIM_FILENAME_ARCH}.deb" # Use corrected arch suffix
	NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_DEB}"

	echo "Downloading ${NVIM_DEB}..."
	# Use curl with -f (fail fast) and -L (follow redirects)
	curl -fLo "${NVIM_DEB}" "${NVIM_DOWNLOAD_URL}"
	if [ $? -ne 0 ]; then
		echo "[Error] Failed to download Neovim .deb (curl error code $?). URL: ${NVIM_DOWNLOAD_URL}"
		exit 1
	fi

	echo "Installing Neovim via apt..."
	# Use apt install on the local .deb file. It handles dependencies.
	sudo apt install -y "./${NVIM_DEB}"
	if [ $? -ne 0 ]; then
		echo "[Error] Failed to install Neovim .deb package."
		rm -f "${NVIM_DEB}"
		exit 1
	fi

	echo "Cleaning up downloaded file..."
	rm -f "${NVIM_DEB}"

	echo "Neovim ${NVIM_VERSION} installation attempt finished."
fi
# Verify install
nvim --version | head -n 1
echo ""

# --- 4. Install Ollama ---
# (Keep this section as it was)
echo "[4/6] Installing Ollama..."
if ! command_exists ollama; then
	echo "Downloading and running Ollama install script..."
	OLLAMA_INSTALL_OUTPUT=$(curl -fsSL https://ollama.com/install.sh | sh)
	if [ $? -ne 0 ]; then
		echo "[Warning] Ollama installation script failed."
		echo "$OLLAMA_INSTALL_OUTPUT"
	else
		echo "Ollama installed. Pulling default models..."
		if ! pgrep -x ollama >/dev/null; then
			echo "Attempting to start Ollama server..."
			(ollama serve &) # Start in background
			sleep 5          # Give it time
		fi
		if pgrep -x ollama >/dev/null; then
			(ollama pull llama3:8b && echo "[Info] Pulled llama3:8b") &
			(ollama pull phi3 && echo "[Info] Pulled phi3") &
			echo "[Info] Default model downloads initiated in background."
		else
			echo "[Warning] Ollama server doesn't seem to be running. Skipping model download."
		fi
	fi
else
	echo "Ollama already installed."
fi
echo ""

# --- 5. Link Dotfiles ---
# (Keep this section as it was)
echo "[5/6] Linking dotfiles using install_links.sh..."
chmod +x "$REPO_ROOT_DIR/dotfiles/install_links.sh"
bash "$REPO_ROOT_DIR/dotfiles/install_links.sh"
if [ $? -ne 0 ]; then
	echo "[Error] Error running install_links.sh."
	exit 1
fi
echo "Dotfiles linked."
echo ""

# --- 6. Setup Neovim Plugins and Tools ---
# (Keep this section as it was)
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
# (Keep this section as it was)
echo "-------------------------------------------------"
echo "✅ WSL Setup Complete!"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. **RESTART YOUR WSL SESSION** for all changes to take effect."
echo "2. Ensure you have installed a **Nerd Font** on your HOST Windows system and configured your terminal."
echo "3. Run 'nvim'. If prompted, run ':Mason' to install any missing tools."
echo "-------------------------------------------------"

exit 0
