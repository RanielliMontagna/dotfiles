# dotfiles (Zorin OS)

Automated setup for a fresh **Zorin OS** machine. Run **one command** after installing the OS and get your full development environment ready with modern tools, optimized shell, and sensible defaults.

> 🎯 **Zorin-first**: Since Zorin is Ubuntu-based, everything uses `apt` and official Ubuntu/Debian repositories.

---

## ✨ Features

- 🐧 **Zorin/Ubuntu friendly** - Optimized for Ubuntu-based distributions
- 🔁 **Idempotent** - Safe to run multiple times without breaking anything
- 🧰 **Essential tools** - Git, curl, build-essential, modern CLI tools (ripgrep, bat, fzf)
- 🐚 **Modern shell** - Zsh + Oh My Zsh + Powerlevel10k theme + useful plugins
- � **Node.js LTS** - Via NVM with global packages (TypeScript)
- 📝 **Code editors** - VS Code and Cursor (always installed)
- 🐳 **Docker** - Latest stable from official repository (always installed)
- ☕ **Java SDK** - Versions 8, 11, 17, LTS via SDKMAN (always installed)
- 🛠️ **Dev tools** - Android Studio, DBeaver, Postman (always installed)
- 🌐 **Applications** - Chrome, Brave, Firefox, Steam, Spotify, Discord, OBS Studio, NordVPN, Bitwarden (always installed)
- 🔧 **Extras** - GitHub CLI, database clients (optional)
- 📦 **Modular scripts** - Organized by function, easy to customize
- 📚 **Well documented** - AI-friendly docs with architecture and version info
- ⚡ **Always updated** - Uses LTS and latest stable versions from official sources
- 🛡️ **Robust downloads** - Timeouts, retries, and connectivity checks prevent hanging
- 🔐 **Automatic sudo renewal** - No password prompts during long installations

---

## 🚀 Quick Start

### Method 1: Clone and Run (Recommended)

```bash
# Clone the repository
git clone https://github.com/RanielliMontagna/dotfiles.git
cd dotfiles

# Run the bootstrap script
bash bootstrap.sh
```

### Method 2: One-Line Install

```bash
# Download and run directly (be careful with this approach!)
curl -fsSL https://raw.githubusercontent.com/RanielliMontagna/dotfiles/main/bootstrap.sh | bash
```

> ⚠️ **Note**: Always review scripts before running them on your system!

---

## 📋 What Gets Installed

### Core Tools (Always Installed)

- **Build essentials**: GCC, G++, make, and compilation tools
- **Version control**: Git, Git LFS
- **Network tools**: curl, wget, ca-certificates, net-tools
- **Modern CLI**: ripgrep, bat, fd-find, fzf, htop, tree, jq
- **System tools**: GParted (partition editor)
- **System monitoring**: htop, lm-sensors, nvtop
- **Editor**: nano (text editor)

### Shell Environment (Always Installed)

- **Zsh**: Modern shell with better features than bash
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Plugins**:
  - zsh-autosuggestions (command suggestions)
  - zsh-syntax-highlighting (real-time syntax check)
  - git, docker, node (completions and helpers)
- **Theme**: Powerlevel10k (beautiful and informative prompt)

### Node.js (Always Installed)

- **NVM**: Latest version from GitHub
- **Node.js**: LTS version (Long Term Support - most stable)
- **Global packages**: yarn, pnpm, bun, TypeScript, npm-check-updates

### Code Editors (Always Installed)

- **VS Code**: Latest stable from Microsoft repository
- **Cursor**: AI-powered code editor (latest from official website)

### Docker (Always Installed)

- **Docker Engine**: Latest stable from official Docker repository
- **Docker Compose**: V2 plugin
- **Buildx**: Build with BuildKit
- User added to docker group (no sudo needed)

### Java SDK (Always Installed)

- **SDKMAN**: Java version manager
- **Java SDK**: Versions 8, 11, 17, and LTS (21)
- Java 17 set as default

### Development Tools (Always Installed)

- **Android Studio**: Latest stable from Google
- **DBeaver**: Database management tool
- **Postman**: API testing tool

### Applications (Always Installed)

- **Browsers**:
  - Google Chrome (latest stable)
  - Brave Browser (latest stable)
  - Firefox (latest from Ubuntu repos)
- **Gaming & Entertainment**:
  - Steam (gaming platform)
  - Spotify (music streaming)
  - Discord (chat and communication)
- **Media & Streaming**:
  - OBS Studio (streaming and recording)
- **VPN**:
  - NordVPN (VPN service)
- **Security**:
  - Bitwarden (password manager)

### Extra Tools (Optional)

- **Languages**: Python 3 with pip
- **Git tools**: GitHub CLI (gh)
- **Databases**: PostgreSQL client, SQLite, Redis CLI
- **HTTP**: HTTPie

