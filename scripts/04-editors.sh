#!/usr/bin/env bash

###############################################################################
# 04-editors.sh
# 
# Install code editors (always installed)
# - VS Code (latest stable from Microsoft repository)
# - Cursor (latest from official website)
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
    echo -e "${BLUE}[editors]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    print_info "Installing code editors..."
    
    # VS Code
    if command -v code &> /dev/null; then
        print_info "VS Code already installed ($(code --version | head -n1))"
    else
        print_info "Installing VS Code..."
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        rm -f packages.microsoft.gpg
        sudo apt update
        sudo apt install -y code
        print_success "VS Code installed"
    fi
    
    # Cursor
    if command -v cursor &> /dev/null; then
        print_info "Cursor already installed ($(cursor --version 2>/dev/null || echo 'installed'))"
    else
        print_info "Installing Cursor..."
        
        # Get architecture
        ARCH=$(dpkg --print-architecture)
        
        # Cursor provides .deb packages for amd64, arm64, armhf
        # The downloader redirects to the latest version
        CURSOR_TEMP="/tmp/cursor.deb"
        
        print_info "Downloading Cursor for ${ARCH}..."
        
        # Download Cursor .deb package
        # The downloader.cursor.sh/linux/deb endpoint redirects to the latest .deb
        if curl -L -f -o "$CURSOR_TEMP" "https://downloader.cursor.sh/linux/deb" 2>/dev/null; then
            print_info "Installing Cursor package..."
            sudo dpkg -i "$CURSOR_TEMP" 2>/dev/null || {
                # If dependencies are missing, install them
                sudo apt-get install -f -y
                sudo dpkg -i "$CURSOR_TEMP"
            }
            rm -f "$CURSOR_TEMP"
            print_success "Cursor installed"
        else
            print_warning "Automatic download failed. Trying alternative method..."
            
            # Alternative: Try to get direct download link
            # Check if we can determine the latest version
            if curl -L -f -o "$CURSOR_TEMP" "https://downloader.cursor.sh/linux/appImage/x64" 2>/dev/null || \
               curl -L -f -o "$CURSOR_TEMP" "https://downloader.cursor.sh/linux/x64" 2>/dev/null; then
                print_info "Installing downloaded Cursor..."
                if file "$CURSOR_TEMP" | grep -q "Debian binary package"; then
                    sudo dpkg -i "$CURSOR_TEMP" || sudo apt-get install -f -y
                    rm -f "$CURSOR_TEMP"
                    print_success "Cursor installed"
                else
                    rm -f "$CURSOR_TEMP"
                    print_warning "Downloaded file is not a valid .deb package"
                    print_info "Please install Cursor manually from https://cursor.com"
                    print_info "After installation, run this script again to verify"
                fi
            else
                print_warning "Could not download Cursor automatically"
                print_info "Please download and install Cursor manually from: https://cursor.com"
                print_info "After manual installation, run this script again to verify"
            fi
        fi
    fi
    
    print_success "Code editors installed successfully!"
}

main "$@"

