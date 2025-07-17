#!/bin/bash
#
# Uses rsync to create/update an exact mirror of a source directory.

set -euo pipefail

# --- Helper Functions ---
log_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
log_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[1;31m[ERROR]\033[0m $1" >&2; exit 1; }

# --- Main Logic ---
main() {
    if [ "$#" -ne 2 ]; then
        log_error "Usage: sync_backup <source_directory> <destination_directory>"
    fi

    local source_dir="$1/" # Add trailing slash to copy contents.
    local dest_dir="$2/"

    if [ ! -d "$source_dir" ]; then
        log_error "Source directory not found: $source_dir"
    fi

    # Ensure destination directory exists.
    mkdir -p "$dest_dir"

    log_info "Preparing to synchronize '$source_dir' to '$dest_dir'."
    log_warn "The --delete flag is active. Files in destination not present in source will be REMOVED."
    read -p "Are you sure you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Synchronization cancelled by user."
        exit 0
    fi

    log_info "Starting rsync..."
    # -a: archive mode (recursive, preserves perms, etc.)
    # -v: verbose
    # -h: human-readable numbers
    # --delete: delete extraneous files from dest dirs
    # --progress: show progress during transfer
    if rsync -avh --delete --progress "$source_dir" "$dest_dir"; then
        log_success "Synchronization complete."
    else
        log_error "Rsync command failed. Please review the output for errors."
    fi
}

main "$@"
