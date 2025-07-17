#!/bin/bash
# install_routines/60_just.sh
# Installs 'just', a modern command runner, along with Rust/cargo if needed.

set -e
echo "Installing just..."

# --- Prerequisite: Install Rust and Cargo ---
if ! command -v cargo &>/dev/null; then
    echo "Cargo not found. Installing Rust toolchain via rustup..."
    # The -y flag automates the rustup installation
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    # Add cargo to the current session's PATH
    # shellcheck source=/dev/null
    source "$HOME/.cargo/env"
    echo "Rust toolchain installed successfully."
else
    echo "Rust (cargo) is already installed."
fi

# --- Install just ---
if ! command -v just &>/dev/null; then
    echo "Installing just via cargo..."
    cargo install just
    echo "'just' installed successfully."
else
    echo "'just' is already installed."
fi

just --version
