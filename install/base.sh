#!/usr/bin/env bash
# Core CLI packages.

set -uo pipefail
source ./scripts/utils.sh

OS=${1:-}

case $OS in
    fedora)
        if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
            log_info "Enabling RPM Fusion (codecs and extra packages)..."
            sudo dnf install -y \
                "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
                "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
                || log_warning "RPM Fusion setup failed."
        else
            log_success "RPM Fusion already enabled."
        fi

        log_info "Installing packages from dnf-packages.txt..."
        sudo dnf upgrade -y --refresh
        grep -vE '^\s*(#|$)' dnf-packages.txt | xargs sudo dnf install -y
        ;;
    ubuntu|debian)
        log_info "Installing packages from apt-packages.txt..."
        sudo apt-get update -y
        grep -vE '^\s*(#|$)' apt-packages.txt | xargs sudo apt-get install -y
        ;;
    *)
        log_warning "Unsupported OS for base packages: $OS. Skipping."
        ;;
esac
