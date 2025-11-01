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
#   or for specific branch:
#   DOTFILES_BRANCH=fix/minor-adjustments curl -s https://raw.githubusercontent.com/RanielliMontagna/dotfiles/fix/minor-adjustments/bootstrap.sh | bash
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

# Download scripts from GitHub when running via curl | bash
download_scripts_from_github() {
    local branch="${DOTFILES_BRANCH:-main}"
    local base_url="https://raw.githubusercontent.com/RanielliMontagna/dotfiles/${branch}"
    local temp_dir="$HOME/.dotfiles-temp"
    local scripts_dir="$temp_dir/scripts"
    
    print_info "Downloading scripts from GitHub (branch: $branch)..."
    
    # Create temporary directory
    mkdir -p "$scripts_dir"
    
    # List of scripts to download
    local scripts=(
        "scripts/common.sh"
        "scripts/00-customization.sh"
        "scripts/01-essentials.sh"
        "scripts/02-shell.sh"
        "scripts/03-nodejs.sh"
        "scripts/04-editors.sh"
        "scripts/05-docker.sh"
        "scripts/06-java.sh"
        "scripts/07-dev-tools.sh"
        "scripts/08-applications.sh"
        "scripts/09-extras.sh"
    )
    
    # Download each script
    local failed=0
    for script_path in "${scripts[@]}"; do
        local script_name=$(basename "$script_path")
        local script_url="${base_url}/${script_path}"
        local script_file="${scripts_dir}/${script_name}"
        
        print_info "Downloading $script_name..."
        if curl -fsSL --max-time 30 "$script_url" -o "$script_file" 2>/dev/null; then
            chmod +x "$script_file"
            print_success "Downloaded $script_name"
        else
            print_error "Failed to download $script_name from $script_url"
            failed=$((failed + 1))
        fi
    done
    
    if [[ $failed -gt 0 ]]; then
        print_error "Failed to download $failed script(s). Please check your internet connection."
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "$temp_dir"
    return 0
}

# Get the directory where this script is located
# This handles both cases: local execution and curl | bash
get_dotfiles_dir() {
    local script_source="${BASH_SOURCE[0]}"
    
    # If running from a file (local execution)
    if [[ -f "$script_source" ]]; then
        echo "$(cd "$(dirname "$script_source")" && pwd)"
        return 0
    fi
    
    # If running via curl | bash, check current directory first
    if [[ -d "scripts" ]] && [[ -f "bootstrap.sh" ]]; then
        echo "$(pwd)"
        return 0
    fi
    
    # Try to find dotfiles directory in common locations
    local possible_dirs=(
        "$HOME/dotfiles"
        "$HOME/www/my/dotfiles"
        "$(pwd)"
    )
    
    for dir in "${possible_dirs[@]}"; do
        if [[ -d "$dir/scripts" ]] && [[ -f "$dir/bootstrap.sh" ]]; then
            echo "$dir"
            return 0
        fi
    done
    
    # If not found and running via curl | bash, download scripts automatically
    # Check if we're running via curl by seeing if script_source is not a regular file
    # BASH_SOURCE[0] will be something like "/dev/fd/63" when run via pipe
    if [[ ! -f "$script_source" ]] || \
       [[ "$script_source" == *"/dev/fd/"* ]] || \
       [[ "$script_source" == *"/proc/self/"* ]] || \
       [[ "$script_source" == "/dev/stdin" ]] || \
       [[ ! -r "$script_source" ]]; then
        # Running via curl | bash, download scripts
        local temp_dir
        if temp_dir=$(download_scripts_from_github); then
            echo "$temp_dir"
            return 0
        else
            return 1
        fi
    fi
    
    return 1
}

# Initialize colors before get_dotfiles_dir (needed for download messages)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

DOTFILES_DIR="$(get_dotfiles_dir)"
if [[ -z "$DOTFILES_DIR" ]] || [[ ! -d "$DOTFILES_DIR/scripts" ]]; then
    print_error "Cannot find dotfiles directory!"
    echo "" >&2
    echo "Please clone the repository first:" >&2
    echo "  git clone https://github.com/RanielliMontagna/dotfiles.git" >&2
    echo "  cd dotfiles" >&2
    echo "  bash bootstrap.sh" >&2
    echo "" >&2
    echo "Or if you're already in the dotfiles directory, make sure the 'scripts/' folder exists." >&2
    exit 1
fi

# Check if we're using a temporary directory (downloaded from GitHub)
USING_TEMP_DIR=false
if [[ "$DOTFILES_DIR" == "$HOME/.dotfiles-temp" ]]; then
    USING_TEMP_DIR=true
    print_info "Using temporary directory with downloaded scripts"
    print_info "Note: Scripts will be cleaned up after execution"
fi

SCRIPTS_DIR="$DOTFILES_DIR/scripts"

###############################################################################
# Load common functions
###############################################################################

# Source common.sh if available
if [[ -f "$SCRIPTS_DIR/common.sh" ]]; then
    source "$SCRIPTS_DIR/common.sh"
