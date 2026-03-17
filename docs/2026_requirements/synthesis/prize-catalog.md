# Synthesis Hackathon — Complete Prize Catalog
Source: https://synthesis.devfolio.co/catalog
Total tracks: 36
Total prize pool: $107,212.96

================================================================================

## Synthesis Open Track
**Sponsor:** Synthesis Community
**Total Pool:** $19,558.96

A community-funded open track. Judges contribute to the prize pool.

### Prizes
- **Synthesis Open Track Prize**: $19,558.96 (USD)
  Community-funded prize pool for the open track.

--------------------------------------------------------------------------------

## Private Agents, Trusted Actions
**Sponsor:** Venice
**Total Pool:** $11,500

Ethereum provides public coordination; Venice provides private cognition. Build agents that reason over sensitive data without exposure, producing trustworthy outputs for public systems: onchain workflows, multi-agent coordination, governance, and operational decisions.

This track focuses on the layer between private intelligence and public consequence: confidential treasury management, private governance analysis, deal negotiation agents, onchain risk desks, and sensitive due diligence. Agents that keep secrets. Agents that trust.

Venice provides no-data-retention inference, an OpenAI-compatible API, and multimodal reasoning across text, vision, and audio. Your job is to wire private cognition to trustworthy public action.

Example project directions: private treasury copilots, confidential governance analysts, private deal negotiation agents, onchain risk desks, confidential due diligence agents, private multi-agent coordination systems.

Prizes are denominated in VVV, Venice's native ecosystem token. VVV is an ownership asset in the Venice intelligence economy — hold it, stake it, and use it to mint DIEM. DIEM is tokenized API access: each DIEM equals $1/day of Venice compute, perpetually — renewable, tradeable as an ERC20 on Base. The strategic value of winning VVV is ongoing access to Venice's intelligence infrastructure, not a one-time cash equivalent. This is a stake in the private AI economy.

### Prizes
- **1st Place — 1,000 VVV**: $5,750 (USD)
  1,000 VVV. The USD field ($5,750) is a platform accounting reference only. VVV is Venice's native token — stake it to mint DIEM, tokenized API access at $1/day of Venice compute, tradeable on Base.
- **2nd Place — 600 VVV**: $3,450 (USD)
  600 VVV. The USD field ($3,450) is a platform accounting reference only. VVV is Venice's native token — stake it to mint DIEM, tokenized API access at $1/day of Venice compute, tradeable on Base.
- **3rd Place — 400 VVV**: $2,300 (USD)
  400 VVV. The USD field ($2,300) is a platform accounting reference only. VVV is Venice's native token — stake it to mint DIEM, tokenized API access at $1/day of Venice compute, tradeable on Base.

--------------------------------------------------------------------------------

## Agents With Receipts — ERC-8004
**Sponsor:** Protocol Labs
**Total Pool:** $8,004

Build agents that can be trusted. As autonomous agents begin interacting with each other, we need systems that allow agents to verify identity, reputation, and capabilities. This challenge focuses on building systems that leverage ERC-8004, a decentralized trust framework for autonomous agents.

**Required Capabilities:**
1. ERC-8004 Integration — interact with identity, reputation, and/or validation registries via real onchain transactions (using multiple registries scores higher)
2. Autonomous Agent Architecture — structured autonomous systems demonstrating planning, execution, verification, and decision loops; multi-agent coordination encouraged
3. Agent Identity + Operator Model — agents must register an ERC-8004 identity linked to an operator wallet to build reputation history and transact with other agents
4. Onchain Verifiability — verifiable transactions demonstrating ERC-8004 usage (agent identity registration, reputation updates, validation credentials), viewable on a blockchain explorer
5. DevSpot Agent Compatibility — must implement the DevSpot Agent Manifest and provide agent.json and agent_log.json

Sponsored by PL_Genesis.

### Prizes
- **1st Place**: $4,000 (USD)
  Awarded to the top project that best demonstrates trusted agent systems using ERC-8004, with the strongest onchain verifiability, autonomous agent architecture, and DevSpot compatibility.
- **2nd Place**: $3,000 (USD)
  Awarded to the second-best project demonstrating trusted agent systems using ERC-8004, with strong onchain verifiability and autonomous architecture.
- **3rd Place**: $1,004 (USD)
  Awarded to the third-place project demonstrating meaningful ERC-8004 integration and autonomous agent capabilities.

--------------------------------------------------------------------------------

## 🤖 Let the Agent Cook — No Humans Required
**Sponsor:** Protocol Labs
**Total Pool:** $8,000

Build fully autonomous agents that can operate end-to-end without human assistance. Agents should be capable of discovering a problem, planning a solution, executing tasks using real tools, and producing a meaningful output. We're looking for agents that behave more like independent operators than scripts.

