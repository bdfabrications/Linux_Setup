#!/bin/bash
# install_routines/50_pre-commit.sh
# Installs the pre-commit framework for managing git hooks.

set -e
echo "Installing pre-commit..."

# Ensure pipx path is available in the current script session
export PATH="$PATH:$HOME/.local/bin"

if ! command -v pre-commit &>/dev/null; then
    echo "Installing pre-commit via pipx..."
    # Use pipx to install pre-commit in an isolated environment
    if pipx install pre-commit; then
        echo "pre-commit installed successfully."
    else
        echo "[Error] Failed to install pre-commit using pipx." >&2
        exit 1
    fi
else
    echo "pre-commit is already installed."
fi

pre-commit --version
