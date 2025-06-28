# Backup System

A collection of two scripts for managing file backups on Linux.

1.  **`backup_dir`**: Creates full, timestamped, compressed (`.tar.gz`) archives of a directory. Ideal for point-in-time snapshots and archival.
2.  **`sync_backup`**: Uses `rsync` to maintain an exact mirror of a directory. Ideal for fast, incremental updates and quick recovery.

---

## `backup_dir` Command

### Overview

This is a simple but powerful command designed to create a timestamped, compressed (`.tar.gz`) backup of any directory you specify.

Its key feature is the ability to automatically detect and exclude the backup destination folder if it happens to be inside the source directory. This makes it safe to perform large backups, such as of an entire user's home directory, without creating a dangerous recursive backup loop.

By default, all backups are stored in `~/backups/`, but this can be changed via a configuration file (see Setup).

### Setup (Optional)

To change the default backup destination, create a configuration file:

mkdir -p ~/.config/backup_system
cp config.example ~/.config/backup_system/config
Then edit ~/.config/backup_system/config to set your desired path.

Usage

To use the command, simply call it with the path to the directory you want to back up.

# Back up a specific configuration folder

backup_dir ~/.config/nvim

# Back up your entire home directory

backup*dir ~
This will create a file like your_directory_backup*...tar.gz inside the destination folder.

How to Restore From a Backup

Use the tar command to extract your files.

# Navigate to where you want the files placed and run:

tar xzf /path/to/your/backup_file.tar.gz

# For a full system restore, use sudo and the -p flag to preserve permissions

sudo tar xpzf /path/to/your/backup_file.tar.gz

---

sync_backup Command

Overview

This command uses rsync to perform fast, incremental backups. Instead of creating a new archive every time, it synchronizes a destination directory to perfectly mirror a source directory. It is extremely efficient because it only copies files that are new or have been changed.

Usage

Specify the source directory and the destination directory.

# Example: Keep a mirror of Documents on an external drive

sync_backup ~/Documents /mnt/external_drive/backups/documents

How It Works

This script uses rsync with the following key options:

    -a (archive): Preserves all permissions, ownership, and metadata.

    --delete: IMPORTANT. This deletes files from the backup destination if they have been deleted from the source. This keeps the backup a perfect mirror, but use it with care.
