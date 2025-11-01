#!/usr/bin/env bash

###############################################################################
# bootstrap.sh
# 
# Main entry point for dotfiles setup on Zorin OS (Ubuntu-based)
# 
# Usage:
#   bash bootstrap.sh
#   or
#   curl -s https://raw.githubusercontent.com/RanielliMontagna/dotfiles/main/bootstrap.sh | bash
#
# This script is idempotent - safe to run multiple times
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

###############################################################################
# Helper functions
###############################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if running on Ubuntu/Zorin
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS. This script is designed for Zorin OS (Ubuntu-based)."
        exit 1
    fi
    
    . /etc/os-release
    
    if [[ "$ID" != "zorin" ]] && [[ "$ID_LIKE" != *"ubuntu"* ]] && [[ "$ID" != "ubuntu" ]]; then
        print_warning "This script is optimized for Zorin OS (Ubuntu-based)."
        print_warning "Detected: $NAME"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

###############################################################################
# Main execution
###############################################################################

main() {
    print_header "🚀 Dotfiles Setup for Zorin OS"
    
    print_info "Starting setup process..."
    print_info "Dotfiles directory: $DOTFILES_DIR"
    
    # Check OS compatibility
    check_os
    
    # Make sure all scripts are executable
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
    
    # Run installation scripts in order
    print_header "📦 Installing Essential Tools"
    bash "$SCRIPTS_DIR/01-essentials.sh"
    
    print_header "🐚 Setting up Shell (Zsh)"
    bash "$SCRIPTS_DIR/02-shell.sh"
    
    print_header "🟢 Installing Node.js (via NVM)"
    bash "$SCRIPTS_DIR/03-nodejs.sh"
    
    print_header "📝 Installing Code Editors"
    bash "$SCRIPTS_DIR/04-editors.sh"
    
    print_header "🐳 Installing Docker"
    bash "$SCRIPTS_DIR/05-docker.sh"
    
    print_header "☕ Installing Java SDK"
    bash "$SCRIPTS_DIR/06-java.sh"
    
    print_header "🛠️ Installing Development Tools"
    bash "$SCRIPTS_DIR/07-dev-tools.sh"
    
    print_header "🌐 Installing Applications"
    bash "$SCRIPTS_DIR/08-applications.sh"
    
    print_header "🔧 Installing Extra Tools"
    read -p "Install extra development tools? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$SCRIPTS_DIR/09-extras.sh"
    else
        print_info "Skipping extra tools installation"
    fi
    
    print_header "✨ Setup Complete!"
    print_success "Your development environment is ready!"
    print_info "Please restart your terminal or run: source ~/.zshrc"
    
    # Show next steps
    echo -e "\n${YELLOW}Next steps:${NC}"
    echo "1. Restart your terminal"
    echo "2. Configure git with your details:"
    echo "   git config --global user.name \"Your Name\""
    echo "   git config --global user.email \"your.email@example.com\""
    echo "3. Review and customize ~/.zshrc if needed"
    echo ""
}

# Run main function
main "$@"
