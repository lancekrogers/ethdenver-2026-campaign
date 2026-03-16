---
fest_type: task
fest_id: 02_submission_prep.md
fest_name: 02_submission_prep
fest_parent: 05_submission
fest_order: 2
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-13T19:25:35.216458-06:00
fest_updated: 2026-03-15T19:52:21.84676-06:00
fest_tracking: true
---


# Task: Submission Preparation

## Objective

Prepare all Synthesis hackathon submission artifacts: demo recording, conversation logs, and submission metadata with on-chain references.

## Dependencies

- ALL prior sequences (01-04) must be complete.
- Vault must be deployed on Base mainnet with verified trades.
- Agent must be registered via Synthesis API (ERC-8004 identity).

## Context

- Hackathon deadline: **Mar 22, 2026 (11:59pm PST)**
- Agent harness: `claude-code`
- Model: `claude-sonnet-4-6`
- All on-chain artifacts should be on Base mainnet.

## Step 1: Verify all on-chain artifacts

Check each of the following exists and is accessible:

- [ ] **Vault contract on Base mainnet** — verified on Basescan
  - URL: `https://basescan.org/address/<VAULT_ADDRESS>#code` (should show green checkmark)
- [ ] **ERC-8004 agent identity on Base** — the `registrationTxn` from Synthesis registration
  - URL: from `workflow/design/synthesis/deployment.md`
- [ ] **At least 2-3 SwapExecuted events on-chain**
  - URL: `https://basescan.org/address/<VAULT_ADDRESS>#events`
  - If fewer than 2 trades exist, run the agent longer to generate more.

Gather all TX hashes for the submission metadata.

## Step 2: Export conversation logs

Export Claude Code conversation logs that show the development process:

1. Locate conversation logs (typically in `~/.claude/` or the Claude Code export location).
2. Export or copy the relevant conversations covering:
   - Contract development
   - Agent runtime development
   - Registration and deployment
   - Trading execution

## Step 3: Record demo video

Script the demo before recording. The demo must show all 6 checkpoints in order:

### Checkpoint 1: Agent Registration (ERC-8004)
- Show the `registrationTxn` on Basescan
- Highlight the ERC-8004 identity NFT minted for the agent

### Checkpoint 2: Human Deposits USDC
- Show the deposit transaction on Basescan, or perform live:
```bash
cast send <VAULT_ADDRESS> "deposit(uint256,address)" \
    <AMOUNT> <DEPOSITOR_ADDRESS> \
    --rpc-url https://mainnet.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

### Checkpoint 3: Agent Trades Autonomously
- Run the vault-agent and show the terminal logs:
```bash
cd projects/agent-defi
VAULT_ADDRESS=<vault> AGENT_PRIVATE_KEY=<key> \
RPC_URL=https://mainnet.base.org \
ANTHROPIC_API_KEY=<key> \
just vault-agent
```
- Show the agent analyzing market conditions and deciding to trade

### Checkpoint 4: Trades Visible On-Chain with Rationale
- Open Basescan to the vault address events tab
- Show a `SwapExecuted` event
- Decode the event data to show the trade rationale

### Checkpoint 5: Boundary Enforcement (Rejected Swap)
- Demonstrate that a swap exceeding `maxSwapSize` is reverted
- Show the revert message in the agent logs or on-chain

### Checkpoint 6: Exit at NAV
- Redeem shares showing the depositor gets back their proportional share:
```bash
cast send <VAULT_ADDRESS> "redeem(uint256,address,address)" \
    <SHARES> <RECEIVER> <OWNER> \
    --rpc-url https://mainnet.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```
- Show the redemption amount matches the NAV

## Step 4: Prepare submission metadata

Compile the following into the submission:

```json
{
  "agentHarness": "claude-code",
  "model": "claude-sonnet-4-6",
  "conversationLogs": "<path or link to exported logs>",
  "onChainArtifacts": {
    "vaultAddress": "0x<MAINNET_VAULT_ADDRESS>",
    "agentIdentityNFT": "0x<REGISTRATION_TX_HASH>",
    "tradeTxHashes": [
      "0x<TRADE_1_TX>",
      "0x<TRADE_2_TX>",
      "0x<TRADE_3_TX>"
    ],
    "network": "base-mainnet",
    "explorer": "https://basescan.org"
  }
}
```

Fill in actual values from `workflow/design/synthesis/deployment.md` and Basescan.

## Step 5: Submit

Submit via the Synthesis platform before the deadline (Mar 22, 2026 11:59pm PST).

## Verification Checklist

- [ ] Vault contract verified on Basescan (green checkmark)
- [ ] ERC-8004 registration TX confirmed
- [ ] At least 2-3 SwapExecuted events on-chain
- [ ] Conversation logs exported
- [ ] Demo video recorded covering all 6 checkpoints
- [ ] Submission metadata JSON complete with all on-chain references
- [ ] Submitted before deadline

## Done When

- [ ] All verification checks pass
- [ ] Demo recording captures all 6 checkpoints
- [ ] Submission metadata complete with all on-chain references