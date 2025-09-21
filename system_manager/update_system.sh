#!/bin/bash
# Simple script to update the system, upgrade packages, and clean up.
# Cross-distribution support for multiple Linux distributions
# Version 3.0: Added multi-distribution support

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

# --- Help Function ---
show_help() {
    cat << EOF
A script to update, upgrade, and clean a Linux system across multiple distributions.

Usage: update_system [OPTIONS]

OPTIONS:
    -h, --help    Show this help message

Supported distributions:
    • Debian/Ubuntu (apt)
    • RHEL/CentOS/Rocky Linux (dnf/yum)
    • Fedora (dnf)
    • openSUSE (zypper)

The script automatically detects your distribution and uses the appropriate package manager.

For more details, please see the README.md file in the system_manager project.
EOF
}

# --- Argument Parsing for Help ---
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# --- Sudo Check ---
check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        if command -v sudo &>/dev/null; then
            echo "[Info] Not root. Using 'sudo' for package operations."
            SUDO_CMD="sudo"
        else
            echo "[Error] This script must be run as root or with sudo." >&2
            exit 1
        fi
    else
        SUDO_CMD=""
    fi
}

# --- Distribution Detection ---
detect_system() {
    echo "[Info] Detecting Linux distribution..."

    if ! run_distribution_detection; then
        echo "[Error] Failed to detect Linux distribution." >&2
        exit 1
    fi

    echo "[Info] Detected: $DISTRO_NAME ($DISTRO_FAMILY) using $PKG_MANAGER"

    if ! is_supported_distribution; then
        echo "[Warning] Your distribution ($DISTRO_ID) may not be fully supported."
        echo "[Warning] The script will attempt to continue, but some operations may fail."
    fi
}

# --- Update Package Lists ---
update_package_lists() {
    echo "[Info] [1/4] Updating package lists for $PKG_MANAGER..."

    if ! pkg_update; then
        echo "[Error] Package list update failed. Exiting." >&2
        exit 1
    else
        echo "[Success] Package lists updated successfully."
    fi
}

# --- Upgrade Packages ---
upgrade_packages() {
    echo "[Info] [2/4] Upgrading packages..."

    case "$PKG_MANAGER" in
        apt)
            if ! $SUDO_CMD apt upgrade -y; then
                echo "[Warning] 'apt upgrade' encountered issues, but continuing cleanup." >&2
            else
                echo "[Success] Packages upgraded successfully."
            fi
            ;;
        dnf)
            if ! $SUDO_CMD dnf upgrade -y; then
                echo "[Warning] 'dnf upgrade' encountered issues, but continuing cleanup." >&2
            else
                echo "[Success] Packages upgraded successfully."
            fi
            ;;
        yum)
            if ! $SUDO_CMD yum update -y; then
                echo "[Warning] 'yum update' encountered issues, but continuing cleanup." >&2
            else
                echo "[Success] Packages upgraded successfully."
            fi
            ;;
        zypper)
            if ! $SUDO_CMD zypper update -y; then
                echo "[Warning] 'zypper update' encountered issues, but continuing cleanup." >&2
            else
                echo "[Success] Packages upgraded successfully."
            fi
            ;;
        *)
            echo "[Error] Unsupported package manager: $PKG_MANAGER" >&2
            exit 1
            ;;
    esac
}

# --- Remove Unused Packages ---
remove_unused_packages() {
    echo "[Info] [3/4] Removing unused packages..."

    case "$PKG_MANAGER" in
        apt)
            if ! $SUDO_CMD apt autoremove -y; then
                echo "[Warning] 'apt autoremove' encountered issues." >&2
            else
                echo "[Success] Unused packages removed successfully."
            fi
            ;;
        dnf)
            if ! $SUDO_CMD dnf autoremove -y; then
                echo "[Warning] 'dnf autoremove' encountered issues." >&2
            else
                echo "[Success] Unused packages removed successfully."
            fi
            ;;
        yum)
            if ! $SUDO_CMD yum autoremove -y; then
                echo "[Warning] 'yum autoremove' encountered issues." >&2
            else
                echo "[Success] Unused packages removed successfully."
            fi
            ;;
        zypper)
            # zypper doesn't have a direct autoremove, but we can clean up
            echo "[Info] Cleaning up zypper cache..."
            if ! $SUDO_CMD zypper clean -a; then
                echo "[Warning] 'zypper clean' encountered issues." >&2
            else
                echo "[Success] Package cache cleaned successfully."
            fi
            ;;
        *)
            echo "[Warning] Unused package removal not implemented for $PKG_MANAGER"
            ;;
    esac
}

