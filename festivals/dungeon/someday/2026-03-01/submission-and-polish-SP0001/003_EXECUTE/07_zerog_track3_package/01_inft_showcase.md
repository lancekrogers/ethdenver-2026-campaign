---
fest_type: task
fest_id: 01_inft_showcase.md
fest_name: inft_showcase
fest_parent: 07_zerog_track3_package
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:13:55.031411-07:00
fest_tracking: true
---


# Task: Create iNFT Showcase Documentation

**Task Number:** 01 | **Sequence:** 04_zerog_track3_package | **Autonomy:** medium

## Objective

Create an iNFT showcase document at `docs/inft-showcase.md` in the agent-inference project. This document shows the minted iNFT, explains the encrypted metadata implementation, describes ERC-7857 compliance, and includes screenshots of on-chain data. This is the primary evidence document for the 0G Track 3 ($7k) bounty.

## Requirements

- [ ] Minted iNFT displayed with token ID and contract address
- [ ] Encrypted metadata flow explained step-by-step
- [ ] ERC-7857 compliance documented with references to the standard
- [ ] Screenshots of on-chain data from block explorer included
- [ ] Document saved at `projects/agent-inference/docs/inft-showcase.md`

## Implementation

### Step 1: Gather on-chain data

Collect all relevant on-chain data for the minted iNFT:

- **Contract address**: The ERC-7857 contract deployed on testnet
- **Token ID**: The specific iNFT token that was minted
- **Minting transaction hash**: The transaction that created the iNFT
- **Metadata URI**: The URI pointing to the encrypted metadata
- **Owner address**: The current owner of the iNFT

Query this data from the block explorer or directly from the contract:

```bash
cd $(fgo)
# Use project tools to query on-chain data
just inft-info
# Or query directly via etherscan/basescan API
```

### Step 2: Capture screenshots

Take screenshots of:

1. **Block explorer - Contract page**: Shows the deployed ERC-7857 contract with its functions
2. **Block explorer - Token page**: Shows the minted iNFT with its metadata
3. **Block explorer - Mint transaction**: Shows the minting transaction details
4. **Metadata endpoint**: Shows the encrypted metadata structure (if accessible via URL)

Save screenshots to `docs/screenshots/` in the project.

### Step 3: Write the encrypted metadata flow

Explain the encryption process step-by-step:

1. Agent generates inference result (model output)
2. Result is encrypted with a symmetric key
3. Symmetric key is encrypted with the owner's public key
4. Encrypted result + encrypted key are stored as iNFT metadata
5. Only the owner can decrypt by using their private key to recover the symmetric key
6. The decrypted result can then be verified against the on-chain commitment

### Step 4: Document ERC-7857 compliance

Reference the ERC-7857 standard and show how the implementation complies:

- **Required interfaces implemented**: List each ERC-7857 interface and the corresponding contract function
- **Encrypted metadata storage**: How metadata is stored following the standard
- **Access control**: How decryption access is restricted to the owner
- **Standard extensions**: Any extensions beyond the base standard

### Step 5: Write the showcase document

Create `docs/inft-showcase.md`:

```markdown
# iNFT Showcase: ERC-7857 Intelligent NFT

## Overview
[Brief description of what the iNFT represents and why it matters]

## On-Chain Data

| Field | Value |
|-------|-------|
| Contract Address | [address] |
| Token ID | [id] |
| Mint Transaction | [hash] |
| Owner | [address] |
| Network | [testnet name] |

## Screenshots
[Include or reference screenshots from docs/screenshots/]

## Encrypted Metadata Flow
[Step-by-step flow from Step 3 above]

## ERC-7857 Compliance
[Compliance documentation from Step 4 above]

## How to Verify
[Instructions for judges to independently verify the iNFT on-chain]

## Key Differentiators
[What makes this implementation unique or noteworthy]
```

## Done When

- [ ] All on-chain data gathered and documented
- [ ] Screenshots captured and saved
- [ ] Encrypted metadata flow explained clearly
- [ ] ERC-7857 compliance documented with standard references
- [ ] Verification instructions provided for judges
- [ ] Document saved at `projects/agent-inference/docs/inft-showcase.md`