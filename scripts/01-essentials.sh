#!/usr/bin/env bash

###############################################################################
# 01-essentials.sh
# 
# Install essential development tools and dependencies
# - Updates system packages
# - Installs build essentials, git, curl, wget, etc.
# - All packages are kept up-to-date using apt
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
    NC='\033[0m'
    
    print_info() {
        echo -e "${BLUE}[essentials]${NC} $1"
    }
    
    print_success() {
        echo -e "${GREEN}✓${NC} $1"
    }
    
    print_error() {
        echo -e "\033[0;31m✗\033[0m $1"
    }
fi

# Check if package is installed
is_installed() {
    local pkg="$1"
    if ! command -v dpkg >/dev/null 2>&1; then
        return 1
    fi
    dpkg -l "$pkg" 2>/dev/null | grep -q "^ii" || return 1
}

install_if_missing() {
    if is_installed "$1"; then
        print_info "$1 is already installed"
    else
        print_info "Installing $1..."
        sudo apt-get install -y "$1"
        print_success "$1 installed"
    fi
}

main() {
    # Verify required commands exist
    if ! command -v sudo >/dev/null 2>&1; then
        print_error "sudo is not installed or not in PATH"
        exit 1
    fi
    if ! command -v apt-get >/dev/null 2>&1; then
        print_error "apt-get is not installed or not in PATH"
        exit 1
    fi
    if ! command -v dpkg >/dev/null 2>&1; then
        print_error "dpkg is not installed or not in PATH"
        exit 1
    fi
    
    # Use centralized apt update (optimization)
    if command -v ensure_apt_updated &> /dev/null; then
        ensure_apt_updated
    else
        # Fallback if common.sh not loaded
        print_info "Updating package lists..."
        sudo apt-get update
    fi
    
    print_info "Upgrading existing packages..."
    sudo apt-get upgrade -y
    
    # Essential packages
    PACKAGES=(
        "build-essential"   # Compiler and build tools
        "git"               # Version control
        "curl"              # Transfer data from URLs
        "wget"              # Download files
        "ca-certificates"   # SSL certificates
        "gnupg"             # GNU Privacy Guard
        "lsb-release"       # LSB version reporting
        "software-properties-common"  # Manage repositories
        "apt-transport-https"  # HTTPS support for apt
        "unzip"             # Unzip files
        "zip"               # Zip files
        "tree"              # Display directory structure
        "htop"              # Interactive process viewer
        "lm-sensors"        # Hardware monitoring (temperature, voltage)
        "nvtop"             # GPU monitoring (NVIDIA)
        "nano"              # Text editor
        "tmux"              # Terminal multiplexer
        "jq"                # JSON processor
        "net-tools"         # Network tools (ifconfig, netstat, route)
        "ripgrep"           # Fast grep alternative
        "bat"               # Cat with syntax highlighting
        "fd-find"           # Fast find alternative
        "fzf"               # Fuzzy finder
        "gparted"           # Partition editor (GUI)
    )
    
    print_info "Installing essential packages..."
    for package in "${PACKAGES[@]}"; do
        install_if_missing "$package"
    done
    
    # Clean up
    print_info "Cleaning up..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean -y
    
    print_success "Essential tools installed successfully!"
}

main "$@"
