# Reproducible Developer Workstation Setup 🚀

Automated, idempotent setup for a Fedora (or Debian) developer workstation —
packages, dotfiles, DevOps tooling, and the full Dracula desktop theming.

## Quick Start 🏎️

```bash
git clone https://github.com/crypticani/dev-setup.git   # anywhere you like
cd dev-setup
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
| `dotfiles` | Stows `.zshrc`, `.gitconfig`, `nvim`, `tmux`, `bat` — backs up conflicting real files, installs the Dracula nvim colorscheme |
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
├── dotfiles/               # GNU Stow packages (zsh, git, nvim, tmux, bat)
├── config/                 # settings.json, extensions.txt, flatpaks.txt, *.dconf
│   └── personal/           # one person's desktop state — safe to delete on a fork
├── assets/wallpapers/      # wallpapers
├── bin/                    # scripts on PATH (update-system.sh)
├── scripts/                # utils.sh, capture.sh, apply-wallpaper.sh
└── {dnf,apt}-packages.txt  # base package lists
```

## Forking this 🍴

Nothing here is pinned to one machine or one person:

- **Git identity** is not in the repo. `install/dotfiles.sh` writes `~/.gitconfig.local`
  on first run (reusing your existing `git config` if set, otherwise prompting);
  the tracked `.gitconfig` just `[include]`s it.
- **Repo location** is derived, not hardcoded — `.zshrc` resolves its own stow
  symlink, so clone anywhere.
- **Shell greeting** uses `$USER`; override with `GREETING_NAME` in `~/.env.local`.
- **`config/personal/`** holds one person's desktop state (dock favourites, app
  grid order, world clocks). Delete it, or overwrite it with `scripts/capture.sh`.
- **Taste, edit freely:** `config/extensions.txt` (`wakatime` needs your own API
  key), `config/flatpaks.txt`, `install/apps.sh`, and the `EXTENSIONS` table in
  `install/desktop.sh`.

## Theming 🧛

Dracula everywhere, with the palette from [draculatheme.com](https://draculatheme.com):

| Surface | Where it's set |
|---|---|
| GTK apps, GNOME Shell | `install/desktop.sh` — `dracula/gtk` into `~/.themes` + `user-theme` |
| GNOME accent colour | `install/desktop.sh` — `accent-color = purple`, so libadwaita matches |
| Terminal (Ptyxis) | `config/ptyxis.dconf` — `palette = dracula` |
| zsh prompt | `dotfiles/zsh/.zshrc` — `ZSH_THEME="dracula"`, installed by `install/zsh.sh` |
| Neovim | `dotfiles/nvim/.config/nvim/init.lua` — `dracula/vim` as a native package |
| tmux | `dotfiles/tmux/.tmux.conf` — hand-rolled, no TPM needed |
| bat | `dotfiles/bat/.config/bat/config` — `--theme="Dracula"` (built in) |
| fzf | `dotfiles/zsh/.zshrc` — `FZF_DEFAULT_OPTS` |
| VS Code | `config/settings.json` — `Dracula Theme` extension |

**btop is left alone on purpose.** It rewrites its whole 286-line config on
exit, so stowing it meant a dirty `git diff` after every run. Set it once in the
TUI (`Esc` → Options → color theme → `dracula`) — btop ships the theme.

**Icons are the one exception:** Dracula publishes no icon theme, so GNOME uses
Papirus-Dark (the pairing Dracula's own GTK docs suggest) and VS Code uses
`vs-seti`. For purple folders, `papirus-folders -C violet` gets closer, but it
rewrites `/usr/share/icons` and has to be re-run after every Papirus update —
which is why it is not automated here.

To use a different theme, change `ZSH_THEME` in `dotfiles/zsh/.zshrc` and the
theme lines in `install/desktop.sh`, then swap the dotfiles above.

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
