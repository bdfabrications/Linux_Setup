# My Linux Development Environment Dotfiles

This repository contains my personal configuration files (dotfiles) for setting up a development environment, primarily focused on WSL (Ubuntu/Debian) with a customized shell and Neovim.

## Features

* **Shell:** Bash configured with Oh My Posh for a themed prompt (using `jandedobbeleer.omp.json` modified for Python venv display).
* **Terminal Welcome:** Custom startup message in `.bashrc` including a Figlet banner, time-based greeting, local weather (optional), and handy script list.
* **Editor:** Neovim (v0.11.0+) configured using [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) as a base.
* **Neovim Features:** Includes setup for LSP (via Mason), autocompletion, fuzzy finding (Telescope), syntax highlighting (Treesitter), etc.
* **Helper Scripts & Functions:** Utility scripts/functions for system maintenance, backups, project setup, searching, local web server, and Ollama interaction.
* **Management:** Uses symbolic linking (`install_links.sh` script) to keep configurations version-controlled in this repository while active in the home directory.

## Prerequisites

Before setting up, ensure the following are installed on your target **Debian/Ubuntu-based Linux system** (like WSL):

1.  **Core Tools:**
    ```bash
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y git curl wget unzip build-essential ca-certificates
    ```
2.  **Python Environment:** (Needed for Neovim plugins like `ruff` and helper scripts)
    ```bash
    sudo apt install -y python3 python3-pip python3-venv
    ```
3.  **Shell Customization Tools:**
    * **Oh My Posh:** (Required for the prompt theme)
        ```bash
        # Installs to /usr/local/bin
        sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
        sudo chmod +x /usr/local/bin/oh-my-posh
        ```
    * **Figlet:** (Used for the welcome banner)
        ```bash
        sudo apt install -y figlet
        ```
    * **FZF:** (Required for the `p` project launcher function)
         ```bash
         sudo apt install -y fzf
         ```

4.  **Search Tools:** (Used by Telescope in Neovim and `rgf.sh`)
    ```bash
    sudo apt install -y ripgrep fd-find
    # Create 'fd' symlink if needed (common on Debian/Ubuntu)
    # Check if needed and create link:
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then sudo ln -s $(which fdfind) /usr/local/bin/fd; fi
    ```
