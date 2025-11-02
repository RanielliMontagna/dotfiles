#!/usr/bin/env bash

###############################################################################
# 02-shell.sh
# 
# Setup Zsh with Oh My Zsh and Starship prompt
# - Installs Zsh (latest from Ubuntu repos)
# - Installs Oh My Zsh framework
# - Installs useful plugins
# - Installs Starship prompt (modern, fast, customizable)
# - Links dotfiles
# - Sets Zsh as default shell
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
        echo -e "${BLUE}[shell]${NC} $1"
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

# Get dotfiles directory
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DOTFILES_CONFIG_DIR="$DOTFILES_DIR/dotfiles"

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
    
    # Install Nerd Font (required for Starship icons to display correctly)
    print_info "Installing Nerd Font (Meslo) for Starship icons..."
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Check if any Nerd Font is already installed
    local nerd_font_installed=false
    if fc-list | grep -qi "nerd\|meslo" 2>/dev/null; then
        nerd_font_installed=true
        print_info "Nerd Font already installed"
    else
        # Try to install Meslo Nerd Font
        local meslo_dir="$fonts_dir/Meslo"
        mkdir -p "$meslo_dir"
        
        # Download Meslo Nerd Font from GitHub releases
        local meslo_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip"
        local meslo_zip="/tmp/meslo-nerd-font.zip"
        
        if command -v safe_curl_download_with_cache &> /dev/null; then
            if safe_curl_download_with_cache "$meslo_url" "$meslo_zip" 3 300 30; then
                # Install unzip if not available
                if ! command -v unzip &> /dev/null; then
                    if command -v ensure_apt_updated &> /dev/null; then
                        ensure_apt_updated
                    fi
                    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y unzip 2>/dev/null || true
                fi
                
                if command -v unzip &> /dev/null; then
                    unzip -q -o "$meslo_zip" -d "/tmp/meslo-extract" 2>/dev/null || true
                    if [[ -d "/tmp/meslo-extract" ]]; then
                        find "/tmp/meslo-extract" -name "*.ttf" -exec cp {} "$meslo_dir/" \; 2>/dev/null || true
                        rm -rf "/tmp/meslo-extract"
                        nerd_font_installed=true
                    fi
                    rm -f "$meslo_zip"
                fi
            fi
        elif command -v curl &> /dev/null; then
            # Fallback: direct curl
            if curl -fsSL --max-time 300 --connect-timeout 30 --retry 3 "$meslo_url" -o "$meslo_zip" 2>/dev/null; then
                if command -v unzip &> /dev/null; then
                    unzip -q -o "$meslo_zip" -d "/tmp/meslo-extract" 2>/dev/null || true
                    if [[ -d "/tmp/meslo-extract" ]]; then
                        find "/tmp/meslo-extract" -name "*.ttf" -exec cp {} "$meslo_dir/" \; 2>/dev/null || true
                        rm -rf "/tmp/meslo-extract"
                        nerd_font_installed=true
                    fi
                    rm -f "$meslo_zip"
                fi
            fi
        fi
        
        # Update font cache
        if [[ "$nerd_font_installed" == "true" ]] && command -v fc-cache &> /dev/null; then
            print_info "Updating font cache..."
            fc-cache -fv "$fonts_dir" 2>/dev/null || true
            print_success "Nerd Font (Meslo) installed and cache updated"
        elif [[ "$nerd_font_installed" == "false" ]]; then
            print_warning "Could not install Nerd Font automatically"
            print_info "You may need to install it manually. Visit: https://www.nerdfonts.com/"
        fi
    fi
    
    # Install Starship prompt (modern, fast, customizable)
    if command -v starship &> /dev/null; then
        print_info "Starship already installed ($(starship --version 2>/dev/null | head -n1 || echo 'installed'))"
    else
        print_info "Installing Starship prompt..."
        
        # Use official Starship installer script
        if command -v curl &> /dev/null; then
            # Use safe_curl_download_with_cache if available, otherwise direct curl
            if command -v safe_curl_download_with_cache &> /dev/null; then
                local installer_script="/tmp/starship-install.sh"
                if safe_curl_download_with_cache "https://starship.rs/install.sh" "$installer_script" 3 120 30; then
                    sh "$installer_script" --yes
                    rm -f "$installer_script"
                    print_success "Starship installed"
                else
                    print_error "Failed to download Starship installer"
                    return 1
                fi
            else
                # Fallback: direct curl
                if curl -fsSL https://starship.rs/install.sh | sh -s -- --yes; then
                    print_success "Starship installed"
                else
                    print_error "Failed to install Starship"
                    return 1
                fi
            fi
        else
            print_error "curl is required to install Starship"
            return 1
        fi
        
        # Verify installation
        if command -v starship &> /dev/null; then
            print_success "Starship installed successfully"
        else
            print_warning "Starship installation completed but command not found"
            print_info "You may need to restart your terminal or run: source ~/.zshrc"
        fi
    fi
    
    # Configure Starship with Nerd Font Symbols preset
    if command -v starship &> /dev/null; then
        local starship_config_dir="$HOME/.config"
        local starship_config_file="$starship_config_dir/starship.toml"
        
        # Only create config if it doesn't exist (preserve user customization)
        if [[ ! -f "$starship_config_file" ]]; then
            print_info "Configuring Starship with Nerd Font Symbols preset..."
            mkdir -p "$starship_config_dir"
            
            # Generate preset using starship command
            if starship preset nerd-font-symbols > "$starship_config_file" 2>/dev/null; then
                print_success "Starship configured with Nerd Font Symbols preset"
                print_info "Config file: $starship_config_file"
            else
                print_warning "Could not generate Starship preset automatically"
                print_info "You can manually configure by running: starship preset nerd-font-symbols > ~/.config/starship.toml"
            fi
        else
            print_info "Starship config already exists, skipping preset generation"
            print_info "To apply Nerd Font Symbols preset, run: starship preset nerd-font-symbols > ~/.config/starship.toml"
        fi
    fi
    
    # Create project directories structure
    print_info "Creating project directories..."
    PROJECT_DIRS=(
        "$HOME/www/personal"
    )
    
    for dir in "${PROJECT_DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            print_info "Directory $dir already exists"
        else
            mkdir -p "$dir"
            print_success "Created directory $dir"
        fi
    done
    
    # Link dotfiles
    print_info "Linking dotfiles..."
    
    # Backup existing files
    for file in .zshrc .gitconfig .aliases; do
        if [[ -f "$HOME/$file" ]] && [[ ! -L "$HOME/$file" ]]; then
            print_warning "Backing up existing $file to $file.backup"
            mv "$HOME/$file" "$HOME/$file.backup"
        fi
    done
    
    # Backup existing Git config files if they exist and are not symlinks
    if [[ -f "$HOME/.gitconfig-my" ]] && [[ ! -L "$HOME/.gitconfig-my" ]]; then
        print_warning "Backing up existing .gitconfig-my to .gitconfig-my.backup"
        mv "$HOME/.gitconfig-my" "$HOME/.gitconfig-my.backup"
    fi
    
    # Create symlinks for main dotfiles
    ln -sf "$DOTFILES_CONFIG_DIR/.zshrc" "$HOME/.zshrc"
    ln -sf "$DOTFILES_CONFIG_DIR/.gitconfig" "$HOME/.gitconfig"
    ln -sf "$DOTFILES_CONFIG_DIR/.aliases" "$HOME/.aliases"
    
    # Copy Git config file for personal projects (not symlinked, so it can be customized)
    if [[ ! -f "$HOME/.gitconfig-my" ]]; then
        cp "$DOTFILES_CONFIG_DIR/.gitconfig-my" "$HOME/.gitconfig-my"
        print_success "Created ~/.gitconfig-my"
    else
        print_info ".gitconfig-my already exists (skipping)"
    fi
    
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
