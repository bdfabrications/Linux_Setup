#!/bin/bash
#
# Package Management Abstraction Library for Linux Setup
# Provides unified interface for different package managers across distributions
#

# Source distribution detection if not already loaded
if [[ -z "$DISTRO_FAMILY" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    # shellcheck source=./distro_detect.sh
    source "$SCRIPT_DIR/distro_detect.sh"
    run_distribution_detection
fi

# Color codes for consistent output (only set if not already defined)
if [[ -z "${PKG_RED:-}" ]]; then
    readonly PKG_RED='\033[0;31m'
    readonly PKG_GREEN='\033[0;32m'
    readonly PKG_YELLOW='\033[1;33m'
    readonly PKG_BLUE='\033[0;34m'
    readonly PKG_NC='\033[0m'
fi

# Logging functions for package management
pkg_log_info() {
    echo -e "${PKG_BLUE}[PKG-INFO]${PKG_NC} ${1}"
}

pkg_log_success() {
    echo -e "${PKG_GREEN}[PKG-SUCCESS]${PKG_NC} ${1}"
}

pkg_log_warning() {
    echo -e "${PKG_YELLOW}[PKG-WARNING]${PKG_NC} ${1}"
}

pkg_log_error() {
    echo -e "${PKG_RED}[PKG-ERROR]${PKG_NC} ${1}" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Update package lists
pkg_update() {
    pkg_log_info "Updating package lists for $PKG_MANAGER..."

    case "$PKG_MANAGER" in
        apt)
            sudo apt update
            ;;
        dnf)
            sudo dnf check-update || true  # dnf returns 100 for available updates
            ;;
        yum)
            sudo yum check-update || true  # yum returns 100 for available updates
            ;;
        zypper)
            sudo zypper refresh
            ;;
        pacman)
            sudo pacman -Sy
            ;;
        apk)
            sudo apk update
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    pkg_log_success "Package lists updated"
}

# Upgrade all packages
pkg_upgrade() {
    pkg_log_info "Upgrading packages for $PKG_MANAGER..."

    case "$PKG_MANAGER" in
        apt)
            sudo apt upgrade -y
            ;;
        dnf)
            sudo dnf upgrade -y
            ;;
        yum)
            sudo yum update -y
            ;;
        zypper)
            sudo zypper update -y
            ;;
        pacman)
            sudo pacman -Su --noconfirm
            ;;
        apk)
            sudo apk upgrade
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    pkg_log_success "Packages upgraded"
}

# Install a single package
pkg_install_single() {
    local package="$1"

    if [[ -z "$package" ]]; then
        pkg_log_error "No package specified for installation"
        return 1
    fi

    pkg_log_info "Installing package: $package"

    case "$PKG_MANAGER" in
        apt)
            sudo apt install -y "$package"
            ;;
        dnf)
            # Handle group installations for DNF
            if [[ "$package" =~ ^@.* ]]; then
                sudo dnf groupinstall -y "$package"
            else
                sudo dnf install -y "$package"
            fi
            ;;
        yum)
            # Handle group installations for YUM
            if [[ "$package" =~ ^@.* ]]; then
                sudo yum groupinstall -y "$package"
            else
                sudo yum install -y "$package"
            fi
            ;;
        zypper)
            sudo zypper install -y "$package"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$package"
            ;;
        apk)
            sudo apk add "$package"
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        pkg_log_success "Successfully installed: $package"
        return 0
    else
        pkg_log_error "Failed to install: $package"
        return 1
    fi
}

# Install multiple packages
pkg_install() {
    local packages=("$@")
    local failed_packages=()
    local successful_packages=()

    if [[ ${#packages[@]} -eq 0 ]]; then
        pkg_log_error "No packages specified for installation"
        return 1
    fi

    pkg_log_info "Installing ${#packages[@]} packages..."

    for package in "${packages[@]}"; do
        if pkg_install_single "$package"; then
            successful_packages+=("$package")
        else
            failed_packages+=("$package")
        fi
    done

    if [[ ${#successful_packages[@]} -gt 0 ]]; then
        pkg_log_success "Successfully installed ${#successful_packages[@]} packages: ${successful_packages[*]}"
    fi

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        pkg_log_error "Failed to install ${#failed_packages[@]} packages: ${failed_packages[*]}"
        return 1
    fi

    return 0
}

# Remove a package
pkg_remove() {
    local package="$1"

    if [[ -z "$package" ]]; then
        pkg_log_error "No package specified for removal"
        return 1
    fi

    pkg_log_info "Removing package: $package"

    case "$PKG_MANAGER" in
        apt)
            sudo apt remove -y "$package"
            ;;
        dnf)
            sudo dnf remove -y "$package"
            ;;
        yum)
            sudo yum remove -y "$package"
            ;;
        zypper)
            sudo zypper remove -y "$package"
            ;;
        pacman)
            sudo pacman -R --noconfirm "$package"
            ;;
        apk)
            sudo apk del "$package"
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    pkg_log_success "Removed package: $package"
}

# Clean package cache and remove unused packages
pkg_cleanup() {
    pkg_log_info "Cleaning up packages and cache for $PKG_MANAGER..."

    case "$PKG_MANAGER" in
        apt)
            sudo apt autoremove -y
            sudo apt autoclean
            ;;
        dnf)
            sudo dnf autoremove -y
            sudo dnf clean all
            ;;
        yum)
            sudo yum autoremove -y
            sudo yum clean all
            ;;
        zypper)
            sudo zypper packages --unneeded | awk -F'|' 'NR==0 || NF==0 || /^-+\+/ { next } { gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3 }' | xargs -r sudo zypper remove -y
            sudo zypper clean -a
            ;;
        pacman)
            sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
            sudo pacman -Sc --noconfirm
            ;;
        apk)
            # APK doesn't have autoremove, but we can clean cache
            sudo apk cache clean
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac

    pkg_log_success "Package cleanup completed"
}

# Search for packages
pkg_search() {
    local query="$1"

    if [[ -z "$query" ]]; then
        pkg_log_error "No search query specified"
        return 1
    fi

    pkg_log_info "Searching for packages matching: $query"

    case "$PKG_MANAGER" in
        apt)
            apt search "$query"
            ;;
        dnf)
            dnf search "$query"
            ;;
        yum)
            yum search "$query"
            ;;
        zypper)
            zypper search "$query"
            ;;
        pacman)
            pacman -Ss "$query"
            ;;
        apk)
            apk search "$query"
            ;;
        *)
            pkg_log_error "Unsupported package manager: $PKG_MANAGER"
            return 1
            ;;
    esac
}

# Check if a package is installed
pkg_is_installed() {
    local package="$1"

    if [[ -z "$package" ]]; then
        return 1
    fi

    case "$PKG_MANAGER" in
        apt)
            dpkg -l "$package" 2>/dev/null | grep -q "^ii"
            ;;
        dnf)
            dnf list installed "$package" >/dev/null 2>&1
            ;;
        yum)
            yum list installed "$package" >/dev/null 2>&1
            ;;
        zypper)
            zypper search -i "$package" | grep -q "^i"
            ;;
        pacman)
            pacman -Q "$package" >/dev/null 2>&1
            ;;
        apk)
            apk info -e "$package" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Get distribution-specific package name
