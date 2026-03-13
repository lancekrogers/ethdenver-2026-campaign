---
fest_type: task
fest_id: 03_devnet_deploy.md
fest_name: devnet_deploy
fest_parent: 02_vault_tests
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.377129-06:00
fest_tracking: true
---

# Task: Deploy MVP Vault to Solana Devnet

## Objective

Deploy the `obey-mvp-vault` program to Solana devnet, initialize a test vault, and run a full deposit/withdraw cycle against it to validate the program works in a real Solana environment (not just local validator).

## Requirements

- [ ] Program deployed to Solana devnet with a stable program ID
- [ ] Anchor.toml `[programs.devnet]` updated with the deployed program ID
- [ ] Test vault initialized on devnet with a test agent wallet
- [ ] Full deposit/withdraw cycle executed successfully on devnet
- [ ] Program ID, vault PDA, and share mint PDA documented for client integration
- [ ] Justfile recipe `just deploy-devnet` created for repeatable deployment

## Implementation

### Step 1: Configure Solana CLI for devnet

```bash
solana config set --url devnet
solana config set --keypair ~/.config/solana/id.json
```

Ensure you have devnet SOL:

```bash
solana airdrop 5
solana balance
```

### Step 2: Build the program for devnet deployment

```bash
cd projects/obey-platform
anchor build
```

After build, verify the program keypair exists:

```bash
ls -la target/deploy/obey_mvp_vault-keypair.json
```

Get the program ID:

```bash
solana-keygen pubkey target/deploy/obey_mvp_vault-keypair.json
```

### Step 3: Update program ID in all locations

1. `programs/obey-mvp-vault/src/lib.rs` — update `declare_id!("...")`
2. `Anchor.toml` — update `[programs.devnet]` section
3. Rebuild after updating the program ID:

```bash
anchor build
```

### Step 4: Deploy to devnet

```bash
anchor deploy --provider.cluster devnet
```

If the program is too large for a single transaction (unlikely for ~200 LOC but possible with Anchor framework overhead):

```bash
solana program deploy target/deploy/obey_mvp_vault.so --program-id target/deploy/obey_mvp_vault-keypair.json
```

Verify deployment:

```bash
solana program show $(solana-keygen pubkey target/deploy/obey_mvp_vault-keypair.json)
```

### Step 5: Create a devnet USDC token for testing

Devnet does not have real USDC. Create a test SPL token:

```bash
# Create a new mint with 6 decimals (matching USDC)
spl-token create-token --decimals 6
# Note the mint address — this is your devnet "USDC"

# Create a token account for the admin
spl-token create-account <MINT_ADDRESS>

# Mint some test USDC
spl-token mint <MINT_ADDRESS> 100000
```

### Step 6: Initialize the vault on devnet

Write a deployment script at `projects/obey-platform/scripts/init-devnet.ts`:

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { ObeyMvpVault } from "../target/types/obey_mvp_vault";
import { PublicKey } from "@solana/web3.js";

async function main() {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.ObeyMvpVault as Program<ObeyMvpVault>;

  const admin = provider.wallet;
  const agentWallet = new PublicKey("YOUR_AGENT_WALLET_PUBKEY");
  const usdcMint = new PublicKey("YOUR_DEVNET_USDC_MINT");

  // Derive PDAs
  const [vaultStatePda] = PublicKey.findProgramAddressSync(
    [Buffer.from("vault"), admin.publicKey.toBuffer()],
    program.programId
  );
  const [shareMintPda] = PublicKey.findProgramAddressSync(
    [Buffer.from("share_mint"), vaultStatePda.toBuffer()],
    program.programId
  );

  console.log("Program ID:", program.programId.toBase58());
  console.log("Vault PDA:", vaultStatePda.toBase58());
  console.log("Share Mint PDA:", shareMintPda.toBase58());

  // Initialize
  const tx = await program.methods
    .initialize(agentWallet, new anchor.BN(0)) // 0 delay for MVP
    .accounts({
      admin: admin.publicKey,
      vaultState: vaultStatePda,
      shareMint: shareMintPda,
      usdcMint: usdcMint,
    })
    .rpc();

  console.log("Initialize tx:", tx);

  // Verify
  const vault = await program.account.vaultState.fetch(vaultStatePda);
  console.log("Vault state:", {
    admin: vault.admin.toBase58(),
    agentWallet: vault.agentWallet.toBase58(),
    totalShares: vault.totalShares.toString(),
    totalNav: vault.totalNav.toString(),
    paused: vault.paused,
  });
}

