# My Linux Development Environment Dotfiles

This repository contains my personal configuration files (dotfiles) for setting up a development environment, primarily focused on WSL (Ubuntu/Debian) with a customized shell and Neovim.

## Features

* **Shell:** Bash configured with Oh My Posh for a themed prompt.
* **Terminal Welcome:** Custom startup message including a Figlet banner, time-based greeting, and optional weather display.
* **Editor:** Neovim (v0.11.0+) configured using [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) as a base.
* **Neovim Features:** Includes setup for LSP (via Mason), autocompletion, fuzzy finding (Telescope), syntax highlighting (Treesitter), etc.
* **Helper Scripts:** Some utility scripts for system maintenance, backups, and project setup.
* **Management:** Uses symbolic linking (`install_links.sh` script) to keep configurations version-controlled in this repository while active in the home directory.

## Prerequisites

Before setting up, ensure the following are installed on your target **Debian/Ubuntu-based Linux system** (like WSL):

1.  **Core Tools:**
    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git curl wget unzip build-essential ca-certificates
    ```
2.  **Python Environment:** (Needed for Neovim plugins like `ruff`)
    ```bash
    sudo apt install -y python3 python3-pip python3-venv
    ```
3.  **Shell Customization Tools:**
    ```bash
    # For welcome banner
    sudo apt install -y figlet 
    # Oh My Posh binary (installed by master script, but good to have prerequisite noted)
    # Ensure /usr/local/bin is in PATH
    ```
4.  **Search Tools:** (Used by Telescope in Neovim)
    ```bash
    sudo apt install -y ripgrep fd-find
    # Create 'fd' symlink if needed (common on Debian/Ubuntu)
    # Check if needed: command -v fd || sudo ln -s $(which fdfind) /usr/local/bin/fd 
    ```
5.  **Neovim (v0.11.0 or newer):** The version in standard `apt` repositories might be too old. It's recommended to install a recent version manually. You can download the pre-built binary:
    * Go to [Neovim Releases](https://github.com/neovim/neovim/releases/latest).
    * Download `nvim-linux64.tar.gz` (or arm64).
    * Extract and place the contents appropriately (e.g., move `nvim-linux64` directory to `/opt/nvim-vX.Y.Z` and symlink `/opt/nvim-vX.Y.Z/bin/nvim` to `/usr/local/bin/nvim`).
    * *Alternatively, the `master_setup.sh` script (if included/adapted later) automates this.*

6.  **Nerd Font (CRITICAL FOR ICONS):**
    * You **MUST** install a [Nerd Font](https://www.nerdfonts.com/font-downloads) on your **Host Operating System** (e.g., Windows). Popular choices: Fira Code Nerd Font, Cascadia Code NF, JetBrains Mono Nerd Font, MesloLGS NF.
    * Configure your **Terminal Emulator** (e.g., Windows Terminal) to *use* the installed Nerd Font for your Linux profile. Without this, icons in Oh My Posh and Neovim will not display correctly (you'll see squares or question marks).

## Installation

1.  **Clone this Repository:**
    ```bash
    # Replace <YOUR_GITHUB_REPO_URL> with the actual URL
    # Clone into ~/dotfiles 
    git clone https://github.com/bdfabrications/Linux_Setup ~/dotfiles 
    ```
    *(You may need to authenticate with GitHub using a Personal Access Token or SSH Key).*

2.  **Navigate into the Repository:**
    ```bash
    cd ~/dotfiles
    ```

3.  **Run the Linking Script:** This script backs up any existing default configuration files in your home directory and creates symbolic links pointing to the files within this repository.
    ```bash
    ./install_links.sh
    ```

4.  **Reload Shell Configuration:** Apply the `.bashrc` changes (prompt, PATH, welcome message) to your current session, or simply close and restart your terminal.
    ```bash
    source ~/.bashrc
    ```

## Post-Installation Setup

1.  **Neovim First Run (Plugin Installation):**
    * Start Neovim: `nvim`
    * The `lazy.nvim` plugin manager will automatically run and install all the plugins defined in the configuration. **Wait patiently** for this to complete.
    * Once finished, **quit Neovim** (`:q`).
    * **Restart Neovim:** `nvim`

2.  **Install Language Tools via Mason:**
    * Inside Neovim (after restarting), run `:Mason` to open the Mason package manager UI.
    * Use `j`/`k` to navigate and `i` to install the Language Servers (LSPs), Linters, and Formatters you need for the languages you use.
    * **Recommendations based on initial setup:**
        * **LSP:** `bash-language-server`, `lua-language-server`, `jdtls` (needs JDK!), `html-lsp`, `css-lsp`, `typescript-language-server`, `pyright`
        * **Linter:** `shellcheck`, `ruff`
        * **Formatter:** `shfmt`, `stylua`, `prettier`, `ruff`
    * Remember to install any necessary runtime prerequisites in WSL (e.g., `sudo apt install default-jdk` for `jdtls`).
    * Close Mason with `q`.

## Customization

* **Weather:** To enable the weather display in the welcome message, edit your `~/.bashrc` file (which links to `~/dotfiles/bashrc_config`), find the `--- 3. Display Weather ---` section, uncomment the lines, and set the `LOCATION` variable to your city or zip code.
* **Oh My Posh Theme:** Edit `~/.bashrc` (linked to `~/dotfiles/bashrc_config`) and change the filename in the `--config` path within the `oh-my-posh init` command. Available themes are in `~/.poshthemes` (linked to `~/dotfiles/poshthemes`).
* **Neovim:** All Neovim configuration is within `~/.config/nvim` (linked to `~/dotfiles/config_nvim`). Explore the `init.lua` and files under `lua/` to customize further.

## Included Scripts (`~/bin`)

The following helper scripts are included and linked into `~/bin` (which should be in your PATH):

* `update_system.sh`: Updates system packages (`apt update`, `upgrade`, `autoremove`, `clean`). 
  **To run, use the alias:** `update-sys`. This command uses `sudo` and will likely prompt for your user password.
* `backup_dir.sh`: Creates a timestamped `.tar.gz` backup of a specified directory (defaults to storing backups in `~/backups`). Usage: `backup_dir.sh <directory_to_backup>`
* `new_pyproject.sh`: Creates a basic Python project folder with git init, a `.venv`, and a `.gitignore`. Usage: `new_pyproject.sh <ProjectName>`

## License

(Optional: Add license information here if you wish, e.g., MIT License, or state it's for personal use).

---
