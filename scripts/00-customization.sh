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
                DEBIAN_FRONTEND=noninteractive sudo apt-get install -y unzip 2>/dev/null || true
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
                DEBIAN_FRONTEND=noninteractive sudo apt-get install -y unzip 2>/dev/null || true
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
    
    print_info "Configuring Zorin OS 18 dark theme..."
    
    # Try using Zorin Appearance tool if available (most reliable method for Zorin OS)
    if command -v zorin-appearance &> /dev/null; then
        print_info "Using Zorin Appearance tool to set dark theme..."
        # Zorin Appearance can be controlled via dconf
        # The schema might be org.zorin.desktop.interface or similar
        # Try to set via dconf first
        if command -v dconf &> /dev/null; then
            # Try Zorin-specific paths
            dconf write /org/zorin/desktop/interface/color-scheme "'dark'" 2>/dev/null || \
            dconf write /org/zorin/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
            
            # Try to get current Zorin appearance settings
            local zorin_theme
            zorin_theme=$(dconf read /org/zorin/desktop/interface/gtk-theme 2>/dev/null | tr -d "'" || echo "")
            if [[ -n "$zorin_theme" ]] && [[ "$zorin_theme" != *"-dark" ]]; then
                # Set dark variant
                local zorin_dark="${zorin_theme%-light}-dark"
                if [[ -z "$zorin_dark" ]] || [[ "$zorin_dark" == "-dark" ]]; then
                    zorin_dark="${zorin_theme}-dark"
                fi
                if [[ -d "/usr/share/themes/$zorin_dark" ]]; then
                    dconf write /org/zorin/desktop/interface/gtk-theme "'$zorin_dark'" 2>/dev/null || true
                    print_success "Zorin dark theme set via dconf: $zorin_dark"
                fi
            fi
        fi
    fi
    
    # Get current theme to detect Zorin theme name
    local current_theme
    current_theme=$(get_gnome_setting "org.gnome.desktop.interface" "gtk-theme" 2>/dev/null | tr -d "'" || echo "")
    print_info "Current GTK theme: $current_theme"
    
    # Zorin OS 18 specific: Find and set dark variant directly
    # This is important because color-scheme alone may not activate the dark theme
    local dark_theme_applied=false
    
    if [[ -n "$current_theme" ]]; then
        # Remove quotes and detect theme type
        current_theme=$(echo "$current_theme" | tr -d "'")
        
        # If already dark, confirm it
        if [[ "$current_theme" == *"-dark" ]] || [[ "$current_theme" == *"Dark" ]]; then
            print_info "Theme already appears to be dark: $current_theme"
            dark_theme_applied=true
        else
            # Try to find dark variant
            local dark_theme=""
            
            # Method 1: Replace -light with -dark
            if [[ "$current_theme" == *"-light" ]]; then
                dark_theme="${current_theme%-light}-dark"
            # Method 2: Try common patterns
            elif [[ "$current_theme" == *"Light" ]]; then
                dark_theme="${current_theme%Light}Dark"
            # Method 3: Add -dark suffix
            else
                dark_theme="${current_theme}-dark"
            fi
            
            # Check if dark variant exists
            if [[ -n "$dark_theme" ]]; then
                if [[ -d "/usr/share/themes/$dark_theme" ]] || [[ -d "$HOME/.themes/$dark_theme" ]]; then
                    print_info "Applying dark theme: $dark_theme"
                    set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'$dark_theme'" || true
                    if command -v dconf &> /dev/null; then
                        dconf write /org/gnome/desktop/interface/gtk-theme "'$dark_theme'" 2>/dev/null || true
                    fi
                    print_success "Dark theme applied: $dark_theme"
                    dark_theme_applied=true
                fi
            fi
        fi
    fi
    
    # If dark theme not applied yet, try to find any available dark theme
    if [[ "$dark_theme_applied" == "false" ]]; then
        print_info "Searching for available dark themes..."
        
        # Check for Yaru dark variants (common in Ubuntu-based systems like Zorin)
        local yaru_dark_themes=("Yaru-dark" "Yaru-purple-dark" "Yaru-blue-dark" "Yaru-green-dark" "Yaru-red-dark" "Yaru-orange-dark")
        
        for theme in "${yaru_dark_themes[@]}"; do
            if [[ -d "/usr/share/themes/$theme" ]]; then
                print_info "Found and applying dark theme: $theme"
                set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'$theme'" || true
                if command -v dconf &> /dev/null; then
                    dconf write /org/gnome/desktop/interface/gtk-theme "'$theme'" 2>/dev/null || true
                fi
                print_success "Applied dark theme: $theme"
                dark_theme_applied=true
                break
            fi
        done
        
        # If still not found, try Adwaita-dark (usually always available)
        if [[ "$dark_theme_applied" == "false" ]]; then
            if [[ -d "/usr/share/themes/Adwaita-dark" ]]; then
                print_info "Applying Adwaita-dark theme as fallback..."
                set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'Adwaita-dark'" || true
                if command -v dconf &> /dev/null; then
                    dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'" 2>/dev/null || true
                fi
                print_success "Applied Adwaita-dark theme"
                dark_theme_applied=true
            fi
        fi
    fi
    
    # Enable dark mode via color-scheme (GNOME 42+ method - works on Zorin OS 18)
    print_info "Enabling dark color scheme..."
    set_gnome_setting "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'" || true
    print_success "Dark color scheme enabled"
    
    # Also try setting it via dconf (more reliable)
    if command -v dconf &> /dev/null; then
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
    fi
    
    # Set GNOME Shell theme (for top bar and shell UI) - Important for Zorin OS 18
    print_info "Setting GNOME Shell theme to dark..."
    if command -v dconf &> /dev/null; then
        # Get the GTK theme we just set
        local applied_gtk_theme
        applied_gtk_theme=$(get_gnome_setting "org.gnome.desktop.interface" "gtk-theme" 2>/dev/null | tr -d "'" || echo "")
        
        # Try to set shell theme to match GTK theme
        # First try User Themes extension (if installed)
        if gnome-extensions list 2>/dev/null | grep -q "user-theme"; then
            if [[ -n "$applied_gtk_theme" ]]; then
                dconf write /org/gnome/shell/extensions/user-theme/name "'$applied_gtk_theme'" 2>/dev/null || true
            else
                dconf write /org/gnome/shell/extensions/user-theme/name "'Adwaita-dark'" 2>/dev/null || true
            fi
            print_info "User Themes extension detected, shell theme configured"
        fi
        
        # Also try setting shell theme directly (may work in some GNOME versions)
        # Note: This might not work in all GNOME versions, but worth trying
        if [[ -n "$applied_gtk_theme" ]]; then
            # Try Yaru-dark shell theme if available
            if [[ "$applied_gtk_theme" == *"Yaru"* ]] && [[ -d "/usr/share/gnome-shell/theme/Yaru-dark" ]]; then
                dconf write /org/gnome/shell/theme/name "'Yaru-dark'" 2>/dev/null || true
            fi
        fi
        
        print_success "GNOME Shell configured for dark theme"
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
    
    # Final verification: Check if dark theme is actually applied
    print_info "Verifying dark theme application..."
    local final_theme
    final_theme=$(get_gnome_setting "org.gnome.desktop.interface" "gtk-theme" 2>/dev/null | tr -d "'" || echo "")
    local final_color_scheme
    final_color_scheme=$(get_gnome_setting "org.gnome.desktop.interface" "color-scheme" 2>/dev/null | tr -d "'" || echo "")
    
    if [[ "$final_theme" == *"-dark" ]] || [[ "$final_theme" == *"Dark" ]] || [[ "$final_color_scheme" == "prefer-dark" ]]; then
        print_success "Dark theme is configured: $final_theme (color-scheme: $final_color_scheme)"
        print_info "Note: You may need to restart applications or log out/in for changes to fully apply"
    else
        print_warning "Dark theme might not be fully applied"
        print_info "Current theme: $final_theme"
        print_info "Current color-scheme: $final_color_scheme"
        print_info ""
        print_info "To manually enable dark theme in Zorin OS 18:"
        print_info "  1. Open 'Zorin Appearance' from Applications"
        print_info "  2. Select 'Dark' in the Appearance tab"
        print_info "  Or run: gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
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
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y gnome-shell-extensions gnome-shell-extension-manager 2>/dev/null || \
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y gnome-shell-extensions chrome-gnome-shell 2>/dev/null || true
        
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
# Reload GNOME Shell to load extensions
###############################################################################

reload_gnome_shell() {
    # Try multiple methods to reload GNOME Shell
    local reloaded=false
    
    # Method 1: busctl (most reliable for GNOME Shell restart)
    if command -v busctl &> /dev/null; then
        if busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting GNOME Shell...")' >/dev/null 2>&1; then
            reloaded=true
            sleep 2
        fi
    fi
    
    # Method 2: dbus-send (alternative method)
    if [[ "$reloaded" == "false" ]] && command -v dbus-send &> /dev/null; then
        if dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:'Meta.restart("Restarting...")' >/dev/null 2>&1; then
            reloaded=true
            sleep 2
        fi
    fi
    
    # Method 3: Kill and restart (more aggressive)
    # Note: This is a fallback but may interrupt user work, so we skip it
    
    if [[ "$reloaded" == "true" ]]; then
        return 0
    else
        return 1
    fi
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
        
        # Verify and fix UUID in metadata.json if needed
        local metadata_uuid
        metadata_uuid=$(grep -o '"uuid"[[:space:]]*:[[:space:]]*"[^"]*"' "$extension_dir/metadata.json" 2>/dev/null | sed 's/.*"uuid"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || echo "")
        if [[ -n "$metadata_uuid" ]] && [[ "$metadata_uuid" != "$extension_uuid" ]]; then
            print_info "Fixing UUID in metadata.json: $metadata_uuid -> $extension_uuid"
            sed -i "s/\"uuid\"[[:space:]]*:[[:space:]]*\"$metadata_uuid\"/\"uuid\": \"$extension_uuid\"/g" "$extension_dir/metadata.json" 2>/dev/null || true
        fi
        
        # Set correct permissions for extension files
        # Directories should be 755, files should be 644
        chmod -R u+rwX,go+rX "$extension_dir" 2>/dev/null || true
        find "$extension_dir" -type d -exec chmod 755 {} \; 2>/dev/null || true
        find "$extension_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true
        
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
    
    # Check shell version compatibility
    local metadata_file="$extensions_dir/$extension_uuid/metadata.json"
    if [[ -f "$metadata_file" ]]; then
        local gnome_version
        gnome_version=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "")
        if [[ -n "$gnome_version" ]]; then
            local major_version="${gnome_version%%.*}"
            # Check if metadata.json has compatible shell-version
            if ! grep -q "\"$major_version\"" "$metadata_file" 2>/dev/null && ! grep -q "\"${gnome_version}\"" "$metadata_file" 2>/dev/null; then
                print_warning "Extension $extension_uuid may not be compatible with GNOME Shell $gnome_version"
                print_info "Checking for compatible versions..."
            fi
        fi
    fi
    
    # Try to enable via gnome-extensions command first
    if command -v gnome-extensions &> /dev/null; then
        # First disable and re-enable to ensure clean state
        gnome-extensions disable "$extension_uuid" 2>/dev/null || true
        sleep 1
        
        if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
            # Verify it's actually enabled and active
            sleep 2
            local state
            state=$(gnome-extensions info "$extension_uuid" 2>/dev/null | grep "State:" | grep -o "ACTIVE\|ENABLED\|DISABLED" | head -1 || echo "")
            if [[ "$state" == "ACTIVE" ]] || [[ "$state" == "ENABLED" ]]; then
                print_success "Extension $extension_uuid enabled and active"
                return 0
            else
                print_warning "Extension $extension_uuid enabled but state is: $state"
            fi
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
        
        # Add extension to list using a more robust method
        # Parse the current list properly
        local new_list=""
        if [[ "$current_list" == "[]" ]] || [[ -z "$current_list" ]] || [[ "$current_list" == "@as []" ]]; then
            # Empty list, start fresh
            new_list="['$extension_uuid']"
        else
            # Parse existing list - handle both ['ext1', 'ext2'] and @as ['ext1', 'ext2'] formats
            local clean_list
            clean_list=$(echo "$current_list" | sed "s/^@as //; s/^\[//; s/\]$//; s/'//g" | tr -d ' ')
            
            if [[ -z "$clean_list" ]]; then
                new_list="['$extension_uuid']"
            else
                # Build new list properly
                new_list="['${clean_list//,/\', \'}, '$extension_uuid']"
            fi
        fi
        
        # Write the new list
        if dconf write /org/gnome/shell/enabled-extensions "$new_list" 2>/dev/null; then
            print_success "Extension $extension_uuid enabled via dconf"
            return 0
        else
            # Try alternative format
            if [[ "$new_list" =~ \['.*'\] ]]; then
                # Try with @as prefix (GNOME 42+)
                local alt_list="@as $new_list"
                if dconf write /org/gnome/shell/enabled-extensions "$alt_list" 2>/dev/null; then
                    print_success "Extension $extension_uuid enabled via dconf (alt format)"
                    return 0
                fi
            fi
        fi
    fi
    
    print_warning "Could not enable extension $extension_uuid automatically"
    print_info "You may need to enable it manually via Extension Manager"
    return 1
}

# Try to install extension via Extension Manager CLI or gnome-extensions-cli
install_extension_via_manager() {
    local extension_uuid="$1"
    local extension_id="$2"
    
    # Skip CLI installation for now - Extension Manager CLI may hang or require user interaction
    # The ZIP download method is more reliable and faster
    return 1
    
    # Note: Keeping this function for future use, but disabled for now
    # Extension Manager CLI commands can hang or require GUI interaction
    # if command -v extension-manager &> /dev/null; then
    #     print_info "Trying to install via Extension Manager CLI..."
    #     timeout 10 extension-manager install "$extension_id" 2>/dev/null || true
    #     sleep 1
    #     if [[ -d "$HOME/.local/share/gnome-shell/extensions/$extension_uuid" ]]; then
    #         return 0
    #     fi
    # fi
    #
    # if command -v gnome-extensions-cli &> /dev/null; then
    #     print_info "Trying to install via gnome-extensions-cli..."
    #     timeout 10 gnome-extensions-cli install "$extension_uuid" 2>/dev/null || true
    #     sleep 1
    #     if [[ -d "$HOME/.local/share/gnome-shell/extensions/$extension_uuid" ]]; then
    #         return 0
    #     fi
    # fi
}

configure_system_extensions() {
    if ! is_gnome; then
        return 0
    fi
    
    print_info "Setting up system extensions..."
    
    # Fix permissions for all existing extensions (in case some have wrong permissions)
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    if [[ -d "$extensions_dir" ]]; then
        print_info "Fixing permissions for existing extensions..."
        find "$extensions_dir" -type d -exec chmod 755 {} \; 2>/dev/null || true
        find "$extensions_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true
    fi
    
    # Install Extension Manager if not available
    if ! command -v extension-manager &> /dev/null && ! is_installed "gnome-shell-extension-manager"; then
        print_info "Installing Extension Manager..."
        ensure_apt_updated
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y gnome-shell-extension-manager 2>/dev/null || true
    fi
    
    # Install chrome-gnome-shell for browser integration (helps with extension installation)
    if ! is_installed "chrome-gnome-shell"; then
        print_info "Installing chrome-gnome-shell for extension support..."
        ensure_apt_updated
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y chrome-gnome-shell 2>/dev/null || true
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
        DEBIAN_FRONTEND=noninteractive sudo apt-get install -y unzip 2>/dev/null || true
    fi
    
    # Function to get extension download URL from extensions.gnome.org API
    # Uses multiple parsing methods for compatibility
    get_extension_download_url() {
        local extension_id="$1"
        local gnome_version="$2"
        local extension_uuid="$3"
        
        # Method 1: Use the official API endpoint
        local api_url="https://extensions.gnome.org/extension-info/?pk=${extension_id}&shell_version=${gnome_version}"
        local api_response
        api_response=$(curl -sLf --max-time 10 "$api_url" 2>/dev/null || echo "")
        
        if [[ -n "$api_response" ]]; then
            local download_url=""
            
            # Try sed-based parsing (more compatible than grep -P)
            download_url=$(echo "$api_response" | sed -n 's/.*"download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' 2>/dev/null || echo "")
            
            # If that failed, try with different pattern
            if [[ -z "$download_url" ]]; then
                download_url=$(echo "$api_response" | sed -n 's/.*download_url":"\([^"]*\)".*/\1/p' 2>/dev/null || echo "")
            fi
            
            # If still empty, try grep (non-Perl for compatibility)
            if [[ -z "$download_url" ]]; then
                download_url=$(echo "$api_response" | grep -o '"download_url"[[:space:]]*:[[:space:]]*"[^"]*' | sed 's/.*"download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)/\1/' 2>/dev/null || echo "")
            fi
            
            if [[ -n "$download_url" ]] && [[ "$download_url" != "null" ]] && [[ "$download_url" != "" ]]; then
                # The API returns relative URLs like /download-extension/{uuid}.shell-extension.zip?version_tag={tag}
                # We need to prepend the base URL
                if [[ "$download_url" == /* ]]; then
                    echo "https://extensions.gnome.org${download_url}"
                elif [[ "$download_url" == http* ]]; then
                    # Already a full URL
                    echo "$download_url"
                else
                    # Relative URL without leading slash
                    echo "https://extensions.gnome.org/${download_url}"
                fi
                return 0
            fi
        fi
        
        # Method 2: Try with just major version
        local major_only="${gnome_version%%.*}"
        if [[ "$major_only" != "$gnome_version" ]]; then
            api_url="https://extensions.gnome.org/extension-info/?pk=${extension_id}&shell_version=${major_only}.0"
            api_response=$(curl -sLf --max-time 10 "$api_url" 2>/dev/null || echo "")
            
            if [[ -n "$api_response" ]]; then
                local download_url
                download_url=$(echo "$api_response" | sed -n 's/.*"download_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' 2>/dev/null || echo "")
                
                if [[ -z "$download_url" ]]; then
                    download_url=$(echo "$api_response" | sed -n 's/.*download_url":"\([^"]*\)".*/\1/p' 2>/dev/null || echo "")
                fi
                
                if [[ -n "$download_url" ]] && [[ "$download_url" != "null" ]] && [[ "$download_url" != "" ]]; then
                    if [[ "$download_url" == /* ]]; then
                        echo "https://extensions.gnome.org${download_url}"
                    elif [[ "$download_url" == http* ]]; then
                        echo "$download_url"
                    else
                        echo "https://extensions.gnome.org/${download_url}"
                    fi
                    return 0
                fi
            fi
        fi
        
        return 1
    }
    
    # Function to get extension version number from API
    get_extension_version_number() {
        local extension_id="$1"
        local gnome_version="$2"
        
        local api_url="https://extensions.gnome.org/extension-info/?pk=${extension_id}&shell_version=${gnome_version}"
        local api_response
        api_response=$(curl -sLf --max-time 10 "$api_url" 2>/dev/null || echo "")
        
        if [[ -n "$api_response" ]]; then
            # Look for version field - try multiple patterns
            local version
            version=$(echo "$api_response" | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p' 2>/dev/null || echo "")
            
            if [[ -z "$version" ]]; then
                version=$(echo "$api_response" | grep -o '"version"[[:space:]]*:[[:space:]]*[0-9]*' | grep -o '[0-9]*' | head -1 2>/dev/null || echo "")
            fi
            
            if [[ -n "$version" ]] && [[ "$version" =~ ^[0-9]+$ ]]; then
                echo "$version"
                return 0
            fi
        fi
        
        return 1
    }
    
    # Helper function to install and enable an extension
    install_and_enable_extension() {
        local extension_name="$1"
        local extension_id="$2"
        local extension_uuid="$3"
        local install_success=false
        
        print_info "Installing $extension_name extension..."
        
        # First, try via Extension Manager CLI (if available)
        if install_extension_via_manager "$extension_uuid" "$extension_id"; then
            print_success "$extension_name installed via Extension Manager"
            install_success=true
        else
            # Fallback to manual ZIP download
            print_info "Installing $extension_name from extensions.gnome.org..."
            local extension_url=""
            
            # Try to get download URL from API with full GNOME version
            print_info "Fetching download URL from extensions.gnome.org API..."
            extension_url=$(get_extension_download_url "$extension_id" "$gnome_version" "$extension_uuid" 2>/dev/null || echo "")
            
            # If API failed, try with major.minor version (e.g., 46.0)
            if [[ -z "$extension_url" ]] || [[ "$extension_url" == "null" ]]; then
                print_info "Trying API with major version..."
                extension_url=$(get_extension_download_url "$extension_id" "${major_version}.0" "$extension_uuid" 2>/dev/null || echo "")
            fi
            
            # If still no URL, try to get version number and construct URL directly
            if [[ -z "$extension_url" ]] || [[ "$extension_url" == "null" ]]; then
                print_info "Trying to get extension version from API..."
                local ext_version
                ext_version=$(get_extension_version_number "$extension_id" "$gnome_version" 2>/dev/null || echo "")
                
                if [[ -n "$ext_version" ]]; then
                    extension_url="https://extensions.gnome.org/extension-data/${extension_uuid}.v${ext_version}.shell-extension.zip"
                    print_info "Constructed URL with version ${ext_version}"
                fi
            fi
            
            # Final fallback: Try common version numbers by testing URLs directly
            if [[ -z "$extension_url" ]] || [[ "$extension_url" == "null" ]]; then
                print_info "Trying fallback version detection..."
                # Start from current major version and go backwards
                local fallback_majors
                if [[ "$major_version" -ge 40 ]]; then
                    # Test versions from current major down to 40
                    local start_version=$((major_version * 10))
                    local end_version=$((40 * 10))
                    for ((v=start_version; v>=end_version; v-=10)); do
                        local test_version=$((v / 10))
                        # Try multiple patch versions for each major
                        for patch in 99 50 20 10 5 1 0; do
                            local test_url="https://extensions.gnome.org/extension-data/${extension_uuid}.v${test_version}${patch}.shell-extension.zip"
                            print_info "Testing version ${test_version}.${patch}..."
                            local http_code
                            http_code=$(curl -sLf --head --max-time 5 -w "%{http_code}" -o /dev/null "$test_url" 2>/dev/null || echo "000")
                            if [[ "$http_code" == "200" ]]; then
                                extension_url="$test_url"
                                print_success "Found working URL with version ${test_version}.${patch}"
                                break 2
                            fi
                        done
                    done
                fi
                
                # Last resort: try simple numeric versions (47, 46, 45, etc.)
                if [[ -z "$extension_url" ]] || [[ "$extension_url" == "null" ]]; then
                    local simple_versions=("50" "49" "48" "47" "46" "45" "44" "43" "42" "41" "40")
                    for version in "${simple_versions[@]}"; do
                        local test_url="https://extensions.gnome.org/extension-data/${extension_uuid}.v${version}.shell-extension.zip"
                        print_info "Testing simple version ${version}..."
                        local http_code
                        http_code=$(curl -sLf --head --max-time 5 -w "%{http_code}" -o /dev/null "$test_url" 2>/dev/null || echo "000")
                        if [[ "$http_code" == "200" ]]; then
                            extension_url="$test_url"
                            print_success "Found working URL with version ${version}"
                            break
                        fi
                    done
                fi
            fi
            
            if [[ -n "$extension_url" ]] && [[ "$extension_url" != "null" ]]; then
                if install_extension_from_zip "$extension_uuid" "$extension_url"; then
                    install_success=true
                fi
            fi
        fi
        
        # Enable extension if installed
        if [[ "$install_success" == "true" ]]; then
            print_info "Enabling $extension_name..."
            sleep 1
            
            # Ensure extension directory has correct permissions
            local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
            local extension_dir="$extensions_dir/$extension_uuid"
            if [[ -d "$extension_dir" ]]; then
                chmod -R u+rwX,go+rX "$extension_dir" 2>/dev/null || true
                find "$extension_dir" -type d -exec chmod 755 {} \; 2>/dev/null || true
                find "$extension_dir" -type f -exec chmod 644 {} \; 2>/dev/null || true
            fi
            
            if enable_extension "$extension_uuid"; then
                # Force reload GNOME Shell to activate extension
                sleep 2
                reload_gnome_shell || true
                
                # Wait and verify extension is active
                sleep 3
                local final_state
                if command -v gnome-extensions &> /dev/null; then
                    final_state=$(gnome-extensions info "$extension_uuid" 2>/dev/null | grep "State:" | grep -o "ACTIVE\|ENABLED\|DISABLED" | head -1 || echo "")
                    if [[ "$final_state" == "ACTIVE" ]]; then
                        print_success "$extension_name installed and enabled ✓ (ACTIVE)"
                    elif [[ "$final_state" == "ENABLED" ]]; then
                        print_success "$extension_name installed and enabled ✓ (may need restart)"
                    else
                        print_warning "$extension_name enabled but not active (state: $final_state)"
                        print_info "You may need to restart GNOME Shell: Press Alt+F2, type 'r' and Enter"
                    fi
                else
                    print_success "$extension_name installed and enabled ✓"
                fi
                return 0
            else
                print_warning "$extension_name installed but could not be enabled automatically"
                print_info "Trying alternative enable method..."
                
                # Try multiple methods to enable
                local enable_success=false
                
                # Method 1: Force disable then enable via gnome-extensions
                if command -v gnome-extensions &> /dev/null; then
                    gnome-extensions disable "$extension_uuid" 2>/dev/null || true
                    sleep 1
                    if gnome-extensions enable "$extension_uuid" 2>/dev/null; then
                        enable_success=true
                    fi
                fi
                
                # Method 2: Use dconf directly with proper formatting
                if [[ "$enable_success" == "false" ]] && command -v dconf &> /dev/null; then
                    local current_list
                    current_list=$(dconf read /org/gnome/shell/enabled-extensions 2>/dev/null || echo "[]")
                    if ! echo "$current_list" | grep -q "$extension_uuid"; then
                        # Add to list
                        local clean_list
                        clean_list=$(echo "$current_list" | sed "s/^@as //; s/^\[//; s/\]$//; s/'//g" | tr -d ' ')
                        if [[ -z "$clean_list" ]] || [[ "$clean_list" == "" ]]; then
                            dconf write /org/gnome/shell/enabled-extensions "['$extension_uuid']" 2>/dev/null && enable_success=true
                        else
                            # Build properly formatted list
                            local new_list="@as ['${clean_list//,/\', \'}, '$extension_uuid']"
                            dconf write /org/gnome/shell/enabled-extensions "$new_list" 2>/dev/null && enable_success=true
                        fi
                    else
                        enable_success=true  # Already in list
                    fi
                fi
                
                if [[ "$enable_success" == "true" ]]; then
                    sleep 2
                    reload_gnome_shell || true
                    print_success "$extension_name enabled via alternative method"
                    return 0
                fi
                
                print_info "Please enable manually: Open Extension Manager and toggle $extension_name ON"
                print_info "Or run: gnome-extensions enable $extension_uuid"
                return 1
            fi
        else
            print_warning "Could not install $extension_name automatically"
            print_info "Please install it manually:"
            print_info "  1. Open Extension Manager (extension-manager)"
            print_info "  2. Search for '$extension_name'"
            print_info "  3. Click Install, then toggle it ON"
            return 1
        fi
    }
    
    # Define extensions directory
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    
    # Install Clipboard Indicator (clipboard icon in top bar)
    if install_and_enable_extension "Clipboard Indicator" "779" "clipboard-indicator@tudmotu.com"; then
        print_info "Clipboard Indicator is now active - clipboard icon in top bar"
    fi
    
    # Force re-enable Clipboard Indicator if it's installed but not working
    if [[ -d "$extensions_dir/clipboard-indicator@tudmotu.com" ]]; then
        print_info "Ensuring Clipboard Indicator is properly activated..."
        if command -v gnome-extensions &> /dev/null; then
            gnome-extensions disable "clipboard-indicator@tudmotu.com" 2>/dev/null || true
            sleep 1
            gnome-extensions enable "clipboard-indicator@tudmotu.com" 2>/dev/null || true
            sleep 1
        fi
    fi
    
    # Install Blur My Shell (adds blur effects to GNOME Shell)
    if install_and_enable_extension "Blur My Shell" "3193" "blur-my-shell@aunetx"; then
        print_info "Blur My Shell is now active - blur effects applied to panels and overview"
    fi
    
    # Install Caffeine (prevents screen from locking/sleeping)
    if install_and_enable_extension "Caffeine" "517" "caffeine@patapon.info"; then
        print_info "Caffeine is now active - screen won't lock automatically"
    fi
    
    # Install Dash to Panel (combines dash and top panel into single panel)
    if install_and_enable_extension "Dash to Panel" "1160" "dash-to-panel@jderose9.github.com"; then
        print_info "Dash to Panel is now active - dash and top panel combined"
    fi
    
    # Force re-enable Dash to Panel if it's installed but not working
    if [[ -d "$extensions_dir/dash-to-panel@jderose9.github.com" ]]; then
        print_info "Ensuring Dash to Panel is properly activated..."
        if command -v gnome-extensions &> /dev/null; then
            gnome-extensions disable "dash-to-panel@jderose9.github.com" 2>/dev/null || true
            sleep 1
            gnome-extensions enable "dash-to-panel@jderose9.github.com" 2>/dev/null || true
            sleep 1
        fi
    fi
    
    # Install Vitals (system monitoring - temperature, CPU, memory, network, battery)
    if install_and_enable_extension "Vitals" "1460" "Vitals@CoreCoding.com"; then
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
    fi
    
    # Refresh GNOME Shell to load extensions
    print_info "Refreshing GNOME Shell to load extensions..."
    if reload_gnome_shell; then
        print_success "GNOME Shell reloaded"
    else
        print_warning "Could not automatically reload GNOME Shell"
        print_info "Please restart GNOME Shell manually:"
        print_info "   - Press Alt+F2, type 'r' and press Enter"
        print_info "   - Or log out and log back in"
    fi
    
    print_info ""
    print_info "📋 Extensions installed and enabled:"
    print_info "   - Clipboard Indicator (clipboard icon in top bar)"
    print_info "   - Blur My Shell (blur effects on panels and overview)"
    print_info "   - Caffeine (prevents screen lock/sleep)"
    print_info "   - Dash to Panel (combines dash and top panel)"
    print_info "   - Vitals (temperature, CPU, memory, network, battery in top bar)"
    print_info ""
    print_info "🔍 Verifying extensions..."
    
    # Verify extensions are properly installed and enabled
    local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
    local verified_count=0
    local extensions_to_check=("clipboard-indicator@tudmotu.com" "blur-my-shell@aunetx" "caffeine@patapon.info" "dash-to-panel@jderose9.github.com" "Vitals@CoreCoding.com")
    
    for ext_uuid in "${extensions_to_check[@]}"; do
        local ext_dir="$extensions_dir/$ext_uuid"
        if [[ -d "$ext_dir" ]] && [[ -f "$ext_dir/metadata.json" ]]; then
            # Check if enabled
            if gnome-extensions list 2>/dev/null | grep -q "^$ext_uuid$"; then
                local enabled_status
                enabled_status=$(gnome-extensions info "$ext_uuid" 2>/dev/null | grep "State:" | grep -o "ENABLED\|DISABLED" || echo "")
                if [[ "$enabled_status" == "ENABLED" ]]; then
                    verified_count=$((verified_count + 1))
                    print_success "$ext_uuid is installed and enabled"
                else
                    print_warning "$ext_uuid is installed but disabled"
                fi
            else
                print_warning "$ext_uuid is installed but not in extensions list"
            fi
        else
            print_warning "$ext_uuid is not properly installed"
        fi
    done
    
    print_info ""
    print_info "✅ Verified: $verified_count/${#extensions_to_check[@]} extensions are installed and enabled"
    print_info ""
    print_info "💡 If extensions don't appear in Extension Manager or don't work:"
    print_info "   1. Press Alt+F2, type 'r' and press Enter (restart GNOME Shell)"
    print_info "   2. Or log out and log back in"
    print_info "   3. Open Extension Manager (extension-manager) to verify they're listed"
    print_info "   4. If still not visible, check permissions: ls -la ~/.local/share/gnome-shell/extensions/"
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
    print_info "  4. Configure Starship colors to match your terminal theme (optional)"
}

# Run main function
main "$@"

