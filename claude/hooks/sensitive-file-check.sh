#!/bin/bash
# Protect sensitive files from accidental modification
# Blocks writes to secrets, credentials, and critical config

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Sensitive patterns to protect
SENSITIVE_PATTERNS=(
    ".env"
    ".env.local"
    ".env.production"
    "credentials"
    "secrets"
    "private.key"
    "id_rsa"
    "id_ed25519"
    ".ssh/"
    ".aws/"
    ".kube/config"
    "service-account"
    ".npmrc"
    ".pypirc"
    "token.json"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$FILE_PATH" | grep -qiE "$pattern"; then
        # Output JSON for ask permission
        cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "File matches sensitive pattern: $pattern"
  }
}
EOF
        exit 0
    fi
done

exit 0