else
    # Fallback print functions if common.sh is not available
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    
    print_info() {
        echo -e "${BLUE}ℹ${NC} $1"
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
fi

###############################################################################
# Helper functions
###############################################################################

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
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
    
    # Verify scripts directory exists
    if [[ ! -d "$SCRIPTS_DIR" ]]; then
        print_error "Scripts directory not found: $SCRIPTS_DIR"
        print_error "Please make sure you've cloned the repository first."
        exit 1
    fi
    
    # Verify essential scripts exist
    local required_scripts=(
        "00-customization.sh"
        "01-essentials.sh"
        "02-shell.sh"
        "03-nodejs.sh"
        "04-editors.sh"
        "05-docker.sh"
        "06-java.sh"
        "07-dev-tools.sh"
        "08-applications.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$SCRIPTS_DIR/$script" ]]; then
            print_error "Required script not found: $SCRIPTS_DIR/$script"
            print_error "Please make sure you've cloned the complete repository."
            exit 1
        fi
    done
    
    # Check OS compatibility
    check_os
    
    # Check internet connectivity before proceeding
    if ! check_internet; then
        print_error "Internet connection is required for installation"
        exit 1
    fi
    
    # Cache sudo password upfront to avoid interruptions during installation
    # This will prompt once at the beginning and cache for ~15 minutes
    print_info "Caching sudo credentials (you'll be asked for your password once)..."
    sudo -v
    
    # Start keeping sudo alive during long installations
    if command -v keep_sudo_alive &> /dev/null || type keep_sudo_alive &> /dev/null 2>&1; then
        keep_sudo_alive
        print_info "Sudo will be renewed automatically during installation"
    fi
    
    # Centralized apt-get update (optimization)
    # Update package lists once at the beginning for all scripts
    if command -v ensure_apt_updated &> /dev/null || type ensure_apt_updated &> /dev/null 2>&1; then
        print_info "Updating package lists (once for all scripts)..."
        ensure_apt_updated
    else
        # Fallback if common.sh not loaded
        print_info "Updating package lists..."
        sudo apt-get update -qq
    fi
    
    # Make sure all scripts are executable
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
    
    # Run installation scripts in order
    # Start with visual customization first (better UX - user sees the system getting beautiful from the start)
    print_header "🎨 Visual Customization (Dark Theme)"
    bash "$SCRIPTS_DIR/00-customization.sh"
    
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
    
    # Clean up temporary directory if we downloaded scripts
    if [[ "$USING_TEMP_DIR" == "true" ]]; then
        print_info "Cleaning up temporary files..."
        rm -rf "$DOTFILES_DIR"
        print_success "Cleanup complete"
    fi
    
    # Show installation summary
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📋 Installation Summary${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
    
    # Collect installed versions
    echo -e "${GREEN}✓ Core Tools:${NC}"
    if command -v git &> /dev/null; then
        echo "  • Git: $(git --version 2>/dev/null | cut -d' ' -f3)"
    fi
    if command -v zsh &> /dev/null; then
        echo "  • Zsh: $(zsh --version 2>/dev/null | cut -d' ' -f2)"
    fi
    if command -v node &> /dev/null; then
        echo "  • Node.js: $(node --version)"
        echo "  • npm: $(npm --version)"
        if command -v yarn &> /dev/null; then
            echo "  • Yarn: $(yarn --version)"
        fi
        if command -v pnpm &> /dev/null; then
            echo "  • pnpm: $(pnpm --version)"
        fi
        if command -v bun &> /dev/null; then
            echo "  • Bun: $(bun --version)"
        fi
    fi
    
    echo -e "\n${GREEN}✓ Code Editors:${NC}"
    if command -v code &> /dev/null; then
        echo "  • VS Code: $(code --version 2>/dev/null | head -n1)"
    fi
    if command -v cursor &> /dev/null || dpkg -l 2>/dev/null | grep -q "^ii.*cursor"; then
        if command -v cursor &> /dev/null; then
            echo "  • Cursor: $(cursor --version 2>/dev/null || echo 'installed')"
        else
            echo "  • Cursor: installed"
        fi
    fi
    
    echo -e "\n${GREEN}✓ Development Tools:${NC}"
    if command -v docker &> /dev/null; then
        echo "  • Docker: $(docker --version 2>/dev/null | cut -d' ' -f3 | cut -d',' -f1)"
    fi
    if command -v java &> /dev/null; then
        echo "  • Java: $(java -version 2>&1 | head -n1 | cut -d'"' -f2)"
    fi
    if command -v sdk &> /dev/null; then
        echo "  • SDKMAN: $(sdk version 2>/dev/null | head -n1 | cut -d' ' -f3)"
    fi
    
    echo -e "\n${GREEN}✓ Applications:${NC}"
    if command -v google-chrome &> /dev/null || command -v chrome &> /dev/null; then
        echo "  • Google Chrome: installed"
    fi
    if command -v brave-browser &> /dev/null; then
        echo "  • Brave Browser: installed"
    fi
    if command -v firefox &> /dev/null; then
        echo "  • Firefox: $(firefox --version 2>/dev/null || echo 'installed')"
    fi
    if command -v spotify &> /dev/null; then
        echo "  • Spotify: installed"
    fi
    if command -v discord &> /dev/null; then
        echo "  • Discord: installed"
    fi
    if command -v nordvpn &> /dev/null; then
        echo "  • NordVPN: installed"
    fi
    if command -v bitwarden &> /dev/null || dpkg -l 2>/dev/null | grep -q "^ii.*bitwarden"; then
        echo "  • Bitwarden: installed"
    fi
    
    echo -e "\n${GREEN}✓ Configuration:${NC}"
    echo "  • Shell: Zsh with Oh My Zsh and Powerlevel10k"
    echo "  • Git: Pre-configured for ~/www/personal/ projects"
    if [[ -d "$HOME/www/personal" ]]; then
        echo "  • Project directory: ~/www/personal/ created"
    fi
    
    # Show next steps
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📌 Next Steps:${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}\n"
    echo "1. Restart your terminal or run: ${GREEN}source ~/.zshrc${NC}"
    echo "2. Powerlevel10k is already configured and ready to use!"
    echo "3. Git is already configured for personal projects in ~/www/personal/"
    echo ""
    print_info "Your personal Git config uses:"
    echo "  • Name: Ranielli Montagna"
    echo "  • Email: raniellimontagna@hotmail.com"
    echo "  • SSH: Enabled for GitHub"
    echo ""
}

# Run main function
main "$@"
