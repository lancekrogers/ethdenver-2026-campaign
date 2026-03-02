---
fest_type: task
fest_id: 01_init_project.md
fest_name: init project
fest_parent: 01_project_scaffold
fest_order: 1
fest_status: pending
fest_autonomy: medium
fest_created: 2026-03-01T17:43:28.902809-07:00
fest_tracking: true
---

# Task: init project

## Objective

Create the CRE Risk Router project as a submodule in the Obey Agent Economy monorepo with a private GitHub repo, and scaffold the complete directory structure and config files per spec Section 3.

## Requirements

- [ ] Project created via `camp project new cre-risk-router` as a submodule at `projects/cre-risk-router/` (Req P0.1)
- [ ] Private GitHub repo created at `github.com/lancekrogers/cre-risk-router` and set as remote
- [ ] Directory structure matches spec Section 3 exactly
- [ ] `go.mod` initialized with correct module path
- [ ] `config.json` with all Config fields and defaults per spec Section 5
- [ ] `secrets.yaml` with secret declarations
- [ ] `.env.example` template with all required environment variables
- [ ] Festival linked to project repo via `fest link` (enables `fgo` navigation)

## Implementation

1. **Create the project submodule**:

   ```bash
   camp project new cre-risk-router
   ```

2. **Create private GitHub repo and set as remote**:

   ```bash
   cd projects/cre-risk-router
   gh repo create lancekrogers/cre-risk-router --private
   git remote add origin git@github.com:lancekrogers/cre-risk-router.git
   ```

3. **Link the festival to the project repo**:

   Navigate to the festival directory and link to the new project. This enables `fgo` for quick navigation between the festival and the project for all subsequent phases.

   ```bash
   cd festivals/active/cre-risk-router-planning-CR0001
   fest link ../../projects/cre-risk-router
   ```

5. **Initialize Go module**:

   ```bash
   go mod init github.com/lancekrogers/cre-risk-router
   ```

6. **Create directory structure** per spec Section 3:

   ```
   cre-risk-router/
   ├── workflow.go
   ├── risk.go
   ├── types.go
   ├── helpers.go
   ├── config.json
   ├── secrets.yaml
   ├── .env.example
   ├── go.mod
   ├── contracts/
   │   └── evm/
   │       └── src/
   │           ├── RiskDecisionReceipt.sol
   │           └── abi/
   │               └── RiskDecisionReceipt.json
   ├── test/
   │   └── RiskDecisionReceipt.t.sol
   ├── scenarios/
   │   ├── approved_trade.json
   │   ├── denied_low_confidence.json
   │   ├── denied_high_risk.json
   │   ├── denied_stale_signal.json
   │   └── denied_price_deviation.json
   ├── demo/
   │   └── e2e.sh
   ├── README.md
   ├── justfile
   └── foundry.toml
   ```

   Use `t2s` to scaffold from this tree if available.

7. **Create `config.json`** with all Config fields and defaults:

   ```json
   {
     "market_data_url": "https://api.coingecko.com/api/v3/coins/ethereum",
     "price_feed_address": "",
     "receipt_contract_address": "",
     "target_network": "",
     "signal_confidence_threshold": 0.6,
     "max_risk_score": 75,
     "default_max_position_bps": 10000,
     "decision_ttl_seconds": 300,
     "price_deviation_max_bps": 500,
     "volatility_scale_factor": 1.0,
     "oracle_staleness_seconds": 3600,
     "feed_decimals": 8,
     "enable_heartbeat_gate": false,
     "heartbeat_mirror_node_url": "",
     "heartbeat_ttl_seconds": 600
   }
   ```

8. **Create `secrets.yaml`** declaring required secrets:

   ```yaml
   secrets:
     - name: DEPLOYER_PRIVATE_KEY
       description: Private key for EVM transaction signing
     - name: COINGECKO_API_KEY
       description: CoinGecko API key (optional, for higher rate limits)
   ```

9. **Create `.env.example`**:

   ```env
   # CRE Risk Router Environment Variables
   DEPLOYER_PRIVATE_KEY=your_deployer_private_key_here
   COINGECKO_API_KEY=optional_api_key_here
   TESTNET_RPC=https://rpc-url-for-chosen-testnet
   ```

10. **Create stub files** (`workflow.go`, `risk.go`, `types.go`, `helpers.go`) with package declarations so the project compiles:

   ```go
   package main
   ```

11. **Create `foundry.toml`**:

   ```toml
   [profile.default]
   src = "contracts/evm/src"
   out = "contracts/evm/out"
   test = "test"
   libs = ["lib"]
   ```

12. **Verify the project compiles**:

    ```bash
    go build -o /dev/null .
    ```

## Done When

- [ ] All requirements met
- [ ] `go build` succeeds on the scaffolded project
- [ ] Directory structure matches spec Section 3
- [ ] `config.json` has all 15 Config fields with correct defaults
- [ ] GitHub repo exists and is set as remote (make public before final submission)
- [ ] Festival linked to project via `fest link` — `fgo` navigates between festival and project
