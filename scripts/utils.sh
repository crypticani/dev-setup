#!/usr/bin/env bash
# Utility functions for setup scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "\n${BOLD}${BLUE}==>${NC} ${BOLD}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install packages with the detected package manager.
pkg_install() {
    if command_exists dnf; then
        sudo dnf install -y "$@"
    elif command_exists apt-get; then
        sudo apt-get install -y "$@"
    else
        log_warning "No supported package manager for: $*"
        return 1
    fi
}

# Install only the packages that are actually missing, so repeat runs don't
# need sudo at all.
pkg_ensure() {
    local pkg missing=()
    for pkg in "$@"; do
        if command_exists rpm; then
            rpm -q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
        elif command_exists dpkg; then
            dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        log_success "Already installed: $*"
        return 0
    fi
    log_info "Installing: ${missing[*]}"
    pkg_install "${missing[@]}"
}

# Clone a repo, or pull if it already exists. Idempotent.
git_sync() {
    local url=$1 dest=$2
    if [ -d "$dest/.git" ]; then
        git -C "$dest" pull --quiet --ff-only || log_warning "Could not update $dest"
    else
        git clone --depth 1 --quiet "$url" "$dest" || {
            log_warning "Failed to clone $url"
            return 1
        }
    fi
}

# Move a real (non-symlink) file out of the way so stow can take over.
backup_if_real() {
    local target=$1
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "$target.bak.$(date +%s)"
        log_warning "Backed up existing $target"
    fi
}
