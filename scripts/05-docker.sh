#!/usr/bin/env bash

###############################################################################
# 05-docker.sh
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

# Load common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/common.sh" ]]; then
    source "$SCRIPT_DIR/common.sh"
else
    # Fallback if common.sh not found
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
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
    
    print_error() {
        echo -e "${RED}✗${NC} $1"
    }
fi

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
    
    # Update package index (use centralized function if available)
    if command -v ensure_apt_updated &> /dev/null; then
        ensure_apt_updated
    else
        sudo apt-get update
    fi
    
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
    
    # Download GPG key with retry and timeout
    local gpg_key_installed=false
    local gpg_retries=0
    local max_gpg_retries=3
    
    while [[ $gpg_retries -lt $max_gpg_retries ]] && [[ "$gpg_key_installed" == "false" ]]; do
        if command -v safe_curl_download &> /dev/null; then
            # Use common.sh function if available
            local gpg_temp="/tmp/docker.gpg"
            if safe_curl_download "https://download.docker.com/linux/ubuntu/gpg" "$gpg_temp" 3 60 30; then
                sudo gpg --dearmor < "$gpg_temp" | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
                rm -f "$gpg_temp"
                gpg_key_installed=true
            else
                gpg_retries=$((gpg_retries + 1))
                if [[ $gpg_retries -lt $max_gpg_retries ]]; then
                    print_warning "Failed to download GPG key, retrying ($gpg_retries/$max_gpg_retries)..."
                    sleep 2
                fi
            fi
        else
            # Fallback to direct curl
            if curl -fsSL --max-time 60 --connect-timeout 30 --retry 3 \
                "https://download.docker.com/linux/ubuntu/gpg" | \
                sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null; then
                gpg_key_installed=true
            else
                gpg_retries=$((gpg_retries + 1))
                if [[ $gpg_retries -lt $max_gpg_retries ]]; then
                    print_warning "Failed to download GPG key, retrying ($gpg_retries/$max_gpg_retries)..."
                    sleep 2
                fi
            fi
        fi
    done
    
    if [[ "$gpg_key_installed" == "false" ]]; then
        print_error "Failed to download Docker GPG key after $max_gpg_retries attempts"
        print_info "Please check your internet connection and try again"
        return 1
    fi
    
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    print_success "Docker GPG key added"
    
    # Set up the repository
    print_info "Adding Docker repository..."
    local distro_codename
    distro_codename=$(lsb_release -cs 2>/dev/null || echo "jammy")
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $distro_codename stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    print_success "Docker repository added"
    
    # Update package index again (force update needed after adding repository)
    print_info "Updating package lists with Docker repository..."
    if command -v ensure_apt_updated &> /dev/null; then
        if ! ensure_apt_updated true; then
            print_warning "Package list update had warnings, but continuing..."
        fi
    else
        sudo apt-get update || print_warning "Package list update had warnings, but continuing..."
    fi
    
    # Install Docker Engine
    print_info "Installing Docker Engine..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin; then
        print_success "Docker packages installed"
    else
        print_error "Failed to install Docker packages"
        print_info "This might be due to:"
        print_info "  1. Package availability issues (check if packages exist)"
        print_info "  2. Network problems"
        print_info "  3. Dependency conflicts"
        print_info ""
        print_info "Try running manually:"
        print_info "  sudo apt-get update"
        print_info "  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        return 1
    fi
    
    print_success "Docker installed: $(docker --version)"
    
    # Start and enable Docker service
    print_info "Starting Docker service..."
    if sudo systemctl start docker 2>/dev/null; then
        print_success "Docker service started"
    else
        print_warning "Failed to start Docker service (may need reboot)"
    fi
    
    if sudo systemctl enable docker 2>/dev/null; then
        print_success "Docker service enabled"
    else
        print_warning "Failed to enable Docker service"
    fi
    
    # Add current user to docker group
    print_info "Adding user to docker group..."
    sudo usermod -aG docker "$USER"
    print_success "User added to docker group"
    
    # Test Docker installation
    print_info "Testing Docker installation..."
    if sudo docker run --rm hello-world &> /dev/null 2>&1; then
        print_success "Docker is working correctly!"
    else
        print_warning "Docker test failed, but installation completed"
        print_info "Docker may need a moment to start, or you may need to reboot"
        print_info "You can test manually later with: sudo docker run hello-world"
    fi
    
    print_success "Docker setup complete!"
    print_warning "Please log out and log back in for group changes to take effect"
    print_info "After re-login, you can run Docker without sudo"
}

main "$@"
