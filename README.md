# Reproducible Developer Workstation Setup 🚀

A complete, automated, and idempotent dotfiles and development environment setup built for Fedora/Debian systems. Handcrafted for DevOps engineers.

## Features ✨
- **Idempotent Bootstrap:** Safe to run multiple times; only installs what is missing.
- **GNU Stow:** Modular symlink management for dotfiles (`.zshrc`, `.gitconfig`, `nvim`, etc.).
- **DevOps Core Tooling:** Automated installation of Docker, Kubectl, Terraform, Ansible, and AWS CLI.
- **Visual Studio Code:** Automatic setup with declarative extensions and customized `settings.json`.
- **Zsh & Oh-My-Zsh:** Syntax highlighting, autosuggestions, and optimal standard aliases.

## Structure 📂
```
dev-setup/
├── README.md              # You are here
├── bootstrap.sh           # Main entrypoint script
├── install/               # Modular installation scripts (base, devops, vscode)
├── dotfiles/              # Modular directories for GNU Stow (zsh, git, nvim)
├── config/                # Direct configuration overrides (e.g., VS Code settings.json)
├── assets/                # Local assets like wallpapers or fonts
├── bin/                   # Reusable custom scripts, automatically added to PATH
├── scripts/               # Setup utilities (apply-wallpaper.sh, utils.sh)
├── apt-packages.txt       # Base package list for Debian/Ubuntu
├── dnf-packages.txt       # Base package list for Fedora
├── extensions.txt         # VS Code extensions list
└── .env.example           # Example localized environment secrets
```

## Quick Start 🏎️

To completely restore this development environment on a fresh machine format:

```bash
git clone https://github.com/crypticani/dev-setup.git ~/projects/crypticani/dev-setup
cd ~/projects/crypticani/dev-setup
chmod +x bootstrap.sh scripts/*.sh install/*.sh bin/*.sh
./bootstrap.sh
```

## Customization 🎨

1. **Packages:** Edit `dnf-packages.txt` or `apt-packages.txt`.
2. **VS Code:** Add new extension IDs to `extensions.txt`.
3. **Dotfiles:** Place new configurations inside `dotfiles/` following the existing stow bundle structure `dotfiles/<package>/.<config>`.
4. **Secrets:** Copy `.env.example` to `~/.env.local` to safely source your tokens without committing them to source control.

## Troubleshooting 🛠️
- **Dotfile symlink conflicts:** If a `.zshrc` already exists, Stow will throw a conflict. Back it up and remove it (`rm ~/.zshrc`), then re-run `./bootstrap.sh`.
- **Docker permissions:** Remember to log out and log back in (or reboot) for the newly added `docker` group to take effect.
