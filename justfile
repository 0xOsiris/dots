# Dotfiles management

set dotenv-load := false

home := env("HOME")
dots := justfile_directory()
config := home / ".config"

# List available recipes
default:
    @just --list

# =============================================================================
# Bootstrap
# =============================================================================

# Full bootstrap: install deps + symlink everything
bootstrap: install-deps symlink-all
    @echo ""
    @echo "Bootstrap complete! Restart your shell or: source ~/.zshrc"

# =============================================================================
# Symlinks
# =============================================================================

[private]
_link src dest:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -L "{{ dest }}" ]; then
        rm "{{ dest }}"
    elif [ -e "{{ dest }}" ]; then
        echo "  [backup] {{ dest }}"
        mv "{{ dest }}" "{{ dest }}.bak"
    fi
    mkdir -p "$(dirname '{{ dest }}')"
    ln -s "{{ src }}" "{{ dest }}"
    echo "  [link] $(basename '{{ dest }}')"

# Symlink all configs
symlink-all: symlink-zsh symlink-tmux symlink-git symlink-nvim symlink-ghostty symlink-lazygit symlink-cargo symlink-aerospace symlink-skhd symlink-yabai symlink-mcp symlink-claude
    @echo "All configs linked."

# Shell
symlink-zsh:
    @echo "=== zsh ==="
    @just _link "{{ dots }}/zsh/.zshrc" "{{ home }}/.zshrc"
    @just _link "{{ dots }}/zsh/.zshenv" "{{ home }}/.zshenv"
    @just _link "{{ dots }}/zsh/.zprofile" "{{ home }}/.zprofile"

# Tmux
symlink-tmux:
    @echo "=== tmux ==="
    @just _link "{{ dots }}/tmux/.tmux.conf" "{{ home }}/.tmux.conf"

# Git
symlink-git:
    @echo "=== git ==="
    @just _link "{{ dots }}/git/.gitconfig" "{{ home }}/.gitconfig"
    @just _link "{{ dots }}/git/ignore" "{{ config }}/git/ignore"

# Neovim
symlink-nvim:
    @echo "=== nvim ==="
    @just _link "{{ dots }}/nvim" "{{ config }}/nvim"

# Ghostty
symlink-ghostty:
    @echo "=== ghostty ==="
    @just _link "{{ dots }}/ghostty" "{{ config }}/ghostty"

# LazyGit
symlink-lazygit:
    @echo "=== lazygit ==="
    @just _link "{{ dots }}/lazygit/config-dark.yml" "{{ config }}/lazygit/config-dark.yml"
    @just _link "{{ dots }}/lazygit/config-light.yml" "{{ config }}/lazygit/config-light.yml"

# Cargo
symlink-cargo:
    @echo "=== cargo ==="
    @just _link "{{ dots }}/cargo/config.toml" "{{ home }}/.cargo/config.toml"

# AeroSpace (macOS tiling WM)
symlink-aerospace:
    @echo "=== aerospace ==="
    @just _link "{{ dots }}/aerospace/.aerospace.toml" "{{ home }}/.aerospace.toml"

# skhd (macOS hotkeys)
symlink-skhd:
    @echo "=== skhd ==="
    @just _link "{{ dots }}/skhd/skhdrc" "{{ config }}/skhd/skhdrc"

# yabai (macOS tiling WM)
symlink-yabai:
    @echo "=== yabai ==="
    @just _link "{{ dots }}/yabai/yabairc" "{{ config }}/yabai/yabairc"

# Root MCP config
symlink-mcp:
    @echo "=== mcp ==="
    @just _link "{{ dots }}/mcp.json" "{{ home }}/.mcp.json"

# Claude Code config
symlink-claude:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== claude ==="
    mkdir -p "{{ home }}/.claude" "{{ home }}/.claude/plugins"

    # Config files
    for file in mcp-servers.json settings.json resources.yaml; do
        [ -f "{{ dots }}/claude/$file" ] && just _link "{{ dots }}/claude/$file" "{{ home }}/.claude/$file"
    done

    # Directories
    for dir in agents hooks rules docs commands templates bin; do
        [ -d "{{ dots }}/claude/$dir" ] && just _link "{{ dots }}/claude/$dir" "{{ home }}/.claude/$dir"
    done

    # Plugin configs
    for file in config.json installed_plugins.json; do
        [ -f "{{ dots }}/claude/plugins/$file" ] && just _link "{{ dots }}/claude/plugins/$file" "{{ home }}/.claude/plugins/$file"
    done

# =============================================================================
# Dependencies
# =============================================================================

