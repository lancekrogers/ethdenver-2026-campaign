---
fest_type: task
fest_id: 01_lifecycle_test.md
fest_name: lifecycle_test
fest_parent: 02_vault_tests
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.376584-06:00
fest_tracking: true
---

# Task: Full Lifecycle Integration Tests

## Objective

Write comprehensive integration tests covering the complete vault lifecycle: initialize, deposit, NAV update, withdrawal request, withdrawal execution, and multi-depositor scenarios using Anchor's Bankrun test framework.

## Requirements

- [ ] Test: Initialize vault and verify all PDA accounts are created correctly
- [ ] Test: First deposit mints shares 1:1
- [ ] Test: NAV update changes share pricing for subsequent deposits
- [ ] Test: Second deposit gets proportionally fewer shares after NAV increase
- [ ] Test: Withdrawal request escrows shares correctly
- [ ] Test: Withdrawal execution returns proportional USDC and burns shares
- [ ] Test: Multi-depositor scenario with correct proportional math
- [ ] Test: Full lifecycle end-to-end (init -> deposit -> trade profits via NAV update -> withdraw with profit)
- [ ] Test: Pause blocks deposits, unpause resumes them
- [ ] Test: Withdrawal works even when vault is paused

## Implementation

### Step 1: Set up test infrastructure

File: `projects/obey-platform/tests/lifecycle.ts`

Use Anchor's test framework with `anchor.workspace` and Bankrun. The test file structure:

```typescript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { ObeyMvpVault } from "../target/types/obey_mvp_vault";
import {
  createMint,
  getOrCreateAssociatedTokenAccount,
  mintTo,
  getAccount,
  TOKEN_PROGRAM_ID,
  ASSOCIATED_TOKEN_PROGRAM_ID,
} from "@solana/spl-token";
import { assert } from "chai";

describe("obey-mvp-vault lifecycle", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.ObeyMvpVault as Program<ObeyMvpVault>;

  let admin: anchor.web3.Keypair;
  let userAlice: anchor.web3.Keypair;
  let userBob: anchor.web3.Keypair;
  let agentWallet: anchor.web3.Keypair;
  let usdcMint: anchor.web3.PublicKey;

  // PDAs
  let vaultStatePda: anchor.web3.PublicKey;
  let shareMintPda: anchor.web3.PublicKey;
  let vaultUsdcAta: anchor.web3.PublicKey;

  before(async () => {
    admin = anchor.web3.Keypair.generate();
    userAlice = anchor.web3.Keypair.generate();
    userBob = anchor.web3.Keypair.generate();
    agentWallet = anchor.web3.Keypair.generate();

    // Airdrop SOL to all accounts
    for (const kp of [admin, userAlice, userBob]) {
      const sig = await provider.connection.requestAirdrop(
        kp.publicKey,
        10 * anchor.web3.LAMPORTS_PER_SOL
      );
      await provider.connection.confirmTransaction(sig);
    }

    // Create a mock USDC mint (6 decimals)
    usdcMint = await createMint(
      provider.connection,
      admin,
      admin.publicKey,
      null,
      6
    );

    // Derive PDAs
    [vaultStatePda] = anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("vault"), admin.publicKey.toBuffer()],
      program.programId
    );
    [shareMintPda] = anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("share_mint"), vaultStatePda.toBuffer()],
      program.programId
    );

    // Mint USDC to test users
    const aliceUsdcAta = await getOrCreateAssociatedTokenAccount(
      provider.connection, admin, usdcMint, userAlice.publicKey
    );
    await mintTo(provider.connection, admin, usdcMint, aliceUsdcAta.address, admin, 10_000_000_000); // 10,000 USDC

    const bobUsdcAta = await getOrCreateAssociatedTokenAccount(
      provider.connection, admin, usdcMint, userBob.publicKey
    );
    await mintTo(provider.connection, admin, usdcMint, bobUsdcAta.address, admin, 10_000_000_000); // 10,000 USDC
  });
```

### Step 2: Test initialization

```typescript
  it("initializes vault with correct state", async () => {
    await program.methods
      .initialize(agentWallet.publicKey, new anchor.BN(0)) // 0 delay for MVP
      .accounts({
        admin: admin.publicKey,
        vaultState: vaultStatePda,
        shareMint: shareMintPda,
        usdcMint: usdcMint,
        // vaultUsdcAta derived by framework
      })
      .signers([admin])
      .rpc();

    const vault = await program.account.vaultState.fetch(vaultStatePda);
    assert.equal(vault.admin.toBase58(), admin.publicKey.toBase58());
    assert.equal(vault.agentWallet.toBase58(), agentWallet.publicKey.toBase58());
    assert.equal(vault.totalShares.toNumber(), 0);
    assert.equal(vault.totalNav.toNumber(), 0);
    assert.equal(vault.paused, false);
    assert.equal(vault.withdrawalDelaySecs.toNumber(), 0);
  });
```

### Step 3: Test first deposit (1:1 bootstrap)

```typescript
  it("first deposit mints shares 1:1", async () => {
    const depositAmount = 1_000_000_000; // 1000 USDC

    await program.methods
      .deposit(new anchor.BN(depositAmount))
      .accounts({
        user: userAlice.publicKey,
        vaultState: vaultStatePda,
        // ... remaining accounts
      })
      .signers([userAlice])
      .rpc();

    const vault = await program.account.vaultState.fetch(vaultStatePda);
    assert.equal(vault.totalShares.toNumber(), depositAmount);
    assert.equal(vault.totalNav.toNumber(), depositAmount);

    // Verify Alice's share balance
    const aliceShareAta = await getOrCreateAssociatedTokenAccount(
      provider.connection, admin, shareMintPda, userAlice.publicKey
    );
    assert.equal(Number(aliceShareAta.amount), depositAmount);
  });
```