**Required Capabilities:**
1. Autonomous Execution — full decision loop: discover → plan → execute → verify → submit; demonstrate task decomposition, autonomous decision-making, and self-correction
2. Agent Identity — register a unique ERC-8004 identity linked to an agent operator wallet; include ERC-8004 registration transaction
3. Agent Capability Manifest — machine-readable agent.json with agent name, operator wallet, ERC-8004 identity, supported tools, tech stacks, compute constraints, and task categories
4. Structured Execution Logs — agent_log.json showing decisions, tool calls, retries, failures, and final outputs to verify autonomous operation
5. Tool Use — interact with real tools or APIs (code generation, GitHub, blockchain transactions, data APIs, deployment platforms); multi-tool orchestration scores higher than single-tool usage
6. Safety and Guardrails — safeguards before irreversible actions: validating transaction parameters, confirming API outputs, detecting unsafe operations, aborting or retrying safely
7. Compute Budget Awareness — operate within a defined compute budget; demonstrate efficient resource usage and avoid excessive calls or runaway loops

**Bonus Features:** ERC-8004 trust signal integration, multi-agent swarms with specialized roles (planner, developer, QA, deployment).

Sponsored by Ethereum Foundation. $8,000 total prize pool.

### Prizes
- **1st Place**: $4,000 (USD)
  Awarded to the most autonomous, fully end-to-end agent demonstrating the complete decision loop (discover → plan → execute → verify → submit), multi-tool orchestration, robust safety guardrails, ERC-8004 identity, and meaningful real-world impact.
- **2nd Place**: $2,500 (USD)
  Awarded to the second-best autonomous agent demonstrating strong end-to-end execution, effective tool use, safety guardrails, and ERC-8004 identity integration.
- **3rd Place**: $1,500 (USD)
  Awarded to the third-place autonomous agent demonstrating meaningful autonomous execution, tool use, and compute-aware operation.

--------------------------------------------------------------------------------

## Lido MCP
**Sponsor:** Lido Labs Foundation
**Total Pool:** $5,000

Build the reference MCP server for Lido — a structured toolset that makes stETH staking, position management, and governance natively callable by any AI agent. Must integrate with stETH or wstETH on-chain. Must cover at minimum: stake, unstake, wrap/unwrap, balance and rewards queries, and at least one governance action. All write operations must support dry_run. Testnet or mainnet only, no mocks. Strong entries pair the server with a lido.skill.md that gives agents the Lido mental model before they act — rebasing mechanics, wstETH vs stETH tradeoffs, safe staking patterns. The bar is a developer pointing Claude or Cursor at the MCP server and staking ETH from a conversation with no custom integration code. Not looking for REST API wrappers with an MCP label on top. Target use cases: a developer stakes ETH via Claude without writing any integration code; an agent autonomously monitors and manages a staking position within human-set bounds; a DAO contributor queries and votes on governance proposals through natural language.

Resources:
- Lido docs: https://docs.lido.fi
- Contract addresses (mainnet + Holesky): https://docs.lido.fi/deployed-contracts
- Lido JS SDK: https://github.com/lidofinance/lido-ethereum-sdk
- stETH rebasing explainer: https://docs.lido.fi/guides/steth-integration-guide
- Withdrawal queue mechanics: https://docs.lido.fi/contracts/withdrawal-queue-erc721
- Lido governance (Aragon): https://docs.lido.fi/contracts/lido-dao

### Prizes
- **1st Place**: $3,000 (USD)
  Best reference MCP server for Lido with full stETH/wstETH integration, governance actions, dry_run support, and a developer-ready skill file.
- **2nd Place**: $2,000 (USD)
  Runner-up MCP server for Lido with strong on-chain integration and agent-callable tooling.

--------------------------------------------------------------------------------

## Best Agent on Celo
**Sponsor:** Celo
**Total Pool:** $5,000

Build agentic applications on Celo — an Ethereum L2 designed for fast, low-cost real-world payments. We're looking for AI agents that leverage Celo's stablecoin-native infrastructure, mobile accessibility, and global payments ecosystem to create genuine utility. Agents should demonstrate economic agency, on-chain interaction, and real-world applicability. All agent frameworks are welcome.

### Prizes
- **1st Place**: $3,000 (USD)
  Best agentic application built on Celo, demonstrating real-world utility, economic agency, and strong on-chain integration.
- **2nd Place**: $2,000 (USD)
  Runner-up agentic application built on Celo, showing strong potential and creative use of Celo's infrastructure.

--------------------------------------------------------------------------------

## Best Bankr LLM Gateway Use
**Sponsor:** Bankr
**Total Pool:** $5,000

Build autonomous systems powered by the Bankr LLM Gateway. Use a single API to access 20+ models (Claude, Gemini, GPT) and connect them to real onchain execution through Bankr wallets and tools. Applications can fund their own inference using wallet balances, trading activity, or launch revenue — enabling fully autonomous systems.

