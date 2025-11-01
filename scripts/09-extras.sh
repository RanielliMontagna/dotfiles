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
        echo -e "${BLUE}[extras]${NC} $1"
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

is_installed() {
    dpkg -l "$1" 2>/dev/null | grep -q ^ii
}

main() {
    print_info "Installing extra development tools..."
    
    # Update package lists (use centralized function if available)
    if command -v ensure_apt_updated &> /dev/null; then
        ensure_apt_updated
    else
        sudo apt-get update || print_warning "Package list update had warnings, but continuing..."
    fi
    
    # Python 3 and pip (Ubuntu includes Python 3, but ensure pip is installed)
    if command -v python3 &> /dev/null; then
        print_info "Python3 is already installed ($(python3 --version))"
    else
        print_info "Installing Python3..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-pip python3-venv; then
            print_success "Python3 installed"
        else
            print_warning "Failed to install Python3, but continuing..."
        fi
    fi
    
    if command -v pip3 &> /dev/null; then
        print_info "pip3 is already installed"
    else
        print_info "Installing pip3..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip; then
            print_success "pip3 installed"
        else
            print_warning "Failed to install pip3, but continuing..."
        fi
    fi
    
    # Git extras and tools
    print_info "Installing Git extras..."
    if is_installed "git-lfs"; then
        print_info "git-lfs already installed"
    else
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git-lfs; then
            git lfs install 2>/dev/null || true
            print_success "git-lfs installed"
        else
            print_warning "Failed to install git-lfs, but continuing..."
        fi
    fi
    
    # HTTPie - user-friendly HTTP client
    if command -v http &> /dev/null; then
        print_info "HTTPie already installed"
    else
        print_info "Installing HTTPie..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y httpie; then
            print_success "HTTPie installed"
        else
            print_warning "Failed to install HTTPie, but continuing..."
        fi
    fi
    
    # GitHub CLI
    if command -v gh &> /dev/null; then
        print_info "GitHub CLI already installed ($(gh --version | head -n1))"
    else
        print_info "Installing GitHub CLI..."
        
        # Ensure curl is installed
        if ! command -v curl &> /dev/null; then
            print_info "Installing curl..."
            sudo apt-get install -y curl || print_error "Failed to install curl"
        fi
        
        # Download GitHub CLI GPG key with retry
        print_info "Adding GitHub CLI GPG key..."
        local gpg_key_installed=false
        local gpg_retries=0
        local max_gpg_retries=3
        
        while [[ $gpg_retries -lt $max_gpg_retries ]] && [[ "$gpg_key_installed" == "false" ]]; do
            if command -v safe_curl_download &> /dev/null; then
                # Use common.sh function if available
                local gpg_temp="/tmp/githubcli-archive-keyring.gpg"
                if safe_curl_download "https://cli.github.com/packages/githubcli-archive-keyring.gpg" "$gpg_temp" 3 60 30; then
                    sudo cp "$gpg_temp" /usr/share/keyrings/githubcli-archive-keyring.gpg
                    rm -f "$gpg_temp"
                    gpg_key_installed=true
                else
                    gpg_retries=$((gpg_retries + 1))
                    if [[ $gpg_retries -lt $max_gpg_retries ]]; then
                        print_warning "Failed to download GPG key, retrying ($gpg_retries/$max_gpg_retries)..."
                        sleep 2
                    fi
                fi
            else
                # Fallback to direct curl
                if curl -fsSL --max-time 60 --connect-timeout 30 --retry 3 \
                    "https://cli.github.com/packages/githubcli-archive-keyring.gpg" | \
                    sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null && \
                    [[ -f /usr/share/keyrings/githubcli-archive-keyring.gpg ]]; then
                    gpg_key_installed=true
                else
                    gpg_retries=$((gpg_retries + 1))
                    if [[ $gpg_retries -lt $max_gpg_retries ]]; then
                        print_warning "Failed to download GPG key, retrying ($gpg_retries/$max_gpg_retries)..."
                        sleep 2
                    fi
                fi
            fi
        done
        
        if [[ "$gpg_key_installed" == "false" ]]; then
            print_error "Failed to download GitHub CLI GPG key after $max_gpg_retries attempts"
            print_info "Please check your internet connection and try again"
            print_warning "Skipping GitHub CLI installation"
        else
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            print_success "GitHub CLI GPG key added"
            
            # Add repository
            print_info "Adding GitHub CLI repository..."
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
                sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            print_success "GitHub CLI repository added"
            
            # Force update after adding repository
            print_info "Updating package lists with GitHub CLI repository..."
            if command -v ensure_apt_updated &> /dev/null; then
                if ! ensure_apt_updated true; then
                    print_warning "Package list update had warnings, but continuing..."
                fi
            else
                sudo apt-get update || print_warning "Package list update had warnings, but continuing..."
            fi
            
            # Install GitHub CLI
            print_info "Installing GitHub CLI..."
            if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gh; then
                print_success "GitHub CLI installed"
            else
                print_error "Failed to install GitHub CLI"
                print_info "This might be due to:"
                print_info "  1. Package availability issues"
                print_info "  2. Network problems"
                print_info "  3. Dependency conflicts"
                print_info ""
                print_info "Try running manually:"
                print_info "  sudo apt-get update"
                print_info "  sudo apt-get install -y gh"
                print_warning "Skipping GitHub CLI installation"
            fi
        fi
    fi
    
    # PostgreSQL client
    if command -v psql &> /dev/null; then
        print_info "PostgreSQL client already installed"
    else
        print_info "Installing PostgreSQL client..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-client; then
            print_success "PostgreSQL client installed"
        else
            print_warning "Failed to install PostgreSQL client, but continuing..."
        fi
    fi
    
    # SQLite
    if command -v sqlite3 &> /dev/null; then
        print_info "SQLite already installed"
    else
        print_info "Installing SQLite..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sqlite3; then
            print_success "SQLite installed"
        else
            print_warning "Failed to install SQLite, but continuing..."
        fi
    fi
    
    # Redis CLI
    if command -v redis-cli &> /dev/null; then
        print_info "Redis CLI already installed"
    else
        print_info "Installing Redis CLI..."
        if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y redis-tools; then
            print_success "Redis CLI installed"
        else
            print_warning "Failed to install Redis CLI, but continuing..."
        fi
    fi
    
    # Clean up (optional, don't fail if it errors)
    print_info "Cleaning up..."
    sudo apt-get autoremove -y 2>/dev/null || true
    sudo apt-get autoclean -y 2>/dev/null || true
    
    print_success "Extra tools installation completed!"
    print_info "Some packages may have failed to install due to network/repository issues"
    print_info "You can re-run this script to retry failed installations"
}

main "$@"
