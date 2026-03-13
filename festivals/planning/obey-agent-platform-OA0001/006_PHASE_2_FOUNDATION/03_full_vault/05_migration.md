---
fest_type: task
fest_id: 05_migration.md
fest_name: migration
fest_parent: 03_full_vault
fest_order: 5
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.609611-06:00
fest_tracking: true
---

# Task: Devnet Deployment & Migration Plan

## Objective

Deploy all four Anchor programs (obey_registry, obey_nav, obey_fees, obey_vault) to Solana devnet, initialize platform state, run the full test suite against devnet, and create the mainnet migration plan with deployment scripts and upgrade authority configuration.

## Requirements

- [ ] Devnet deployment of all 4 programs with correct program IDs
- [ ] Platform initialization script: initialize PlatformConfig, approve USDC mint, set treasury
- [ ] Test agent creation on devnet: create agent, deposit, trade, burn lifecycle
- [ ] Upgrade authority configuration: set to multisig for mainnet (2-of-3 minimum)
- [ ] Mainnet migration checklist with step-by-step deployment order
- [ ] Deployment scripts in justfile for repeatable deployments
- [ ] Program size optimization: verify all programs fit within Solana's 10MB limit
- [ ] Rent calculations: document total SOL required for initial deployment

## Implementation

### Step 1: Configure Anchor for devnet deployment

Update `Anchor.toml`:

```toml
[features]
seeds = false
skip-lint = false

[programs.devnet]
obey_registry = "REGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_nav = "NAVxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_fees = "FEExxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_vault = "VLTxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

[programs.mainnet]
obey_registry = "REGxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_nav = "NAVxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_fees = "FEExxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
obey_vault = "VLTxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

[registry]
url = "https://api.apr.dev"

[provider]
cluster = "devnet"
wallet = "~/.config/solana/devnet.json"

[scripts]
test = "yarn run ts-mocha -p ./tsconfig.json -t 1000000 tests/**/*.ts"
```

### Step 2: Create deployment scripts

Add to `justfiles/deploy.just`:

```just
# Deploy all programs to devnet
deploy-devnet:
    @echo "Building programs..."
    anchor build
    @echo "Deploying to devnet..."
    anchor deploy --provider.cluster devnet
    @echo "Programs deployed to devnet"

# Deploy individual program
deploy-registry-devnet:
    anchor build -p obey_registry
    anchor deploy -p obey_registry --provider.cluster devnet

deploy-nav-devnet:
    anchor build -p obey_nav
    anchor deploy -p obey_nav --provider.cluster devnet

deploy-fees-devnet:
    anchor build -p obey_fees
    anchor deploy -p obey_fees --provider.cluster devnet

deploy-vault-devnet:
    anchor build -p obey_vault
    anchor deploy -p obey_vault --provider.cluster devnet

# Initialize platform on devnet
init-platform-devnet:
    npx ts-node scripts/initialize-platform.ts --cluster devnet

# Run integration tests against devnet
test-devnet:
    anchor test --provider.cluster devnet --skip-build

# Check program sizes
check-sizes:
    @echo "Program sizes:"
    @ls -la target/deploy/*.so | awk '{print $9, $5}'
    @echo "Max allowed: 10,485,760 bytes (10 MB)"

# Calculate rent costs
calc-rent:
    @echo "Rent calculations:"
    solana rent 2000 --url devnet  # PlatformConfig
    solana rent 900 --url devnet   # AgentState
    solana rent 130 --url devnet   # VaultState
    solana rent 90 --url devnet    # BurnRequest
    solana rent 86 --url devnet    # ReferralState
    solana rent 57 --url devnet    # FeeAccumulator
```

### Step 3: Platform initialization script

Create `scripts/initialize-platform.ts`:

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { PublicKey, SystemProgram } from "@solana/web3.js";

