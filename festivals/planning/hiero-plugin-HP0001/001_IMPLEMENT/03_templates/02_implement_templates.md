---
fest_type: task
fest_id: 02_implement_templates.md
fest_name: implement_templates
fest_parent: 03_templates
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Implement Templates

**Task Number:** 02 | **Sequence:** 03_templates | **Autonomy:** medium

## Objective

Create the actual template files in the `templates/` directory of the hiero-plugin project. Each template should be a complete project scaffold that works when copied to a new directory and has its variables substituted. Follow the design document from task 01 exactly.

## Requirements

- [ ] `templates/hedera-smart-contract/` directory created with all template files
- [ ] `templates/hedera-dapp/` directory created with all template files
- [ ] `templates/hedera-agent/` directory created with all template files
- [ ] Each template includes a `template.json` metadata file
- [ ] All template files use the defined variable substitution format
- [ ] Each template produces a project that installs/compiles when variables are replaced
- [ ] Each template includes a complete README with Hedera-specific setup instructions

## Implementation

### Step 1: Create the templates directory structure

```bash
cd $(fgo) && mkdir -p templates/hedera-smart-contract
cd $(fgo) && mkdir -p templates/hedera-dapp
cd $(fgo) && mkdir -p templates/hedera-agent
```

### Step 2: Create hedera-smart-contract template

Create all files as designed in `docs/template-design.md`. The key files to create:

**`templates/hedera-smart-contract/template.json`:**
```json
{
  "id": "hedera-smart-contract",
  "name": "Hedera Smart Contract",
  "description": "Solidity + Hardhat project pre-configured for Hedera network deployment",
  "language": "TypeScript/Solidity",
  "tags": ["solidity", "hardhat", "smart-contract", "hedera"]
}
```

**`templates/hedera-smart-contract/package.json`:**
Create with Hardhat dependencies, hedera-specific plugins, and scripts for compile, test, and deploy. Use `{{projectName}}` for the package name.

