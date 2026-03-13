---
fest_type: task
fest_id: 02_attack_tests.md
fest_name: attack_tests
fest_parent: 02_vault_tests
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-13T02:21:30.376904-06:00
fest_tracking: true
---

# Task: Security and Attack Vector Tests

## Objective

Write tests that validate every attack vector from doc 06 (Anti-Gaming & Security) against the MVP vault, confirming that unauthorized access, NAV manipulation attempts, double-execution, and state corruption are all properly rejected.

## Requirements

- [ ] Test: Non-admin cannot call `update_nav`
- [ ] Test: Non-admin cannot call `pause` or `unpause`
- [ ] Test: Cannot deposit zero USDC
- [ ] Test: Cannot request withdrawal of zero shares
- [ ] Test: Cannot request withdrawal of more shares than held
- [ ] Test: Cannot execute withdrawal before delay elapses (with non-zero delay)
- [ ] Test: Cannot execute the same withdrawal request twice
- [ ] Test: Cannot execute withdrawal belonging to a different user
- [ ] Test: Deposit with wrong USDC mint is rejected
- [ ] Test: NAV update to zero does not break withdrawal math (guard against division by zero)
- [ ] Test: Integer overflow scenarios with large deposit amounts
- [ ] Test: Re-initialization attempt fails (PDA already exists)

## Implementation

File: `projects/obey-platform/tests/attacks.ts`

### Test 1: Unauthorized NAV update

```typescript
describe("obey-mvp-vault attacks", () => {
  // ... setup similar to lifecycle tests ...

  it("rejects NAV update from non-admin", async () => {
    const attacker = anchor.web3.Keypair.generate();
    // airdrop SOL to attacker...

    try {
      await program.methods
        .updateNav(new anchor.BN(999_999_999_999))
        .accounts({
          admin: attacker.publicKey,
          vaultState: vaultStatePda,
        })
        .signers([attacker])
        .rpc();
      assert.fail("Should have rejected non-admin");
    } catch (err) {
      // The constraint `admin.key() == vault_state.admin` fails.
      // Could be a ConstraintRaw error or seeds mismatch since PDA is
      // derived from vault_state.admin which won't match attacker.
      assert.ok(err, "Transaction should revert");
    }
  });
```

### Test 2: Unauthorized pause/unpause

```typescript
  it("rejects pause from non-admin", async () => {
    const attacker = anchor.web3.Keypair.generate();
    try {
      await program.methods.pause()
        .accounts({ admin: attacker.publicKey, vaultState: vaultStatePda })
        .signers([attacker])
        .rpc();
      assert.fail("Should have rejected non-admin pause");
    } catch (err) {
      assert.ok(err);
    }
  });

  it("rejects unpause from non-admin", async () => {
    // First pause legitimately
    await program.methods.pause()
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();

    const attacker = anchor.web3.Keypair.generate();
    try {
      await program.methods.unpause()
        .accounts({ admin: attacker.publicKey, vaultState: vaultStatePda })
        .signers([attacker])
        .rpc();
      assert.fail("Should have rejected non-admin unpause");
    } catch (err) {
      assert.ok(err);
    }

    // Clean up
    await program.methods.unpause()
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();
  });
```

### Test 3: Zero-amount guards

```typescript
  it("rejects zero-amount deposit", async () => {
    try {
      await program.methods
        .deposit(new anchor.BN(0))
        .accounts({ user: userAlice.publicKey, vaultState: vaultStatePda, /* ... */ })
        .signers([userAlice])
        .rpc();
      assert.fail("Should have rejected zero deposit");
    } catch (err) {
      assert.include(err.message, "ZeroDeposit");
    }
  });

  it("rejects zero-share withdrawal request", async () => {
    try {
      await program.methods
        .requestWithdrawal(new anchor.BN(0))
        .accounts({ user: userAlice.publicKey, vaultState: vaultStatePda, /* ... */ })
        .signers([userAlice])
        .rpc();
      assert.fail("Should have rejected zero shares");
    } catch (err) {
      assert.include(err.message, "ZeroShares");
    }
  });
```

### Test 4: Withdrawal delay enforcement