get_package_name() {
    local generic_name="$1"

    case "$PKG_MANAGER" in
        apt)
            case "$generic_name" in
                "development-tools") echo "build-essential" ;;
                "python3-devel") echo "python3-dev" ;;
                "openssl-devel") echo "libssl-dev" ;;
                "fd") echo "fd-find" ;;
                "gcc-c++") echo "g++" ;;
                "pkgconfig") echo "pkg-config" ;;
                "container-tools") echo "docker.io" ;;
                *) echo "$generic_name" ;;
            esac
            ;;
        dnf|yum)
            case "$generic_name" in
                "build-essential") echo "@development-tools" ;;
                "development-tools") echo "@'Development Tools'" ;;  # Use group syntax for RHEL
                "python3-dev") echo "python3-devel" ;;
                "python3-venv") echo "python3-devel" ;;  # python3-venv functionality is included in python3-devel on RHEL
                "libssl-dev") echo "openssl-devel" ;;
                "fd-find") echo "fd-find" ;;
                "fd") echo "fd-find" ;;  # fd package is named fd-find on RHEL
                "figlet") echo "" ;;  # figlet not available in base RHEL repos, will be skipped
                "g++") echo "gcc-c++" ;;
                "pkg-config") echo "pkgconfig" ;;
                "docker.io") echo "docker-ce" ;;
                "lolcat") echo "" ;;  # lolcat not available in RHEL repos, will be skipped
                *) echo "$generic_name" ;;
            esac
            ;;
        zypper)
            case "$generic_name" in
                "build-essential") echo "pattern:devel_basis" ;;
                "development-tools") echo "pattern:devel_basis" ;;
                "python3-dev") echo "python3-devel" ;;
                "libssl-dev") echo "libopenssl-devel" ;;
                "fd-find") echo "fd" ;;
                "g++") echo "gcc-c++" ;;
                "pkg-config") echo "pkg-config" ;;
                "docker.io") echo "docker" ;;
                *) echo "$generic_name" ;;
            esac
            ;;
        pacman)
            case "$generic_name" in
                "build-essential") echo "base-devel" ;;
                "python3-dev") echo "python" ;;
                "libssl-dev") echo "openssl" ;;
                "fd-find") echo "fd" ;;
                "g++") echo "gcc" ;;
                "pkg-config") echo "pkgconf" ;;
                "docker.io") echo "docker" ;;
                *) echo "$generic_name" ;;
            esac
            ;;
        *)
            echo "$generic_name"
            ;;
    esac
}

# Install a package with cross-distribution name mapping
pkg_install_mapped() {
    local generic_names=("$@")
    local distribution_packages=()

    for generic_name in "${generic_names[@]}"; do
        local mapped_name
        mapped_name=$(get_package_name "$generic_name")

        # Skip empty package names (packages not available on this distribution)
        if [[ -n "$mapped_name" ]]; then
            distribution_packages+=("$mapped_name")
        else
            pkg_log_warning "Package '$generic_name' not available on $DISTRO_FAMILY, skipping..."
        fi
    done

    # Only attempt installation if we have packages to install
    if [[ ${#distribution_packages[@]} -gt 0 ]]; then
        pkg_install "${distribution_packages[@]}"
    else
        pkg_log_info "No packages to install after filtering"
    fi
}

# Add a repository (distribution-specific)
pkg_add_repository() {
    local repo_info="$1"

    case "$PKG_MANAGER" in
        apt)
            # Expects format: "deb [options] url distribution component"
            echo "$repo_info" | sudo tee "/etc/apt/sources.list.d/$(echo "$repo_info" | awk '{print $3}' | sed 's|.*/||' | sed 's/\./_/g').list" >/dev/null
            pkg_update
            ;;
        dnf)
            # Expects a .repo file URL or repository configuration
            sudo dnf config-manager --add-repo "$repo_info"
            ;;
        yum)
            # Expects a .repo file URL or repository configuration
            sudo yum-config-manager --add-repo "$repo_info"
            ;;
        zypper)
            # Expects format: "url name"
            sudo zypper addrepo "$repo_info"
            sudo zypper refresh
            ;;
        *)
            pkg_log_error "Repository addition not supported for $PKG_MANAGER"
            return 1
            ;;
    esac

    pkg_log_success "Repository added"
}

# Enable EPEL repository for RHEL-based systems
pkg_enable_epel() {
    if [[ "$DISTRO_FAMILY" == "rhel" ]] && [[ "$DISTRO_ID" != "fedora" ]]; then
        pkg_log_info "Enabling EPEL repository for additional packages..."

        case "$PKG_MANAGER" in
            dnf)
                if ! pkg_is_installed "epel-release"; then
                    # For RHEL 9 and newer (including RHEL 10), install EPEL from the official URL
                    local major_version="${DISTRO_VERSION_ID%%.*}"
                    if [[ "$major_version" -ge 9 ]] 2>/dev/null; then
                        pkg_log_info "Installing EPEL for RHEL ${major_version} from official repository..."
                        sudo dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${major_version}.noarch.rpm"
                    else
                        # For older RHEL versions, try the traditional method first
                        pkg_install_single "epel-release" || {
                            pkg_log_warning "Standard EPEL installation failed, trying official repository..."
                            sudo dnf install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${major_version}.noarch.rpm"
                        }
                    fi
                fi
                ;;
            yum)
                if ! pkg_is_installed "epel-release"; then
                    # For RHEL 7 and 8, try traditional method first, then fallback to official URL
                    pkg_install_single "epel-release" || {
                        pkg_log_warning "Standard EPEL installation failed, trying official repository..."
                        sudo yum install -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${DISTRO_VERSION_ID%%.*}.noarch.rpm"
                    }
                fi
                ;;
            *)
                pkg_log_warning "EPEL enablement not supported for $PKG_MANAGER"
                return 1
                ;;
        esac

        pkg_log_success "EPEL repository enabled"
        return 0
    else
        pkg_log_info "EPEL repository not needed for $DISTRO_ID"
        return 0
    fi
}