Ideas: Trading & Markets, Commerce & Payments, Marketplaces & Coordination, Token Launch & Ecosystems, Lending & Borrowing, Research & Data, Design & Engineering Copilots.

Judging: real execution and real onchain outcomes. Bonus points for systems with self-sustaining economics — for example routing token launch fees, trading revenue, or protocol fees to fund their own inference.

Resources:
• Bankr LLM Gateway: https://docs.bankr.bot/llm-gateway/overview
• Token Launching: https://docs.bankr.bot/token-launching/overview
• Bankr Skill: https://docs.bankr.bot/openclaw/installation

### Prizes
- **1st Place**: $3,000 (USD)
  Best autonomous system built on the Bankr LLM Gateway — real onchain execution, genuine multi-model usage, and self-sustaining economics (e.g. routing token launch fees, trading revenue, or protocol fees to fund inference).
- **2nd Place**: $1,500 (USD)
  Strong autonomous system using the Bankr LLM Gateway — real onchain outcomes and meaningful integration of Bankr wallets and tools, with a clear path to self-sustaining operation.
- **3rd Place**: $500 (USD)
  Solid use of the Bankr LLM Gateway with working onchain outcomes — creative application in areas like trading, token launch, payments, or research with demonstrated real-world utility.

--------------------------------------------------------------------------------

## Best Use of Delegations
**Sponsor:** MetaMask
**Total Pool:** $5,000

Awarded to projects that use the MetaMask Delegation Framework in creative, novel, and meaningful ways. Build apps, agent tooling, coordination systems, or anything that meaningfully leverages delegations — via gator-cli, the Smart Accounts Kit, or direct contract integration. The strongest submissions use intent-based delegations as a core pattern, extend ERC-7715 with sub-delegations or novel permission models, or combine ZK proofs with delegation-based authorization. Standard patterns without meaningful innovation will not place.

### Prizes
- **1st Place**: $3,000 (USD)
  Best overall submission to the Best Use of Delegations track — awarded to the project that most creatively, technically, and meaningfully uses the MetaMask Delegation Framework. Dream-tier submissions: intent-based delegations as a core pattern, novel ERC-7715 extensions, or ZK proofs combined with delegation-based authorization.
- **2nd Place**: $1,500 (USD)
  Second-best submission to the Best Use of Delegations track — awarded to strong submissions with creative caveat usage, agent coordination via sub-delegation chains, or well-implemented standard delegation patterns with a clear real-world use case.
- **3rd Place**: $500 (USD)
  Third-place submission to the Best Use of Delegations track — awarded to technically correct submissions that demonstrate solid delegation usage with a clear use case, even if they don't reach the innovation threshold of top tiers.

--------------------------------------------------------------------------------

## Agentic Finance (Best Uniswap API Integration)
**Sponsor:** Uniswap
**Total Pool:** $5,000

Build the future of agentic finance with Uniswap. Integrate the Uniswap API to give your agent the ability to swap, bridge, and settle value onchain with transparency, composability, and real execution. Agents that trade, coordinate with other agents, or invent primitives we haven't imagined yet — if it's powered by Uniswap and it ships, we want to see it.

Requirements: Every submission must integrate the Uniswap API with a real API key from the Developer Platform. Functional swaps with real TxIDs on testnet or mainnet. Open source, public GitHub with README. No mocks, no workarounds. Bonus: the deeper your agent goes into the Uniswap stack — Hooks, AI Skills, Unichain, v4 contracts, Permit2 — the more we notice.

Any agent that pays needs to swap. We're that layer. Show us what comes next.

Resources:

• Uniswap API: https://developers.uniswap.org/
• Uniswap AI Skills: https://github.com/Uniswap/uniswap-ai
• Uniswap API Docs: https://api-docs.uniswap.org/
• Uniswap Docs: https://docs.uniswap.org/

### Prizes
- **1st Place**: $2,500 (USD)
  Best agentic finance integration powered by the Uniswap API. Must use a real Developer Platform API key, ship real TxIDs on testnet or mainnet, and demonstrate meaningful depth in the Uniswap stack. Any agent that pays needs to swap — show us what comes next.
- **2nd Place**: $1,500 (USD)
  Second-best agentic finance integration — functional, open source, and demonstrating solid use of the Uniswap API with real execution and clear documentation.
- **3rd Place**: $1,000 (USD)
  Third-place agentic finance integration — solid Uniswap API usage with real execution, open source code, and a clear README.

--------------------------------------------------------------------------------

## Ship Something Real with OpenServ
**Sponsor:** OpenServ
**Total Pool:** $4,500

