# Agent Orchestration

When the user asks to orchestrate work across multiple agents or delegate tasks to experts, use the Chad MCP server tools.

## Available Orchestration Tools

The following tools are available from the `chad-orchestrator` MCP server:

### Task Delegation
- `delegate_task` - Delegate work to a specialized agent in a tmux session
- `check_agent` - Check status and output of an agent
- `message_agent` - Send follow-up messages to an agent
- `list_expert_agents` - List available agents and their status
- `orchestration_status` - Get overall system status

### Message Bus
- `bus_publish` - Send messages to worker agents (feedback, revisions, approvals)
- `bus_poll_responses` - Receive messages from workers
- `bus_stats` - Get message bus statistics

## Available Agents

| Agent | Expertise |
|-------|-----------|
| `rust-expert` | Rust, tokio, async, performance, reth, alloy |
| `solidity-expert` | Solidity, Foundry, security, ERC standards |
| `ethereum-expert` | EVM, EIPs, execution specs, consensus |
| `zk-expert` | ZK proofs, Circom, Semaphore, cryptography |
| `infra-expert` | K8s, Terraform, AWS, Helm, CI/CD |
| `optimism-expert` | OP Stack, L2, derivation, rollups |
| `worldcoin-expert` | World Chain, World ID, Flashblocks, PBH |
| `go-expert` | Go, geth, concurrency, modules |
| `typescript-expert` | TypeScript, React, Next.js, viem, wagmi |
| `reth-expert` | reth, revm, alloy, Engine API, sync stages |

## Workflow

1. **Plan** - Analyze task, identify workstreams, select agents
2. **Delegate** - Use `delegate_task` with detailed task descriptions
3. **Monitor** - Use `bus_poll_responses` and `check_agent`
4. **Review** - When agents request review, examine their work
5. **Iterate** - Use `bus_publish` with `revision_request` if changes needed
6. **Approve** - Use `bus_publish` with `approval` when work is complete

## Usage

To use orchestration, start Claude with the MCP config:
```bash
claude --mcp-config ~/.claude/mcp-servers.json
```

Or add to a project's `.mcp.json` to auto-load.

For detailed documentation, see:
- `~/.claude/docs/ORCHESTRATION.md` - Expert/Planner guide
- `~/.claude/docs/AGENTS.md` - Worker agent guide
