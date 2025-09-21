#!/bin/bash
# install_routines/70_terminal_enhancements.sh
# Installs terminal workflow enhancements: eza and zoxide.
# Cross-distribution support for Ubuntu/Debian, RHEL/CentOS/Rocky, Fedora, openSUSE

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

set -e
echo "Installing terminal enhancements for $DISTRO_NAME ($DISTRO_FAMILY)..."

# Detect distribution if not already done
if [[ -z "$DISTRO_FAMILY" ]]; then
    run_distribution_detection
fi

# --- Install eza ---
install_eza() {
    if ! command -v eza &>/dev/null; then
        echo "Installing eza (a modern ls replacement)..."

        case "$DISTRO_FAMILY" in
            debian)
                # Use the official eza repository for Debian/Ubuntu
                sudo mkdir -p /etc/apt/keyrings
                wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
                echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
                sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
                pkg_update
                pkg_install "eza"
                ;;

            rhel|fedora)
                # Try EPEL first, then fall back to binary installation
                pkg_enable_epel
                if pkg_install "eza" 2>/dev/null; then
                    echo "eza installed from repository."
                else
                    echo "Installing eza from GitHub releases..."
                    install_eza_from_github
                fi
                ;;

            suse)
                # Try repository first, then GitHub
                if pkg_install "eza" 2>/dev/null; then
                    echo "eza installed from repository."
                else
                    echo "Installing eza from GitHub releases..."
                    install_eza_from_github
                fi
                ;;

            *)
                echo "Installing eza from GitHub releases..."
                install_eza_from_github
                ;;
        esac

        echo "eza installed successfully."
    else
        echo "eza is already installed."
    fi
}

# Fallback installation from GitHub releases
install_eza_from_github() {
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *)
            echo "Unsupported architecture for eza binary installation: $(uname -m)"
            return 1
            ;;
    esac

    local latest_url="https://api.github.com/repos/eza-community/eza/releases/latest"
    local download_url
    download_url=$(curl -s "$latest_url" | grep "browser_download_url.*$arch-unknown-linux-gnu.tar.gz" | cut -d '"' -f 4)

    if [[ -n "$download_url" ]]; then
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"

        curl -L "$download_url" -o eza.tar.gz
        tar -xzf eza.tar.gz
        sudo cp ./eza /usr/local/bin/
        sudo chmod +x /usr/local/bin/eza

        cd - > /dev/null
        rm -rf "$temp_dir"

        echo "eza installed from GitHub releases."
    else
        echo "Failed to find eza download URL for architecture: $arch"
        return 1
    fi
}

# --- Install zoxide ---
install_zoxide() {
    if ! command -v zoxide &>/dev/null; then
        echo "Installing zoxide (a smarter cd command)..."

        case "$DISTRO_FAMILY" in
            debian)
                # Try repository first
                if pkg_install "zoxide" 2>/dev/null; then
                    echo "zoxide installed from repository."
                else
                    echo "Installing zoxide from installation script..."
                    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                fi
                ;;

            rhel|fedora)
                # Enable EPEL and try repository installation
                pkg_enable_epel
                if pkg_install "zoxide" 2>/dev/null; then
                    echo "zoxide installed from repository."
                else
                    echo "Installing zoxide from installation script..."
                    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                fi
                ;;

            suse)
                # Try repository first
                if pkg_install "zoxide" 2>/dev/null; then
                    echo "zoxide installed from repository."
                else
                    echo "Installing zoxide from installation script..."
                    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                fi
                ;;

            *)
                echo "Installing zoxide from installation script..."
                curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                ;;
        esac

        echo "zoxide installed successfully."
    else
        echo "zoxide is already installed."
    fi
}

# --- Install just (command runner) ---
install_just() {
    if ! command -v just &>/dev/null; then
        echo "Installing just (command runner)..."

        case "$DISTRO_FAMILY" in
            debian)
                # Try repository first (available in newer Ubuntu versions)
                if pkg_install "just" 2>/dev/null; then
                    echo "just installed from repository."
                else
                    echo "Installing just from GitHub releases..."
                    install_just_from_github
                fi
                ;;

            rhel|fedora)
                # Enable EPEL and try repository installation
                pkg_enable_epel
                if pkg_install "just" 2>/dev/null; then
                    echo "just installed from repository."
                else
                    echo "Installing just from GitHub releases..."
                    install_just_from_github
                fi
                ;;

            suse)
                # Try repository first
                if pkg_install "just" 2>/dev/null; then
                    echo "just installed from repository."
                else
                    echo "Installing just from GitHub releases..."
                    install_just_from_github
                fi
                ;;

            *)
                echo "Installing just from GitHub releases..."
                install_just_from_github
                ;;
        esac

        echo "just installed successfully."
    else
        echo "just is already installed."
    fi
}

# Install just from GitHub releases
install_just_from_github() {
    local arch
    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *)
            echo "Unsupported architecture for just binary installation: $(uname -m)"
            return 1
            ;;
    esac

    local latest_url="https://api.github.com/repos/casey/just/releases/latest"
    local download_url
    download_url=$(curl -s "$latest_url" | grep "browser_download_url.*$arch-unknown-linux-musl.tar.gz" | cut -d '"' -f 4)

    if [[ -n "$download_url" ]]; then
        local temp_dir
        temp_dir=$(mktemp -d)
        cd "$temp_dir"

        curl -L "$download_url" -o just.tar.gz
        tar -xzf just.tar.gz
        sudo cp ./just /usr/local/bin/
        sudo chmod +x /usr/local/bin/just

        cd - > /dev/null
        rm -rf "$temp_dir"

        echo "just installed from GitHub releases."
    else
        echo "Failed to find just download URL for architecture: $arch"
        return 1
    fi
}

# Main execution
main() {
    echo "Installing terminal enhancements..."

    # Install each enhancement
    install_eza
    install_zoxide
    install_just

    echo ""
    echo "--------------------------------------------------------"
    echo "✅ Terminal enhancements installation completed!"
    echo ""
    echo "Installed tools:"
    echo "  • eza - Modern replacement for ls"
    echo "  • zoxide - Smarter cd command with frecency"
    echo "  • just - Command runner and build tool"
    echo ""
    echo "Note: Restart your terminal or source your shell configuration"
    echo "to enable the new tools and any shell integrations."
    echo "--------------------------------------------------------"
}

# Run main function
main "$@"