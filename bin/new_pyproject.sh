#!/bin/bash
# Simple script to set up a basic Python project structure.

# Check if a project name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <ProjectName>"
  exit 1
fi

PROJECT_NAME="$1"
PROJECT_DIR="./$PROJECT_NAME" # Create in current directory

# Check if directory already exists
if [ -d "$PROJECT_DIR" ]; then
  echo "Error: Directory '$PROJECT_DIR' already exists."
  exit 1
fi

echo "--- Creating Python project: $PROJECT_NAME ---"

# 1. Create project directory
echo "[1/4] Creating directory: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
if [ $? -ne 0 ]; then echo "Error creating directory."; exit 1; fi

# 2. Initialize Git repository
echo "[2/4] Initializing Git repository..."
# Ensure git exists before trying to use it
if ! command -v git &> /dev/null; then
    echo "Error: git command not found. Please install git."
    # Clean up created directory before exiting
    rmdir "$PROJECT_DIR" &> /dev/null || true
    exit 1
fi
# Suppress git output for cleaner script run
git init "$PROJECT_DIR" > /dev/null
if [ $? -ne 0 ]; then echo "Error initializing Git."; exit 1; fi

# 3. Create Python virtual environment
VENV_DIR="$PROJECT_DIR/.venv"
echo "[3/4] Creating Python virtual environment in $VENV_DIR..."
# Ensure python3 exists before trying to use it
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 command not found. Cannot create virtual environment."
    exit 1
fi
# Ensure venv module works (requires python3-venv package usually)
if ! python3 -m venv "$VENV_DIR"; then
    echo "Error: Failed creating virtual environment. Is python3-venv installed?"
    exit 1
fi

# 4. Create basic .gitignore file
GITIGNORE_FILE="$PROJECT_DIR/.gitignore"
echo "[4/4] Creating basic .gitignore file..."
# Using EOG (End Of Gitignore) as delimiter
cat << EOG > "$GITIGNORE_FILE"
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
echo "--- Project '$PROJECT_NAME' created successfully ---"
echo "Next steps:"
echo "1. Change into the project directory: cd $PROJECT_NAME"
echo "2. Activate the virtual environment: source .venv/bin/activate"
echo "3. Start coding!"
echo "-------------------------------------------------"

exit 0
