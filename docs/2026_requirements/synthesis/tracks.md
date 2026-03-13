# Synthesis Hackathon — Tracks & Themes

Source: [github.com/sodofi/synthesis-hackathon](https://github.com/sodofi/synthesis-hackathon)

> These briefs outline four open problem spaces where Ethereum infrastructure
> keeps humans in control of their agents.

---

## Track 1: Agents That Pay

### The Problem

Agents route payments through centralized services where transactions can be blocked, reversed, or surveilled by third parties. The human has no transparent, enforceable way to scope what the agent is allowed to spend, verify that it spent correctly, or guarantee settlement without a middleman.

### Design Space

- **Scoped spending permissions** — the human defines boundaries (amount limits, approved addresses, time windows) and the agent operates freely within them on-chain
- **Onchain settlement** — transactions finalize on Ethereum, no payment processor can block or reverse what you authorized
- **Conditional payments and escrow** — the agent only pays when verifiable conditions are met, enforced by the contract, not a platform
- **Auditable transaction history** — the human can inspect exactly what the agent did with their money, on-chain, after the fact

### Relevant Partner: Uniswap

Swap and liquidity infrastructure for agents moving value onchain.

**Resources:**
- Trading API: `https://trade-api.gateway.uniswap.org/v1/`
- Endpoints: `check_approval`, `quote`, `swap`, `order`
- API capabilities: token swaps, cross-chain bridging, wrap/unwrap, batched actions (EIP-5792), smart wallets (EIP-7702), Permit2 approvals
- Rate limits: Unauthenticated = 60 req/hr, Authenticated = 5,000 req/hr (always use API key)
- [Developer Platform](https://developers.uniswap.org/dashboard/welcome)
- [Protocol Docs](https://docs.uniswap.org/)
- [API Docs](https://api-docs.uniswap.org/introduction)
- [Unichain Docs](https://docs.unichain.org/docs)

**AI Skills:**
- Skills CLI: `npx skills add Uniswap/uniswap-ai`
- Claude Code: `/plugin marketplace add uniswap/uniswap-ai`
- Individual plugins: `uniswap-hooks`, `uniswap-trading`, `uniswap-cca`, `uniswap-driver`, `uniswap-viem`
- [GitHub](https://github.com/Uniswap/uniswap-ai)

---

## Track 2: Agents That Trust

### The Problem

Trust flows through centralized registries and API key providers. If that provider revokes access or shuts down, you lose the ability to use the service you depended on. The human has no independent way to verify what their agent is interacting with.

### Design Space

- **Onchain attestations and reputation** — verify a counterparty's track record without trusting a single registry to stay honest or stay online
- **Portable agent credentials** — tied to Ethereum, no platform can delist your agent and cut off your access
- **Open discovery protocols** — any agent can find services without a gatekeeper deciding who's visible
- **Verifiable service quality** — proof of work performed and results delivered lives onchain, not inside a platform's internal logs

### Relevant Partners

Partners TBD — track is open for tools connecting to this problem space.

---

## Track 3: Agents That Cooperate

### The Problem

Agents make deals on behalf of humans. But the commitments they make are enforced by centralized platforms. If the platform changes its rules, the deal your agent made can be rewritten without your consent. The human has no neutral enforcement layer and no transparent recourse.

### Design Space

- **Smart contract commitments** — terms are enforced by the protocol, not a company; no intermediary can alter the agreement after the fact
- **Human-defined negotiation boundaries** — you set the parameters (price ranges, deliverables, time constraints), the agent executes within them onchain
- **Transparent dispute resolution** — evidence is onchain, resolution logic is inspectable, nothing hidden inside a platform's arbitration process
- **Composable coordination primitives** — escrow, staking, slashing, deadlines as building blocks any agent can plug into

### Relevant Partners

Partners TBD — track is open for tools connecting to this problem space.

---

## Track 4: Agents That Keep Secrets

### The Problem

Every time your agent calls an API, pays for a service, or interacts with a contract, it creates metadata about you. Spending patterns, contacts, preferences, behavior. The agent isn't leaking its own data — it's leaking yours. There's no default privacy layer between your agent and the services it touches.

### Design Space

- **Private payment rails** — your agent pays for things without linking your identity to every transaction
- **Zero-knowledge authorization** — your agent proves it has permission to act without revealing who you are or why
- **Encrypted agent-to-service communication** — intermediaries can't see what your agent is doing on your behalf
- **Human-controlled disclosure policies** — you decide what gets revealed and to whom, enforced at the protocol level

### Relevant Partners

- **Self Protocol** — agent can prove identity or credentials to a service without exposing personal data

---

## Build Guidance

> Start from a real problem. The best projects come from builders who've felt
> the pain firsthand. These briefs name broad spaces — you bring the specifics.

- **Build for the human, not the agent.** The agent is a tool. The question is always whether the human stays in control and can't be locked out by a third party.
- **Use what already exists.** A lot of Ethereum infrastructure is built and underused by AI builders. Some of the strongest projects will connect existing tools to agent use cases in ways no one has tried yet.
- **Solve a problem, not a checklist.** Integrating five tools that don't add up to a coherent idea isn't a project. Start with the problem you're solving, then pick the tools that actually help. Judges evaluate whether your project works and why it matters, not how many integrations you squeezed in.
- **Don't over-scope.** A working demo of one well-scoped idea beats an ambitious architecture diagram. Pick one problem and build something that works.
