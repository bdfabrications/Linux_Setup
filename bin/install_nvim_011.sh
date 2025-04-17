#!/bin/bash
# Script to download and install a SPECIFIC Neovim release binary (v0.11.0 x86_64)
# using the user-provided URL.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration based on user-provided URL ---
NVIM_VERSION="v0.11.0"
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.11.0/nvim-linux-x86_64.tar.gz"
TARBALL_FILENAME="nvim-linux-x86_64.tar.gz" # Derived from URL
EXTRACTED_DIR_NAME="nvim-linux-x86_64"  # Derived from URL
EXPECTED_ARCH="x86_64"                   # Derived from URL

echo "--- Neovim $NVIM_VERSION (x86_64) Binary Installer ---"
echo "[Info] Using specific URL: $NVIM_URL"

# --- Check if running as root ---
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script needs to be run as root."
   exit 1
fi
echo "[Info] Running as root."

# --- Check Dependencies ---
echo "[Check] Verifying required tools (wget, tar)..."
MISSING_DEPS=()
command -v wget &> /dev/null || MISSING_DEPS+=("wget")
command -v tar &> /dev/null || MISSING_DEPS+=("tar")

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    echo "[Error] The following dependencies are missing: ${MISSING_DEPS[*]}"
    echo "[Error] Please install them (e.g., using 'apt install ${MISSING_DEPS[*]}') and re-run."
    exit 1
fi
echo "[Check] Required tools found."

# --- Verify Architecture (Optional Safety Check) ---
CURRENT_ARCH=$(uname -m)
echo "[Info] Current system architecture: $CURRENT_ARCH"
if [[ "$CURRENT_ARCH" != "$EXPECTED_ARCH" ]]; then
    echo "[Warning] The current architecture ($CURRENT_ARCH) does not match the download URL's expected architecture ($EXPECTED_ARCH)."
    read -p "Continue anyway? (y/N): " -i "N" continue_anyway
    if [[ ! "$continue_anyway" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# --- Download, Extract, Install, Cleanup ---
INSTALL_DIR="/root" # Temporary download location
echo "[Info] Changing to directory: $INSTALL_DIR"
cd "$INSTALL_DIR"

echo "[Step] Downloading $TARBALL_FILENAME..."
# Check if file already exists from a previous attempt and remove it to ensure fresh download
if [ -f "$TARBALL_FILENAME" ]; then
    echo "[Info] Removing existing '$TARBALL_FILENAME' before download."
    rm -f "$TARBALL_FILENAME"
fi
wget --quiet --show-progress -O "$TARBALL_FILENAME" "$NVIM_URL"


echo "[Step] Extracting archive..."
# Remove existing extracted directory if it exists to ensure clean extraction
if [ -d "$EXTRACTED_DIR_NAME" ]; then
    echo "[Info] Removing existing directory '$EXTRACTED_DIR_NAME' before extraction."
    rm -rf "$EXTRACTED_DIR_NAME"
fi
tar xzvf "$TARBALL_FILENAME"

INSTALL_BIN_DIR="/usr/local/bin"
echo "[Step] Copying nvim executable to $INSTALL_BIN_DIR/..."
# Ensure the target directory exists
mkdir -p "$INSTALL_BIN_DIR"
# Copy the binary
cp "$EXTRACTED_DIR_NAME/bin/nvim" "$INSTALL_BIN_DIR/"

echo "[Step] Setting permissions..."
chmod +x "$INSTALL_BIN_DIR/nvim"

echo "[Step] Cleaning up downloaded files..."
rm -rf "$EXTRACTED_DIR_NAME" "$TARBALL_FILENAME"

echo "[Step] Clearing command cache..."
hash -r

# --- Verify ---
echo "[Verify] Checking installed Neovim version..."
# Ensure we are checking the newly installed binary
if ! command -v "$INSTALL_BIN_DIR/nvim" &> /dev/null; then
    echo "[Error] Cannot find nvim executable at '$INSTALL_BIN_DIR/nvim' after installation."
    exit 1
fi
INSTALLED_VERSION_FULL=$("$INSTALL_BIN_DIR/nvim" --version | head -n 1)
echo "[Verify] Found: $INSTALLED_VERSION_FULL"

# Extract just the version number part for comparison
INSTALLED_VERSION_NUM=$(echo "$INSTALLED_VERSION_FULL" | sed -n 's/NVIM v\([0-9.]*\).*/\1/p')
EXPECTED_VERSION_NUM=$(echo "$NVIM_VERSION" | sed 's/v//') # Remove 'v' prefix

if [[ "$INSTALLED_VERSION_NUM" == "$EXPECTED_VERSION_NUM" ]]; then
     echo "[Success] Neovim $NVIM_VERSION installed successfully!"
else
    echo "[Error] Verification failed. Expected version '$EXPECTED_VERSION_NUM' but found '$INSTALLED_VERSION_NUM'."
    echo "[Error] Please check the output of '$INSTALL_BIN_DIR/nvim --version'."
    exit 1
fi

# --- Finished ---
echo ""
echo "--------------------------------------------------"
echo "✅ Automatic Neovim $NVIM_VERSION installation script finished."
echo "You can now launch Neovim by typing: nvim"
echo "--------------------------------------------------"

exit 0
