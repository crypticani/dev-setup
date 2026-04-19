# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="eastwood"

# Which plugins would you like to load?
plugins=(
	ansible
	autopep8
	aws
	cp
	docker-compose
	docker
	git
	kubectl
	nmap
	node
	podman
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
alias code='codium'
alias ag='antigravity'

# Fun greeting
figlet -c crypticani | lolcat

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Environment setup
[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Include custom dev-setup bin dir
export PATH="$HOME/projects/crypticani/dev-setup/bin:$PATH"

# Load local environment variables if present
if [ -f "$HOME/.env.local" ]; then
    source "$HOME/.env.local"
fi
