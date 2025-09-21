#!/bin/bash
# install_routines/80_1password_cli.sh
# Installs the 1Password CLI across multiple Linux distributions.

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

set -e

# Detect distribution if not already done
if [[ -z "$DISTRO_FAMILY" ]]; then
    run_distribution_detection
fi

echo "Installing 1Password CLI for $DISTRO_NAME ($DISTRO_FAMILY)..."

if ! command -v op &>/dev/null; then
    echo "Downloading and installing 1Password CLI..."

    case "$DISTRO_FAMILY" in
        debian)
            # Official Debian/Ubuntu installation method
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
            echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

            # Set up debsig verification
            sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
            curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
            sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

            pkg_update
            pkg_install "1password-cli"
            ;;

        rhel|fedora)
            # Official RPM installation method
            curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --import

            if [[ "$DISTRO_ID" == "fedora" ]]; then
                echo '[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc' | sudo tee /etc/yum.repos.d/1password.repo
            else
                # RHEL/CentOS/Rocky/AlmaLinux
                echo '[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc' | sudo tee /etc/yum.repos.d/1password.repo
            fi

            pkg_install "1password-cli"
            ;;

        suse)
            # For openSUSE, try the RPM method or fallback to direct download
            echo "Adding 1Password repository for openSUSE..."
            echo '[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc' | sudo tee /etc/zypp/repos.d/1password.repo

            curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo rpm --import
            sudo zypper refresh
            pkg_install "1password-cli"
            ;;

        *)
            # Fallback: Direct binary download
            echo "Installing 1Password CLI via direct download..."
            install_1password_direct
            ;;
    esac

    echo "1Password CLI installed successfully."
else
    echo "1Password CLI is already installed."
fi

# Verify installation
if command -v op &>/dev/null; then
    echo "1Password CLI version:"
    op --version
else
    echo "Warning: 1Password CLI installation may have failed."
fi

# Function to install 1Password CLI directly from releases
install_1password_direct() {
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            echo "Unsupported architecture for 1Password CLI: $(uname -m)"
            return 1
            ;;
    esac

    local version="2.20.0"  # Update this as needed
    local download_url="https://cache.agilebits.com/dist/1P/op2/pkg/v${version}/op_linux_${arch}_v${version}.zip"

    local temp_dir
    temp_dir=$(mktemp -d)
    cd "$temp_dir"

    curl -L "$download_url" -o op.zip
    unzip op.zip
    sudo cp op /usr/local/bin/
    sudo chmod +x /usr/local/bin/op

    cd - > /dev/null
    rm -rf "$temp_dir"

    echo "1Password CLI installed from direct download."
}