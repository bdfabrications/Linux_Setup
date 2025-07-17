# My Linux Setup

This repository is my personal collection of dotfiles, configurations, and utility scripts for creating a complete, modern, and productive development environment on Linux, centered around the powerful AstroNvim configuration.

The entire setup is designed to be modular, portable, and easily deployed on a new machine with a single command, whether it's a native Linux installation or a WSL instance.

## Core Philosophy

- **Modular**: Every script and configuration is organized into its own self-contained project directory with its own documentation.
- **Configurable**: Scripts with user-specific settings (like API keys or default paths) read their values from private configuration files located in `~/.config/`. The main setup script automatically deploys the necessary templates.
- **Robust & Safe**: Scripts are designed to be idempotent (safe to run multiple times), provide clear feedback, and include safety checks for potentially destructive operations.
- **Fully Automated**: The primary goal is to bootstrap a new machine from zero to a fully configured, aesthetically pleasing, and highly productive development environment with a single command.

## Prerequisites

This setup is designed for Debian-based Linux distributions (like Ubuntu or Debian) and requires `sudo` privileges to run.

The setup scripts will automatically install all necessary tools and dependencies. The core requirements that will be installed are:

- **Essential Build Tools**: `build-essential`, `git`, `curl`, `wget`, `ca-certificates`, `tar`, `gnupg`
- **Programming Runtimes**: `python3`, `python3-pip`, `python3-venv`, `nodejs`, `npm`, and the `rust` toolchain (via rustup)
- **Command-Line Utilities**: `fzf`, `ripgrep`, `fd-find`, `unzip`, `jq`, `figlet`, `eza`, `zoxide`, `lolcat`
- **Key Applications**: Neovim, Docker, Oh My Posh, 1Password CLI, and Ollama.

## Quick Start: Fresh Installation

> **Warning**: These scripts will install numerous packages and require `sudo` privileges. Review their contents before running on a critical system.

1.  **Clone the Repository**

    ```bash
    git clone https://github.com/bdfabrications/my_linux_setup.git
    cd my_linux_setup
    ```

2.  **Run the Appropriate Installer**
    - **For Native Linux (APT-based):**
      ```bash
      chmod +x Linux_Experimental/setup_scripts/setup_linux.sh
      ./Linux_Experimental/setup_scripts/setup_linux.sh
      ```
    - **For WSL (Debian/Ubuntu-based):**
      ```bash
      chmod +x Linux_Experimental/setup_scripts/setup_wsl.sh
      ./Linux_Experimental/setup_scripts/setup_wsl.sh
      ```

3.  **Restart Your Shell**
    After the setup script completes, you **must** close and restart your terminal for all changes, themes, and commands to take effect. The first time you run `nvim`, AstroNvim will finalize its plugin installation.

## Project Portfolio

This repository is organized into the following projects. Click into any directory to see its specific `README.md` for more details.

- `astronvim/`: Your personalized AstroNvim configuration, providing a rich, modern, and beautiful Neovim IDE experience.
- `setup_scripts/`: The core installer scripts for bootstrapping a new machine.
- `shell_config/`: Contains `bash_aliases` and `bashrc_config` for custom functions, aliases, and the welcome message.
- `shell_theming/`: Holds all theme files for Oh My Posh.
- `remind_me/`: A powerful reminder tool that uses `systemd` timers and email notifications.
- `backup_system/`: A set of scripts for creating full (`.tar.gz`) and incremental (`rsync`) backups with safety prompts.
- `project_scaffolding/`: Helper scripts (`new_pyproject`, `new_webproject`) to quickly create boilerplate for new projects.
- `shell_helpers/`: A collection of useful command-line utilities.
  - `ollama_chat`: An interactive chat wrapper for Ollama models.
  - `rgf_helper`: A convenient wrapper for `ripgrep` searches.
  - `simple_server`: A script to instantly start a Python HTTP server and display local and network URLs.
- `system_manager/`: Contains the `update_system` script for easy system maintenance on Debian/APT systems.
- `secrets_management/`: Documentation on the recommended approach for handling secrets using a CLI password manager.
- `tmux_config/`: A well-commented and ergonomic configuration for `tmux`.

## Customization

All projects that require user-specific settings are handled automatically by the main setup script. It will create the necessary directories in `~/.config/` and copy the required `config.example` templates for you.

To customize, simply edit the files in your `~/.config/` directory after running the main setup.
