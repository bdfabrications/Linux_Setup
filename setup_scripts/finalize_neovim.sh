#!/bin/bash
#
# finalize_neovim.sh - Runs the final bootstrapping commands for Neovim.
# This should be called AFTER dotfiles have been linked.
#

set -e

if ! command -v nvim &>/dev/null; then
    echo "[Warning] nvim command not found. Skipping Neovim finalization."
    exit 0
fi

echo "Setting up Neovim plugins (Lazy sync)..."
nvim --headless "+Lazy! sync" +qa || echo "[Warning] Lazy sync failed. Run ':Lazy sync' manually inside nvim."
echo "Lazy sync complete."
echo ""

echo "Installing Neovim Mason tools..."
nvim --headless "+MasonInstallAll" +qa || echo "[Warning] MasonInstallAll failed. Run ':Mason' inside nvim."
echo "Mason tool installation complete."
