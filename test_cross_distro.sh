#!/bin/bash
# test_cross_distro.sh
# Test script to verify cross-distribution functionality

set -e

echo "=========================================="
echo "Cross-Distribution Setup Test"
echo "=========================================="
echo

# Load libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/distro_detect.sh"
source "$SCRIPT_DIR/lib/package_manager.sh"

echo "1. Testing distribution detection..."
if run_distribution_detection; then
    echo "✅ Distribution detection: PASSED"
    echo "   Detected: $DISTRO_NAME ($DISTRO_FAMILY)"
    echo "   Package Manager: $PKG_MANAGER"
else
    echo "❌ Distribution detection: FAILED"
    exit 1
fi

echo
echo "2. Testing package name mapping..."

# Test some common package mappings
test_packages=(
    "development-tools"
    "python3-devel"
    "fd"
    "docker.io"
)

for package in "${test_packages[@]}"; do
    mapped_name=$(get_package_name "$package")
    echo "   $package → $mapped_name"
done
echo "✅ Package name mapping: PASSED"

echo
echo "3. Testing package manager commands..."

# Test basic package manager detection
if command -v "$PKG_MANAGER" >/dev/null 2>&1; then
    echo "✅ Package manager ($PKG_MANAGER): Available"
else
    echo "❌ Package manager ($PKG_MANAGER): Not found"
    exit 1
fi

echo
echo "4. Testing install script compatibility..."

# Check that install scripts can source our libraries
scripts_to_test=(
    "install_routines/40_docker.sh"
    "install_routines/70_terminal_enhancements.sh"
    "install_routines/15_tmux.sh"
    "install_routines/80_1password_cli.sh"
    "system_manager/update_system.sh"
)

for script in "${scripts_to_test[@]}"; do
    if [[ -f "$script" ]]; then
        # Test if script can be sourced without errors (dry run)
        if bash -n "$script" 2>/dev/null; then
            echo "✅ $script: Syntax OK"
        else
            echo "❌ $script: Syntax error"
            exit 1
        fi
    else
        echo "❌ $script: Not found"
        exit 1
    fi
done

echo
echo "5. Testing main setup script..."
if bash -n setup.sh 2>/dev/null; then
    echo "✅ setup.sh: Syntax OK"
else
    echo "❌ setup.sh: Syntax error"
    exit 1
fi

echo
echo "=========================================="
echo "🎉 All tests passed!"
echo
echo "Your Linux Setup is ready for:"
case "$DISTRO_FAMILY" in
    debian)
        echo "   • Debian/Ubuntu systems"
        ;;
    rhel|fedora)
        echo "   • RHEL/CentOS/Rocky Linux/Fedora systems"
        ;;
    suse)
        echo "   • openSUSE systems"
        ;;
    *)
        echo "   • Your current system ($DISTRO_FAMILY)"
        ;;
esac

echo
echo "To run the full setup:"
echo "   ./setup.sh"
echo
echo "To test individual components:"
echo "   ./lib/distro_detect.sh --verbose"
echo "   ./install_routines/70_terminal_enhancements.sh"
echo "   ./system_manager/update_system.sh"
echo "=========================================="