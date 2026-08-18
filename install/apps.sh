#!/usr/bin/env bash
# GUI apps and system utilities that live outside the base package list.

set -uo pipefail
source ./scripts/utils.sh

OS=${1:-}

if [ "$OS" != "fedora" ]; then
    log_warning "apps.sh currently targets Fedora only. Skipping."
    exit 0
fi

# --- Google Chrome ---------------------------------------------------------
if ! command_exists google-chrome-stable; then
    log_info "Installing Google Chrome..."
    sudo dnf install -y fedora-workstation-repositories >/dev/null 2>&1 || true
    sudo dnf config-manager setopt google-chrome.enabled=1 2>/dev/null \
        || sudo dnf config-manager --set-enabled google-chrome 2>/dev/null || true
    pkg_ensure google-chrome-stable || log_warning "Chrome install failed."
else
    log_success "Google Chrome already installed."
fi

pkg_ensure chromium || log_warning "Chromium install failed."

# --- Tailscale -------------------------------------------------------------
if ! command_exists tailscale; then
    log_info "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh || log_warning "Tailscale install failed."
    sudo systemctl enable --now tailscaled || true
    log_info "Run 'sudo tailscale up' to authenticate."
else
    log_success "Tailscale already installed."
fi

# --- Laptop power management ----------------------------------------------
pkg_ensure tlp tlp-rdw powertop || log_warning "Power tools install failed."
systemctl is-enabled tlp >/dev/null 2>&1 || sudo systemctl enable --now tlp 2>/dev/null || true

# --- Flatpak apps ---------------------------------------------------------
if command_exists flatpak; then
    flatpak remote-add --if-not-exists --user flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo || true
    while IFS= read -r app; do
        [[ $app =~ ^[[:space:]]*(#|$) ]] && continue
        if flatpak info "$app" >/dev/null 2>&1; then
            log_success "$app already installed."
        else
            log_info "Installing flatpak $app..."
            flatpak install -y --user flathub "$app" || log_warning "Failed: $app"
        fi
    done < config/flatpaks.txt
else
    log_warning "flatpak not available; skipping flatpak apps."
fi
