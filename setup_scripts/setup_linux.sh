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
sudo apt update
# --- MODIFIED: Added libfuse2 for AppImage support ---
sudo apt install -y git curl wget build-essential ca-certificates tar python3 python3-pip python3-venv figlet fzf ripgrep fd-find unzip nodejs npm libfuse2 lolcat
# ... (rest of dependency installation) ...
echo "Core dependencies installed."
echo ""

# --- PHASE 2: Run Individual Software Installers ---
echo "[PHASE 2] Executing all installation routines from $INSTALL_ROUTINES_DIR..."
# NOTE: We now explicitly call the AstroNvim installer AFTER the main Neovim installer.
bash "$INSTALL_ROUTINES_DIR/10_oh_my_posh.sh"
bash "$INSTALL_ROUTINES_DIR/20_neovim.sh"
bash "$INSTALL_ROUTINES_DIR/25_astronvim.sh"
bash "$INSTALL_ROUTINES_DIR/30_ollama.sh"
bash "$INSTALL_ROUTINES_DIR/40_docker.sh"
# --- NEW: Add new installers ---
bash "$INSTALL_ROUTINES_DIR/45_pipx.sh"
bash "$INSTALL_ROUTINES_DIR/50_pre-commit.sh"
bash "$INSTALL_ROUTINES_DIR/60_just.sh"
bash "$INSTALL_ROUTINES_DIR/70_terminal_enhancements.sh"
bash "$INSTALL_ROUTINES_DIR/80_1password_cli.sh"
echo "All installation routines completed."
echo ""

# --- PHASE 3: Set up User Config Files ---
echo "[PHASE 3] Setting up user configuration files..."
bash "$REPO_ROOT_DIR/setup_scripts/install_configs.sh"
echo "User configurations set up."
echo ""

# --- PHASE 4: Link All Configurations & Scripts ---
echo "[PHASE 4] Linking all dotfiles and configurations..."
bash "$REPO_ROOT_DIR/setup_scripts/install_links.sh"
echo "Dotfiles linked."
echo ""

# --- PHASE 5: Finalize Neovim Setup ---
echo "[PHASE 5] Running final Neovim bootstrapping..."
# We still run this to install Mason tools and sync plugins for AstroNvim
bash "$REPO_ROOT_DIR/setup_scripts/finalize_neovim.sh"
echo "Neovim finalization complete."
echo ""

# --- PHASE 6: Final Configuration Step ---
echo "[PHASE 6] Final Manual Step Required"
echo "To complete the setup, please run the following command to link your new shell configuration:"
echo ""
echo "  echo 'if [ -f ~/.bashrc_config ]; then . ~/.bashrc_config; fi' >> ~/.bashrc"
echo ""
echo "This only needs to be done once."
echo ""


# --- Finish ---
echo "-------------------------------------------------"
echo "✅ Master Linux Setup Complete!"
echo "Please RESTART YOUR TERMINAL for all changes to take effect."
echo "-------------------------------------------------"
exit 0
