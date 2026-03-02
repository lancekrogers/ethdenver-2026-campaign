# Constraints

## Hard Constraints (Non-Negotiable)

### Hackathon Rules

- **Language:** Go (CRE supports Go or TypeScript; Go chosen for alignment with existing agents)
- **CRE compatibility:** Must use `cre workflow simulate` — not a wrapper, not a subprocess
- **On-chain write:** At least one write to a CRE-supported EVM testnet (not Hedera EVM)
- **Public repo:** Repository must be publicly accessible
- **No secrets:** All credentials via `.env` / `secrets.yaml`, never hardcoded
- **Submission format:** Moltbook post with exact `#chainlink-hackathon-convergence #cre-ai` title format
- **Deadline:** March 8, 2026, 11:59 PM ET — hard cutoff, no extensions
- **Registration:** Human operator must complete Google Form before submission
- **One submission per person:** One human, one agent, one submission

### Technical

- **Standalone project:** CRE workflow must be self-contained; judges evaluate it independently
- **Clean-clone simulation:** `cre workflow simulate .` must work from a fresh `git clone` with only documented setup steps
- **8-decimal price precision:** All price math uses Chainlink native 8-decimal format throughout (types, contract, events)
- **CRE-supported testnet:** On-chain write targets a CRE-supported EVM testnet (likely Arbitrum Sepolia or Base Sepolia — resolve in Phase 0)

## Soft Constraints (Strong Preferences)

### Scope

- **P0 is standalone.** No modifications to existing agent repos required for the core submission
- **Integration is evidence, not dependency.** `demo/e2e.sh` proves the integration path without requiring the coordinator to be running
- **Phase 0 is a hard gate.** No Risk Router code until basic CRE simulation is validated

### Architecture

- **Append-only decisions.** Every evaluation (approved or denied) writes on-chain. No silent failures.
- **Graceful degradation.** CoinGecko failure → fallback to oracle-only + conservative volatility. Chainlink failure → valid denied outcome. Workflow never crashes.
- **Gate 8 off by default.** Heartbeat gate is configurable to prevent external dependency from breaking clean-clone simulation.

### Process

- **Front-load risk.** Phase 0 (CRE validation) and contract deployment happen first, not mid-sprint.
- **Steps, not days.** Planning is step-based. Time estimates are irrelevant given agent execution speed.
- **No scope creep into P1/P2.** P0 must be stable before any integration work begins.

## Known Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| CRE CLI doesn't work as documented | Medium | Critical | Phase 0 validation gate on day 1 |
| Testnet faucet issues | Low | Medium | Get testnet ETH early, have fallback network |
| CoinGecko rate limiting | Medium | Low | Graceful fallback to oracle-only mode |
| CRE SDK unfamiliar | High | Medium | Start with simplest workflow, iterate |
| Scope creep into integration | Medium | Medium | P0/P1/P2 boundary is strictly enforced |
| Submission format error | Low | Critical | Triple-check Moltbook format before publish |
