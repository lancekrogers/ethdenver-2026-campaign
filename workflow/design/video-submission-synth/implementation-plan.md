# Implementation Plan — Remotion Video

## Setup (Step 1)

### Create the Remotion project

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/Obey-Agent-Economy/projects
npx create-video@latest
# Name: obey-demo-video
# Template: Blank
# TailwindCSS: Yes
# Install skills: Yes
```

### Install Remotion skills for Claude Code

```bash
cd obey-demo-video
npx skills add remotion-dev/skills
```

### Add MCP server (optional, for editor integration)

Add to `.claude/settings.json` or editor MCP config:

```json
{
  "mcpServers": {
    "remotion-documentation": {
      "command": "npx",
      "args": ["@remotion/mcp@latest"]
    }
  }
}
```

### Verify setup

```bash
npm run dev     # Studio at localhost:3000
npx remotion render MyComp out.mp4  # test render
```

---

## Project Structure (Step 2)

```
obey-demo-video/
├── src/
│   ├── Root.tsx                    # Composition registry
│   ├── ObeyDemo.tsx                # Main video component (all scenes)
│   ├── scenes/
│   │   ├── S1_VaultBoundaries.tsx  # Vault constraints + role separation
│   │   ├── S2_AgentIdentity.tsx    # ERC-8004 registration
│   │   ├── S3_RitualCycle.tsx      # Live ritual execution (longest scene)
│   │   ├── S4_OnChainReceipt.tsx   # SwapExecuted event + agent_log
│   │   ├── S5_MultiChain.tsx       # Architecture diagram
│   │   └── S6_Closing.tsx          # CTA + tech stack
│   ├── components/
│   │   ├── TerminalWindow.tsx      # Animated terminal output
│   │   ├── JsonViewer.tsx          # Syntax-highlighted JSON display
│   │   ├── ChainBadge.tsx          # Chain logo + name
│   │   ├── DecisionCard.tsx        # GO/NO_GO decision display
│   │   ├── FlowDiagram.tsx         # discover→plan→execute→verify loop
│   │   └── TitleCard.tsx           # Branded title slides
│   ├── data/
│   │   ├── agent.json              # Symlink or copy from root
│   │   ├── agent_log.json          # Symlink or copy from projects/agent-defi
│   │   └── decision-samples/       # Real decision.json files from ritual runs
│   └── styles/
│       └── theme.ts                # Colors, fonts, spacing
├── public/
│   ├── fonts/                      # Monospace font for terminal scenes
│   └── images/                     # Chain logos, OBEY logo
├── package.json
└── remotion.config.ts
```

Run `t2s` with the tree above to scaffold.

---

## Composition Definition (Step 3)

```tsx
// src/Root.tsx
import { Composition } from 'remotion';
import { ObeyDemo } from './ObeyDemo';

export const RemotionRoot = () => {
  return (
    <Composition
      id="obey-demo"
      component={ObeyDemo}
      width={1920}
      height={1080}
      fps={30}
      durationInFrames={5400}  // 3 minutes
      defaultProps={{
        agentJsonPath: '../../../agent.json',
        agentLogPath: '../../../projects/agent-defi/agent_log.json',
      }}
    />
  );
};
```

---

## Scene Breakdown with Frame Budgets (Step 4)

| Scene | Frames | Seconds | Component | Content |
|-------|--------|---------|-----------|---------|
| 1 — Vault Boundaries | 0–900 | 0:00–0:30 | S1_VaultBoundaries | Title card → animated constraints → role diagram |
| 2 — Agent Identity | 900–1500 | 0:30–0:50 | S2_AgentIdentity | ERC-8004 tx → identity contract → operator link |
| 3 — Ritual Cycle | 1500–3300 | 0:50–1:50 | S3_RitualCycle | Festival loop → terminal sim → decision.json → GO/NO_GO |
| 4 — On-Chain Receipt | 3300–4200 | 1:50–2:20 | S4_OnChainReceipt | SwapExecuted event → reason field → agent_log entry |
| 5 — Multi-Chain | 4200–4800 | 2:20–2:40 | S5_MultiChain | Architecture diagram → chain badges → tx counts |
| 6 — Closing | 4800–5400 | 2:40–3:00 | S6_Closing | Tagline → links → tech stack → tracks |

---

## Build Each Scene (Step 5)

### Scene 1: Vault Boundaries

Key animations:
- Spring-animated numbers counting up to constraint values
- Side-by-side Guardian vs Agent role cards sliding in
- Contract address fading in at bottom

```tsx
// Pseudocode pattern
const frame = useCurrentFrame();
const maxSwap = interpolate(frame, [30, 90], [0, 1000], { extrapolateRight: 'clamp' });
```

Data to import:
```ts
import agentJson from '../data/agent.json';
const constraints = agentJson.compute_constraints;
```

### Scene 2: Agent Identity

Key animations:
- ERC-8004 badge appearing with spring effect
- Tx hash typing out character by character
- Identity → Operator wallet connection line drawing

### Scene 3: Ritual Cycle (most complex)

Sub-sequences within this scene:
1. **Loop diagram** (frames 0–150): Animated discover→plan→execute→verify circle
2. **Terminal simulation** (frames 150–600): Fake terminal showing `fest ritual run` output, session creation, tool calls
3. **NO_GO card** (frames 600–900): Decision card with blocking factors, red border
4. **GO card** (frames 900–1200): Decision card with confidence score, green border
5. **Swap execution** (frames 1200–1500): Animated arrow from decision to vault

Use `TerminalWindow` component with typed-out text using `Sequence` offsets:
```tsx
<Sequence from={150}>
  <TerminalWindow lines={[
    { text: '$ fest ritual run agent-market-research-RI-AM0001', delay: 0 },
    { text: '{"run_id": "RI-AM0001-0012", "status": "created"}', delay: 30 },
    { text: '$ obey session create --festival RI-AM0001-0012', delay: 60 },
    { text: 'Session abc123 bound to workdir', delay: 90 },
  ]} />
