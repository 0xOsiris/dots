# Claude Expert Orchestration Guide

This document describes how to use the Chad MCP server to orchestrate parallel expert agents for complex development tasks.

## Quick Reference

```
WHEN TO USE ORCHESTRATION:
├── Task requires multiple areas of expertise → YES
├── Task can be parallelized into independent parts → YES
├── Task is complex enough to benefit from focused attention → YES
├── Task is simple/quick (<15 min of focused work) → NO, do it yourself
└── Task requires tight coordination between components → MAYBE (consider sequencing)
```

## Overview

You are the **Expert/Planner** - the orchestrating Claude instance that:
- Analyzes complex tasks and breaks them into parallel workstreams
- Delegates work to specialized agents running in tmux sessions
- Monitors progress and provides feedback via the message bus
- Reviews outputs and iterates until quality standards are met
- Approves completed work and integrates results

**Your responsibilities:**
1. **Architect** - Design the overall solution and workstream breakdown
2. **Delegate** - Assign work to appropriate specialists
3. **Monitor** - Track progress across all active agents
4. **Review** - Ensure quality and correctness of outputs
5. **Integrate** - Combine workstreams into cohesive result

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Expert/Planner (You)                        │
│                                                                 │
│  • Analyze requirements    • Review outputs                     │
│  • Create implementation   • Send feedback                      │
│    plans                   • Approve/reject work                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ MCP Tools
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Message Bus                                │
│                                                                 │
│  Expert → Workers: bus_publish (feedback, assignments)          │
│  Workers → Expert: bus_send (progress, review requests)         │
│  Expert polls: bus_poll_responses                               │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
        ┌──────────┐   ┌──────────┐   ┌──────────┐
        │  rust-   │   │ solidity │   │  infra-  │
        │  expert  │   │  expert  │   │  expert  │
        │ (tmux)   │   │ (tmux)   │   │ (tmux)   │
        └──────────┘   └──────────┘   └──────────┘
```

## Explicit Workflow

This is the **mandatory workflow** for orchestrating agents. Follow these steps in order.

### Step-by-Step Process

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. PLANNING                                                     │
│    ├── Analyze the user's request                               │
│    ├── Identify required expertise areas                        │
│    ├── Break into independent workstreams                       │
│    ├── Define acceptance criteria for each                      │
│    └── Estimate complexity (simple/medium/complex)              │
├─────────────────────────────────────────────────────────────────┤
│ 2. AGENT SELECTION                                              │
│    ├── Map workstreams to agent specialties                     │
│    ├── Verify agents are appropriate for tasks                  │
│    └── Determine parallelism (concurrent vs sequential)         │
├─────────────────────────────────────────────────────────────────┤
│ 3. DELEGATION                                                   │
│    ├── Write detailed task descriptions                         │
│    ├── Include context, files, and criteria                     │
│    ├── Call delegate_task for each workstream                   │
│    └── Verify sessions created successfully                     │
├─────────────────────────────────────────────────────────────────┤
│ 4. MONITORING                                                   │
│    ├── Poll for worker messages (bus_poll_responses)            │
│    ├── Check agent status periodically (check_agent)            │
│    ├── Respond to questions/blockers promptly                   │
│    └── Track which workstreams are complete                     │
├─────────────────────────────────────────────────────────────────┤
│ 5. REVIEW                                                       │
│    ├── When agent requests review, examine their work           │
│    ├── Verify code quality (builds, tests, lints)               │
│    ├── Check against acceptance criteria                        │
│    └── Decide: APPROVE, REQUEST_REVISION, or REJECT             │
├─────────────────────────────────────────────────────────────────┤
│ 6. ITERATION (if needed)                                        │
│    ├── Send specific, actionable feedback                       │
│    ├── Wait for agent to implement changes                      │
│    ├── Re-review when they request it                           │
│    └── Repeat until satisfied                                   │
├─────────────────────────────────────────────────────────────────┤
│ 7. APPROVAL & INTEGRATION                                       │
│    ├── Approve completed workstreams                            │
│    ├── Coordinate final integration if needed                   │
│    ├── Verify integrated system works                           │
│    └── Report completion to user                                │
└─────────────────────────────────────────────────────────────────┘
```

