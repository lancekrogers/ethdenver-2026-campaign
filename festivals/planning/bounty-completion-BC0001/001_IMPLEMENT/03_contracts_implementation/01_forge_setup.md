---
fest_type: task
fest_id: 01_forge_setup.md
fest_name: forge setup
fest_parent: 03_contracts_implementation
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:46.81355-07:00
fest_tracking: true
---

# Task: Verify Forge Setup and Install Dependencies

## Objective

Confirm that Foundry is installed and configured correctly in `projects/contracts`, install OpenZeppelin contracts as a Forge dependency, and verify that `forge build` runs clean before any Solidity files are written.

## Requirements

- [ ] Foundry (`forge`, `cast`, `anvil`) installed and accessible in PATH
- [ ] `foundry.toml` exists in `projects/contracts` with correct `src`, `test`, `script` paths
- [ ] OpenZeppelin Contracts v5 installed via `forge install`
- [ ] Remapping configured in `foundry.toml` or `remappings.txt` so `@openzeppelin/contracts/` resolves
- [ ] `forge build` exits 0 (on whatever Solidity files already exist, even if directory is empty)

## Implementation

Step 1: Check if Foundry is installed.

```bash
forge --version
```

If not installed, run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Step 2: Inspect the contracts project structure.

```bash
ls projects/contracts/
cat projects/contracts/foundry.toml
```

If `foundry.toml` does not exist, create it:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
test = "test"
script = "script"
solc = "0.8.24"
evm_version = "paris"

[profile.default.optimizer]
enabled = true
runs = 200
```

Note: Use `evm_version = "paris"` for Hedera EVM compatibility — Hedera supports up to Paris.

Step 3: Create required directories if they do not exist.

```bash
mkdir -p projects/contracts/src
mkdir -p projects/contracts/test
mkdir -p projects/contracts/script
mkdir -p projects/contracts/lib
```

Step 4: Install OpenZeppelin Contracts.

```bash
cd projects/contracts
forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

Step 5: Configure remapping. Add to `foundry.toml` under `[profile.default]`:

```toml
remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"
]
```

Or create `remappings.txt`:

```
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
```

Step 6: Run forge build to confirm setup is clean.

```bash
cd projects/contracts
forge build
```

It should exit 0. If there are existing Solidity files with errors, note them but do not fix them here — this task only verifies the toolchain.

## Done When

- [ ] All requirements met
- [ ] `forge --version` shows a valid Foundry version
- [ ] `forge build` exits 0 in `projects/contracts`
- [ ] `@openzeppelin/contracts/` remapping resolves without errors
