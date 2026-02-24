#!/bin/bash
# Block dangerous commands that could harm the system or repos
# Returns exit 2 to block, exit 0 to allow

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Dangerous patterns to block
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \$HOME"
    ":(){ :|:& };:"
    "> /dev/sda"
    "dd if=/dev/zero"
    "mkfs."
    "chmod -R 777 /"
    "chown -R .* /"
    "git push.*--force.*main"
    "git push.*--force.*master"
    "git reset --hard origin/main"
    "npm publish"
    "cargo publish"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        echo "Blocked dangerous command matching: $pattern" >&2
        exit 2
    fi
done

# Warn about force pushes (but don't block non-main branches)
if echo "$COMMAND" | grep -qE "git push.*--force"; then
    echo "Warning: Force push detected. Ensure you're not pushing to a protected branch." >&2
fi

exit 0
