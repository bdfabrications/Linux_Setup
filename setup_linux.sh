#!/bin/bash
# Setup script for Native Linux environments (Debian/Ubuntu, Fedora, Arch).
# Detects distro, installs dependencies (incl. Node.js), Neovim v0.11.0 (using tar.gz),
# Oh My Posh, links dotfiles, and sets up Neovim plugins.

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
        # shellcheck disable=SC1091
        . /etc/os-release
        OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Ubuntu/Debian without lsb_release command
        # shellcheck disable=SC1091
        . /etc/lsb-release
        OS=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
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
    # Handle pop os which is based on ubuntu
    if [[ "$OS" == "pop" ]]; then
        OS="ubuntu"
    fi
    echo "$OS"
}

# --- Ensure Script is Run from Repo Root ---
if [ ! -f "./dotfiles/install_links.sh" ]; then
    echo "[Error] Please run this script from the root directory of the cloned repository." >&2
    exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"
echo "[Info] Detecting distribution..."
DISTRO=$(detect_distro)
echo "[Info] Detected distribution: $DISTRO"

# --- 1. Install System Dependencies (Distro Specific) ---
echo "[1/7] Installing system dependencies for $DISTRO..." # Step count increased

# Define core dependencies - adjust package names per distro as needed
# Common: git, curl, wget, build tools, python3, pip3, venv, figlet, fzf, ripgrep, fd, unzip, ca-certs, tar, nodejs, npm
PACKAGES_DEBIAN="git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip"
PACKAGES_FEDORA="git curl wget make automake gcc gcc-c++ kernel-devel tar python3 python3-pip python3-virtualenv figlet fzf ripgrep fd-find unzip ca-certificates nodejs npm" # Add nodejs/npm here
PACKAGES_ARCH="git curl wget base-devel tar python python-pip python-venv figlet fzf ripgrep fd unzip ca-certificates nodejs npm"                                             # Add nodejs/npm here

INSTALL_CMD=""
UPDATE_CMD=""
REMOVE_NVIM_CMD_BASE="" # Store only the base command here
PACKAGES=""
NEEDS_NODESOURCE=false

case "$DISTRO" in
ubuntu | debian)
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
    REMOVE_NVIM_CMD_BASE="sudo apt remove --purge neovim neovim-runtime -y" # Base command without || true
    PACKAGES="$PACKAGES_DEBIAN"
    NEEDS_NODESOURCE=true # Use NodeSource for up-to-date Node on Debian/Ubuntu
    ;;
fedora)
    UPDATE_CMD="sudo dnf check-update"
    INSTALL_CMD="sudo dnf install -y"
    REMOVE_NVIM_CMD_BASE="sudo dnf remove neovim -y"
    PACKAGES="$PACKAGES_FEDORA" # Includes nodejs/npm
    ;;
arch | manjaro)
    # UPDATE_CMD="sudo pacman -Syu --noconfirm" # Uncomment if full system upgrade is desired
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    REMOVE_NVIM_CMD_BASE="sudo pacman -Rns neovim --noconfirm"
    PACKAGES="$PACKAGES_ARCH" # Includes nodejs/npm
    ;;
*)
    echo "[Error] Unsupported distribution: $DISTRO. Cannot install dependencies automatically." >&2
    echo "Please install the following or their equivalents manually:" >&2
    echo "  git, curl, wget, build-essential/base-devel, tar, python3, python3-pip, python3-venv," >&2
    echo "  figlet, fzf, ripgrep, fd-find/fd, unzip, ca-certificates, nodejs, npm" >&2
    exit 1
    ;;
esac

# Update package manager cache (if applicable for distro)
if [ -n "$UPDATE_CMD" ]; then
    echo "Updating package manager..."
    $UPDATE_CMD || echo "[Warning] Package manager update command failed, continuing install attempt..."
fi

# Remove existing package manager Neovim FIRST
if [ -n "$REMOVE_NVIM_CMD_BASE" ]; then
    echo "Attempting to remove existing package manager Neovim (if any)..."
    # Execute the base command and add '|| true' here to ignore errors
    $REMOVE_NVIM_CMD_BASE || true
fi

