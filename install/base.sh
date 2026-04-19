#!/usr/bin/env bash

set -e
source ./scripts/utils.sh

OS=$1

if [ "$OS" = "fedora" ]; then
    log_info "Updating DNF and installing packages from dnf-packages.txt..."
    sudo dnf update -y
    xargs -a dnf-packages.txt sudo dnf install -y
elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    log_info "Updating APT and installing packages from apt-packages.txt..."
    sudo apt-get update -y
    xargs -a apt-packages.txt sudo apt-get install -y
else
    log_warning "Unsupported OS for base packages: $OS. Skipping base installation."
fi

# Install Homebrew if not exists
if ! command_exists brew; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
    
    # Configure homebrew in path for current session based on OS
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
else
    log_success "Homebrew already installed."
fi
