# Agent Interface Guide

This document describes how worker agents (Claude instances in tmux sessions) interface with the Chad MCP server to receive work, report progress, and communicate with the Expert.

## Overview

You are a **Worker Agent** - a specialized Claude instance that:
- Receives task assignments from the Expert/Planner
- Implements specific workstreams within your area of expertise
- Reports progress and requests reviews via the message bus
- Iterates based on feedback until work is approved

## Your Environment

When your session starts, you have:

```bash
# Session identification
$CHAD_SESSION_ID=chad-<your-agent-name>  # e.g., "chad-rust-expert"
$CHAD_AGENT=<your-agent-name>            # e.g., "rust-expert"

# Your tmux session
Session: chad-<agent-name>
Window: <agent-name>-main
```

## Message Bus Protocol

### Receiving Messages

The Expert sends messages that appear in your terminal. They look like this:

```
+------------------------------------------------------------------+
| FEEDBACK     from Expert               [14:32:15] |
+------------------------------------------------------------------+
  Your implementation looks good! A few suggestions:
  1. Consider adding error handling for edge cases
  2. The test coverage could be improved
+------------------------------------------------------------------+
```

You can also programmatically poll for messages:

```
bus_poll:
  session_id: "chad-rust-expert"  # Or omit to use $CHAD_SESSION_ID
  limit: 10
```

### Sending Messages

Report your status and request reviews using `bus_send`:

#### Progress Update
```
bus_send:
  content_type: "progress_update"
  status: "Completed initial implementation, writing tests"
  files_changed: ["src/lib.rs", "src/tests.rs"]
  steps_completed: [1, 2, 3]
```

#### Review Request
```
bus_send:
  content_type: "review_request"
  summary: |
    Implementation complete. Changes:
    - Added retry logic with exponential backoff
    - Configurable max_retries (default: 3)
    - Unit tests for all code paths
  files_changed: ["src/github.rs", "src/github_test.rs"]
```

#### Blocked
```
bus_send:
  content_type: "blocked"
  reason: |
    Need clarification on requirements:
    - Should retry apply to all HTTP methods or just GET?
    - What's the maximum backoff duration?
```

#### Workstream Complete
```
bus_send:
  content_type: "workstream_complete"
  summary: |
    ✅ Workstream complete!

    Implemented:
    - Exponential backoff retry logic
    - Configurable retry count and delays
    - Comprehensive test coverage

    Files changed:
    - src/github.rs (retry logic)
    - src/github_test.rs (new tests)

    Verified:
    - cargo build ✓
    - cargo test ✓
    - cargo clippy ✓
```

### Message Types Reference

| Type | When to Use | Required Fields |
|------|-------------|-----------------|
| `progress_update` | Periodic status updates | `status` |
| `review_request` | Ready for Expert review | `summary`, `files_changed` |
| `blocked` | Need help or clarification | `reason` |
| `workstream_complete` | All work done | `summary` |
| `text` | General communication | `text` |

## Task Lifecycle (Agent Perspective)

### 1. Receive Assignment

When delegated a task, you'll see it in your terminal:

```
## Task: Implement retry logic for GitHub API client

Requirements:
- Add exponential backoff for failed requests
- Make max retries configurable
- Add unit tests

Files to modify:
- src/github.rs

Acceptance criteria:
- All tests pass
- No clippy warnings
- Retry behavior is configurable

Priority: Normal
```

### 2. Acknowledge and Plan

Before starting work:
1. Read and understand the requirements
2. Identify files to modify
3. Plan your approach
4. Send initial progress update

```
bus_send:
  content_type: "progress_update"
  status: "Received task. Planning implementation approach."
```

### 3. Implement

Work on the task, sending periodic updates:

```
bus_send:
  content_type: "progress_update"
  status: "Implementing retry logic in github.rs"
  steps_completed: [1]
```

```
bus_send:
  content_type: "progress_update"
  status: "Writing unit tests"
  files_changed: ["src/github.rs"]
  steps_completed: [1, 2]
```

### 4. Request Review

When implementation is complete:

```
bus_send:
  content_type: "review_request"
  summary: |
    Ready for review!

    ## Changes
    - Added `RetryConfig` struct with configurable parameters
    - Implemented exponential backoff in `fetch_with_retry()`
    - Added 5 new unit tests covering retry scenarios

    ## Verification
    - `cargo build` ✓
    - `cargo test` ✓
    - `cargo clippy` ✓

    ## Files
    - src/github.rs: Added retry logic
    - src/github_test.rs: New test cases
  files_changed: ["src/github.rs", "src/github_test.rs"]
```

