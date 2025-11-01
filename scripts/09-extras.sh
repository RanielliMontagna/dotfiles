#!/usr/bin/env bash

###############################################################################
# 09-extras.sh
# 
# Install extra development tools and utilities
# - Programming languages (Python, Go, Rust)
# - Database clients
# - Cloud CLIs (if needed)
# - Additional productivity tools
#
# All tools use latest stable/LTS versions from official sources
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
    echo -e "${BLUE}[extras]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q ^ii
}

main() {
    print_info "Installing extra development tools..."
    
    # Python 3 and pip (Ubuntu includes Python 3, but ensure pip is installed)
    if command -v python3 &> /dev/null; then
        print_info "Python3 is already installed ($(python3 --version))"
    else
        print_info "Installing Python3..."
        sudo apt-get install -y python3 python3-pip python3-venv
        print_success "Python3 installed"
    fi
    
    if command -v pip3 &> /dev/null; then
        print_info "pip3 is already installed"
    else
        print_info "Installing pip3..."
        sudo apt-get install -y python3-pip
        print_success "pip3 installed"
    fi
    
    # Git extras and tools
    print_info "Installing Git extras..."
    if is_installed "git-lfs"; then
        print_info "git-lfs already installed"
    else
        sudo apt-get install -y git-lfs
        git lfs install
        print_success "git-lfs installed"
    fi
    
    # HTTPie - user-friendly HTTP client
    if command -v http &> /dev/null; then
        print_info "HTTPie already installed"
    else
        print_info "Installing HTTPie..."
        sudo apt-get install -y httpie
        print_success "HTTPie installed"
    fi
    
    # GitHub CLI
    if command -v gh &> /dev/null; then
        print_info "GitHub CLI already installed ($(gh --version | head -n1))"
    else
        print_info "Installing GitHub CLI..."
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
        print_success "GitHub CLI installed"
    fi
    
    # PostgreSQL client
    if command -v psql &> /dev/null; then
        print_info "PostgreSQL client already installed"
    else
        print_info "Installing PostgreSQL client..."
        sudo apt-get install -y postgresql-client
        print_success "PostgreSQL client installed"
    fi
    
    # SQLite
    if command -v sqlite3 &> /dev/null; then
        print_info "SQLite already installed"
    else
        print_info "Installing SQLite..."
        sudo apt-get install -y sqlite3
        print_success "SQLite installed"
    fi
    
    # Redis CLI
    if command -v redis-cli &> /dev/null; then
        print_info "Redis CLI already installed"
    else
        print_info "Installing Redis CLI..."
        sudo apt-get install -y redis-tools
        print_success "Redis CLI installed"
    fi
    
    # Clean up
    print_info "Cleaning up..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    
    print_success "Extra tools installed successfully!"
}

main "$@"
