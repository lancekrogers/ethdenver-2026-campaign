---
fest_type: task
fest_id: 01_compile_evidence_manifest.md
fest_name: compile-evidence-manifest
fest_parent: 03_evidence_manifest
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-11T05:02:44.512081-06:00
fest_tracking: true
---

# Task: Compile Evidence Manifest

## Objective

Compile all transaction hashes from 0G Galileo and Base Sepolia sequences into a single evidence manifest file, verify each on its respective block explorer, and fill in [PLACEHOLDER] values in the hall post.

## Requirements

- [ ] All 0G Galileo transactions completed (sequence 01 tasks done)
- [ ] All Base Sepolia transactions completed (sequence 02 tasks done)
- [ ] Evidence manifest written to `workflow/explore/grant-research/2026-03-11/evidence-manifest.md`
- [ ] All [PLACEHOLDER] values in `workflow/explore/grant-research/2026-03-11/0g/hall-post.md` replaced with real values
- [ ] Every explorer link verified to load correctly

## Implementation

### Step 1: Collect all transaction hashes

Gather the following from completed task outputs:

**0G Galileo (chain ID 16602) — Explorer: https://chainscan.0g.ai**
1. Faucet funding tx hash
2. AgentINFT.sol deploy tx hash + contract address
3. Storage `submit()` tx hash (Flow contract: 0x22E03a6A89B950F1c82ec5e74F8eCa321a105296)
4. DA `submitOriginalData()` tx hash (DA Entrance: 0xE75A073dA5bb7b0eC622170Fd268f35E675a957B)
5. iNFT `mint()` tx hash + token ID

**Base Sepolia (chain ID 84532) — Explorer: https://sepolia.basescan.org**
1. Faucet funding tx hash (ETH + USDC)
2. ERC-8004 identity registration tx hash
3. Uniswap V3 swap tx hash

### Step 2: Verify each transaction on block explorer

For each tx hash, open the explorer link and confirm:
- Transaction status is "Success"
- The correct contract was called
- The correct method was invoked

```bash
# Quick verification via cast for 0G txs
cast receipt <TX_HASH> --rpc-url https://evmrpc-testnet.0g.ai

# Quick verification via cast for Base Sepolia txs
cast receipt <TX_HASH> --rpc-url https://sepolia.base.org
```

### Step 3: Write the evidence manifest

Create `workflow/explore/grant-research/2026-03-11/evidence-manifest.md` with the following structure:

```markdown
# Evidence Manifest — Grant Submission GS0003

**Generated:** 2026-03-11
**Wallet Address:** <WALLET_ADDRESS>

## 0G Galileo (Chain ID 16602)

| # | Operation | Tx Hash | Explorer Link | Status |
|---|-----------|---------|---------------|--------|
| 1 | Fund wallet | <TX_HASH> | [chainscan](<LINK>) | Verified |
| 2 | Deploy AgentINFT | <TX_HASH> | [chainscan](<LINK>) | Verified |
| 3 | Storage submit() | <TX_HASH> | [chainscan](<LINK>) | Verified |
| 4 | DA submitOriginalData() | <TX_HASH> | [chainscan](<LINK>) | Verified |
| 5 | iNFT mint() | <TX_HASH> | [chainscan](<LINK>) | Verified |

**Contract Addresses:**
- AgentINFT: <ADDRESS>

## Base Sepolia (Chain ID 84532)

| # | Operation | Tx Hash | Explorer Link | Status |
|---|-----------|---------|---------------|--------|
| 1 | Fund wallet | <TX_HASH> | [basescan](<LINK>) | Verified |
| 2 | ERC-8004 identity register | <TX_HASH> | [basescan](<LINK>) | Verified |
| 3 | Uniswap V3 swap | <TX_HASH> | [basescan](<LINK>) | Verified |
```

### Step 4: Update hall-post.md placeholders

Open `workflow/explore/grant-research/2026-03-11/0g/hall-post.md` and replace all `[PLACEHOLDER]` values with the real transaction hashes, contract addresses, and explorer links collected in Step 1.

### Step 5: Final review

- Re-read the evidence manifest and hall post
- Confirm no `[PLACEHOLDER]` or `<TX_HASH>` markers remain
- Spot-check 2-3 explorer links to ensure they resolve

## Done When

- [ ] All requirements met
- [ ] Evidence manifest file exists at `workflow/explore/grant-research/2026-03-11/evidence-manifest.md` with all tx hashes, every explorer link verified, and zero [PLACEHOLDER] values remaining in hall-post.md