</Sequence>
```

### Scene 4: On-Chain Receipt

Key animations:
- Basescan-style event log card
- Highlight `reason` field with glow effect
- agent_log.json entry sliding in from right
- Verification checkmark: "within_tolerance: true"

Data to import:
```ts
import agentLog from '../data/agent_log.json';
const swapEntry = agentLog.entries.find(e => e.action === 'vault_swap');
```

### Scene 5: Multi-Chain Architecture

Key animations:
- Central OBEY logo with chain nodes orbiting/connected
- Each chain badge appears with spring animation + tx count
- Lines connecting chains to show data flow

### Scene 6: Closing

Key animations:
- Tagline fade-in: "The agent cooks. The vault keeps it honest."
- Tech stack badges grid appearing one by one
- Track names with prize amounts

---

## Import Real Data (Step 6)

Symlink project data into the video project:

```bash
cd projects/obey-demo-video/src/data
ln -s ../../../../agent.json agent.json
ln -s ../../../../projects/agent-defi/agent_log.json agent_log.json

# Copy real decision samples
mkdir decision-samples
cp ../../../../.campaign/quests/*/003_DECIDE/01_synthesize_decision/results/decision.json \
   decision-samples/ 2>/dev/null || echo "Copy manually from latest quest"
```

---

## Preview and Iterate (Step 7)

```bash
# Start studio — live preview with hot reload
npm run dev

# Open Claude Code in another terminal
claude

# Prompt Claude: "Build scene 1 — vault boundaries with animated constraint values"
# Preview updates in real-time in the Studio
```

---

## Render Final Video (Step 8)

```bash
# Full render
npx remotion render obey-demo output/obey-vault-agent-demo.mp4 --codec h264

# Quick preview render (lower quality, faster)
npx remotion render obey-demo output/preview.mp4 --quality 50 --scale 0.5
```

---

## Upload and Update Submission (Step 9)

Upload the rendered MP4 to a public host (YouTube unlisted, Loom, or IPFS), then:

```bash
just synthesis video "https://your-video-url-here"
```

---

## Justfile Integration

Add to `.justfiles/synthesis.just` or create a video recipe:

```just
# Render the demo video
render-video:
    cd {{root}}/projects/obey-demo-video && npx remotion render obey-demo output/obey-vault-agent-demo.mp4 --codec h264

# Preview video in studio
video-studio:
    cd {{root}}/projects/obey-demo-video && npm run dev
```

---

## Time Estimate (Steps to Completion)

| Step | Tasks |
|------|-------|
| 1. Setup | Create project, install skills, verify render |
| 2. Structure | Scaffold with t2s, symlink data files |
| 3. Composition | Define Root.tsx with frame budgets |
| 4. Scene 1 | Vault boundaries — simplest scene, good warm-up |
| 5. Scene 2 | Agent identity — short, mostly text animation |
| 6. Scene 3 | Ritual cycle — most complex, terminal sim + decision cards |
| 7. Scene 4 | On-chain receipt — JSON viewer + event log |
| 8. Scene 5 | Multi-chain — architecture diagram |
| 9. Scene 6 | Closing — tagline + badges |
| 10. Polish | Transitions, timing, color consistency |
| 11. Render | Final MP4 output |
| 12. Upload | Host video + update submission |
