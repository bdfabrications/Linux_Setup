#!/bin/bash
# Simple wrapper for ripgrep (rg) for quick recursive searching.
# Usage: rgf <pattern> [path]

if [ -z "$1" ]; then
    echo "Usage: $0 <pattern> [path]"
    echo "Recursively searches for <pattern> in [path] (default: current directory)"
    echo "using ripgrep (rg) with line numbers and case-insensitivity."
    exit 1
fi

PATTERN="$1"
SEARCH_PATH="${2:-.}" # Default to current directory if path not given

if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) command not found."
    echo "Please install it first (e.g., sudo apt install ripgrep)."
    exit 1
fi

echo "Searching for '$PATTERN' in '$SEARCH_PATH' (case-insensitive)..."
# rg options:
# --heading : print filename above matches
# --line-number : show line number
# --ignore-case : make search case-insensitive
# --color=always : force color output
# Add/remove options as needed
rg --heading --line-number --ignore-case --color=always "$PATTERN" "$SEARCH_PATH"