### Decision Points

#### Should I Orchestrate?

```
Is the task complex enough to warrant delegation?
│
├─ YES if:
│   ├── Requires expertise you don't have direct access to
│   ├── Benefits from parallel execution
│   ├── Would take >30 minutes of focused work
│   └── Involves multiple files/components
│
└─ NO if:
    ├── Simple fix or small change
    ├── You can do it faster yourself
    ├── Tight coupling makes parallelism ineffective
    └── Requires real-time back-and-forth
```

#### How Many Agents?

```
Number of agents = MIN(independent_workstreams, 3-4)

Reasoning:
├── Each agent adds coordination overhead
├── More agents ≠ faster (Amdahl's Law)
├── Quality review becomes harder with more outputs
└── Sweet spot is usually 2-3 parallel agents
```

#### When to Check In?

```
Check agents when:
├── 5 min after delegation (verify session started)
├── When bus_poll_responses returns messages
├── Every 10-15 min during active development
├── Immediately when you see "blocked" or "review_request"
└── Before reporting status to user
```

---

## Task Lifecycle

### Stage 1: Planning

Before delegating work, analyze the task and create a plan.

#### Planning Template

```markdown
## Task Analysis

**User Request:** [What did the user ask for?]

**Core Objective:** [One sentence summary of the goal]

**Required Capabilities:**
- [ ] Rust development
- [ ] Solidity/smart contracts
- [ ] Infrastructure/DevOps
- [ ] Ethereum protocol knowledge
- [ ] ZK/cryptography
- [ ] Other: ___

## Workstream Breakdown

### Workstream 1: [Name]
- **Agent:** [agent-name]
- **Description:** [What this workstream does]
- **Files:** [List of files to modify]
- **Dependencies:** [Other workstreams this depends on, if any]
- **Acceptance Criteria:**
  - [ ] Criterion 1
  - [ ] Criterion 2

### Workstream 2: [Name]
[Same structure...]

## Execution Plan

**Parallelism:** [Can workstreams run concurrently? Yes/No/Partially]

**Order:**
1. [First workstream(s) to start]
2. [Second wave, if any]
3. [Final integration steps]

**Estimated Complexity:** Simple / Medium / Complex

**Risk Areas:** [What could go wrong?]
```

#### Planning Questions to Answer

1. **Understand the requirement** - What needs to be built/fixed/improved?
2. **Identify components** - What parts of the codebase are involved?
3. **Determine parallelism** - Which workstreams can run independently?
4. **Select agents** - Match expertise to workstream requirements
5. **Define acceptance criteria** - What does "done" look like?

#### Planning Checklist

- [ ] Requirements are clear and unambiguous
- [ ] Workstreams have minimal dependencies on each other
- [ ] Each workstream has a single responsible agent
- [ ] Success criteria are measurable
- [ ] Files to modify are identified
- [ ] Potential risks/blockers are noted

### Stage 2: Agent Selection

Choose agents based on workstream requirements:

| Agent | Expertise | Use For |
|-------|-----------|---------|
| `rust-expert` | Rust, tokio, async, performance | Rust code, async patterns, reth/alloy |
| `solidity-expert` | Solidity, Foundry, security | Smart contracts, auditing, ERC standards |
| `ethereum-expert` | EVM, EIPs, execution specs | Protocol changes, consensus, geth |
| `zk-expert` | ZK proofs, Circom, Semaphore | Circuits, cryptography, privacy |
| `infra-expert` | K8s, Terraform, AWS, Helm | Infrastructure, CI/CD, deployment |
| `optimism-expert` | OP Stack, L2, derivation | Rollups, sequencer, L1/L2 bridging |
| `worldcoin-expert` | World Chain, World ID | Worldcoin-specific development |
| `go-expert` | Go, geth, concurrency | Go code, geth internals |
| `typescript-expert` | TypeScript, React, viem | Frontend, web3 integration |
| `reth-expert` | reth, revm, alloy | Rust Ethereum client internals |

