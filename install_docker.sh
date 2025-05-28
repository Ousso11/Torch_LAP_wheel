#!/bin/bash

# Detect OS
OS="$(uname)"
echo "Detected OS: $OS"

install_docker_linux() {
  echo "Installing Docker for Linux..."

  # Update package index and install prerequisites
  sudo apt-get update
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  # Add Docker's GPG key
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  # Add Docker repository
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker Engine
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # Enable Docker service
  sudo systemctl enable docker
  sudo systemctl start docker

  echo "Docker installed successfully on Linux."
}

install_docker_macos() {
  echo "Installing Docker for macOS..."

  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Install Docker using Homebrew
  brew install --cask docker

  echo "Docker installed successfully on macOS."
  echo "Please open Docker.app from the Applications folder to complete the setup."
}

# Run appropriate installer
case "$OS" in
  "Linux")
    install_docker_linux
    ;;
  "Darwin")
    install_docker_macos
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac
