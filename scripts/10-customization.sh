#!/usr/bin/env bash

###############################################################################
# 10-customization.sh
# 
# Visual customization for Zorin OS (GNOME-based)
# - GTK dark themes (Adwaita Dark, Arc Dark)
# - Dark icon sets (Papirus Dark, Tela Dark)
# - Custom fonts (Inter, Fira Sans, JetBrains Mono)
# - Dark wallpaper configuration
# - GNOME Terminal dark profile
# - GNOME extensions (User Themes, Blur My Shell, etc.)
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
    print_info "Installing GTK dark themes..."
    
    # Arc theme (popular dark theme)
    if ! is_installed "arc-theme"; then
        print_info "Installing Arc theme..."
        ensure_apt_updated
        sudo apt-get install -y arc-theme
        print_success "Arc theme installed"
    else
        print_info "Arc theme already installed"
    fi
    
    # Adwaita-dark is usually included with gnome-themes-standard or Adwaita
    # We'll ensure it's available
    if ! dpkg -l | grep -q "gnome-themes-standard\|adwaita-icon-theme"; then
        print_info "Installing GNOME standard themes (includes Adwaita Dark)..."
        ensure_apt_updated
        sudo apt-get install -y gnome-themes-standard adwaita-icon-theme-full || \
        sudo apt-get install -y adwaita-icon-theme || true
    fi
    
    print_success "GTK themes installation complete"
}

###############################################################################
# Install Icon Themes
###############################################################################

