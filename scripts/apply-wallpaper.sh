#!/usr/bin/env bash
# Applies a wallpaper using gsettings (GNOME).

set -uo pipefail
REPO_ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEFAULT_WALLPAPER="$REPO_ROOT/assets/wallpapers/tanjiro-kamado-fire-effect-5120x2880-33507.jpg"

if ! command -v gsettings >/dev/null; then
    echo "gsettings not found. This script targets GNOME desktops."
    exit 1
fi

WALLPAPER_PATH=$(realpath "${1:-$DEFAULT_WALLPAPER}" 2>/dev/null || echo "")

if [ -f "$WALLPAPER_PATH" ]; then
    echo "Applying wallpaper: $WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER_PATH"
    gsettings set org.gnome.desktop.background picture-options 'zoom'
else
    echo "Wallpaper not found: ${1:-$DEFAULT_WALLPAPER}"
    exit 1
fi
