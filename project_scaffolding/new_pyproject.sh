#!/bin/bash
# Simple script to set up a basic Python project structure.
# Version 2.0: Reads base directory from an optional config file.

# --- Help Function ---
show_help() {
    echo "Creates a standard boilerplate project for a Python application."
    echo "Usage: new_pyproject <ProjectName>"
    echo "For detailed instructions, see the README.md in the project_scaffolding project."
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi
if [ -z "$1" ]; then
    echo "Error: ProjectName is a required argument." >&2
    echo "Usage: new_pyproject <ProjectName>" >&2
    exit 1
fi

# --- Configuration ---
# Define a default base directory.
PROJECTS_BASE_DIR="$HOME/projects"

# Define the path to the user's private config file.
USER_CONFIG_FILE="$HOME/.config/project_scaffolding/config"

# If the user's config file exists, source it to override the default.
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

PROJECT_NAME="$1"
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"

# --- Cleanup Function ---
cleanup() {
    echo ""
    echo "[Cleanup] Script interrupted or failed. Removing partial project $PROJECT_DIR..." >&2
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

echo "--- Creating Python project: $PROJECT_NAME in $PROJECTS_BASE_DIR ---"

# 1. Create project directory
echo "[1/4] Creating directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"

# 2. Initialize Git repository
echo "[2/4] Initializing Git repository..."
if ! command -v git &>/dev/null; then
    echo "Error: git not found." >&2
    exit 1
fi
git init "$PROJECT_DIR" >/dev/null

# 3. Create Python virtual environment
echo "[3/4] Creating Python virtual environment..."
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 not found." >&2
    exit 1
fi
if ! python3 -m venv "$PROJECT_DIR/.venv"; then
    echo "Error: Failed creating venv. Is 'python3-venv' installed?" >&2
    exit 1
fi

# 4. Create .gitignore file
echo "[4/4] Creating .gitignore file..."
cat <<EOG >"$PROJECT_DIR/.gitignore"
# Virtual Environment
.venv/
venv/
__pycache__/

# IDE / Editor specific
.idea/
.vscode/
*.swp
*~
.DS_Store

# Environment variables
.env
.env.*
!*.env.example

# Build artifacts
build/
dist/
*.egg-info/
EOG

echo ""
echo "--- Project '$PROJECT_NAME' created successfully ---"
echo "Next steps:"
echo "1. cd '$PROJECT_DIR'"
echo "2. source .venv/bin/activate"

trap - ERR EXIT
exit 0
