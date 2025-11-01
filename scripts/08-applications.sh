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
# - Bitwarden (password manager)
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
fi

# Alias for compatibility
is_installed() {
    is_package_installed "$1"
}

main() {
    print_info "Installing browsers, games, media apps, and VPN..."
    
    # Install Google Chrome
    if command -v google-chrome &> /dev/null || command -v chrome &> /dev/null || is_installed "google-chrome-stable"; then
        print_info "Google Chrome already installed"
    else
        print_info "Installing Google Chrome..."
        
        # Validate architecture (Chrome supports amd64 and arm64)
        if ! is_architecture_supported "amd64" && ! is_architecture_supported "arm64"; then
            print_warning "Chrome may not be available for architecture: $(get_architecture)"
            print_info "Skipping Chrome installation"
        else
            # Download and install Chrome .deb
            CHROME_DEB="/tmp/google-chrome.deb"
            # Chrome URL (Google redirects to correct architecture if needed)
            safe_curl_download_with_cache "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "$CHROME_DEB" 3 300 30
            
            if [[ -f "$CHROME_DEB" ]]; then
                sudo dpkg -i "$CHROME_DEB" || sudo apt-get install -f -y
                rm -f "$CHROME_DEB"
                print_success "Google Chrome installed"
            else
                print_warning "Could not download Chrome. Please install manually from https://www.google.com/chrome/"
            fi
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
        
        # Update and install (force update needed after adding repository)
        if command -v ensure_apt_updated &> /dev/null; then
            ensure_apt_updated true
        else
            sudo apt-get update
        fi
        sudo apt-get install -y brave-browser
        print_success "Brave Browser installed"
    fi
    
    # Install Firefox (check if already installed)
    if command -v firefox &> /dev/null || is_installed "firefox"; then
        print_info "Firefox already installed ($(firefox --version 2>/dev/null || echo 'installed'))"
    else
        print_info "Installing Firefox..."
        if command -v ensure_apt_updated &> /dev/null; then
            ensure_apt_updated
        else
            sudo apt-get update
        fi
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
            if command -v ensure_apt_updated &> /dev/null; then
                ensure_apt_updated
            else
                sudo apt-get update
            fi
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
            # Force update after adding repository
            if command -v ensure_apt_updated &> /dev/null; then
                ensure_apt_updated true
            else
                sudo apt-get update
            fi
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
            safe_curl_download_with_cache "https://discord.com/api/download?platform=linux&format=deb" "$DISCORD_DEB" 3 300 30
            
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
            if command -v ensure_apt_updated &> /dev/null; then
                ensure_apt_updated
            else
                sudo apt-get update
            fi
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
        if command -v ensure_apt_updated &> /dev/null; then
            ensure_apt_updated
        else
            sudo apt-get update || true
        fi
        sudo apt-get install -y curl 2>/dev/null || {
            print_warning "Could not install curl, trying to continue..."
        }
        
        # Download NordVPN installer script first (safer than piping curl to sh)
        print_info "Downloading NordVPN installer..."
        local NORDVPN_INSTALLER="/tmp/nordvpn-install.sh"
        
        # Use safe download with retries
        if safe_curl_download_with_cache "https://downloads.nordcdn.com/apps/linux/install.sh" "$NORDVPN_INSTALLER" 3 300 30; then
            # Make executable
            chmod +x "$NORDVPN_INSTALLER" 2>/dev/null || true
            
            # Run installer with better error handling
            print_info "Running NordVPN installer..."
            if bash "$NORDVPN_INSTALLER" 2>&1; then
                # Wait a moment for installation to complete
                sleep 3
                
                # Verify installation
                if command -v nordvpn &> /dev/null; then
                    print_success "NordVPN installed successfully"
                    print_info "To login to NordVPN, run: nordvpn login"
                    print_info "To connect, run: nordvpn connect"
                    print_warning "Note: You may need to log out and back in for NordVPN to work properly"
                else
                    # Check if package was installed but command not in PATH
                    sleep 2
                    if command -v nordvpn &> /dev/null || is_installed "nordvpn"; then
                        print_success "NordVPN package installed (may need logout/login to activate)"
                        print_info "To login to NordVPN, run: nordvpn login"
                    else
                        print_warning "NordVPN installation completed but nordvpn command not found"
                        print_info "This may be normal - try logging out and back in, then run: nordvpn login"
                    fi
                fi
            else
                print_warning "NordVPN installer script failed to execute properly"
                print_info "You can try installing manually:"
                print_info "  sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)"
                print_info "Or visit: https://nordvpn.com/download/linux/"
            fi
            
            # Cleanup
            rm -f "$NORDVPN_INSTALLER" 2>/dev/null || true
        else
            print_warning "Could not download NordVPN installer script"
            print_info "This might be due to network issues. You can try installing manually:"
            print_info "  sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)"
            print_info "Or visit: https://nordvpn.com/download/linux/"
        fi
    fi
    
    # Install Bitwarden
    if command -v bitwarden &> /dev/null || is_installed "bitwarden"; then
        print_info "Bitwarden already installed"
    else
        print_info "Installing Bitwarden..."
        
        if command -v snap &> /dev/null; then
            sudo snap install bitwarden
            print_success "Bitwarden installed via snap"
        else
            print_warning "Snap not available, trying alternative method..."
            
            # Alternative: Download .deb from Bitwarden (get latest version from GitHub releases)
            BITWARDEN_DEB="/tmp/bitwarden.deb"
            
            # Get latest release URL from GitHub API (looking for desktop Linux .deb)
            if command -v jq &> /dev/null; then
                LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | jq -r '.assets[] | select(.name | contains("desktop") and contains(".deb")) | .browser_download_url' | head -1)
            else
                # Fallback: use grep if jq is not available
                LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/bitwarden/clients/releases/latest | grep -o '"browser_download_url": "[^"]*desktop[^"]*\.deb"' | head -1 | cut -d'"' -f4)
            fi
            
            if [[ -n "$LATEST_RELEASE_URL" ]] && [[ "$LATEST_RELEASE_URL" != "null" ]]; then
                print_info "Downloading Bitwarden from GitHub releases..."
                safe_curl_download_with_cache "$LATEST_RELEASE_URL" "$BITWARDEN_DEB" 3 300 30
                
                if [[ -f "$BITWARDEN_DEB" ]] && [[ -s "$BITWARDEN_DEB" ]]; then
                    sudo dpkg -i "$BITWARDEN_DEB" || sudo apt-get install -f -y
                    rm -f "$BITWARDEN_DEB"
                    print_success "Bitwarden installed"
                else
                    print_warning "Could not download Bitwarden. Please install manually from https://bitwarden.com/download/"
                fi
            else
                print_warning "Could not find Bitwarden download URL. Please install manually from https://bitwarden.com/download/"
            fi
        fi
    fi
    
    print_success "Applications installed successfully!"
}

main "$@"

