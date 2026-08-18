#!/usr/bin/env bash
# VS Code, extensions and settings.

set -uo pipefail
source ./scripts/utils.sh

if ! command_exists code; then
    log_info "Installing VS Code..."
    if command_exists dnf; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf check-update || true
        sudo dnf install -y code
    elif command_exists apt-get; then
        sudo apt-get install -y wget gpg apt-transport-https
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
            | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
        rm -f packages.microsoft.gpg
        sudo apt-get update && sudo apt-get install -y code
    fi
    log_success "VS Code installed."
else
    log_success "VS Code already installed."
fi

# Settings — back up any existing file rather than silently overwriting it.
VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
mkdir -p "$VSCODE_CONFIG_DIR"
if [ -f "$VSCODE_CONFIG_DIR/settings.json" ] \
    && ! diff -q ./config/settings.json "$VSCODE_CONFIG_DIR/settings.json" >/dev/null; then
    cp "$VSCODE_CONFIG_DIR/settings.json" "$VSCODE_CONFIG_DIR/settings.json.bak"
    log_warning "Existing settings.json backed up to settings.json.bak"
fi
cp ./config/settings.json "$VSCODE_CONFIG_DIR/settings.json"
log_success "VS Code settings applied."

# Extensions
log_info "Installing VS Code extensions..."
installed=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
while IFS= read -r ext || [ -n "$ext" ]; do
    [[ $ext =~ ^[[:space:]]*(#|$) ]] && continue
    if grep -qix "$ext" <<<"$installed"; then
        log_success "$ext already installed."
    else
        code --install-extension "$ext" --force >/dev/null && log_success "Installed $ext" \
            || log_warning "Failed to install $ext"
    fi
done < ./config/extensions.txt
