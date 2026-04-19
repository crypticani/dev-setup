#!/usr/bin/env bash

set -e

# Load utility functions
source ./scripts/utils.sh

log_info "Starting Developer Workstation Setup..."

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    log_error "Cannot detect Operating System."
    exit 1
fi

log_info "Detected OS: $OS"

# Run Base Installations
log_info "Installing base packages..."
bash ./install/base.sh "$OS"

# Set up oh-my-zsh and plugins before stowing to avoid conflicts
log_info "Setting up Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || true
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || true
fi

# Apply dotfiles using Stow
log_info "Stowing dotfiles..."
cd dotfiles
# Stow individual dotfile packages
for app in */ ; do
    stow -R -t "$HOME" "${app%/}"
    log_success "Stowed ${app%/}"
done
cd ..

# Install DevOps Tools
log_info "Installing DevOps tools..."
bash ./install/devops-tools.sh "$OS"

# Setup VS Code
log_info "Setting up VS Code..."
bash ./install/vscode.sh

# Change default shell to zsh if needed
if [[ "$SHELL" != *zsh ]]; then
    log_info "Changing default shell to zsh..."
    chsh -s "$(which zsh)" || log_warning "Failed to change shell. You may need to do this manually."
fi

log_success "Setup Completed! Please restart your terminal/session for all changes to take effect."
