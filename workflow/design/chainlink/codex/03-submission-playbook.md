# 03 - Submission Playbook (Chainlink Convergence)

## Mandatory Format Rules (From Requirements Doc)

Post destination:

- `m/chainlink-official`

Title must be exactly:

`#chainlink-hackathon-convergence #[USE_CASE_HASHTAG(S)] — [PROJECT_NAME]`

First line of post body must be exactly:

`#chainlink-hackathon-convergence #[USE_CASE_HASHTAG(S)]`

Valid use-case hashtags include:

- `#defi-tokenization`
- `#cre-ai`
- `#prediction-markets`

## Recommended Positioning For This Codebase

Primary submission:

- Hashtag: `#cre-ai`
- Project name: `CRE Risk Router for Obey Agent Economy`

Optional dual-tag only if truly implemented:

- `#cre-ai #defi-tokenization`

## Post Skeleton (Ready To Fill)

**Title**

`#chainlink-hackathon-convergence #cre-ai — CRE Risk Router for Obey Agent Economy`

**Body**

Line 1 (must be exact):

`#chainlink-hackathon-convergence #cre-ai`

Then include:

1. Problem statement (why autonomous agents need runtime risk controls)
2. Architecture summary (coordinator + inference + DeFi + CRE + receipt contract)
3. Simulation proof (`cre simulate` command + outcomes)
4. On-chain write proof (tx hash + what was written)
5. Why this matters (safety, determinism, reproducibility, auditability)
6. Repo links and reproducibility steps

## Evidence Pack Checklist

## A. CRE Simulation Evidence

- exact command(s) used:
  - `cre simulate ...`
- output snippet showing pass/fail decision
- scenario matrix (at least 2 different outcomes)

## B. On-Chain Write Evidence

- tx hash
- network + contract address
- event emitted (`RunRecorded` or equivalent)
- explanation of how write maps to CRE run ID

## C. End-to-End Agent Evidence

- inference signal payload example
- CRE decision payload example
- DeFi execution accepted/rejected example
- dashboard screenshot with CRE timeline visible

## D. Reproducibility

- minimum setup commands
- env vars required (non-secret names only)
- one command path to replay the simulation + execution flow

## Judge-Facing Demo Script (90-120 seconds)

1. "We already had a live multi-agent economy; we added CRE as the runtime risk brain."
2. Show simulation run and decision outcome.
3. Show DeFi agent obeying CRE constraints.
4. Show on-chain receipt write for this run.
5. Close on why this is meaningful beyond demo: safer autonomous execution.

## Quality Bar Before Posting

1. One clean successful run from start to finish without manual patching mid-demo.
2. One denied run proving risk controls are real, not always-approve.
3. Evidence artifacts stored and linkable.
4. Title/body formatting verified against exact requirement strings.
5. Post published before **March 8, 2026, 11:59 PM ET**.

