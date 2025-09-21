#!/bin/bash

# Docker & Docker Compose Installation Script - Cross Distribution Support
# This script automates the installation of Docker Engine and the Docker Compose plugin
# across multiple Linux distributions (Ubuntu/Debian, RHEL/CentOS/Rocky, Fedora, openSUSE)

# --- Load Library Functions ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/distro_detect.sh
source "$SCRIPT_DIR/../lib/distro_detect.sh"
# shellcheck source=../lib/package_manager.sh
source "$SCRIPT_DIR/../lib/package_manager.sh"

echo "Starting Docker installation process..."
set -e # Exit immediately if a command exits with a non-zero status.

# Detect distribution if not already done
if [[ -z "$DISTRO_FAMILY" ]]; then
    run_distribution_detection
fi

echo "Installing Docker for $DISTRO_NAME ($DISTRO_FAMILY)..."

# --- Step 1: Remove old Docker versions ---
echo "Removing old Docker versions if present..."
case "$DISTRO_FAMILY" in
    debian)
        sudo apt-get remove --purge -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli 2>/dev/null || true
        ;;
    rhel|fedora)
        sudo $PKG_MANAGER remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine podman buildah 2>/dev/null || true
        ;;
    suse)
        sudo zypper remove -y docker docker-engine containerd runc 2>/dev/null || true
        ;;
esac

# --- Step 2: Update package lists and install prerequisites ---
echo "Updating package list and installing prerequisites..."
pkg_update

case "$DISTRO_FAMILY" in
    debian)
        pkg_install "apt-transport-https" "ca-certificates" "curl" "software-properties-common" "gnupg" "lsb-release"
        ;;
    rhel|fedora)
        pkg_install "ca-certificates" "curl" "gnupg" "lsb-release"
        if [[ "$DISTRO_FAMILY" == "rhel" ]]; then
            pkg_install "yum-utils" "device-mapper-persistent-data" "lvm2"
        fi
        ;;
    suse)
        pkg_install "ca-certificates" "curl" "gnupg" "lsb-release"
        ;;
esac

# --- Step 3: Add Docker's official GPG key and repository ---
echo "Adding Docker's GPG key and repository..."

case "$DISTRO_FAMILY" in
    debian)
        # Create the directory for keyrings if it doesn't exist
        sudo install -m 0755 -d /etc/apt/keyrings

        # Determine the correct Docker repository URL
        if [[ "$DISTRO_ID" == "ubuntu" ]]; then
            DOCKER_REPO_URL="https://download.docker.com/linux/ubuntu"
        else
            DOCKER_REPO_URL="https://download.docker.com/linux/debian"
        fi

        # Download and save the Docker GPG key
        curl -fsSL "$DOCKER_REPO_URL/gpg" | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg

        # Add the repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $DOCKER_REPO_URL $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        pkg_update
        ;;

    rhel|fedora)
        # Add Docker's GPG key
        sudo mkdir -p /etc/pki/rpm-gpg

        if [[ "$DISTRO_ID" == "fedora" ]]; then
            curl -fsSL https://download.docker.com/linux/fedora/gpg | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-docker > /dev/null
            sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        else
            # RHEL, CentOS, Rocky, AlmaLinux
            curl -fsSL https://download.docker.com/linux/centos/gpg | sudo tee /etc/pki/rpm-gpg/RPM-GPG-KEY-docker > /dev/null
            sudo $PKG_MANAGER config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        fi
        ;;

    suse)
        # Add Docker repository for openSUSE
        sudo zypper addrepo https://download.docker.com/linux/sles/docker-ce.repo
        sudo zypper refresh
        ;;
esac

# --- Step 4: Install Docker Engine and Compose Plugin ---
echo "Installing Docker Engine and Docker Compose..."

case "$DISTRO_FAMILY" in
    debian)
        pkg_install "docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin"
        ;;
    rhel|fedora)
        pkg_install "docker-ce" "docker-ce-cli" "containerd.io" "docker-buildx-plugin" "docker-compose-plugin"
        ;;
    suse)
        pkg_install "docker" "docker-compose"
        ;;
esac

# --- Step 5: Enable and start Docker service ---
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# --- Step 6: Add current user to the docker group ---
echo "Adding current user ($USER) to the 'docker' group..."
sudo usermod -aG docker "$USER"

# --- Step 7: Final instructions ---
echo ""
echo "--------------------------------------------------------"
echo "✅ Docker installation completed successfully on $DISTRO_NAME!"
echo ""
echo "IMPORTANT: To use Docker without 'sudo', you need to apply the group changes."
echo "You have two options:"
echo "  1. (Recommended) Log out of your system and log back in. This works permanently."
echo "  2. (For this session only) Run the following command to apply changes for the current terminal:"
echo "     newgrp docker"
echo ""
echo "After applying the changes using one of the methods above, you can verify the installation:"
echo "  docker --version"
echo "  docker compose version"
echo "  docker run hello-world"
echo ""
if [[ "$IS_WSL" == "true" ]]; then
    echo "WSL NOTE: You may need to restart your WSL session for Docker to work properly."
fi
echo "--------------------------------------------------------"