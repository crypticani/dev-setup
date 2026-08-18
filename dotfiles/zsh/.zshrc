# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="dracula"

# Which plugins would you like to load?
plugins=(
#	ansible
#	autopep8
#	aws
	cp
	docker-compose
	docker
	git
	kubectl
#	nmap
#	node
#	podman
	ssh
	zsh-autosuggestions
        zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Custom aliases
alias k="kubectl"
alias d="docker"
alias dc="docker-compose"
alias tf="terraform"

# Set personal aliases from original .zshrc
#alias code='codium'
alias ag='antigravity'

# Fun greeting (override the name with GREETING_NAME in ~/.env.local)
(( $+commands[figlet] && $+commands[lolcat] )) && figlet -c "${GREETING_NAME:-$USER}" | lolcat

# Dracula for fzf (bat and btop read their own stowed configs)
export FZF_DEFAULT_OPTS="\
--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 \
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 \
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Environment setup
[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Include the dev-setup bin dir, resolved from where this file is stowed from,
# so the repo can live anywhere.
DEV_SETUP_DIR=${${(%):-%N}:A:h:h:h}
[ -d "$DEV_SETUP_DIR/bin" ] && export PATH="$DEV_SETUP_DIR/bin:$PATH"

# Load local environment variables if present
if [ -f "$HOME/.env.local" ]; then
    source "$HOME/.env.local"
fi

# Show git branch and status (1 = on, 0 = off)
DRACULA_DISPLAY_GIT=1

# Show current time
DRACULA_DISPLAY_TIME=0

# Show username and host context
DRACULA_DISPLAY_CONTEXT=1

# Show the path as the full current working directory
DRACULA_DISPLAY_FULL_CWD=1

# Trim the directory path when full cwd is enabled (0 = no trim)
DRACULA_DIR_TRIM=1

# Put command input on a new line
DRACULA_DISPLAY_NEW_LINE=0

# Arrow symbol at the prompt start
#DRACULA_ARROW_ICON="-> "

# Time format, for example a 24-hour clock
#DRACULA_TIME_FORMAT="%-H:%M"

RPROMPT='%F{#6272A4}%T%f'
