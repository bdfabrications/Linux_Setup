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

**On RHEL/CentOS/Rocky Linux/Fedora:**
```bash
# Download and install a Nerd Font (e.g., Hack Nerd Font)
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip
unzip Hack.zip -d ~/.local/share/fonts/
fc-cache -fv
```

**On openSUSE:**
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
# Works on all supported distributions
git clone https://github.com/bdfabrications/Linux_Setup.git
cd Linux_Setup
./setup.sh
```

### Method 2: One-Command Remote Installation
```bash
# Universal installation - detects your distribution automatically
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

### Fully Supported Distributions
- **Ubuntu 20.04+** - Primary development target
- **Debian 11+** - Full feature support
- **RHEL 8+** - Enterprise Linux support
- **CentOS 8+ / Rocky Linux 8+** - RHEL derivatives
- **Fedora 35+** - Latest Fedora releases
- **openSUSE Leap 15.4+** - SUSE Linux support

### Additional Support
- **WSL**: Fully supported (both WSL 1 and WSL 2) on all distributions
- **AlmaLinux**: Full RHEL-compatible support
- **Linux Mint**: Debian/Ubuntu derivative support

### Requirements
- `sudo` privileges for package installation
- Internet connection for downloading packages and repositories
- Minimum 2GB available disk space

The script automatically:
- Detects your Linux distribution and version
- Uses the appropriate package manager (apt, dnf, yum, zypper)
- Adapts installation methods for distribution-specific packages
- Enables EPEL repository on RHEL-based systems when needed

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

## 🔍 What's New in This Version

Major update with **cross-distribution support** for enterprise and certification preparation:

### ✅ New Features
- **Multi-distribution support** - Ubuntu, Debian, RHEL, CentOS, Rocky Linux, Fedora, openSUSE
- **Intelligent package management** - Automatically uses apt, dnf, yum, or zypper
- **Distribution detection** - Robust detection using `/etc/os-release` and fallback methods
- **Package name mapping** - Cross-distribution package compatibility (e.g., `build-essential` ↔ `@development-tools`)
- **EPEL auto-enablement** - Automatically enables EPEL on RHEL-based systems
- **Enhanced error handling** - Better logging and distribution-specific error messages
- **RHEL certification ready** - Perfect for Red Hat certification preparation

### 🔧 Technical Improvements
- **Modular architecture** - Separate libraries for distribution detection and package management
- **Backward compatibility** - Existing Debian/Ubuntu installations unaffected
- **Graceful degradation** - Script continues if optional packages unavailable
- **Security updates** - Distribution-specific security patch handling
- **Reboot detection** - Automatically detects when system restart needed

### 📦 Enhanced Installation Support
- **Docker** - Cross-distribution Docker installation with proper repository setup
- **1Password CLI** - Multi-distribution support with fallback to direct download
- **Terminal enhancements** - eza, zoxide, just with GitHub fallback installation
- **System updates** - Universal system update script works across all distributions

### 🗑️ Removed
- Distribution-specific hardcoded commands
- Ubuntu/Debian-only assumptions
- Single package manager dependency

### 🔄 Preserved
- **All personal configurations and dotfiles** remain unchanged
- **Existing functionality** on Debian/Ubuntu systems
- **Custom shell aliases and functions**
- **AstroNvim configuration**
- **All utility scripts and tools**
- **Oh My Posh themes**

### 🎯 Perfect for RHEL Certification
This setup is now ideal for:
- **RHCSA/RHCE preparation** - Full RHEL environment setup
- **Multi-distribution experience** - Learn differences between package managers
- **Enterprise Linux skills** - Real-world RHEL development environment
- **Consistent tooling** - Same development tools across all distributions

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

The script automatically detects your distribution and installs the appropriate packages:

### Core Development Tools
**Ubuntu/Debian**: build-essential, git, curl, wget, ca-certificates, tar
**RHEL/CentOS/Rocky**: @development-tools, git, curl, wget, ca-certificates, tar
**Fedora**: @development-tools, git, curl, wget, ca-certificates, tar
**openSUSE**: pattern:devel_basis, git, curl, wget, ca-certificates, tar

### Programming Ecosystems
**Python**: python3, python3-pip, python3-venv, pipx (all distributions)
**Node.js**: nodejs, npm via NVM (universal installation method)
**Rust**: rustc, cargo via rustup (universal installation method)

### Command-line Utilities
**Universal**: fzf, ripgrep, unzip, jq, figlet, lolcat
**Distribution-mapped**: fd-find → fd, pkg-config → pkgconfig, etc.

### System Libraries
**Ubuntu/Debian**: libfuse2 (AppImage support)
**RHEL-based**: fuse-libs (AppImage support)
**openSUSE**: fuse (AppImage support)

### Additional Repositories
**RHEL/CentOS/Rocky**: EPEL repository automatically enabled for additional packages
**All distributions**: Docker, 1Password CLI, and other third-party repositories added as needed

## 🛠️ Troubleshooting

### Installation Issues
- **Check the log file**: Path shown during installation (e.g., `/tmp/linux_setup_YYYYMMDD_HHMMSS.log`)
- **Verify privileges**: Ensure you have `sudo` privileges
- **Check connectivity**: Verify internet connection for package downloads
- **Distribution support**: Confirm your distribution is supported (script will warn if not)

### Distribution-Specific Issues

#### RHEL/CentOS/Rocky Linux
- **EPEL repository**: Script automatically enables EPEL for additional packages
- **Subscription**: RHEL may require active subscription for some packages
- **SELinux**: Some applications (like Docker) may need SELinux configuration

#### Fedora
- **Package availability**: Some packages may be newer/different versions
- **Updates**: Fedora moves quickly; some package names may change

#### openSUSE
- **Repository refresh**: May take longer due to repository metadata
- **Package patterns**: Uses pattern:devel_basis instead of individual development packages

### Post-Installation
- **Commands not found**: Restart your terminal or run `source ~/.bashrc`
- **Docker issues on WSL**: Restart your WSL session
- **Configuration**: Templates are in `~/.config/*/config`
- **Package manager**: Run distribution detection: `./lib/distro_detect.sh --verbose`

### Common Solutions
```bash
# Re-run distribution detection
./lib/distro_detect.sh

# Test package manager
./lib/package_manager.sh

# Update system manually
./system_manager/update_system.sh

# Check Docker installation
docker --version
docker compose version
```

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs!

### Reporting Issues
- **Distribution compatibility**: Report new distributions or version issues
- **Package mapping**: Suggest better cross-distribution package alternatives
- **Installation failures**: Include distribution info and log files
- **Enhancement requests**: Ideas for better cross-platform support

### Contributing
- **New distributions**: Add support for additional Linux distributions
- **Package improvements**: Better package name mappings and fallbacks
- **Testing**: Multi-distribution testing and validation
- **Documentation**: Distribution-specific guides and troubleshooting

Please open an issue on GitHub with:
1. Your Linux distribution and version (`cat /etc/os-release`)
2. Error logs from `/tmp/linux_setup_*.log`
3. Steps to reproduce the issue

## 📄 License

This project is open source. Use it, modify it, share it!

---

**Happy coding!** 🚀