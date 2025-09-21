#!/bin/bash
# install_routines/15_tmux.sh
# Installs tmux across multiple Linux distributions.

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

set -e # Exit immediately if a command fails.

# Detect distribution if not already done
if [[ -z "$DISTRO_FAMILY" ]]; then
    run_distribution_detection
fi

echo "Installing tmux for $DISTRO_NAME ($DISTRO_FAMILY)..."

if ! command -v tmux &>/dev/null; then
    pkg_update
    pkg_install "tmux"
    echo "tmux installed successfully."
else
    echo "tmux is already installed."
fi
