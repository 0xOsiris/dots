# ~/.zprofile - Login shell configuration
# Loaded once at login (before .zshrc)

# =============================================================================
# OS-specific Configuration
# =============================================================================

case "$(uname -s)" in
    Darwin)
        eval "$(/opt/homebrew/bin/brew shellenv)"
        ;;
    Linux)
        if [[ -d /home/linuxbrew/.linuxbrew ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        ;;
esac

# Cargo/Rust (if not already in path via .zshenv)
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
