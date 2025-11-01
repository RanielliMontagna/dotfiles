#!/usr/bin/env bash

###############################################################################
# 07-dev-tools.sh
# 
# Install development tools (always installed)
# - Android Studio (latest)
# - DBeaver (database management tool)
# - Postman (API testing tool)
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
    echo -e "${BLUE}[dev-tools]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

main() {
    print_info "Installing development tools..."
    
    # Install Android Studio
    ANDROID_STUDIO_INSTALLED=false
    if command -v android-studio &> /dev/null || [[ -d "/opt/android-studio" ]] || [[ -d "$HOME/.local/share/applications/android-studio.desktop" ]] || [[ -d "$HOME/snap/android-studio" ]]; then
        print_info "Android Studio already installed"
        ANDROID_STUDIO_INSTALLED=true
    else
        print_info "Installing Android Studio..."
        
        # Check if snap is available
        if command -v snap &> /dev/null; then
            sudo snap install android-studio --classic
            print_success "Android Studio installed via snap"
            ANDROID_STUDIO_INSTALLED=true
        else
            print_warning "Snap not available, installing Android Studio manually..."
            
            # Install dependencies
            sudo apt-get update
            sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386
            
            # Download Android Studio
            ANDROID_STUDIO_VERSION=$(curl -s https://developer.android.com/studio | grep -oP 'android-studio-.*-linux\.tar\.gz' | head -1 | grep -oP '\d+\.\d+\.\d+' || echo "latest")
            ANDROID_STUDIO_DIR="/opt/android-studio"
            
            if [[ ! -d "$ANDROID_STUDIO_DIR" ]]; then
                print_info "Downloading Android Studio..."
                wget -O /tmp/android-studio.tar.gz "https://redirector.gvt1.com/edgedl/android/studio/ide-zips/${ANDROID_STUDIO_VERSION}/android-studio-${ANDROID_STUDIO_VERSION}-linux.tar.gz" 2>/dev/null || \
                wget -O /tmp/android-studio.tar.gz "https://dl.google.com/dl/android/studio/ide-zips/latest/android-studio-linux.tar.gz"
                
                sudo mkdir -p /opt
                sudo tar -xzf /tmp/android-studio.tar.gz -C /opt
                sudo mv /opt/android-studio-* "$ANDROID_STUDIO_DIR" 2>/dev/null || true
                
                # Create desktop entry
                cat <<EOF | sudo tee /usr/share/applications/android-studio.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Icon=$ANDROID_STUDIO_DIR/bin/studio.png
Exec="$ANDROID_STUDIO_DIR/bin/studio.sh" %f
Comment=The Official IDE for Android
Categories=Development;IDE;
Terminal=false
MimeType=text/x-java;
EOF
                
                sudo chmod +x /usr/share/applications/android-studio.desktop
                rm -f /tmp/android-studio.tar.gz
                print_success "Android Studio installed manually"
                ANDROID_STUDIO_INSTALLED=true
            fi
        fi
    fi
    
    # Setup Android SDK after installation
    if [[ "$ANDROID_STUDIO_INSTALLED" == "true" ]] || [[ -d "$HOME/Android/Sdk" ]] || [[ -d "$HOME/snap/android-studio/current/Android/Sdk" ]]; then
        print_info "Setting up Android SDK..."
        
        # Determine SDK location
        ANDROID_SDK_PATH=""
        if [[ -d "$HOME/Android/Sdk" ]]; then
            ANDROID_SDK_PATH="$HOME/Android/Sdk"
        elif [[ -d "$HOME/snap/android-studio/current/Android/Sdk" ]]; then
            ANDROID_SDK_PATH="$HOME/snap/android-studio/current/Android/Sdk"
        else
            # Create SDK directory
            ANDROID_SDK_PATH="$HOME/Android/Sdk"
            mkdir -p "$ANDROID_SDK_PATH"
            print_info "Created Android SDK directory: $ANDROID_SDK_PATH"
        fi
        
        # Find sdkmanager
        SDKMANAGER=""
        if [[ -f "$ANDROID_SDK_PATH/cmdline-tools/latest/bin/sdkmanager" ]]; then
            SDKMANAGER="$ANDROID_SDK_PATH/cmdline-tools/latest/bin/sdkmanager"
        elif [[ -d "$ANDROID_SDK_PATH/cmdline-tools" ]]; then
            # Find any version
            SDKMANAGER=$(find "$ANDROID_SDK_PATH/cmdline-tools" -name "sdkmanager" -type f | head -1)
        fi
        
        # If sdkmanager not found, install command-line tools
        if [[ -z "$SDKMANAGER" ]] || [[ ! -f "$SDKMANAGER" ]]; then
            print_info "Installing Android SDK Command-line Tools..."
            mkdir -p "$ANDROID_SDK_PATH/cmdline-tools"
            
            # Download command-line tools
            CMDLINE_TOOLS_ZIP="/tmp/cmdline-tools.zip"
            if curl -L -o "$CMDLINE_TOOLS_ZIP" "https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip" 2>/dev/null || \
               curl -L -o "$CMDLINE_TOOLS_ZIP" "https://dl.google.com/android/repository/commandlinetools-latest-linux.zip" 2>/dev/null; then
                unzip -q "$CMDLINE_TOOLS_ZIP" -d "$ANDROID_SDK_PATH/cmdline-tools"
                mv "$ANDROID_SDK_PATH/cmdline-tools/cmdline-tools" "$ANDROID_SDK_PATH/cmdline-tools/latest" 2>/dev/null || true
                rm -f "$CMDLINE_TOOLS_ZIP"
                
                SDKMANAGER="$ANDROID_SDK_PATH/cmdline-tools/latest/bin/sdkmanager"
                if [[ -f "$SDKMANAGER" ]]; then
                    print_success "Android SDK Command-line Tools installed"
                fi
            else
                print_warning "Could not download Android SDK Command-line Tools"
                print_info "You can install them manually from Android Studio later"
            fi
        fi
        
        # Configure and install SDK components if sdkmanager is available
        if [[ -n "$SDKMANAGER" ]] && [[ -f "$SDKMANAGER" ]]; then
            print_info "Configuring Android SDK..."
            
            # Ensure Java is available (SDKMAN should already be loaded, but just in case)
            if command -v java &> /dev/null; then
                print_info "Java found: $(java -version 2>&1 | head -n1)"
            else
                # Try to load SDKMAN if available
                if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
                    source "$HOME/.sdkman/bin/sdkman-init.sh" || true
                fi
            fi
            
            # Accept licenses
            print_info "Accepting Android SDK licenses..."
            yes | "$SDKMANAGER" --licenses > /dev/null 2>&1 || {
                print_info "Accepting licenses interactively..."
                "$SDKMANAGER" --licenses || true
            }
            
            # Install essential SDK components
            print_info "Installing essential Android SDK components (this may take a few minutes)..."
            "$SDKMANAGER" --update || true
            
            # Install platform-tools, build-tools, and latest platform
            COMPONENTS=(
                "platform-tools"
                "build-tools;34.0.0"
                "platforms;android-34"
                "platforms;android-33"
                "sources;android-34"
            )
            
            for component in "${COMPONENTS[@]}"; do
                print_info "Installing $component..."
                "$SDKMANAGER" "$component" > /dev/null 2>&1 || "$SDKMANAGER" "$component" || true
            done
            
            # Install emulator separately (optional, can take longer)
            print_info "Installing Android Emulator (optional, this may take a while)..."
            "$SDKMANAGER" "emulator" > /dev/null 2>&1 || {
                print_warning "Emulator installation skipped (can be installed later)"
            }
            
            # Set environment variables (will be added to .zshrc by shell script)
            export ANDROID_HOME="$ANDROID_SDK_PATH"
            export ANDROID_SDK_ROOT="$ANDROID_SDK_PATH"
            export PATH="$PATH:$ANDROID_SDK_PATH/platform-tools:$ANDROID_SDK_PATH/tools"
            
            print_success "Android SDK setup completed"
            print_info "SDK Location: $ANDROID_SDK_PATH"
            print_info "Environment variables will be set in your shell after restart"
        else
            print_warning "Android Studio installed but SDK setup requires manual configuration"
            print_info "Please open Android Studio and complete the initial setup wizard"
            print_info "The SDK will be configured automatically during first launch"
        fi
    fi
    
    # Install DBeaver
    if command -v dbeaver &> /dev/null; then
        print_info "DBeaver already installed ($(dbeaver --version 2>/dev/null | head -1 || echo 'installed'))"
    else
        print_info "Installing DBeaver..."
        
        # Check if snap is available
        if command -v snap &> /dev/null; then
            sudo snap install dbeaver-ce
            print_success "DBeaver installed via snap"
        else
            print_warning "Snap not available, installing DBeaver manually..."
            
            # Download DBeaver .deb
            DBEAVER_DEB="/tmp/dbeaver.deb"
            curl -L -o "$DBEAVER_DEB" "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" || \
            curl -L -o "$DBEAVER_DEB" "https://github.com/dbeaver/dbeaver/releases/latest/download/dbeaver-ce_latest_amd64.deb"
            
            if [[ -f "$DBEAVER_DEB" ]]; then
                sudo dpkg -i "$DBEAVER_DEB" || sudo apt-get install -f -y
                rm -f "$DBEAVER_DEB"
                print_success "DBeaver installed"
            else
                print_warning "Could not download DBeaver. Please install manually from https://dbeaver.io"
            fi
        fi
    fi
    
    # Install Postman
    if command -v postman &> /dev/null; then
        print_info "Postman already installed"
    else
        print_info "Installing Postman..."
        if command -v snap &> /dev/null; then
            sudo snap install postman
            print_success "Postman installed"
        else
            print_warning "Snap not available, trying alternative installation..."
            
            # Try to install via apt if available
            if curl -fsSL https://dl.pstmn.io/download/latest/linux64 -o /tmp/postman.tar.gz; then
                sudo mkdir -p /opt
                sudo tar -xzf /tmp/postman.tar.gz -C /opt
                
                # Create desktop entry
                cat <<EOF | sudo tee /usr/share/applications/postman.desktop
[Desktop Entry]
Type=Application
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Categories=Development;
EOF
                
                sudo chmod +x /usr/share/applications/postman.desktop
                sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman
                rm -f /tmp/postman.tar.gz
                print_success "Postman installed"
            else
                print_warning "Could not download Postman. Please install manually from https://www.postman.com/downloads/"
            fi
        fi
    fi
    
    print_success "Development tools installed successfully!"
}

main "$@"

