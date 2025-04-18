#!/bin/bash
# Starts a simple Python HTTP server in the current directory.
# Useful for quick testing or sharing files on the local network.
# Usage: serve_here.sh [port]

DEFAULT_PORT=8000
PORT="${1:-$DEFAULT_PORT}" # Use provided port or default

if ! command -v python3 &> /dev/null; then
    echo "Error: python3 command not found."
    exit 1
fi

# Try to get primary non-localhost IP address(es)
# This handles multiple IPs better, ignores 127.0.0.1
IP_ADDRS=$(hostname -I 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i != "127.0.0.1") printf "%s ", $i}')

echo "Serving files from directory: $(pwd)"
echo "Access locally at     : http://localhost:$PORT"
if [ -n "$IP_ADDRS" ]; then
    for ip in $IP_ADDRS; do
         echo "Access on network at: http://$ip:$PORT"
    done
else
    echo "Could not determine network IP address."
fi
echo "Press Ctrl+C to stop the server."
echo "Starting server..."

# Start the server, binding to all interfaces (0.0.0.0) if possible
# Fallback to localhost if binding to 0.0.0.0 fails (e.g., port busy)
if ! python3 -m http.server "$PORT" --bind 0.0.0.0; then
    echo ""
    echo "[Warning] Could not bind to 0.0.0.0 (maybe port $PORT is busy?)."
    echo "Trying to bind to localhost only..."
    # This might only be accessible from the WSL instance itself
    python3 -m http.server "$PORT" 
fi

# This line won't be reached until server is stopped with Ctrl+C
echo ""
echo "Server stopped."
