# Synthesis Hackathon Submission Checklist

**Deadline:** Mar 22, 2026, 11:59 PM PST
**Today:** Mar 18, 2026 (4 days remaining)
**Registration:** Complete (Participant ID: `5b9dc2f5...`, Team ID: `56a0c5c0...`)

---

## Current State (as of Mar 18)

| Asset | Status | Location |
|-------|--------|----------|
| Registration | Done | API key + on-chain TX confirmed |
| Repos public | Done | agent-defi, agent-coordinator, contracts all PUBLIC |
| `.env` secrets | Safe | gitignored, never committed |
| All tests | Passing | 13 packages, 0 failures |
| Testnet vault | Done | `0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1` on Base Sepolia |
| Testnet swap evidence | Done | `agent_log.json` with 1 USDC->WETH swap |
| Uniswap API client | Built | `internal/base/trading/uniswap_api.go` |
| x402 payment module | Built | `internal/base/payment/x402.go` |
| ERC-8004 identity | Deployed | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` on Base Mainnet |
| Mainnet vault | Not deployed | Need funds + deploy |
| `agent.json` manifest | Not created | DevSpot format for Protocol Labs |
| Video demo | Not recorded | 3 min, 6 checkpoints |
| Track submissions | Not submitted | 6 tracks via Synthesis API |

---

## 1. Infrastructure (Do First)

### 1.1 Mainnet Deployment

- [ ] Source Base mainnet ETH for gas (faucet, bridge, or transfer)
- [ ] Source Base mainnet USDC for vault funding
- [ ] Deploy ObeyVault to Base mainnet using `DeployVault.s.sol` with `MAINNET=true`
  - Mainnet USDC: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`
  - Mainnet SwapRouter02: `0x2626664c2603336E57B271c5C0b26F421741e481`
  - Mainnet Factory: `0x33128a8fC17869897dcE68Ed026d694621f6FDfD`
- [ ] Approve WETH as trading token on mainnet vault
- [ ] Deposit USDC into mainnet vault
- [ ] Record deployment tx hash in `deployments/base-mainnet.json`

### 1.2 Mainnet Live Trades

- [ ] Execute 2-3 live swaps on Base mainnet via vault `executeSwap()`
- [ ] Record all swap tx hashes
- [ ] Run `loggen` against mainnet vault to generate `agent_log.json` with real mainnet data
- [ ] Verify `agent_log.json` has 2-3 entries with real TxIDs

### 1.3 Uniswap Developer Platform API Verification

- [ ] Verify API key works: `UNISWAP_API_KEY=KHIT2oP...` against `trade-api.gateway.uniswap.org/v1`
- [ ] Test `/check_approval` endpoint
- [ ] Test `/quote` endpoint with real token pair
- [ ] Document API integration flow in README or submission narrative
- [ ] Ensure `uniswap_api.go` uses the Trading API (not raw router calls) for submission evidence

---

## 2. Protocol Labs Artifacts

### 2.1 `agent.json` (DevSpot Format)

- [ ] Create `agent.json` manifest with:
  - Agent name: "OBEY Vault Agent"
  - Operator wallet address
  - ERC-8004 identity address: `0x0C97820abBdD2562645DaE92D35eD581266CCe70`
  - Supported tools list (vault, uniswap, risk engine, etc.)
  - Tech stack (Go, Base, Uniswap V3, ERC-4626)
  - Compute constraints (trading interval, daily volume, max swap size, slippage limits)
  - Task categories

### 2.2 `agent_log.json` (DevSpot Format)

- [ ] Generate from mainnet vault events (not testnet)
- [ ] Include 3+ complete autonomous loop iterations:
  - discover -> plan -> execute -> verify
- [ ] Each entry must have: timestamp, phase, action, tools_used, decision, reasoning, execution (tx_hash), verification
- [ ] Include ritual decision artifacts from festival runs (if available via `-rituals` flag)

### 2.3 Narratives

- [ ] Write "Let the Agent Cook" narrative (autonomy + multi-tool orchestration)
- [ ] Write "Agents With Receipts" narrative (identity + verifiable receipts + trust)
- [ ] Narratives must be differentiated — not the same story told twice

---

## 3. Low-Effort Guaranteed Bounties

### 3.1 Status Network (Equal-share bounty)

- [ ] Deploy ObeyVault (or minimal contract) to Status Network Sepolia
- [ ] Execute 1 gasless transaction
- [ ] Record tx hashes as evidence
- [ ] Include in submission: tx hash + AI agent reference + README

### 3.2 Markee ($800, objective split)

- [ ] Grant OAuth access to Markee on a GitHub repo
- [ ] Add Markee delimiter text to a markdown file in the repo
- [ ] Verify "Live" status on Markee integrations page

---

## 4. Repo & Documentation Cleanup

- [ ] Verify no secrets in git history (`git log -p --all -S "PRIVATE_KEY"`)
- [ ] Verify `.env` is gitignored in all submodules
- [ ] Add/update README in agent-defi with:
  - Project description
  - Architecture overview
  - Setup instructions
  - How to run the agent
- [ ] Add/update README in contracts with:
  - Contract addresses (testnet + mainnet)
  - Deployment instructions
  - Verified contract links

---

## 5. Submission Packaging

### 5.1 Video Demo (~3 min)

- [ ] Record video covering 6 checkpoints:
  1. Spending boundaries enforcement (maxSwapSize, maxDailyVolume, maxSlippageBps)
  2. On-chain identity verification (ERC-8004 registration tx)
  3. Festival Methodology framework (planning system)
  4. Trading/execution loop (autonomous discover -> execute cycle)
  5. Verification and audit trail (agent_log.json, on-chain events)
  6. Dashboard/state visualization (vault state, holdings)

