---
fest_type: task
fest_id: 03_deploy_dashboard.md
fest_name: deploy_dashboard
fest_parent: 07_deploy
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Deploy Dashboard

**Task Number:** 03 | **Sequence:** 07_deploy | **Autonomy:** medium

## Objective

Deploy the dashboard to a hosting platform (Vercel, Railway, or similar) with a public URL. Configure the WebSocket endpoint to connect to the running agents. Verify all five dashboard panels show live data.

## Requirements

- [ ] Dashboard deployed to hosting with a public URL
- [ ] WebSocket endpoint configured and connecting to agent system
- [ ] All 5 dashboard panels show live data
- [ ] Dashboard loads within 3 seconds
- [ ] Public URL is accessible without authentication
- [ ] Deployment details documented

## Implementation

### Step 1: Prepare the dashboard for deployment

Navigate to the dashboard project:

```bash
cd /Users/lancerogers/Dev/Crypto/ETHDENVER/ethdenver2026/projects/dashboard
```

Verify the dashboard builds for production:

```bash
# Use the project's build command
just build
# Or: npm run build / yarn build / pnpm build
```

### Step 2: Configure environment variables

Set the production environment variables:

- **WebSocket endpoint**: URL of the agent system's WebSocket server (where the coordinator exposes agent state)
- **API endpoint**: URL for any REST API calls to the agent system
- **Network**: Testnet identifiers for Hedera and Base

Create or update the production environment file:

```bash
# Example .env.production
NEXT_PUBLIC_WS_ENDPOINT=wss://[your-agent-host]/ws
NEXT_PUBLIC_API_ENDPOINT=https://[your-agent-host]/api
NEXT_PUBLIC_NETWORK=testnet
```

### Step 3: Deploy to hosting platform

**Option A: Vercel**

```bash
# Install Vercel CLI if needed
npm i -g vercel

# Deploy
vercel --prod

# Note the deployment URL
```

**Option B: Railway**

```bash
# Push to Railway
railway up

# Note the deployment URL
```

**Option C: Other platform**

Follow the platform's deployment guide. The dashboard is a standard web application (React/Next.js).

### Step 4: Verify the deployment

1. Open the public URL in a browser
2. Verify the page loads within 3 seconds
3. Check that the WebSocket connection establishes (look for connection indicator in the dashboard UI or browser dev tools)
4. Verify each of the 5 panels shows live data:
   - **Panel 1**: Agent status (coordinator, inference, defi -- all showing "online" or "active")
   - **Panel 2**: HCS message feed (recent messages flowing)
   - **Panel 3**: Task activity (current or recent tasks)
   - **Panel 4**: DeFi/trading activity (recent trades)
   - **Panel 5**: System overview or metrics

5. Wait 60 seconds and verify data continues updating (not a stale snapshot)

### Step 5: Test accessibility

- Test from a different device or browser (ensure no cookies/auth required)
- Test the URL on mobile (judges may check from phones)
- Verify the URL is memorable or easy to share

### Step 6: Document deployment

Record:

- **Public URL**: The deployed dashboard URL
- **Hosting platform**: Which platform was used
- **Deployment command**: How to redeploy if needed
- **Environment variables**: Which env vars are configured (not the values for secrets)
- **WebSocket status**: Whether WS connection is stable
- **Known limitations**: Any panels that may show stale data or edge cases

### Step 7: Update READMEs with dashboard URL

Go back to each project README and add the dashboard URL where referenced:

- agent-coordinator README demo section
- Demo notes documents
- Any other documents that reference "dashboard URL"

## Done When

- [ ] Dashboard deployed with public URL
- [ ] WebSocket connected to running agents
- [ ] All 5 panels showing live data
- [ ] Dashboard loads within 3 seconds
- [ ] Accessible without authentication from any device
- [ ] Deployment documented
- [ ] READMEs updated with dashboard URL
