# dotfiles – Zorin OS Dev Environment

**Purpose**: Automated setup for a fresh **Zorin OS** machine. Run **one command** → get a full development environment.

**Target OS**: Zorin OS (Ubuntu-based Linux distribution)

**Repository**: https://github.com/RanielliMontagna/dotfiles

---

## Quick Context for AI Assistants

This file provides context for AI agents (ChatGPT, Claude, etc.) to understand the project structure, help generate scripts, improve existing code, or fix issues.

**Key Principles**:

- **Idempotent**: All scripts check before installing - safe to run multiple times
- **Modular**: Scripts are numbered (01-05) and separated by concern
- **Official Sources**: Always use official repositories and LTS versions when available
- **Zorin-first**: Uses `apt` and Ubuntu/Debian repositories

---

## Project Structure

```
dotfiles/
├── bootstrap.sh              # Main orchestration script
├── scripts/                  # Installation scripts (executed in order)
│   ├── 01-essentials.sh     # System tools, build essentials, CLI tools
│   ├── 02-shell.sh          # Zsh + Oh My Zsh + Powerlevel10k + plugins
│   ├── 03-nodejs.sh         # NVM + Node.js LTS + global npm packages
│   ├── 04-editors.sh         # VS Code + Cursor (always installed)
│   ├── 05-docker.sh          # Docker Engine (always installed)
│   ├── 06-java.sh            # Java SDK via SDKMAN (always installed)
│   ├── 07-dev-tools.sh      # Android Studio, DBeaver, Postman (always installed)
│   └── 08-extras.sh          # Python, GitHub CLI, databases (optional)
├── dotfiles/                 # Configuration files (symlinked to ~/)
│   ├── .zshrc               # Zsh configuration with plugins and theme
│   ├── .gitconfig           # Git aliases and sensible defaults
│   └── .aliases             # Shell aliases organized by category
├── PROJECT.md               # This file (AI context)
└── README.md                 # User documentation
```

**Note**: This project uses `release-please` for automatic changelog generation on releases. Don't manually create/update CHANGELOG.md.

---

## Script Details

### bootstrap.sh

**Purpose**: Main entry point that orchestrates all installation scripts.

**Behavior**:

- Checks OS compatibility (Zorin/Ubuntu)
- Executes scripts 01-07 always
- Prompts user for script 08 (Extras)
- Makes all scripts executable
- Provides colored output (info, success, warning, error)
- Exits on error (`set -e`)

**Location**: Root directory

---

### 01-essentials.sh

**Purpose**: Install core system tools and dependencies.

**Installs**:

- **Build tools**: `build-essential` (gcc, g++, make)
- **Version control**: `git`
- **Network**: `curl`, `wget`, `ca-certificates`, `gnupg`
- **System utils**: `lsb-release`, `software-properties-common`, `apt-transport-https`
- **Archives**: `unzip`, `zip`
- **Modern CLI tools**:
  - `ripgrep` (rg) - Fast grep alternative
  - `bat` - Cat with syntax highlighting
  - `fd-find` (fd) - Fast find alternative
  - `fzf` - Fuzzy finder
  - `htop` - Interactive process viewer
  - `tree` - Directory structure display
  - `jq` - JSON processor
- **Editor**: `nano` - Simple text editor
- **Terminal**: `tmux`

**Idempotency**: Checks via `dpkg -l` before installing

**Source**: Ubuntu repositories via `apt-get`

---

### 02-shell.sh

**Purpose**: Set up modern Zsh shell environment with Oh My Zsh framework.

**Installs**:

- **Zsh**: Latest from Ubuntu repos
- **Oh My Zsh**: Framework for managing Zsh (via curl install script)
- **Plugins**:
  - `zsh-autosuggestions` (from zsh-users/zsh-autosuggestions)
  - `zsh-syntax-highlighting` (from zsh-users/zsh-syntax-highlighting)
  - Built-in: `git`, `docker`, `node`
- **Theme**: `powerlevel10k` (from romkatv/powerlevel10k)

**Configuration**:

- Symlinks dotfiles from `dotfiles/` to `~/`
- Backs up existing files with `.backup` suffix
- Sets Zsh as default shell (`chsh -s $(which zsh)`)

**Files symlinked**:

- `dotfiles/.zshrc` → `~/.zshrc`
- `dotfiles/.gitconfig` → `~/.gitconfig`
- `dotfiles/.aliases` → `~/.aliases`