### 5. Handle Feedback

The Expert may request revisions:

```
+------------------------------------------------------------------+
| REVISION     from Expert               [15:45:22] |
+------------------------------------------------------------------+
  Good progress! Please make these changes:
  1. Add a test for the case when all retries are exhausted
  2. The delay calculation should cap at 30 seconds
  3. Log retry attempts at debug level
+------------------------------------------------------------------+
```

Acknowledge and implement:

```
bus_send:
  content_type: "progress_update"
  status: "Implementing requested changes from review"
```

Then request review again when complete.

### 6. Complete

When approved:

```
+------------------------------------------------------------------+
| APPROVAL     from Expert               [16:12:08] |
+------------------------------------------------------------------+
  ✅ Approved! Great work.

  Please commit with message:
  "feat(github): add retry logic with exponential backoff"
+------------------------------------------------------------------+
```

Commit and report completion:

```
bus_send:
  content_type: "workstream_complete"
  summary: |
    ✅ Complete!

    Committed: abc123f
    Message: "feat(github): add retry logic with exponential backoff"

    All acceptance criteria met.
```

## Communication Guidelines

### Progress Updates

Send updates:
- When starting a new phase of work
- After completing significant milestones
- When encountering unexpected issues
- At least every 15-20 minutes during active work

### Asking Questions

If requirements are unclear, ask immediately:

```
bus_send:
  content_type: "blocked"
  reason: |
    Need clarification before proceeding:

    1. The task mentions "retry failed requests" but doesn't specify:
       - Which HTTP status codes should trigger retry?
       - Should network errors also trigger retry?

    2. For exponential backoff:
       - What should be the base delay?
       - Is there a maximum delay cap?

    Waiting for response before implementing.
```

### Reporting Issues

If you encounter problems:

```
bus_send:
  content_type: "blocked"
  reason: |
    Encountered an issue:

    Error: `cargo test` fails with:
    ```
    error[E0433]: failed to resolve: use of undeclared type `RetryConfig`
    ```

    The type is defined in github.rs but not exported in lib.rs.

    Proposed fix: Add `pub use github::RetryConfig;` to lib.rs

    Please confirm this approach or suggest alternative.
```

## Best Practices

### Do

- **Acknowledge tasks promptly** - Send a progress update when you receive work
- **Update frequently** - The Expert can't see your work until you report
- **Be specific in reviews** - List exactly what changed and how to verify
- **Ask questions early** - Don't guess at requirements
- **Verify before requesting review** - Run tests, clippy, etc.
- **Keep messages concise** - Bullet points over paragraphs

### Don't

- **Go silent** - Always keep the Expert informed
- **Submit incomplete work** - Verify everything works first
- **Ignore feedback** - Address all points in revision requests
- **Make assumptions** - Ask if requirements are unclear
- **Forget context** - Reference relevant code/docs when asking questions

## Code Quality Checklist

Before requesting review, verify:

```bash
# Build
cargo build

# Tests
cargo test

# Linting
cargo clippy --all-features

# Format (if changed)
cargo fmt --check
```

For Solidity:
```bash
forge build
forge test
forge fmt --check
```

For TypeScript:
```bash
npm run build
npm test
npm run lint
```

## Example Session Flow

```
[14:00] Task received: "Implement message bus statistics"

[14:02] bus_send(progress_update): "Starting implementation"

[14:15] bus_send(progress_update): "Added BusStats struct, implementing stats() method"

[14:30] bus_send(progress_update): "Implementation complete, writing tests"

[14:45] bus_send(review_request): "Ready for review - added stats endpoint with tests"

[15:00] Received REVISION: "Add active_workstreams count"

[15:02] bus_send(progress_update): "Implementing requested changes"

[15:15] bus_send(review_request): "Changes complete, ready for re-review"

[15:20] Received APPROVAL: "LGTM! Please commit"

[15:22] bus_send(workstream_complete): "Committed as abc123f"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Not receiving messages | Check `$CHAD_SESSION_ID` is set correctly |
| Messages not sending | Use explicit `session_id` in `bus_send` |
| Expert not responding | They may be reviewing other agents - continue working |
| Unclear requirements | Send `blocked` message with specific questions |
| Unexpected errors | Report immediately, don't try to hide problems |
