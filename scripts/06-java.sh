#!/usr/bin/env bash

###############################################################################
# 06-java.sh
# 
# Install Java SDK via SDKMAN (Java Version Manager)
# - Installs SDKMAN
# - Installs Java SDK 8, 11, 17, and LTS (21)
# - Sets Java 17 as default
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
    echo -e "${BLUE}[java]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    print_info "Installing Java SDK via SDKMAN..."
    
    # Install SDKMAN for Java version management
    if [[ -d "$HOME/.sdkman" ]]; then
        print_info "SDKMAN is already installed"
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        print_info "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        export SDKMAN_DIR="$HOME/.sdkman"
        [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        print_success "SDKMAN installed"
    fi
    
    # Load SDKMAN
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # Install Java versions
    print_info "Installing Java SDK versions..."
    
    # Java 8
    if sdk list java | grep -q "8.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/8.0"* ]]; then
        print_info "Java 8 already installed"
    else
        print_info "Installing Java 8..."
        sdk install java 8.0.392-tem || sdk install java 8.0.382-tem || sdk install java 8.0.372-tem
        print_success "Java 8 installed"
    fi
    
    # Java 11
    if sdk list java | grep -q "11.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/11.0"* ]]; then
        print_info "Java 11 already installed"
    else
        print_info "Installing Java 11..."
        sdk install java 11.0.21-tem || sdk install java 11.0.20-tem || sdk install java 11.0.19-tem
        print_success "Java 11 installed"
    fi
    
    # Java 17
    if sdk list java | grep -q "17.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/17.0"* ]]; then
        print_info "Java 17 already installed"
    else
        print_info "Installing Java 17..."
        sdk install java 17.0.9-tem || sdk install java 17.0.8-tem || sdk install java 17.0.7-tem
        print_success "Java 17 installed"
    fi
    
    # Java LTS (21 or 17, prefer 21)
    if sdk list java | grep -q "21.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/21.0"* ]]; then
        print_info "Java 21 (LTS) already installed"
    else
        print_info "Installing Java 21 (LTS)..."
        sdk install java 21.0.1-tem || sdk install java 21.0.0-tem || sdk install java 17.0.9-tem
        print_success "Java LTS installed"
    fi
    
    # Set Java 17 as default (most commonly used)
    print_info "Setting Java 17 as default..."
    sdk default java 17.0.9-tem 2>/dev/null || sdk default java 17.0.8-tem 2>/dev/null || true
    
    print_success "Java SDK installed successfully!"
    print_info "SDKMAN is initialized. Use 'sdk use java <version>' to switch Java versions"
    print_info "Default version: Java 17"
}

main "$@"

