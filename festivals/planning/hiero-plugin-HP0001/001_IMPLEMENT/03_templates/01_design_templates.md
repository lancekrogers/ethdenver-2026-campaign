---
fest_type: task
fest_id: 01_design_templates.md
fest_name: design_templates
fest_parent: 03_templates
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Design Templates

**Task Number:** 01 | **Sequence:** 03_templates | **Autonomy:** medium

## Objective

Design the three Hedera scaffold templates that will bundle with the plugin. Define the complete file structure, configuration files, source code files, and documentation for each template. This design document will be the blueprint used in the next task to create the actual template files.

## Requirements

- [ ] Design the `hedera-smart-contract` template (Solidity + Hardhat for Hedera)
- [ ] Design the `hedera-dapp` template (React + HashConnect for Hedera dApps)
- [ ] Design the `hedera-agent` template (Go agent with HCS and HTS integration)
- [ ] Define the variable substitution format for dynamic values (project name, etc.)
- [ ] Document each template's directory structure, key files, and dependencies
- [ ] Save the design document to `docs/template-design.md` in the project

## Implementation

### Step 1: Define the variable substitution format

Choose a template variable format that the init command will replace when generating projects. Common approaches:

- Handlebars-style: `{{projectName}}`, `{{description}}`
- Dollar-style: `$PROJECT_NAME`, `$DESCRIPTION`

Define the standard variables available in all templates:

| Variable | Description | Example |
|----------|-------------|---------|
| `{{projectName}}` | The project name from init command | `my-hedera-app` |
| `{{projectNamePascal}}` | PascalCase version of project name | `MyHederaApp` |
| `{{description}}` | Project description | `A Hedera smart contract project` |
| `{{author}}` | Author name | `Developer` |
| `{{year}}` | Current year | `2026` |

### Step 2: Design the hedera-smart-contract template

This template provides a Solidity + Hardhat project pre-configured for Hedera network deployment.

**Target file structure:**

```
{{projectName}}/
  package.json
  hardhat.config.ts
  tsconfig.json
  .env.example
  .gitignore
  README.md
  contracts/
    HelloHedera.sol
  scripts/
    deploy.ts
  test/
    HelloHedera.test.ts
```

**Key design decisions to document:**

- Hardhat version and plugins (hardhat-toolbox, hedera-specific plugins if any)
- Hedera testnet RPC endpoint configuration
- Sample Solidity contract that demonstrates Hedera-specific features
- Deploy script targeting Hedera testnet
- Test setup with Hardhat network

### Step 3: Design the hedera-dapp template

This template provides a React application with HashConnect for Hedera wallet integration.

**Target file structure:**

```
{{projectName}}/
  package.json
  tsconfig.json
  vite.config.ts
  index.html
  .env.example
  .gitignore
  README.md
  src/
    main.tsx
    App.tsx
    App.css
    components/
      WalletConnect.tsx
      AccountInfo.tsx
    hooks/
      useHashConnect.ts
    config/
      hedera.ts
  public/
    vite.svg
```

**Key design decisions to document:**

- React version and build tool (Vite recommended for speed)
- HashConnect version and initialization pattern
- Hedera testnet configuration for the dApp
- Sample components showing wallet connection and account info
- Environment variable setup for Hedera network

### Step 4: Design the hedera-agent template

This template provides a Go agent that integrates with Hedera Consensus Service (HCS) for messaging and Hedera Token Service (HTS) for token operations.

**Target file structure:**

```
{{projectName}}/
  go.mod
  go.sum
  Makefile
  .env.example
  .gitignore
  README.md
  cmd/
    agent/
      main.go
  internal/
    agent/
      agent.go
    hcs/
      client.go
      topic.go
    hts/
      client.go
      token.go
    config/
      config.go
```

**Key design decisions to document:**

- Go version and module path format
- Hedera Go SDK version
- Agent structure (main loop, HCS subscription, HTS operations)
- Configuration loading from environment variables
- Sample HCS topic creation and message publishing
- Sample HTS token query

### Step 5: Document template metadata

Each template needs metadata for the init command to display:

```typescript
interface TemplateMetadata {
  id: string;           // e.g., "hedera-smart-contract"
  name: string;         // e.g., "Hedera Smart Contract"
  description: string;  // e.g., "Solidity + Hardhat project for Hedera"
  language: string;     // e.g., "TypeScript/Solidity"
  tags: string[];       // e.g., ["solidity", "hardhat", "smart-contract"]
}
```

### Step 6: Write the design document

Create `docs/template-design.md` in the project with the complete design:

```bash
cd $(fgo) && mkdir -p docs
```

The design document should contain:

1. **Overview**: Purpose and philosophy of the templates
2. **Variable Substitution**: Format and available variables
3. **Template: hedera-smart-contract**: Full file tree, key file descriptions, dependencies
4. **Template: hedera-dapp**: Full file tree, key file descriptions, dependencies
5. **Template: hedera-agent**: Full file tree, key file descriptions, dependencies
6. **Template Metadata**: Schema for template registration
7. **Integration Plan**: How templates connect to the init command

### Step 7: Review the design

Before proceeding to implementation, verify:

- Each template has a clear purpose and target audience
- File structures are complete and realistic
- Dependencies are pinned to stable versions
- Hedera-specific configuration is correct (testnet endpoints, SDK versions)
- Variable substitution covers all dynamic values
- READMEs provide enough guidance for a developer new to Hedera

## Done When

- [ ] All three template designs are fully specified with file structures
- [ ] Variable substitution format is defined with all standard variables
- [ ] Template metadata schema is defined
- [ ] Each template's dependencies and versions are documented
- [ ] Hedera testnet configuration is correct in all templates
- [ ] Design document saved to `docs/template-design.md`
- [ ] Design is detailed enough for a developer to implement all templates
