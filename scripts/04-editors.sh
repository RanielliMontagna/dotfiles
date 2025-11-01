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
        echo -e "${BLUE}[editors]${NC} $1"
    }
    
    print_success() {
        echo -e "${GREEN}✓${NC} $1"
    }
    
    print_warning() {
        echo -e "${YELLOW}⚠${NC} $1"
    }
fi

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
    # Check if Cursor editor is installed (be specific - avoid false positives from system cursor packages)
    # First check if the cursor package is installed via dpkg (most reliable)
    CURSOR_PACKAGE_INSTALLED=false
    if dpkg -l cursor 2>/dev/null | grep -qE "^ii[[:space:]]+cursor[[:space:]]"; then
        CURSOR_PACKAGE_INSTALLED=true
    fi
    
    # Check if cursor command exists
    CURSOR_CMD_EXISTS=false
    if command -v cursor &> /dev/null 2>&1; then
        CURSOR_CMD=$(command -v cursor)
        # If it's a real file (not just an alias), it's installed
        if [[ -f "$CURSOR_CMD" ]] && [[ -x "$CURSOR_CMD" ]]; then
            CURSOR_CMD_EXISTS=true
        # If it's an alias but package is installed, that's OK
        elif [[ "$CURSOR_PACKAGE_INSTALLED" == "true" ]]; then
            CURSOR_CMD_EXISTS=true
        fi
    fi
    
    # Cursor is considered installed if package is installed OR command exists as executable
    if [[ "$CURSOR_PACKAGE_INSTALLED" == "true" ]] || [[ "$CURSOR_CMD_EXISTS" == "true" ]]; then
        if command -v cursor &> /dev/null 2>&1; then
            CURSOR_VERSION=$(cursor --version 2>/dev/null | head -1 || echo "")
            if [[ -n "$CURSOR_VERSION" ]]; then
                print_info "Cursor already installed ($CURSOR_VERSION)"
            else
                print_info "Cursor already installed"
            fi
        elif [[ "$CURSOR_PACKAGE_INSTALLED" == "true" ]]; then
            print_info "Cursor package installed (command may not be in PATH yet)"
            print_info "Try restarting your terminal or run: export PATH=\"/usr/bin:\$PATH\""
        fi
    else
        print_info "Installing Cursor..."
        
        # Get architecture
        ARCH=$(dpkg --print-architecture)
        CURSOR_TEMP="/tmp/cursor.deb"
        
        print_info "Downloading Cursor for ${ARCH}..."
        
        # Try to download Cursor .deb package using official download methods
        # Based on https://cursor.com/downloads and official API
        DOWNLOADED=false
        
        # Determine architecture for download URL
        local download_arch="amd64"
        if [[ "$ARCH" == "arm64" ]] || [[ "$ARCH" == "aarch64" ]]; then
            download_arch="arm64"
        fi
        
        # Method 1: Try official API endpoint (using version 2.0 for latest)
        # API format: https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.0
        if [[ "$download_arch" == "amd64" ]]; then
            if safe_curl_download_with_cache "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.0" "$CURSOR_TEMP" 3 300 30; then
                # Verify it's a valid .deb file (at least 1MB)
                if [[ -f "$CURSOR_TEMP" ]] && [[ -s "$CURSOR_TEMP" ]] && [[ $(stat -f%z "$CURSOR_TEMP" 2>/dev/null || stat -c%s "$CURSOR_TEMP" 2>/dev/null || echo 0) -gt 1048576 ]]; then
                    DOWNLOADED=true
                fi
            fi
        elif [[ "$download_arch" == "arm64" ]]; then
            if safe_curl_download_with_cache "https://api2.cursor.sh/updates/download/golden/linux-arm64-deb/cursor/2.0" "$CURSOR_TEMP" 3 300 30; then
                if [[ -f "$CURSOR_TEMP" ]] && [[ -s "$CURSOR_TEMP" ]] && [[ $(stat -f%z "$CURSOR_TEMP" 2>/dev/null || stat -c%s "$CURSOR_TEMP" 2>/dev/null || echo 0) -gt 1048576 ]]; then
                    DOWNLOADED=true
                fi
            fi
        fi
        
        # Method 2: If API method failed, try direct download from downloads.cursor.com
        # Fallback to known stable version link (may be updated periodically)
        if [[ "$DOWNLOADED" == "false" ]] && [[ "$download_arch" == "amd64" ]]; then
            print_info "Trying alternative download URL (direct link)..."
            rm -f "$CURSOR_TEMP"
            if safe_curl_download_with_cache "https://downloads.cursor.com/production/45fd70f3fe72037444ba35c9e51ce86a1977ac11/linux/x64/deb/amd64/deb/cursor_2.0.34_amd64.deb" "$CURSOR_TEMP" 3 300 30; then
                if [[ -f "$CURSOR_TEMP" ]] && [[ -s "$CURSOR_TEMP" ]] && [[ $(stat -f%z "$CURSOR_TEMP" 2>/dev/null || stat -c%s "$CURSOR_TEMP" 2>/dev/null || echo 0) -gt 1048576 ]]; then
                    DOWNLOADED=true
                fi
            fi
        elif [[ "$DOWNLOADED" == "false" ]] && [[ "$download_arch" == "arm64" ]]; then
            print_info "Trying alternative download URL (direct link)..."
            rm -f "$CURSOR_TEMP"
            if safe_curl_download_with_cache "https://downloads.cursor.com/production/45fd70f3fe72037444ba35c9e51ce86a1977ac11/linux/arm64/deb/arm64/deb/cursor_2.0.34_arm64.deb" "$CURSOR_TEMP" 3 300 30; then
                if [[ -f "$CURSOR_TEMP" ]] && [[ -s "$CURSOR_TEMP" ]] && [[ $(stat -f%z "$CURSOR_TEMP" 2>/dev/null || stat -c%s "$CURSOR_TEMP" 2>/dev/null || echo 0) -gt 1048576 ]]; then
                    DOWNLOADED=true
                fi
            fi
        fi
        
        # Install if download succeeded
        if [[ "$DOWNLOADED" == "true" ]] && [[ -f "$CURSOR_TEMP" ]] && [[ -s "$CURSOR_TEMP" ]]; then
            print_info "Installing Cursor package..."
            
            # Pre-configure debconf to answer "yes" to repository question
            # This prevents the interactive prompt during installation
            echo "cursor cursor/apt_repo boolean true" | sudo debconf-set-selections 2>/dev/null || true
            
            # Install with dependency resolution (non-interactive)
            if sudo DEBIAN_FRONTEND=noninteractive dpkg -i "$CURSOR_TEMP" 2>&1; then
                rm -f "$CURSOR_TEMP"
                print_success "Cursor installed successfully"
            else
                # Install dependencies and retry
                print_info "Installing missing dependencies..."
                sudo DEBIAN_FRONTEND=noninteractive apt-get install -f -y
                if sudo DEBIAN_FRONTEND=noninteractive dpkg -i "$CURSOR_TEMP" 2>&1; then
                    rm -f "$CURSOR_TEMP"
                    print_success "Cursor installed successfully"
                else
                    rm -f "$CURSOR_TEMP"
                    print_warning "Failed to install Cursor package"
                    print_info "Please install Cursor manually from https://cursor.com/download"
                fi
            fi
            
            # Verify installation
            sleep 1
            if ! command -v cursor &> /dev/null && ! dpkg -l 2>/dev/null | grep -q "^ii.*cursor"; then
                print_warning "Cursor package installed but command may not be in PATH yet"
                print_info "Try logging out and back in, or restart your terminal"
            fi
        else
            rm -f "$CURSOR_TEMP"
            print_warning "Could not download Cursor automatically"
            print_info "Please download and install Cursor manually:"
            print_info "  1. Visit https://cursor.com/download"
            print_info "  2. Download the .deb package for Linux"
            print_info "  3. Run: sudo dpkg -i cursor.deb"
            print_info "  4. If dependencies are missing: sudo apt-get install -f -y"
            print_info "After manual installation, run this script again to verify"
        fi
    fi
    
    print_success "Code editors installed successfully!"
}

main "$@"

