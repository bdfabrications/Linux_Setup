#!/bin/bash
# Simple script to update the system, upgrade packages, and clean up.

# --- Help Function ---
show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTION]

A simple script to update, upgrade, and clean a Debian-based Linux system
(e.g., Ubuntu, Debian, Linux Mint) using the APT package manager.

Options:
  -h, --help      Display this help message and exit.

Description:
  This script automates the standard system maintenance process by executing
  the following sequence of commands:
  1. apt update       - Refreshes the local package lists.
  2. apt upgrade -y    - Upgrades all installed packages to their latest versions.
  3. apt autoremove -y - Removes packages that were automatically installed
                       as dependencies but are no longer required.
  4. apt clean        - Clears the local cache of downloaded package files.

Execution Notes:
  - If the script is not run as the root user, it will automatically try to
    use the 'sudo' command for all package management operations.
  - The script will exit if it's not run as root and 'sudo' is not available.
EOF
}

# --- Argument Parsing for Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Sudo Check ---
# Determine if sudo is needed and set the SUDO_CMD variable accordingly.
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
# Using -y assumes yes to all prompts during upgrade
echo "[2/4] Upgrading installed packages..."
if ! $SUDO_CMD apt upgrade -y; then
    echo "[Warning] 'apt upgrade' encountered issues, but continuing cleanup." >&2
else
    echo "Packages upgraded successfully."
fi
echo ""

# 3. Remove automatically installed dependencies that are no longer needed
echo "[3/4] Removing unused packages..."
if ! $SUDO_CMD apt autoremove -y; then
    echo "[Warning] 'apt autoremove' encountered issues." >&2
else
    echo "Unused packages removed successfully."
fi
echo ""

# 4. Clean up downloaded package files (.deb) from the local repository
echo "[4/4] Cleaning up downloaded package cache..."
if ! $SUDO_CMD apt clean; then
    echo "[Warning] 'apt clean' encountered issues." >&2
else
    echo "Package cache cleaned successfully."
fi
echo ""

echo "--- System Update & Cleanup Finished ---"
exit 0
