#!/bin/bash
# Creates a basic HTML/CSS/JS project structure.
# Version 2.0: Reads base directory from an optional config file.

# --- Help Function ---
show_help() {
    echo "Creates a boilerplate project for a simple HTML/CSS/JS web application."
    echo "Usage: new_webproject <ProjectName>"
    echo "For detailed instructions, see the README.md in the project_scaffolding project."
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi
if [ -z "$1" ]; then
    echo "Error: ProjectName is a required argument." >&2
    echo "Usage: new_webproject <ProjectName>" >&2
    exit 1
fi

# Exit immediately if a command fails
set -e

# --- Configuration ---
PROJECTS_BASE_DIR="$HOME/projects"

USER_CONFIG_FILE="$HOME/.config/project_scaffolding/config"
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

PROJECT_NAME="$1"
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"

# --- Cleanup Function ---
cleanup() {
    echo ""
    echo "[Cleanup] Removing partial project $PROJECT_DIR..." >&2
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR"
        echo "[Cleanup] Removed $PROJECT_DIR." >&2
    fi
}
trap cleanup ERR EXIT

# --- Pre-checks ---
if [ ! -d "$PROJECTS_BASE_DIR" ]; then
    echo "Info: Base project directory '$PROJECTS_BASE_DIR' not found. Creating it..."
    mkdir -p "$PROJECTS_BASE_DIR"
fi
if [ -d "$PROJECT_DIR" ]; then
    echo "Error: Project directory '$PROJECT_DIR' already exists." >&2
    exit 1
fi

echo "--- Creating web project: $PROJECT_NAME in $PROJECTS_BASE_DIR ---"

# 1. Create directories and files
echo "[1/4] Creating directory structure and boilerplate files..."
mkdir -p "$PROJECT_DIR"/{css,js,images}

cat <<EOF >"$PROJECT_DIR/index.html"
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>${PROJECT_NAME}</title><link rel="stylesheet" href="css/styles.css"></head><body><h1>Welcome to ${PROJECT_NAME}!</h1><script src="js/script.js"></script></body></html>
EOF

cat <<EOF >"$PROJECT_DIR/css/styles.css"
body { font-family: system-ui, sans-serif; line-height: 1.6; padding: 20px; }
EOF

cat <<EOF >"$PROJECT_DIR/js/script.js"
console.log('Hello from ${PROJECT_NAME} script!');
EOF

# 2. Create README.md
echo "[2/4] Creating README.md..."
echo "# ${PROJECT_NAME}" >"$PROJECT_DIR/README.md"

# 3. Initialize Git repository
if command -v git &>/dev/null; then
    echo "[3/4] Initializing Git repository..."
    cd "$PROJECT_DIR"
    git init -b main >/dev/null

    # Create .gitignore
    echo -e ".vscode/\n.DS_Store\nnode_modules/" >.gitignore

    # Add and commit
    git add .
    git commit -m "Initial project structure" >/dev/null 2>&1 || true
    cd - >/dev/null # Go back to original directory
else
    echo "[3/4] Skipping Git initialization (git not found)."
fi

# 4. Open in Neovim (optional)
if command -v nvim &>/dev/null; then
    echo "[4/4] Handing off to Neovim..."
    trap - ERR EXIT # Success, disable cleanup
    nvim "$PROJECT_DIR"
else
    echo "[4/4] Skipping Neovim (nvim not found)."
fi

# --- Finalize ---
trap - ERR EXIT
echo ""
echo "--- Web project '$PROJECT_NAME' created successfully ---"
exit 0
