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
    if command -v android-studio &> /dev/null || [[ -d "/opt/android-studio" ]] || [[ -d "$HOME/.local/share/applications/android-studio.desktop" ]]; then
        print_info "Android Studio already installed"
    else
        print_info "Installing Android Studio..."
        
        # Check if snap is available
        if command -v snap &> /dev/null; then
            sudo snap install android-studio --classic
            print_success "Android Studio installed via snap"
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
            fi
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

