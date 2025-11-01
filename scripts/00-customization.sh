#!/usr/bin/env bash

###############################################################################
# 00-customization.sh
# 
# Visual customization for Zorin OS (GNOME-based)
# - Zorin OS native dark theme (built-in dark mode)
# - Custom fonts (Inter, JetBrains Mono)
# - Dark wallpaper configuration
# - GNOME Terminal dark profile
# - GNOME extensions (system monitoring, clipboard indicator, etc.)
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
        echo -e "${BLUE}[customization]${NC} $1"
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

# Alias for compatibility
is_installed() {
    is_package_installed "$1"
}

# Check if running in GNOME environment
is_gnome() {
    if [[ -n "$XDG_CURRENT_DESKTOP" ]] && [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
        return 0
    fi
    
    # Fallback check
    if command -v gnome-shell &> /dev/null || command -v gsettings &> /dev/null; then
        return 0
    fi
    
    return 1
}

# Set GNOME setting using gsettings
set_gnome_setting() {
    local schema="$1"
    local key="$2"
    local value="$3"
    
    if command -v gsettings &> /dev/null; then
        if gsettings set "$schema" "$key" "$value" 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# Get GNOME setting value
get_gnome_setting() {
    local schema="$1"
    local key="$2"
    
    if command -v gsettings &> /dev/null; then
        gsettings get "$schema" "$key" 2>/dev/null || echo ""
    fi
}

###############################################################################
# Install GTK Themes
###############################################################################

install_gtk_themes() {
    print_info "Using Zorin OS native dark theme..."
    print_info "No additional themes needed - Zorin OS has built-in dark mode support"
    print_success "GTK themes check complete"
}

###############################################################################
# Install Icon Themes
###############################################################################

install_icon_themes() {
    print_info "Using Zorin OS native icon theme..."
    print_info "No additional icon themes needed - Zorin OS has built-in dark icons"
    print_success "Icon themes check complete"
}

###############################################################################
# Install Custom Fonts
###############################################################################

install_custom_fonts() {
    print_info "Installing custom fonts..."
    
    local fonts_dir="$HOME/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    # Inter font (modern, clean)
    if [[ ! -f "$fonts_dir/Inter-Regular.ttf" ]]; then
        print_info "Installing Inter font..."
        local inter_dir="$fonts_dir/Inter"
        mkdir -p "$inter_dir"
        
        # Download Inter font from GitHub releases
        local inter_url="https://github.com/rsms/inter/releases/download/v4.0/Inter-4.0.zip"
        local inter_zip="/tmp/inter-font.zip"
        
        if safe_curl_download_with_cache "$inter_url" "$inter_zip" 3 300 30; then
            # Install unzip if not available
            if ! command -v unzip &> /dev/null; then
                ensure_apt_updated
                sudo apt-get install -y unzip
            fi
            
            if command -v unzip &> /dev/null; then
                
                unzip -q -o "$inter_zip" -d "/tmp/inter-font-extract" 2>/dev/null || true
                # Find the font files and copy them
                if [[ -d "/tmp/inter-font-extract" ]]; then
                    find "/tmp/inter-font-extract" -name "*.ttf" -exec cp {} "$inter_dir/" \; 2>/dev/null || true
                    find "/tmp/inter-font-extract" -name "*.otf" -exec cp {} "$inter_dir/" \; 2>/dev/null || true
                    rm -rf "/tmp/inter-font-extract"
                fi
                rm -f "$inter_zip"
                print_success "Inter font installed"
            else
                print_warning "unzip not available, skipping Inter font"
            fi
        else
            print_warning "Could not download Inter font"
        fi
    else
        print_info "Inter font already installed"
    fi
    
    # JetBrains Mono (monospace font for terminal/editors)
    if [[ ! -f "$fonts_dir/JetBrainsMono-Regular.ttf" ]]; then
        print_info "Installing JetBrains Mono font..."
        local jetbrains_dir="$fonts_dir/JetBrainsMono"
        mkdir -p "$jetbrains_dir"
        
        # Download JetBrains Mono from GitHub releases
        local jetbrains_url="https://github.com/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
        local jetbrains_zip="/tmp/jetbrains-mono.zip"
        
        if safe_curl_download_with_cache "$jetbrains_url" "$jetbrains_zip" 3 300 30; then
            # Install unzip if not available
            if ! command -v unzip &> /dev/null; then
                ensure_apt_updated
                sudo apt-get install -y unzip
            fi
            
            if command -v unzip &> /dev/null; then
                unzip -q -o "$jetbrains_zip" -d "/tmp/jetbrains-extract" 2>/dev/null || true
                if [[ -d "/tmp/jetbrains-extract" ]]; then
                    find "/tmp/jetbrains-extract" -name "*.ttf" -exec cp {} "$jetbrains_dir/" \; 2>/dev/null || true
                    rm -rf "/tmp/jetbrains-extract"
                fi
                rm -f "$jetbrains_zip"
                print_success "JetBrains Mono font installed"
            else
                print_warning "unzip not available, skipping JetBrains Mono font"
            fi
        else
            print_warning "Could not download JetBrains Mono font"
        fi
    else
        print_info "JetBrains Mono font already installed"
    fi
    
    # Update font cache
    if command -v fc-cache &> /dev/null; then
        print_info "Updating font cache..."
        fc-cache -fv "$fonts_dir" 2>/dev/null || true
        print_success "Font cache updated"
    fi
    
    print_success "Custom fonts installation complete"
}

###############################################################################
# Configure GNOME Appearance Settings
###############################################################################

configure_gnome_appearance() {
    if ! is_gnome; then
        print_warning "Not running in GNOME environment, skipping GNOME appearance configuration"
        return 0
    fi
    
    print_info "Configuring Zorin OS dark theme..."
    
    # Enable dark mode for applications (this is the main setting for Zorin OS)
    set_gnome_setting "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'" || true
    print_success "Dark color scheme enabled"
    
    # Use Zorin OS native theme (will automatically use dark variant)
    print_info "Setting Zorin OS native theme..."
    # Get current theme to see if we need to change it
    local current_theme
    current_theme=$(get_gnome_setting "org.gnome.desktop.interface" "gtk-theme" 2>/dev/null || echo "")
    
    # If theme is set to a light variant, switch to dark variant
    if [[ -n "$current_theme" ]]; then
        print_info "Current theme: $current_theme"
        # Zorin OS themes typically have -dark variants
        # But the color-scheme preference should handle this automatically
    fi
    
    # For Zorin OS, the color-scheme setting should be sufficient
    # The system will automatically use the dark variant of the current theme
    print_success "Zorin OS will use dark theme variant automatically"
    
    # Set GNOME Shell theme (for top bar and shell UI)
    print_info "Setting GNOME Shell theme to dark..."
    if command -v dconf &> /dev/null; then
        # Check if User Themes extension is needed for shell theming
        # For Zorin/GNOME, the shell typically uses the system theme
        # The color-scheme setting should handle most of it
        # But we can also try to set shell theme if User Themes extension is installed
        if gnome-extensions list 2>/dev/null | grep -q "user-theme"; then
            dconf write /org/gnome/shell/extensions/user-theme/name "'Adwaita-dark'" 2>/dev/null || true
            print_info "User Themes extension detected, shell theme configured"
        fi
        # Most modern GNOME versions (40+) use color-scheme for shell automatically
        print_info "Shell theme will follow system color scheme (dark)"
    fi
    
    # Keep Zorin OS native icon theme (will use dark variant automatically)
    print_info "Keeping Zorin OS native icon theme..."
    local current_icon_theme
    current_icon_theme=$(get_gnome_setting "org.gnome.desktop.interface" "icon-theme" 2>/dev/null || echo "")
    if [[ -n "$current_icon_theme" ]]; then
        print_info "Using icon theme: $current_icon_theme (dark variant will be used automatically)"
    fi
    print_success "Icon theme configured"
    
    # Keep Zorin OS native cursor theme
    print_info "Keeping Zorin OS native cursor theme..."
    # Cursor will automatically use dark variant with color-scheme
    
    # Zorin-specific dark mode settings
    if command -v dconf &> /dev/null; then
        print_info "Configuring Zorin OS dark mode..."
        # Enable dark mode in Zorin Appearance settings (if schema exists)
        # Note: color-scheme should be sufficient, but we can try Zorin-specific settings
        dconf write /org/zorin/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
        
        # Get and keep current Zorin theme (it will automatically use dark variant)
        local zorin_theme
        zorin_theme=$(dconf read /org/zorin/desktop/interface/gtk-theme 2>/dev/null | tr -d "'" || echo "")
        if [[ -n "$zorin_theme" ]]; then
            print_info "Keeping Zorin theme: $zorin_theme (will use dark variant)"
        fi
    fi
    
    # Set dark theme for text editor and other default apps
    if command -v dconf &> /dev/null; then
        # Gedit dark theme preference
        dconf write /org/gnome/gedit/preferences/editor/scheme "'classic-dark'" 2>/dev/null || true
        # Nautilus (file manager) dark theme
        dconf write /org/gnome/nautilus/preferences/use-dark-theme "true" 2>/dev/null || true
    fi
    
    # Set font (try to use Inter if installed, fallback to default)
    local current_font
    current_font=$(get_gnome_setting "org.gnome.desktop.interface" "font-name" 2>/dev/null || echo "")
    
    if [[ -z "$current_font" ]] || [[ "$current_font" == *"'*'"* ]]; then
        # Try to set Inter font if available
        if fc-list | grep -q "Inter"; then
            set_gnome_setting "org.gnome.desktop.interface" "font-name" "'Inter 11'" || \
            set_gnome_setting "org.gnome.desktop.interface" "font-name" "'Ubuntu 11'" || true
        fi
    fi
    
    # Set monospace font (JetBrains Mono if available)
    if fc-list | grep -q "JetBrains Mono"; then
        set_gnome_setting "org.gnome.desktop.interface" "monospace-font-name" "'JetBrains Mono 11'" || \
        set_gnome_setting "org.gnome.desktop.interface" "monospace-font-name" "'Ubuntu Mono 11'" || true
    fi
    
    # Set document font
    if fc-list | grep -q "Inter"; then
        set_gnome_setting "org.gnome.desktop.interface" "document-font-name" "'Inter 11'" || true
    fi
    
    print_success "GNOME appearance settings configured"
}

###############################################################################
# Configure GNOME Terminal Dark Profile
###############################################################################

configure_terminal_profile() {
    if ! command -v gnome-terminal &> /dev/null; then
        print_warning "GNOME Terminal not found, skipping terminal profile configuration"
        return 0
    fi
    
    print_info "Configuring GNOME Terminal dark profile..."
    
    # Check if we're running in a display environment
    if [[ -z "$DISPLAY" ]] && [[ -z "$WAYLAND_DISPLAY" ]]; then
        print_warning "No display detected, skipping terminal profile configuration"
        print_info "You may need to configure the terminal profile manually after logging in"
        return 0
    fi
    
    # Use dconf to configure terminal profile
    if command -v dconf &> /dev/null; then
        local profile_id
        profile_id=$(dconf read /org/gnome/terminal/legacy/profiles:/default 2>/dev/null | tr -d "'" || echo "")
        
        if [[ -z "$profile_id" ]]; then
            # Get the first available profile
            profile_id=$(dconf list /org/gnome/terminal/legacy/profiles:/ 2>/dev/null | grep -E "^:" | head -n1 | sed 's|/||g' || echo "")
        fi
        
        if [[ -n "$profile_id" ]]; then
            print_info "Configuring terminal profile: $profile_id"
            
            # Set dark background colors (Nord theme inspired)
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/background-color "'rgb(46,52,64)'" 2>/dev/null || true  # Nord: nord0
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/foreground-color "'rgb(216,222,233)'" 2>/dev/null || true  # Nord: nord4
            
            # Cursor colors
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/cursor-colors-set "true" 2>/dev/null || true
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/cursor-background-color "'rgb(216,222,233)'" 2>/dev/null || true
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/cursor-foreground-color "'rgb(46,52,64)'" 2>/dev/null || true
            
            # Palette colors (Nord theme)
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/palette "['rgb(46,52,64)', 'rgb(191,97,106)', 'rgb(163,190,140)', 'rgb(235,203,139)', 'rgb(129,161,193)', 'rgb(180,142,173)', 'rgb(136,192,208)', 'rgb(216,222,233)', 'rgb(88,110,117)', 'rgb(191,97,106)', 'rgb(163,190,140)', 'rgb(235,203,139)', 'rgb(129,161,193)', 'rgb(180,142,173)', 'rgb(136,192,208)', 'rgb(236,239,244)']" 2>/dev/null || true
            
            # Use system theme colors as fallback
            dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/use-theme-colors "false" 2>/dev/null || true
            
            # Font (JetBrains Mono if available)
            if fc-list | grep -q "JetBrains Mono"; then
                dconf write /org/gnome/terminal/legacy/profiles:/:${profile_id}/font "'JetBrains Mono 11'" 2>/dev/null || true
            fi
            
            # Set as default
            dconf write /org/gnome/terminal/legacy/profiles:/default "'${profile_id}'" 2>/dev/null || true
            
            print_success "GNOME Terminal dark profile configured"
        else
            print_warning "Could not find terminal profile to configure"
        fi
    else
        print_warning "dconf not available, skipping terminal profile configuration"
        print_info "You can configure the terminal profile manually:"
        print_info "  - Open GNOME Terminal"
        print_info "  - Go to Preferences > Profiles"
        print_info "  - Select your profile and configure colors to dark theme"
    fi
}

###############################################################################
# Configure Wallpaper (Optional)
###############################################################################

configure_wallpaper() {
    if ! is_gnome; then
        print_warning "Not running in GNOME environment, skipping wallpaper configuration"
        return 0
    fi
    
    print_info "Configuring wallpaper..."
    
    # Get dotfiles directory
    local dotfiles_dir
    dotfiles_dir="$(cd "$SCRIPT_DIR/.." && pwd)"
    local wallpaper_dir="$dotfiles_dir/assets/wallpapers"
    
    # Check for background images (multiple formats and naming conventions)
    local wallpaper_file=""
    local wallpaper_extensions=("jpg" "jpeg" "png" "webp")
    local wallpaper_names=("background" "wallpaper" "desktop")
    
    # Try to find wallpaper file
    for name in "${wallpaper_names[@]}"; do
        for ext in "${wallpaper_extensions[@]}"; do
            # Try lowercase extension
            if [[ -f "$wallpaper_dir/${name}.${ext}" ]]; then
                wallpaper_file="$wallpaper_dir/${name}.${ext}"
                break 2
            fi
            # Try uppercase extension
            local ext_upper="${ext^^}"
            if [[ -f "$wallpaper_dir/${name}.${ext_upper}" ]]; then
                wallpaper_file="$wallpaper_dir/${name}.${ext_upper}"
                break 2
            fi
        done
    done
    
    # If found, copy to user's Pictures directory and set as wallpaper
    if [[ -n "$wallpaper_file" ]] && [[ -f "$wallpaper_file" ]]; then
        print_info "Found wallpaper: $(basename "$wallpaper_file")"
        
        # Create Pictures directory if it doesn't exist
        local pictures_dir="$HOME/Pictures"
        mkdir -p "$pictures_dir"
        
        # Copy wallpaper to Pictures directory
        local wallpaper_dest="$pictures_dir/background.${wallpaper_file##*.}"
        cp "$wallpaper_file" "$wallpaper_dest"
        print_success "Wallpaper copied to: $wallpaper_dest"
        
        # Set as wallpaper (convert to file URI)
        local wallpaper_uri="file://$(readlink -f "$wallpaper_dest" || echo "$wallpaper_dest")"
        
        # For GNOME, use gsettings
        if command -v gsettings &> /dev/null; then
            set_gnome_setting "org.gnome.desktop.background" "picture-uri" "'$wallpaper_uri'" || true
            set_gnome_setting "org.gnome.desktop.background" "picture-uri-dark" "'$wallpaper_uri'" || true
            # Set picture options (centered, scaled, spanned, etc.)
            set_gnome_setting "org.gnome.desktop.background" "picture-options" "'zoom'" || true
            print_success "Wallpaper configured successfully"
        else
            print_warning "gsettings not available, wallpaper copied but not set"
            print_info "You can set it manually from Settings > Appearance"
            print_info "Or run: gsettings set org.gnome.desktop.background picture-uri '$wallpaper_uri'"
        fi
    else
        print_info "No wallpaper file found in $wallpaper_dir"
        print_info "Supported names: background.jpg, wallpaper.png, desktop.webp, etc."
        print_info "Place your wallpaper in: $wallpaper_dir/"
        print_info "Supported formats: ${wallpaper_extensions[*]}"
    fi
}

###############################################################################
# Install GNOME Extensions
###############################################################################

install_gnome_extensions() {
    if ! is_gnome; then
        print_warning "Not running in GNOME environment, skipping GNOME extensions"
        return 0
    fi
    
    print_info "Installing GNOME extensions support..."
    
    # Install GNOME Shell Extensions tool and Extension Manager
    if ! command -v gnome-extensions-app &> /dev/null && ! is_installed "gnome-shell-extensions"; then
        print_info "Installing GNOME Shell Extensions..."
        ensure_apt_updated
        sudo apt-get install -y gnome-shell-extensions gnome-shell-extension-manager || \
        sudo apt-get install -y gnome-shell-extensions chrome-gnome-shell || true
        
        print_success "GNOME Shell Extensions support installed"
    else
        print_info "GNOME Shell Extensions already installed"
    fi
    
    # Install gnome-extensions-cli if available (for easier extension management)
    if ! command -v gnome-extensions-cli &> /dev/null; then
        print_info "Installing gnome-extensions-cli for extension management..."
        ensure_apt_updated
        # Try to install via pip (may require python3-pip)
        if command -v pip3 &> /dev/null || command -v pip &> /dev/null; then
            pip3 install --user gnome-extensions-cli 2>/dev/null || \
            pip install --user gnome-extensions-cli 2>/dev/null || true
        fi
    fi
    
    print_info "Configuring system monitoring extensions..."
    configure_system_extensions
}

###############################################################################
# Configure System Extensions (Clipboard, System Monitor, etc.)
###############################################################################

# Install extension from ZIP file
install_extension_from_zip() {
    local extension_uuid="$1"
    local download_url="$2"
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    local extension_dir="$extensions_dir/$extension_uuid"
    
    # Skip if already installed
    if [[ -d "$extension_dir" ]] && [[ -f "$extension_dir/metadata.json" ]]; then
        print_info "Extension $extension_uuid already installed"
        return 0
    fi
    
    print_info "Downloading extension: $extension_uuid from $download_url"
    
    # Validate URL
    if [[ -z "$download_url" ]] || [[ "$download_url" == "null" ]]; then
        print_warning "Invalid download URL for extension $extension_uuid"
        return 1
    fi
    
    # Create extensions directory
    mkdir -p "$extensions_dir"
    
    # Download extension ZIP
    local zip_file="/tmp/${extension_uuid}-$(date +%s).zip"
    local download_success=false
    
    if command -v safe_curl_download_with_cache &> /dev/null; then
        if safe_curl_download_with_cache "$download_url" "$zip_file" 3 120 30; then
            download_success=true
        fi
    else
        if curl -fsSL --max-time 120 --connect-timeout 30 --retry 3 -o "$zip_file" "$download_url" 2>/dev/null; then
            download_success=true
        fi
    fi
    
    # Verify ZIP file was downloaded and is valid
    if [[ ! -f "$zip_file" ]] || [[ ! -s "$zip_file" ]]; then
        print_warning "Failed to download extension $extension_uuid (file is empty or missing)"
        rm -f "$zip_file" 2>/dev/null || true
        return 1
    fi
    
    # Check if it's a valid ZIP file
    if ! command -v unzip &> /dev/null; then
        print_warning "unzip not available, cannot extract extension"
        rm -f "$zip_file" 2>/dev/null || true
        return 1
    fi
    
    # Test ZIP file integrity
    if ! unzip -tq "$zip_file" >/dev/null 2>&1; then
        print_warning "Downloaded file is not a valid ZIP for extension $extension_uuid"
        rm -f "$zip_file" 2>/dev/null || true
        return 1
    fi
    
    # Extract extension
    print_info "Extracting extension $extension_uuid..."
    mkdir -p "$extension_dir"
    
    # Clean directory in case of partial previous installation
    rm -rf "$extension_dir"/* 2>/dev/null || true
    
    if unzip -q -o "$zip_file" -d "$extension_dir" 2>/dev/null; then
        # Check if files were extracted to a subdirectory
        if [[ -d "$extension_dir/${extension_uuid}" ]]; then
            mv "$extension_dir/${extension_uuid}"/* "$extension_dir/" 2>/dev/null || true
            rmdir "$extension_dir/${extension_uuid}" 2>/dev/null || true
        fi
        
        # Verify metadata.json exists
        if [[ ! -f "$extension_dir/metadata.json" ]]; then
            print_warning "Extension $extension_uuid extracted but metadata.json not found"
            rm -rf "$extension_dir" 2>/dev/null || true
            rm -f "$zip_file" 2>/dev/null || true
            return 1
        fi
        
        rm -f "$zip_file" 2>/dev/null || true
        print_success "Extension $extension_uuid installed successfully"
        return 0
    else
        print_warning "Failed to extract extension $extension_uuid"
        rm -rf "$extension_dir" 2>/dev/null || true
        rm -f "$zip_file" 2>/dev/null || true
        return 1
    fi
}

# Enable extension via gnome-extensions or dconf
enable_extension() {
    local extension_uuid="$1"
    
    # First check if extension is installed
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    if [[ ! -d "$extensions_dir/$extension_uuid" ]]; then
        print_warning "Extension $extension_uuid not found in $extensions_dir"
        return 1
    fi
    
    # Try to enable via gnome-extensions command first
    if command -v gnome-extensions &> /dev/null; then
        if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
            print_success "Extension $extension_uuid enabled"
            return 0
        fi
    fi
    
    # Fallback: enable via dconf
    if command -v dconf &> /dev/null; then
        # Read current enabled extensions
        local current_list
        current_list=$(dconf read /org/gnome/shell/enabled-extensions 2>/dev/null || echo "[]")
        
        # Check if already enabled
        if echo "$current_list" | grep -q "$extension_uuid"; then
            print_info "Extension $extension_uuid already enabled"
            return 0
        fi
        
        # Add extension to list
        # Handle empty list case
        if [[ "$current_list" == "[]" ]] || [[ -z "$current_list" ]]; then
            dconf write /org/gnome/shell/enabled-extensions "['$extension_uuid']" 2>/dev/null || true
        else
            # Remove brackets and quotes, add new extension, then reformat
            local clean_list
            clean_list=$(echo "$current_list" | sed "s/^\[//; s/\]$//; s/'//g")
            local new_list="['$clean_list','$extension_uuid']"
            new_list=$(echo "$new_list" | sed "s/','/', '/g")  # Fix spacing
            dconf write /org/gnome/shell/enabled-extensions "$new_list" 2>/dev/null || true
        fi
        
        print_success "Extension $extension_uuid enabled via dconf"
        return 0
    fi
    
    print_warning "Could not enable extension $extension_uuid automatically"
    print_info "You may need to enable it manually via Extension Manager"
    return 1
}

configure_system_extensions() {
    if ! is_gnome; then
        return 0
    fi
    
    print_info "Setting up system extensions..."
    
    # Install Extension Manager if not available
    if ! command -v extension-manager &> /dev/null && ! is_installed "gnome-shell-extension-manager"; then
        print_info "Installing Extension Manager..."
        ensure_apt_updated
        sudo apt-get install -y gnome-shell-extension-manager 2>/dev/null || true
    fi
    
    # Get GNOME Shell version for extension compatibility
    local gnome_version
    gnome_version=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "44")
    local major_version="${gnome_version%%.*}"
    
    print_info "GNOME Shell version: $gnome_version (major: $major_version)"
    
    # Ensure unzip is available
    if ! command -v unzip &> /dev/null; then
        print_info "Installing unzip for extension extraction..."
        ensure_apt_updated
        sudo apt-get install -y unzip 2>/dev/null || true
    fi
    
    # Function to get latest extension download URL from extensions.gnome.org
    get_extension_download_url() {
        local extension_id="$1"
        local gnome_version="$2"
        
        # Try to get download URL from extensions.gnome.org API
        local api_url="https://extensions.gnome.org/extension-info/?pk=${extension_id}&shell_version=${gnome_version}"
        local download_url
        download_url=$(curl -s "$api_url" 2>/dev/null | grep -o '"download_url":"[^"]*' | cut -d'"' -f4 || echo "")
        
        if [[ -n "$download_url" ]] && [[ "$download_url" != "null" ]]; then
            echo "https://extensions.gnome.org${download_url}"
            return 0
        fi
        
        return 1
    }
    
    # Install Clipboard Indicator
    print_info "Installing Clipboard Indicator extension..."
    local clipboard_id="779"  # Extension ID from extensions.gnome.org
    local clipboard_uuid="clipboard-indicator@tudmotu.com"
    local clipboard_url=""
    
    # Try to get download URL from API
    print_info "Fetching compatible version from extensions.gnome.org..."
    clipboard_url=$(get_extension_download_url "$clipboard_id" "$gnome_version" 2>/dev/null || echo "")
    
    # If API failed, try with major version only
    if [[ -z "$clipboard_url" ]] || [[ "$clipboard_url" == "null" ]]; then
        print_info "Trying with major version..."
        clipboard_url=$(get_extension_download_url "$clipboard_id" "${major_version}.0" 2>/dev/null || echo "")
    fi
    
    # Multiple fallback URLs for different versions
    if [[ -z "$clipboard_url" ]] || [[ "$clipboard_url" == "null" ]]; then
        print_info "Using fallback URLs..."
        # Try multiple common version numbers
        local fallback_versions=("47" "46" "45" "44" "43" "42")
        for version in "${fallback_versions[@]}"; do
            local test_url="https://extensions.gnome.org/extension-data/${clipboard_uuid}.v${version}.shell-extension.zip"
            print_info "Trying version $version..."
            if curl -sLf --head --max-time 10 "$test_url" >/dev/null 2>&1; then
                clipboard_url="$test_url"
                print_success "Found compatible version: $version"
                break
            fi
        done
    fi
    
    if [[ -z "$clipboard_url" ]] || [[ "$clipboard_url" == "null" ]]; then
        print_warning "Could not find download URL for Clipboard Indicator"
        print_info "You can install it manually via Extension Manager or visit:"
        print_info "  https://extensions.gnome.org/extension/${clipboard_id}/clipboard-indicator/"
    elif install_extension_from_zip "$clipboard_uuid" "$clipboard_url"; then
        print_info "Enabling Clipboard Indicator..."
        if enable_extension "$clipboard_uuid"; then
            print_success "Clipboard Indicator installed and enabled"
        else
            print_warning "Clipboard Indicator installed but could not be enabled automatically"
            print_info "Please enable it manually via Extension Manager"
        fi
    else
        print_warning "Could not install Clipboard Indicator automatically"
        print_info "You can install it manually via Extension Manager or visit:"
        print_info "  https://extensions.gnome.org/extension/${clipboard_id}/clipboard-indicator/"
    fi
    
    # Install Vitals (most comprehensive - temperature, CPU, memory, network, battery)
    print_info "Installing Vitals extension..."
    local vitals_id="1460"  # Extension ID from extensions.gnome.org
    local vitals_uuid="Vitals@CoreCoding.com"
    local vitals_url=""
    
    # Try to get download URL from API
    print_info "Fetching compatible version from extensions.gnome.org..."
    vitals_url=$(get_extension_download_url "$vitals_id" "$gnome_version" 2>/dev/null || echo "")
    
    # If API failed, try with major version only
    if [[ -z "$vitals_url" ]] || [[ "$vitals_url" == "null" ]]; then
        print_info "Trying with major version..."
        vitals_url=$(get_extension_download_url "$vitals_id" "${major_version}.0" 2>/dev/null || echo "")
    fi
    
    # Multiple fallback URLs for different versions
    if [[ -z "$vitals_url" ]] || [[ "$vitals_url" == "null" ]]; then
        print_info "Using fallback URLs..."
        # Try multiple common version numbers
        local fallback_versions=("85" "84" "83" "82" "81" "80")
        for version in "${fallback_versions[@]}"; do
            local test_url="https://extensions.gnome.org/extension-data/${vitals_uuid}.v${version}.shell-extension.zip"
            print_info "Trying version $version..."
            if curl -sLf --head --max-time 10 "$test_url" >/dev/null 2>&1; then
                vitals_url="$test_url"
                print_success "Found compatible version: $version"
                break
            fi
        done
    fi
    
    if [[ -z "$vitals_url" ]] || [[ "$vitals_url" == "null" ]]; then
        print_warning "Could not find download URL for Vitals"
        print_info "You can install it manually via Extension Manager"
    elif install_extension_from_zip "$vitals_uuid" "$vitals_url"; then
        print_info "Enabling Vitals..."
        if enable_extension "$vitals_uuid"; then
            print_success "Vitals installed and enabled"
            
            # Configure Vitals to show temperature, CPU, memory, network, battery
            if command -v dconf &> /dev/null; then
                print_info "Configuring Vitals settings..."
                dconf write /org/gnome/shell/extensions/vitals/show-temperature "true" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-voltage "false" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-fan "false" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-frequency "false" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-memory "true" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-cpu "true" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-network "true" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-disk "false" 2>/dev/null || true
                dconf write /org/gnome/shell/extensions/vitals/show-battery "true" 2>/dev/null || true
                print_success "Vitals configured (temperature, CPU, memory, network, battery)"
            fi
        else
            print_warning "Vitals installed but could not be enabled automatically"
            print_info "Please enable it manually via Extension Manager"
        fi
    else
        print_warning "Could not install Vitals automatically"
        print_info "You can install it manually via Extension Manager"
    fi
    
    # Refresh GNOME Shell to load extensions
    if command -v busctl &> /dev/null; then
        print_info "Refreshing GNOME Shell to load extensions..."
        busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting GNOME Shell...")' 2>/dev/null || true
    fi
    
    print_info ""
    print_info "📋 Extensions installed and enabled:"
    print_info "   - Clipboard Indicator (clipboard icon in top bar)"
    print_info "   - Vitals (temperature, CPU, memory, network, battery in top bar)"
    print_info ""
    print_info "💡 If extensions don't appear:"
    print_info "   1. Press Alt+F2, type 'r' and press Enter (restart GNOME Shell)"
    print_info "   2. Or log out and log back in"
    print_info "   3. Or check Extension Manager to see if they're enabled"
}

###############################################################################
# Main Function
###############################################################################

main() {
    print_info "Starting visual customization setup..."
    
    # Check if running in a graphical environment (optional check)
    if [[ -z "$DISPLAY" ]] && [[ -z "$WAYLAND_DISPLAY" ]]; then
        print_warning "No display detected. Some settings may not apply until you log in to a graphical session."
    fi
    
    # Install themes
    install_gtk_themes
    
    # Install icon themes
    install_icon_themes
    
    # Install custom fonts
    install_custom_fonts
    
    # Configure GNOME appearance (only if running in GNOME)
    if is_gnome; then
        configure_gnome_appearance
        configure_terminal_profile
        configure_wallpaper
        install_gnome_extensions
    else
        print_warning "Not running in GNOME environment"
        print_info "Themes and fonts have been installed, but some settings need GNOME"
    fi
    
    print_success "Visual customization setup complete!"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Log out and log back in (or restart) to apply theme changes"
    print_info "  2. Open GNOME Extensions app to install additional extensions"
    print_info "  3. Set a custom dark wallpaper from Settings > Appearance"
    print_info "  4. Configure Powerlevel10k colors to match your terminal theme"
}

# Run main function
main "$@"