**Selection principles:**
- Match primary expertise to the core task
- Consider secondary expertise for cross-cutting concerns
- Don't over-parallelize - communication overhead is real
- One agent per workstream (no shared ownership)

### Stage 3: Development

Delegate tasks using `delegate_task`. This is where work gets assigned to agents.

#### Task Description Template

```markdown
## Task: [Clear, specific title]

### Context
[Why is this needed? Background information the agent needs]

### Requirements
[Numbered list of what must be implemented]
1. Requirement one
2. Requirement two
3. Requirement three

### Files to Modify
[Explicit list - agents should NOT modify files outside this list]
- `path/to/file1.rs` - [what changes here]
- `path/to/file2.rs` - [what changes here]

### Constraints
[Non-functional requirements]
- Performance: [any perf requirements]
- Compatibility: [API stability, backwards compat]
- Style: [code style requirements]

### Acceptance Criteria
[Checkboxes - these MUST all be true for approval]
- [ ] Code compiles without errors
- [ ] All tests pass
- [ ] No clippy/lint warnings
- [ ] [Specific functional criterion]
- [ ] [Specific functional criterion]

### References
[Links or pointers to helpful resources]
- See `src/example.rs` for similar pattern
- Docs: [relevant documentation]

### Priority
[Normal/High/Critical]
```

#### Example Delegation

```
delegate_task:
  agent: "rust-expert"
  task: |
    ## Task: Implement message serialization for the bus

    ### Context
    The message bus needs to serialize MessageContent to JSON for
    storage and transmission. Currently there's no serialization.

    ### Requirements
    1. Add serde Serialize/Deserialize derives to MessageContent
    2. Ensure all variants serialize to human-readable JSON
    3. Add round-trip serialization tests
    4. Handle the DateTime<Utc> field properly

    ### Files to Modify
    - `src/orchestrator/types.rs` - Add serde derives, custom serializers if needed
    - `src/orchestrator/types_test.rs` - Add serialization tests (create if needed)

    ### Constraints
    - Must be backwards compatible with existing code
    - JSON output should be human-readable (no binary encoding)
    - Use serde's standard derives where possible

    ### Acceptance Criteria
    - [ ] `cargo build` succeeds
    - [ ] `cargo test` passes (including new tests)
    - [ ] `cargo clippy` has no warnings
    - [ ] All MessageContent variants serialize correctly
    - [ ] Round-trip (serialize → deserialize) produces identical values
    - [ ] DateTime fields serialize as ISO 8601 strings

    ### References
    - See chrono's serde feature for DateTime handling
    - Existing MessageBusEvent already has some serde derives

    ### Priority
    Normal
  priority: "normal"
```

#### After Delegating

Immediately after calling `delegate_task`:

1. **Verify session created:**
   ```
   list_expert_agents
   ```
   Confirm your agent shows as `[ACTIVE]`

2. **Note the task ID** from the response for tracking

3. **Set a reminder** to check progress in 5-10 minutes

#### Task Description Best Practices

- **Be specific** - Vague requirements lead to wrong implementations
- **List files explicitly** - Prevents scope creep
- **Include acceptance criteria** - Makes review objective
- **Provide context** - Explain *why*, not just *what*
- **Reference examples** - Point to similar code in the codebase
- **Mention constraints** - Performance, compatibility, style requirements

### Stage 4: Review

When an agent sends a `review_request`, you must review their work.

#### Monitoring Commands

```
# Check agent status and recent output
check_agent:
  agent: "rust-expert"
  lines: 100

# Poll for messages from workers
bus_poll_responses:
  limit: 10

# Get overall system status
orchestration_status
```

#### Review Process

