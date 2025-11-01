#!/usr/bin/env bash

###############################################################################
# 01-essentials.sh
# 
# Install essential development tools and dependencies
# - Updates system packages
# - Installs build essentials, git, curl, wget, etc.
# - All packages are kept up-to-date using apt
#
# This script is idempotent - safe to run multiple times
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[essentials]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Check if package is installed
is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q ^ii
}

install_if_missing() {
    if is_installed "$1"; then
        print_info "$1 is already installed"
    else
        print_info "Installing $1..."
        sudo apt-get install -y "$1"
        print_success "$1 installed"
    fi
}

main() {
    print_info "Updating package lists..."
    sudo apt-get update
    
    print_info "Upgrading existing packages..."
    sudo apt-get upgrade -y
    
    # Essential packages
    PACKAGES=(
        "build-essential"   # Compiler and build tools
        "git"               # Version control
        "curl"              # Transfer data from URLs
        "wget"              # Download files
        "ca-certificates"   # SSL certificates
        "gnupg"             # GNU Privacy Guard
        "lsb-release"       # LSB version reporting
        "software-properties-common"  # Manage repositories
        "apt-transport-https"  # HTTPS support for apt
        "unzip"             # Unzip files
        "zip"               # Zip files
        "tree"              # Display directory structure
        "htop"              # Interactive process viewer
        "nano"              # Text editor
        "tmux"              # Terminal multiplexer
        "jq"                # JSON processor
        "ripgrep"           # Fast grep alternative
        "bat"               # Cat with syntax highlighting
        "fd-find"           # Fast find alternative
        "fzf"               # Fuzzy finder
    )
    
    print_info "Installing essential packages..."
    for package in "${PACKAGES[@]}"; do
        install_if_missing "$package"
    done
    
    # Clean up
    print_info "Cleaning up..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    
    print_success "Essential tools installed successfully!"
}

main "$@"