main().catch(console.error);
```

Run it:

```bash
npx ts-node scripts/init-devnet.ts
```

### Step 7: Run a test deposit/withdraw cycle

Write `projects/obey-platform/scripts/test-devnet-cycle.ts`:

```typescript
async function testCycle() {
  // 1. Deposit 100 test USDC
  const depositTx = await program.methods
    .deposit(new anchor.BN(100_000_000)) // 100 USDC
    .accounts({ /* ... */ })
    .rpc();
  console.log("Deposit tx:", depositTx);

  // 2. Check vault state
  let vault = await program.account.vaultState.fetch(vaultStatePda);
  console.log("After deposit — shares:", vault.totalShares.toString(), "NAV:", vault.totalNav.toString());

  // 3. Update NAV to simulate profit
  const navTx = await program.methods
    .updateNav(new anchor.BN(120_000_000)) // 120 USDC (20% profit)
    .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
    .rpc();
  console.log("NAV update tx:", navTx);

  // 4. Request withdrawal of all shares
  const withdrawReqTx = await program.methods
    .requestWithdrawal(new anchor.BN(100_000_000)) // all shares
    .accounts({ /* ... */ })
    .rpc();
  console.log("Withdrawal request tx:", withdrawReqTx);

  // 5. Execute withdrawal (delay=0 so immediate)
  const withdrawExecTx = await program.methods
    .executeWithdrawal()
    .accounts({ /* ... */ })
    .rpc();
  console.log("Withdrawal execution tx:", withdrawExecTx);

  // 6. Verify final state
  vault = await program.account.vaultState.fetch(vaultStatePda);
  console.log("After withdrawal — shares:", vault.totalShares.toString(), "NAV:", vault.totalNav.toString());
  // Should be 0 shares, 0 NAV. User received 120 USDC (original 100 + 20 profit).
}
```

### Step 8: Add justfile recipe

Add to `projects/obey-platform/justfile`:

```just
deploy-devnet:
    anchor deploy --provider.cluster devnet

init-devnet:
    npx ts-node scripts/init-devnet.ts

test-devnet:
    npx ts-node scripts/test-devnet-cycle.ts
```

### Step 9: Document deployed addresses

Create `projects/obey-platform/deployments/devnet.json`:

```json
{
  "cluster": "devnet",
  "programId": "YOUR_PROGRAM_ID",
  "vaultPda": "YOUR_VAULT_PDA",
  "shareMint": "YOUR_SHARE_MINT_PDA",
  "usdcMint": "YOUR_DEVNET_USDC_MINT",
  "deployedAt": "2026-03-XX",
  "notes": "MVP vault — admin-managed NAV, 0 withdrawal delay"
}
```

This file is used by the Go agent client (Sequence 03) to find the correct accounts on devnet.

## Done When

- [ ] All requirements met
- [ ] Program is live on devnet and responds to RPC calls
- [ ] `solana program show <PROGRAM_ID>` returns deployment info
- [ ] Vault initialized on devnet with correct state
- [ ] Full deposit -> NAV update -> withdrawal cycle completes on devnet
- [ ] Program ID documented in `Anchor.toml`, `lib.rs`, and `deployments/devnet.json`
- [ ] `just deploy-devnet` recipe works for redeployment
- [ ] All devnet transaction signatures logged for verification
