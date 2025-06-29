````markdown
# My Linux Setup

This repository is my personal collection of dotfiles, configurations,
and utility scripts for creating a complete, modern, and productive
development environment on Linux.

The entire setup is designed to be modular, portable, and easily
deployed on a new machine, whether it's a native Linux installation or a
WSL instance.

## Core Philosophy

- **Modular:** Every script and configuration is organized into its own
  self-contained project directory with its own documentation.
- **Configurable:** Scripts with user-specific settings (like API keys
  or default paths) read their values from private configuration files
  located in `~/.config/`. This keeps personal secrets completely separate
  from this public repository.
- **Automated:** The primary goal is to bootstrap a new machine from
  zero to fully configured with a single command.

---

## Quick Start: Fresh Installation

These setup scripts are designed to be run **once** on a new system to
install all dependencies, tools, and configurations.

> **Warning:** These scripts will install numerous packages and require
> `sudo` privileges. Review their contents before running on a critical
> system.

### 1. Clone the Repository

```bash
git clone https://github.com/bdfabrications/my_linux_setup.git
cd my_linux_setup
```
````

### 2. Run the Appropriate Installer

#### For Native Linux (Specifically APT-based distributions)

This script is optimized for a fresh Debian/Ubuntu instance.

```bash
chmod +x setup_scripts/setup_linux.sh
./setup_scripts/setup_linux.sh
```

#### For WSL (Debian/Ubuntu-based)

This script is optimized for a fresh WSL instance.

```bash
chmod +x setup_scripts/setup_wsl.sh
./setup_scripts/setup_wsl.sh
```

### 3. Restart Your Shell

After the setup script completes, you must close and restart your
terminal for all changes, themes, and commands to take effect.

### Manual Installation

If you prefer to install dependencies yourself and only want to deploy
the configurations, you can run the linking script directly:

```bash
# This will create symlinks for all configs and scripts.
./setup_scripts/install_links.sh
```

---

## Project Portfolio

This repository is organized into the following projects. Click into any
directory to see its specific README.md for more details.

- **setup_scripts/**: The core installer scripts for bootstrapping a new
  machine.
- **nvim_config/**: A complete, modern Neovim configuration based on
  kickstart.nvim.
- **shell_config/**: Contains the main `bash_aliases` and
  `bashrc_config` files that define custom functions and the welcome
  message.
- **shell_theming/**: Holds all theme files for Oh My Posh.
- **remind_me/**: A powerful reminder tool that uses systemd timers and
  email notifications.
- **backup_system/**: A set of scripts for creating full (`.tar.gz`) and
  incremental (`rsync`) backups.
- **project_scaffolding/**: Helper scripts (`new_pyproject`,
  `new_webproject`) to quickly create boilerplate for new projects.
- **shell_helpers/**: A collection of useful command-line utilities.
  - **ollama_chat**: An interactive chat wrapper for Ollama models.
  - **rgf_helper**: A convenient wrapper for ripgrep searches.
  - **simple_server**: A script to instantly start a Python HTTP server.
- **system_manager/**: Contains the `update_system` script for easy
  system maintenance on Debian/APT systems.

---

## Customization

Most projects that require user-specific settings follow a simple
pattern:

1. Look for a `config.example` file in the project's directory.
2. Copy it to the corresponding location in `~/.config/`, e.g., `cp 
remind_me/config.example ~/.config/remind_me/config`.
3. Edit the new file in `~/.config/` with your personal values.

---

Feel free to contribute or customize this setup for your own use! If you
have any questions or issues, please open an issue on the [GitHub
repository](https://github.com/bdfabrications/my_linux_setup/issues).

Happy coding!

```

```
