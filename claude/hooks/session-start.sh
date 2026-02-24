# #!/bin/bash
# # Claude Code Session Start Hook
# # Automatically loads project context and detects project type
# #
# # This hook runs when a new Claude Code session starts.
# # It helps provide context about the project to Claude.

# PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
# PROJECT_NAME=$(basename "$PROJECT_ROOT")

# # Detect project type and print helpful context
# detect_project() {
#     local indicators=""

#     if [[ -f "$PROJECT_ROOT/Cargo.toml" ]]; then
#         indicators+="rust "
#     fi
#     if [[ -f "$PROJECT_ROOT/package.json" ]]; then
#         indicators+="node "
#     fi
#     if [[ -f "$PROJECT_ROOT/foundry.toml" ]]; then
#         indicators+="foundry "
#     fi
#     if [[ -f "$PROJECT_ROOT/pyproject.toml" ]] || [[ -f "$PROJECT_ROOT/setup.py" ]]; then
#         indicators+="python "
#     fi
#     if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
#         indicators+="go "
#     fi

#     echo "$indicators"
# }

# # Check for context files
# check_context_files() {
#     local found=""

#     if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
#         found+="CLAUDE.md "
#     fi
#     if [[ -f "$PROJECT_ROOT/AGENTS.md" ]]; then
#         found+="AGENTS.md "
#     fi
#     if [[ -d "$PROJECT_ROOT/.claude" ]]; then
#         found+=".claude/ "
#     fi

#     echo "$found"
# }

# # Main output
# PROJECT_TYPE=$(detect_project)
# CONTEXT_FILES=$(check_context_files)

# # Build status message
# echo "Project: $PROJECT_NAME"

# if [[ -n "$PROJECT_TYPE" ]]; then
#     echo "Type: $PROJECT_TYPE"
# fi

# if [[ -n "$CONTEXT_FILES" ]]; then
#     echo "Context: $CONTEXT_FILES"
# fi

# # Remind about plan mode if configured
# if [[ -f "$PROJECT_ROOT/.claude/settings.local.json" ]]; then
#     if grep -q '"defaultMode".*"plan"' "$PROJECT_ROOT/.claude/settings.local.json" 2>/dev/null; then
#         echo "Mode: planFirst (propose changes before executing)"
#     fi
# fi
