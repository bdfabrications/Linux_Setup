#!/bin/bash
# Creates a basic HTML/CSS/JS project structure.
# Version 3.0: Adds pre-commit, justfile, and devcontainer.

# --- Help Function & Argument Parsing (remains the same) ---

# --- Configuration ---
PROJECTS_BASE_DIR="$HOME/projects"
USER_CONFIG_FILE="$HOME/.config/project_scaffolding/config"
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi
PROJECT_NAME="$1"
PROJECT_DIR="$PROJECTS_BASE_DIR/$PROJECT_NAME"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- Pre-checks (remains the same) ---

echo "--- Creating web project: $PROJECT_NAME in $PROJECTS_BASE_DIR ---"

# 1. Create directories and boilerplate files
mkdir -p "$PROJECT_DIR"/{css,js,images}
# ... (file creation remains the same) ...

# 2. Initialize Git and create .gitignore
git init "$PROJECT_DIR" -b main >/dev/null
echo -e ".vscode/\n.DS_Store\nnode_modules/\n.devcontainer/" > "$PROJECT_DIR/.gitignore"

# --- NEW: Add justfile ---
echo "[3/6] Creating justfile..."
cat <<EOF >"$PROJECT_DIR/justfile"
# justfile for ${PROJECT_NAME}

# Serve the site locally
serve:
    serve_here 8000

# Run linting and formatting
lint:
    pre-commit run --all-files
EOF

# --- NEW: Add devcontainer ---
echo "[4/6] Creating Dev Container config..."
mkdir -p "$PROJECT_DIR/.devcontainer"
cat <<EOF >"$PROJECT_DIR/.devcontainer/devcontainer.json"
{
  "name": "Web Project",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {}
  },
  "forwardPorts": [8000],
  "postCreateCommand": "npm install -g live-server"
}
EOF

# --- NEW: Add pre-commit ---
echo "[5/6] Setting up pre-commit..."
cp "$REPO_DIR/code_quality/.pre-commit-config.yaml" "$PROJECT_DIR/.pre-commit-config.yaml"
cd "$PROJECT_DIR"
git add .
git commit -m "Initial project structure" >/dev/null
pre-commit install >/dev/null
cd - >/dev/null

# 6. Open in Neovim (optional)
# ... (remains the same) ...
