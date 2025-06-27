#!/bin/bash
# Simple script to set up a basic Python project structure inside ~/projects.

# --- Help Function ---
show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTION] <ProjectName>

Creates a standard boilerplate project for a Python application.

Arguments:
  <ProjectName>   The name of the project to create. This will be used for the
                  main project directory. It should not contain spaces.

Options:
  -h, --help      Display this help message and exit.

Description:
  This script automates the creation of a standard Python project structure.
  It performs the following steps:
  1. Creates a main project directory inside '$HOME/projects'.
  2. Initializes a Git repository within the new project directory.
  3. Creates a Python 3 virtual environment named '.venv' inside the project.
  4. Creates a comprehensive '.gitignore' file tailored for Python projects.

Dependencies:
  - python3 (and the python3-venv package)
  - git
EOF
}

# --- Argument Parsing for Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Configuration ---
PROJECTS_BASE_DIR="$HOME/projects"

# --- Input Validation ---
if [ -z "$1" ]; then
    echo "Error: ProjectName is a required argument." >&2
    echo "Usage: $(basename "$0") <ProjectName>" >&2
    echo "Use '$(basename "$0") --help' for more details." >&2
    exit 1
fi

PROJECT_NAME="$1"
# Define project path within the base directory
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"

# --- Cleanup Function ---
# Function to remove the project directory if script fails
cleanup() {
    echo "" # Newline for cleaner output on interruption
    echo "[Cleanup] Script interrupted or failed. Removing partial project $PROJECT_DIR..." >&2
    # Make sure PROJECT_DIR is set and is a directory before removing!
    if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        rm -rf "$PROJECT_DIR"
        if [ $? -eq 0 ]; then
            echo "[Cleanup] Removed $PROJECT_DIR." >&2
        else
            echo "[Cleanup Warning] Failed to remove '$PROJECT_DIR'. Please remove it manually." >&2
        fi
    else
        echo "[Cleanup] PROJECT_DIR variable not set or directory does not exist. No cleanup needed." >&2
    fi
}

# Set the trap to call cleanup function on ERR signal (error) or EXIT signal (includes Ctrl+C)
trap cleanup ERR EXIT

# --- Pre-checks ---
# Ensure the base projects directory exists
if [ ! -d "$PROJECTS_BASE_DIR" ]; then
    echo "Info: Base project directory '$PROJECTS_BASE_DIR' not found. Creating it..."
    mkdir -p "$PROJECTS_BASE_DIR"
fi

# Check if specific project directory already exists within the base dir
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
    echo "Error: git command not found. Please install git." >&2
    exit 1
fi
# Run git init directly on the target directory path
git init "$PROJECT_DIR" >/dev/null

# 3. Create Python virtual environment
VENV_DIR="$PROJECT_DIR/.venv"
echo "[3/4] Creating Python virtual environment in $VENV_DIR..."
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 command not found. Cannot create virtual environment." >&2
    exit 1
fi
if ! python3 -m venv "$VENV_DIR"; then
    echo "Error: Failed creating virtual environment. Is the 'python3-venv' package installed?" >&2
    exit 1
fi

# 4. Create basic .gitignore file
GITIGNORE_FILE="$PROJECT_DIR/.gitignore"
echo "[4/4] Creating basic .gitignore file..."
# Using EOG (End Of Gitignore) as delimiter
cat <<EOG >"$GITIGNORE_FILE"
# Virtual Environment
.venv/
venv/
*/.venv/
*/venv/
__pycache__/
*.pyc
*.pyo
*.pyd

# Build artifacts
build/
dist/
*.egg-info/
*.so
*.wheel

# Distribution / packaging
*.tar.gz
*.zip
*.whl

# IDE / Editor specific
.idea/
.vscode/
*.swp
*~
.DS_Store

# Other common Python ignores
*.log
*.pot
*.py[cod]

# Environment variables
.env
*.env.*
!*.env.example

# Instance Folder (Flask)
instance/

# Jupyter Notebook checkpoints
.ipynb_checkpoints

# Pytest cache
.pytest_cache/
.coverage
htmlcov/

# MyPy cache
.mypy_cache/

# Ruff cache
.ruff_cache/
EOG

echo ""
echo "--- Project '$PROJECT_NAME' created successfully in $PROJECT_DIR ---"
echo "Next steps:"
echo "1. Change into the new directory: cd '$PROJECT_DIR'"
echo "2. Activate the virtual environment: source .venv/bin/activate"
echo "-------------------------------------------------"

# Remove trap on successful exit
trap - ERR EXIT

exit 0
