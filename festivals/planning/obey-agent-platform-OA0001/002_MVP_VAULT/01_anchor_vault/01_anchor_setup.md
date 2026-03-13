---
fest_type: task
fest_id: 01_anchor_setup.md
fest_name: anchor_setup
fest_parent: 01_anchor_vault
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.355188-06:00
fest_tracking: true
---

# Task: Anchor Project Setup and Cargo Configuration

## Objective

Configure the `obey-mvp-vault` Anchor program with all required dependencies, Cargo.toml settings, and project scaffolding so subsequent tasks can implement instructions directly.

## Requirements

- [ ] `Anchor.toml` exists at `projects/obey-platform/` root with correct program ID and cluster config
- [ ] `Cargo.toml` for `obey-mvp-vault` includes `anchor-lang`, `anchor-spl`, and `spl-token` dependencies
- [ ] Program compiles with `anchor build` (stub instructions are fine)
- [ ] Program ID is generated via `anchor keys list` and set in both `declare_id!()` and `Anchor.toml`
- [ ] Overflow checks enabled in release profile for integer safety

## Implementation

### Step 1: Create `Anchor.toml` at project root

File: `projects/obey-platform/Anchor.toml`

```toml
[features]
seeds = false
skip-lint = false

[programs.localnet]
obey_mvp_vault = "11111111111111111111111111111111"

[programs.devnet]
obey_mvp_vault = "11111111111111111111111111111111"

[registry]
url = "https://api.apr.dev"

[provider]
cluster = "Localnet"
wallet = "~/.config/solana/id.json"

[scripts]
test = "yarn run ts-mocha -p ./tsconfig.json -t 1000000 tests/**/*.ts"
```

### Step 2: Configure `Cargo.toml` for the vault program

File: `projects/obey-platform/programs/obey-mvp-vault/Cargo.toml`

```toml
[package]
name = "obey-mvp-vault"
version = "0.1.0"
description = "OBEY MVP Vault — minimal deposit/withdraw program for AI agent economy"
edition = "2021"

[lib]
crate-type = ["cdylib", "lib"]
name = "obey_mvp_vault"

[features]
no-entrypoint = []
no-idl = []
no-log-ix-name = []
cpi = ["no-entrypoint"]
default = []

[dependencies]
anchor-lang = { version = "0.30.1", features = ["init-if-needed"] }
anchor-spl = "0.30.1"
```

### Step 3: Create workspace `Cargo.toml` at project root

File: `projects/obey-platform/Cargo.toml`

```toml
[workspace]
members = [
    "programs/*"
]
resolver = "2"

[profile.release]
overflow-checks = true
lto = "fat"
codegen-units = 1

[profile.release.build-override]
opt-level = 3
```

### Step 4: Generate a real program ID

```bash
cd projects/obey-platform
anchor keys list
# Copy the generated key for obey_mvp_vault
```

Update `declare_id!()` in `programs/obey-mvp-vault/src/lib.rs` and both `[programs.localnet]` and `[programs.devnet]` sections in `Anchor.toml` with the generated key.

### Step 5: Verify the build compiles

```bash
cd projects/obey-platform
anchor build
```

The existing stub in `lib.rs` should compile cleanly. If `anchor` is not installed, install via:

```bash
cargo install --git https://github.com/coral-xyz/anchor avm --locked
avm install 0.30.1
avm use 0.30.1
```

### Step 6: Update the justfile

Ensure `projects/obey-platform/justfile` has these recipes working:

```just
build:
    anchor build

test:
    anchor test

keys:
    anchor keys list
```

## Done When

- [ ] All requirements met
- [ ] `anchor build` completes without errors
- [ ] `anchor keys list` returns a valid program ID
- [ ] `declare_id!()` in lib.rs matches the program ID in Anchor.toml
- [ ] `Cargo.toml` has `overflow-checks = true` in release profile