Build a useful AI-powered product or service on OpenServ. We're looking for projects that use OpenServ to power multi-agent use cases. Your submission should show how agents can coordinate, perform useful work, serve humans, and earn as real services in the emerging agent economy.

OpenServ gives you the building blocks to create:
- Multi-agent workflows
- Custom agents
- x402-native services
- ERC-8004-powered agent identity
- Token launch mechanics

You do not need to use every OpenServ primitive. But OpenServ should be clearly and meaningfully used as the infrastructure powering the core agentic behavior of your product.

We want to see: agentic economy products, x402-native services, and agentic DeFi (trading copilots, strategy assistants, yield/vault helpers, liquidity management tools, DeFi monitoring, portfolio automation). Bonus: register your workflow or agent on ERC-8004.

### Prizes
- **1st Place**: $2,500 (USD)
  Best overall project using OpenServ to power meaningful multi-agent behavior, agentic economy products, x402-native services, or agentic DeFi.
- **3rd Place**: $1,000 (USD)
  Third best project using OpenServ infrastructure to power core agentic behavior.
- **2nd Place**: $1,000 (USD)
  Second best project using OpenServ infrastructure to power core agentic behavior.

--------------------------------------------------------------------------------

## stETH Agent Treasury
**Sponsor:** Lido Labs Foundation
**Total Pool:** $3,000

Build a contract primitive that lets a human give an AI agent a yield-bearing operating budget backed by stETH, without ever giving the agent access to the principal. ETH staked via Lido, only yield flows to the agent's spendable balance, spending permissions enforced at the contract level. Must demonstrate at minimum: principal structurally inaccessible to the agent, a spendable yield balance the agent can query and draw from, and at least one configurable permission (recipient whitelist, per-transaction cap, or time window). Testnet or mainnet only, no mocks. Strong entries show a working demo where an agent pays for something from its yield balance without touching principal. Not looking for multisigs with a staking deposit bolted on. Target use cases: an agent pays for API calls and compute from its yield balance without ever touching principal; a team gives their autonomous agent a monthly dollar budget funded entirely by staking rewards; a multi-agent system where a parent agent allocates yield budgets to sub-agents.

Resources:
- stETH integration guide (rebasing drift is the key section): https://docs.lido.fi/guides/steth-integration-guide
- wstETH contract: https://docs.lido.fi/contracts/wst-eth
- Contract addresses: https://docs.lido.fi/deployed-contracts
- Lido JS SDK: https://github.com/lidofinance/lido-ethereum-sdk

### Prizes
- **1st Place**: $2,000 (USD)
  Best contract primitive enabling AI agents to spend stETH yield without accessing principal, with enforced permission controls and a working demo.
- **2nd Place**: $1,000 (USD)
  Runner-up stETH agent treasury primitive with solid on-chain design and yield-only spending enforcement.

--------------------------------------------------------------------------------

## Best Use of Locus
**Sponsor:** Locus
**Total Pool:** $3,000

Award for projects that most meaningfully integrate Locus payment infrastructure for AI agents. Projects must use Locus wallets, spending controls, pay-per-use APIs, or vertical tools as core to the product — not bolted on. Automatic disqualification for projects without a working Locus integration. On Base chain, USDC only. The more deeply Locus is woven into the agent's autonomous payment flows, the better.

### Prizes
- **1st Place**: $2,000 (USD)
  Best overall Locus integration — agent-native payments that are core to the product, deeply woven into autonomous flows with spending controls and auditability.
- **2nd Place**: $500 (USD)
  Runner-up Locus integration — strong use of Locus APIs with meaningful agent autonomy, showing clear understanding of the agent-native payment model.
- **3rd Place**: $500 (USD)
  Third-place Locus integration — demonstrates working Locus integration with promising approach to agent-native payments.

--------------------------------------------------------------------------------

## SuperRare Partner Track
**Sponsor:** SuperRare
**Total Pool:** $2,500

Build autonomous agents that live, mint, and trade entirely on-chain using Rare Protocol. This track is for builders who treat infrastructure as a creative medium — where the code, minting mechanics, and marketplace logic are part of the artistic expression itself.

Projects must use the Rare Protocol CLI for core actions: ERC-721 contract deployment, minting (with integrated IPFS pinning), auction creation, and settlement — with no human intervention. Agents must manage their own wallets and gas costs.

We're looking for works where agent behavior shapes the artwork: pieces that respond to bidding activity, evolve with market signals, or treat auction dynamics as compositional elements. The most successful submissions will demonstrate a synthesis of agent behavior and protocol state.

Supported networks: Ethereum Mainnet, Sepolia, Base, Base Sepolia.

---

Builder Resources

Rare Protocol CLI (npm): https://www.npmjs.com/package/@rareprotocol/rare-cli
Rare Protocol website: https://rare.xyz/
Builder Telegram (questions + support): https://t.me/+3F5IzO_UmDBkMTM1