---

## 🚀 Recent Improvements

The project has been enhanced with **high-priority improvements** for better reliability:

- ✅ **Download timeouts and retries** - All downloads now have timeouts (300-600s) and automatic retries (3 attempts) to prevent hanging
- ✅ **Internet connectivity check** - Verifies connection before starting installation
- ✅ **Automatic sudo renewal** - Keeps sudo credentials active during long installations
- ✅ **Shared functions** - New `scripts/common.sh` provides reusable functions for all scripts, reducing code duplication

These improvements make the installation process more robust and prevent common issues like hanging downloads or expired sudo passwords.

---

## 📚 Documentation

- **README.md** - Complete user guide (this file)
- **PROJECT.md** - Project overview and AI context

---

## 🔧 Configuration Files

All configuration files are in the `dotfiles/` directory and are symlinked to your home:

- **`.zshrc`** - Zsh configuration with plugins, theme, and custom functions
- **`.gitconfig`** - Git aliases, better diffs, and conditional includes
- **`.aliases`** - Hundreds of useful aliases for Git, Docker, npm, and more

### Git Configuration with Conditional Includes

The Git configuration uses `includeIf` to automatically load different settings based on project location:

- **`~/.gitconfig`** - Main configuration (symlinked, contains common aliases and settings)
- **`~/.gitconfig-my`** - Personal projects configuration (auto-created)
  - Used for: `~/www/personal/`
  - Pre-configured with your personal name, email, and SSH settings

After installation, your existing files will be backed up to `~/.filename.backup`.

### Project Directories

The setup automatically creates the following project directory for personal projects:

- `~/www/personal/`

---

## 📦 Version Policy

This setup follows a **"always use latest stable/LTS"** approach:

| Component       | Version Strategy                      |
| --------------- | ------------------------------------- |
| System packages | Latest from Ubuntu repos              |
| Node.js         | **LTS** (Long Term Support)           |
| NVM             | Latest from GitHub                    |
| Bun             | Latest stable from official installer |
| Docker          | Latest stable from official repo      |
| VS Code         | Latest stable (auto-updates)          |
| Cursor          | Latest from official website          |
| Java (SDKMAN)   | Versions 8, 11, 17, LTS (21)          |
| Android Studio  | Latest stable                         |
| npm packages    | Latest stable                         |

All tools use LTS or latest stable versions from official sources.

---

## 🎯 Post-Installation

After running the bootstrap script:

### 1. Restart Your Terminal

```bash
# Or reload the shell config
source ~/.zshrc
```

### 2. Configure Git (Optional - Personal projects already configured)

Personal projects in `~/www/personal/` are already configured with:

- Name: Ranielli Montagna
- Email: raniellimontagna@hotmail.com
- SSH: Uses `ssh://git@github.com/` instead of `https://github.com/`

If you need to add work projects later, you can create a new config file (e.g., `~/.gitconfig-work`) and add an `includeIf` entry in `~/.gitconfig` pointing to it.

### 3. Powerlevel10k Theme

Powerlevel10k is already pre-configured and ready to use! The prompt will work immediately after restarting your terminal.

To customize it later, run:

```bash
p10k configure
```

### 4. (Optional) Authenticate GitHub CLI

```bash
gh auth login
```

### 5. Switch Java Versions (if needed)

```bash
# List installed Java versions
sdk list java

# Switch to a specific version
sdk use java 17.0.9-tem

# Set default version
sdk default java 17.0.9-tem
```

### 6. Configure NordVPN (if needed)

```bash
# Login to your NordVPN account
nordvpn login

# Connect to VPN
nordvpn connect

# Check status
nordvpn status
```

### 7. (Optional) Log Out and Back In

Required for Docker group permissions and NordVPN to take effect.

---

## 🔄 Updating

### Update System Packages

```bash
sudo apt update && sudo apt upgrade -y
```

### Update Node.js to Latest LTS

```bash
nvm install --lts
nvm alias default lts/*
```

### Update Global npm Packages

```bash
npm update -g
```

### Update Bun

```bash
bun upgrade
```

### Update Oh My Zsh and Plugins

```bash
omz update

# Update plugins manually
cd ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && git pull
cd ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && git pull
cd ~/.oh-my-zsh/custom/themes/powerlevel10k && git pull
```

### Update Docker

```bash
sudo apt update && sudo apt upgrade docker-ce
```

### Update Java Versions

```bash
# Update SDKMAN
sdk update

# Install newer versions
sdk install java <version>

# Switch versions
sdk use java <version>
```

### Update Android Studio

```bash
# If installed via snap
sudo snap refresh android-studio

# If installed manually, download latest from https://developer.android.com/studio
```

### Update Applications

