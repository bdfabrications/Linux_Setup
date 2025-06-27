#!/bin/bash
# A script to perform efficient, incremental backups using rsync.
# This script synchronizes a source directory with a destination,
# ensuring the destination is an exact mirror of the source.

# --- Help Function ---
# Displays detailed help information for the command.
display_help() {
  cat <<'EOF'

# sync_backup README

## 1. Overview

This command uses `rsync` to perform fast, incremental backups. Instead of
creating a new archive every time, it synchronizes a destination directory
to perfectly mirror a source directory.

It is extremely efficient because it only copies files that are new or have
been changed since the last sync.

## 2. How to Use the Command

### Basic Syntax

To use the command, specify the source directory you want to back up and
the destination directory where the backup should be stored.

sync_backup <source_directory> <destination_directory>

### Example

sync_backup ~/Documents /mnt/external_drive/backups/documents

This command will ensure that the contents of `/mnt/external_drive/backups/documents`
are an exact copy of the contents of `~/Documents`.

---

## 3. How It Works

This script is a wrapper around the powerful `rsync` command. It uses the
following options:

* `-a` (archive): A magic flag that preserves permissions, ownership,
  timestamps, and other metadata. It's essential for a true backup.
* `-v` (verbose): Shows which files are being transferred.
* `-h` (human-readable): Displays transfer sizes in KB, MB, GB, etc.
* `--delete`: **IMPORTANT**. This deletes files from the backup destination
  if they have been deleted from the source. This keeps the backup
  a perfect mirror, but use with caution.
* `--stats`: Shows a summary of the transfer at the end.

EOF
}

# --- Argument Parsing ---
# Check for the --help flag.
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
  exit 0
fi

# Check if the correct number of arguments (2) was provided.
if [ "$#" -ne 2 ]; then
  echo "Usage: sync_backup <source_directory> <destination_directory>"
  echo "Use 'sync_backup --help' for more detailed instructions."
  exit 1
fi

# --- Configuration ---
SOURCE_DIR="$1"
DEST_DIR="$2"

# --- Validate Paths ---
# Check if the source directory exists.
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found."
  exit 1
fi

# Create the destination directory if it doesn't exist.
# The '-p' flag ensures no error if the directory already exists.
mkdir -p "$DEST_DIR"

# --- Run Sync ---
echo "Starting synchronization..."
echo "  Source: $SOURCE_DIR"
echo "  Destination: $DEST_DIR"
echo ""

# The trailing slash on $SOURCE_DIR/ is important!
# It tells rsync to copy the *contents* of the source directory,
# not the directory itself.
rsync -avh --delete --stats "$SOURCE_DIR/" "$DEST_DIR/"

# Check the exit code of the rsync command.
if [ $? -eq 0 ]; then
  echo ""
  echo "Synchronization completed successfully!"
else
  echo ""
  echo "Error: Synchronization failed."
  exit 1
fi

exit 0
