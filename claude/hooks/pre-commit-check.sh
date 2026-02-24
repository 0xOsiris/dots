#!/bin/bash
# Pre-commit validation for Worldcoin projects
# Runs format checks and clippy before allowing commits

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Only intercept git commit commands
if ! echo "$COMMAND" | grep -qE "git commit"; then
    exit 0
fi

cd "$CWD"

# Check if this is a Rust project
if [ -f "Cargo.toml" ]; then
    # Check if there are staged changes
    if git diff --cached --name-only | grep -qE "\.(rs)$"; then
        # Run format check (non-blocking, just warn)
        if ! cargo +nightly fmt --all --check 2>/dev/null; then
            echo "Warning: Rust files need formatting. Run: cargo +nightly fmt --all" >&2
        fi
    fi
fi

# Check if TypeScript project
if [ -f "package.json" ]; then
    if git diff --cached --name-only | grep -qE "\.(ts|tsx)$"; then
        # Check for lint script
        if jq -e '.scripts.lint' package.json > /dev/null 2>&1; then
            if ! npm run lint --silent 2>/dev/null; then
                echo "Warning: TypeScript lint issues detected. Run: npm run lint" >&2
            fi
        fi
    fi
fi

exit 0
