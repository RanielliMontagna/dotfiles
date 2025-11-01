#!/usr/bin/env bash

###############################################################################
# 04-docker.sh
# 
# Install Docker Engine and Docker Compose
# - Installs latest stable Docker from official repository
# - Installs Docker Compose plugin
# - Adds user to docker group
# - Enables Docker service
#
# Uses official Docker repository for latest stable versions
#
# This script is idempotent - safe to run multiple times
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[docker]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        print_info "Docker is already installed ($(docker --version))"
        
        # Check if user is in docker group
        if groups | grep -q docker; then
            print_info "User is already in docker group"
            print_success "Docker setup complete!"
            return 0
        else
            print_info "Adding user to docker group..."
            sudo usermod -aG docker "$USER"
            print_success "User added to docker group"
            print_warning "Please log out and log back in for group changes to take effect"
            return 0
        fi
    fi
    
    print_info "Installing Docker..."
    
    # Remove old versions if any
    print_info "Removing old Docker versions (if any)..."
    sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
    
    # Update package index
    sudo apt-get update
    
    # Install dependencies
    print_info "Installing dependencies..."
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    print_info "Adding Docker GPG key..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    print_info "Adding Docker repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine
    print_info "Installing Docker Engine..."
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    print_success "Docker installed: $(docker --version)"
    
    # Start and enable Docker service
    print_info "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker
    print_success "Docker service enabled"
    
    # Add current user to docker group
    print_info "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    print_success "User added to docker group"
    
    # Test Docker installation
    print_info "Testing Docker installation..."
    if sudo docker run --rm hello-world &> /dev/null; then
        print_success "Docker is working correctly!"
    else
        print_warning "Docker test failed, but installation completed"
    fi
    
    print_success "Docker setup complete!"
    print_warning "Please log out and log back in for group changes to take effect"
    print_info "After re-login, you can run Docker without sudo"
}

main "$@"
