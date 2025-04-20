# My Linux Development Environment Dotfiles (Optimized)

This repository contains personal configuration files (dotfiles) for setting up a development environment on Debian/Ubuntu-based Linux systems, including WSL. It features a customized Bash shell, a Neovim setup based on Kickstart.nvim, helper scripts, and aims for an easy, automated installation.

## Features

* **Automated Setup:** Uses `setup_wsl.sh` or `setup_linux.sh` scripts for one-command installation of dependencies and configuration linking.
* **Shell:** Bash configured with Oh My Posh for a themed prompt (using a modified `jandedobbeleer.omp.json` theme).
* **Terminal Welcome:** Custom startup message in `.bashrc` including a Figlet banner, time-based greeting, and helper script list.
* **Editor:** Neovim (latest stable/nightly recommended) configured using Kickstart.nvim as a base.
* **Neovim Features (via Mason):**
    * **LSPs:** `lua-language-server`, `pyright`, `ruff-lsp`, `bash-language-server`, `typescript-language-server`, `html-lsp`, `css-lsp`, `marksman` (Markdown).
    * **Linters:** `shellcheck`, `markdownlint` (included with `ruff-lsp` for Python).
    * **Formatters:** `stylua` (Lua), `ruff_format` (Python), `shfmt` (Bash), `prettierd` (Web Dev, Markdown).
    * **Debuggers:** `delve` (Go), `debugpy` (Python).
    * *Easily add more tools via `:Mason` inside Neovim.*
* **Helper Scripts & Functions:** Utility scripts/functions for system maintenance (`update-sys`), backups (`backup_dir.sh`), project setup (`new_pyproject.sh`, `new_webproject.sh`), searching (`rgf.sh`), local web server (`serve_here.sh`), and Ollama interaction (`ollama_chat.sh`). Includes interactive project launcher (`p` function).
* **Management:** Uses symbolic linking (`dotfiles/install_links.sh` script, run automatically by setup scripts) to keep configurations version-controlled.

## Prerequisites

* A Debian/Ubuntu-based Linux system (including WSL). Other distributions might work with `setup_linux.sh` if dependencies are met.
* Internet connection (for downloading dependencies).
* Basic command-line tools: `git`, `curl`.
* `sudo` access (for installing packages).
* **(CRITICAL) Nerd Font Installed on Host OS:** See below.

## !! IMPORTANT: Nerd Font Installation !!

This setup heavily relies on icons provided by **Nerd Fonts** for both the Oh My Posh prompt and Neovim UI elements (like file icons, LSP signs). **You MUST install a Nerd Font on your *Host* Operating System** (the OS running your terminal emulator, e.g., Windows, macOS, or your Linux Desktop Environment) **AND configure your terminal emulator to use it.**

1.  **Download a Nerd Font:** Go to the [Nerd Fonts Website](https://www.nerdfonts.com/font-downloads) and download a font that suits you. Popular choices include:
    * FiraCode Nerd Font
    * Cascadia Code Nerd Font (often default on Windows Terminal)
    * JetBrainsMono Nerd Font
    * MesloLGS Nerd Font
2.  **Install the Font:** Follow instructions for your specific Host OS (Windows, macOS, Linux Desktop) to install the downloaded font files.
3.  **Configure Your Terminal:** Open the settings for your terminal emulator (e.g., Windows Terminal, GNOME Terminal, iTerm2, Alacritty) and set the font for your Linux/WSL profile to the Nerd Font you just installed.

**Failure to complete these steps will result in missing icons and a broken-looking UI.**

## Installation

1.  **Clone this Repository:**
    ```bash
    # Choose a location, e.g., your home directory
    git clone [https://github.com/](https://github.com/)<your_username>/<your_repo_name>.git ~/my_linux_setup
    # Replace <your_username>/<your_repo_name> with your actual repo details
    cd ~/my_linux_setup
    ```
    *(Authentication via PAT or SSH key may be required if your repo is private).*

2.  **Run the Appropriate Setup Script:**
    * **For WSL (Ubuntu/Debian):**
        ```bash
        bash setup_wsl.sh
        ```
    * **For Native Linux (attempts auto-detection for Debian/Fedora/Arch):**
        ```bash
        bash setup_linux.sh
        ```
    These scripts will:
    * Install all necessary system dependencies.
    * Install the latest stable Neovim.
    * Install Oh My Posh.
    * Install other required tools (fzf, ripgrep, fd, figlet, Ollama [optional]).
    * Run the `dotfiles/install_links.sh` script to set up your configuration symlinks (backing up existing files).
    * Run Neovim headlessly once to install plugins via `lazy.nvim`.
    * *(Attempt to install default Mason tools - may require manual `:Mason` run in Neovim after first launch).*

3.  **Restart Your Terminal:** After the script finishes, close and reopen your terminal/WSL session completely to ensure all changes (PATH, `.bashrc`, prompt) take effect.

4.  **First Neovim Launch:**
    * Run `nvim`.
    * If the setup script didn't automatically install Mason tools, run `:Mason` to check their status and install any missing ones from the default list if needed.

## Included Helper Scripts / Functions (`~/bin`)

(Accessed via your PATH, symlinked from `dotfiles/bin`)

* **`p` (function in `.bashrc`):** Interactively select `~/projects` directory using `fzf`, `cd` into it, activate venv (`.venv`/`venv`), launch `nvim`. Usage: `p`
* **`update-sys` (alias for `sudo ~/bin/update_system.sh`):** Updates system packages (`apt update`, `upgrade`, `autoremove`, `clean`). Prompts by default; use `update-sys -y` to skip prompts.
* **`backup_dir.sh`:** Creates timestamped `.tar.gz` backup of a directory into `$HOME/backups`. Usage: `backup_dir.sh <directory_to_backup>`
* **`new_pyproject.sh`:** Creates Python project folder in `~/projects` with `git init`, `.venv`, `.gitignore`. Usage: `new_pyproject.sh <ProjectName>`
* **`new_webproject.sh`:** Creates HTML/CSS/JS project in `~/projects` with `git init`, boilerplate, `.gitignore`, first commit, opens `nvim`. Usage: `new_webproject.sh <ProjectName>`
