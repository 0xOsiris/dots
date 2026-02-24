# Load Project Context

Load and summarize all available context for the current project.

## Steps

1. Check for and read CLAUDE.md in the project root
2. Check for and read AGENTS.md if present
3. Read .claude/settings.local.json for permission configuration
4. List available MCP servers with /mcp
5. Summarize the project structure and key files

## Context Files to Check

- `CLAUDE.md` - Project-specific development guide
- `AGENTS.md` - Workflow rules and restrictions
- `.claude/settings.local.json` - Permissions and default mode
- `Cargo.toml` / `package.json` / `foundry.toml` - Project manifest

## Output

Provide a brief summary of:
- Project type and key technologies
- Available context files
- Current permission mode (acceptEdits, plan, etc.)
- Any restrictions or special rules
