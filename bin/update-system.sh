#!/usr/bin/env bash

# A small utility to update system packages and homebrew
echo "Updating OS Packages..."
if command -v dnf >/dev/null 2>&1; then
    sudo dnf update -y
elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

if command -v brew >/dev/null 2>&1; then
    echo "Updating Homebrew..."
    brew update
    brew upgrade
fi

echo "System update complete."