# Install all dependencies (detects OS)
install-deps:
    #!/usr/bin/env bash
    set -e
    OS="$(uname -s)"
    echo "Installing dependencies ($OS)..."

    if [[ "$OS" == "Darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        brew install git curl zsh tmux fzf neovim lazygit bat eza just yq ghostty || true
    elif [[ "$OS" == "Linux" ]]; then
        sudo apt update
        sudo apt install -y git curl build-essential cmake pkg-config libssl-dev zsh tmux fzf unzip bat mold clang
    fi

    # Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Zsh plugins
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] && \
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    [[ ! -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ]] && \
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

    # NVM + Node
    if [[ ! -d "$HOME/.nvm" ]]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts
    fi

    # Rust
    if ! command -v rustup &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi

    # Rust CLI tools
    source "$HOME/.cargo/env" 2>/dev/null || true
    for tool in zoxide ripgrep fd-find bat eza git-delta; do
        cargo install "$tool" --locked 2>/dev/null || true
    done

    echo "Done."

# Install Rust dev tools (nightly, nextest, etc.)
install-rust-dev:
    #!/usr/bin/env bash
    set -e
    source "$HOME/.cargo/env" 2>/dev/null || true
    rustup toolchain install nightly --profile minimal
    rustup component add rust-analyzer clippy rustfmt rust-src llvm-tools
    rustup component add rustfmt --toolchain nightly
    cargo install sccache cargo-nextest cargo-expand --locked 2>/dev/null || true

# Fetch Claude Code reference resources from manifest
fetch-resources agent="":
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v yq &>/dev/null; then
        echo "Error: yq required. Install with: brew install yq"
        exit 1
    fi
    MANIFEST="{{ dots }}/claude/resources.yaml"
    TARGET="{{ home }}/.claude/resources"
    FILTER="{{ agent }}"

    clone_resource() {
        local cat="$1" name="$2" repo="$3" sparse="$4"
        local dest="$TARGET/$cat/$name"
        [ -d "$dest" ] && { echo "  [skip] $cat/$name"; return; }
        echo "  [clone] $cat/$name"
        mkdir -p "$dest"
        if [ -n "$sparse" ] && [ "$sparse" != "null" ]; then
            git clone --depth 1 --filter=blob:none --sparse "https://github.com/$repo.git" "$dest" 2>/dev/null
            cd "$dest"
            echo "$sparse" | yq -r '.[]' 2>/dev/null | while read -r dir; do
                git sparse-checkout add "$dir" 2>/dev/null || true
            done
            cd - >/dev/null
        else
            git clone --depth 1 "https://github.com/$repo.git" "$dest" 2>/dev/null
        fi
    }

    echo "Fetching resources -> $TARGET"
    for a in $(yq -r '.agents | keys[]' "$MANIFEST"); do
        [ -n "$FILTER" ] && [ "$a" != "$FILTER" ] && continue
        cat=$(yq -r ".agents.$a.category" "$MANIFEST")
        echo "[$a] ($cat)"
        count=$(yq -r ".agents.$a.resources | length" "$MANIFEST")
        for i in $(seq 0 $((count - 1))); do
            name=$(yq -r ".agents.$a.resources[$i].name" "$MANIFEST")
            repo=$(yq -r ".agents.$a.resources[$i].repo" "$MANIFEST")
            sparse=$(yq -c ".agents.$a.resources[$i].sparse // null" "$MANIFEST")
            clone_resource "$cat" "$name" "$repo" "$sparse"
        done
    done
    echo "Done."

# =============================================================================
# Utilities
# =============================================================================

# Show symlink status
status:
    #!/usr/bin/env bash
    echo "Symlink status:"
    check() {
        if [ -L "$1" ]; then
            echo "  [linked]  $2 -> $(readlink "$1")"
        elif [ -e "$1" ]; then
            echo "  [local]   $2"
        else
            echo "  [missing] $2"
        fi
    }
    check "{{ home }}/.zshrc" ".zshrc"
    check "{{ home }}/.zshenv" ".zshenv"
    check "{{ home }}/.zprofile" ".zprofile"
    check "{{ home }}/.tmux.conf" ".tmux.conf"
    check "{{ home }}/.gitconfig" ".gitconfig"
    check "{{ config }}/nvim" "nvim"
    check "{{ config }}/ghostty" "ghostty"
    check "{{ config }}/lazygit/config-dark.yml" "lazygit"
    check "{{ home }}/.cargo/config.toml" "cargo"
    check "{{ home }}/.aerospace.toml" "aerospace"
    check "{{ home }}/.mcp.json" "mcp.json"
    check "{{ home }}/.claude/agents" "claude/agents"
    check "{{ home }}/.claude/hooks" "claude/hooks"
    check "{{ home }}/.claude/rules" "claude/rules"

# Remove all symlinks
uninstall:
    #!/usr/bin/env bash
    echo "Removing symlinks..."
    for f in "{{ home }}/.zshrc" "{{ home }}/.zshenv" "{{ home }}/.zprofile" \
             "{{ home }}/.tmux.conf" "{{ home }}/.gitconfig" "{{ home }}/.aerospace.toml" \
             "{{ home }}/.mcp.json" "{{ home }}/.cargo/config.toml" \
             "{{ config }}/nvim" "{{ config }}/ghostty" \
             "{{ config }}/lazygit/config-dark.yml" "{{ config }}/lazygit/config-light.yml" \
             "{{ config }}/git/ignore" "{{ config }}/skhd/skhdrc" "{{ config }}/yabai/yabairc"; do
        [ -L "$f" ] && rm "$f" && echo "  [rm] $(basename "$f")"
    done
    for f in mcp-servers.json settings.json resources.yaml; do
        [ -L "{{ home }}/.claude/$f" ] && rm "{{ home }}/.claude/$f" && echo "  [rm] claude/$f"
    done
    for d in agents hooks rules docs commands templates bin; do
        [ -L "{{ home }}/.claude/$d" ] && rm "{{ home }}/.claude/$d" && echo "  [rm] claude/$d"
    done
    echo "Done. Backups (.bak) preserved."

# Check installed tools
check:
    #!/usr/bin/env bash
    check_cmd() { command -v "$1" &>/dev/null && echo "  + $1" || echo "  - $1"; }
    echo "Shell:";    check_cmd zsh
    echo "Editor:";   check_cmd nvim
    echo "Terminal:";  check_cmd ghostty; check_cmd tmux
    echo "VCS:";      check_cmd git; check_cmd lazygit; check_cmd delta
    echo "Rust:";     check_cmd rustc; check_cmd cargo; check_cmd sccache; check_cmd cargo-nextest
    echo "Node:";     check_cmd node; check_cmd npm
    echo "CLI:";      check_cmd fzf; check_cmd zoxide; check_cmd rg; check_cmd fd; check_cmd bat; check_cmd eza
