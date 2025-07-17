#!/bin/bash
#
# Creates a standard boilerplate project for a Python application.

set -euo pipefail

# --- Configuration & Helpers ---
CONFIG_FILE="$HOME/.config/project_scaffolding/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

PROJECTS_BASE_DIR="${PROJECTS_BASE_DIR:-$HOME/projects}"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Main Logic ---
main() {
    if [ "$#" -ne 1 ]; then
        log_error "Usage: new_pyproject <ProjectName>"
    fi

    local project_name="$1"
    local project_path="$PROJECTS_BASE_DIR/$project_name"

    if [ -d "$project_path" ]; then
        log_error "Project directory already exists: $project_path"
    fi

    log_info "Creating Python project at: $project_path"

    mkdir -p "$project_path"
    cd "$project_path"

    log_info "  -> Initializing Git repository..."
    git init

    log_info "  -> Creating Python virtual environment (.venv)..."
    python3 -m venv .venv

    log_info "  -> Generating .gitignore for Python..."
    cat <<EOF > .gitignore
# Python
__pycache__/
*.py[cod]
*$py.class

# venv
.venv/
EOF

    log_success "Project '$project_name' created successfully."
    log_info "Run 'cd $project_path' to get started."
}

main "$@"
