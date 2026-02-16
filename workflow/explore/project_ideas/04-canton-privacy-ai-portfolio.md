# Privacy-Preserving AI Portfolio Manager on Canton

## Target Bounties

| Bounty | Prize | Fit |
|--------|-------|-----|
| **Canton Network - Privacy-Focused App** | $5,000 (1st place) | PRIMARY |
| **zkDepth Track** | Track prize | Security/privacy/zk-tech |
| **New France Village Track** | Track prize | DeFi/institutional |

**Total potential: $5k sponsor bounty + track prizes**

## Concept

An AI-powered portfolio management system built on Canton Network that uses selective disclosure to protect trading strategies while proving performance to investors. An institutional-grade solution where an AI agent manages a DeFi portfolio but reveals only what each party needs to know - investors see verified returns without seeing the strategy, auditors see compliance data without seeing positions, and regulators see risk metrics without seeing individual trades.

This leverages Canton's unique privacy model in a way no other chain can replicate.

## Architecture

### Core Components

1. **Private Strategy Engine**
   - AI agent analyzes markets and generates trading signals
   - All strategy logic, model weights, and decision history stored privately on Canton
   - Only the agent and its owner can see the full strategy
   - Uses Canton's sub-transaction privacy - each party sees only their authorized view

2. **Selective Disclosure Layers**
   ```
   Full View (Agent Owner)
   ├── All trades, positions, strategy details, model parameters
   │
   Investor View (LP Depositors)
   ├── Verified returns, risk metrics, drawdown history
   ├── CANNOT see: individual trades, strategy logic, position sizes
   │
   Auditor View (Compliance)
   ├── Transaction patterns, concentration limits, regulatory flags
   ├── CANNOT see: specific alpha signals, model weights
   │
   Public View (Anyone)
   ├── Total AUM, high-level performance tier, fund status
   └── CANNOT see: any specifics
   ```

3. **Verified Performance Proofs**
   - Canton's ledger model provides cryptographic proof of returns
   - Investors can verify the AI agent's claimed performance without seeing trades
   - Historical track record is tamper-proof and auditable at the appropriate disclosure level

4. **Multi-Party Workflow**
   - Deposit flow: Investor deposits -> Canton workflow validates -> funds allocated privately
   - Trade flow: AI decides -> trade executes privately -> performance updated for all views
   - Withdrawal flow: Investor requests -> Canton ensures fair NAV -> funds returned
   - Each step respects the disclosure matrix automatically

5. **Regulatory Compliance Module**
   - Automated reporting with appropriate disclosure levels
   - Concentration limit monitoring
   - KYC/AML integration points (Canton's institutional design)

### Canton Privacy Model in Action

```
Canton Participant: Portfolio AI Agent
  ├── Sees: Everything
  │
Canton Participant: Investor A
  ├── Sees: Their deposit, their returns, fund-level metrics
  ├── Proven by: Canton's transaction validation
  │
Canton Participant: Auditor
  ├── Sees: Compliance-relevant data, risk metrics
  ├── Proven by: Canton's cryptographic proofs
  │
Canton Participant: Public Observer
  └── Sees: Fund exists, tier-level performance only
```

## Technical Stack

- **Chain**: Canton Network (Global Synchronizer)
- **Smart Contracts**: Daml (Canton's native language for privacy-preserving workflows)
- **AI**: Python-based strategy engine connecting to Canton via API
- **Privacy**: Canton's native selective disclosure (not ZK proofs bolted on - native to the protocol)
- **Frontend**: Investor portal showing role-appropriate views
- **Data**: Canton's built-in privacy-preserving data layer

## Why This Wins

1. **Unique to Canton**: This CANNOT be built on any other chain - Canton's sub-transaction privacy is unique
2. **Institutional appeal**: Judges from Canton Network care about institutional/regulated finance use cases
3. **Real problem**: Fund managers need privacy for alpha; investors need transparency for trust
4. **AI angle**: Portfolio management by AI agent aligns with the hackathon's AI theme
5. **Selective disclosure showcase**: Demonstrates Canton's core differentiator in a compelling way
6. **Polyglot Canton**: If EVM compatibility is available, could bridge to DeFi protocols on other chains

## Demo Scenario

1. Show the AI agent analyzing market data and making trade decisions (owner view)
2. Switch to investor view: verified returns chart, no trade details visible
3. Switch to auditor view: compliance dashboard, different data subset
4. Show a deposit flowing through the system with each party seeing their appropriate view
5. Highlight: "All views are cryptographically proven by Canton - no trust required"

## Risk Assessment

- **Medium risk**: Daml is less familiar than Solidity, but Canton docs are solid
- **Medium complexity**: Multi-party privacy workflows are inherently complex
- **High reward**: $5k first place + likely fewer competitors (Canton is niche)
- **Differentiator**: Very few teams will build on Canton - less competition