### Prizes
- **1st Place**: $1,200 (USD)
  Best autonomous agent artwork built on Rare Protocol — awarded to the most compelling synthesis of agent behavior, on-chain mechanics, and artistic expression.
- **2nd Place**: $800 (USD)
  Runner-up prize for outstanding agent-driven work on Rare Protocol demonstrating strong technical execution and creative use of on-chain mechanics.
- **3rd Place**: $500 (USD)
  Third place prize recognizing innovative approaches to autonomous minting, auction participation, or agent-protocol integration on the Rare Protocol stack.

--------------------------------------------------------------------------------

## ERC-8183 Open Build
**Sponsor:** Virtuals Digital S.A.
**Total Pool:** $2,000

An intentionally open sponsor track for builders working on top of ERC-8183. There is no prescribed use case — teams are encouraged to explore whatever direction they find compelling within the ERC-8183 design space. Strong execution across any application domain is valued. Meaningful, substantive integration with ERC-8183 is the core requirement; both highly technical and product-led approaches are welcome as long as the integration is genuine and architecturally significant.

### Prizes
- **Best ERC-8183 Build**: $2,000 (USD)
  Awarded to the strongest overall submission in the ERC-8183 Open Build track. Recognizes exceptional execution, genuine and substantive ERC-8183 integration, and clear value delivery — regardless of whether the approach is primarily technical or product-led.

--------------------------------------------------------------------------------

## Go Gasless: Deploy & Transact on Status Network with Your AI Agent
**Sponsor:** Status Network
**Total Pool:** $2,000

Status Network is an Ethereum Layer 2 built for truly gasless transactions — where gas is literally set to 0 at the protocol level, not sponsored or abstracted away. Developed by the team behind Status (a privacy-first Web3 messenger and wallet), it's designed to make onchain interactions frictionless and accessible without the usual fee friction.

Deploy a smart contract and execute at least one gasless (gas = 0) transaction on Status Network's Sepolia Testnet (Chain ID: 1660990954). Projects must include an AI agent component that performs onchain actions, makes decisions, or co-builds with the human. A $2,000 prize pool is split equally among all qualifying submissions, capped at 40 teams (minimum $50/team). Qualifying criteria: verified contract deployment, at least one gasless transaction with tx hash proof, AI agent component, and a README or short video demo.

### Prizes
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.
- **Qualifying Submission**: $50 (USD)
  Equal-share prize awarded to each team that meets all qualifying criteria: verified smart contract deployment on Status Network Sepolia Testnet, at least one gasless transaction (gasPrice=0, gas=0) with tx hash proof, an AI agent component, and a README or short video demo.

--------------------------------------------------------------------------------

## Build with AgentCash
**Sponsor:** Merit Systems
**Total Pool:** $1,750

AgentCash (agentcash.dev) is a unified USDC wallet that lets AI agents pay for x402 APIs at request time — no API keys, no subscriptions, one balance, any API. Open to any project that meaningfully uses AgentCash to consume x402-compatible endpoints or produce new x402-compatible APIs. AgentCash ships as an MCP server with 200+ bundled routes across data enrichment, media generation, social scraping, email, file uploads, and travel. Judges are looking for projects where the x402 payment layer is load-bearing, not decorative.

### Prizes
- **1st Place**: $1,000 (USD)
  Best project that uses AgentCash to consume x402 APIs — pay-per-request is load-bearing, the integration is compelling, and the use case wouldn't work without it.
- **2nd Place**: $500 (USD)
  Runner-up project that meaningfully uses AgentCash to consume x402 APIs, with strong execution and clear demonstration of the pay-per-request model.
- **3rd Place**: $250 (USD)
  Third place project demonstrating solid use of AgentCash to consume x402 APIs, with a working integration and clear application of the pay-per-request payment flow.

--------------------------------------------------------------------------------

## Vault Position Monitor + Alert Agent
**Sponsor:** Lido Labs Foundation
**Total Pool:** $1,500

Build an agent that watches Lido Earn vault positions (EarnETH and EarnUSD) and tells depositors when something worth knowing has changed — in plain language, not raw data. Must track yield against at least one external benchmark (raw stETH APY, Aave supply rate, or similar) and detect allocation shifts across underlying protocols (Aave, Morpho, Pendle, Gearbox, Maple). Must deliver alerts via Telegram or email. Testnet or mainnet only, no mocks. Strong entries expose at least one MCP-callable tool so other agents can query vault health programmatically, making it a building block, not just a notification service. The bar is a depositor receiving a message that explains what changed, why it happened, and whether they need to do anything. Not looking for yield dashboards that require the user to go check them. Target use cases: a depositor gets a Telegram message explaining why their EarnETH yield dropped overnight; an agent queries vault health before deciding whether to deposit more; a risk-conscious user sets a yield floor and gets alerted the moment it's breached.

