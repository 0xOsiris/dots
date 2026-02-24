# dotfiles

Personal development environment: shell, editor, terminal, window management, and Claude Code agent orchestration.

## Quick Start

```bash
git clone git@github.com:0xOsiris/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Full bootstrap (install deps + symlink everything)
just bootstrap

# Or piecemeal:
just symlink-all              # link configs only
just symlink-zsh              # just shell
just symlink-nvim             # just neovim
just install-deps             # install tools
just install-rust-dev         # rust nightly + cargo plugins
just fetch-resources          # clone Claude agent reference repos

# Copy and fill in secrets
cp zsh/.secrets.example ~/.secrets.local
```

Requires [just](https://github.com/casey/just) (`brew install just`).

## Structure

```
.
├── zsh/                     # Shell config (zshrc, zshenv, zprofile)
├── tmux/                    # Tmux (Catppuccin Mocha, C-e leader, vi mode)
├── nvim/                    # Neovim (AstroNvim v5, Rust pack, Claude integration)
├── git/                     # Gitconfig + global ignore
├── cargo/                   # Cargo config (mold linker, sparse registry)
├── ghostty/                 # Ghostty terminal (JetBrains Mono, GitHub Dark)
├── lazygit/                 # LazyGit themes (dark/light)
├── aerospace/               # AeroSpace tiling WM (macOS)
├── skhd/                    # skhd hotkey daemon (macOS)
├── yabai/                   # yabai tiling WM (macOS)
├── claude/                  # Claude Code configuration
│   ├── agents/              # 10 expert agent definitions
│   ├── hooks/               # Safety hooks (dangerous cmd, kubectl, secrets)
│   ├── rules/               # Global instruction rules
│   ├── docs/                # Orchestration documentation
│   ├── commands/            # Slash commands
│   ├── templates/           # MCP config templates
│   ├── bin/                 # Orchestration scripts
│   ├── plugins/             # Plugin config
│   ├── mcp-servers.json     # MCP server definitions
│   ├── settings.json        # Hooks + feature flags
│   └── resources.yaml       # 100+ reference repo manifest
├── scripts/                 # Helper scripts
├── mcp.json                 # Root MCP config (GitHub, Foundry, K8s)
└── justfile                 # Bootstrap and management
```

## Key Choices

- **Shell**: zsh + Oh My Zsh, vi mode, zoxide, fzf (Catppuccin colors)
- **Editor**: Neovim via AstroNvim, Rust LSP, Copilot, Claude CLI integration
- **Terminal**: Ghostty (primary), tmux for sessions
- **Theme**: Catppuccin Mocha everywhere
- **Rust**: sccache, mold linker, nightly fmt/clippy, nextest
- **Aliases**: `c`=cargo, `g`=git, `v`=nvim, `lg`=lazygit, modern CLI replacements

## Secrets

All secrets are sourced from `~/.secrets.local` (gitignored). Copy the example:

```bash
cp zsh/.secrets.example ~/.secrets.local
# Fill in: ALCHEMY_API_KEY, GITHUB_TOKEN, etc.
```

## Notes

- `claude/bin/chad-mcp` is gitignored (build from source at `~/claude-expert-agents/mcp-server/`)
- macOS window management (aerospace/skhd/yabai) is only relevant on Darwin
- `just check` shows which tools are installed
- `just status` shows which configs are linked