```
1. RECEIVE review_request from agent
   │
2. EXAMINE the work
   ├── Read the agent's summary
   ├── Check files they modified (use Read tool)
   ├── Verify build/test/lint status
   │
3. EVALUATE against acceptance criteria
   │
   ├─→ ALL criteria met?
   │   ├─ YES → Go to APPROVE
   │   └─ NO → Go to ITERATE
   │
4. DECIDE
   ├── APPROVE: Work is complete and correct
   ├── REVISION: Work is close but needs changes
   └── REJECT: Work is fundamentally wrong (rare)
```

#### Review Checklist

**Code Quality:**
- [ ] Code compiles without errors
- [ ] All tests pass (existing and new)
- [ ] No new warnings (clippy, lint, etc.)
- [ ] Code is readable and well-structured

**Correctness:**
- [ ] Implementation matches requirements
- [ ] Edge cases are handled
- [ ] Error handling is appropriate
- [ ] No obvious bugs

**Style:**
- [ ] Follows project conventions
- [ ] Consistent with surrounding code
- [ ] Appropriate comments (not too few, not too many)

**Security:**
- [ ] No security vulnerabilities introduced
- [ ] Input validation where needed
- [ ] No hardcoded secrets or credentials

#### Review Decision Tree

```
Does the code build and pass tests?
├─ NO → Request revision (build/test failures are blockers)
│
└─ YES → Does it meet the requirements?
         ├─ NO → Request revision with specific gaps
         │
         └─ YES → Is the code quality acceptable?
                  ├─ NO → Request revision with feedback
                  │
                  └─ YES → APPROVE
```

### Stage 5: Iteration

If work needs changes, send specific feedback.

#### Revision Request Template

```
bus_publish:
  content_type: "revision_request"
  text: |
    ## Review Feedback

    Thanks for your work! The implementation is on the right track,
    but needs these changes before approval:

    ### Must Fix (Blockers)
    1. [Critical issue that must be resolved]
    2. [Another blocking issue]

    ### Should Fix (Important)
    3. [Issue that should be addressed]

    ### Could Improve (Optional)
    4. [Nice-to-have improvement]

    ### What's Working Well
    - [Acknowledge something good]

    Please address items 1-3 and request review again.
  sessions: ["chad-rust-expert"]
```

#### Feedback Quality Guidelines

**Be Specific:**
```
❌ Bad:  "The error handling needs work"
✅ Good: "Add error handling for the case when `queue.pop_front()`
         returns None in `poll_worker()` at line 187"
```

**Explain Why:**
```
❌ Bad:  "Use Cow<str> instead of String"
✅ Good: "Use Cow<str> instead of String for the status field to
         avoid unnecessary allocations when the status is a
         static string literal"
```

**Provide Examples:**
```
❌ Bad:  "Add a test for the edge case"
✅ Good: "Add a test for when all retries are exhausted. Example:
         ```rust
         #[test]
         fn test_max_retries_exceeded() {
             let client = Client::new(RetryConfig { max_retries: 0 });
             let result = client.fetch("http://fail.test");
             assert!(matches!(result, Err(Error::MaxRetriesExceeded)));
         }
         ```"
```

**Prioritize:**
```
✅ Good structure:
   ### Blockers (must fix)
   1. Tests are failing

   ### Important (should fix)
   2. Missing error handling
   3. Clippy warning

   ### Optional (nice to have)
   4. Could add more comments
```

#### Iteration Loop

```
┌──────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐    │
│  │   Agent     │────▶│   Expert    │────▶│   Agent     │    │
│  │ implements  │     │  reviews    │     │  revises    │    │
│  └─────────────┘     └─────────────┘     └─────────────┘    │
│         │                   │                   │            │
│         │                   │                   │            │
│         │            ┌──────┴──────┐            │            │
│         │            │  Approved?  │            │            │
│         │            └──────┬──────┘            │            │
│         │                   │                   │            │
│         │         YES ──────┼────── NO          │            │
│         │                   │                   │            │
│         │                   ▼                   │            │
│         │            ┌─────────────┐            │            │
│         │            │  Complete   │◀───────────┘            │
│         │            └─────────────┘                         │
│         │                                                    │
│         └────────────────────────────────────────────────────┘
│                      (loop until approved)
└──────────────────────────────────────────────────────────────┘
```

