#!/bin/bash
# Detect project context and inject specialized agent guidance
# This runs on SessionStart to provide domain-specific context

# Don't use set -e - we handle errors gracefully
set -uo pipefail

INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null) || exit 0

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
    exit 0
fi

cd "$CWD" || exit 0

# Initialize detection flags
DOMAINS=""
AGENTS=""

add_domain() {
    if [[ ! "$DOMAINS" =~ $1 ]]; then
        DOMAINS="$DOMAINS $1"
    fi
}

add_agent() {
    if [[ ! "$AGENTS" =~ $1 ]]; then
        AGENTS="$AGENTS $1"
    fi
}

# ============================================
# Project Detection (simplified, fast)
# ============================================

# Worldcoin detection via path
if echo "$CWD" | grep -qE "(worldcoin|world-chain|world-id|semaphore|iris-mpc|orb-)"; then
    add_domain "worldcoin"
    add_agent "worldcoin-expert"

    if echo "$CWD" | grep -qE "(world-chain|builder)"; then
        add_domain "world-chain"
        add_agent "optimism-expert"
        add_agent "reth-expert"
    fi

    if echo "$CWD" | grep -qE "(world-id|semaphore|iris-mpc)"; then
        add_domain "world-id"
        add_agent "zk-cryptography-expert"
    fi
fi

# Rust detection
if [ -f "Cargo.toml" ]; then
    add_domain "rust"
    add_agent "rust-expert"

    if grep -q "reth" Cargo.toml 2>/dev/null || [ -d "crates/reth" ]; then
        add_domain "reth"
        add_agent "reth-expert"
    fi

    if grep -qE "(circom|groth16|plonk|semaphore|ark-|bellman|snark)" Cargo.toml 2>/dev/null; then
        add_domain "zk-cryptography"
        add_agent "zk-cryptography-expert"
    fi
fi

# Go detection
if [ -f "go.mod" ]; then
    add_domain "go"
    add_agent "go-expert"

    if grep -qE "(go-ethereum|op-node|op-geth)" go.mod 2>/dev/null; then
        add_domain "ethereum"
        add_agent "ethereum-expert"
    fi
fi

# TypeScript detection
if [ -f "package.json" ]; then
    if grep -qE "(typescript|tsx|ts-node)" package.json 2>/dev/null; then
        add_domain "typescript"
        add_agent "typescript-expert"
    fi
fi

# Solidity detection
if [ -f "foundry.toml" ] || [ -d "contracts" ]; then
    add_domain "solidity"
    add_agent "solidity-expert"
fi

# Infrastructure detection
if [ -f "Dockerfile" ] || [ -d "helm" ] || [ -d "terraform" ] || [ -d ".github/workflows" ]; then
    add_domain "infrastructure"
    add_agent "infrastructure-expert"
fi

# OP Stack detection
if [ -d "op-node" ] || [ -d "op-geth" ] || [ -d "op-batcher" ]; then
    add_domain "optimism"
    add_agent "optimism-expert"
fi

# ============================================
# Output context if domains detected
# ============================================

# Trim leading spaces
DOMAINS=$(echo "$DOMAINS" | xargs)
AGENTS=$(echo "$AGENTS" | xargs | tr ' ' '\n' | sort -u | tr '\n' ' ' | xargs)

if [ -n "$DOMAINS" ]; then
    cat << EOF
<project-context>
Detected domains: ${DOMAINS// /, }

Recommended agents for this codebase: ${AGENTS// /, }

Use the Task tool with appropriate subagent_type for domain-specific expertise.
</project-context>
EOF
fi

exit 0