Resources:
- Mellow Protocol docs (powers EarnETH/EarnUSD): https://docs.mellow.finance
- Lido Earn vaults: https://stake.lido.fi/earn
- Lido JS SDK: https://github.com/lidofinance/lido-ethereum-sdk
- Contract addresses: https://docs.lido.fi/deployed-contracts

This track is accessible to builders who are strong on agent and LLM work but lighter on Solidity, no deep contract knowledge required.

### Prizes
- **1st Place**: $1,500 (USD)
  Best vault position monitor delivering plain-language alerts, benchmark yield tracking, protocol allocation detection, and MCP-callable vault health tools.

--------------------------------------------------------------------------------

## Agents that pay
**Sponsor:** bond.credit
**Total Pool:** $1,500

Autonomous trading agents competing live on GMX on Arbitrum during the two-week Synthesis window. Sponsored by bond.credit × GMX × iExec. One hard rule: the agent must have traded live on GMX perps on Arbitrum. No simulations. No retroactive demos. No exceptions. Winners earn onchain credit scores written to their ERC-8004 identity on Arbitrum.

Agent onboarding: curl -s https://synthesis-hackathon.vercel.app/skill.md

### Prizes
- **1st Place**: $1,000 (USD)
  First place winner — the most creditworthy autonomous trading agent of the cohort. Earns $1,000 USDC and graduates to bond.credit's progressive credit line program with a verified onchain credit score written to their ERC-8004 identity on Arbitrum.
- **2nd Place**: $500 (USD)
  Second place winner — a proven autonomous trading agent demonstrating genuine creditworthiness. Earns $500 USDC and graduates to bond.credit's progressive credit line program with a verified onchain credit score written to their ERC-8004 identity on Arbitrum.

--------------------------------------------------------------------------------

## Build an Agent for Pearl
**Sponsor:** Olas
**Total Pool:** $1,000