async function main() {
    const provider = anchor.AnchorProvider.env();
    anchor.setProvider(provider);

    const registry = anchor.workspace.ObeyRegistry;

    // Derive PlatformConfig PDA
    const [platformConfig, bump] = PublicKey.findProgramAddressSync(
        [Buffer.from("platform_config")],
        registry.programId
    );

    // USDC mint on devnet
    const USDC_DEVNET = new PublicKey("4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU");

    // Initialize platform
    const tx = await registry.methods
        .initializePlatform(100) // 1% fee rate (100 bps)
        .accounts({
            admin: provider.wallet.publicKey,
            platformConfig,
            treasury: provider.wallet.publicKey, // use admin as treasury for devnet
            systemProgram: SystemProgram.programId,
        })
        .rpc();

    console.log("Platform initialized:", tx);
    console.log("PlatformConfig PDA:", platformConfig.toBase58());

    // Approve USDC
    const approveTx = await registry.methods
        .approveToken(USDC_DEVNET)
        .accounts({
            admin: provider.wallet.publicKey,
            platformConfig,
        })
        .rpc();

    console.log("USDC approved:", approveTx);

    // Create a test agent
    const agentSigner = anchor.web3.Keypair.generate();
    const [agentState] = PublicKey.findProgramAddressSync(
        [Buffer.from("agent"), new anchor.BN(0).toArrayLike(Buffer, "le", 8)],
        registry.programId
    );

    const createAgentTx = await registry.methods
        .createAgent(
            { predictionMarket: {} }, // agent_type
            1500,                      // 15% owner_pct
            [USDC_DEVNET],            // accepted_assets
            [USDC_DEVNET],            // trading_tokens
            "https://arweave.net/test-metadata", // metadata_uri
            2000,                      // max_drawdown_bps (20%)
            4000,                      // max_concentration_bps (40%)
            new anchor.BN(0),         // withdrawal_delay_secs (instant)
        )
        .accounts({
            creator: provider.wallet.publicKey,
            agentSigner: agentSigner.publicKey,
            agentState,
            platformConfig,
            systemProgram: SystemProgram.programId,
        })
        .rpc();

    console.log("Test agent created:", createAgentTx);
    console.log("Agent state PDA:", agentState.toBase58());
}

main().catch(console.error);
```

### Step 4: Mainnet migration checklist

Create `scripts/MAINNET_MIGRATION.md` (internal reference only):

```
MAINNET DEPLOYMENT CHECKLIST
============================

Pre-deployment:
[ ] All devnet tests passing
[ ] Security audit complete (or scheduled)
[ ] Program sizes verified < 10MB each
[ ] Upgrade authority configured as 2-of-3 multisig
[ ] Treasury wallet funded with SOL for rent
[ ] USDC mint address confirmed: EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v

Deployment order (dependencies matter):
1. [ ] Deploy obey_nav (no dependencies)
2. [ ] Deploy obey_fees (no dependencies)
3. [ ] Deploy obey_registry (no dependencies)
4. [ ] Deploy obey_vault (depends on registry, nav, fees program IDs)

Post-deployment:
5. [ ] Initialize PlatformConfig (admin, fee_rate=80 bps, treasury)
6. [ ] Approve USDC token
7. [ ] Approve initial routers (Jupiter, etc.)
8. [ ] Set upgrade authority to multisig
9. [ ] Verify all PDAs derivable
10. [ ] Create first test agent with team funds
11. [ ] Execute test deposit -> trade -> burn lifecycle

Monitoring:
12. [ ] Set up Helius webhooks for program events
13. [ ] Configure alerting for: emergency_pause, drawdown triggers, large withdrawals
```

### Step 5: Upgrade authority setup

```bash
# Generate multisig (using Squads Protocol or similar)
# For devnet, use single deployer key
# For mainnet, configure 2-of-3 multisig

# After deployment, transfer upgrade authority:
solana program set-upgrade-authority <PROGRAM_ID> \
    --new-upgrade-authority <MULTISIG_ADDRESS> \
    --url mainnet-beta
```

### Step 6: Write integration tests

1. `test_devnet_full_lifecycle` — deploy, init, create agent, deposit, trade, burn on devnet
2. `test_program_sizes` — verify all .so files are under 10MB
3. `test_pda_derivation` — verify all PDA addresses match expected seeds
4. `test_cross_program_cpi` — verify vault can CPI to fees, nav programs
5. `test_rent_calculations` — verify documented rent costs match actual

## Done When

- [ ] All requirements met
- [ ] All 4 programs deployed to Solana devnet
- [ ] PlatformConfig initialized with correct admin, fee rate, and USDC approved
- [ ] Test agent created and full deposit->trade->burn lifecycle executed on devnet
- [ ] Deployment scripts in justfile for repeatable deploys
- [ ] Mainnet migration checklist created with step-by-step deployment order
- [ ] Program sizes verified under 10MB limit
- [ ] Upgrade authority strategy documented (multisig for mainnet)
