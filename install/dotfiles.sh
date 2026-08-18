#!/usr/bin/env bash
# Symlink dotfiles with GNU Stow. Backs up conflicting real files instead of
# aborting the run (the old behaviour killed every later step).

set -uo pipefail
source ./scripts/utils.sh

command_exists stow || pkg_ensure stow

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
