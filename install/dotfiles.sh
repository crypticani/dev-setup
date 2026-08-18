#!/usr/bin/env bash
# Symlink dotfiles with GNU Stow. Backs up conflicting real files instead of
# aborting the run (the old behaviour killed every later step).

set -uo pipefail
source ./scripts/utils.sh

command_exists stow || pkg_ensure stow

# Git identity is per-person, so it lives outside the repo. Reuse whatever git
# already knows; only ask if this is a genuinely fresh machine.
if [ ! -f "$HOME/.gitconfig.local" ]; then
    name=$(git config --global user.name 2>/dev/null || true)
    email=$(git config --global user.email 2>/dev/null || true)
    if [ -z "$name" ] || [ -z "$email" ]; then
        log_info "Setting up your git identity (stored in ~/.gitconfig.local)."
        [ -z "$name" ] && read -rp "  Git user.name: " name
        [ -z "$email" ] && read -rp "  Git user.email: " email
    fi
    if [ -n "$name" ] && [ -n "$email" ]; then
        printf '[user]\n\tname = %s\n\temail = %s\n' "$name" "$email" > "$HOME/.gitconfig.local"
        log_success "Wrote ~/.gitconfig.local for $name <$email>"
    else
        log_warning "No git identity set — run: git config --global user.name/user.email"
    fi
fi

# Dracula for Neovim as a native package — no plugin manager needed. Lives
# outside the repo so the stowed nvim config stays a pure config directory.
NVIM_PACK="$HOME/.local/share/nvim/site/pack/themes/start"
mkdir -p "$NVIM_PACK"
git_sync https://github.com/dracula/vim.git "$NVIM_PACK/dracula" \
    && log_success "Dracula colorscheme ready for Neovim."

cd dotfiles
STATUS=0
for pkg in */; do
    pkg=${pkg%/}

    # Move any real file that stow wants to own out of the way. Paths that
    # already resolve into this repo are stowed symlinks — never touch those,
    # or a second run would "back up" the repo's own files.
    while IFS= read -r target; do
        home_file="$HOME/$target"
        [ -e "$home_file" ] || continue
        [ "$(realpath "$home_file")" = "$(realpath "$pkg/$target")" ] && continue
        backup_if_real "$home_file"
    done < <(cd "$pkg" && find . -type f -printf '%P\n')

    if stow -R -t "$HOME" "$pkg"; then
        log_success "Stowed $pkg"
    else
        log_error "Failed to stow $pkg"
        STATUS=1
    fi
done
exit $STATUS
