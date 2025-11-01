# dotfiles (Zorin OS)

Automated setup for a fresh **Zorin OS** machine. Run **one command** after installing the OS and get your full development environment ready with modern tools, optimized shell, and sensible defaults.

> 🎯 **Zorin-first**: Since Zorin is Ubuntu-based, everything uses `apt` and official Ubuntu/Debian repositories.

---

## ✨ Features

- 🐧 **Zorin/Ubuntu friendly** - Optimized for Ubuntu-based distributions
- 🔁 **Idempotent** - Safe to run multiple times without breaking anything
- 🧰 **Essential tools** - Git, curl, build-essential, modern CLI tools (ripgrep, bat, fzf)
- 🐚 **Modern shell** - Zsh + Oh My Zsh + Powerlevel10k theme + useful plugins
- � **Node.js LTS** - Via NVM with global packages (TypeScript, ESLint, Prettier)
- 🐳 **Docker** - Latest stable from official repository (optional)
- 🛠️ **Dev tools** - VS Code, GitHub CLI, database clients (optional)
- 📦 **Modular scripts** - Organized by function, easy to customize
- 📚 **Well documented** - AI-friendly docs with architecture and version info
- ⚡ **Always updated** - Uses LTS and latest stable versions from official sources

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
- **Network tools**: curl, wget, ca-certificates
- **Modern CLI**: ripgrep, bat, fd-find, fzf, htop, tree, jq
- **Editors**: vim, neovim

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
- **Global packages**: yarn, pnpm, TypeScript, ts-node, nodemon, pm2, ESLint, Prettier

### Docker (Optional)

- **Docker Engine**: Latest stable from official Docker repository
- **Docker Compose**: V2 plugin
- **Buildx**: Build with BuildKit
- User added to docker group (no sudo needed)

### Extra Tools (Optional)

- **Languages**: Python 3 with pip
- **Git tools**: GitHub CLI (gh)
- **Databases**: PostgreSQL client, SQLite, Redis CLI
- **HTTP**: HTTPie, Postman
- **Editors**: VS Code (latest stable)

---

## 📚 Documentation

- **README.md** - Complete user guide (this file)
- **PROJECT.md** - Project overview and AI context

---

## 🔧 Configuration Files

All configuration files are in the `dotfiles/` directory and are symlinked to your home:

- **`.zshrc`** - Zsh configuration with plugins, theme, and custom functions
- **`.gitconfig`** - Git aliases, better diffs, and sensible defaults
- **`.aliases`** - Hundreds of useful aliases for Git, Docker, npm, and more

After installation, your existing files will be backed up to `~/.filename.backup`.

---

## 📦 Version Policy

This setup follows a **"always use latest stable/LTS"** approach:

| Component       | Version Strategy                 |
| --------------- | -------------------------------- |
| System packages | Latest from Ubuntu repos         |
| Node.js         | **LTS** (Long Term Support)      |
| NVM             | Latest from GitHub               |
| Docker          | Latest stable from official repo |
| VS Code         | Latest stable (auto-updates)     |
| npm packages    | Latest stable                    |

All tools use LTS or latest stable versions from official sources.

---

## 🎯 Post-Installation

After running the bootstrap script:

### 1. Restart Your Terminal

```bash
# Or reload the shell config
source ~/.zshrc
```

### 2. Configure Git with Your Details

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 3. Configure Powerlevel10k Theme

```bash
p10k configure
```

This will guide you through customizing your prompt appearance.

### 4. (Optional) Authenticate GitHub CLI

```bash
gh auth login
```

### 5. (Optional) Log Out and Back In

Required for Docker group permissions to take effect.

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

---

## 🛠️ Customization

### Add Your Own Aliases

Edit `~/.aliases` (symlinked to `dotfiles/.aliases`):

```bash
vim ~/.aliases
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

Create a new script in `scripts/`, e.g., `06-my-tools.sh`:

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
docker --version
git --version
zsh --version
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
- [Docker](https://www.docker.com/)
- And many more open-source projects!

---

**Happy coding! 🚀**
