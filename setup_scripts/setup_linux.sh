#!/bin/bash
# Master setup script for Ubuntu/Debian-based Linux environments.

set -e
echo "--- Starting Master Linux Environment Setup ---"

# --- Ensure Script is Run from Repo Root ---
if [ ! -d "./setup_scripts" ] || [ ! -d "./install_routines" ]; then
    echo "[Error] Please run this script from the root of the repository." >&2
    exit 1
fi
REPO_ROOT_DIR=$(pwd)
INSTALL_ROUTINES_DIR="$REPO_ROOT_DIR/install_routines"

# --- PHASE 1: Install Core System Dependencies ---
echo "[PHASE 1] Installing core dependencies via apt..."
sudo apt-get update
# libfuse2 is for AppImage support, lolcat is for the welcome message
sudo apt-get install -y git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip nodejs npm libfuse2 lolcat
echo "Core dependencies installed."
echo ""

# --- PHASE 2: Run Individual Software Installers ---
echo "[PHASE 2] Executing all installation routines from $INSTALL_ROUTINES_DIR..."
# This loop ensures every installer script in the directory is executed.
for installer in "$INSTALL_ROUTINES_DIR"/*.sh; do
    if [ -f "$installer" ]; then
        echo ""
        echo "--- Running installer: $(basename "$installer") ---"
        bash "$installer"
    fi
done
echo "All installation routines completed."
echo ""

# --- PHASE 3: Set up User Config Files ---
echo "[PHASE 3] Setting up user configuration files..."
bash "$REPO_ROOT_DIR/setup_scripts/install_configs.sh"
echo "User configurations set up."
echo ""

# --- PHASE 4: Link All Configurations & Scripts ---
echo "[PHASE 4] Linking all dotfiles and configurations..."
# The install_links.sh script now handles sourcing automatically.
bash "$REPO_ROOT_DIR/setup_scripts/install_links.sh"
echo "Dotfiles linked."
echo ""

# --- PHASE 5: Finalize Neovim Setup ---
echo "[PHASE 5] Running final Neovim bootstrapping..."
# We still run this to install Mason tools and sync plugins for AstroNvim
bash "$REPO_ROOT_DIR/setup_scripts/finalize_neovim.sh"
echo "Neovim finalization complete."
echo ""


# --- Finish ---
echo "-------------------------------------------------"
echo "✅ Master Linux Setup Complete!"
echo "Please RESTART YOUR TERMINAL for all changes to take effect."
echo "-------------------------------------------------"
exit 0
