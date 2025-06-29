#!/bin/bash
# Simple script to update the system, upgrade packages, and clean up.
# Version 2.1: Improved logging, error handling, and modularization

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
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        if command -v sudo &>/dev/null; then
            echo "[Info] Not root. Using 'sudo' for package operations."
            SUDO_CMD="sudo"
        else
            echo "[Error] This script must be run as root or with sudo." >&2
            exit 1
        fi
    fi
}

# --- Update Package Lists ---
update_package_lists() {
    echo "[Info] [1/4] Updating package lists..."
    if ! $SUDO_CMD apt update; then
        echo "[Error] 'apt update' failed. Exiting." >&2
        exit 1
    else
        echo "[Success] Package lists updated successfully."
    fi
}

# --- Upgrade Installed Packages ---
upgrade_packages() {
    echo "[Info] [2/4] Upgrading installed packages..."
    if ! $SUDO_CMD apt upgrade -y; then
        echo "[Warning] 'apt upgrade' encountered issues, but continuing cleanup." >&2
    else
        echo "[Success] Packages upgraded successfully."
    fi
}

# --- Remove Unused Dependencies ---
remove_unused_packages() {
    echo "[Info] [3/4] Removing unused packages..."
    if ! $SUDO_CMD apt autoremove -y; then
        echo "[Warning] 'apt autoremove' encountered issues." >&2
    else
        echo "[Success] Unused packages removed successfully."
    fi
}

# --- Clean Up Package Cache ---
clean_package_cache() {
    echo "[Info] [4/4] Cleaning up downloaded package cache..."
    if ! $SUDO_CMD apt clean; then
        echo "[Warning] 'apt clean' encountered issues." >&2
    else
        echo "[Success] Package cache cleaned successfully."
    fi
}

# --- Main Function ---
main() {
    check_sudo
    echo "--- Starting System Update & Cleanup ---"
    update_package_lists
    upgrade_packages
    remove_unused_packages
    clean_package_cache
    echo "--- System Update & Cleanup Finished ---"
    exit 0
}

main
