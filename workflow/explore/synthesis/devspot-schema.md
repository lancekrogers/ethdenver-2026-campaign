# DevSpot Schema Reference

Source: Protocol Labs bounty descriptions in `docs/2026_requirements/synthesis/prize-catalog.md` and `bounties-agents-optimized.txt`. No formal schema repo exists — these fields are extracted from the bounty requirements.

---

## agent.json — Agent Capability Manifest

From bounty: *"machine-readable agent.json with agent name, operator wallet, ERC-8004 identity, supported tools, tech stacks, compute constraints, and task categories"*

```json
{
  "name": "OBEY Vault Agent",
  "description": "Autonomous trading agent with human-controlled spending boundaries and verifiable decision orchestration",
  "operator_wallet": "0xC71d8A19422C649fe9bdCbF3ffA536326c82b58b",
  "erc8004_identity": "0x0C97820abBdD2562645DaE92D35eD581266CCe70",
  "erc8004_registration_tx": "0x9b31bd785dd7b12649d9d12379546c268aea1da6e0060777bed6276cf8e4002a",
  "supported_tools": [
    "uniswap_v3_trading_api",
    "uniswap_v3_pool_query",
    "uniswap_v3_twap_oracle",
    "cre_risk_router_8gate",
    "obey_vault_execute_swap",
    "obey_vault_state_query",
    "erc8004_identity_registry",
    "hedera_hcs_messaging"
  ],
  "tech_stack": {
    "language": "Go",
    "runtime": "go1.22+",
    "frameworks": ["go-ethereum", "hiero-sdk-go"],
    "chains": ["Base (8453)", "Base Sepolia (84532)", "Hedera Testnet"],
    "contracts": ["ObeyVault (ERC-4626)", "AgentIdentityRegistry (ERC-8004)"],
    "agent_harness": "obey by obedience corp",
    "model": "claude-opus-4-6"
  },
  "compute_constraints": {
    "max_trading_interval_seconds": 300,
    "max_daily_volume_usd": 10000,
    "max_swap_size_usd": 1000,
    "max_slippage_bps": 100,
    "risk_gate_count": 8,
    "ritual_execution_target_seconds": 15
  },
  "task_categories": [
    "market_research",
    "risk_evaluation",
    "trade_execution",
    "portfolio_monitoring",
    "reputation_building"
  ]
}
```

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Agent name |
| `operator_wallet` | address | Ethereum address of the human operator |
| `erc8004_identity` | address | On-chain identity contract address |
| `supported_tools` | string[] | Tools and APIs the agent can invoke |
| `tech_stack` | object | Frameworks, languages, chains used |
| `compute_constraints` | object | Resource limits and budgets |
| `task_categories` | string[] | What the agent can do |

### Optional/Bonus Fields

| Field | Type | Description |
|-------|------|-------------|
| `erc8004_registration_tx` | string | Transaction hash of identity registration |
| `description` | string | What the agent does |
| `tech_stack.agent_harness` | string | Agent orchestration framework |
| `tech_stack.model` | string | AI model used |

---

## agent_log.json — Structured Execution Log

From bounty: *"agent_log.json showing decisions, tool calls, retries, failures, and final outputs to verify autonomous operation"*

```json
{
  "agent_name": "OBEY Vault Agent",
  "agent_identity": "0x0C97820abBdD2562645DaE92D35eD581266CCe70",
  "log_version": "1.0",
  "entries": [
    {
      "timestamp": "2026-03-17T03:15:00Z",
      "phase": "discover",
      "action": "market_research_ritual",
      "festival_id": "RI-AM0001",
      "tools_used": [
        "uniswap_v3_pool_query",
        "uniswap_v3_twap_oracle",
        "cre_risk_router_8gate",
        "obey_vault_state_query"
      ],
      "decision": "GO",
      "reasoning": {
        "signal": "BUY",
        "deviation_pct": -2.10,
        "sma_30": 3240.50,
        "current_price": 3172.34,
        "confidence": 0.72,
        "gates_passed": "7/8",
        "failed_gates": ["signal_confidence: 0.525 < 0.6"],
        "net_profit_estimate_usd": 12.50
      },
      "execution": {
        "tx_hash": "0x...",
        "chain": "Base",
        "chain_id": 8453,
        "token_in": "USDC",
        "token_out": "WETH",
        "amount_in": "20000000",
        "amount_out": "6200000000000000",
        "gas_used": 150000,
        "gas_cost_usd": "0.01"
      },
      "verification": {
        "expected_output": "6300000000000000",
        "actual_output": "6200000000000000",
        "slippage_bps": 15,
        "within_tolerance": true
      },
      "retries": 0,
      "errors": [],
      "duration_ms": 2340
    }
  ]
}
```

### Required Entry Fields

| Field | Type | Description |
|-------|------|-------------|
| `timestamp` | ISO 8601 | When the action occurred |
| `phase` | string | Which phase of the autonomous loop (discover/plan/execute/verify) |
| `action` | string | What the agent did |
| `tools_used` | string[] | Which tools/APIs were called |
| `decision` | string | GO or NO_GO |
| `reasoning` | object | Why the decision was made (specific numbers) |
| `execution` | object | Transaction details (if trade executed) |
| `verification` | object | Outcome vs expectation comparison |
| `retries` | int | Number of retry attempts |
| `errors` | string[] | Any errors encountered |
| `duration_ms` | int | How long the action took |

### Top-Level Fields

| Field | Type | Description |
|-------|------|-------------|
| `agent_name` | string | Agent identifier |
| `agent_identity` | address | ERC-8004 identity address |
| `log_version` | string | Schema version |
| `entries` | array | Ordered list of log entries |

---

## Notes

- No formal DevSpot schema repo exists as of 2026-03-17
- Schema is inferred from bounty requirements text
- Protocol Labs judges will evaluate: decisions, tool calls, retries, failures, final outputs
- NO_GO decisions with strong rationale are valuable — they show judgment
- Multiple entries showing the full loop (discover → plan → execute → verify) are expected
