#!/bin/bash
# Simple wrapper for ripgrep (rg) for quick recursive searching.
# Version 2.0: Reads default options from a config file.

# --- Argument Validation ---
if [ -z "$1" ]; then
    echo "Usage: rgf <pattern> [path]"
    echo "Recursively searches for <pattern> in [path] (default: current directory)."
    exit 1
fi

if ! command -v rg &>/dev/null; then
    echo "Error: ripgrep (rg) command not found." >&2
    echo "Please install it first (e.g., sudo apt install ripgrep)." >&2
    exit 1
fi

# --- Configuration ---
# Define default options for ripgrep.
RG_DEFAULT_OPTS="--heading --line-number --ignore-case --color=always"

# Define path to user's private config file.
USER_CONFIG_FILE="$HOME/.config/rgf_helper/config"

# If the user's config file exists, source it to override the defaults.
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

PATTERN="$1"
SEARCH_PATH="${2:-.}" # Default to current directory if path not given

echo "Searching for '$PATTERN' in '$SEARCH_PATH'..."

# Use the configured options. Note: SC2086 is intentionally ignored
# as we want the options string to be split into separate arguments.
# shellcheck disable=SC2086
rg $RG_DEFAULT_OPTS "$PATTERN" "$SEARCH_PATH"