```bash
# Update Chrome (auto-updates enabled)
# Update Brave Browser
sudo apt update && sudo apt upgrade brave-browser

# Update Firefox
sudo apt update && sudo apt upgrade firefox

# Update Steam (if via snap)
sudo snap refresh steam

# Update Spotify (if via snap)
sudo snap refresh spotify

# Update Discord (if via snap)
sudo snap refresh discord

# Update OBS Studio (if via snap)
sudo snap refresh obs-studio

# Update NordVPN
nordvpn update

# Update Bitwarden (if via snap)
sudo snap refresh bitwarden
```

---

## 🛠️ Customization

### Add Your Own Aliases

Edit `~/.aliases` (symlinked to `dotfiles/.aliases`):

```bash
nano ~/.aliases
# Then reload
source ~/.zshrc
```

### Install Additional Node Versions

```bash
nvm install 18      # Install Node.js 18
nvm install 20      # Install Node.js 20
nvm use 18          # Switch to Node.js 18
nvm alias default 20  # Set Node.js 20 as default
```

### Add More Scripts

Create a new script in `scripts/`, e.g., `09-my-tools.sh`:

```bash
#!/usr/bin/env bash
set -e
# Your installation logic here
```

Then add it to `bootstrap.sh`.

---

## 🧪 Testing

Before running on your main machine, test in a VM:

### Option 1: VirtualBox/VMware

1. Create a new VM with Zorin OS
2. Clone this repo
3. Run `bash bootstrap.sh`
4. Verify everything works
5. Run again to test idempotency

### Option 2: Docker Container

```bash
# Start Ubuntu container (similar to Zorin)
docker run -it ubuntu:22.04 bash

# Inside container:
apt update && apt install -y git
git clone https://github.com/RanielliMontagna/dotfiles.git
cd dotfiles
bash bootstrap.sh
```

### Option 3: Testing a Specific Branch

To test changes from a specific branch (e.g., before merging to main):

**Method 1: Local Repository (Recommended for Development)**

```bash
# If you already have the repo cloned locally
cd dotfiles
git checkout fix/minor-adjustments  # or your branch name
git pull origin fix/minor-adjustments
bash bootstrap.sh  # Uses local files from current branch
```

**Method 2: Clone Specific Branch**

```bash
# Clone the specific branch
git clone -b fix/minor-adjustments https://github.com/RanielliMontagna/dotfiles.git
cd dotfiles
bash bootstrap.sh
```

**Method 3: One-Line Install from Branch (Testing Only)**

```bash
# Download and run bootstrap.sh from a specific branch
curl -fsSL https://raw.githubusercontent.com/RanielliMontagna/dotfiles/fix/minor-adjustments/bootstrap.sh | bash
```

> ⚠️ **Warning**: Always review the code before running scripts from untested branches!

---

## 🐛 Troubleshooting

### Zsh not default shell after installation

```bash
chsh -s $(which zsh)
# Then log out and log back in
```

### Docker permission denied

```bash
# Make sure you're in docker group
groups

# If not, add yourself
sudo usermod -aG docker $USER
# Then log out and log back in
```

### NVM command not found

```bash
# Make sure NVM is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Or restart your terminal
```

### Oh My Zsh plugins not working

```bash
# Check if plugins are installed
ls ~/.oh-my-zsh/custom/plugins/

# Reinstall if needed
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

---

## 📖 Useful Commands

### Show All Aliases

```bash
aliases  # or show-aliases
```

### Check Installed Versions

```bash
node --version
npm --version
yarn --version
pnpm --version
bun --version
docker --version
java --version
git --version
zsh --version
sdk version  # SDKMAN version
google-chrome --version  # or chrome --version
brave-browser --version
firefox --version
steam --version 2>/dev/null || echo "Steam installed"
spotify --version 2>/dev/null || echo "Spotify installed"
discord --version 2>/dev/null || echo "Discord installed"
obs --version 2>/dev/null || echo "OBS Studio installed"
nordvpn --version
bitwarden --version 2>/dev/null || echo "Bitwarden installed"
```

### Clean Up Docker

```bash
docker system prune -a  # Remove unused images, containers, networks
```

### Update Everything

```bash
# System
sudo apt update && sudo apt upgrade -y

# Node.js globals
npm update -g

# Oh My Zsh
omz update
```

---

## 🤝 Contributing

This is a personal dotfiles repo, but feel free to:

- Fork it and adapt to your needs
- Open issues for bugs
- Suggest improvements via PR

---

## 📝 License

MIT - Use freely, modify as needed.

---

## 🙏 Credits

Built with these amazing tools:

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [NVM](https://github.com/nvm-sh/nvm)
- [SDKMAN](https://sdkman.io/)
- [Docker](https://www.docker.com/)
- [Android Studio](https://developer.android.com/studio)
- [DBeaver](https://dbeaver.io/)
- And many more open-source projects!

---

**Happy coding! 🚀**
