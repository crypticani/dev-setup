#!/usr/bin/env bash
# Main entrypoint. Interactive by default, --all for one-click.

set -uo pipefail
cd "$(dirname "$0")"
source ./scripts/utils.sh

# name|description|default-on|script
COMPONENTS=(
    "base|Core CLI packages (git, zsh, stow, ripgrep, fzf, eza, ...)|1|install/base.sh"
    "zsh|Zsh + oh-my-zsh + plugins + Dracula theme + default shell|1|install/zsh.sh"
    "dotfiles|Symlink .zshrc / .gitconfig / nvim via GNU Stow|1|install/dotfiles.sh"
    "devops|Docker, kubectl, Terraform, Ansible, AWS CLI, Trivy|1|install/devops-tools.sh"
    "vscode|VS Code + extensions + settings.json|1|install/vscode.sh"
    "desktop|Nerd Fonts, Dracula GTK/shell theme, GNOME extensions, terminal|1|install/desktop.sh"
    "apps|Chrome, Tailscale, Flatpak apps, power tools|1|install/apps.sh"
    "node|nvm + latest Node (system node is used otherwise)|0|install/node.sh"
)

usage() {
    cat <<EOF
Usage: ./bootstrap.sh [options]

  (no options)      interactive checklist
  --all             run every component, no prompts
  --only a,b,c      run only these components
  --skip a,b        run defaults except these
  --list            list component names and exit
  -h, --help        this message

Components: $(for c in "${COMPONENTS[@]}"; do printf '%s ' "${c%%|*}"; done)
EOF
}

# --- selection state -------------------------------------------------------
SELECTED=()
for c in "${COMPONENTS[@]}"; do
    IFS='|' read -r _ _ def _ <<<"$c"
    SELECTED+=("$def")
done

index_of() {
    local name=$1 i
    for i in "${!COMPONENTS[@]}"; do
        [ "${COMPONENTS[$i]%%|*}" = "$name" ] && { echo "$i"; return 0; }
    done
    return 1
}

set_all() {
    local value=$1 i
    for i in "${!SELECTED[@]}"; do SELECTED[$i]=$value; done
}

set_many() {
    local value=$1 list=$2 name idx
    IFS=',' read -ra names <<<"$list"
    for name in "${names[@]}"; do
        idx=$(index_of "$name") || { log_error "Unknown component: $name"; exit 1; }
        SELECTED[$idx]=$value
    done
}

INTERACTIVE=1
while [ $# -gt 0 ]; do
    case $1 in
        --all)  INTERACTIVE=0; set_all 1 ;;
        --only) INTERACTIVE=0; set_all 0; set_many 1 "$2"; shift ;;
        --skip) INTERACTIVE=0; set_many 0 "$2"; shift ;;
        --list) for c in "${COMPONENTS[@]}"; do echo "${c%%|*}"; done; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown option: $1"; usage; exit 1 ;;
    esac
    shift
done

print_menu() {
    echo
    echo -e "${BOLD}Select what to install/configure:${NC}"
    local i name desc mark
    for i in "${!COMPONENTS[@]}"; do
        IFS='|' read -r name desc _ _ <<<"${COMPONENTS[$i]}"
        [ "${SELECTED[$i]}" = "1" ] && mark="${GREEN}x${NC}" || mark=" "
        printf "  %2d) [%b] %-9s %s\n" "$((i + 1))" "$mark" "$name" "$desc"
    done
    echo
}

if [ "$INTERACTIVE" = "1" ]; then
    while true; do
        print_menu
        read -rp "Toggle numbers (e.g. '2 5'), 'a' all, 'n' none, Enter to start: " reply
        case $reply in
            "") break ;;
            a|A) set_all 1 ;;
            n|N) set_all 0 ;;
            *)
                for n in $reply; do
                    if [[ $n =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#COMPONENTS[@]}" ]; then
                        i=$((n - 1))
                        [ "${SELECTED[$i]}" = "1" ] && SELECTED[$i]=0 || SELECTED[$i]=1
                    else
                        log_warning "Ignoring '$n'"
                    fi
                done
                ;;
        esac
    done
fi

# --- run -------------------------------------------------------------------
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    log_error "Cannot detect operating system."
    exit 1
fi

log_info "Detected OS: $OS $VERSION_ID"

# Prime sudo so long runs don't stall midway on a password prompt.
sudo -v || log_warning "sudo not primed; individual steps may prompt."

FAILED=()
DONE=()
for i in "${!COMPONENTS[@]}"; do
    [ "${SELECTED[$i]}" = "1" ] || continue
    IFS='|' read -r name desc _ script <<<"${COMPONENTS[$i]}"
    log_step "$name — $desc"
    # A failing component must not abort the rest of the run.
    if bash "$script" "$OS"; then
        DONE+=("$name")
    else
        FAILED+=("$name")
        log_error "Component '$name' failed (continuing)."
    fi
done

echo
[ ${#DONE[@]} -gt 0 ] && log_success "Completed: ${DONE[*]}"
if [ ${#FAILED[@]} -gt 0 ]; then
    log_error "Failed: ${FAILED[*]} — rerun with: ./bootstrap.sh --only $(IFS=,; echo "${FAILED[*]}")"
    exit 1
fi
log_success "Setup complete. Log out and back in for shell, docker group and GNOME changes."
