#!/bin/bash
#
# Distribution Detection Library for Linux Setup
# Provides robust cross-distribution detection and environment setup
#

# Global variables for distribution information
declare -g DISTRO_ID=""
declare -g DISTRO_ID_LIKE=""
declare -g DISTRO_NAME=""
declare -g DISTRO_VERSION=""
declare -g DISTRO_VERSION_ID=""
declare -g DISTRO_CODENAME=""
declare -g DISTRO_FAMILY=""
declare -g PKG_MANAGER=""
declare -g IS_WSL=""

# Color codes for consistent output (only set if not already defined)
if [[ -z "${DISTRO_RED:-}" ]]; then
    readonly DISTRO_RED='\033[0;31m'
    readonly DISTRO_GREEN='\033[0;32m'
    readonly DISTRO_YELLOW='\033[1;33m'
    readonly DISTRO_BLUE='\033[0;34m'
    readonly DISTRO_NC='\033[0m'
fi

# Logging functions for distribution detection
distro_log_info() {
    echo -e "${DISTRO_BLUE}[DISTRO-INFO]${DISTRO_NC} ${1}"
}

distro_log_success() {
    echo -e "${DISTRO_GREEN}[DISTRO-SUCCESS]${DISTRO_NC} ${1}"
}

distro_log_warning() {
    echo -e "${DISTRO_YELLOW}[DISTRO-WARNING]${DISTRO_NC} ${1}"
}

distro_log_error() {
    echo -e "${DISTRO_RED}[DISTRO-ERROR]${DISTRO_NC} ${1}" >&2
}

# Check if running in WSL environment
detect_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null || [[ "${WSL_DISTRO_NAME:-}" != "" ]]; then
        IS_WSL="true"
        return 0
    else
        IS_WSL="false"
        return 1
    fi
}

# Main distribution detection function
detect_distribution() {
    local detected=false

    distro_log_info "Detecting Linux distribution..."

    # Detect WSL first
    detect_wsl
    if [[ "$IS_WSL" == "true" ]]; then
        distro_log_info "WSL environment detected"
    fi

    # Primary method: /etc/os-release (modern standard)
    if [[ -f /etc/os-release ]]; then
        # Source the file to get distribution information
        . /etc/os-release

        DISTRO_ID="${ID:-unknown}"
        DISTRO_ID_LIKE="${ID_LIKE:-}"
        DISTRO_NAME="${NAME:-Unknown Linux}"
        DISTRO_VERSION="${VERSION:-Unknown}"
        DISTRO_VERSION_ID="${VERSION_ID:-}"
        DISTRO_CODENAME="${VERSION_CODENAME:-}"

        detected=true
        distro_log_info "Distribution detected via /etc/os-release: $DISTRO_NAME"
    fi

    # Fallback methods for older systems
    if [[ "$detected" != "true" ]]; then
        # Check for RHEL/CentOS specific files
        if [[ -f /etc/redhat-release ]]; then
            local redhat_info=$(cat /etc/redhat-release)
            DISTRO_NAME="$redhat_info"
            if [[ "$redhat_info" =~ CentOS ]]; then
                DISTRO_ID="centos"
            elif [[ "$redhat_info" =~ "Red Hat Enterprise Linux" ]]; then
                DISTRO_ID="rhel"
            elif [[ "$redhat_info" =~ Rocky ]]; then
                DISTRO_ID="rocky"
            elif [[ "$redhat_info" =~ AlmaLinux ]]; then
                DISTRO_ID="almalinux"
            else
                DISTRO_ID="rhel-based"
            fi
            DISTRO_FAMILY="rhel"
            detected=true
            distro_log_info "Distribution detected via /etc/redhat-release: $DISTRO_NAME"

        # Check for Debian/Ubuntu specific files
        elif [[ -f /etc/debian_version ]]; then
            DISTRO_VERSION=$(cat /etc/debian_version)
            if [[ -f /etc/lsb-release ]]; then
                . /etc/lsb-release
                DISTRO_ID="${DISTRIB_ID,,}"
                DISTRO_NAME="$DISTRIB_DESCRIPTION"
                DISTRO_CODENAME="$DISTRIB_CODENAME"
            else
                DISTRO_ID="debian"
                DISTRO_NAME="Debian GNU/Linux"
            fi
            DISTRO_FAMILY="debian"
            detected=true
            distro_log_info "Distribution detected via /etc/debian_version: $DISTRO_NAME"

        # Check for openSUSE specific files
        elif [[ -f /etc/SuSE-release ]]; then
            DISTRO_ID="opensuse"
            DISTRO_NAME="openSUSE"
            DISTRO_FAMILY="suse"
            detected=true
            distro_log_info "Distribution detected via /etc/SuSE-release: $DISTRO_NAME"
        fi
    fi

    # If still not detected, try lsb_release command
    if [[ "$detected" != "true" ]] && command -v lsb_release >/dev/null 2>&1; then
        DISTRO_ID=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        DISTRO_NAME=$(lsb_release -sd | tr -d '"')
        DISTRO_VERSION=$(lsb_release -sr)
        DISTRO_CODENAME=$(lsb_release -sc)
        detected=true
        distro_log_info "Distribution detected via lsb_release: $DISTRO_NAME"
    fi

    # Determine distribution family if not already set
    if [[ -z "$DISTRO_FAMILY" ]]; then
        determine_distribution_family
    fi

    # Set package manager based on distribution family
    set_package_manager

    if [[ "$detected" == "true" ]]; then
        distro_log_success "Distribution detection completed successfully"
        return 0
    else
        distro_log_error "Failed to detect Linux distribution"
        return 1
    fi
}

