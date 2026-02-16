# Camp as the Agent Workspace Standard

## Dual Purpose

| Axis | Score | Why |
|------|-------|-----|
| **Bounty** | Medium-High | Targets Hedera Hiero CLI Plugin $5k + Canton Dev Tooling $7k + 0G Dev Tooling $4k |
| **Exposure** | Very High | camp IS the product. Dev tooling bounties = direct marketing. |

## Concept

Position camp (the Campaign CLI) as the workspace management standard for AI agent development. Build hackathon-specific integrations that make camp indispensable for multi-chain, multi-agent projects:

1. **Hiero CLI plugin** that bridges camp workspace navigation to Hedera development
2. **Canton dev environment manager** that uses camp to scaffold Canton/Daml projects
3. **0G project templates** for camp that scaffold complete 0G agent projects

Each integration is a bounty submission AND a direct advertisement for camp's workflow management capabilities.

## Why Dev Tooling Bounties Are Perfect for Exposure

Dev tooling bounties ask: "Build something developers will use." If we build camp integrations, the developers who USE the tools become camp users. The bounty literally pays us to acquire users.

| Bounty | What We Build | Users Acquired |
|--------|--------------|---------------|
| Hedera Hiero CLI ($5k) | `hiero camp` plugin | Hedera developers |
| Canton Dev Tooling ($7k) | Canton scaffold templates for camp | Canton developers |
| 0G Dev Tooling ($4k) | 0G agent project templates | 0G developers |

## Architecture

### 1. Hiero CLI Plugin: `hiero camp`

A Hiero CLI plugin that brings camp's workspace management to Hedera development:

```bash
# Initialize a Hedera campaign workspace
hiero camp init my-hedera-project

# Creates:
# my-hedera-project/
# ├── projects/
# │   ├── contracts/      # Hedera smart contracts
# │   ├── agent/          # AI agent code
# │   └── dashboard/      # Frontend
# ├── festivals/          # Planning via fest
# ├── workflow/           # Workflow artifacts
# └── justfile           # Build commands

# Add a Hedera agent project
hiero camp add-agent --template defi-agent

# Navigate using camp shortcuts
cgo p       # → projects/
cgo agent   # → projects/agent/

# Deploy with camp workflow
hiero camp deploy testnet
```

Plugin manifest follows Hiero CLI's Node.js plugin architecture, wrapping camp's Go binary for workspace operations.

### 2. Canton Scaffold Templates

Camp templates that scaffold complete Canton/Daml development environments:

```bash
# Create a Canton privacy app workspace
camp init --template canton-privacy-app

# Creates:
# my-canton-app/
# ├── projects/
# │   ├── daml-contracts/     # Daml smart contracts with privacy patterns
# │   ├── canton-node/        # Local Canton node config
# │   └── frontend/           # Investor/auditor portal
# ├── festivals/
# │   └── planned/
# │       └── privacy-app/    # Pre-built festival plan
# ├── justfile               # Canton-specific just recipes
# └── .canton/               # Canton configuration

# Scaffold a selective disclosure contract
camp create --template canton-selective-disclosure

# Run the local Canton environment
just canton start
just canton deploy
just canton test
```

### 3. 0G Agent Project Templates

Camp templates for scaffolding complete 0G agent projects:

```bash
# Create a 0G iNFT agent workspace
camp init --template 0g-inft-agent

# Creates structured workspace with:
# - 0G Chain smart contracts (ERC-7857)
# - 0G Storage integration code
# - 0G Compute broker setup
# - Agent runtime scaffolding
# - Dashboard frontend
# - Festival plan for the build

# Or scaffold specific components
camp create --template 0g-storage-adapter
camp create --template 0g-compute-broker
camp create --template 0g-inft-contract
```

## Bounty Targets

| Bounty | Submission | Prize |
|--------|-----------|-------|
| **Hedera Track 4: Hiero CLI Plugin** | `hiero camp` plugin | $2,500 (1 of 2 winners) |
| **Canton Dev Tooling** | Canton scaffold templates + just recipes | Up to $875 (1 of 8 prizes) |
| **0G Dev Tooling** | 0G project templates for camp | Up to $4,000 |

**Total potential: $7,375+**

## Exposure Value

- **Direct user acquisition**: Developers who use these templates become camp users
- **Ecosystem presence**: camp becomes known in Hedera, Canton, and 0G dev communities
- **Open source visibility**: Templates are open source, discoverable, forkable
- **Conference networking**: "We built dev tools for your ecosystem" opens doors with sponsors
- **Ongoing value**: Templates live beyond the hackathon, continuing to drive camp adoption

## Risk Assessment

- **Low-medium complexity**: Camp templates and CLI plugins are well-understood
- **Multiple small bets**: 3 submissions across 3 sponsors = diversified risk
- **Practical value**: These are genuinely useful, not hackathon-only demos
- **Compounding**: Each template makes camp more valuable, attracting more users
