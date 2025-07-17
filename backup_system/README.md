#Backup System

A collection of robust scripts for managing file backups on linux, designed with safety and usability in mind.

- `backup.dir`: Create `full`, `timestamped`, `compressed` (`tar.gz`) archives of a directory. Ideal for `point in time` snapshots and archival.
- `sync.dir`: Create `fast`, `incremental` backups of a directory. Ideal for `frequently updated` mirrors.

---

## backup.dir Command

### Summary

This command creates a `timestamped`, `compressed` (`tar.gz`) backup of any directory you specify. It's perfect for creating a complete snapshot of a project or configuration directory at a specific moment.

### Key Feature: Recursion & Backup Prevention

This script includes a critical safety feature: it automatically detects if the backup destination directory is located _inside_ the source directory you are trying to back up. If it is, the script will refuse to run, preventing a dangerous recursive loop that would otherwise fill your hard drive. This makes it safe to run commands like `backup.dir .`.

### Setup (Optional)

By default, all backups are stored in `~/backups`. To change this destination:

1.  Create a configuration directory within:
    `~/.config/backup_system`

2.  Copy the configuration template:
    `back`
    from this repo to `~/.config/backup_system/config`

3.  Edit `~/.config/backup_system/config` to set your preferred `BACKUP_DEST_DIR` path.

### Usage

Simply provide the path to the directory you want to back up.

# Back up a specific configuration folder

`backup.dir ~/.config/htop`

# Back up your entire home directory safely

`backup.dir ~`

> This will create a file like `your_directory.backup.[DATE].tar.gz` inside your configured destination folder.

## How to Restore from a Backup

Use the `tar` command to extract your files. For a standard restore:

### Generated Bash

# Navigate to where you want the files placed and run:

`tar -xvf /path/to/your/backup_file.tar.gz`

For a full system restore where permissions are critical use `-x` and the `-p` (preserve-permissions) flag:

### Generated Bash

`sudo tar -xpf /path/to/full/backup_file.tar.gz`

---

## sync.dir Command

### Summary

This command uses `rsync` to perform fast, incremental backups. Instead of creating a new archive every time, it efficiently synchronizes a destination directory to be an exact mirror of a source directory. It's extremely fast after the initial run because it only copies files that are new or have been changed.

### Warning: Destructive Operation

This command uses `rsync` with the `--delete` option. This means any file that exists in the destination but not in the source will be **permanently deleted** from the destination to maintain a perfect mirror.

To prevent accidental data loss, the script now includes a **safety prompt** and will require you to confirm with a `y` before it makes any changes.

### Usage

Specify the source directory and the destination directory.

### Generated Bash

# Sync your Documents folder to an external drive

`sync.dir ~/Documents /mnt/external_drive/backups/documents`

### How it Works

This script uses `rsync` with the following key options for a safe and informative experience:

1.  `-a` (archive): Preserves permissions, ownership, and other metadata.
2.  `-v` (verbose): Shows which files are being transferred.
3.  `-h` (human-readable): Displays file sizes in KB, MB, GB, etc.
4.  `--progress`: Shows the progress of larger file transfers.
5.  `--delete`: Deletes files from the destination if they've been removed from the source.
