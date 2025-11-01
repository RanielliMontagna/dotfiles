#!/usr/bin/env bash

###############################################################################
# 08-applications.sh
# 
# Install browsers, games, media apps, and VPN (always installed)
# - Chrome (latest from Google)
# - Brave Browser (latest)
# - Firefox (ensure installed, usually comes with system)
# - Steam (gaming platform)
# - Spotify (music streaming)
# - Discord (chat and communication)
# - OBS Studio (streaming and recording)
# - NordVPN (VPN service)
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
    echo -e "${BLUE}[applications]${NC} $1"
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
    print_info "Installing browsers, games, media apps, and VPN..."
    
    # Install Google Chrome
    if command -v google-chrome &> /dev/null || command -v chrome &> /dev/null || is_installed "google-chrome-stable"; then
        print_info "Google Chrome already installed"
    else
        print_info "Installing Google Chrome..."
        
        # Download and install Chrome .deb
        CHROME_DEB="/tmp/google-chrome.deb"
        curl -L -o "$CHROME_DEB" "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        
        if [[ -f "$CHROME_DEB" ]]; then
            sudo dpkg -i "$CHROME_DEB" || sudo apt-get install -f -y
            rm -f "$CHROME_DEB"
            print_success "Google Chrome installed"
        else
            print_warning "Could not download Chrome. Please install manually from https://www.google.com/chrome/"
        fi
    fi
    
    # Install Brave Browser
    if command -v brave-browser &> /dev/null || is_installed "brave-browser"; then
        print_info "Brave Browser already installed"
    else
        print_info "Installing Brave Browser..."
        
        # Install via apt repository (recommended method)
        sudo apt-get install -y apt-transport-https curl
        
        # Add Brave GPG key
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        
        # Add Brave repository
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        
        # Update and install
        sudo apt-get update
        sudo apt-get install -y brave-browser
        print_success "Brave Browser installed"
    fi
    
    # Install Firefox (check if already installed)
    if command -v firefox &> /dev/null || is_installed "firefox"; then
        print_info "Firefox already installed ($(firefox --version 2>/dev/null || echo 'installed'))"
    else
        print_info "Installing Firefox..."
        sudo apt-get update
        sudo apt-get install -y firefox
        print_success "Firefox installed"
    fi
    
    # Install Steam
    if command -v steam &> /dev/null || is_installed "steam-launcher"; then
        print_info "Steam already installed"
    else
        print_info "Installing Steam..."
        
        # Check if snap is available
        if command -v snap &> /dev/null; then
            sudo snap install steam --classic
            print_success "Steam installed via snap"
        else
            print_info "Installing Steam via apt..."
            sudo apt-get update
            sudo apt-get install -y steam-launcher
            print_success "Steam installed"
        fi
    fi
    
    # Install Spotify
    if command -v spotify &> /dev/null || is_installed "spotify-client"; then
        print_info "Spotify already installed"
    else
        print_info "Installing Spotify..."
        
        if command -v snap &> /dev/null; then
            sudo snap install spotify
            print_success "Spotify installed via snap"
        else
            print_warning "Snap not available, trying alternative method..."
            
            # Alternative: Add Spotify repository
            curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/spotify.gpg
            echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt-get update
            sudo apt-get install -y spotify-client
            print_success "Spotify installed"
        fi
    fi
    
    # Install Discord
    if command -v discord &> /dev/null || is_installed "discord"; then
        print_info "Discord already installed"
    else
        print_info "Installing Discord..."
        
        if command -v snap &> /dev/null; then
            sudo snap install discord
            print_success "Discord installed via snap"
        else
            print_warning "Snap not available, trying alternative method..."
            
            # Alternative: Download .deb from Discord
            DISCORD_DEB="/tmp/discord.deb"
            curl -L -o "$DISCORD_DEB" "https://discord.com/api/download?platform=linux&format=deb"
            
            if [[ -f "$DISCORD_DEB" ]]; then
                sudo dpkg -i "$DISCORD_DEB" || sudo apt-get install -f -y
                rm -f "$DISCORD_DEB"
                print_success "Discord installed"
            else
                print_warning "Could not download Discord. Please install manually from https://discord.com/download"
            fi
        fi
    fi
    
    # Install OBS Studio
    if command -v obs &> /dev/null || is_installed "obs-studio"; then
        print_info "OBS Studio already installed"
    else
        print_info "Installing OBS Studio..."
        
        if command -v snap &> /dev/null; then
            sudo snap install obs-studio
            print_success "OBS Studio installed via snap"
        else
            print_warning "Snap not available, installing via apt..."
            sudo apt-get update
            sudo apt-get install -y obs-studio
            print_success "OBS Studio installed"
        fi
    fi
    
    # Install NordVPN
    if command -v nordvpn &> /dev/null || is_installed "nordvpn"; then
        print_info "NordVPN already installed ($(nordvpn --version 2>/dev/null | head -1 || echo 'installed'))"
    else
        print_info "Installing NordVPN..."
        
        # Install dependencies
        sudo apt-get update
        sudo apt-get install -y curl
        
        # Download and run NordVPN installer
        print_info "Downloading NordVPN installer..."
        
        # The installer script from NordVPN (official method)
        # This downloads and executes the installer in one step
        if sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh); then
            # Wait a moment for installation to complete
            sleep 2
            
            # Verify installation
            if command -v nordvpn &> /dev/null; then
                print_success "NordVPN installed"
                print_info "To login to NordVPN, run: nordvpn login"
                print_info "To connect, run: nordvpn connect"
                print_warning "Note: You may need to log out and back in for NordVPN to work properly"
            else
                print_warning "NordVPN installation may have failed. Please check manually."
                print_info "You can try: sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)"
            fi
        else
            print_warning "Could not install NordVPN automatically. Please install manually from https://nordvpn.com/download/linux/"
        fi
    fi
    
    print_success "Applications installed successfully!"
}

main "$@"

