#!/bin/bash
#
# install_links.sh - Deploys all personal configurations by creating symbolic links.
# This is the "heart" of the setup, linking repository files to their correct
# locations in the user's home directory.

set -euo pipefail

# --- Configuration and Helper Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." &>/dev/null && pwd)"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }

# --- Main Logic ---

log_info "Creating symbolic links for configuration files..."

# Ensure the target directories exist.
mkdir -p "$HOME/.config"
mkdir -p "$HOME/bin"

# --- Link Core Shell Configuration ---
log_info "Linking shell configuration..."
ln -sf "$REPO_ROOT/shell_config/bashrc_config" "$HOME/.bashrc_config"
ln -sf "$REPO_ROOT/shell_config/bash_aliases" "$HOME/.bash_aliases"

# --- Link Tmux Configuration ---
log_info "Linking tmux configuration..."
ln -sf "$REPO_ROOT/tmux_config/tmux.conf" "$HOME/.tmux.conf"

# --- Link Oh My Posh Themes ---
log_info "Linking Oh My Posh themes directory..."
ln -sf "$REPO_ROOT/shell_theming/poshthemes" "$HOME/.poshthemes"

# --- Link AstroNvim Configuration ---
log_info "Linking AstroNvim user configuration..."
mkdir -p "$HOME/.config/nvim/lua/user"
ln -sf "$REPO_ROOT/astronvim/init.lua" "$HOME/.config/nvim/lua/user/init.lua"

# --- Link All Helper Scripts to ~/bin ---
log_info "Linking all helper scripts to '$HOME/bin'..."
# Find all files (not directories) in all subdirectories of shell_helpers and system_manager,
# excluding READMEs and config examples, and link them.
find "$REPO_ROOT/shell_helpers" "$REPO_ROOT/system_manager" -mindepth 2 -type f \
    ! -name 'README.md' ! -name 'config.example' | while read -r script_path; do
    script_name=$(basename "$script_path")
    ln -sf "$script_path" "$HOME/bin/$script_name"
    log_info "  -> Linked '$script_name'"
done

# --- Final PATH Validation ---
# Check if ~/bin is in the user's PATH. This is a critical check.
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    log_warn "Your PATH does not seem to include '$HOME/bin'."
    log_warn "Please add 'export PATH=\"\$HOME/bin:\$PATH\"' to your ~/.bashrc or ~/.profile and restart your shell."
else
    log_info "'$HOME/bin' is correctly found in your PATH."
fi

log_success "Symbolic link setup complete."
