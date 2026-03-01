---
fest_type: task
fest_id: 05_test_0g_inft.md
fest_name: test_0g_inft
fest_parent: 02_unblock_0g
fest_order: 5
fest_status: pending
fest_autonomy: low
fest_created: 2026-02-21T09:45:00-07:00
fest_tracking: true
---

# Task: Test ERC-7857 iNFT Contract

**Task Number:** 05 | **Sequence:** 02_unblock_0g | **Autonomy:** low

## Objective

Determine whether an ERC-7857 iNFT contract is already deployed on 0G Chain (Galileo testnet). If it exists, test minting an agent iNFT with encrypted metadata. If it does not exist, deploy it using the project's existing tooling and then test the mint. Document the status either way.

## Requirements

- [ ] iNFT contract existence on Galileo testnet is confirmed or refuted with evidence
- [ ] If deployed: contract address documented and mint test attempted
- [ ] If not deployed: contract deployed and mint test attempted
- [ ] Test mint includes encrypted agent metadata
- [ ] Outcome documented in `results/inft_test_results.md`

## Context

- ERC-7857 is the "Intelligent NFT" standard for representing AI agents as on-chain entities with encrypted, verifiable metadata
- 0G Chain is the execution layer of the 0G network (same Galileo testnet, chain ID 16602)
- The iNFT gives the inference agent an on-chain identity that can be verified by the coordinator

## Implementation

### Step 1: Check if iNFT contract already exists

Search the project for any deployed contract address:

```bash
grep -r "iNFT\|ERC7857\|erc7857\|IntelligentNFT\|INFT_CONTRACT\|ZG_INFT" \
  /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference/ 2>/dev/null
```

Also check the contracts directory in the campaign:

```bash
ls /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/contracts/ 2>/dev/null
```

### Step 2: If a contract address is found — verify it on-chain

```bash
cast code --rpc-url https://evmrpc-testnet.0g.ai <CONTRACT_ADDRESS>
```

If this returns bytecode (not `0x`), the contract is deployed. Record the address.

### Step 3: If no contract exists — deploy

Check for an existing Solidity or deployment script:

```bash
find /Users/lancerogers/Dev/ethdenver-2026-campaign/projects \
  -name "*.sol" | xargs grep -l "ERC7857\|iNFT\|IntelligentNFT" 2>/dev/null
```

If a deployment script exists, run it:

```bash
# Using foundry
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/contracts
forge script script/DeployINFT.s.sol \
  --rpc-url https://evmrpc-testnet.0g.ai \
  --broadcast \
  --verify
```

If no deployment script exists, note this in the results document and use a minimal ERC-7857-compatible contract. The minimal requirement is:
- `mint(address to, bytes calldata encryptedMetadata)` function
- ERC-721-compatible ownership and transfer

Record the deployed contract address in `.env`:

```
ZG_INFT_CONTRACT=<deployed address>
```

### Step 4: Test minting an agent iNFT

Use the existing iNFT package in the agent, or the Go integration test:

```bash
cd /Users/lancerogers/Dev/ethdenver-2026-campaign/projects/agent-inference
go test ./internal/zerog/inft/... -v -run Integration -count=1
```

The test should mint a token with encrypted agent metadata such as:

```json
{
  "agent_id": "inference-agent-001",
  "model": "llama-3-8b",
  "capabilities": ["text-generation", "summarization"],
  "public_key": "<agent public key>",
  "encrypted_config": "<encrypted JSON>"
}
```

### Step 5: Verify the minted token

After minting, verify ownership:

```bash
cast call --rpc-url https://evmrpc-testnet.0g.ai \
  <INFT_CONTRACT_ADDRESS> \
  "ownerOf(uint256)(address)" 1
```

The returned address should match the agent's wallet address.

### Step 6: Document results

Create `results/inft_test_results.md`:

```markdown
# ERC-7857 iNFT Test Results

**Date:** 2026-02-21
**Chain:** Galileo testnet (chain ID 16602)

## Contract Status

- Was pre-deployed: [Yes / No]
- Contract address: [address or "Deployed in this task"]
- Deployment tx hash: [hash or "N/A - pre-existing"]

## Mint Test

- Token ID minted: [N]
- Mint transaction hash: [txhash]
- Owner verified: [Yes / No]
- Encrypted metadata included: [Yes / No]

## Issues Encountered

[Any errors, deployment problems, or metadata encryption issues]

## Conclusion

[Pass / Fail / Partial — and what remains blocked]
```

## Done When

- [ ] iNFT contract status confirmed: deployed address recorded or deployment completed
- [ ] Test mint transaction executed and transaction hash recorded
- [ ] Ownership of minted token verified on-chain
- [ ] `results/inft_test_results.md` written with all details
- [ ] `ZG_INFT_CONTRACT` added to `.env` with the contract address
