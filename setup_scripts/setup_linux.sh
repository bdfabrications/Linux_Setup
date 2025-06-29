#!/bin/bash
# Master setup script for Ubuntu/Debian-based Linux environments.
# This script acts as an orchestrator, installing core dependencies
# and then running all modular installation routines.

set -e
echo "--- Starting Master Linux Environment Setup ---"

# --- Ensure Script is Run from Repo Root ---
if [ ! -d "./setup_scripts" ] || [ ! -d "./install_routines" ]; then
    echo "[Error] Please run this script from the root directory of the repository." >&2
    exit 1
fi
REPO_ROOT_DIR=$(pwd)
INSTALL_ROUTINES_DIR="$REPO_ROOT_DIR/install_routines"

# --- PHASE 1: Install Core System Dependencies ---
echo "[PHASE 1] Installing core dependencies via apt..."
sudo apt update
# This list contains tools needed by the installers (curl, wget, tar)
# and common tools for the base environment (git, python, node, fzf, etc.).
sudo apt install -y git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip nodejs npm

# Create 'fd' symlink needed on Debian/Ubuntu
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    echo "Creating 'fd' symlink for 'fdfind'..."
    sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
fi
echo "Core dependencies installed."
echo ""

# --- PHASE 2: Run Individual Software Installers ---
echo "[PHASE 2] Executing all installation routines from $INSTALL_ROUTINES_DIR..."
for installer in "$INSTALL_ROUTINES_DIR"/*.sh; do
    if [ -f "$installer" ]; then
        echo ""
        echo "--- Running installer: $(basename "$installer") ---"
        bash "$installer"
    fi
done
echo "All installation routines completed."
echo ""

# --- PHASE 3: Link All Configurations ---
echo "[PHASE 3] Linking all dotfiles and configurations..."
bash "$REPO_ROOT_DIR/setup_scripts/install_links.sh"
echo "Dotfiles linked."
echo ""

# --- PHASE 4: Finalize Neovim Setup ---
echo "[PHASE 4] Running final Neovim bootstrapping..."
bash "$REPO_ROOT_DIR/setup_scripts/finalize_neovim.sh"
echo "Neovim finalization complete."
echo ""

# --- Finish ---
echo "-------------------------------------------------"
echo "✅ Master Linux Setup Complete!"
echo "Please RESTART YOUR TERMINAL for all changes to take effect."
echo "-------------------------------------------------"
exit 0
