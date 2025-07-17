#!/bin/bash
#
# A wrapper script for the 'ollama' command-line tool that provides
# a convenient interactive chat session.

set -euo pipefail

# --- Configuration & Helper Functions ---
CONFIG_FILE="$HOME/.config/ollama_helper/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Set a default model if not provided by user config or command line.
DEFAULT_MODEL="${DEFAULT_MODEL:-llama3:8b}"
MODEL_TO_USE="${1:-$DEFAULT_MODEL}"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Dependency Checks ---
if ! command -v ollama &>/dev/null; then
    log_error "ollama command not found. Please install Ollama to use this script."
fi
if ! command -v curl &>/dev/null; then
    log_error "curl command not found, which is required to check the server status."
fi

# --- Main Logic ---
# Check if the Ollama server is running by making a quiet request to its endpoint.
if ! curl -s --fail http://localhost:11434 > /dev/null; then
    log_info "Ollama server not detected. Attempting to start it in the background..."
    # Use 'nohup' and redirect output to ensure the process detaches from the terminal.
    nohup ollama serve > /tmp/ollama.log 2>&1 &
    
    # Give the server a moment to start up.
    sleep 3
    
    if ! curl -s --fail http://localhost:11434 > /dev/null; then
        log_error "Failed to start the Ollama server. Check logs at /tmp/ollama.log"
    else
        log_info "Ollama server started successfully."
    fi
fi

log_info "Starting interactive chat with model: ${MODEL_TO_USE}"
log_info "To exit the chat, type /bye or press Ctrl+D."
echo "----------------------------------------------------"

# Start the interactive chat session.
ollama run "${MODEL_TO_USE}"
