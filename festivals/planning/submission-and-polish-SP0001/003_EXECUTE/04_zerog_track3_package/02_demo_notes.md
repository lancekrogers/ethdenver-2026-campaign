---
fest_type: task
fest_id: 02_demo_notes.md
fest_name: demo_notes
fest_parent: 04_zerog_track3_package
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Write Demo Notes for 0G Track 3

**Task Number:** 02 | **Sequence:** 04_zerog_track3_package | **Autonomy:** medium

## Objective

Write demo notes at `docs/demo-notes-0g-track3.md` in the agent-inference project. These notes provide the talking points for demonstrating the ERC-7857 iNFT to 0G Track 3 judges: what to show, how to verify on-chain, and the key differentiators.

## Requirements

- [ ] Demo structure defined with timed sections
- [ ] Key talking points for each section emphasizing iNFT and encrypted metadata
- [ ] On-chain verification steps included (what URL to visit, what to look for)
- [ ] Key differentiators highlighted (why this is a strong 0G Track 3 entry)
- [ ] Document saved at `projects/agent-inference/docs/demo-notes-0g-track3.md`

## Implementation

### Step 1: Define the demo structure

Structure the 0G Track 3 portion of the demo:

1. **Opening (10s)**: Introduce the iNFT concept -- an NFT whose metadata is an encrypted inference result
2. **Minting Flow (15s)**: Show or describe how the iNFT is minted after inference completes
3. **Encrypted Metadata (15s)**: Explain what is stored and how it is encrypted
4. **On-Chain Verification (15s)**: Show the iNFT on a block explorer, point out the contract, token, and metadata
5. **Key Differentiator (10s)**: Explain why ERC-7857 iNFTs matter for AI agent ownership

### Step 2: Write talking points

For each section, write 2-3 concise talking points:

- Focus on what judges care about: real on-chain data, standard compliance, novel use case
- Avoid deep technical jargon -- keep it accessible
- Reference the iNFT showcase document for judges who want more detail

### Step 3: Include verification steps

Provide step-by-step instructions judges can follow to verify independently:

1. Visit [block explorer URL] for the contract
2. Look up token ID [X]
3. See the encrypted metadata URI
4. Verify the ERC-7857 interface functions

### Step 4: Highlight differentiators

Emphasize what makes this entry stand out:

- Real AI inference results stored as iNFT metadata
- Encrypted so only the owner can access the full result
- ERC-7857 standard compliance (not a custom implementation)
- Part of a larger multi-agent economy (not a standalone NFT project)

## Done When

- [ ] Demo structure defined with timing
- [ ] Talking points written for every section
- [ ] On-chain verification steps included
- [ ] Key differentiators clearly articulated
- [ ] Document saved at `projects/agent-inference/docs/demo-notes-0g-track3.md`
