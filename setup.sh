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
        nodejs npm
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
    local repo_dir="${HOME}/${REPO_NAME}"
    
    if [[ -d "${repo_dir}" ]]; then
        log_info "Repository already exists, updating..."
        cd "${repo_dir}"
        git pull origin main || {
            log_warning "Failed to update repository, continuing with existing version"
        }
    else
        log_info "Cloning repository..."
        cd "${HOME}"
        git clone "${REPO_URL}" "${REPO_NAME}"
        cd "${repo_dir}"
    fi
    
    # Export the repository path for use by install routines
    export REPO_ROOT_DIR="${repo_dir}"
    export INSTALL_ROUTINES_DIR="${repo_dir}/install_routines"
    
    log_success "Repository ready at: ${repo_dir}"
}

install_oh_my_posh() {
    if command_exists oh-my-posh; then
        log_info "Oh My Posh already installed, skipping..."
        return
    fi
    
    log_info "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
    log_success "Oh My Posh installed"
}

install_neovim() {
    local nvim_version="v0.11.2"
    local nvim_url="https://github.com/neovim/neovim/releases/download/${nvim_version}/nvim-linux-x86_64.appimage"
    local nvim_dest="/usr/local/bin/nvim"
    
    if command_exists nvim && nvim --version | grep -q "${nvim_version}"; then
        log_info "Neovim ${nvim_version} already installed, skipping..."
        return
    fi
    
    log_info "Installing Neovim ${nvim_version}..."
    
    # Remove any existing installations
    sudo apt-get remove --purge neovim neovim-runtime -y >/dev/null 2>&1 || true
    sudo rm -f "${nvim_dest}"
    
    # Download and install AppImage
    sudo curl -fLo "${nvim_dest}" "${nvim_url}"
    sudo chmod +x "${nvim_dest}"
    
    log_success "Neovim installed"
}

install_astronvim() {
    local astronvim_dir="${HOME}/.config/nvim"
    
    if [[ -d "${astronvim_dir}" ]] && [[ -f "${astronvim_dir}/lua/community.lua" ]]; then
        log_info "AstroNvim configuration already exists, skipping..."
        return
    fi
    
    log_info "Installing AstroNvim configuration..."
    
    # Backup existing config if it exists
    if [[ -d "${astronvim_dir}" ]]; then
        log_warning "Backing up existing Neovim config to ~/.config/nvim.backup"
        mv "${astronvim_dir}" "${astronvim_dir}.backup"
    fi
    
    # Clone AstroNvim template
    git clone --depth 1 https://github.com/AstroNvim/template "${astronvim_dir}"
    
    # Remove .git directory from template
    rm -rf "${astronvim_dir}/.git"
    
    log_success "AstroNvim configuration installed"
}

install_docker() {
    if command_exists docker; then
        log_info "Docker already installed, skipping..."
        return
    fi
    
    log_info "Installing Docker..."
    
    # Install Docker using the official installation script
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    
    # Add user to docker group (if USER is set and not root)
    if [[ -n "${USER:-}" ]] && [[ "${USER}" != "root" ]]; then
        sudo usermod -aG docker "${USER}"
    elif [[ -z "${USER:-}" ]] && [[ "$(id -u)" != "0" ]]; then
        # Get username from id if USER is not set and we're not root
        local current_user="$(id -un)"
        sudo usermod -aG docker "${current_user}"
    fi
    
    log_success "Docker installed (you may need to log out and back in for group changes to take effect)"
}

install_ollama() {
    if command_exists ollama; then
        log_info "Ollama already installed, skipping..."
        return
    fi
    
    log_info "Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
    log_success "Ollama installed"
}

install_pipx() {
    if command_exists pipx; then
        log_info "pipx already installed, skipping..."
        return
    fi
    
    log_info "Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    log_success "pipx installed"
}

install_additional_tools() {
    log_info "Installing additional development tools..."
    
    # Install Rust toolchain
    if ! command_exists rustc; then
        log_info "Installing Rust toolchain..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "${HOME}/.cargo/env"
        log_success "Rust toolchain installed"
    fi
    
    # Install eza (modern ls replacement) via cargo
    if ! command_exists eza; then
        log_info "Installing eza..."
        cargo install eza
        log_success "eza installed"
    fi
    
    # Install zoxide (smart cd command) via cargo
    if ! command_exists zoxide; then
        log_info "Installing zoxide..."
        cargo install zoxide
        log_success "zoxide installed"
    fi
    
    # Install just (command runner) via cargo
    if ! command_exists just; then
        log_info "Installing just..."
        cargo install just
        log_success "just installed"
    fi
    
    # Install pre-commit via pipx
    if ! command_exists pre-commit; then
        log_info "Installing pre-commit..."
        pipx install pre-commit
        log_success "pre-commit installed"
    fi
    
    # Install 1Password CLI
    if ! command_exists op; then
        log_info "Installing 1Password CLI..."
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
        sudo apt update
        sudo apt install -y 1password-cli
        log_success "1Password CLI installed"
    fi
}

setup_user_configs() {
    log_info "Setting up user configuration files..."
    
    local projects=(
        "backup_system"
        "ollama_helper:shell_helpers/ollama_chat"
        "project_scaffolding"
        "remind_me"
        "rgf_helper:shell_helpers/rgf_helper"
        "simple_server:shell_helpers/simple_server"
    )
    
    for project in "${projects[@]}"; do
        local config_name="${project%%:*}"
        local project_path="${project#*:}"
        [[ "${project_path}" == "${config_name}" ]] && project_path="${config_name}"
        
        local target_config_dir="${HOME}/.config/${config_name}"
        local target_config_file="${target_config_dir}/config"
        local source_config_example="${REPO_ROOT_DIR}/${project_path}/config.example"
        
        if [[ -f "${source_config_example}" ]]; then
            mkdir -p "${target_config_dir}"
            if [[ ! -f "${target_config_file}" ]]; then
                cp "${source_config_example}" "${target_config_file}"
                chmod 600 "${target_config_file}"
                log_info "Created config template: ${target_config_file}"
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
        ln -sfn "${REPO_ROOT_DIR}/${source_path}" "${target_bin_dir}/${target_name}"
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

finalize_neovim_setup() {
    log_info "Finalizing Neovim setup..."
    
    # Run Neovim to trigger lazy.nvim installation
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    
    log_success "Neovim setup finalized"
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
    log_info "• Programming runtimes (Python, Node.js, Rust)"
    log_info "• Command-line utilities (fzf, ripgrep, eza, zoxide, just)"
    log_info "• Applications (Neovim with AstroNvim, Docker, Ollama, 1Password CLI)"
    log_info "• Shell enhancements (Oh My Posh, custom aliases and functions)"
    log_info "• Development tools (pre-commit, pipx)"
    echo
    log_info "Next steps:"
    log_info "1. Restart your terminal or run: source ~/.bashrc"
    log_info "2. Your dotfiles and configurations are now active"
    log_info "3. Edit config files in ~/.config/ to customize your setup"
    log_info "4. The first time you run 'nvim', AstroNvim will complete its setup"
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
    
    # Install applications
    install_oh_my_posh
    install_neovim
    install_astronvim
    install_docker
    install_ollama
    install_pipx
    install_additional_tools
    
    # Setup configurations and links
    setup_user_configs
    setup_symlinks
    finalize_shell_setup
    finalize_neovim_setup
    
    show_completion_message
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi