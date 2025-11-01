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
    
    # Helper function to install Java version non-interactively
    install_java_version() {
        local version_pattern=$1
        shift
        local versions=("$@")
        
        if sdk list java | grep -q "${version_pattern}.*installed" || [[ -d "$HOME/.sdkman/candidates/java/${version_pattern}"* ]]; then
            return 0  # Already installed
        fi
        
        for version in "${versions[@]}"; do
            print_info "Attempting to install Java ${version}..."
            
            # SDKMAN asks "Do you want java X to be set as default? (Y/n):"
            # We need to answer "n" to skip setting as default (we'll set it manually at the end)
            # Use printf to send "n" followed by newline when the prompt appears
            local install_output
            install_output=$(printf "n\n" | sdk install java "$version" 2>&1)
            local install_status=$?
            
            # Show any errors (but not the full verbose output)
            if echo "$install_output" | grep -qiE "(not found|not available|invalid|cannot find|unable to)"; then
                # Version doesn't exist or is unavailable, try next
                continue
            fi
            
            # Check if there's a real error (not just warnings)
            if [[ $install_status -ne 0 ]] && echo "$install_output" | grep -qiE "error|failed"; then
                # Installation failed, try next version
                continue
            fi
            
            # Give SDKMAN time to update its state after installation
            # Installation can take time, so we wait a bit
            sleep 4
            
            # Check if installation was successful by verifying it's in the installed list
            # Use a pattern match that's more flexible
            local installed_versions
            installed_versions=$(sdk list java | grep -E "${version_pattern}.*installed" || true)
            
            if [[ -n "$installed_versions" ]]; then
                # Found installed version matching pattern
                return 0
            fi
            
            # Also check if the directory exists as fallback (SDKMAN uses exact version names)
            if [[ -d "$HOME/.sdkman/candidates/java/${version}" ]]; then
                return 0
            fi
            
            # Check for any directory matching the major version pattern
            if ls -d "$HOME/.sdkman/candidates/java/${version_pattern}"* 2>/dev/null | head -1 | grep -q .; then
                return 0
            fi
            
            # If install_status is 0 but not found, wait a bit more (SDKMAN may need time to update)
            if [[ $install_status -eq 0 ]]; then
                sleep 3
                # Try checking again
                installed_versions=$(sdk list java | grep -E "${version_pattern}.*installed" || true)
                if [[ -n "$installed_versions" ]] || [[ -d "$HOME/.sdkman/candidates/java/${version}" ]]; then
                    return 0
                fi
            fi
            # If this version doesn't exist or failed, try next
        done
        return 1
    }
    
    # Java 8
    if sdk list java | grep -q "8.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/8.0"* ]]; then
        print_info "Java 8 already installed"
    else
        print_info "Installing Java 8..."
        # Try specific versions first, then fallback to generic pattern
        if install_java_version "8.0" "8.0.392-tem" "8.0.382-tem" "8.0.372-tem"; then
            print_success "Java 8 installed"
        elif printf "n\n" | sdk install java 8-tem 2>&1 | grep -q "installed"; then
            sleep 2
            if sdk list java | grep -q "8.0.*installed"; then
                print_success "Java 8 installed"
            else
                print_warning "Failed to install Java 8, continuing..."
            fi
        else
            print_warning "Failed to install Java 8, continuing..."
        fi
    fi
    
    # Java 11
    if sdk list java | grep -q "11.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/11.0"* ]]; then
        print_info "Java 11 already installed"
    else
        print_info "Installing Java 11..."
        # Try specific versions first, then fallback to generic pattern
        if install_java_version "11.0" "11.0.21-tem" "11.0.20-tem" "11.0.19-tem"; then
            print_success "Java 11 installed"
        elif printf "n\n" | sdk install java 11-tem 2>&1 | grep -q "installed"; then
            sleep 2
            if sdk list java | grep -q "11.0.*installed"; then
                print_success "Java 11 installed"
            else
                print_warning "Failed to install Java 11, continuing..."
            fi
        else
            print_warning "Failed to install Java 11, continuing..."
        fi
    fi
    
    # Java 17
    if sdk list java | grep -q "17.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/17.0"* ]]; then
        print_info "Java 17 already installed"
    else
        print_info "Installing Java 17..."
        # Try specific versions first, then fallback to generic pattern
        if install_java_version "17.0" "17.0.9-tem" "17.0.8-tem" "17.0.7-tem"; then
            print_success "Java 17 installed"
        elif printf "n\n" | sdk install java 17-tem 2>&1 | grep -q "installed"; then
            sleep 2
            if sdk list java | grep -q "17.0.*installed"; then
                print_success "Java 17 installed"
            else
                print_warning "Failed to install Java 17, continuing..."
            fi
        else
            print_warning "Failed to install Java 17, continuing..."
        fi
    fi
    
    # Java LTS (21 or 17, prefer 21)
    if sdk list java | grep -q "21.0.*installed" || [[ -d "$HOME/.sdkman/candidates/java/21.0"* ]]; then
        print_info "Java 21 (LTS) already installed"
    else
        print_info "Installing Java 21 (LTS)..."
        # Try specific versions first, then fallback to generic pattern
        if install_java_version "21.0" "21.0.1-tem" "21.0.0-tem"; then
            print_success "Java 21 LTS installed"
        elif printf "n\n" | sdk install java 21-tem 2>&1 | grep -q "installed"; then
            sleep 2
            if sdk list java | grep -q "21.0.*installed"; then
                print_success "Java 21 LTS installed"
            else
                print_warning "Failed to install Java 21, continuing..."
            fi
        else
            print_warning "Failed to install Java 21, continuing..."
        fi
    fi
    
    # Set Java 17 as default (most commonly used)
    # Try to find the actual installed version first
    print_info "Setting Java 17 as default..."
    local java17_version
    java17_version=$(sdk list java | grep -E "17\.0\..*-tem.*installed" | head -1 | awk '{print $NF}' | tr -d '|' | xargs) || true
    
    if [[ -n "$java17_version" ]]; then
        sdk default java "$java17_version" 2>/dev/null || true
    else
        # Fallback to common versions
        sdk default java 17.0.9-tem 2>/dev/null || \
        sdk default java 17.0.8-tem 2>/dev/null || \
        sdk default java 17.0.7-tem 2>/dev/null || true
    fi
    
    print_success "Java SDK installed successfully!"
    print_info "SDKMAN is initialized. Use 'sdk use java <version>' to switch Java versions"
    print_info "Default version: Java 17"
}

main "$@"