### 5.2 Conversation Log

- [ ] Compile human-agent collaboration log
- [ ] Include examples of planning, debugging, decision-making

### 5.3 Moltbook Post

- [ ] Write project summary post for Moltbook community

---

## 6. Submit to Tracks (via Synthesis API)

All submissions go to `POST https://synthesis.devfolio.co` endpoints with:
```
Authorization: Bearer sk-synth-6d5c471ccfdc067a2cb919680a13c38d01767ca5d817e442
```

### 6.1 Protocol Labs "Let the Agent Cook" ($8,000)

- [ ] Submit with:
  - `agent.json` manifest
  - `agent_log.json` with 3+ loop iterations
  - Narrative: autonomy + multi-tool orchestration
  - Video demo link
  - GitHub repo links
  - On-chain artifacts (vault address, swap tx hashes)

### 6.2 Protocol Labs "Agents With Receipts" ($8,004)

- [ ] Submit with:
  - ERC-8004 identity contract + registration tx
  - `agent_log.json` with reasoning chains
  - Narrative: identity + verifiable receipts
  - Guardian/agent role separation evidence
  - SwapExecuted events with encoded `reason` field

### 6.3 Uniswap "Agentic Finance" ($5,000)

- [ ] Submit with:
  - Uniswap Developer Platform API key usage evidence
  - Mainnet swap tx hashes (real TxIDs, not mocks)
  - API integration flow documentation
  - Public GitHub repo

### 6.4 Synthesis Open Track ($14,500 shared)

- [ ] Submit with:
  - Cross-sponsor integration highlights
  - System architecture overview
  - Festival Methodology as novel collaboration framework
  - All on-chain artifacts from other tracks

### 6.5 Status Network + Markee

- [ ] Submit Status Network with:
  - Sepolia deployment tx hash
  - Gasless tx hash
  - AI agent reference
- [ ] Submit Markee with:
  - Live integration confirmation
  - Repository URL

---

## Transaction Evidence Registry

### Base Sepolia (Testnet)

| Transaction | Tx Hash | Explorer |
|------------|---------|----------|
| Deploy ObeyVault v2 | `0x194ca4e3...a99605` | [basescan](https://sepolia.basescan.org/tx/0x194ca4e3b078e3d1854911de562f4003a5f4c1bf4167b5ce7eff335a3ca99605) |
| Approve WETH | `0x8c99cd15...76e1a` | [basescan](https://sepolia.basescan.org/tx/0x8c99cd15bdf251ec74aa1e8a2fb080814b845bcf869ebad2f11f5b9d84d76e1a) |
| Redeem from v1 | `0x521385...4ffaf7` | [basescan](https://sepolia.basescan.org/tx/0x5213851bf6366dac9bafa3649d9813da3ddf2b0319983f079ee8de87ea4ffaf7) |
| Approve USDC | `0x8ad4a4...a9f7` | [basescan](https://sepolia.basescan.org/tx/0x8ad4a4ef80d0a4de3421f03f920e2babc5705b26359696bbdcca6bac800ba9f7) |
| Deposit 10 USDC | `0x26125e...4473` | [basescan](https://sepolia.basescan.org/tx/0x26125e050928c3d259f545a58f7843651fe4610afcc108e2c2d6524726214473) |
| Swap 1 USDC->WETH | `0xafc1c6...a9d7` | [basescan](https://sepolia.basescan.org/tx/0xafc1c6b2e0ad1e0f0bff17aa86f2cca6ab19ce2859929e5fa066b989d2d3a9d7) |

### Base Mainnet

| Transaction | Tx Hash | Explorer |
|------------|---------|----------|
| ERC-8004 Identity | `0xcc31bda6...0832c73` | [basescan](https://basescan.org/tx/0xcc31bda693422433cdc9e364077d29e42bb5a3ade9220d714d33ca44f0832c73) |
| Deploy ObeyVault | TBD | — |
| Live Trade 1 | TBD | — |
| Live Trade 2 | TBD | — |
| Live Trade 3 | TBD | — |

### Contract Addresses

| Contract | Network | Address |
|----------|---------|---------|
| ObeyVault v2 | Base Sepolia | `0xbAbDd92397Cd812593e79A5b4c2a32bB4aDb06b1` |
| ObeyVault v1 (deprecated) | Base Sepolia | `0xa7412780435905728260d5eaA59786e4a3C07e7E` |
| ERC-8004 Identity | Base Mainnet | `0x0C97820abBdD2562645DaE92D35eD581266CCe70` |
| ObeyVault | Base Mainnet | TBD |

---

## Priority Order (4 days)

| Priority | Task | Bounty Impact | Effort |
|----------|------|--------------|--------|
| 1 | Mainnet deploy + 2-3 live trades | Unlocks Uniswap ($5K) + Protocol Labs ($16K) + Open Track ($14.5K) | Medium |
| 2 | `agent.json` manifest | Required for Protocol Labs | Low |
| 3 | Regenerate `agent_log.json` from mainnet | Required for Protocol Labs | Low (automated) |
| 4 | Uniswap Trading API verification | Required for Uniswap bounty | Low-Medium |
| 5 | Protocol Labs narratives | Required for both PL tracks | Medium |
| 6 | Status Network deploy + gasless tx | Guaranteed bounty | Low |
| 7 | Markee integration | Guaranteed bounty ($800) | Low |
| 8 | Video demo | Required for all tracks | Medium |
| 9 | Conversation log + Moltbook post | Required for submission | Low |
| 10 | Submit all 6 tracks via API | Final step | Low |

**Total bounty potential: ~$51,304**
