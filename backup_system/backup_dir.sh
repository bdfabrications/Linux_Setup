#!/bin/bash
# Simple script to create a timestamped backup of a specified directory.
# Version 4.0: Reads destination from an optional config file.

# --- Help Function ---
display_help() {
  echo "Creates a timestamped .tar.gz backup of a directory."
  echo "For detailed instructions, please see the README.md file in the backup_system project directory."
}

# --- Argument Parsing ---
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
  exit 0
fi

if [ -z "$1" ]; then
  echo "Usage: backup_dir <directory_to_backup>"
  echo "Use 'backup_dir --help' for more information."
  exit 1
fi

# --- Configuration ---
# Define the default backup destination.
BACKUP_DEST_DIR="$HOME/backups"
SOURCE_DIR="$1"

# Define the path to the user's private config file.
USER_CONFIG_FILE="$HOME/.config/backup_system/config"

# If the user's config file exists, source it to override the default.
if [ -f "$USER_CONFIG_FILE" ]; then
  source "$USER_CONFIG_FILE"
fi

# --- Validate Paths ---
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found."
  exit 1
fi

if [ ! -d "$BACKUP_DEST_DIR" ]; then
  echo "Info: Backup destination '$BACKUP_DEST_DIR' not found. Creating it..."
  mkdir -p "$BACKUP_DEST_DIR"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup directory '$BACKUP_DEST_DIR'."
    exit 1
  fi
fi

# --- Prepare for Backup ---
BASENAME=$(basename "$SOURCE_DIR")
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILENAME="${BASENAME}_backup_${TIMESTAMP}.tar.gz"
BACKUP_FULL_PATH="$BACKUP_DEST_DIR/$BACKUP_FILENAME"
PARENT_DIR=$(dirname "$SOURCE_DIR")
DIR_TO_ARCHIVE=$(basename "$SOURCE_DIR")

# --- Exclusion Logic ---
declare -a TAR_EXTRA_OPTS=()
CANONICAL_SOURCE=$(readlink -f "$SOURCE_DIR")
CANONICAL_BACKUP_DEST=$(readlink -f "$BACKUP_DEST_DIR")

if [[ "$CANONICAL_BACKUP_DEST"/ == "$CANONICAL_SOURCE"/* ]]; then
  EXCLUDE_PATTERN="${DIR_TO_ARCHIVE}/$(basename "$CANONICAL_BACKUP_DEST")"
  echo "Info: Backup destination is inside the source. Excluding '$EXCLUDE_PATTERN'."
  TAR_EXTRA_OPTS+=(--exclude="$EXCLUDE_PATTERN")
fi

# --- Create Backup ---
echo "Starting backup of '$SOURCE_DIR'..."
echo "Backup file will be: $BACKUP_FULL_PATH"

if tar czf "$BACKUP_FULL_PATH" "${TAR_EXTRA_OPTS[@]}" -C "$PARENT_DIR" "$DIR_TO_ARCHIVE"; then
  echo "Backup created successfully!"
else
  echo "Error: Backup creation failed."
  exit 1
fi

exit 0
