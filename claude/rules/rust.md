# Rust Development Conventions

## Code Style

- Use `cargo +nightly fmt --all` for formatting
- Run clippy with all features: `RUSTFLAGS="-D warnings" cargo +nightly clippy --workspace --all-features`
- Use `cargo nextest run` for testing when available

## Common Patterns

### Error Handling
- Use `?` operator for propagating errors
- Prefer `thiserror` for library errors, `anyhow` for application errors
- Add context with `.context()` or `.with_context()`

### Async Code
- Use `tokio` for async runtime
- Never block in async contexts - use `spawn_blocking` for CPU-intensive work
- Prefer `tokio::sync` primitives over std::sync in async code

### Performance
- Avoid allocations in hot paths
- Use `rayon` for CPU-bound parallelism
- Prefer `&str` over `String` where possible
- Use `Cow<'_, str>` for flexible ownership

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_component() {
        // Arrange
        let input = ...;

        // Act
        let result = function(input);

        // Assert
        assert_eq!(result, expected);
    }
}
```

## Common Commands

```bash
# Format
cargo +nightly fmt --all

# Lint
RUSTFLAGS="-D warnings" cargo +nightly clippy --workspace --all-features --locked

# Test
cargo nextest run --workspace

# Build release
cargo build --release

# Check all features
cargo check --workspace --all-features

# Documentation
cargo doc --document-private-items --open
```

## Anti-Patterns

- Don't use `.unwrap()` in production code
- Don't block async code with synchronous operations
- Don't ignore clippy warnings
- Don't use `unsafe` without thorough justification
