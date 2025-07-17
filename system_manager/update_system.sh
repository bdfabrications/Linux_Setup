#!/bin/bash
#
# A simple script to update, upgrade, and clean a Debian-based system
# using the APT package manager.

set -euo pipefail

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }

# --- Sudo Check ---
# Ensure we have sudo privileges before starting.
if [[ $EUID -ne 0 ]]; then
    log_info "Requesting sudo privileges for system update..."
    sudo -v
    if [[ $? -ne 0 ]]; then
      echo "Sudo privileges are required. Aborting." >&2
      exit 1
    fi
fi

# --- Main Logic ---
log_info "Step 1: Refreshing package lists with 'apt update'..."
sudo apt update

log_info "Step 2: Upgrading all installed packages with 'apt upgrade'..."
sudo apt upgrade -y

log_info "Step 3: Removing unused packages with 'apt autoremove'..."
sudo apt autoremove -y

log_info "Step 4: Clearing the local package cache with 'apt clean'..."
sudo apt clean

log_success "System maintenance complete!"
