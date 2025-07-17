#!/bin/bash
#
# Creates a timestamped, compressed .tar.gz backup of a specified directory.

# Exit on error, treat unset variables as an error, and disable globbing.
set -euo pipefail

# --- Configuration & Helper Functions ---
CONFIG_FILE="$HOME/.config/backup_system/config"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Set a default backup destination if not defined in the config.
BACKUP_DEST_DIR="${BACKUP_DEST_DIR:-$HOME/backups}"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Main Logic ---
main() {
    if [ "$#" -ne 1 ]; then
        log_error "Usage: backup_dir <directory_to_backup>"
    fi

    local source_dir="$1"
    # Use realpath to get the absolute, canonical path.
    local source_path
    source_path=$(realpath "$source_dir")
    local dest_path
    dest_path=$(realpath "$BACKUP_DEST_DIR")

    if [ ! -d "$source_path" ]; then
        log_error "Source directory not found: $source_path"
    fi

    # The most critical safety check: prevent recursive backups.
    if [[ "$dest_path" == "$source_path"* ]]; then
        log_error "Safety abort! The destination directory is inside the source directory."
    fi

    # Create the backup destination directory if it doesn't exist.
    mkdir -p "$dest_path"

    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_filename
    backup_filename="$(basename "$source_path")_backup_${timestamp}.tar.gz"
    local full_backup_path="$dest_path/$backup_filename"

    log_info "Starting backup of '$source_path'..."
    log_info "Destination: '$full_backup_path'"

    # The --exclude option is crucial for preventing the backup from including itself.
    if tar -czf "$full_backup_path" --exclude="$dest_path" -C "$(dirname "$source_path")" "$(basename "$source_path")"; then
        log_success "Backup completed successfully."
    else
        log_error "Backup failed. Please check for errors above."
    fi
}

main "$@"