### Step 4: Test NAV update and proportional deposit

```typescript
  it("NAV update changes share pricing", async () => {
    // Agent profits — NAV goes from 1000 to 1200 USDC
    const newNav = 1_200_000_000; // 1200 USDC
    await program.methods
      .updateNav(new anchor.BN(newNav))
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();

    const vault = await program.account.vaultState.fetch(vaultStatePda);
    assert.equal(vault.totalNav.toNumber(), newNav);
    assert.equal(vault.allTimeHighNav.toNumber(), newNav);
  });

  it("second deposit gets fewer shares at higher NAV", async () => {
    const depositAmount = 600_000_000; // 600 USDC

    await program.methods
      .deposit(new anchor.BN(depositAmount))
      .accounts({
        user: userBob.publicKey,
        vaultState: vaultStatePda,
        // ... remaining accounts
      })
      .signers([userBob])
      .rpc();

    // shares = 600 * 1000 / 1200 = 500 shares (500_000_000 base units)
    const vault = await program.account.vaultState.fetch(vaultStatePda);
    assert.equal(vault.totalShares.toNumber(), 1_500_000_000); // 1000 + 500
    assert.equal(vault.totalNav.toNumber(), 1_800_000_000);    // 1200 + 600

    const bobShareAta = await getOrCreateAssociatedTokenAccount(
      provider.connection, admin, shareMintPda, userBob.publicKey
    );
    assert.equal(Number(bobShareAta.amount), 500_000_000);
  });
```

### Step 5: Test withdrawal flow

```typescript
  it("withdrawal request escrows shares", async () => {
    const sharesToWithdraw = 500_000_000; // 500 shares (half of Alice's)

    await program.methods
      .requestWithdrawal(new anchor.BN(sharesToWithdraw))
      .accounts({
        user: userAlice.publicKey,
        vaultState: vaultStatePda,
        // ... remaining accounts
      })
      .signers([userAlice])
      .rpc();

    // Alice's share balance should decrease by 500
    const aliceShareAta = await getOrCreateAssociatedTokenAccount(
      provider.connection, admin, shareMintPda, userAlice.publicKey
    );
    assert.equal(Number(aliceShareAta.amount), 500_000_000); // 1000 - 500
  });

  it("withdrawal execution returns proportional USDC", async () => {
    // With delay=0, execute immediately
    // usdc = 500 shares * 1800 NAV / 1500 total_shares = 600 USDC
    await program.methods
      .executeWithdrawal()
      .accounts({
        payer: userAlice.publicKey,
        user: userAlice.publicKey,
        vaultState: vaultStatePda,
        // ... remaining accounts
      })
      .signers([userAlice])
      .rpc();

    const vault = await program.account.vaultState.fetch(vaultStatePda);
    assert.equal(vault.totalShares.toNumber(), 1_000_000_000); // 1500 - 500
    assert.equal(vault.totalNav.toNumber(), 1_200_000_000);    // 1800 - 600
  });
```

### Step 6: Test pause/unpause

```typescript
  it("pause blocks deposits", async () => {
    await program.methods.pause()
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();

    try {
      await program.methods
        .deposit(new anchor.BN(100_000_000))
        .accounts({ user: userBob.publicKey, vaultState: vaultStatePda, /* ... */ })
        .signers([userBob])
        .rpc();
      assert.fail("Should have thrown VaultPaused error");
    } catch (err) {
      assert.include(err.message, "VaultPaused");
    }
  });

  it("withdrawal still works when paused", async () => {
    // Request should fail (paused)
    // But execute_withdrawal on existing request should succeed
    // ... test that execute_withdrawal succeeds while paused
  });

  it("unpause resumes deposits", async () => {
    await program.methods.unpause()
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();

    // Deposit should succeed again
    await program.methods
      .deposit(new anchor.BN(100_000_000))
      .accounts({ user: userBob.publicKey, vaultState: vaultStatePda, /* ... */ })
      .signers([userBob])
      .rpc();
  });
```

### Step 7: Full end-to-end profit scenario

```typescript
  it("full lifecycle: deposit -> profit -> withdraw with gains", async () => {
    // 1. Fresh user deposits 1000 USDC
    // 2. Admin updates NAV to 1500 (50% profit from trading)
    // 3. User withdraws all shares
    // 4. User receives 1500 USDC (their original 1000 + 500 profit)
    // This proves the share-based accounting works for profit distribution
  });
```

### Test Utilities

Create a helper module for repeated setup patterns:

```typescript
// tests/helpers.ts
export async function initializeVault(program, admin, usdcMint, agentWallet, delay = 0) { /* ... */ }
export async function depositUsdc(program, user, vaultPda, amount) { /* ... */ }
export async function requestWithdraw(program, user, vaultPda, shares) { /* ... */ }
export async function executeWithdraw(program, user, vaultPda, requestPda) { /* ... */ }
export async function updateNav(program, admin, vaultPda, newNav) { /* ... */ }
```

## Done When

- [ ] All requirements met
- [ ] `anchor test` passes all lifecycle tests
- [ ] Initialize test verifies all PDA creation and state initialization
- [ ] First deposit test confirms 1:1 share minting
- [ ] NAV update test confirms share pricing changes
- [ ] Multi-depositor test confirms proportional math across users
- [ ] Withdrawal test confirms proportional USDC return and share burning
- [ ] Pause/unpause test confirms deposit blocking and withdrawal passthrough
- [ ] Full lifecycle test demonstrates profit distribution through share pricing
