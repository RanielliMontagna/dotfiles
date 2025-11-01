#!/usr/bin/env bash

###############################################################################
# 02-shell.sh
# 
# Setup Zsh with Oh My Zsh and apply dotfiles
# - Installs Zsh (latest from Ubuntu repos)
# - Installs Oh My Zsh framework
# - Installs useful plugins
# - Links dotfiles
# - Sets Zsh as default shell
#
# This script is idempotent - safe to run multiple times
###############################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/dotfiles"

print_info() {
    echo -e "${BLUE}[shell]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    # Install Zsh
    if command -v zsh &> /dev/null; then
        print_info "Zsh is already installed ($(zsh --version))"
    else
        print_info "Installing Zsh..."
        sudo apt-get install -y zsh
        print_success "Zsh installed"
    fi
    
    # Install Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_info "Oh My Zsh is already installed"
    else
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    fi
    
    # Install zsh-autosuggestions plugin
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        print_info "zsh-autosuggestions already installed"
    else
        print_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        print_success "zsh-autosuggestions installed"
    fi
    
    # Install zsh-syntax-highlighting plugin
    if [[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        print_info "zsh-syntax-highlighting already installed"
    else
        print_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        print_success "zsh-syntax-highlighting installed"
    fi
    
    # Install Powerlevel10k theme
    if [[ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
        print_info "Powerlevel10k already installed"
    else
        print_info "Installing Powerlevel10k theme..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        print_success "Powerlevel10k installed"
    fi
    
    # Link dotfiles
    print_info "Linking dotfiles..."
    
    # Backup existing files
    for file in .zshrc .gitconfig .aliases; do
        if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
            print_warning "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        fi
    done
    
    # Create symlinks
    ln -sf "$DOTFILES_CONFIG_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_CONFIG_DIR/.gitconfig" "$HOME/.gitconfig"
    ln -sf "$DOTFILES_CONFIG_DIR/.aliases" "$HOME/.aliases"
    
    print_success "Dotfiles linked"
    
    # Change default shell to Zsh
    ZSH_PATH="$(which zsh)"
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
    
    if [[ "$CURRENT_SHELL" != "$ZSH_PATH" ]]; then
        print_info "Setting Zsh as default shell..."
        # Use sudo since we've cached the password in bootstrap.sh
        sudo chsh -s "$ZSH_PATH" "$USER"
        print_success "Zsh set as default shell"
        print_warning "You may need to log out and log back in for this to take effect"
    else
        print_info "Zsh is already the default shell"
    fi
    
    print_success "Shell setup complete!"
}

main "$@"