# Install NodeSource repo if needed (Debian/Ubuntu)
if [ "$NEEDS_NODESOURCE" = true ]; then
    if ! command_exists node || ! command_exists npm; then
        echo "Installing Node.js and npm via NodeSource..."
        # Check if curl is installed before using it
        if ! command_exists curl; then
            echo "[Error] curl is required to setup NodeSource repository."
            exit 1
        fi
        # Use NodeSource setup script for Node LTS (modify version if needed, e.g., node_20.x)
        NODE_MAJOR=20 # Specify desired major LTS version
        curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | sudo -E bash -
        # Install Node.js and npm
        sudo apt install nodejs -y
    else
        echo "Node.js/npm already installed."
    fi
fi

# Install packages
echo "Installing core packages..."
$INSTALL_CMD $PACKAGES
if [ $? -ne 0 ]; then
    echo "[Error] Failed to install core packages. Please check package names for your distribution."
    exit 1
fi

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
# (Step count increases due to Node install step)
echo "[2/7] Installing Oh My Posh..."
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

# --- 3. Install Neovim v0.11.0 (tar.gz method) ---
echo "[3/7] Installing Neovim v0.11.0 (tar.gz method)..."
NVIM_VERSION="v0.11.0"
CORRECT_VERSION_INSTALLED=false
NVIM_INSTALL_DIR="/usr/local/lib/nvim-${NVIM_VERSION}"
if command_exists nvim && [[ "$(nvim --version | head -n 1)" == *"${NVIM_VERSION#v}"* ]]; then
    if [[ -L /usr/local/bin/nvim ]] && [[ "$(readlink /usr/local/bin/nvim)" == *"${NVIM_INSTALL_DIR}/bin/nvim"* ]]; then
        echo "Neovim ${NVIM_VERSION} already installed and linked correctly."
        CORRECT_VERSION_INSTALLED=true
    else
        echo "[Info] Neovim ${NVIM_VERSION} command exists, but link is incorrect or missing. Re-installing link."
        CORRECT_VERSION_INSTALLED=false
    fi
fi

if [ "$CORRECT_VERSION_INSTALLED" = false ]; then
    echo "[Info] Cleaning up potential old Neovim installations in /usr/local/..."
    sudo rm -f /usr/local/bin/nvim
    sudo rm -rf "${NVIM_INSTALL_DIR}"

    ARCH=$(uname -m)
    NVIM_FILENAME_ARCH=""
    if [[ "$ARCH" == "x86_64" ]]; then NVIM_FILENAME_ARCH="linux-x86_64"; elif [[ "$ARCH" == "aarch64" ]]; then NVIM_FILENAME_ARCH="linux-aarch64"; else
        echo "[Error] Unsupported architecture: $ARCH"
        exit 1
    fi

    NVIM_TARBALL="nvim-${NVIM_FILENAME_ARCH}.tar.gz"
    NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TARBALL}"
    NVIM_EXTRACT_DIR_NAME="nvim-${NVIM_FILENAME_ARCH}"

    if [ ! -d "${NVIM_INSTALL_DIR}/bin" ]; then
        rm -f "${NVIM_TARBALL}"
        echo "Downloading ${NVIM_TARBALL}..."
        curl -fLo "${NVIM_TARBALL}" "${NVIM_DOWNLOAD_URL}"
        if [ $? -ne 0 ]; then
            echo "[Error] Failed to download Neovim tarball (curl error code $?). URL: ${NVIM_DOWNLOAD_URL}"
            exit 1
        fi
        echo "Extracting Neovim..."
        tar xzf "${NVIM_TARBALL}"
        if [ $? -ne 0 ]; then
            echo "[Error] Failed to extract Neovim tarball."
            rm -f "${NVIM_TARBALL}"
            exit 1
        fi
        if [ ! -d "${NVIM_EXTRACT_DIR_NAME}" ]; then
            echo "[Error] Extracted directory '${NVIM_EXTRACT_DIR_NAME}' not found."
            rm -f "${NVIM_TARBALL}"
            exit 1
        fi
        echo "Installing Neovim to ${NVIM_INSTALL_DIR}..."
        sudo mv "${NVIM_EXTRACT_DIR_NAME}" "${NVIM_INSTALL_DIR}"
        if [ $? -ne 0 ]; then
            echo "[Error] Failed to move extracted Neovim files."
            rm -f "${NVIM_TARBALL}"
            exit 1
        fi
        echo "Cleaning up downloaded file..."
        rm -f "${NVIM_TARBALL}"
    else
        echo "[Info] Neovim ${NVIM_VERSION} files already found in ${NVIM_INSTALL_DIR}. Skipping download/extract."
    fi
    echo "Creating symlink /usr/local/bin/nvim..."
    sudo ln -sf "${NVIM_INSTALL_DIR}/bin/nvim" /usr/local/bin/nvim
    if [ $? -ne 0 ]; then
        echo "[Error] Failed to create Neovim symlink."
        exit 1
    fi
    echo "Neovim ${NVIM_VERSION} installed successfully."