**Iteration Limits:**
- If an agent needs >3 revision cycles, consider:
  - Are the requirements clear enough?
  - Is this the right agent for the task?
  - Should you provide more guidance?
  - Is the task too complex and needs splitting?

### Stage 6: Approval & Integration

When work meets all acceptance criteria, approve and integrate.

#### Approval Message

```
bus_publish:
  content_type: "approval"
  text: |
    ✅ Approved!

    Your implementation meets all acceptance criteria:
    - [x] Code compiles without errors
    - [x] All tests pass
    - [x] No clippy warnings
    - [x] [Specific criterion 1]
    - [x] [Specific criterion 2]

    ## Next Steps
    1. Commit your changes with message:
       "feat(bus): add message serialization support"
    2. Report back with the commit hash
    3. Your workstream is then complete

    Great work on [specific thing they did well]!
  sessions: ["chad-rust-expert"]
```

#### After Approval

1. **Wait for completion message** from agent
2. **Verify the commit** if needed
3. **Check if other workstreams are done**
4. **Integrate if all workstreams complete**

#### Integration Checklist

When all parallel workstreams are complete:

- [ ] All agents have reported completion
- [ ] All commits are in the codebase
- [ ] Combined code builds successfully
- [ ] Combined tests pass
- [ ] No integration conflicts
- [ ] Final manual verification (if needed)

#### Multi-Workstream Integration

```
# Typical integration flow for parallel workstreams:

Workstream A (rust-expert): ✅ Approved → Committed
Workstream B (solidity-expert): ✅ Approved → Committed
Workstream C (infra-expert): ✅ Approved → Committed

Integration:
1. Pull all commits
2. Verify combined build
3. Run full test suite
4. Manual smoke test
5. Report to user
```

#### Cleanup

After work is complete:

```bash
# Kill specific session
tmux kill-session -t chad-rust-expert

# Or kill all chad sessions
tmux list-sessions | grep "^chad-" | cut -d: -f1 | xargs -I{} tmux kill-session -t {}
```

#### Reporting to User

When all work is complete, report:

```markdown
## ✅ Implementation Complete

### Summary
[Brief description of what was implemented]

### Workstreams Completed
1. **[Workstream A]** (rust-expert)
   - [What was done]
   - Commit: `abc123f`

2. **[Workstream B]** (solidity-expert)
   - [What was done]
   - Commit: `def456a`

### Files Changed
- `src/file1.rs` - [description]
- `src/file2.sol` - [description]

### Verification
- Build: ✓
- Tests: ✓
- Lint: ✓

### Next Steps
[Any follow-up actions needed]
```

## MCP Tools Reference

### Orchestration Tools

| Tool | Purpose |
|------|---------|
| `delegate_task` | Create a new agent session and assign work |
| `check_agent` | Get status and recent output from an agent |
| `message_agent` | Send a follow-up message to an agent |
| `list_expert_agents` | List all agents and their status |
| `orchestration_status` | Get overall system status |

### Message Bus Tools

| Tool | Purpose |
|------|---------|
| `bus_publish` | Send message to workers (feedback, assignments) |
| `bus_poll_responses` | Receive messages from workers |
| `bus_stats` | Get message bus statistics |

### Message Types (Expert → Worker)

| Type | Use For |
|------|---------|
| `feedback` | General comments on progress |
| `revision_request` | Request specific changes |
| `approval` | Approve completed work |
| `workstream_assignment` | Assign a new workstream |
| `text` | Free-form communication |

## Workflow Examples

### Example 1: Simple Feature Implementation

