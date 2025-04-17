#!/bin/bash
# Simple script to create a timestamped backup of a specified directory.

# --- Configuration ---
# Directory where you want to store backups (MAKE SURE THIS EXISTS!)
# Using /root/backups as an example for the root user
BACKUP_DEST_DIR="/root/backups"

# --- Check Input ---
# Check if a directory path was provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <directory_to_backup>"
  echo "Example: $0 /root/.config/nvim"
  exit 1
fi

SOURCE_DIR="$1"

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found."
  exit 1
fi

# Check if the backup destination directory exists
if [ ! -d "$BACKUP_DEST_DIR" ]; then
  echo "Info: Backup destination directory '$BACKUP_DEST_DIR' not found. Creating it..."
  mkdir -p "$BACKUP_DEST_DIR"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create backup directory '$BACKUP_DEST_DIR'."
    exit 1
  fi
fi

# --- Create Backup ---
# Get the base name of the source directory (e.g., 'nvim' from '/root/.config/nvim')
BASENAME=$(basename "$SOURCE_DIR")

# Create a timestamp string (e.g., 20250416_212030)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Define the backup filename
BACKUP_FILENAME="${BASENAME}_backup_${TIMESTAMP}.tar.gz"
BACKUP_FULL_PATH="$BACKUP_DEST_DIR/$BACKUP_FILENAME"

echo "Starting backup of '$SOURCE_DIR'..."
echo "Backup file will be: $BACKUP_FULL_PATH"

# Create the compressed archive
# tar options:
#   c: create archive
#   z: compress with gzip
#   v: verbose (list files being archived - remove 'v' for less output)
#   f: specify filename
#   -C: change to the PARENT directory of the source before archiving
#       this avoids including the full path in the archive.
PARENT_DIR=$(dirname "$SOURCE_DIR")
DIR_TO_ARCHIVE=$(basename "$SOURCE_DIR")

if tar czf "$BACKUP_FULL_PATH" -C "$PARENT_DIR" "$DIR_TO_ARCHIVE"; then
  echo "Backup created successfully!"
else
  echo "Error: Backup creation failed."
  exit 1
fi

exit 0
