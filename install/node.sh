#!/usr/bin/env bash
# nvm + latest LTS Node. Optional — the distro's node package works fine too.

set -uo pipefail
source ./scripts/utils.sh

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    log_info "Installing nvm..."
    PROFILE=/dev/null curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
    log_success "nvm already installed."
fi

# shellcheck disable=SC1091
\. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default lts/*
log_success "Node $(node --version) active via nvm."
