#!/bin/bash
# Simple script to create a timestamped backup of a specified directory.
# Version 3.1: Updated help text to use 'backupd' as the command name.

# --- Help Function ---
# This function displays the help text derived from the README.
display_help() {
  cat <<'EOF'

# backupd README

## 1. Overview

This is a simple but powerful command designed to create a timestamped, 
compressed (`.tar.gz`) backup of any directory you specify.

Its key feature is the ability to automatically detect and exclude the backup 
destination folder if it happens to be inside the source directory. This makes 
it safe to perform large backups, such as of an entire user's home directory, 
without creating a dangerous recursive backup loop.

All backups are stored by default in `~/backups/`.

---

## 2. How to Use the Command

### Basic Syntax

To use the command, simply call it with the path to the directory you want to back up.
(Assuming this script has been renamed to 'backupd' and placed in your PATH).

backupd <path_to_directory>

### Examples

**Back up a specific configuration folder:**
backupd ~/.config/nvim

**Back up your entire home directory:**
backupd $HOME

This will create a file like `your_username_backup_...tar.gz` inside `~/backups/`.

---

## 3. How to Restore From a Backup

### Use Case 1: Restoring a Specific Directory

1. Navigate to where you want the files placed (e.g., `cd ~/Desktop`).
2. Run the extract command:
   # 'x' = extract, 'z' = gzip, 'f' = file
   tar xzf /path/to/your/backup_file.tar.gz

### Use Case 2: Full Restore on a New Machine (Disaster Recovery)

1. Transfer the full backup file to the new machine.
2. CRITICAL: Before extracting, navigate to the `/home` directory.
   cd /home
3. Run the extraction command using `sudo` to restore with correct permissions.
   # 'p' = preserve permissions and ownership
   sudo tar xpzf /path/to/your/backup_file.tar.gz

---

## 4. Important Notes

* **Permissions are Key:** For a full restore, `sudo` and the `-p` flag are required.
* **Dry Run:** You can safely list contents with `tar tzf <file>`.
* **Existing Directories:** `tar` will merge/overwrite files. It is often best to 
    rename or remove an existing directory before restoring into its place.

EOF
}

# --- Argument Parsing ---
# Check for the --help flag or an empty argument first.
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
  exit 0
fi

if [ -z "$1" ]; then
  # Updated usage to reflect 'backupd'
  echo "Usage: backupd <directory_to_backup>"
  echo "Example: backupd $HOME"
  echo "Use 'backupd --help' for more detailed instructions."
  exit 1
fi

# --- Configuration ---
SOURCE_DIR="$1"
BACKUP_DEST_DIR="$HOME/backups"

# --- Validate Paths ---
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory '$SOURCE_DIR' not found."
  exit 1
fi

if [ ! -d "$BACKUP_DEST_DIR" ]; then
  echo "Info: Backup destination directory '$BACKUP_DEST_DIR' not found. Creating it..."
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
  echo "Info: Backup destination is inside the source directory. Excluding '$EXCLUDE_PATTERN'."
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