```typescript
  it("rejects early withdrawal execution with non-zero delay", async () => {
    // Initialize a separate vault with 60-second delay
    const delayAdmin = anchor.web3.Keypair.generate();
    // ... airdrop, init with withdrawal_delay_secs = 60 ...

    // Deposit then request withdrawal
    // ... deposit 1000 USDC, request withdrawal of 500 shares ...

    // Try to execute immediately — should fail
    try {
      await program.methods.executeWithdrawal()
        .accounts({
          payer: delayAdmin.publicKey,
          user: depositor.publicKey,
          vaultState: delayVaultPda,
          withdrawalRequest: requestPda,
          // ...
        })
        .signers([delayAdmin])
        .rpc();
      assert.fail("Should have rejected early execution");
    } catch (err) {
      assert.include(err.message, "WithdrawalDelayActive");
    }

    // Advance clock by 61 seconds (using bankrun warp or similar)
    // Then execute — should succeed
  });
```

### Test 5: Double execution

```typescript
  it("rejects double execution of same withdrawal request", async () => {
    // First execution succeeds (setup from prior test)
    // Second execution should fail
    try {
      await program.methods.executeWithdrawal()
        .accounts({
          payer: userAlice.publicKey,
          user: userAlice.publicKey,
          vaultState: vaultStatePda,
          withdrawalRequest: requestPda,
          // ...
        })
        .signers([userAlice])
        .rpc();
      assert.fail("Should have rejected double execution");
    } catch (err) {
      assert.include(err.message, "AlreadyExecuted");
    }
  });
```

### Test 6: Wrong user withdrawal

```typescript
  it("rejects execution for wrong user", async () => {
    // Alice has a pending withdrawal request
    // Bob tries to claim it by passing himself as user
    try {
      await program.methods.executeWithdrawal()
        .accounts({
          payer: userBob.publicKey,
          user: userBob.publicKey,       // Wrong! Request belongs to Alice
          vaultState: vaultStatePda,
          withdrawalRequest: aliceRequestPda,
          // ...
        })
        .signers([userBob])
        .rpc();
      assert.fail("Should have rejected wrong user");
    } catch (err) {
      assert.include(err.message, "WrongUser");
    }
  });
```

### Test 7: Re-initialization attempt

```typescript
  it("rejects re-initialization of existing vault", async () => {
    try {
      await program.methods
        .initialize(agentWallet.publicKey, new anchor.BN(0))
        .accounts({
          admin: admin.publicKey,
          vaultState: vaultStatePda,
          shareMint: shareMintPda,
          usdcMint: usdcMint,
        })
        .signers([admin])
        .rpc();
      assert.fail("Should have rejected re-initialization");
    } catch (err) {
      // Anchor rejects init on existing account
      assert.ok(err);
    }
  });
```

### Test 8: Large number overflow

```typescript
  it("handles large deposit amounts without overflow", async () => {
    // Deposit u64::MAX / 2 worth of USDC (theoretical max)
    // This tests that u128 intermediate math works correctly
    // In practice, mint this much mock USDC and attempt deposit
    // The u128 multiplication in share calculation must not overflow
    const largeAmount = new anchor.BN("4611686018427387903"); // ~2^62
    // This should either succeed (math works) or fail with
    // insufficient balance, NOT with an overflow panic
  });
```

### Test 9: NAV set to zero with existing shares

```typescript
  it("deposit fails when NAV is zero but shares exist", async () => {
    // Scenario: admin accidentally sets NAV to 0
    await program.methods
      .updateNav(new anchor.BN(0))
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();

    // Attempting deposit should fail with NavIsZero, not divide-by-zero
    try {
      await program.methods
        .deposit(new anchor.BN(100_000_000))
        .accounts({ user: userBob.publicKey, vaultState: vaultStatePda, /* ... */ })
        .signers([userBob])
        .rpc();
      assert.fail("Should have rejected deposit at zero NAV");
    } catch (err) {
      assert.include(err.message, "NavIsZero");
    }

    // Restore NAV for subsequent tests
    await program.methods
      .updateNav(new anchor.BN(1_000_000_000))
      .accounts({ admin: admin.publicKey, vaultState: vaultStatePda })
      .signers([admin])
      .rpc();
  });
```

## Done When

- [ ] All requirements met
- [ ] `anchor test` passes all attack tests
- [ ] Every unauthorized access attempt is properly rejected
- [ ] Every invalid input (zero amounts, wrong mints) is properly rejected
- [ ] Withdrawal timing enforcement works with non-zero delays
- [ ] Double-execution prevention works
- [ ] No integer overflow panics — all failures are clean error returns
- [ ] Re-initialization blocked by Anchor's PDA uniqueness
