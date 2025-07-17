#!/bin/bash
#
# finalize_neovim.sh - Runs the final bootstrapping commands for Neovim.
# This should be called AFTER all configurations and symlinks are in place.

# A robust shell script header:
# -e: exits immediately if a command exits with a non-zero status.
# -u: treats unset variables as an error when substituting.
# -o pipefail: causes a pipeline to return the exit status of the last command
#              to exit with a non-zero status, or zero if all exit successfully.
set -euo pipefail

# Check if Neovim is even installed before attempting to run it.
if ! command -v nvim &>/dev/null; then
    echo "[Warning] nvim command not found. Skipping Neovim finalization."
    exit 0
fi

echo "--- Neovim Finalization ---"

# --- Step 1: Synchronize Lazy.nvim plugins ---
echo "Running Lazy sync to install and update plugins..."
if nvim --headless "+Lazy! sync" +qa; then
    echo "Lazy sync completed successfully."
else
    # This command can sometimes fail on a fresh install due to network issues or timing.
    # The 'if' statement prevents set -e from killing the whole script.
    echo "[Warning] Lazy sync failed. This can sometimes happen on the very first run."
    echo "         You may need to run ':Lazy sync' manually the next time you open nvim."
fi
echo "" # for spacing

# --- Step 2: Install Mason Language Servers and Tools ---
echo "Running MasonInstallAll to set up language servers and tools..."
if nvim --headless "+MasonInstallAll" +qa; then
    echo "Mason tool installation completed successfully."
else
    echo "[Warning] MasonInstallAll command failed."
    echo "         Please run ':Mason' to review and install tools manually inside nvim."
fi
echo ""

echo "Neovim finalization complete. It should be ready to use!"
