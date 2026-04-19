#!/usr/bin/env bash

set -e
source ./scripts/utils.sh

OS=$1

# Docker
if ! command_exists docker; then
    log_info "Installing Docker..."
    if [ "$OS" = "fedora" ]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    fi
    sudo systemctl start docker || true
    sudo systemctl enable docker || true
    sudo usermod -aG docker "$USER" || true
    log_success "Docker installed."
else
    log_success "Docker already installed."
fi

# kubectl
if ! command_exists kubectl; then
    log_info "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    log_success "kubectl installed."
else
    log_success "kubectl already installed."
fi

# Terraform
if ! command_exists terraform; then
    log_info "Installing Terraform..."
    if [ "$OS" = "fedora" ]; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf -y install terraform
    else
        # fallback to direct download for simple setup
        wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
        unzip terraform_1.7.5_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        rm terraform_1.7.5_linux_amd64.zip
    fi
    log_success "Terraform installed."
else
    log_success "Terraform already installed."
fi

# Ansible
if ! command_exists ansible; then
    log_info "Installing Ansible..."
    if [ "$OS" = "fedora" ]; then
        sudo dnf install -y ansible
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt update
        sudo apt install -y software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible || true
        sudo apt install -y ansible
    fi
    log_success "Ansible installed."
else
    log_success "Ansible already installed."
fi

# AWS CLI
if ! command_exists aws; then
    log_info "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install || true
    rm -rf aws awscliv2.zip
    log_success "AWS CLI installed."
else
    log_success "AWS CLI already installed."
fi
