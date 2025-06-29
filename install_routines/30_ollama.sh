#!/bin/bash
# install_routines/30_ollama.sh
# Installs Ollama and pulls default models.

set -e
echo "Installing Ollama..."

if ! command -v ollama &>/dev/null; then
	echo "Downloading and running Ollama install script..."
	curl -fsSL https://ollama.com/install.sh | sh

	echo "Ollama installed successfully."
	echo "Attempting to pull default models in the background..."

	# Start server if not running (common on first install)
	if ! pgrep -x ollama >/dev/null; then
		ollama serve &
		sleep 5 # Give it a moment to start
	fi

	(ollama pull llama3:8b && echo "[Info] Pulled llama3:8b") &
	(ollama pull phi3 && echo "[Info] Pulled phi3") &
	echo "Default model downloads initiated. Check progress with 'ollama list'."
else
	echo "Ollama already installed."
fi
