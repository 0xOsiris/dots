# ~/.zshrc - Main zsh configuration

# =============================================================================
# Oh My Zsh Configuration
# =============================================================================
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  docker
  zsh-autosuggestions
  fast-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

source ~/.zshenv

# =============================================================================
# NVM / Node.js
# =============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export PATH=$PATH:$NVM_DIR
export PATH="$HOME/bin:$PATH"

# =============================================================================
# Environment Variables
# =============================================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"

# Rust-specific
export SCCACHE_CACHE_SIZE="10G"
export RUSTC_WRAPPER="sccache"

# History
export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# =============================================================================
# Tool Initialization
# =============================================================================

# Zoxide (smart cd replacement)
eval "$(zoxide init zsh)"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --info=inline
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  "
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# =============================================================================
# Aliases - General
# =============================================================================

alias vim="nvim"
alias v="nvim"

alias ll="eza -la --git --icons"
alias la="eza -a --icons"
alias l="eza --icons"
alias ls="eza --icons"
alias lt="eza -T --icons --git-ignore"
alias tree="eza -T --icons --git-ignore"
alias cat="bat --style=plain"
alias grep="rg"
alias find="fd"
alias claude="claude --resume"

# =============================================================================
# Aliases - Git
# =============================================================================
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate"
alias lg="lazygit"

# =============================================================================
# Aliases - Cargo / Rust
# =============================================================================
alias c="cargo"
alias cb="cargo build"
alias cbr="cargo build --release"
alias cr="cargo run"
alias crr="cargo run --release"
alias ct="cargo nextest run"
alias cta="cargo nextest run --workspace"
alias ctw="cargo watch -x test"
alias cc="cargo check"
alias ccw="cargo watch -x check"
alias cf="cargo +nightly fmt --all"
alias cl="RUSTFLAGS='-D warnings' cargo +nightly clippy --workspace --all-features"
alias cla="RUSTFLAGS='-D warnings' cargo +nightly clippy --workspace --all-features --locked"
alias cfix="cargo fix --allow-dirty --allow-staged"
alias cdoc="cargo doc --document-private-items --open"
alias cupdate="cargo update"
alias cclean="cargo clean"
alias caudit="cargo audit"
alias cdeny="cargo deny check"
alias coutdated="cargo outdated -R"
alias cexpand="cargo expand"

# Bacon (continuous compilation)
alias b="bacon"
alias bw="bacon clippy"
alias bt="bacon test"

# =============================================================================
# Key Bindings
# =============================================================================
bindkey -v  # Vi mode
bindkey 'jj' vi-cmd-mode
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' kill-whole-line

# =============================================================================
# Completion
# =============================================================================
autoload -Uz compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Completion menu
zstyle ':completion:*' menu select

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/.huff/bin"

# =============================================================================
# Local overrides (secrets, machine-specific config)
# =============================================================================
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
