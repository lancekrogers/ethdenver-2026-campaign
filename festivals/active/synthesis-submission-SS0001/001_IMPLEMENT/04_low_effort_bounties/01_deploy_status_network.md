---
fest_type: task
fest_id: 01_deploy_status_network.md
fest_name: deploy status network
fest_parent: 04_low_effort_bounties
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-16T21:39:48.851095-06:00
fest_updated: 2026-03-17T00:18:27.539463-06:00
fest_tracking: true
---


# Task: Deploy Contract to Status Network Sepolia

## Objective

Deploy a smart contract to Status Network Sepolia testnet and execute 1 gasless transaction to qualify for the Status Network bounty ($50+ guaranteed).

## Requirements

- [ ] Deploy a contract to Status Network Sepolia
- [ ] Execute at least 1 gasless transaction on Status Network
- [ ] Record the deployment and transaction hashes

## Implementation

1. Status Network Sepolia chain details:
   - **RPC URL:** `https://public.sepolia.status.im` (check https://docs.status.network for current endpoint)
   - **Chain ID:** check docs — Status is a custom L2 with gas set to 0 at protocol level
   - **Explorer:** check docs for block explorer URL
   - **No gas needed** — gas is literally 0, no faucet required, just need an account with a private key
2. Choose the simplest contract to deploy — the bounty just requires "any smart contract":
   - **Recommended:** Deploy the `AgentIdentityRegistry.sol` from `projects/contracts/src/` — it's small, relevant to the OBEY project, and already tested
   - Alternative: A minimal contract like:
     ```solidity
     contract ObeyAgent {
         string public agentName = "OBEY";
         event AgentAction(string action, uint256 timestamp);
         function recordAction(string memory action) external {
             emit AgentAction(action, block.timestamp);
         }
     }
     ```
3. Deploy using Foundry:
   ```bash
   cd projects/contracts
   forge create src/AgentIdentityRegistry.sol:AgentIdentityRegistry \
     --rpc-url https://public.sepolia.status.im \
     --private-key $PRIVATE_KEY
   ```
4. Execute 1 gasless transaction — call a function on the deployed contract:
   ```bash
   cast send <DEPLOYED_ADDRESS> "registerAgent(string,string)" "OBEY" "Verifiable Agent Autonomy" \
     --rpc-url https://public.sepolia.status.im \
     --private-key $PRIVATE_KEY
   ```
5. Record both tx hashes:
   - Deploy tx: `0x...`
   - Interaction tx: `0x...`
6. Verify on Status Network explorer
7. Write a short README section or separate `status-network-proof.md` with:
   - Contract address
   - Both tx hashes
   - Brief description of the OBEY agent component
   - This satisfies the "include README or short video demo" requirement

## Done When

- [ ] All requirements met
- [ ] Contract deployed to Status Network Sepolia
- [ ] 1 gasless transaction executed and confirmed
- [ ] Both tx hashes recorded for submission