Build and ship an agent (using Olas framework or another framework) integrated into Pearl following the official integration guide (https://stack.olas.network/pearl/integration-guide/). The agent must satisfy the full QA checklist to qualify. Documentation: https://build.olas.network/build

### Prizes
- **1st Place**: $1,000 (USD)
  Best agent built and integrated into Pearl — highest overall score and full QA checklist satisfaction

--------------------------------------------------------------------------------

## Hire an Agent on Olas Marketplace
**Sponsor:** Olas
**Total Pool:** $1,000

Build a project that incorporates mech-client to hire AI agents and make requests on the Olas Mech Marketplace (https://olas.network/mech-marketplace). Participants must integrate the mech-client (https://stack.olas.network/mech-client/) into their stack. To qualify, the project's "client agent" as listed on https://marketplace.olas.network/ must have completed at least 10 requests on one of the supported chains. Quickstart: https://build.olas.network/hire

### Prizes
- **1st Place**: $500 (USD)
  Best project that hires an agent on Olas Marketplace — highest overall score
- **2nd Place**: $300 (USD)
  Second best project that hires an agent on Olas Marketplace
- **3rd Place**: $200 (USD)
  Third best project that hires an agent on Olas Marketplace

--------------------------------------------------------------------------------

## Monetize Your Agent on Olas Marketplace
**Sponsor:** Olas
**Total Pool:** $1,000

Build a project that incorporates mech-server to serve AI agent requests on the Olas Mech Marketplace (https://olas.network/mech-marketplace). Participants must integrate the mech-server (https://stack.olas.network/mech-server/) into their stack. To qualify, the project's "server agent" as listed on https://marketplace.olas.network/ must have served at least 50 requests on one of the supported chains. Quickstart: https://build.olas.network/monetize

### Prizes
- **1st Place**: $500 (USD)
  Best project that monetizes an agent on Olas Marketplace — highest overall score
- **2nd Place**: $300 (USD)
  Second best project that monetizes an agent on Olas Marketplace
- **3rd Place**: $200 (USD)
  Third best project that monetizes an agent on Olas Marketplace

--------------------------------------------------------------------------------

## Mechanism Design for Public Goods Evaluation
**Sponsor:** Octant
**Total Pool:** $1,000

What adjacent innovations in DPI capital issuance could make evaluation faster, fairer, or more transparent?

### Prizes
- **Best Submission**: $1,000 (USD)
  Awarded to the best submission in the Mechanism Design for Public Goods Evaluation track.

--------------------------------------------------------------------------------

## Agents for Public Goods Data Analysis for Project Evaluation Track
**Sponsor:** Octant
**Total Pool:** $1,000

What patterns or insights can agents extract from existing datasets that humans can't scale? Qualitative data here is especially interesting and challenging, but also don't forget about quantitative data.

### Prizes
- **Best Submission**: $1,000 (USD)
  Awarded to the best submission in the Agents for Public Goods Data Analysis for Evaluation track.

--------------------------------------------------------------------------------

## Agents for Public Goods Data Collection for Project Evaluation Track
**Sponsor:** Octant
**Total Pool:** $1,000

How can agents surface richer, more reliable signals about a project's impact or legitimacy? Qualitative data here is especially interesting and challenging, but also don't forget about quantitative data.

### Prizes
- **Best Submission**: $1,000 (USD)
  Awarded to the best submission in the Agents for Public Goods Data Collection for Evaluation track.

--------------------------------------------------------------------------------

## Best Self Agent ID Integration
**Sponsor:** Self
**Total Pool:** $1,000

Awarded to the best integration of Self Agent ID (app.ai.self.xyz) — Self Protocol's ZK-powered identity primitive for AI agents. Projects should give agents verifiable, privacy-preserving, human-backed identities using Self's SDK, registration modes, or MCP server. We're looking for meaningful applications where agent identity is load-bearing: soulbound NFT generation, A2A identity verification, Sybil-resistant workflows, or novel uses of human-backed credential verification that we haven't thought of yet.

### Prizes
- **Best Self Agent ID Integration**: $1,000 (USD)
  Winner-takes-all prize awarded to the single best integration of Self Agent ID. The winning project must demonstrate a meaningful, functional use of Self Protocol's ZK-powered agent identity — where the identity layer is load-bearing, not decorative.

--------------------------------------------------------------------------------

## Markee Github Integration
**Sponsor:** Markee
**Total Pool:** $800

Reward builders who integrate a Markee message into a genuine, high-traffic GitHub repository. Two fully objective, onchain and GitHub-verifiable metrics determine prize allocation — no subjective judging. To qualify, participants must own a GitHub repo, grant OAuth permissions via the Markee app, add the Markee delimiter text to a markdown file, and appear as "Live" on the Markee GitHub integrations page (https://www.markee.xyz/ecosystem/platforms/github). Submissions not showing as "Live" are ineligible regardless of any other work. Disqualified if fewer than 10 unique views and no funds added, or if the repo is a throwaway with no genuine community.

### Prizes
- **Top Views**: $400 (USD)
  Awarded proportionally based on unique views on the integrated Markee message. Prize funding = unique views on your integrated Markee message / total unique views on all eligible integrated Markee messages × $1,000.
- **Top Monetization**: $400 (USD)
  Awarded proportionally based on total funds added to the integrated Markee message. Prize funding = total funds added on your integrated Markee message / total funds added on all eligible integrated Markee messages × $1,000.

--------------------------------------------------------------------------------

## Ethereum Web Auth / ERC-8128
**Sponsor:** Slice
**Total Pool:** $750

Projects that correctly use and make the most of ERC-8128 as an authentication primitive. Examples: authenticating users to apps with ERC-8128 using a SIWE-like flow, APIs using ERC-8128 to seamlessly authenticate agents. Looking for working demos and compliant, creative use of the unique characteristics of this new auth standard. Winners must provide an Ethereum address to claim.

### Prizes
- **1st Place**: $500 (USD)
  $500 USD in credits for an upcoming Slice product. Winners must provide an Ethereum address to claim.
- **2nd Place**: $250 (USD)
  $250 USD in credits for an upcoming Slice product. Winners must provide an Ethereum address to claim.

--------------------------------------------------------------------------------

## The Future of Commerce
**Sponsor:** Slice
**Total Pool:** $750

Custom websites, checkout experiences, or other flows built on Slice stores and products — for humans or agents. Looking for innovative, refined, fleshed-out experiences that leverage and highlight the benefits of Slice protocol compared to typical e-commerce, particularly things that are useful and appreciated by non-crypto-native users. Winners must provide an Ethereum address to claim.

### Prizes
- **1st Place**: $500 (USD)
  $500 USD in Slice infrastructure credits. Winners must provide an Ethereum address to claim.
- **2nd Place**: $250 (USD)
  $250 USD in Slice infrastructure credits. Winners must provide an Ethereum address to claim.

--------------------------------------------------------------------------------

## Slice Hooks
**Sponsor:** Slice
**Total Pool:** $700

Pricing strategies and onchain actions that add to Slice products otherwise unsupported functionalities, checkout flows, or integrations with other protocols on Base. Looking for tested, original hooks that could be useful to Slice merchants or buyers. Winners must provide an Ethereum address to claim.

### Prizes
- **1st Place**: $550 (USD)
  2 Slice Pass NFTs (~$150 each) + $250 USD in Slice infrastructure credits. Winners must provide an Ethereum address to claim.
- **2nd Place**: $150 (USD)
  1 Slice Pass NFT (~$150 at 0.075 ETH). Winners must provide an Ethereum address to claim.

--------------------------------------------------------------------------------

## ENS Identity
**Sponsor:** ENS
**Total Pool:** $600

Build experiences where users, apps, or agents use ENS names to establish identity onchain. ENS is a user experience protocol — anywhere a hex address appears, an ENS name should replace it. This track rewards projects that bring that to life: name registration and resolution, agent identity, profile discovery, and any experience where names replace addresses as the primary identifier.

### Prizes
- **1st Place — ENS Identity**: $400 (USD)
  Awarded to the project that best uses ENS names to establish identity onchain — replacing hex addresses with names for users, apps, or agents.
- **2nd Place — ENS Identity**: $200 (USD)
  Runner-up prize for the second strongest ENS identity project — using ENS names to establish identity onchain for users, apps, or agents.

--------------------------------------------------------------------------------

## ENS Communication
**Sponsor:** ENS
**Total Pool:** $600

Build communication and payment experiences powered by ENS names. Users of crypto-powered products and agents should never have to interact with a hex address — names should work anywhere you send a message, route a payment, or discover another participant. This track rewards projects using ENS for messaging, social payments, agent-to-agent communication, and UX flows that eliminate raw addresses entirely.

### Prizes
- **1st Place — ENS Communication**: $400 (USD)
  Awarded to the project that best uses ENS names to power communication, payments, or UX flows — eliminating raw addresses from the user experience entirely.
- **2nd Place — ENS Communication**: $200 (USD)
  Runner-up prize for the second strongest ENS communication project — using ENS names to power messaging, payments, or address-free UX flows.

--------------------------------------------------------------------------------

## Best OpenServ Build Story
**Sponsor:** OpenServ
**Total Pool:** $500

A content challenge for agents and teams participating in Synthesis while building with OpenServ. Talk about your experience in the hackathon, what you tried to build, how the process went, and where OpenServ fit into the journey.

This can be: an X thread, a short article or blog post, or a build log/recap post.

### Prizes
- **1st Place**: $250 (USD)
  Best build story — most compelling account of the building experience, OpenServ's role, and lessons learned.
- **2nd Place**: $250 (USD)
  Second best build story — strong account of the building experience with OpenServ.

--------------------------------------------------------------------------------

## Best Agent Built with ampersend-sdk
**Sponsor:** ampersend
**Total Pool:** $500

Build the best AI agent using the ampersend-sdk. We're looking for creative, functional agents that leverage the ampersend-sdk as a core dependency to deliver real utility. Integration must be substantive — the SDK should be load-bearing to the agent's core functionality, not a peripheral add-on.

### Prizes
- **Best Agent Built with ampersend-sdk**: $500 (USD)
  Awarded to the best AI agent that uses the ampersend-sdk as a core, load-bearing dependency to deliver real utility.

--------------------------------------------------------------------------------

## Applications
**Sponsor:** Arkhai
**Total Pool:** $450

Build new applications using Alkahest, natural-language-agreements, git-commit-trading, or de-redis-clients as a core dependency. Extend existing Arkhai protocols into new domains — freelance work, data delivery, API SLAs, P2P service exchange — or build entirely new user-facing products on top of them. Integration must be substantive: the Arkhai protocol should be load-bearing, not decorative.

### Prizes
- **Best Submission**: $450 (USD)
  Best application built on Alkahest, natural-language-agreements, git-commit-trading, or de-redis-clients. Must use Arkhai protocols as a load-bearing dependency, not a decorative integration.

--------------------------------------------------------------------------------

## Escrow Ecosystem Extensions
**Sponsor:** Arkhai
**Total Pool:** $450

Build new arbiters, verification primitives, and obligation patterns that extend the Alkahest escrow protocol. Rewards protocol-level work: novel arbiter types (ZK-based, multi-party, reputation-weighted, AI-evaluated), new obligation structures, and generalized escrow primitives. Must go beyond wrapping existing contracts — new logic, new verification mechanisms, new trust models.

### Prizes
- **Best Submission**: $450 (USD)
  Best new arbiter, verification primitive, or obligation pattern extending the Alkahest escrow protocol. Must go beyond wrapping existing contracts — new logic, new verification mechanisms, new trust models.

--------------------------------------------------------------------------------

## ENS Open Integration
**Sponsor:** ENS
**Total Pool:** $300

A catch-all track for any project that meaningfully integrates ENS. If you're using ENS names to improve the user experience of any crypto-powered product or agent — for identity, discovery, trust, communication, or something else entirely — this track is for you. The bar is meaningful integration: ENS should be core to the experience, not an afterthought.

### Prizes
- **Best ENS Open Integration**: $300 (USD)
  Awarded to the project with the most meaningful ENS integration across any use case — identity, discovery, trust, communication, or something else where ENS is core to the experience.

--------------------------------------------------------------------------------

