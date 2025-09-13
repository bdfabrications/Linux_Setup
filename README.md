# My Linux Setup

**One-command setup for a complete, modern Linux development environment.**

This repository provides a fully automated setup script that transforms a fresh Linux installation into a powerful, aesthetically pleasing, and highly productive development environment with a single command.

## 📋 Prerequisites

Before running the setup script, you **must** install a Nerd Font for proper shell prompt display:

### Install a Nerd Font

**On Ubuntu/Debian:**
```bash
# Download and install a Nerd Font (e.g., Hack Nerd Font)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
unzip Hack.zip -d ~/.local/share/fonts/
fc-cache -fv
```

**On other systems:**
1. Visit [Nerd Fonts](https://www.nerdfonts.com/) and download your preferred font
2. Install it according to your system's font installation method
3. Configure your terminal to use the Nerd Font

**Popular Nerd Font choices:**
- Hack Nerd Font (recommended)
- JetBrains Mono Nerd Font
- Fira Code Nerd Font
- Cascadia Code Nerd Font

> **Why is this required?** The custom shell prompts use special icons and symbols that are only available in Nerd Fonts. Without a Nerd Font, you'll see missing characters or squares in your terminal prompt.

## 🚀 Quick Start

The setup script automatically detects the repository location and works from anywhere! Choose your preferred installation method:

### Method 1: Clone and Run (Recommended)
```bash
git clone https://github.com/bdfabrications/Linux_Setup.git
cd Linux_Setup
./setup.sh
```

### Method 2: One-Command Remote Installation
```bash
curl -fsSL https://raw.githubusercontent.com/bdfabrications/Linux_Setup/main/setup.sh | bash
```

### Method 3: Choose Your Directory
The script automatically detects and uses existing development directories:
```bash
# Will automatically use ~/projects/, ~/dev/, ~/Development/, or ~/code/ if they exist
git clone https://github.com/bdfabrications/Linux_Setup.git ~/projects/Linux_Setup
cd ~/projects/Linux_Setup
./setup.sh
```

**That's it!** After the script completes:
1. Restart your terminal
2. Ensure your terminal is configured to use a Nerd Font
3. Everything is ready to use

> **🔧 Smart Auto-Detection**: The setup script automatically finds your repository whether you clone it to `~/projects/`, `~/dev/`, `~/Development/`, `~/code/`, or directly to your home directory. Symlinks and configurations will be created correctly regardless of location.

## ✨ What Gets Installed

### Core Development Tools
- **Build essentials**: git, curl, wget, build-essential, ca-certificates
- **Programming runtimes**: Python 3, Node.js, Rust toolchain
- **Command-line utilities**: fzf, ripgrep, fd-find, eza, zoxide, just, jq

### Applications & Services
- **Neovim v0.11.2** with **AstroNvim** configuration
- **Docker** with user group setup
- **Ollama** for local AI models
- **Oh My Posh** for beautiful shell prompts
- **1Password CLI** for secure credential management

### Development Tools
- **pipx** for Python CLI application management
- **pre-commit** for code quality hooks
- Custom shell aliases and functions
- Automated backup and project scaffolding scripts

### Personal Configurations
All your custom dotfiles, shell configurations, and utility scripts are automatically symlinked and ready to use.

## 🖥️ System Compatibility

- **Primary**: Ubuntu 20.04+ / Debian 11+
- **Also supports**: Any Debian-based distribution
- **WSL**: Fully supported (both WSL 1 and WSL 2)
- **Requirements**: `sudo` privileges for package installation

The script automatically detects WSL environments and adapts accordingly.

## 🔧 Features

### Fully Automated
- **Zero manual intervention** required
- **Idempotent**: Safe to run multiple times
- **Robust error handling** with detailed logging
- **Smart prerequisite detection** and installation

### Modular Architecture
Each tool has its own installation logic that checks if it's already installed before proceeding, making the script efficient and safe to re-run.

### Comprehensive Logging
All installation steps are logged to `/tmp/linux_setup_YYYYMMDD_HHMMSS.log` for troubleshooting.

## 📁 Project Structure

After installation, you'll have access to these custom utilities:

| Command | Description |
|---------|-------------|
| `remind_me` | Systemd-based reminder system with email notifications |
| `backup_dir` / `sync_backup` | Full and incremental backup utilities |
| `update_system` | System maintenance and package updates |
| `new_pyproject` / `new_webproject` | Project scaffolding tools |
| `rgf` | Enhanced ripgrep search wrapper |
| `serve_here` | Instant HTTP server for current directory |
| `ollama_chat` | Interactive chat interface for Ollama models |

## ⚙️ Customization

Configuration files are automatically created in `~/.config/` from templates:

- `~/.config/backup_system/config` - Backup destinations and settings
- `~/.config/remind_me/config` - Email and notification settings  
- `~/.config/ollama_helper/config` - Default AI model preferences
- `~/.config/project_scaffolding/config` - Default project templates
- And more...

Edit these files to customize the behavior of your tools.

## 🔍 What's Different in This Version

This is a completely refactored version focused on simplicity and automation:

### ✅ New Features
- **Single script installation** - no more multiple setup scripts
- **Comprehensive prerequisite handling** - installs everything needed
- **Better error handling and logging**
- **WSL auto-detection and optimization**
- **Idempotent operation** - safe to run multiple times

### 🗑️ Removed
- Multiple separate setup scripts (`setup_linux.sh`, `setup_wsl.sh`)
- Manual prerequisite installation steps
- Complex multi-phase installation process
- All Gemini-related configurations (none were found)

### 🔄 Preserved
- **All personal configurations and dotfiles** remain unchanged
- Custom shell aliases and functions
- AstroNvim configuration
- All utility scripts and tools
- Oh My Posh themes

## 🧪 Testing

To test the script in a safe environment:

```bash
# In a Docker container
docker run -it ubuntu:22.04 bash
apt update && apt install -y git sudo
git clone https://github.com/bdfabrications/Linux_Setup.git
cd Linux_Setup
./setup.sh
```

## 📋 Prerequisites Installed Automatically

The script will install these prerequisites if they're missing:

**Essential tools**: curl, git, sudo, build-essential, ca-certificates, tar, wget  
**Python ecosystem**: python3, python3-pip, python3-venv, pipx  
**Node.js ecosystem**: nodejs, npm  
**Rust toolchain**: rustc, cargo (via rustup)  
**Command-line utilities**: fzf, ripgrep, fd-find, unzip, jq, figlet, lolcat  
**System libraries**: libfuse2 (for AppImage support)

## 🛠️ Troubleshooting

### Installation Issues
- Check the log file (path shown during installation)
- Ensure you have `sudo` privileges
- Verify internet connection for package downloads

### Post-Installation
- If commands aren't found, restart your terminal
- For Docker issues on WSL, restart your WSL session
- Configuration templates are in `~/.config/*/config`

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs! If you find bugs or have suggestions, please open an issue.

## 📄 License

This project is open source. Use it, modify it, share it!

---

**Happy coding!** 🚀