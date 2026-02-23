---
fest_type: task
fest_id: 02_add_root_quickstart.md
fest_name: add root quickstart
fest_parent: 06_doc_accuracy
fest_order: 2
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.828681-07:00
fest_tracking: true
---

# Task: Add Quick Start Section to Root README

## Objective

Add a quick start section to the root `README.md` so judges can run the demo with a single command without reading individual project READMEs.

## Requirements

- [ ] Root `README.md` has a "Quick Start" section near the top with `just demo` as the primary command
- [ ] The quick start section explains what `just demo` does (builds dashboard in mock mode, shows all 5 panels with simulated data)

## Implementation

### Step 1: Add quick start section

In `README.md` (root), add after the project description / architecture diagram:

```markdown
## Quick Start

```bash
# Clone with submodules
git clone --recursive https://github.com/lancekrogers/ethdenver-2026-campaign.git
cd ethdenver-2026-campaign

# Run the demo (dashboard in mock mode — no env vars needed)
just demo
```

This builds and starts the dashboard at `http://localhost:3000` with simulated data showing all 5 panels: Festival View, HCS Feed, Agent Activity, DeFi P&L, and Inference Metrics.

### Full System (requires .env configuration)

```bash
# Build all Docker images (agents + dashboard)
just docker build-all

# Start everything
just docker up-all

# View logs
just docker logs
```

```

### Step 2: Verify commands work

Run `just demo` yourself to confirm it builds and starts successfully.

## Done When

- [ ] All requirements met
- [ ] Root README has a Quick Start section and `just demo` is the first command a judge would see