# Determine distribution family based on ID and ID_LIKE
determine_distribution_family() {
    case "$DISTRO_ID" in
        ubuntu|debian|pop|mint|elementary|zorin|kali|parrot)
            DISTRO_FAMILY="debian"
            ;;
        rhel|centos|rocky|almalinux|oracle|scientific)
            DISTRO_FAMILY="rhel"
            ;;
        fedora)
            DISTRO_FAMILY="fedora"
            ;;
        opensuse*|sled|sles)
            DISTRO_FAMILY="suse"
            ;;
        arch|manjaro|endeavouros|garuda)
            DISTRO_FAMILY="arch"
            ;;
        gentoo)
            DISTRO_FAMILY="gentoo"
            ;;
        alpine)
            DISTRO_FAMILY="alpine"
            ;;
        *)
            # Try to determine based on ID_LIKE
            if [[ "$DISTRO_ID_LIKE" =~ debian|ubuntu ]]; then
                DISTRO_FAMILY="debian"
            elif [[ "$DISTRO_ID_LIKE" =~ rhel|fedora ]]; then
                DISTRO_FAMILY="rhel"
            elif [[ "$DISTRO_ID_LIKE" =~ suse ]]; then
                DISTRO_FAMILY="suse"
            elif [[ "$DISTRO_ID_LIKE" =~ arch ]]; then
                DISTRO_FAMILY="arch"
            else
                DISTRO_FAMILY="unknown"
                distro_log_warning "Unknown distribution family for: $DISTRO_ID"
            fi
            ;;
    esac
}

# Set package manager based on distribution family
set_package_manager() {
    case "$DISTRO_FAMILY" in
        debian)
            PKG_MANAGER="apt"
            ;;
        rhel|fedora)
            if command -v dnf >/dev/null 2>&1; then
                PKG_MANAGER="dnf"
            elif command -v yum >/dev/null 2>&1; then
                PKG_MANAGER="yum"
            else
                PKG_MANAGER="unknown"
                distro_log_warning "No supported package manager found for RHEL-based system"
            fi
            ;;
        suse)
            PKG_MANAGER="zypper"
            ;;
        arch)
            PKG_MANAGER="pacman"
            ;;
        alpine)
            PKG_MANAGER="apk"
            ;;
        gentoo)
            PKG_MANAGER="emerge"
            ;;
        *)
            PKG_MANAGER="unknown"
            distro_log_warning "Package manager not determined for distribution family: $DISTRO_FAMILY"
            ;;
    esac
}

# Check if the current distribution is supported
is_supported_distribution() {
    case "$DISTRO_FAMILY" in
        debian|rhel|fedora|suse)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get distribution information as a formatted string
get_distribution_info() {
    cat << EOF
Distribution Information:
  Name: $DISTRO_NAME
  ID: $DISTRO_ID
  Family: $DISTRO_FAMILY
  Version: $DISTRO_VERSION
  Version ID: $DISTRO_VERSION_ID
  Codename: $DISTRO_CODENAME
  Package Manager: $PKG_MANAGER
  WSL Environment: $IS_WSL
EOF
}

# Validate that all required distribution information is available
validate_distribution_detection() {
    local errors=()

    if [[ -z "$DISTRO_ID" ]]; then
        errors+=("Distribution ID not detected")
    fi

    if [[ -z "$DISTRO_FAMILY" ]]; then
        errors+=("Distribution family not determined")
    fi

    if [[ -z "$PKG_MANAGER" || "$PKG_MANAGER" == "unknown" ]]; then
        errors+=("Package manager not available or unknown")
    fi

    if [[ ${#errors[@]} -gt 0 ]]; then
        distro_log_error "Distribution detection validation failed:"
        for error in "${errors[@]}"; do
            distro_log_error "  - $error"
        done
        return 1
    fi

    return 0
}

# Export all distribution variables for use in other scripts
export_distribution_variables() {
    export DISTRO_ID
    export DISTRO_ID_LIKE
    export DISTRO_NAME
    export DISTRO_VERSION
    export DISTRO_VERSION_ID
    export DISTRO_CODENAME
    export DISTRO_FAMILY
    export PKG_MANAGER
    export IS_WSL
}

# Main function to run complete distribution detection
run_distribution_detection() {
    if detect_distribution; then
        if validate_distribution_detection; then
            export_distribution_variables
            distro_log_success "Distribution detection and validation completed"
            if [[ "${1:-}" == "--verbose" ]]; then
                echo
                get_distribution_info
                echo
            fi
            return 0
        else
            distro_log_error "Distribution detection validation failed"
            return 1
        fi
    else
        distro_log_error "Distribution detection failed"
        return 1
    fi
}

# Function to check if we're on a specific distribution
is_distribution() {
    local target_distro="$1"
    [[ "$DISTRO_ID" == "$target_distro" ]]
}

# Function to check if we're on a specific distribution family
is_distribution_family() {
    local target_family="$1"
    [[ "$DISTRO_FAMILY" == "$target_family" ]]
}

# If this script is run directly, perform detection
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_distribution_detection --verbose
fi