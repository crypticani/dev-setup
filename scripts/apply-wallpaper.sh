#!/usr/bin/env bash

# Applies a wallpaper using gsettings (GNOME)
DEFAULT_WALLPAPER="../assets/wallpapers/default.jpg"

if ! command -v gsettings >/dev/null; then
    echo "gsettings not found. This script is intended for GNOME desktop environments."
    exit 1
fi

WALLPAPER_PATH=$(realpath "${1:-$DEFAULT_WALLPAPER}")

if [ -f "$WALLPAPER_PATH" ]; then
    echo "Applying wallpaper: $WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
else
    echo "Wallpaper file not found: $WALLPAPER_PATH"
    exit 1
fi