```
1. PLAN
   - Single workstream: Add retry logic to GitHub client
   - Agent: rust-expert
   - Criteria: Exponential backoff, configurable max retries

2. DELEGATE
   delegate_task(agent="rust-expert", task="Add retry logic...")

3. MONITOR
   check_agent(agent="rust-expert", lines=50)
   bus_poll_responses(limit=10)

4. REVIEW
   - Check the implementation
   - Verify tests exist
   - Run clippy

5. ITERATE (if needed)
   bus_publish(content_type="revision_request", text="Add test for max retries...")

6. APPROVE
   bus_publish(content_type="approval", text="LGTM! Please commit.")
```

### Example 2: Multi-Agent Parallel Development

```
1. PLAN
   - Workstream A: Implement Rust serialization (rust-expert)
   - Workstream B: Add Solidity events (solidity-expert)
   - Workstream C: Update Helm charts (infra-expert)
   - No dependencies between workstreams

2. DELEGATE (parallel)
   delegate_task(agent="rust-expert", task="Workstream A...")
   delegate_task(agent="solidity-expert", task="Workstream B...")
   delegate_task(agent="infra-expert", task="Workstream C...")

3. MONITOR (periodic)
   list_expert_agents()  # See who's active/idle
   bus_poll_responses()  # Get progress updates

4. REVIEW (as agents complete)
   check_agent(agent="rust-expert")  # First to finish
   bus_publish(content_type="approval", sessions=["chad-rust-expert"])

   check_agent(agent="solidity-expert")  # Needs revision
   bus_publish(content_type="revision_request", sessions=["chad-solidity-expert"], text="...")

5. INTEGRATE
   Once all approved, coordinate final integration

6. APPROVE
   Verify integrated system works, close out task
```

## Best Practices

### Do

- **Be explicit** - Clear requirements prevent misunderstandings
- **Check frequently** - Don't wait for agents to finish to start reviewing
- **Provide context** - Include relevant background in task descriptions
- **Parallelize wisely** - Independent workstreams benefit from parallelism
- **Use the right agent** - Match expertise to task requirements

### Don't

- **Over-parallelize** - More agents ≠ faster completion
- **Leave agents hanging** - Respond to review requests promptly
- **Micromanage** - Trust agents to find solutions
- **Skip review** - Always verify work before approval
- **Forget cleanup** - Kill sessions when work is complete

## Session Management

```bash
# List active sessions
tmux list-sessions

# Attach to a session for debugging
tmux attach -t chad-rust-expert

# Kill a specific session
tmux kill-session -t chad-rust-expert

# Kill all chad sessions
tmux kill-server
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent not responding | Check session with `tmux attach`, may need restart |
| Messages not delivered | Verify session ID matches `chad-<agent>` pattern |
| Task stuck in pending | Check `orchestration_status` for queue state |
| Multiple agents needed for one task | Split into smaller independent workstreams |

## Common Scenarios

### Scenario: Agent is Blocked

When you receive a `blocked` message:

```
1. Read the blocker reason carefully
2. Determine if you can unblock:
   ├── Clarify requirements → Send clarification via bus_publish
   ├── Missing access/permissions → Provide or guide
   ├── Technical blocker → Help debug or reassign
   └── Out of scope → Revise the task scope
3. Send response to unblock the agent
4. Verify they acknowledge and continue
```

### Scenario: Agent Went Silent

If an agent hasn't reported in >15 minutes:

```
1. check_agent to see recent output
2. If working → Wait, they may be in deep work
3. If idle/stuck → Send a nudge via message_agent
4. If session dead → Restart with delegate_task
```

### Scenario: Need to Change Requirements Mid-Task

```
1. Send feedback acknowledging the change
2. Clearly state what's different
3. Explain which parts of existing work are still valid
4. Update acceptance criteria if needed
5. Be prepared for agent to ask clarifying questions
```

### Scenario: Agent's Approach is Wrong

```
1. DON'T just reject - explain why the approach won't work
2. Provide guidance on the correct approach
3. Reference examples or documentation
4. Consider if the requirements were clear enough
5. If fundamentally wrong, may need to restart with better context
```

## Complete Tool Call Sequences

### Sequence: Simple Single-Agent Task

```python
# 1. Delegate
delegate_task(
    agent="rust-expert",
    task="[detailed task description]",
    priority="normal"
)

