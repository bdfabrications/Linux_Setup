#!/bin/bash
#
# serve_here - A convenient wrapper script to start a simple Python HTTP
# server in the current directory, making it accessible on the local network.

set -euo pipefail

# --- Configuration & Helper Functions ---
CONFIG_FILE="$HOME/.config/simple_server/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Set a default port if not defined in the config.
DEFAULT_PORT="${DEFAULT_PORT:-8000}"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Usage and Help ---
usage() {
    cat <<EOF
Usage: serve_here [port]
Starts a simple Python HTTP server in the current directory.

Arguments:
  [port]          The port to listen on. Defaults to ${DEFAULT_PORT} or the value
                  in ~/.config/simple_server/config.
EOF
    exit 0
}

# --- Argument Parsing ---
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
fi

# --- Main Logic ---
main() {
    # Check for the Python dependency.
    if ! command -v python3 &>/dev/null; then
        log_error "python3 is not installed, which is required to run the server."
    fi

    local port="${1:-$DEFAULT_PORT}"

    # Validate that the port is a number.
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_error "Invalid port: '$port'. Port must be a number."
    fi

    # Function to get the primary non-localhost IP address.
    # Uses 'ip' command, which is standard on modern Linux systems.
    get_lan_ip() {
        ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v "127.0.0.1" | head -n 1
    }

    local lan_ip
    lan_ip=$(get_lan_ip)

    log_success "Starting Python HTTP server..."
    echo "----------------------------------------------------"
    log_info "Serving files from: $(pwd)"
    echo
    log_info "Access URLs:"
    echo "  - From this machine:   http://localhost:$port"
    if [ -n "$lan_ip" ]; then
        echo "  - From your network:   http://$lan_ip:$port"
    else
        echo "  (Could not determine network IP address)"
    fi
    echo "----------------------------------------------------"
    echo "Press Ctrl+C to stop the server."

    # Start the server, binding to all interfaces (0.0.0.0) to make it
    # accessible from the local network.
    if ! python3 -m http.server "$port" --bind 0.0.0.0; then
        log_error "Failed to start the server. The port may be in use."
    fi
}

# Pass all script arguments to the main function.
main "$@"
