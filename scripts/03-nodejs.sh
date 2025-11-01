#!/usr/bin/env bash

###############################################################################
# 03-nodejs.sh
# 
# Install Node.js via NVM (Node Version Manager)
# - Installs latest NVM
# - Installs Node.js LTS version (recommended)
# - Sets up npm global packages
# - Configures npm for optimal performance
#
# NVM allows easy switching between Node versions
# Always installs LTS version by default (most stable)
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
    echo -e "${BLUE}[nodejs]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    # Install NVM
    if [[ -d "$HOME/.nvm" ]]; then
        print_info "NVM is already installed"
        # Load NVM to check version
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        print_info "NVM version: $(nvm --version)"
    else
        print_info "Installing NVM..."
        # Get latest NVM version from GitHub
        NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
        print_info "Installing NVM $NVM_VERSION..."
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
        
        # Load NVM
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        
        print_success "NVM installed"
    fi
    
    # Load NVM if not loaded
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install Node.js LTS
    print_info "Installing Node.js LTS (Long Term Support)..."
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
    
    print_success "Node.js $(node --version) installed"
    print_success "npm $(npm --version) installed"
    
    # Install useful global packages
    print_info "Installing global npm packages..."
    
    GLOBAL_PACKAGES=(
        "yarn"              # Alternative package manager
        "pnpm"              # Fast, disk space efficient package manager
        "typescript"        # TypeScript compiler
        "npm-check-updates" # Update package.json dependencies
    )
    
    for package in "${GLOBAL_PACKAGES[@]}"; do
        if npm list -g "$package" &> /dev/null; then
            print_info "$package is already installed globally"
        else
            print_info "Installing $package..."
            npm install -g "$package"
            print_success "$package installed"
        fi
    done
    
    # Install Bun (JavaScript runtime and package manager)
    if command -v bun &> /dev/null; then
        print_info "Bun is already installed ($(bun --version))"
    else
        print_info "Installing Bun..."
        curl -fsSL https://bun.sh/install | bash
        # Add Bun to PATH for current session
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        print_success "Bun installed"
    fi
    
    # Configure npm
    print_info "Configuring npm..."
    npm config set fund false        # Disable funding messages
    npm config set audit false       # Disable audit messages (for faster installs)
    npm config set update-notifier false  # Disable update notifications
    
    print_success "Node.js setup complete!"
    print_info "Node version: $(node --version)"
    print_info "NPM version: $(npm --version)"
    if command -v bun &> /dev/null; then
        print_info "Bun version: $(bun --version)"
    fi
    print_info "You can install other Node versions with: nvm install <version>"
}

main "$@"