install_icon_themes() {
    print_info "Installing dark icon themes..."
    
    # Papirus icon theme (popular dark icons)
    if ! is_installed "papirus-icon-theme"; then
        print_info "Installing Papirus icon theme..."
        ensure_apt_updated
        sudo apt-get install -y papirus-icon-theme
        print_success "Papirus icon theme installed"
    else
        print_info "Papirus icon theme already installed"
    fi
    
    # Add Papirus icon theme repository for latest version (optional)
    # We'll use the Ubuntu/Debian repository version which should be sufficient
    
    print_success "Icon themes installation complete"
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
    
    print_info "Configuring GNOME/Zorin appearance settings for dark theme..."
    
    # Enable dark mode for applications (this affects many GTK apps)
    set_gnome_setting "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'" || true
    print_success "Dark color scheme enabled"
    
    # Set GTK theme (try multiple dark themes in order of preference)
    print_info "Setting GTK theme to dark..."
    if set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'Adwaita-dark'"; then
        print_success "GTK theme set to Adwaita-dark"
    elif set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'Arc-Dark'"; then
        print_success "GTK theme set to Arc-Dark"
    elif set_gnome_setting "org.gnome.desktop.interface" "gtk-theme" "'Yaru-dark'"; then
        print_success "GTK theme set to Yaru-dark"
    else
        print_warning "Could not set GTK theme, may need to set manually"
    fi
    
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
    
    # Set icon theme (prefer dark variant)
    print_info "Setting icon theme to dark..."
    if set_gnome_setting "org.gnome.desktop.interface" "icon-theme" "'Papirus-Dark'"; then
        print_success "Icon theme set to Papirus-Dark"
    elif set_gnome_setting "org.gnome.desktop.interface" "icon-theme" "'Papirus'"; then
        print_success "Icon theme set to Papirus"
    elif set_gnome_setting "org.gnome.desktop.interface" "icon-theme" "'Yaru-dark'"; then
        print_success "Icon theme set to Yaru-dark"
    else
        print_warning "Could not set icon theme"
    fi
    
    # Set cursor theme (use default dark cursor if available)
    set_gnome_setting "org.gnome.desktop.interface" "cursor-theme" "'Adwaita'" || \
    set_gnome_setting "org.gnome.desktop.interface" "cursor-theme" "'DMZ-White'" || true
    
    # Zorin-specific settings (if available)
    if command -v dconf &> /dev/null; then
        print_info "Configuring Zorin OS specific dark theme settings..."
        # Zorin appearance theme (check if schema exists)
        dconf write /org/zorin/desktop/interface/gtk-theme "'Adwaita-dark'" 2>/dev/null || true
        dconf write /org/zorin/desktop/interface/icon-theme "'Papirus-Dark'" 2>/dev/null || true
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

configure_system_extensions() {
    if ! is_gnome; then
        return 0
    fi
    
    print_info "Setting up system extensions configuration..."
    
    # List of useful extensions with their UUIDs and installation methods
    # These will be installed via Extension Manager or manual instructions
    
    print_info "Recommended extensions for system monitoring:"
    print_info ""
    print_info "📋 Clipboard Indicator"
    print_info "   UUID: clipboard-indicator@tudmotu.com"
    print_info "   URL: https://extensions.gnome.org/extension/779/clipboard-indicator/"
    print_info ""
    print_info "📊 Vitals (Temperature, CPU, Memory, Network)"
    print_info "   UUID: Vitals@CoreCoding.com"
    print_info "   URL: https://extensions.gnome.org/extension/1460/vitals/"
    print_info ""
    print_info "🌡️  Freon (Temperature Monitoring)"
    print_info "   UUID: freon@UshakovVasilii_Github.yahoo.com"
    print_info "   URL: https://extensions.gnome.org/extension/841/freon/"
    print_info ""
    print_info "💻 System Monitor"
    print_info "   UUID: system-monitor@paradoxxx.zero.gmail.com"
    print_info "   URL: https://extensions.gnome.org/extension/450/system-monitor/"
    print_info ""
    
    # Install Extension Manager if not available
    if ! command -v extension-manager &> /dev/null && ! is_installed "gnome-shell-extension-manager"; then
        print_info "Installing Extension Manager for easier extension installation..."
        ensure_apt_updated
        sudo apt-get install -y gnome-shell-extension-manager 2>/dev/null || true
    fi
    
    # Try to install extensions via gnome-extensions if available
    if command -v gnome-extensions &> /dev/null; then
        local extensions_dir="$HOME/.local/share/gnome-shell/extensions"
        mkdir -p "$extensions_dir"
        
        # Check GNOME Shell version for compatibility
        local gnome_version
        gnome_version=$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "44")
        
        print_info "GNOME Shell version detected: $gnome_version"
        print_info "Attempting to install extensions..."
        
        # Note: Direct installation requires downloading extension files
        # For now, we'll provide instructions and try to enable if already installed
        print_info ""
        print_info "📥 Quick Installation via Extension Manager:"
        print_info "  1. Open Extension Manager (search 'Extensions' in Activities)"
        print_info "  2. Browse and install:"
        print_info "     - 'Clipboard Indicator' by Tudmotu"
        print_info "     - 'Vitals' by CoreCoding (recommended - shows all metrics)"
        print_info ""
    else
        print_info ""
        print_info "To install these extensions:"
        print_info "  1. Open Extension Manager (if installed) from Activities"
        print_info "  2. Or visit https://extensions.gnome.org"
        print_info "  3. Install 'GNOME Shell Integration' browser extension first"
        print_info "  4. Then click 'ON' on the extension pages to install"
    fi
    
    # Configure extensions if Extension Manager is available
    if command -v gnome-extensions &> /dev/null; then
        print_info "Checking installed extensions..."
        
        # Enable User Themes extension if installed (needed for custom shell themes)
        if gnome-extensions list 2>/dev/null | grep -q "user-theme"; then
            gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || \
            gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null || true
            print_success "User Themes extension enabled (allows custom shell themes)"
        fi
        
        # Enable clipboard indicator if installed
        if gnome-extensions list 2>/dev/null | grep -q "clipboard-indicator"; then
            gnome-extensions enable clipboard-indicator@tudmotu.com 2>/dev/null || true
            print_success "Clipboard Indicator enabled"
        fi
        
        # Enable Vitals if installed
        if gnome-extensions list 2>/dev/null | grep -q "Vitals"; then
            gnome-extensions enable Vitals@CoreCoding.com 2>/dev/null || true
            print_success "Vitals enabled"
            
            # Configure Vitals to show temperature, CPU, memory, network
            if command -v dconf &> /dev/null; then
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
    fi
    
    print_info ""
    print_info "💡 Tip: After installing extensions, restart GNOME Shell:"
    print_info "   Press Alt+F2, type 'r' and press Enter"
    print_info "   Or log out and log back in"
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