5.  **Neovim (v0.11.0 or newer):** The version in standard `apt` repositories might be too old for the Kickstart configuration. Install manually:
    * Go to [Neovim Releases](https://github.com/neovim/neovim/releases/latest).
    * Download `nvim-linux64.tar.gz` (or arm64).
    * Extract it.
    * Move the *entire* `nvim-linux64` directory to `/opt/nvim-vX.Y.Z` (replace X.Y.Z with version).
    * Create a symlink: `sudo ln -sf /opt/nvim-vX.Y.Z/bin/nvim /usr/local/bin/nvim`.
    * *(This setup uses v0.11.0 installed via this method).*

6.  **Nerd Font (CRITICAL FOR ICONS):**
    * You **MUST** install a [Nerd Font](https://www.nerdfonts.com/font-downloads) on your **Host Operating System** (e.g., Windows). Popular choices: Fira Code NF, Cascadia Code NF, JetBrains Mono NF, MesloLGS NF.
    * Configure your **Terminal Emulator** (e.g., Windows Terminal) to *use* the installed Nerd Font for your Linux profile. Without this, icons in Oh My Posh and Neovim will **not** display correctly.

## Installation

1.  **Clone this Repository:**
    ```bash
    # Clone into ~/dotfiles (replace ~ with desired user home if not default)
    git clone https://github.com/bdfabrications/Linux_Setup.git ~/dotfiles
    ```
    *(Authentication via PAT or SSH key may be required).*

2.  **Navigate into the Repository:**
    ```bash
    cd ~/dotfiles
    ```

3.  **Run the Linking Script:** This script backs up existing default config files (to `~/.dotfiles_backup_...`) and creates symbolic links from standard locations (`~/.bashrc`, `~/.config/nvim`, etc.) to the corresponding files within this repository.
    ```bash
    ./install_links.sh
    ```

4.  **Reload Shell Configuration:** Apply the `.bashrc` changes (prompt, PATH, welcome message) or **close and restart your terminal/WSL session**.
    ```bash
    source ~/.bashrc
    ```

## Post-Installation Setup

1.  **Neovim First Run (Plugin Installation):**
    * Start Neovim: `nvim`
    * The `lazy.nvim` plugin manager will automatically run and install all the plugins (defined in `~/dotfiles/config_nvim`). **Wait patiently** for this to complete.
    * Once finished, **quit Neovim** (`:q`).
    * **Restart Neovim:** `nvim`

2.  **Install Language Tools via Mason:**
    * Inside Neovim (after restarting), run `:Mason` to open the Mason package manager UI.
    * Use `j`/`k` to navigate and `i` to install the Language Servers (LSPs), Linters, and Formatters needed for your development workflow.
    * **Recommendations:**
        * **LSP:** `bash-language-server`, `lua-language-server`, `jdtls` (needs JDK!), `html-lsp`, `css-lsp`, `typescript-language-server`, `pyright`
        * **Linter:** `shellcheck`, `ruff`
        * **Formatter:** `shfmt`, `stylua`, `prettier`, `ruff`
    * Remember to install runtime prerequisites in WSL (e.g., `sudo apt install default-jdk` for `jdtls`).
    * Close Mason with `q`.

3.  **Install Ollama (Optional):**
    * If you want to use the local AI assistant features:
        ```bash
        curl -fsSL https://ollama.com/install.sh | sh
        # Pull desired models, e.g.:
        ollama pull phi3
        ollama pull llama3:8b
        ```

## Customization

* **Weather:** To enable the weather display in the welcome message, edit `~/dotfiles/bashrc_config` (which is linked to `~/.bashrc`), find the `--- 3. Display Weather ---` section, uncomment the lines, and set the `LOCATION` variable.
* **Oh My Posh Theme:** The theme used is defined in `~/dotfiles/bashrc_config` in the `oh-my-posh init` line (`--config` flag). The theme file itself (`jandedobbeleer.omp.json` modified for venv) is in `~/dotfiles/poshthemes`. Edit the JSON file to change colors/segments or change the theme file path in `.bashrc` to use a different theme.
* **Neovim:** Configuration is in `~/dotfiles/config_nvim`. Edit `init.lua` and files under `lua/` to modify Neovim behavior, plugins, and keymaps.

## Included Scripts / Functions (`~/bin`)

The following are included and linked into `~/bin` (which is added to your PATH by `.bashrc`):

* **(Function in `.bashrc`) `p`**: Interactively select a project directory from `~/projects` using `fzf`, change into it, automatically activate `.venv` or `venv` if found, and launch `nvim`. Usage: `p`
* `update_system.sh`: Updates system packages (`apt update`, `upgrade`, `autoremove`, `clean`).
    * **Usage:** `update-sys` (This alias defined in `.bashrc` runs the script with `sudo` and prompts for your password).
* `backup_dir.sh`: Creates a timestamped `.tar.gz` backup of a specified directory. Stores backups in `~/backups` by default.
    * **Usage:** `backup_dir.sh <directory_to_backup>`
* `new_pyproject.sh`: Creates a basic Python project folder with `git init`, a `.venv`, and a standard Python `.gitignore`.
    * **Usage:** `new_pyproject.sh <ProjectName>`
* `rgf.sh`: Quick recursive text search using `ripgrep` (case-insensitive, shows line numbers).
    * **Usage:** `rgf.sh <pattern> [path]`
* `serve_here.sh`: Starts a simple Python HTTP web server in the current directory for local file sharing/testing.
    * **Usage:** `serve_here.sh [port]` (Defaults to port 8000)
* `ollama_chat.sh`: Ensures Ollama server is running (starts if needed) and begins an interactive chat with the specified model.
    * **Usage:** `ollama_chat.sh [model_name]` (Defaults to `phi3`)

## License

(Consider adding a license, e.g., MIT, if sharing publicly)

---
