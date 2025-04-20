#!/bin/bash
# Simple script to update the system, upgrade packages, and clean up.

# Determine if sudo is needed
SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    if command -v sudo &>/dev/null; then
        SUDO_CMD="sudo"
        echo "[Info] Not root. Using 'sudo' for package operations."
    else
        echo "[Error] Not root and 'sudo' command not found. Cannot manage packages."
        exit 1
    fi
fi

echo "--- Starting System Update & Cleanup ---"

# Update package lists
echo "[1/4] Updating package lists (apt update)..."
if ! apt update; then
    echo "Error: apt update failed. Exiting."
    exit 1
fi
echo "Package lists updated."
echo ""

# Upgrade installed packages
# Using -y assumes yes to all prompts during upgrade
echo "[2/4] Upgrading installed packages (apt upgrade -y)..."
if ! apt upgrade -y; then
    echo "Warning: apt upgrade encountered issues, but continuing cleanup."
else
    echo "Packages upgraded."
fi
echo ""

# Remove automatically installed dependencies that are no longer needed
echo "[3/4] Removing unused packages (apt autoremove -y)..."
if ! apt autoremove -y; then
    echo "Warning: apt autoremove encountered issues."
else
    echo "Unused packages removed."
fi
echo ""

# Clean up downloaded package files (.deb) from the local repository
echo "[4/4] Cleaning up downloaded package cache (apt clean)..."
if ! apt clean; then
    echo "Warning: apt clean encountered issues."
else
    echo "Package cache cleaned."
fi
echo ""

echo "--- System Update & Cleanup Finished ---"
exit 0
