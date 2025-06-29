#!/bin/bash

# Docker & Docker Compose Installation Script for Ubuntu
# This script automates the installation of Docker Engine and the Docker Compose plugin.
# It follows the official Docker installation guide.

# --- Step 0: Announce the start of the script ---
echo "Starting Docker installation process..."
set -e # Exit immediately if a command exits with a non-zero status.

# --- Step 1: Update package lists and install prerequisites ---
echo "Updating package list and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# --- Step 2: Add Docker's official GPG key ---
echo "Adding Docker's GPG key..."
# Create the directory for keyrings if it doesn't exist
sudo install -m 0755 -d /etc/apt/keyrings
# Download and save the Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# Set the permissions for the key
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# --- Step 3: Set up the Docker repository ---
echo "Setting up the Docker repository..."
echo \
	"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# --- Step 4: Install Docker Engine and Compose Plugin ---
echo "Installing Docker Engine and Docker Compose..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Step 5: Add current user to the docker group ---
echo "Adding current user ($USER) to the 'docker' group..."
sudo usermod -aG docker $USER

# --- Step 6: Final instructions ---
echo ""
echo "--------------------------------------------------------"
echo "✅ Docker installation completed successfully!"
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
echo "--------------------------------------------------------"
