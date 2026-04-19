#!/usr/bin/env bash

set -e
source ./scripts/utils.sh

# Install VS Code if missing
if ! command_exists code; then
    log_info "Installing VS Code..."
    if command_exists dnf; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update || true
        sudo dnf install -y code
    elif command_exists apt-get; then
        sudo apt-get install -y wget gpg
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        sudo apt-get install -y apt-transport-https
        sudo apt-get update
        sudo apt-get install -y code
    fi
    log_success "VS Code installed."
else
    log_success "VS Code already installed."
fi

# Setup config
log_info "Setting up VS Code configuration..."
VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
mkdir -p "$VSCODE_CONFIG_DIR"
cp ./config/settings.json "$VSCODE_CONFIG_DIR/" || true

# Install extensions
if [ -f extensions.txt ]; then
    log_info "Installing VS Code extensions..."
    cat extensions.txt | while read -r ext || [ -n "$ext" ]; do
        # Ignore comments and empty lines
        if [[ "$ext" =~ ^#.* ]] || [[ -z "$ext" ]]; then
            continue
        fi
        code --install-extension "$ext" --force || true
    done
fi
