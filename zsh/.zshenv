# ~/.zshenv - Environment variables (loaded for all shells)
# This file is read first, before .zprofile and .zshrc

# Cargo/Rust environment
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

export PATH="$PATH:$HOME/.foundry/bin"
export PATH="$PATH:$HOME/go/bin"

# =============================================================================
# Local secrets (gitignored, machine-specific)
# =============================================================================
[[ -f "$HOME/.secrets.local" ]] && source "$HOME/.secrets.local"
