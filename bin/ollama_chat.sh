#!/bin/bash
# Ensures Ollama server is running and starts an interactive chat with a specified model.
# Usage: ollama_chat.sh [model_name] (Defaults to phi3 if no model specified)

# --- Configuration ---
DEFAULT_MODEL="llama3:8b"
MODEL_NAME="${1:-$DEFAULT_MODEL}" # Use provided model name or the default

# --- Check Dependencies ---
if ! command -v ollama &>/dev/null; then
    echo "Error: 'ollama' command not found. Please ensure Ollama is installed."
    exit 1
fi
if ! command -v curl &>/dev/null; then
    echo "Error: 'curl' command not found. Cannot check server status."
    # Attempting to start server anyway, but checking is preferred
fi

# --- Ensure Server is Running ---
echo "Checking Ollama server status..."
# Use curl to ping the server endpoint silently
if command -v curl &>/dev/null && curl --silent --output /dev/null --head --fail --connect-timeout 2 http://localhost:11434; then
    echo "Ollama server is running."
else
    echo "Ollama server not detected. Starting it in the background..."
    ollama serve &
    # Give the server a moment to initialize
    echo "Waiting for server to start..."
    sleep 3
    # Check again
    if command -v curl &>/dev/null && ! curl --silent --output /dev/null --head --fail --connect-timeout 2 http://localhost:11434; then
        echo "Error: Failed to start or connect to Ollama server after starting it."
        echo "You might need to run 'ollama serve &' manually in another terminal first."
        exit 1
    else
        echo "Ollama server started successfully."
    fi
fi

# --- Start Interactive Chat ---
# Note: 'ollama run' will automatically pull the model if it's not found locally.
echo ""
echo "Starting interactive chat with model: $MODEL_NAME"
echo "Type '/bye' or press Ctrl+D to exit the chat."
echo "---"

# Execute the interactive run command
ollama run "$MODEL_NAME"

# --- Chat Ended ---
echo "---"
echo "Ollama chat session ended."

exit 0
