#!/bin/bash
# Simple script to set up a basic Python project structure.
# Version 3.0: Adds justfile and pre-commit integration.

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
PROJECTS_BASE_DIR="$HOME/projects"
USER_CONFIG_FILE="$HOME/.config/project_scaffolding/config"
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

PROJECT_NAME="$1"
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" # Assumes script is in project_scaffolding

# --- Pre-checks ---
# ... (pre-checks remain the same) ...

echo "--- Creating Python project: $PROJECT_NAME in $PROJECTS_BASE_DIR ---"

# 1. Create project directory
mkdir -p "$PROJECT_DIR"

# 2. Initialize Git repository
git init "$PROJECT_DIR" >/dev/null

# 3. Create Python virtual environment and .gitignore
python3 -m venv "$PROJECT_DIR/.venv"
# ... (.gitignore creation remains the same) ...

# --- NEW: Add justfile ---
echo "[4/5] Creating justfile..."
cat <<EOF >"$PROJECT_DIR/justfile"
# justfile for ${PROJECT_NAME}

# Activate the virtual environment
venv:
    source .venv/bin/activate

# Install dependencies
install:
    pip install -r requirements.txt

# Run linting and formatting
lint:
    pre-commit run --all-files
EOF

# --- NEW: Add pre-commit ---
echo "[5/5] Setting up pre-commit..."
cp "$REPO_DIR/code_quality/.pre-commit-config.yaml" "$PROJECT_DIR/.pre-commit-config.yaml"
cd "$PROJECT_DIR"
git add .
git commit -m "Initial project structure with pre-commit and justfile" >/dev/null
pre-commit install >/dev/null
cd - >/dev/null

echo ""
echo "--- Project '$PROJECT_NAME' created successfully ---"
echo "Next steps:"
echo "1. cd '$PROJECT_DIR'"
echo "2. source .venv/bin/activate"