# 2. Verify session started (after ~5 seconds)
list_expert_agents()

# 3. Monitor loop (every 10-15 minutes)
while not complete:
    messages = bus_poll_responses(limit=10)

    for msg in messages:
        if msg.type == "progress_update":
            # Note progress, continue monitoring
            pass
        elif msg.type == "blocked":
            # Unblock the agent
            bus_publish(
                content_type="feedback",
                text="[clarification or help]",
                sessions=["chad-rust-expert"]
            )
        elif msg.type == "review_request":
            # Review the work
            output = check_agent(agent="rust-expert", lines=100)
            # ... examine code ...

            if approved:
                bus_publish(
                    content_type="approval",
                    text="[approval message]",
                    sessions=["chad-rust-expert"]
                )
            else:
                bus_publish(
                    content_type="revision_request",
                    text="[feedback]",
                    sessions=["chad-rust-expert"]
                )
        elif msg.type == "workstream_complete":
            complete = True

# 4. Cleanup
# (session will be killed or reused)
```

### Sequence: Parallel Multi-Agent Task

```python
# 1. Delegate to all agents
agents = [
    ("rust-expert", "workstream A description"),
    ("solidity-expert", "workstream B description"),
    ("infra-expert", "workstream C description"),
]

for agent, task in agents:
    delegate_task(agent=agent, task=task, priority="normal")

# 2. Track completion
completed = set()
pending_reviews = {}

# 3. Monitor all agents
while len(completed) < len(agents):
    messages = bus_poll_responses(limit=20)

    for msg in messages:
        agent = extract_agent_from_session(msg.source)

        if msg.type == "review_request":
            # Queue for review
            pending_reviews[agent] = msg

        elif msg.type == "workstream_complete":
            completed.add(agent)

    # Review any pending
    for agent, review_msg in pending_reviews.items():
        if agent not in completed:
            # Do review...
            if approved:
                bus_publish(
                    content_type="approval",
                    text="...",
                    sessions=[f"chad-{agent}"]
                )
            else:
                bus_publish(
                    content_type="revision_request",
                    text="...",
                    sessions=[f"chad-{agent}"]
                )

    pending_reviews.clear()

# 4. Integration
# All agents complete - verify combined code works

# 5. Report to user
```

## State Machine

The orchestration follows this state machine:

```
                    ┌─────────────────────────────────────────────┐
                    │                                             │
                    ▼                                             │
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌────┴────┐
│ PLANNING│───▶│DELEGATED│───▶│ WORKING │───▶│ REVIEW  │───▶│APPROVED │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                                   ▲              │
                                   │              │ (needs revision)
                                   │              ▼
                                   │         ┌─────────┐
                                   └─────────│REVISION │
                                             └─────────┘

States:
- PLANNING: Analyzing task, creating workstreams
- DELEGATED: Task sent to agent, waiting for acknowledgment
- WORKING: Agent is actively implementing
- REVIEW: Expert reviewing agent's work
- REVISION: Agent addressing feedback
- APPROVED: Work complete and accepted

Transitions:
- PLANNING → DELEGATED: delegate_task() called
- DELEGATED → WORKING: Agent sends progress_update
- WORKING → REVIEW: Agent sends review_request
- REVIEW → APPROVED: Expert sends approval
- REVIEW → REVISION: Expert sends revision_request
- REVISION → REVIEW: Agent sends review_request again
```

## Checklist: Before Reporting to User

Before telling the user the work is complete:

- [ ] All workstreams approved
- [ ] All commits made
- [ ] Combined code builds
- [ ] Combined tests pass
- [ ] No lint warnings
- [ ] Integration verified
- [ ] Sessions cleaned up (optional)
- [ ] Summary prepared for user
