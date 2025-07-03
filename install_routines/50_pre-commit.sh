#!/bin/bash
# install_routines/50_pre-commit.sh
# Installs the pre-commit framework for managing git hooks.

set -e
echo "Installing pre-commit..."

if ! command -v pre-commit &>/dev/null; then
    echo "Installing pre-commit via pip..."
    if sudo python3 -m pip install pre-commit; then
        echo "pre-commit installed successfully."
    else
        echo "[Error] Failed to install pre-commit." >&2
        exit 1
    fi
else
    echo "pre-commit is already installed."
fi

pre-commit --version
