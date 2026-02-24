# Worldcoin Development Conventions

## Domain Expertise Mapping

When working on Worldcoin projects, leverage specialized agents via the Task tool:

| Project/Domain | Primary Agents | Secondary Agents |
|---------------|----------------|------------------|
| world-chain | `rust-expert`, `worldcoin-expert` | `reth-expert`, `optimism-expert` |
| world-id-protocol | `solidity-expert`, `worldcoin-expert` | `zk-cryptography-expert` |
| iris-mpc | `rust-expert`, `zk-cryptography-expert` | |
| semaphore-rs | `rust-expert`, `zk-cryptography-expert` | |
| orb-software | `rust-expert` | `infrastructure-expert` |
| telemetry-batteries | `rust-expert` | |
| oxide | `rust-expert` | |
| go-sonic | `go-expert` | |
| developer-portal | `typescript-expert` | |
| developer-docs | `typescript-expert` | |
| bedrock | `go-expert`, `optimism-expert` | |
| world-chain-builder-deploy | `infrastructure-expert` | `rust-expert` |

## Agent Selection Guidelines

### Always use `rust-expert` when:
- Working with any `.rs` files
- Debugging Cargo.toml dependency issues
- Async/await patterns with tokio
- Performance optimization in Rust code
- Error handling with thiserror/anyhow

### Combine `rust-expert` with domain experts:
- ZK code: `rust-expert` + `zk-cryptography-expert`
- Blockchain: `rust-expert` + `reth-expert` or `ethereum-expert`
- Infrastructure: `rust-expert` + `infrastructure-expert`

## Project-Specific Patterns

### World Chain (OP Stack L2)
**Agents:** `rust-expert`, `worldcoin-expert`, `reth-expert`, `optimism-expert`

- Built on reth + OP Stack
- Uses Flashblocks for fast L2 blocks
- Priority Bundle Handler (PBH) for World ID verified transactions
- Builder configuration in `world-chain-builder`

```rust
// Priority transaction patterns
use world_chain_builder::pbh::{PriorityBundleHandler, WorldIdVerifier};

// Async patterns - use tokio primitives
use tokio::sync::{mpsc, RwLock};
```

### World ID Protocol
**Agents:** `solidity-expert`, `worldcoin-expert`, `zk-cryptography-expert`

- Semaphore-based ZK proofs for privacy-preserving identity
- On-chain verification via WorldIDRouter
- OPRF protocol for iris biometric privacy

Key contracts:
- `WorldIDRouter.sol` - Entry point for verification
- `SemaphoreVerifier.sol` - Groth16 proof verification
- `WorldIDIdentityManager.sol` - Merkle tree management

### Iris MPC / Semaphore-rs
**Agents:** `rust-expert`, `zk-cryptography-expert`

- Groth16 proofs over BN254
- Poseidon hash for Merkle trees
- nullifier hash prevents double-signaling
- MPC protocols for secure computation

```rust
// Semaphore patterns
use semaphore::{identity::Identity, merkle_tree::MerkleTree, proof::Proof};

// Use Cow for flexible ownership in ZK code paths
use std::borrow::Cow;
```

### Orb Software / Telemetry Batteries
**Agents:** `rust-expert`

- Embedded-adjacent Rust patterns
- Heavy use of async/tokio
- Telemetry and observability

```rust
// Telemetry patterns
use tracing::{info, instrument, span, Level};
use metrics::{counter, gauge, histogram};
```

## Code Quality Standards

### Rust Projects (All Worldcoin Rust)
```bash
# Format (required before commit)
cargo +nightly fmt --all

# Lint with all features - treat warnings as errors
RUSTFLAGS="-D warnings" cargo +nightly clippy --workspace --all-features --locked

# Test with nextest (preferred)
cargo nextest run --workspace

# Or standard test
cargo test --workspace
```

### Solidity Projects
```bash
# Format
forge fmt

# Test with verbosity
forge test -vvv

# Coverage
forge coverage

# Gas snapshots
forge snapshot
```

### TypeScript Projects
```bash
# Lint and format
npm run lint
npm run format

# Type check
npm run typecheck
```

## Security Considerations

### ZK Circuits
- Never expose witness data in logs
- Validate all public inputs on-chain
- Use constant-time operations for secret handling
- Audit nullifier derivation carefully

### Rust Code
- Never use `.unwrap()` in production code
- Prefer `?` operator with proper error context
- Use `spawn_blocking` for CPU-intensive work in async contexts
- Avoid allocations in hot paths

### Smart Contracts
- Use OpenZeppelin contracts where applicable
- Follow checks-effects-interactions pattern
- Consider upgradability implications
- Test with invariant/fuzz testing

### Infrastructure
- No secrets in code or logs
- Use sealed secrets for Kubernetes
- Rotate credentials regularly
- Audit IAM policies

## Common Workflows

### Adding a New Feature to World Chain
1. Use `rust-expert` + `worldcoin-expert` for implementation
2. Understand the OP Stack derivation pipeline
3. Check if changes affect L1/L2 message passing
4. Consider Flashblocks timing implications
5. Update PBH if it affects priority transactions
6. Test with local devnet before testnet

### Modifying World ID Circuits
1. Use `zk-cryptography-expert` + `rust-expert` for circuit changes
2. Regenerate proving/verification keys
3. Update on-chain verifier contract
4. Test proof generation and verification e2e
5. Verify nullifier uniqueness properties

### Rust Performance Work
1. Use `rust-expert` for optimization
2. Profile with `cargo flamegraph` or `perf`
3. Use `rayon` for CPU-bound parallelism
4. Consider `Cow<'_, str>` for flexible ownership
5. Avoid unnecessary allocations

## Resources

- World Chain docs: Internal documentation
- OP Stack specs: https://specs.optimism.io/
- Semaphore protocol: https://semaphore.pse.dev/
- reth book: https://reth.rs/
- Tokio docs: https://tokio.rs/
