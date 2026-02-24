#!/bin/bash
# PreToolUse hook for Bash - Restrict kubectl to safe read-only operations
# Allows: logs, get, describe, top
# Blocks: delete, apply, patch, edit, exec, port-forward, scale, rollout, drain, cordon

COMMAND="$CLAUDE_TOOL_ARG_COMMAND"

# Only check kubectl commands
if ! echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|)kubectl\s'; then
    exit 0
fi

# Allowed namespaces for World Chain
ALLOWED_NS="world-chain|world-chain-builder|sequencer|monitoring|default"

# Blocked dangerous operations
DANGEROUS_OPS="delete|apply|patch|create|edit|replace|set|scale|rollout|drain|cordon|uncordon|taint|label|annotate|exec|cp|port-forward|attach|run"

# Check for dangerous operations
if echo "$COMMAND" | grep -qE "kubectl\s+($DANGEROUS_OPS)"; then
    OP=$(echo "$COMMAND" | grep -oE "kubectl\s+($DANGEROUS_OPS)" | awk '{print $2}')
    echo "BLOCKED: kubectl $OP is not allowed"
    echo "Allowed operations: logs, get, describe, top, config, version, api-resources"
    exit 1
fi

# Check for namespace restrictions on data-reading commands
if echo "$COMMAND" | grep -qE "kubectl\s+(logs|get|describe|top)"; then
    # If -A or --all-namespaces is used, block it
    if echo "$COMMAND" | grep -qE "\s+(-A|--all-namespaces)"; then
        echo "BLOCKED: --all-namespaces not allowed"
        echo "Allowed namespaces: $ALLOWED_NS"
        exit 1
    fi

    # If a namespace is specified, verify it's allowed
    if echo "$COMMAND" | grep -qE "\s+(-n|--namespace)[=\s]+"; then
        NS=$(echo "$COMMAND" | grep -oE "(-n|--namespace)[=\s]+[a-zA-Z0-9_-]+" | sed 's/.*[= ]//')
        if ! echo "$NS" | grep -qE "^($ALLOWED_NS)$"; then
            echo "BLOCKED: namespace '$NS' not in allowed list"
            echo "Allowed namespaces: $ALLOWED_NS"
            exit 1
        fi
    fi
fi

# Allow the command
exit 0
