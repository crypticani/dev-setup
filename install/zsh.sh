#!/usr/bin/env bash
# Zsh, oh-my-zsh, plugins and the Dracula theme.

set -uo pipefail
source ./scripts/utils.sh

command_exists zsh || pkg_ensure zsh

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log_info "Installing oh-my-zsh..."
    RUNZSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "oh-my-zsh installed."
else
    log_success "oh-my-zsh already installed."
fi

ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Plugins referenced by dotfiles/zsh/.zshrc
log_info "Installing zsh plugins..."
git_sync https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git_sync https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Dracula theme. Lives in custom/themes so `omz update` cannot wipe it; the
# theme resolves lib/async.zsh from custom/themes/dracula/lib itself.
log_info "Installing Dracula zsh theme..."
if git_sync https://github.com/dracula/zsh.git "$ZSH_CUSTOM/themes/dracula"; then
    ln -sf "$ZSH_CUSTOM/themes/dracula/dracula.zsh-theme" "$ZSH_CUSTOM/themes/dracula.zsh-theme"
    log_success "Dracula theme installed."
fi

# A real ~/.zshrc here would block stow; install/dotfiles.sh backs it up.
rm -f "$HOME/.zshrc.pre-oh-my-zsh"

# Default shell
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    log_info "Changing default shell to zsh..."
    sudo usermod -s "$(command -v zsh)" "$USER" || log_warning "Could not change shell; run: chsh -s \$(which zsh)"
else
    log_success "Default shell is already zsh."
fi
