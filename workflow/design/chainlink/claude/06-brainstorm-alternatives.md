# 06 - Brainstorm: Alternative Approaches & Strategic Considerations

## Core Question: What's the Strongest Submission?

The hackathon is agents-only on Moltbook. Judges are human. Two prizes ($3.5k + $1.5k). Let's think about what wins.

## Approach Comparison

### Approach A: CRE Risk Router (Recommended - documented in 01-05)

**Concept:** CRE workflow that evaluates risk for autonomous DeFi agents

**Strengths:**

- Direct `#cre-ai` alignment - AI signals driving CRE decisions
- Leverages entire existing agent economy as context
- Clear on-chain write with meaningful business logic
- Multiple risk gates make the demo compelling
- Story: "CRE as the safety layer for autonomous agents"

**Weaknesses:**

- Risk of over-engineering if we try to integrate too deeply
- CRE SDK learning curve is the primary time risk

**Verdict:** Strong default. Proceed with this.

---

### Approach B: CRE Oracle-Powered Trading Signal Aggregator

**Concept:** CRE workflow that aggregates multiple data sources (Chainlink feeds, DEX prices, AI inference) into a consensus trading signal, writes signal on-chain

**Strengths:**

- More "pure CRE" - fully built on CRE capabilities
- Multiple HTTP calls + EVM reads demonstrate CRE feature breadth
- Signal aggregation is a natural CRE use case

**Weaknesses:**

- Less differentiated - many teams will do data aggregation
- Doesn't leverage the existing agent economy as strongly
- "Yet another oracle aggregator"

**Verdict:** Weaker narrative than Risk Router. Skip.

---

### Approach C: CRE Agent Reputation Oracle

**Concept:** CRE workflow that computes and publishes agent reputation scores on-chain, using task completion data from HCS

**Strengths:**

- Novel - agent reputation as a CRE workflow is unique
- Ties into `ReputationDecay.sol` already in contracts
- Could read HCS data via HTTP (Mirror Node API) inside CRE

**Weaknesses:**

- Reputation scoring is abstract - harder to demo concretely
- Less exciting for judges than risk/trading
- May not produce a compelling simulation

**Verdict:** Interesting concept but weaker demo. Could be P1 stretch.

---

### Approach D: CRE Prediction Market for Agent Outcomes

**Concept:** CRE workflow that creates prediction markets for agent task outcomes, resolves them based on on-chain evidence

**Strengths:**

- Maps to `#prediction-markets` hashtag (different category, less competition?)
- Novel intersection of agents + prediction markets
- Could be very compelling to judges

**Weaknesses:**

- Heavier build - needs market contract, resolution logic
- Might feel forced - agents predicting their own outcomes?
- More complex simulation setup

**Verdict:** High ceiling but high risk. Save for a future hackathon.

---

## Strategic Decisions

### Single vs Dual Hashtag

The submission can include multiple use case hashtags. Options:

1. **`#cre-ai` only** (safe, focused)
   - Pure AI+CRE story
   - Competes in one category

2. **`#cre-ai #defi-tokenization`** (stretch)
   - Add tokenized strategy receipts (mint an NFT per approved trade)
   - Only if P0 is solid by Mar 6

**Decision:** Start with `#cre-ai` only. Add `#defi-tokenization` only if contract write + simulation are stable by Mar 5.

### New Repo vs Monorepo Directory

The CRE workflow needs a public repo. Options:

1. **New standalone repo** (`cre-risk-router`)
   - Clean, focused, easy for judges to evaluate
   - Clear README with setup instructions
   - No noise from other projects

2. **Directory in Obey Agent Economy repo**
   - Shows integration context
   - Judges might get lost in the larger codebase
   - README needs to point judges to the right directory

**Decision:** New standalone repo. Link to Obey Agent Economy in the description for context. The submission repo should be laser-focused on the CRE workflow.

### Go vs TypeScript

CRE supports both. Our agents are all Go.

**Decision:** Go. Obvious choice given the existing codebase.

### Which Testnet?

CRE supports EVM testnets. Need to verify which ones.

**Options to evaluate:**

- Arbitrum Sepolia - Popular, good tooling
- Base Sepolia - Already used by agent-defi
- Ethereum Sepolia - Most standard but higher gas
- Optimism Sepolia - Less common

**Decision:** Verify CRE-supported networks via CLI. Prefer Arbitrum Sepolia or Base Sepolia (familiar territory from agent-defi).

## What Judges Will Look For

Based on the rules and typical hackathon judging:

1. **Does it work?** - `cre simulate` must run from clean clone. Non-functional = DQ.
2. **Is there a real on-chain write?** - Read-only = DQ. Need tx hash.
3. **Is the use case meaningful?** - "Useful real-world problem" > toy demo
4. **Quality of CRE integration** - Are they using CRE capabilities properly?
5. **Code quality** - Clean, well-structured, documented
6. **Simulation reproducibility** - Can judges run it themselves?

## Things to Watch Out For

1. **CRE CLI availability** - Install early, test basic commands day 1
2. **Testnet faucets** - Need testnet ETH for the target network. Get funds early.
3. **CRE authentication** - May need `cre login` and account setup. Handle on day 1.
4. **Chainlink price feeds on testnet** - Verify feeds exist on chosen testnet
5. **Moltbook submission format** - Triple-check the exact title/body format
6. **Human registration form** - Must be completed separately at the Google Form link
7. **Time zones** - Deadline is 11:59 PM **ET**. Account for this.

## Open Questions to Resolve During Build

1. What exact CRE-supported testnets are available? (`cre --help` or docs)
2. What Chainlink price feed addresses exist on the chosen testnet?
3. Does `cre workflow simulate --broadcast` require authentication or a funded wallet?
4. How does the CRE HTTP trigger work in simulation mode? Is it mocked?
5. Can we use the cron trigger as a simulation-friendly alternative?
6. What is the exact `IReceiver` interface if we want proper CRE report consumption?

## Quick Wins That Improve Score

1. **Clear README** with one-command setup (not 15 steps)
2. **Verified contract** on block explorer (shows professionalism)
3. **Multiple simulation scenarios** (not just happy path)
4. **Architecture diagram** in submission (Mermaid or ASCII)
5. **Video/GIF of simulation run** (visual evidence)
6. **Genuine CRE feedback** (judges want real feedback, not generic praise)
