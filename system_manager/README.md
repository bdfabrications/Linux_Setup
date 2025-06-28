# System Manager

Contains scripts related to general system maintenance and management.

---

## `update_system` Command

### Overview

A simple script to update, upgrade, and clean a Debian-based Linux system (e.g., Ubuntu, Debian, Linux Mint) using the APT package manager.

### What It Does

This script automates the standard system maintenance process by safely executing the following sequence of commands:

1.  `sudo apt update` - Refreshes the local package lists from their sources.
2.  `sudo apt upgrade -y` - Upgrades all installed packages to their latest versions without prompting.
3.  `sudo apt autoremove -y` - Removes packages that were automatically installed as dependencies for other packages but are no longer required.
4.  `sudo apt clean` - Clears the local cache of downloaded package files (`.deb`), freeing up disk space.

### Usage

The script requires no arguments. Simply run the command:

```bash
update_system

Execution Notes

    The script automatically detects if it is being run by a non-root user and will prepend sudo to all package management commands.

    It requires sudo access to function.

    It is designed specifically for Debian/APT-based systems.
```
