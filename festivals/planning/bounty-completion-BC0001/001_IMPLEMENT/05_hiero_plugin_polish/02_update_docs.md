---
fest_type: task
fest_id: 02_update_docs.md
fest_name: update docs
fest_parent: 05_hiero_plugin_polish
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T16:43:54.706473-07:00
fest_tracking: true
---

# Task: Update Hiero Plugin Submission and Architecture Docs

## Objective

Update `submission.md`, `architecture.md`, and `usage-guide.md` in `projects/hiero-plugin/docs/` so they accurately reflect the 0G template additions and are ready for Hedera Track 4 judging.

## Requirements

- [ ] `submission.md` mentions `0g-agent` and `0g-inft-build` templates, describes their purpose, and references the 0G Track 4 bounty eligibility
- [ ] `architecture.md` includes a section explaining how the 0G templates integrate with the plugin's template system and which 0G services they interact with (Compute, Storage, DA)
- [ ] `usage-guide.md` includes concrete `hiero camp init --template 0g-agent` and `hiero camp init --template 0g-inft-build` examples with expected output and next steps
- [ ] No stale references remain (e.g., old template names, old command flags, removed features)

## Implementation

### Step 1: Read the current docs

Read all three documents to understand their current structure and identify what needs to change:

```
projects/hiero-plugin/docs/submission.md
projects/hiero-plugin/docs/architecture.md
projects/hiero-plugin/docs/usage-guide.md
```

Note any existing 0G references that may be stubs or TODOs.

### Step 2: Update `submission.md`

Add a section for the 0G templates after the existing Hedera template content:

```markdown
## 0G Track 4 — Dev Tooling

The plugin includes two camp templates specifically designed for 0G development:

### `0g-agent` Template
A Go project scaffold that wires 0G Compute, Storage, and EVM chain interactions into a runnable agent. Developers can generate a new project with:

```bash
hiero camp init --template 0g-agent --name my-0g-agent
```

The generated project includes:
- `internal/zerog/compute.go` — 0G Compute broker client stub
- `internal/zerog/storage.go` — 0G Storage client stub
- `internal/zerog/chain.go` — EVM chain helpers (LoadKey, DialClient, MakeTransactOpts)
- `internal/config/config.go` — env-based configuration loader
- `Justfile` with build/run/test/lint recipes

### `0g-inft-build` Template
An ERC-7857 iNFT minting scaffold with AES-256-GCM encryption and 0G DA storage:

```bash
hiero camp init --template 0g-inft-build --name my-inft
```

The generated project includes:
- `internal/crypto/encrypt.go` — AES-256-GCM encrypt/decrypt
- `internal/da/publisher.go` — 0G DA layer publisher stub
- `internal/inft/minter.go` — ERC-7857 contract interaction via go-ethereum
- `Justfile` with build/run/test/lint recipes
```

### Step 3: Update `architecture.md`

Add a "0G Template Architecture" section:

```markdown
## 0G Template Architecture

The plugin's template system embeds Go project scaffolds under `templates/`. When a user runs `hiero camp init --template <name>`, the plugin:

1. Looks up the template in the registry (manifest.json or in-memory registry)
2. Copies the template directory tree to the target path
3. Optionally runs `go mod tidy` to resolve dependencies

### 0G Template Components

```
hiero-plugin/
  templates/
    0g-agent/
      internal/zerog/     ← 0G Compute + Storage + Chain stubs
      internal/config/    ← env-based config loader
      cmd/agent/          ← runnable entry point
    0g-inft-build/
      internal/crypto/    ← AES-256-GCM encrypt/decrypt
      internal/da/        ← 0G DA publisher stub
      internal/inft/      ← ERC-7857 minter via go-ethereum
      cmd/mint/           ← runnable entry point
```

Both templates target the 0G EVM-compatible testnet and require:
- `ZG_RPC_URL` pointing to `https://evmrpc-testnet.0g.ai`
- A funded private key (`ZG_PRIVATE_KEY`)
- Service-specific endpoints (Compute, Storage, DA)
```

### Step 4: Update `usage-guide.md`

Add a "0G Templates" section with complete worked examples:

```markdown
## 0G Templates

### Generate a 0G Compute+Storage agent

```bash
hiero camp init --template 0g-agent --name my-agent
cd my-agent
cp .env.example .env
# Edit .env with your ZG_RPC_URL, ZG_PRIVATE_KEY, etc.
just build
just run
```

Expected output:
```
0g-agent running — press Ctrl+C to stop
task=task-68656c6c stored=cid-68656c6c
```

### Generate an ERC-7857 iNFT minter

```bash
hiero camp init --template 0g-inft-build --name my-inft
cd my-inft
cp .env.example .env
# Edit .env with ZG_CONTRACT_ADDRESS and ZG_ENCRYPT_KEY
just build
just run
```

Expected output:
```
published encrypted model to DA: cid=da-cid-73747562
minted iNFT tokenID=12345678 tokenURI=0g-da://da-cid-73747562
```
```

### Step 5: Remove stale TODOs and placeholder text

Search each document for `TODO`, `REPLACE`, `TBD`, `[placeholder]`, or similar markers and either fill them in or remove them.

### Step 6: Verify with a final read

Re-read all three documents after editing to confirm they flow correctly and contain no obvious errors or broken markdown.

## Done When

- [ ] All requirements met
- [ ] All three docs updated with accurate 0G template content and no stale placeholders