fi
nvim --version | head -n 1
echo ""

# --- 4. Install Ollama ---
echo "[4/7] Installing Ollama..."
# (Keep Ollama section as it was, with refactored startup)
if ! command_exists ollama; then
    echo "Downloading and running Ollama install script..."
    OLLAMA_INSTALL_OUTPUT=$(curl -fsSL https://ollama.com/install.sh | sh)
    if [ $? -ne 0 ]; then
        echo "[Warning] Ollama installation script failed."
        echo "$OLLAMA_INSTALL_OUTPUT"
    else
        echo "Ollama installed successfully."
        echo "Attempting to pull default models (this might take time)..."
        OLLAMA_STARTED=false
        if command_exists systemctl; then
            echo "[Info] Attempting to start Ollama via systemctl..."
            if sudo systemctl start ollama || true; then
                if systemctl is-active --quiet ollama; then
                    OLLAMA_STARTED=true
                    echo "[Info] Ollama started via systemctl."
                    sleep 2
                else echo "[Warning] 'systemctl start ollama' command finished, but service is not active. Will try direct command..."; fi
            else echo "[Warning] 'systemctl start ollama' command failed. Will try direct command..."; fi
        fi
        if [ "$OLLAMA_STARTED" = false ]; then
            echo "[Info] Attempting to start Ollama directly..."
            (ollama serve &) || true
            sleep 5
            if pgrep -x ollama >/dev/null; then
                OLLAMA_STARTED=true
                echo "[Info] Ollama serve command issued and process found."
            else echo "[Warning] Failed to find ollama process after attempting direct start."; fi
        fi
        if [ "$OLLAMA_STARTED" = true ] && (pgrep -x ollama >/dev/null || (command_exists systemctl && systemctl is-active --quiet ollama)); then
            echo "[Info] Ollama server appears running. Initiating model downloads..."
            (ollama pull llama3:8b && echo "[Info] Pulled llama3:8b") &
            (ollama pull phi3 && echo "[Info] Pulled phi3") &
            echo "[Info] Default model downloads initiated in background. Check progress with 'ollama list'."
        else echo "[Warning] Ollama server doesn't seem to be running after startup attempts. Skipping model download."; fi
    fi
else echo "Ollama already installed."; fi
echo ""

# --- 5. Link Dotfiles ---
echo "[5/7] Linking dotfiles using install_links.sh..."
chmod +x "$REPO_ROOT_DIR/dotfiles/install_links.sh"
bash "$REPO_ROOT_DIR/dotfiles/install_links.sh"
if [ $? -ne 0 ]; then
    echo "[Error] Error running install_links.sh."
    exit 1
fi
echo "Dotfiles linked."
echo ""

# --- 6. Setup Neovim Plugins and Tools ---
echo "[6/7] Setting up Neovim plugins (Lazy sync)..."
nvim --headless "+Lazy! sync" +qa
if [ $? -ne 0 ]; then echo "[Warning] Neovim Lazy sync failed. Run ':Lazy sync' manually inside nvim."; fi
echo "Lazy sync complete."
echo ""

# --- 7. Install Mason Tools ---
echo "[7/7] Attempting to install default Mason tools (LSPs, linters, etc.)..."
# Note: This might occasionally fail depending on network or Mason state.
nvim --headless "+MasonInstallAll" +qa
if [ $? -ne 0 ]; then echo "[Warning] Neovim MasonInstallAll command encountered issues. Run ':Mason' inside nvim to check/install tools manually."; fi
echo "Mason tool installation attempt complete."
echo ""

# --- Finish ---
echo "-------------------------------------------------"
echo "✅ Native Linux Setup Complete!"
echo ""
echo "IMPORTANT NEXT STEPS:"
echo "1. **RESTART YOUR TERMINAL/SHELL** for all changes to take effect."
echo "2. Ensure you have installed a **Nerd Font** on your Desktop Environment and configured your terminal emulator."
echo "3. Run 'nvim'. Check ':Mason' status if needed."
echo "-------------------------------------------------"

exit 0
