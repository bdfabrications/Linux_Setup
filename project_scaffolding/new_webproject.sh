#!/bin/bash
#
# Creates a standard boilerplate project for a simple web application.

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
        log_error "Usage: new_webproject <ProjectName>"
    fi

    local project_name="$1"
    local project_path="$PROJECTS_BASE_DIR/$project_name"

    if [ -d "$project_path" ]; then
        log_error "Project directory already exists: $project_path"
    fi

    log_info "Creating web project at: $project_path"
    mkdir -p "$project_path"
    cd "$project_path"

    log_info "  -> Creating subdirectories (css, js, images)..."
    mkdir -p css js images

    log_info "  -> Creating boilerplate files..."
    cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${project_name}</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
    <h1>Welcome to ${project_name}</h1>
    <script src="js/script.js"></script>
</body>
</html>
EOF

    touch css/styles.css
    touch js/script.js

    log_info "  -> Initializing Git repository and making first commit..."
    git init
    git add .
    git commit -m "feat: Initial project structure"

    log_success "Project '$project_name' created successfully."

    # Optional: Open in Neovim if available
    if command -v nvim &> /dev/null; then
        log_info "Opening project in Neovim..."
        nvim .
    else
        log_info "Run 'cd $project_path' to get started."
    fi
}

main "$@"
