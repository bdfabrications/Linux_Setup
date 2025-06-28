#!/bin/bash
# Setup script for Native Linux environments (Debian/Ubuntu, Fedora, Arch).

set -e
echo "--- Starting Native Linux Development Environment Setup ---"

# --- Helper Functions ---
command_exists() { command -v "$1" >/dev/null 2>&1; }
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$(echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/debian_version ]; then
        OS=debian
    elif [ -f /etc/fedora-release ]; then
        OS=fedora
    elif [ -f /etc/arch-release ]; then
        OS=arch
    else OS=$(uname -s | tr '[:upper:]' '[:lower:]'); fi
    if [[ "$OS" == "pop" ]]; then OS="ubuntu"; fi
    echo "$OS"
}

# --- Ensure Script is Run from Repo Root ---
# UPDATED PATH: Check for a file in the new structure
if [ ! -f "./setup_scripts/install_links.sh" ]; then
    echo "[Error] Please run this script from the root directory of the repository." >&2
    exit 1
fi
REPO_ROOT_DIR=$(pwd)
echo "[Info] Running setup from: $REPO_ROOT_DIR"
DISTRO=$(detect_distro)
echo "[Info] Detected distribution: $DISTRO"

# --- 1. Install System Dependencies ---
echo "[1/7] Installing system dependencies for $DISTRO..."
PACKAGES_DEBIAN="git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip"
PACKAGES_FEDORA="git curl wget make automake gcc gcc-c++ kernel-devel tar python3 python3-pip python3-virtualenv figlet fzf ripgrep fd-find unzip ca-certificates nodejs npm"
PACKAGES_ARCH="git curl wget base-devel tar python python-pip python-venv figlet fzf ripgrep fd unzip ca-certificates nodejs npm"
INSTALL_CMD="" UPDATE_CMD="" REMOVE_NVIM_CMD_BASE="" PACKAGES="" NEEDS_NODESOURCE=false

case "$DISTRO" in
ubuntu | debian)
    UPDATE_CMD="sudo apt update"
    INSTALL_CMD="sudo apt install -y"
    REMOVE_NVIM_CMD_BASE="sudo apt remove --purge neovim neovim-runtime -y"
    PACKAGES="$PACKAGES_DEBIAN"
    NEEDS_NODESOURCE=true
    ;;
fedora)
    UPDATE_CMD="sudo dnf check-update"
    INSTALL_CMD="sudo dnf install -y"
    REMOVE_NVIM_CMD_BASE="sudo dnf remove neovim -y"
    PACKAGES="$PACKAGES_FEDORA"
    ;;
arch | manjaro)
    INSTALL_CMD="sudo pacman -S --noconfirm --needed"
    REMOVE_NVIM_CMD_BASE="sudo pacman -Rns neovim --noconfirm"
    PACKAGES="$PACKAGES_ARCH"
    ;;
*)
    echo "[Error] Unsupported distribution: $DISTRO." >&2
    exit 1
    ;;
esac

if [ -n "$UPDATE_CMD" ]; then
    echo "Updating package manager..."
    $UPDATE_CMD || true
fi
if [ -n "$REMOVE_NVIM_CMD_BASE" ]; then
    echo "Removing old package manager Neovim..."
    $REMOVE_NVIM_CMD_BASE || true
fi

if [ "$NEEDS_NODESOURCE" = true ]; then
    if ! command_exists node; then
        echo "Installing Node.js and npm via NodeSource..."
        if ! command_exists curl; then sudo apt install -y curl; fi
        NODE_MAJOR=20
        curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
fi

echo "Installing core packages..."
$INSTALL_CMD $PACKAGES
if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]] && command_exists fdfind && ! command_exists fd; then
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
echo "✅ Native Linux Setup Complete! Please RESTART YOUR TERMINAL."
exit 0
