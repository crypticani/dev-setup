#!/usr/bin/env bash
# Update system packages, flatpaks and oh-my-zsh.

set -uo pipefail

echo "Updating OS packages..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf upgrade -y --refresh
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

if command -v flatpak >/dev/null 2>&1; then
    echo "Updating flatpaks..."
    flatpak update -y
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Updating oh-my-zsh..."
    zsh -ic "omz update" 2>/dev/null || true
fi

echo "System update complete."
