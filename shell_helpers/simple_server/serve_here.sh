#!/bin/bash
# Starts a simple Python HTTP server in the current directory.
# Version 2.0: Reads default port from an optional config file.

# --- Help Function ---
show_help() {
    echo "Starts a simple Python HTTP server in the current directory."
    echo "Usage: serve_here [port]"
    echo "For detailed instructions, see the README.md in the simple_server project."
}

# --- Argument Parsing ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Configuration ---
# Define a default port.
DEFAULT_PORT=8000

# Define path to user's private config file.
USER_CONFIG_FILE="$HOME/.config/simple_server/config"

# If the user's config file exists, source it to override the default.
if [ -f "$USER_CONFIG_FILE" ]; then
    source "$USER_CONFIG_FILE"
fi

# Use the first command-line argument as the port, or the configured default.
PORT="${1:-$DEFAULT_PORT}"

# --- Dependency Check ---
if ! command -v python3 &>/dev/null; then
    echo "Error: python3 command not found." >&2
    exit 1
fi

# --- Start Server ---
# Try to get primary non-localhost IP address(es) for convenience
IP_ADDRS=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i != "127.0.0.1") printf "%s ", $i}')

echo "Serving files from directory: $(pwd)"
echo "Access locally at    : http://localhost:$PORT"
if [ -n "$IP_ADDRS" ]; then
    for ip in $IP_ADDRS; do
        echo "Access on network at : http://$ip:$PORT"
    done
fi
echo "Press Ctrl+C to stop the server."
echo "---"

# Start the server, binding to all interfaces (0.0.0.0)
python3 -m http.server "$PORT" --bind 0.0.0.0

echo ""
echo "Server stopped."
