#!/bin/bash
# Stop hook: Verify tests pass after code changes
# Uses agent-based verification for intelligent test detection

set -euo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')

# Prevent infinite loops
if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
    exit 0
fi

# Check if we're in a project with tests
cd "$CWD" 2>/dev/null || exit 0

HAS_TESTS=false
TEST_CMD=""

if [ -f "Cargo.toml" ]; then
    HAS_TESTS=true
    # Check for nextest first
    if command -v cargo-nextest &> /dev/null; then
        TEST_CMD="cargo nextest run"
    else
        TEST_CMD="cargo test"
    fi
elif [ -f "package.json" ]; then
    if jq -e '.scripts.test' package.json > /dev/null 2>&1; then
        HAS_TESTS=true
        TEST_CMD="npm test"
    fi
elif [ -f "go.mod" ]; then
    HAS_TESTS=true
    TEST_CMD="go test ./..."
fi

# If project has tests, output reminder context
if [ "$HAS_TESTS" = "true" ]; then
    cat << EOF
Consider running tests to verify changes: $TEST_CMD
EOF
fi

exit 0