# --- Clean Package Cache ---
clean_package_cache() {
    echo "[Info] [4/4] Cleaning package cache..."

    case "$PKG_MANAGER" in
        apt)
            if ! $SUDO_CMD apt clean; then
                echo "[Warning] 'apt clean' encountered issues." >&2
            else
                echo "[Success] Package cache cleaned successfully."
            fi
            ;;
        dnf)
            if ! $SUDO_CMD dnf clean all; then
                echo "[Warning] 'dnf clean all' encountered issues." >&2
            else
                echo "[Success] Package cache cleaned successfully."
            fi
            ;;
        yum)
            if ! $SUDO_CMD yum clean all; then
                echo "[Warning] 'yum clean all' encountered issues." >&2
            else
                echo "[Success] Package cache cleaned successfully."
            fi
            ;;
        zypper)
            # Already handled in remove_unused_packages for zypper
            echo "[Info] Package cache already cleaned for zypper."
            ;;
        *)
            echo "[Warning] Cache cleaning not implemented for $PKG_MANAGER"
            ;;
    esac
}

# --- Security Updates (for distributions that support it) ---
install_security_updates() {
    echo "[Info] Checking for security updates..."

    case "$PKG_MANAGER" in
        apt)
            # Check if unattended-upgrades is available for security updates
            if command -v unattended-upgrade &>/dev/null; then
                echo "[Info] Running security updates via unattended-upgrades..."
                $SUDO_CMD unattended-upgrade -d
            else
                echo "[Info] unattended-upgrades not available, security updates included in regular upgrade."
            fi
            ;;
        dnf)
            # DNF supports security updates
            echo "[Info] Installing security updates..."
            $SUDO_CMD dnf upgrade --security -y || echo "[Warning] Security update command failed or no security updates available."
            ;;
        yum)
            # YUM supports security updates
            echo "[Info] Installing security updates..."
            $SUDO_CMD yum update --security -y || echo "[Warning] Security update command failed or no security updates available."
            ;;
        zypper)
            # Check for security patches
            echo "[Info] Installing security patches..."
            $SUDO_CMD zypper patch --category security --non-interactive || echo "[Warning] No security patches available or command failed."
            ;;
        *)
            echo "[Info] Security update checking not implemented for $PKG_MANAGER"
            ;;
    esac
}

# --- Main Function ---
main() {
    echo "=========================================="
    echo "Linux System Update Script v3.0"
    echo "Cross-Distribution Support"
    echo "=========================================="
    echo

    # Initialize
    check_sudo
    detect_system

    echo
    echo "Starting system update process..."
    echo

    # Core update operations
    update_package_lists
    upgrade_packages
    remove_unused_packages
    clean_package_cache

    # Optional security updates
    echo
    install_security_updates

    echo
    echo "=========================================="
    echo "[Success] System update completed!"
    echo "Distribution: $DISTRO_NAME"
    echo "Package Manager: $PKG_MANAGER"
    echo "=========================================="

    # Check if reboot is needed (distribution-specific)
    check_reboot_needed
}

# --- Check if reboot is needed ---
check_reboot_needed() {
    case "$DISTRO_FAMILY" in
        debian)
            if [[ -f /var/run/reboot-required ]]; then
                echo
                echo "[Info] ⚠️  System reboot is required to complete some updates."
                echo "[Info] Run 'sudo reboot' when convenient."
            fi
            ;;
        rhel|fedora)
            if command -v needs-restarting &>/dev/null; then
                if needs-restarting -r &>/dev/null; then
                    echo
                    echo "[Info] ⚠️  System reboot is recommended to complete some updates."
                    echo "[Info] Run 'sudo reboot' when convenient."
                fi
            fi
            ;;
        suse)
            if command -v zypper &>/dev/null; then
                if zypper ps -s 2>/dev/null | grep -q "reboot"; then
                    echo
                    echo "[Info] ⚠️  System reboot may be required to complete some updates."
                    echo "[Info] Run 'sudo reboot' when convenient."
                fi
            fi
            ;;
    esac
}

# --- Error Handling ---
set -e
trap 'echo "[Error] Script failed on line $LINENO. Exiting." >&2; exit 1' ERR

# --- Run Main Function ---
main "$@"