**`templates/hedera-smart-contract/hardhat.config.ts`:**
Configure Hedera testnet network with the JSON-RPC relay endpoint. Include the Hedera testnet chain ID (296) and RPC URL (https://testnet.hashio.io/api).

**`templates/hedera-smart-contract/contracts/HelloHedera.sol`:**
Create a simple Solidity contract that demonstrates deployment on Hedera. Keep it straightforward -- a greeting contract with get/set functions.

**`templates/hedera-smart-contract/scripts/deploy.ts`:**
Hardhat deploy script that deploys the HelloHedera contract to the configured network.

**`templates/hedera-smart-contract/test/HelloHedera.test.ts`:**
Basic test suite using Hardhat's testing utilities (ethers, chai).

**`templates/hedera-smart-contract/.env.example`:**
```
# Hedera Testnet Configuration
HEDERA_TESTNET_OPERATOR_ID=0.0.XXXXX
HEDERA_TESTNET_OPERATOR_KEY=302e...
HEDERA_TESTNET_RPC_URL=https://testnet.hashio.io/api
```

**`templates/hedera-smart-contract/README.md`:**
Complete setup guide: prerequisites, installation, configuration (account setup on Hedera portal), compilation, testing, and deployment instructions.

**`templates/hedera-smart-contract/.gitignore`:**
Standard Node.js + Hardhat gitignore (node_modules, artifacts, cache, .env, coverage).

### Step 3: Create hedera-dapp template

Create all files as designed:

**`templates/hedera-dapp/template.json`:**
```json
{
  "id": "hedera-dapp",
  "name": "Hedera dApp",
  "description": "React + HashConnect application for building Hedera dApps",
  "language": "TypeScript/React",
  "tags": ["react", "hashconnect", "dapp", "hedera", "vite"]
}
```

**`templates/hedera-dapp/package.json`:**
Create with React, Vite, HashConnect, and Hedera SDK dependencies. Use `{{projectName}}` for the package name. Include scripts for dev, build, preview, and lint.

**`templates/hedera-dapp/vite.config.ts`:**
Standard Vite configuration with React plugin. Add any polyfills needed for HashConnect (Buffer, crypto).

**`templates/hedera-dapp/src/main.tsx`:**
React entry point rendering the App component.

**`templates/hedera-dapp/src/App.tsx`:**
Main application component that renders the WalletConnect and AccountInfo components. Provides the HashConnect context.

**`templates/hedera-dapp/src/components/WalletConnect.tsx`:**
Component with a "Connect Wallet" button that initiates HashConnect pairing.

**`templates/hedera-dapp/src/components/AccountInfo.tsx`:**
Component that displays the connected Hedera account ID and balance.

**`templates/hedera-dapp/src/hooks/useHashConnect.ts`:**
Custom React hook that manages HashConnect lifecycle: initialization, pairing, disconnection, and account state.

**`templates/hedera-dapp/src/config/hedera.ts`:**
Hedera network configuration constants: network type (testnet), mirror node URL, and HashConnect app metadata.

**`templates/hedera-dapp/.env.example`:**
```
# Hedera dApp Configuration
VITE_HEDERA_NETWORK=testnet
VITE_HEDERA_MIRROR_NODE=https://testnet.mirrornode.hedera.com
```

**`templates/hedera-dapp/README.md`:**
Complete setup guide: prerequisites, installation, HashPack wallet setup, running the dev server, connecting wallet, and building for production.

### Step 4: Create hedera-agent template

Create all files as designed:

**`templates/hedera-agent/template.json`:**
```json
{
  "id": "hedera-agent",
  "name": "Hedera Agent",
  "description": "Go agent with HCS (Hedera Consensus Service) and HTS (Hedera Token Service) integration",
  "language": "Go",
  "tags": ["go", "agent", "hcs", "hts", "hedera"]
}
```

**`templates/hedera-agent/go.mod`:**
Go module definition with `{{projectName}}` in the module path. Include the Hedera Go SDK dependency at a pinned version.

**`templates/hedera-agent/cmd/agent/main.go`:**
Main entry point that loads configuration, initializes the Hedera client, starts the agent loop. Clean startup/shutdown with signal handling and context cancellation.

**`templates/hedera-agent/internal/agent/agent.go`:**
Agent struct with Start/Stop methods. Demonstrates subscribing to an HCS topic and processing messages in a loop.

**`templates/hedera-agent/internal/hcs/client.go`:**
HCS client that wraps the Hedera SDK for topic creation and message subscription.

**`templates/hedera-agent/internal/hcs/topic.go`:**
Topic operations: create topic, get topic info, subscribe to topic messages.

**`templates/hedera-agent/internal/hts/client.go`:**
HTS client that wraps the Hedera SDK for token queries.

**`templates/hedera-agent/internal/hts/token.go`:**
Token operations: get token info, get account token balance.

**`templates/hedera-agent/internal/config/config.go`:**
Configuration loader that reads from environment variables: operator ID, operator key, network type.

**`templates/hedera-agent/Makefile`:**
Standard Go Makefile with targets: build, test, run, lint, clean.

**`templates/hedera-agent/.env.example`:**
```
# Hedera Agent Configuration
HEDERA_NETWORK=testnet
HEDERA_OPERATOR_ID=0.0.XXXXX
HEDERA_OPERATOR_KEY=302e...
```

**`templates/hedera-agent/README.md`:**
Complete setup guide: prerequisites (Go 1.21+), Hedera account setup, building, running, and extending the agent.

### Step 5: Verify template file completeness

For each template, verify all files exist and contain valid content:

```bash
cd $(fgo) && find templates/ -type f | sort
```

Check that each template has:
- [ ] template.json with correct metadata
- [ ] All source files referenced in the design document
- [ ] README.md with complete setup instructions
- [ ] .env.example with Hedera configuration
- [ ] .gitignore with appropriate exclusions
- [ ] No `{{variable}}` markers left un-documented

### Step 6: Validate template contents

For the JavaScript/TypeScript templates, verify the package.json is valid JSON and dependencies are real packages:

```bash
cd $(fgo) && node -e "JSON.parse(require('fs').readFileSync('templates/hedera-smart-contract/package.json'))"
cd $(fgo) && node -e "JSON.parse(require('fs').readFileSync('templates/hedera-dapp/package.json'))"
```

For the Go template, verify the go.mod syntax is correct.

## Done When

- [ ] `templates/hedera-smart-contract/` contains all files with valid Solidity/Hardhat scaffold
- [ ] `templates/hedera-dapp/` contains all files with valid React/HashConnect scaffold
- [ ] `templates/hedera-agent/` contains all files with valid Go agent scaffold
- [ ] Each template has a `template.json` with correct metadata
- [ ] All template files use `{{variable}}` syntax for substitutable values
- [ ] Each template's README includes complete Hedera-specific setup instructions
- [ ] Template package.json/go.mod files reference real, compatible dependency versions
- [ ] No placeholder or TODO markers in template files (aside from Hedera account IDs in .env.example)
