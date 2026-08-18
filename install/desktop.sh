#!/usr/bin/env bash
# GNOME look and feel: Nerd Fonts, Dracula GTK/shell theme, extensions,
# terminal palette, wallpaper. Everything here was previously done by hand.

set -uo pipefail
source ./scripts/utils.sh

if ! command_exists gsettings; then
    log_warning "gsettings not found — not a GNOME session. Skipping desktop setup."
    exit 0
fi

FONT_NAME="JetBrainsMono"
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"

# --- Nerd Font -------------------------------------------------------------
if ls "$FONT_DIR"/${FONT_NAME}NerdFont-*.ttf >/dev/null 2>&1; then
    log_success "$FONT_NAME Nerd Font already installed."
else
    log_info "Installing $FONT_NAME Nerd Font..."
    mkdir -p "$FONT_DIR"
    tmp=$(mktemp -d)
    if curl -fsSL -o "$tmp/font.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"; then
        unzip -qo "$tmp/font.zip" -x 'README*' 'LICENSE*' 'OFL*' -d "$FONT_DIR"
        fc-cache -f "$FONT_DIR" >/dev/null
        log_success "$FONT_NAME Nerd Font installed."
    else
        log_warning "Font download failed."
    fi
    rm -rf "$tmp"
fi

# --- Dracula GTK theme + Papirus icons -------------------------------------
log_info "Installing Dracula GTK theme..."
mkdir -p "$HOME/.themes"
git_sync https://github.com/dracula/gtk.git "$HOME/.themes/Dracula"

pkg_ensure papirus-icon-theme gnome-tweaks gnome-extensions-app \
    || log_warning "Could not install theme helper packages."

# --- GNOME Shell extensions ------------------------------------------------
# uuid|distro package (empty = extensions.gnome.org only)|enable after install
EXTENSIONS=(
    "user-theme@gnome-shell-extensions.gcampax.github.com|gnome-shell-extension-user-theme|yes"
    "background-logo@fedorahosted.org|gnome-shell-extension-background-logo|yes"
    "dash-to-dock@micxgx.gmail.com|gnome-shell-extension-dash-to-dock|yes"
    "appindicatorsupport@rgcjonas.gmail.com|gnome-shell-extension-appindicator|yes"
    "caffeine@patapon.info|gnome-shell-extension-caffeine|yes"
    "clipboard-indicator@tudmotu.com||yes"
    "gsconnect@andyholmes.github.io|gnome-shell-extension-gsconnect|no"
)

# Fall back to extensions.gnome.org when there is no distro package.
install_from_ego() {
    local uuid=$1 shell_ver url tmp
    shell_ver=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)
    url=$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=$uuid&shell_version=$shell_ver" \
        | jq -r '.download_url // empty')
    if [ -z "$url" ]; then
        log_warning "No $uuid build for GNOME $shell_ver — install it from extensions.gnome.org"
        return 0
    fi
    tmp=$(mktemp -d)
    curl -fsSL -o "$tmp/ext.zip" "https://extensions.gnome.org$url" \
        && gnome-extensions install --force "$tmp/ext.zip" \
        && log_success "Installed $uuid"
    rm -rf "$tmp"
}

log_info "Installing GNOME Shell extensions..."
for entry in "${EXTENSIONS[@]}"; do
    IFS='|' read -r uuid pkg enable <<<"$entry"
    # Already present as a user or system extension? Leave it alone — installing
    # the distro package on top would just duplicate it.
    if gnome-extensions list 2>/dev/null | grep -qx "$uuid"; then
        log_success "$uuid already installed."
    elif [ -n "$pkg" ]; then
        pkg_ensure "$pkg" || log_warning "Could not install $pkg"
    else
        install_from_ego "$uuid"
    fi
    if [ "$enable" = "yes" ]; then
        gnome-extensions enable "$uuid" 2>/dev/null \
            || log_warning "Could not enable $uuid (needs a session restart)."
    fi
done

# --- Settings --------------------------------------------------------------
log_info "Applying GNOME settings..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'
# Match libadwaita/Shell tinting to Dracula's purple, or GNOME apps stay teal
# while Dracula-themed GTK apps go purple. Ignored on GNOME < 47.
gsettings set org.gnome.desktop.interface accent-color 'purple' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font Mono 12'
gsettings set org.gnome.shell.extensions.user-theme name 'Dracula' 2>/dev/null || true

# Shared per-extension tweaks (dock position, caffeine, shell theme name).
if command_exists dconf && [ -f config/gnome-shell.dconf ]; then
    dconf load /org/gnome/shell/extensions/ < config/gnome-shell.dconf \
        && log_success "Loaded extension settings."
fi

# Personal desktop state — dock favourites, app grid order, world clocks.
# Delete config/personal/ if you forked this; scripts/capture.sh regenerates it.
if command_exists dconf && [ -f config/personal/gnome-shell.dconf ]; then
    dconf load /org/gnome/shell/ < config/personal/gnome-shell.dconf \
        && log_success "Loaded personal Shell state (favourites, app grid)."
fi

# Ptyxis (Fedora's default terminal): Dracula palette + Nerd Font
if [ -f config/ptyxis.dconf ] && command_exists dconf; then
    dconf load /org/gnome/Ptyxis/ < config/ptyxis.dconf \
        && log_success "Applied terminal profile."
fi

# --- Wallpaper -------------------------------------------------------------
bash ./scripts/apply-wallpaper.sh || log_warning "Wallpaper not applied."

log_success "Desktop setup done. Log out and back in for the shell theme to load."
