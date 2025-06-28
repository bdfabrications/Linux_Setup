#!/bin/bash
# Simple script to update the system, upgrade packages, and clean up.
# Version 2.0: Help text moved to README.md

# --- Help Function ---
show_help() {
    echo "A script to update, upgrade, and clean a Debian-based system using APT."
    echo "Usage: update_system"
    echo "For more details, please see the README.md file in the system_manager project."
}

# --- Argument Parsing for Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Sudo Check ---
SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    if command -v sudo &>/dev/null; then
        SUDO_CMD="sudo"
        echo "[Info] Not root. Using 'sudo' for package operations."
    else
        echo "[Error] This script must be run as root or with sudo." >&2
        exit 1
    fi
fi

echo "--- Starting System Update & Cleanup ---"

# 1. Update package lists
echo "[1/4] Updating package lists..."
if ! $SUDO_CMD apt update; then
    echo "Error: 'apt update' failed. Exiting." >&2
    exit 1
fi
echo "Package lists updated successfully."
echo ""

# 2. Upgrade installed packages
echo "[2/4] Upgrading installed packages..."
if ! $SUDO_CMD apt upgrade -y; then
    echo "[Warning] 'apt upgrade' encountered issues, but continuing cleanup." >&2
else
    echo "Packages upgraded successfully."
fi
echo ""

# 3. Remove unused dependencies
echo "[3/4] Removing unused packages..."
if ! $SUDO_CMD apt autoremove -y; then
    echo "[Warning] 'apt autoremove' encountered issues." >&2
else
    echo "Unused packages removed successfully."
fi
echo ""

# 4. Clean up package cache
echo "[4/4] Cleaning up downloaded package cache..."
if ! $SUDO_CMD apt clean; then
    echo "[Warning] 'apt clean' encountered issues." >&2
else
    echo "Package cache cleaned successfully."
fi
echo ""

echo "--- System Update & Cleanup Finished ---"
exit 0
