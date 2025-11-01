#!/usr/bin/env bash

###############################################################################
# common.sh
# 
# Shared functions for all installation scripts
# Provides: download helpers, connectivity checks, sudo management, etc.
#
# This file should be sourced by all scripts:
#   source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

###############################################################################
# Internet Connectivity
###############################################################################

# Check if internet connection is available
check_internet() {
    print_info "Checking internet connectivity..."
    
    # Try multiple DNS servers with short timeout
    if ping -c 1 -W 5 8.8.8.8 &>/dev/null || \
       ping -c 1 -W 5 1.1.1.1 &>/dev/null || \
       ping -c 1 -W 5 208.67.222.222 &>/dev/null; then
        print_success "Internet connection detected"
        return 0
    fi
    
    print_error "No internet connection detected"
    print_warning "Please check your network connection and try again"
    return 1
}

###############################################################################
# Sudo Management
###############################################################################

# Keep sudo alive during long-running scripts
# This function runs in background and renews sudo periodically
keep_sudo_alive() {
    # Only start if not already running
    if pgrep -f "keep_sudo_alive" > /dev/null; then
        return 0
    fi
    
    (
        while true; do
            # Try to renew sudo (non-interactive, won't prompt)
            sudo -n true 2>/dev/null || break
            sleep 60
            # Exit if parent process is dead
            kill -0 "$$" 2>/dev/null || exit
        done
    ) &
    
    # Store PID for potential cleanup
    SUDO_KEEPALIVE_PID=$!
    export SUDO_KEEPALIVE_PID
}

###############################################################################
# Download Functions with Timeout and Retry
###############################################################################

# Safe download with timeout, retry, and error handling
# Usage: safe_download <url> <output_file> [max_retries] [timeout_seconds]
safe_download() {
    local url="$1"
    local output_file="$2"
    local max_retries="${3:-3}"
    local timeout="${4:-300}"
    local connect_timeout="${5:-30}"
    
    local retry_count=0
    local retry_delay=5
    
    while [[ $retry_count -lt $max_retries ]]; do
        # Use curl if available (preferred), fallback to wget
        if command -v curl &> /dev/null; then
            if curl -L \
                --max-time "$timeout" \
                --connect-timeout "$connect_timeout" \
                --retry "$max_retries" \
                --retry-delay "$retry_delay" \
                --progress-bar \
                --fail \
                --silent \
                --show-error \
                -o "$output_file" \
                "$url"; then
                print_success "Downloaded: $(basename "$output_file")"
                return 0
            fi
        elif command -v wget &> /dev/null; then
            if wget \
                --timeout="$timeout" \
                --tries="$max_retries" \
                --wait="$retry_delay" \
                --quiet \
                --show-progress \
                -O "$output_file" \
                "$url"; then
                print_success "Downloaded: $(basename "$output_file")"
                return 0
            fi
        else
            print_error "Neither curl nor wget is available"
            return 1
        fi
        
        retry_count=$((retry_count + 1))
        if [[ $retry_count -lt $max_retries ]]; then
            print_warning "Download failed, retrying ($retry_count/$max_retries)..."
            sleep "$retry_delay"
        fi
    done
    
    print_error "Failed to download after $max_retries attempts: $url"
    return 1
}

# Download using curl (for cases where we need curl-specific features)
# Usage: safe_curl_download <url> <output_file> [max_retries] [timeout_seconds]
safe_curl_download() {
    local url="$1"
    local output_file="$2"
    local max_retries="${3:-3}"
    local timeout="${4:-300}"
    local connect_timeout="${5:-30}"
    
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        return 1
    fi
    
    local retry_count=0
    local retry_delay=5
    
    while [[ $retry_count -lt $max_retries ]]; do
        if curl -L \
            --max-time "$timeout" \
            --connect-timeout "$connect_timeout" \
            --retry "$max_retries" \
            --retry-delay "$retry_delay" \
            --progress-bar \
            --fail \
            --silent \
            --show-error \
            -o "$output_file" \
            "$url"; then
            print_success "Downloaded: $(basename "$output_file")"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [[ $retry_count -lt $max_retries ]]; then
            print_warning "Download failed, retrying ($retry_count/$max_retries)..."
            sleep "$retry_delay"
        fi
    done
    
    print_error "Failed to download after $max_retries attempts: $url"
    return 1
}

# Download using wget (for cases where we need wget-specific features)
# Usage: safe_wget_download <url> <output_file> [max_retries] [timeout_seconds]
safe_wget_download() {
    local url="$1"
    local output_file="$2"
    local max_retries="${3:-3}"
    local timeout="${4:-300}"
    
    if ! command -v wget &> /dev/null; then
        print_error "wget is required but not installed"
        return 1
    fi
    
    if wget \
        --timeout="$timeout" \
        --tries="$max_retries" \
        --quiet \
        --show-progress \
        -O "$output_file" \
        "$url"; then
        print_success "Downloaded: $(basename "$output_file")"
        return 0
    fi
    
    print_error "Failed to download: $url"
    return 1
}

###############################################################################
# Installation Helpers
###############################################################################

# Check if a command is available
is_command_available() {
    command -v "$1" &> /dev/null
}

# Check if a package is installed (via dpkg)
is_package_installed() {
    dpkg -l "$1" 2>/dev/null | grep -qE "^ii[[:space:]]+$1[[:space:]]"
}

# Check if a directory exists
is_directory() {
    [[ -d "$1" ]]
}

# Check if a file exists
is_file() {
    [[ -f "$1" ]]
}

