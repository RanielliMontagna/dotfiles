# Zsh Configuration
# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# ============================================================================
# Powerlevel10k Instant Prompt
# ============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# This must be loaded BEFORE Oh My Zsh is sourced.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Theme - Powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    docker-compose
    node
    npm
    yarn
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# User Configuration
# ============================================================================

# Preferred editor
export EDITOR='nano'
export VISUAL='nano'

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion

# SDKMAN (Java Version Manager)
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Bun (JavaScript runtime and package manager)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Android SDK
if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
    export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"
elif [[ -d "$HOME/snap/android-studio/current/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/snap/android-studio/current/Android/Sdk"
    export ANDROID_SDK_ROOT="$HOME/snap/android-studio/current/Android/Sdk"
    export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools"
fi

# Load aliases
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# ============================================================================
# History Configuration
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_ALL_DUPS  # Don't save duplicates
setopt HIST_FIND_NO_DUPS     # Don't show duplicates when searching
setopt HIST_SAVE_NO_DUPS     # Don't save duplicates
setopt SHARE_HISTORY         # Share history between sessions

# ============================================================================
# Better directory navigation
# ============================================================================

setopt AUTO_CD              # cd by just typing directory name
setopt AUTO_PUSHD           # Push directory to stack on cd
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack

# ============================================================================
# Completion
# ============================================================================

setopt COMPLETE_IN_WORD     # Complete from both ends of word
setopt ALWAYS_TO_END        # Move cursor to end if word had one match

# ============================================================================
# FZF Configuration (Fuzzy Finder)
# ============================================================================

if command -v fzf &> /dev/null; then
    # Use fd instead of find for better performance
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    
    # Use ripgrep for better search
    if command -v rg &> /dev/null; then
        export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    fi
fi

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# This should be loaded AFTER Oh My Zsh is sourced.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ============================================================================
# Utility Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive types
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# Welcome Message
# ============================================================================

echo "🚀 Welcome to your dev environment!"
echo "📝 Run 'aliases' to see available shortcuts"
