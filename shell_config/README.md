# Shell Configuration

This directory contains the core configuration files for the Bash shell.

- `bash_aliases`: Holds all custom command aliases (e.g., `ll`, `update-sys`).
- `bashrc_config`: Contains custom functions (like `p()`) and the welcome message logic that runs when a new terminal is opened.

These files are automatically deployed by the `install_links.sh` script, which creates symlinks to them in the user's home directory (`~/.bash_aliases` and `~/.bashrc_config`). They are then sourced by the main `~/.bashrc` file on startup.
