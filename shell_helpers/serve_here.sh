#!/bin/bash
# Starts a simple Python HTTP server in the current directory.
# Useful for quick testing or sharing files on the local network.
# Usage: serve_here.sh [port]

# --- Help Function ---
show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTION] [PORT]

Starts a simple Python HTTP server in the current directory, making its contents
accessible via a web browser on the local network.

Arguments:
  [PORT]          Optional. The port number to run the server on.
                  If not provided, defaults to 8000.

Options:
  -h, --help      Display this help message and exit.

Description:
  This script uses Python's built-in 'http.server' module to serve the files
  and subdirectories of the current working directory. It automatically
  detects and displays the local and network IP addresses you can use to
  access the server.

Dependencies:
  - python3: Required to run the HTTP server.
  - hostname: Used to determine network IP addresses for convenience.
EOF
}

# --- Argument Parsing for Help ---
# Check for help flag before processing other arguments
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Configuration & Validation ---
DEFAULT_PORT=8000
PORT="${1:-$DEFAULT_PORT}" # Use provided port or default

if ! command -v python3 &>/dev/null; then
    echo "Error: python3 command not found." >&2
    echo "Please install Python 3 to use this script." >&2
    exit 1
fi

# Try to get primary non-localhost IP address(es)
# This handles multiple IPs better, ignores 127.0.0.1
IP_ADDRS=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i != "127.0.0.1") printf "%s ", $i}')

echo "Serving files from directory: $(pwd)"
echo "Access locally at    : http://localhost:$PORT"
if [ -n "$IP_ADDRS" ]; then
    for ip in $IP_ADDRS; do
        echo "Access on network at : http://$ip:$PORT"
    done
else
    echo "Could not determine network IP address."
fi
echo "Press Ctrl+C to stop the server."
echo "Starting server..."

# Start the server, binding to all interfaces (0.0.0.0)
python3 -m http.server "$PORT" --bind 0.0.0.0

# This line won't be reached until server is stopped with Ctrl+C
echo ""
echo "Server stopped."
