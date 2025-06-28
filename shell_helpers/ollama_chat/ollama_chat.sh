#!/bin/bash
# Ensures Ollama server is running and starts an interactive chat with a specified model.
# Version 2.0: Reads default model from an optional config file.

# --- Help Function ---
show_help() {
    echo "A wrapper to start an interactive Ollama chat session."
    echo "Usage: ollama_chat [model_name]"
    echo "For detailed instructions, see the README.md in the ollama_helper project."
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Configuration ---
# Define a default model.
DEFAULT_MODEL="llama3:8b"

# Define the path to the user's private config file.
USER_CONFIG_FILE="$HOME/.config/ollama_helper/config"

# If the user's config file exists, source it to override the default.
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

# Use the first command-line argument as the model, or the configured default.
MODEL_NAME="${1:-$DEFAULT_MODEL}"

# --- Check Dependencies ---
if ! command -v ollama &>/dev/null; then
    echo "Error: 'ollama' command not found. Please ensure Ollama is installed." >&2
    exit 1
fi

# --- Ensure Server is Running ---
echo "Checking Ollama server status..."
if ! curl --silent --output /dev/null --head --fail --connect-timeout 2 http://localhost:11434; then
    echo "Ollama server not detected. Starting it in the background..."
    ollama serve &
    echo "Waiting for server to start..."
    sleep 3
    if ! curl --silent --output /dev/null --head --fail --connect-timeout 2 http://localhost:11434; then
        echo "Error: Failed to connect to Ollama server after starting it." >&2
        exit 1
    fi
    echo "Ollama server started successfully."
else
    echo "Ollama server is running."
fi

# --- Start Interactive Chat ---
echo ""
echo "Starting interactive chat with model: $MODEL_NAME"
echo "Type '/bye' or press Ctrl+D to exit the chat."
echo "---"

ollama run "$MODEL_NAME"

echo "---"
echo "Ollama chat session ended."
exit 0