**Idempotency**: Checks for `.oh-my-zsh` directory and plugin directories

---

### 03-nodejs.sh

**Purpose**: Install Node.js via NVM (Node Version Manager) with global packages.

**Installs**:

- **NVM**: Latest version from GitHub (https://github.com/nvm-sh/nvm)
  - Fetches latest release tag via GitHub API
  - Installs to `$HOME/.nvm`
- **Node.js**: LTS version (Long Term Support)
  - Sets LTS as default via `nvm alias default 'lts/*'`
- **Global npm packages**:
  - `yarn` - Alternative package manager
  - `pnpm` - Fast, disk-efficient package manager
  - `typescript` - TypeScript compiler
  - `ts-node` - TypeScript execution engine
  - `nodemon` - Development file watcher
  - `pm2` - Production process manager
  - `eslint` - JavaScript linter
  - `prettier` - Code formatter

**Configuration**:

- Configures npm for optimal performance (cache, registry)
- Adds NVM initialization to `.zshrc` (via dotfiles symlink)

**Idempotency**: Checks for `$HOME/.nvm` directory, loads NVM to check version

**Source**:

- NVM: GitHub releases
- Node.js: Via NVM (nodejs.org)
- npm packages: npm registry

---

### 04-editors.sh

**Purpose**: Install code editors (always installed).

**Installs**:

- **VS Code**: Latest stable from Microsoft repository
  - Adds Microsoft GPG key
  - Adds VS Code repository to apt sources
  - Installs via `apt install code`
- **Cursor**: AI-powered code editor
  - Downloads latest .deb package from official website
  - Installs via `dpkg` with dependency resolution
  - Falls back to manual installation instructions if download fails

**Idempotency**: Checks `command -v code` and `command -v cursor` before installing

**Source**:

- VS Code: Microsoft repository
- Cursor: Official Cursor website (downloader.cursor.sh)

**Note**: This script always runs (not optional) as both editors are essential for development.

---

### 05-docker.sh

**Purpose**: Install Docker Engine from official Docker repository (always installed).

**Installs**:

- **Docker Engine**: Latest stable from official Docker repository
- **Docker Compose**: V2 plugin (built-in)
- **BuildKit**: Enabled by default

**Configuration**:

- Adds user to `docker` group (no sudo required)
- Enables and starts Docker service
- Removes old Docker versions if present

**Idempotency**: Checks `command -v docker`, verifies user in docker group

**Source**: Official Docker repository (download.docker.com)

**Note**: This script always runs (not optional) as Docker is essential for development.

---

### 06-java.sh

**Purpose**: Install Java SDK via SDKMAN (always installed).

**Installs**:

- **SDKMAN**: Java version manager (https://sdkman.io/)
  - Installs via curl script
  - Initializes in `.zshrc` for interactive shells
- **Java SDK**: Multiple versions via SDKMAN
  - Java 8 (8.0.x-tem)
  - Java 11 (11.0.x-tem)
  - Java 17 (17.0.x-tem) - Set as default
  - Java 21 LTS (21.0.x-tem)

**Configuration**:
- SDKMAN initialized in `.zshrc`
- Java 17 set as default version

**Idempotency**: 
- Checks for `$HOME/.sdkman` directory
- Checks installed Java versions via SDKMAN

**Source**:
- SDKMAN: https://get.sdkman.io
- Java: Via SDKMAN (Temurin builds)

**Note**: This script always runs (not optional) as Java is essential for development.

---

### 07-dev-tools.sh

**Purpose**: Install development tools (always installed).

**Installs**:

- **Android Studio**: Latest stable
  - Prefers snap installation
  - Falls back to manual .tar.gz installation
  - Creates desktop entry
- **DBeaver**: Database management tool
  - Prefers snap installation
  - Falls back to .deb download
- **Postman**: API testing tool
  - Prefers snap installation
  - Falls back to manual .tar.gz installation

**Idempotency**: 
- Checks `command -v` for Android Studio, DBeaver, Postman
- Checks for installation directories

**Source**:
- Android Studio: Snap or official Google download
- DBeaver: Snap or official .deb
- Postman: Snap or official download

**Note**: This script always runs (not optional) as these development tools are essential.

---

### 08-extras.sh

**Purpose**: Install additional development tools (optional).

**Installs**:

- **Languages**:
  - `python3` + `pip3` + `python3-venv` (from Ubuntu repos)
- **Git tools**:
  - `git-lfs` (Git Large File Storage)
  - `gh` (GitHub CLI) - from GitHub official repository
- **Database clients**:
  - `postgresql-client` - PostgreSQL client
  - `sqlite3` - SQLite database
  - `redis-tools` - Redis CLI
- **HTTP tools**:
  - `httpie` - User-friendly HTTP client

**Idempotency**: Checks via `command -v` or `dpkg -l` before installing

**Source**: Mix of Ubuntu repos, official repositories (GitHub), and snap

**User Prompt**: Bootstrap script asks before running this script

---

## Configuration Files

### dotfiles/.zshrc

**Purpose**: Complete Zsh configuration.

**Contents**:

- Oh My Zsh initialization
- Plugin configuration (autosuggestions, syntax-highlighting)
- Powerlevel10k theme setup
- NVM initialization (loads NVM in interactive shells)
- SDKMAN initialization (loads SDKMAN in interactive shells)
- Editor set to `nano` (EDITOR and VISUAL variables)
- Custom functions:
  - `mkcd` - Create directory and cd into it
  - `extract` - Extract various archive formats
- History optimization (size, deduplication)
- FZF integration (fuzzy finder key bindings)
- NVM auto-switch directory support

**Location after install**: `~/.zshrc` (symlinked)

---

### dotfiles/.gitconfig

**Purpose**: Git global configuration with useful aliases.

**Contents**:

- **Aliases** (15+):
  - `lg` - Pretty log graph
  - `last` - Show last commit
  - `undo` - Undo last commit (keep changes)
  - `branches` - List all branches
  - `cleanup` - Delete merged branches
  - `st` - Status short
  - And more...
- **Diff**: Uses `histogram` algorithm (better for large files)
- **Colors**: Enabled for better readability
- **Auto-prune**: Removes deleted remote branches on fetch
- **Merge tool**: VS Code/Cursor as merge/conflict tool

**Location after install**: `~/.gitconfig` (symlinked)

---

### dotfiles/.aliases

**Purpose**: Comprehensive collection of shell aliases.

**Categories**:

- **Navigation**: `cd` shortcuts, directory helpers
- **LS improvements**: Enhanced `ls` with color and formatting
- **Git**: 50+ aliases for common Git operations
- **Docker**: 20+ aliases for Docker commands
- **npm/yarn/pnpm**: Package manager shortcuts
- **System**: Process management, disk usage, system info
- **Network**: IP address, connectivity tests

**Location after install**: `~/.aliases` (symlinked, sourced by `.zshrc`)

---

## Design Principles

1. **Idempotency**: All scripts check if tools are installed before attempting installation. Safe to run multiple times.

2. **Modularity**: Scripts are numbered and separated by concern. Easy to add new scripts (06, 07, etc.).

3. **Official Sources First**:

   - Use official repositories over system packages when newer versions are needed
   - Docker: Official Docker repository
   - VS Code: Microsoft repository
   - GitHub CLI: GitHub repository
   - NVM: GitHub releases

4. **LTS When Available**:

   - Node.js: Always installs LTS version
   - Prefer stability over bleeding edge

5. **Fail Fast**:

   - All scripts use `set -e` (exit on error)
   - Bootstrap script checks OS compatibility first

6. **User Choice**:

   - Optional components (Extras) prompt user before installation
   - User can skip optional installations
   - Docker, Java, and Android tools are always installed

7. **Backup Strategy**:

   - Existing dotfiles backed up to `.backup` suffix before symlinking
   - No data loss during installation

8. **Informative Output**:
   - Color-coded messages (info=blue, success=green, warning=yellow, error=red)
   - Clear status messages for each step

---

## AI Assistant Guidelines

When helping with this project:

### ✅ DO:

1. **Maintain idempotency** - Always check if tools/configs exist before installing/modifying
2. **Use official sources** - Prefer official repositories and GitHub releases
3. **Follow LTS strategy** - Use Long Term Support versions when available
4. **Preserve modularity** - Keep scripts focused on single concerns
5. **Update both files** - Keep README.md and PROJECT.md in sync
6. **Test suggestions** - Mention testing in VM/container before running on main machine
7. **Explain changes** - Document why changes are made, not just what changed
8. **Use consistent style** - Follow existing script patterns (colors, functions, structure)

### ❌ DON'T:

1. **Don't break idempotency** - Never install without checking first
2. **Don't create CHANGELOG.md** - Project uses release-please for automatic changelogs
3. **Don't modify bootstrap.sh without updating this doc** - Keep orchestration documented
4. **Don't use third-party PPAs** - Use official repositories only
5. **Don't hardcode versions** - Use "latest" or "LTS" strategies

---

## Common Tasks for AI

### Adding a New Tool

**Process**:

1. Determine which script to modify (or create new numbered script)
2. Add idempotency check (command exists? dpkg installed?)
3. Add installation logic following existing patterns
4. Update README.md with new tool in appropriate section
5. Update this PROJECT.md with tool details in script section

**Example**: Adding Rust

- Could go in `08-extras.sh` or new `09-rust.sh`
- Check: `command -v rustc`
- Install via official rustup installer
- Update both documentation files

---

### Fixing Installation Issues

**Process**:

1. Identify the failing script (check error output)
2. Reproduce issue in VM/container first
3. Check if idempotency check is causing issue
4. Verify OS compatibility (Zorin/Ubuntu)
5. Check if dependencies are installed
6. Update script with fix
7. Test idempotency (run script twice)
8. Update documentation if needed

---

### Improving Scripts

**Guidelines**:

- Keep colored output for consistency
- Add more informative messages
- Improve error handling
- Add progress indicators for long operations
- Maintain backward compatibility

---

## Version Management Strategy

| Component           | Strategy                 | Source               | Update Method                                                                      |
| ------------------- | ------------------------ | -------------------- | ---------------------------------------------------------------------------------- |
| System packages     | Latest from Ubuntu repos | `apt`                | `sudo apt update && sudo apt upgrade`                                              |
| Node.js             | LTS version              | NVM (nodejs.org)     | `nvm install --lts && nvm alias default lts/*`                                     |
| NVM                 | Latest release           | GitHub               | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh \| bash` |
| Docker              | Latest stable            | Official Docker repo | `sudo apt update && sudo apt upgrade docker-ce`                                    |
| Global npm packages | Latest stable            | npm registry         | `npm update -g`                                                                    |
| VS Code             | Latest stable            | Microsoft repo       | Auto-updates enabled                                                               |
| Cursor              | Latest                   | Official website     | Manual updates via downloader                                                      |
| Java (SDKMAN)       | 8, 11, 17, 21 LTS        | SDKMAN (Temurin)     | `sdk update && sdk install java <version>`                                         |
| Android Studio      | Latest stable            | Snap/Google          | `snap refresh android-studio` or manual download                                  |
| Oh My Zsh           | Latest                   | GitHub               | `omz update`                                                                        |
| Shell plugins       | Latest                   | GitHub               | `git pull` in plugin directories                                                    |

---

## Testing Strategy

**Before running on main machine**:

1. **VM Testing** (Recommended):

   - Create VM with fresh Zorin OS
   - Clone repo
   - Run `bash bootstrap.sh`
   - Verify all tools work
   - Test idempotency (run bootstrap again)

2. **Docker Container Testing**:

   ```bash
   docker run -it ubuntu:22.04 bash
   apt update && apt install -y git sudo
   git clone https://github.com/RanielliMontagna/dotfiles.git
   cd dotfiles
   bash bootstrap.sh
   ```

3. **Idempotency Test**:
   - Run bootstrap script
   - Wait for completion
   - Run bootstrap script again
   - Should skip already-installed components
   - Should complete without errors

---

## Current Status

**Status**: ✅ **COMPLETE AND READY TO USE**

All core components implemented:

- ✅ Bootstrap orchestration script
- ✅ All installation scripts (01-07 always; 08 optional)
- ✅ Configuration files (.zshrc, .gitconfig, .aliases)
- ✅ Documentation (README.md, PROJECT.md)

**Version Management**: Uses `release-please` for automatic changelog generation on releases to main branch.

---

## Resources

- **Node.js Releases**: https://nodejs.org/en/about/releases/
- **NVM**: https://github.com/nvm-sh/nvm
- **Oh My Zsh**: https://ohmyz.sh/
- **Powerlevel10k**: https://github.com/romkatv/powerlevel10k
- **Docker Docs**: https://docs.docker.com/
- **SDKMAN**: https://sdkman.io/
- **Android Studio**: https://developer.android.com/studio
- **DBeaver**: https://dbeaver.io/
- **Ubuntu Packages**: https://packages.ubuntu.com/

---

**Last Updated**: November 2025
