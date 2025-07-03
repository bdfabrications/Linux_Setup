My Linux Setup

This repository is my personal collection of dotfiles, configurations,
and utility scripts for creating a complete, modern, and productive
development environment on Linux, centered around the powerful AstroNvim configuration.

The entire setup is designed to be modular, portable, and easily
deployed on a new machine with a single command, whether it's a native Linux installation or a
WSL instance.
Core Philosophy

    Modular: Every script and configuration is organized into its own
    self-contained project directory with its own documentation.

    Configurable: Scripts with user-specific settings (like API keys
    or default paths) read their values from private configuration files
    located in ~/.config/. The main setup script automatically deploys the necessary templates.

    Fully Automated: The primary goal is to bootstrap a new machine from
    zero to a fully configured, aesthetically pleasing, and highly productive development environment with a single command.

Quick Start: Fresh Installation

These setup scripts are designed to be run once on a new system to
install all dependencies, tools, and configurations.

    Warning: These scripts will install numerous packages and require
    sudo privileges. Review their contents before running on a critical
    system.

1. Clone the Repository

git clone [https://github.com/bdfabrications/my_linux_setup.git](https://github.com/bdfabrications/my_linux_setup.git)
cd my_linux_setup

2. Run the Appropriate Installer
For Native Linux (Specifically APT-based distributions)

This script is optimized for a fresh Debian/Ubuntu instance.

chmod +x setup_scripts/setup_linux.sh
./setup_scripts/setup_linux.sh

For WSL (Debian/Ubuntu-based)

This script is optimized for a fresh WSL instance.

chmod +x setup_scripts/setup_wsl.sh
./setup_scripts/setup_wsl.sh

3. Restart Your Shell

After the setup script completes, you must close and restart your
terminal for all changes, themes, and commands to take effect. The first time you run nvim, AstroNvim will finalize its plugin installation.
Project Portfolio

This repository is organized into the following projects. Click into any
directory to see its specific README.md for more details.

    astronvim/: Your personalized AstroNvim configuration, providing a rich, modern, and beautiful Neovim IDE experience.

    setup_scripts/: The core installer scripts for bootstrapping a new
    machine.

    shell_config/: Contains the main bash_aliases and
    bashrc_config files that define custom functions and the welcome
    message.

    shell_theming/: Holds all theme files for Oh My Posh.

    remind_me/: A powerful reminder tool that uses systemd timers and
    email notifications.

    backup_system/: A set of scripts for creating full (.tar.gz) and
    incremental (rsync) backups.

    project_scaffolding/: Helper scripts (new_pyproject,
    new_webproject) to quickly create boilerplate for new projects.

    shell_helpers/: A collection of useful command-line utilities.

        ollama_chat: An interactive chat wrapper for Ollama models.

        rgf_helper: A convenient wrapper for ripgrep searches.

        simple_server: A script to instantly start a Python HTTP server.

    system_manager/: Contains the update_system script for easy
    system maintenance on Debian/APT systems.

Customization

All projects that require user-specific settings are now handled automatically by the main setup script. It will create the necessary directories in ~/.config/ and copy the required config.example templates for you.

To customize, simply edit the files in your ~/.config/ directory after running the main setup.

Feel free to contribute or customize this setup for your own use! If you
have any questions or issues, please open an issue on the GitHub
repository.

Happy coding!