# Install essential development tools
pkg_install_development_tools() {
    pkg_log_info "Installing essential development tools..."

    local dev_packages=(
        "development-tools"
        "git"
        "curl"
        "wget"
        "tar"
        "unzip"
        "python3"
        "python3-pip"
    )

    # Enable EPEL if needed
    pkg_enable_epel

    # Install mapped packages
    pkg_install_mapped "${dev_packages[@]}"

    pkg_log_success "Essential development tools installed"
}

# Function to handle distribution-specific package installation quirks
pkg_handle_special_packages() {
    local package="$1"

    case "$package" in
        "nodejs")
            # Node.js installation varies significantly between distributions
            pkg_install_nodejs_via_package_manager
            ;;
        "docker")
            # Docker installation is complex and distribution-specific
            pkg_log_warning "Docker requires special installation - use dedicated Docker installation script"
            return 1
            ;;
        *)
            pkg_install_mapped "$package"
            ;;
    esac
}

# Install Node.js via package manager (fallback method)
pkg_install_nodejs_via_package_manager() {
    pkg_log_info "Installing Node.js via package manager..."

    case "$DISTRO_FAMILY" in
        debian)
            # Use NodeSource repository for latest version
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
            pkg_install_single "nodejs"
            ;;
        rhel|fedora)
            # Use NodeSource repository for latest version
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            pkg_install_single "nodejs" "npm"
            ;;
        suse)
            # Use NodeSource repository
            sudo zypper addrepo https://rpm.nodesource.com/pub_lts.x/el/7/x86_64 nodesource
            sudo zypper refresh
            pkg_install_single "nodejs" "npm"
            ;;
        *)
            # Fallback to distribution's default Node.js
            pkg_install_single "nodejs" "npm"
            ;;
    esac

    pkg_log_success "Node.js installation completed"
}

# Validate package manager functionality
validate_package_manager() {
    pkg_log_info "Validating package manager functionality..."

    # Check if package manager is available
    if ! command_exists "$PKG_MANAGER"; then
        pkg_log_error "Package manager $PKG_MANAGER is not available"
        return 1
    fi

    # Check if we can run basic operations
    case "$PKG_MANAGER" in
        apt)
            if ! sudo apt list >/dev/null 2>&1; then
                pkg_log_error "APT is not functioning properly"
                return 1
            fi
            ;;
        dnf|yum)
            if ! sudo $PKG_MANAGER list >/dev/null 2>&1; then
                pkg_log_error "$PKG_MANAGER is not functioning properly"
                return 1
            fi
            ;;
        zypper)
            if ! sudo zypper packages >/dev/null 2>&1; then
                pkg_log_error "Zypper is not functioning properly"
                return 1
            fi
            ;;
        *)
            # Basic validation for other package managers
            if ! $PKG_MANAGER --version >/dev/null 2>&1; then
                pkg_log_error "$PKG_MANAGER is not functioning properly"
                return 1
            fi
            ;;
    esac

    pkg_log_success "Package manager validation completed"
    return 0
}

# If this script is run directly, show package manager information
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Package Manager Information:"
    echo "  Distribution: $DISTRO_NAME"
    echo "  Family: $DISTRO_FAMILY"
    echo "  Package Manager: $PKG_MANAGER"
    echo

    if validate_package_manager; then
        echo "Package manager is ready for use."
    else
        echo "Package manager validation failed."
        exit 1
    fi
fi