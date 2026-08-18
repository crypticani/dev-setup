#!/usr/bin/env bash
# DevOps tooling. Each tool is independent — one failure must not skip the rest.

set -uo pipefail
source ./scripts/utils.sh

OS=${1:-}

# Docker
if ! command_exists docker; then
    log_info "Installing Docker..."
    if [ "$OS" = "fedora" ]; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager addrepo --overwrite-spec \
            --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        curl -fsSL https://get.docker.com | sudo sh
    fi
    sudo systemctl enable --now docker || true
    sudo usermod -aG docker "$USER" || true
    log_success "Docker installed (log out and back in for group membership)."
else
    log_success "Docker already installed."
fi

# kubectl
if ! command_exists kubectl; then
    log_info "Installing kubectl..."
    tmp=$(mktemp -d)
    if curl -fsSLo "$tmp/kubectl" \
        "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; then
        sudo install -o root -g root -m 0755 "$tmp/kubectl" /usr/local/bin/kubectl
        log_success "kubectl installed."
    else
        log_warning "kubectl download failed."
    fi
    rm -rf "$tmp"
else
    log_success "kubectl already installed."
fi

# Terraform
if ! command_exists terraform; then
    log_info "Installing Terraform..."
    if [ "$OS" = "fedora" ]; then
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager addrepo --overwrite-spec \
            --from-repofile=https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf -y install terraform
    else
        curl -fsSL https://apt.releases.hashicorp.com/gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
            | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
        sudo apt-get update && sudo apt-get install -y terraform
    fi
    log_success "Terraform installed."
else
    log_success "Terraform already installed."
fi

# Trivy (uses the HashiCorp-style repo pattern above; Fedora ships it directly)
if ! command_exists trivy; then
    log_info "Installing Trivy..."
    pkg_ensure trivy || log_warning "Trivy install failed."
else
    log_success "Trivy already installed."
fi

# Ansible
if ! command_exists ansible; then
    log_info "Installing Ansible..."
    pkg_ensure ansible || log_warning "Ansible install failed."
else
    log_success "Ansible already installed."
fi

# AWS CLI
if ! command_exists aws; then
    log_info "Installing AWS CLI..."
    tmp=$(mktemp -d)
    if curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmp/awscliv2.zip"; then
        unzip -q "$tmp/awscliv2.zip" -d "$tmp"
        sudo "$tmp/aws/install" --update || log_warning "AWS CLI install failed."
        log_success "AWS CLI installed."
    fi
    rm -rf "$tmp"
else
    log_success "AWS CLI already installed."
fi
