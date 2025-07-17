#!/bin/bash
#
# Master setup script for native Ubuntu/Debian-based Linux environments.
# This script orchestrates the entire setup process, is idempotent,
# and provides clear feedback to the user.

# A more robust shell script header
set -euo pipefail

# --- Script Configuration and Path Management ---
# Use the script's own location to reliably determine the repository root.
# This makes the script runnable from any directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." &>/dev/null && pwd)"
INSTALL_ROUTINES_DIR="$REPO_ROOT/Linux_Experimental/install_routines"

# --- Helper Functions for Logging ---
log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Sudo Privilege Check ---
check_sudo() {
    log_info "Checking for sudo privileges..."
    if ! sudo -v; then
        log_error "Sudo privileges are required to proceed. Aborting."
    fi
    # Keep sudo privileges alive throughout the script execution.
    sudo -v
    log_success "Sudo privileges confirmed."
}

# --- Main Setup Functions ---

set_script_permissions() {
    log_info "--- PREP: Setting execute permissions for all setup scripts ---"
    
    # Set permissions for scripts in the setup_scripts directory
    for script in "$SCRIPT_DIR"/*.sh; do
        if [ -f "$script" ]; then
            chmod +x "$script"
        fi
    done

    # Set permissions for all modular installation routines
    if [ -d "$INSTALL_ROUTINES_DIR" ]; then
        for installer in "$INSTALL_ROUTINES_DIR"/*.sh; do
            if [ -f "$installer" ]; then
                chmod +x "$installer"
            fi
        done
    fi
    log_success "All necessary scripts are now executable."
}

install_core_dependencies() {
    log_info "--- PHASE 1: Installing Core Dependencies ---"
    sudo apt-get update
    
    # List of packages is broken into multiple lines for readability.
    sudo apt-get install -y \
        build-essential \
        ca-certificates \
        curl \
        docker.io \
        docker-compose \
        fd-find \
        figlet \
        fzf \
        git \
        jq \
        libfuse2 \
        lolcat \
        nodejs \
        npm \
        python3 \
        python3-pip \
        python3-venv \
        ripgrep \
        tar \
        unzip \
        wget

    # Create 'fd' symlink if needed (for Debian/Ubuntu where binary is 'fdfind').
    if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
        log_info "Creating 'fd' symlink for 'fdfind'."
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
    log_success "Core dependencies installed."
}

run_install_routines() {
    log_info "--- PHASE 2: Executing Modular Installation Routines ---"
    if [ ! -d "$INSTALL_ROUTINES_DIR" ]; then
        log_info "No install_routines directory found, skipping."
        return
    fi

    # Now that scripts are executable, run them directly.
    for installer in "$INSTALL_ROUTINES_DIR"/*.sh; do
        if [ -f "$installer" ]; then
            log_info "--> Running installer: $(basename "$installer")"
            "$installer"
        fi
    done
    log_success "All installation routines completed."
}

setup_user_configs() {
    log_info "--- PHASE 3: Setting Up User Configuration Files ---"
    "$SCRIPT_DIR/install_configs.sh"
    log_success "User configurations set up."
}

link_configurations() {
    log_info "--- PHASE 4: Linking All Dotfiles & Scripts ---"
    "$SCRIPT_DIR/install_links.sh"
    log_success "Dotfiles linked."
}

finalize_neovim() {
    log_info "--- PHASE 5: Finalizing Neovim Setup ---"
    # The chmod command is no longer needed here as it's handled by set_script_permissions
    "$SCRIPT_DIR/finalize_neovim.sh"
    log_success "Neovim finalization complete."
}

source_in_bashrc() {
    log_info "--- PHASE 6: Ensuring Shell Configuration is Loaded ---"
    local line_to_add="if [ -f ~/.bashrc_config ]; then . ~/.bashrc_config; fi"
    
    # Ensure the line is present in .bashrc for the new config to take effect.
    if grep -qFx -- "$line_to_add" ~/.bashrc; then
        log_info "Sourcing line already exists in ~/.bashrc. No action needed."
    else
        log_info "Adding sourcing line to ~/.bashrc for automation."
        echo "" >> ~/.bashrc
        echo "# Load custom shell functions and aliases from my_linux_setup" >> ~/.bashrc
        echo "$line_to_add" >> ~/.bashrc
        log_success "Sourcing line added to ~/.bashrc."
    fi
}

# --- Script Execution Orchestrator ---
main() {
    log_info "--- Starting Master Linux Environment Setup ---"
    
    check_sudo
    set_script_permissions
    install_core_dependencies
    run_install_routines
    setup_user_configs
    link_configurations
    finalize_neovim
    source_in_bashrc

    echo
    log_success "-------------------------------------------------"
    log_success "✅ Master Linux Setup Complete!"
    log_info "Please RESTART YOUR TERMINAL for all changes to take effect."
    log_success "-------------------------------------------------"
    exit 0
}

# Run the main function
main
