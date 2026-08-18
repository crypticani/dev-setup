# Reproducible Developer Workstation Setup 🚀

Automated, idempotent setup for a Fedora (or Debian) developer workstation —
packages, dotfiles, DevOps tooling, and the full Dracula desktop theming.

## Quick Start 🏎️

```bash
git clone https://github.com/crypticani/dev-setup.git ~/projects/crypticani/dev-setup
cd ~/projects/crypticani/dev-setup
./bootstrap.sh          # interactive checklist
./bootstrap.sh --all    # one-click, no prompts
```

Other flags:

```bash
./bootstrap.sh --only zsh,dotfiles   # just these
./bootstrap.sh --skip desktop,apps   # defaults minus these
./bootstrap.sh --list                # component names
```

Each component runs independently — one failure no longer aborts the rest, and
the summary line tells you exactly what to rerun.

## Components 🧩

| Component  | What it does |
|------------|--------------|
| `base`     | RPM Fusion + core CLI packages (`dnf-packages.txt` / `apt-packages.txt`) |
| `zsh`      | oh-my-zsh, autosuggestions, syntax-highlighting, **Dracula theme**, default shell |
| `dotfiles` | Stows `.zshrc`, `.gitconfig`, `nvim` — backs up conflicting real files |
| `devops`   | Docker, kubectl, Terraform, Ansible, AWS CLI, Trivy |
| `vscode`   | VS Code + `config/extensions.txt` + `config/settings.json` |
| `desktop`  | JetBrainsMono Nerd Font, Dracula GTK/shell theme, Papirus icons, GNOME extensions, Ptyxis palette, wallpaper |
| `apps`     | Chrome, Chromium, Tailscale, TLP/powertop, Flathub apps (`config/flatpaks.txt`) |
| `node`     | nvm + latest LTS Node (off by default; distro `nodejs` is used otherwise) |

## Structure 📂

```
dev-setup/
├── bootstrap.sh            # entrypoint: checklist + dispatch
├── install/                # one script per component
├── dotfiles/               # GNU Stow packages (zsh, git, nvim)
├── config/                 # settings.json, extensions.txt, flatpaks.txt, *.dconf
├── assets/wallpapers/      # wallpapers
├── bin/                    # scripts on PATH (update-system.sh)
├── scripts/                # utils.sh, capture.sh, apply-wallpaper.sh
└── {dnf,apt}-packages.txt  # base package lists
```

## Keeping the repo in sync 🔄

Tweaked something by hand? Pull it back in instead of losing it on the next
reinstall:

```bash
./scripts/capture.sh   # re-dumps VS Code, flatpaks, GNOME + terminal dconf
git diff               # review, then commit
```

## Customization 🎨

1. **Packages:** edit `dnf-packages.txt` / `apt-packages.txt`.
2. **VS Code:** add extension IDs to `config/extensions.txt`.
3. **Flatpaks:** add app IDs to `config/flatpaks.txt`.
4. **Dotfiles:** add a stow bundle at `dotfiles/<package>/.<config>`.
5. **Wallpaper:** `./scripts/apply-wallpaper.sh /path/to/image.jpg`.
6. **Secrets:** copy `.env.example` to `~/.env.local`; `.zshrc` sources it if present.

## Notes / Manual steps 📝

- Log out and back in after a first run — shell change, `docker` group, and the
  GNOME shell theme all need a fresh session.
- `sudo tailscale up` to authenticate Tailscale.
- Google Antigravity has no package repo; install it manually. The `ag` alias in
  `.zshrc` assumes it is on `PATH`.
- Homebrew was removed — everything here comes from dnf/apt or upstream installers.
