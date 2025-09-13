#!/bin/bash
#
# Linux Setup - Fully Automated Environment Configuration
# https://github.com/bdfabrications/Linux_Setup
#
# This script provides a one-command setup for a complete Linux development environment.
# It installs all necessary tools, configurations, and dotfiles automatically.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/bdfabrications/Linux_Setup/main/setup.sh | bash
#   OR
#   git clone https://github.com/bdfabrications/Linux_Setup.git && cd Linux_Setup && ./setup.sh
#

set -e
set -u
set -o pipefail

# --- Constants and Configuration ---
readonly SCRIPT_NAME="$(basename "${0}")"
readonly REPO_URL="https://github.com/bdfabrications/Linux_Setup.git"
readonly REPO_NAME="Linux_Setup"
readonly LOG_FILE="/tmp/linux_setup_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# --- Utility Functions ---
log() {
    echo -e "${1}" | tee -a "${LOG_FILE}"
}

log_info() {
    log "${BLUE}[INFO]${NC} ${1}"
}

log_success() {
    log "${GREEN}[SUCCESS]${NC} ${1}"
}

log_warning() {
    log "${YELLOW}[WARNING]${NC} ${1}"
}

log_error() {
    log "${RED}[ERROR]${NC} ${1}" >&2
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_wsl() {
    grep -qi microsoft /proc/version 2>/dev/null || [[ "${WSL_DISTRO_NAME:-}" != "" ]]
}

check_prerequisites() {
    local missing_tools=()

    # Check for essential tools
    if ! command_exists curl; then missing_tools+=("curl"); fi
    if ! command_exists git; then missing_tools+=("git"); fi
    if ! command_exists sudo; then missing_tools+=("sudo"); fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing essential tools: ${missing_tools[*]}"
        log_error "Please install them manually first: sudo apt install ${missing_tools[*]}"
        exit 1
    fi

    # Check if we're running on a supported system
    if [[ ! -f /etc/debian_version ]]; then
        log_warning "This script is optimized for Debian/Ubuntu-based systems"
        log_warning "It may not work correctly on other distributions"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

install_core_dependencies() {
    log_info "Installing core system dependencies..."

    # Update package lists
    sudo apt update

    # Core packages - essential for the entire setup
    local core_packages=(
        build-essential git curl wget ca-certificates tar
        python3 python3-pip python3-venv
        figlet fzf ripgrep fd-find unzip jq
        libfuse2  # Required for AppImages
        lolcat    # For colorful output
    )

    sudo apt install -y "${core_packages[@]}"

    # Create 'fd' symlink if needed (Debian-based systems use 'fdfind')
    if command_exists fdfind && ! command_exists fd; then
        log_info "Creating 'fd' symlink for 'fdfind'..."
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi

    log_success "Core dependencies installed"
}

setup_repository() {
    local repo_dir=""

    # Check if we're already running from within the repository
    if [[ -f "${PWD}/setup.sh" && -d "${PWD}/shell_config" ]]; then
        repo_dir="${PWD}"
        log_info "Running from existing repository directory: ${repo_dir}"
    else
        # Try to find existing repository in common locations
        local possible_locations=(
            "${HOME}/projects/${REPO_NAME}"
            "${HOME}/${REPO_NAME}"
            "${HOME}/dev/${REPO_NAME}"
            "${HOME}/Development/${REPO_NAME}"
            "${HOME}/code/${REPO_NAME}"
        )

        for location in "${possible_locations[@]}"; do
            if [[ -d "${location}" && -f "${location}/setup.sh" ]]; then
                repo_dir="${location}"
                log_info "Found existing repository at: ${repo_dir}"
                cd "${repo_dir}"
                git pull origin main || {
                    log_warning "Failed to update repository, continuing with existing version"
                }
                break
            fi
        done

        # If no existing repository found, clone to preferred location
        if [[ -z "${repo_dir}" ]]; then
            # Determine best location for cloning
            if [[ -d "${HOME}/projects" ]]; then
                repo_dir="${HOME}/projects/${REPO_NAME}"
                cd "${HOME}/projects"
            elif [[ -d "${HOME}/dev" ]]; then
                repo_dir="${HOME}/dev/${REPO_NAME}"
                cd "${HOME}/dev"
            elif [[ -d "${HOME}/Development" ]]; then
                repo_dir="${HOME}/Development/${REPO_NAME}"
                cd "${HOME}/Development"
            elif [[ -d "${HOME}/code" ]]; then
                repo_dir="${HOME}/code/${REPO_NAME}"
                cd "${HOME}/code"
            else
                # Fall back to home directory
                repo_dir="${HOME}/${REPO_NAME}"
                cd "${HOME}"
            fi

            log_info "Cloning repository to: ${repo_dir}"
            git clone "${REPO_URL}" "${REPO_NAME}"
            cd "${repo_dir}"
        fi
    fi

    # Export the repository path for use by install routines
    export REPO_ROOT_DIR="${repo_dir}"
    export INSTALL_ROUTINES_DIR="${repo_dir}/install_routines"

    log_success "Repository ready at: ${repo_dir}"
}

# Run a modular install routine script
run_install_routine() {
    local script_name="$1"
    local script_path="${INSTALL_ROUTINES_DIR}/${script_name}"

    if [[ -f "${script_path}" ]]; then
        log_info "Running install routine: ${script_name}"
        if [[ -x "${script_path}" ]]; then
            bash "${script_path}"
        else
            log_warning "Script ${script_name} is not executable, making it executable and running..."
            chmod +x "${script_path}"
            bash "${script_path}"
        fi
        log_success "Completed install routine: ${script_name}"
    else
        log_warning "Install routine not found: ${script_name}"
    fi
}

install_applications() {
    log_info "Installing applications using modular install routines..."

    # Install applications in order (using numbered prefixes)
    run_install_routine "10_oh_my_posh.sh"
    run_install_routine "15_tmux.sh"
    run_install_routine "20_neovim.sh"
    run_install_routine "25_astronvim.sh"
    run_install_routine "30_ollama.sh"
    run_install_routine "40_docker.sh"
    run_install_routine "70_terminal_enhancements.sh"
    run_install_routine "75_tmux_config.sh"
    run_install_routine "80_1password_cli.sh"
}

install_nodejs() {
    if command_exists node; then
        log_info "Node.js already installed, skipping..."
        return
    fi

    log_info "Installing Node.js via nvm..."

    # Install nvm (Node Version Manager)
    local nvm_version="v0.39.7"
    local nvm_url="https://raw.githubusercontent.com/nvm-sh/nvm/${nvm_version}/install.sh"

    # Download and run nvm installer
    curl -o- "${nvm_url}" | bash

    # Source nvm to make it available in current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Install latest LTS version of Node.js
    nvm install --lts
    nvm use --lts
    nvm alias default lts/*

    log_success "Node.js (LTS) installed via nvm"
}

setup_user_configs() {
    log_info "Setting up user configuration files..."

    # Configuration mappings: config_name:source_path
    local projects=(
        "backup_system:backup_system"
        "ollama_helper:shell_helpers/ollama_chat"
        "project_scaffolding:project_scaffolding"
        "remind_me:remind_me"
        "rgf_helper:shell_helpers/rgf_helper"
        "simple_server:shell_helpers/simple_server"
        "bash-personal:shell_config"  # Special case for welcome message personal config
    )

    for project in "${projects[@]}"; do
        local config_name="${project%%:*}"
        local project_path="${project#*:}"

        local target_config_dir="${HOME}/.config/${config_name}"
        local target_config_file="${target_config_dir}/config"
        local source_config_example="${REPO_ROOT_DIR}/${project_path}/config.example"

        # Create the config directory
        mkdir -p "${target_config_dir}"

        if [[ -f "${source_config_example}" ]]; then
            # Copy the config.example to config if it doesn't exist
            if [[ ! -f "${target_config_file}" ]]; then
                cp "${source_config_example}" "${target_config_file}"
                chmod 600 "${target_config_file}"
                log_info "Created config template: ${target_config_file}"
            fi
        elif [[ "${config_name}" == "bash-personal" ]]; then
            # Special case: create empty bash-personal config to prevent welcome message errors
            if [[ ! -f "${target_config_file}" ]]; then
                cat > "${target_config_file}" << 'EOF'
# Personal configuration for the welcome message
# This file prevents error messages in the welcome script

# Customize your welcome message figlet text
# FIGLET_TEXT="Your Name"

# Set your location for weather (can be city name, zip code, or lat,lon)
# LOCATION="Austin, TX"

EOF
                chmod 600 "${target_config_file}"
                log_info "Created bash-personal config template: ${target_config_file}"
            fi
        fi
    done

    log_success "User configurations set up"
}

setup_symlinks() {
    log_info "Setting up symlinks..."

    local target_bin_dir="${HOME}/bin"
    mkdir -p "${target_bin_dir}"

    # Executable scripts
    local scripts=(
        "remind_me/remind_me.sh:remind_me"
        "remind_me/email_test.sh:email_test"
        "backup_system/backup_dir.sh:backup_dir"
        "backup_system/sync_backup.sh:sync_backup"
        "system_manager/update_system.sh:update_system"
        "project_scaffolding/new_pyproject.sh:new_pyproject"
        "project_scaffolding/new_webproject.sh:new_webproject"
        "shell_helpers/rgf_helper/rgf.sh:rgf"
        "shell_helpers/simple_server/serve_here.sh:serve_here"
        "shell_helpers/ollama_chat/ollama_chat.sh:ollama_chat"
    )

    for script in "${scripts[@]}"; do
        local source_path="${script%%:*}"
        local target_name="${script#*:}"
        local full_source_path="${REPO_ROOT_DIR}/${source_path}"
        local full_target_path="${target_bin_dir}/${target_name}"

        if [[ -f "${full_source_path}" ]]; then
            ln -sfn "${full_source_path}" "${full_target_path}"
            log_info "Created symlink: ${target_name} -> ${source_path}"
        else
            log_warning "Source script not found: ${source_path}"
        fi
    done

    # Shell configurations
    ln -sfn "${REPO_ROOT_DIR}/shell_config/bash_aliases" "${HOME}/.bash_aliases"
    ln -sfn "${REPO_ROOT_DIR}/shell_config/bashrc_config" "${HOME}/.bashrc_config"

    # Oh My Posh themes
    ln -sfn "${REPO_ROOT_DIR}/shell_theming/poshthemes" "${HOME}/.poshthemes"

    log_success "Symlinks created"
}

finalize_shell_setup() {
    log_info "Finalizing shell setup..."

    # Add bashrc_config to .bashrc if not already present
    local bashrc_line="if [ -f ~/.bashrc_config ]; then . ~/.bashrc_config; fi"
    if ! grep -q "bashrc_config" "${HOME}/.bashrc" 2>/dev/null; then
        echo "" >> "${HOME}/.bashrc"
        echo "# Linux Setup - Custom configuration" >> "${HOME}/.bashrc"
        echo "${bashrc_line}" >> "${HOME}/.bashrc"
        log_success "Added custom configuration to .bashrc"
    else
        log_info ".bashrc already configured"
    fi

    # Ensure ~/bin is in PATH
    local path_line='export PATH="$HOME/bin:$PATH"'
    if ! grep -q 'export PATH="$HOME/bin:$PATH"' "${HOME}/.bashrc" 2>/dev/null; then
        echo "${path_line}" >> "${HOME}/.bashrc"
        log_success "Added ~/bin to PATH"
    fi
}

finalize_astronvim_setup() {
    log_info "Finalizing AstroNvim setup with personal customizations..."

    local nvim_config_dir="${HOME}/.config/nvim"
    local astronvim_user_dir="${nvim_config_dir}/lua/user"
    local repo_astronvim_user_config="${REPO_ROOT_DIR}/astronvim/lua/user"

    # Check if we have personal AstroNvim configuration to link
    if [[ -d "${repo_astronvim_user_config}" ]]; then
        log_info "Linking personal AstroNvim user configuration..."
        # Remove the default user directory if it exists
        rm -rf "${astronvim_user_dir}"
        # Create symlink to our custom user configuration
        ln -sfn "${repo_astronvim_user_config}" "${astronvim_user_dir}"
        log_success "Personal AstroNvim configuration linked"
    else
        log_info "No personal AstroNvim user configuration found, using template defaults"
    fi

    # Run Neovim to trigger plugin installation and synchronization
    if command_exists nvim; then
        log_info "Running Neovim plugin synchronization..."
        nvim --headless "+Lazy! sync" +qa 2>/dev/null || {
            log_warning "Plugin sync completed with warnings (this is normal for first run)"
        }
        log_success "AstroNvim setup finalized"
    else
        log_warning "Neovim not found in PATH, skipping plugin sync"
    fi
}

cleanup() {
    log_info "Cleaning up temporary files..."
    # Add any cleanup tasks here if needed
}

show_completion_message() {
    echo
    log_success "🎉 Linux Setup Complete!"
    echo
    log_info "What was installed:"
    log_info "• Core development tools (git, curl, build tools, etc.)"
    log_info "• Programming runtimes (Python, Node.js via nvm, Rust)"
    log_info "• Command-line utilities (fzf, ripgrep, eza, zoxide, just)"
    log_info "• Applications (Neovim with AstroNvim, Docker, Ollama, 1Password CLI)"
    log_info "• Shell enhancements (Oh My Posh, custom aliases and functions)"
    log_info "• Personal configurations and symbolic links"
    echo
    log_info "Next steps:"
    log_info "1. Restart your terminal or run: source ~/.bashrc"
    log_info "2. Install a Nerd Font for proper shell prompt display"
    log_info "3. Your dotfiles and configurations are now active"
    log_info "4. Edit config files in ~/.config/ to customize your setup"
    log_info "5. The first time you run 'nvim', AstroNvim may complete additional setup"
    echo
    log_info "Configuration files created in ~/.config/:"
    log_info "• backup_system/config - Backup destinations and settings"
    log_info "• remind_me/config - Email and notification settings"
    log_info "• ollama_helper/config - AI model preferences"
    log_info "• bash-personal/config - Personal welcome message settings"
    log_info "• And more... Edit these to customize your setup"
    echo
    log_info "Log file saved to: ${LOG_FILE}"
    echo
    if is_wsl; then
        log_warning "WSL detected: You may need to restart your WSL session for Docker to work properly"
    fi
}

main() {
    # Trap to ensure cleanup runs on exit
    trap cleanup EXIT

    log_info "Starting Linux Setup - Automated Environment Configuration"
    log_info "Log file: ${LOG_FILE}"
    echo

    check_prerequisites
    install_core_dependencies
    setup_repository

    # Change to repository directory for the rest of the setup
    cd "${REPO_ROOT_DIR}"

    # Install applications using modular scripts
    install_applications
    install_nodejs

    # Setup configurations and links
    setup_user_configs
    setup_symlinks
    finalize_shell_setup
    finalize_astronvim_setup

    show_completion_message
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi