---
fest_type: task
fest_id: 03_performance_verify.md
fest_name: performance_verify
fest_parent: 07_demo_polish
fest_order: 3
fest_status: pending
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_tracking: true
---

# Task: Performance Verification

**Task Number:** 03 | **Sequence:** 07_demo_polish | **Autonomy:** medium

## Objective

Verify that the complete dashboard meets the performance requirements: all panels render with live data within 2 seconds of page load, WebSocket reconnects automatically on disconnect, and the dashboard runs smoothly with all five panels visible simultaneously.

## Requirements

- [ ] All five panels render within 2 seconds of page load
- [ ] WebSocket auto-reconnects on disconnect
- [ ] No visible lag or jank when all panels are active
- [ ] Memory usage stays stable over a 10-minute session
- [ ] No TypeScript errors across the entire project

## Implementation

### Step 1: Verify TypeScript compilation

Run a full TypeScript check across the entire project:

```bash
cd $(fgo) && npx tsc --noEmit
```

This must pass with zero errors. If there are any errors, fix them before proceeding.

### Step 2: Measure initial render time

Open the dashboard in Chrome with DevTools open:

1. Open Chrome DevTools (F12)
2. Go to the Performance tab
3. Click "Record" and then reload the page (Cmd+Shift+R / Ctrl+Shift+R)
4. Wait for all panels to render
5. Stop recording

**Measure:**
- Time from navigation start to Largest Contentful Paint (LCP)
- Time from navigation start to all 5 panels visible
- Target: < 2 seconds for both metrics

**If render time exceeds 2 seconds:**
- Check for large bundle sizes: `cd $(fgo) && npm run build && ls -la .next/static/chunks/`
- Check for unnecessary re-renders: use React DevTools Profiler
- Check for slow data fetching: ensure initial mock data is synchronous
- Consider lazy loading panels below the fold
- Consider code splitting with `next/dynamic`

### Step 3: Test WebSocket reconnection

Test the auto-reconnect behavior:

1. Start the dashboard in live mode (not mock): `NEXT_PUBLIC_USE_MOCK=false npm run dev`
2. If a local WebSocket server is running, verify connection
3. Kill the WebSocket server (or disconnect network briefly)
4. Verify the dashboard shows "Disconnected" or "Connecting..." status
5. Restart the WebSocket server (or restore network)
6. Verify the dashboard reconnects automatically within the configured delay
7. Verify data resumes flowing after reconnection

**If no local WebSocket server is available:**
- Use mock mode and verify the connection state indicator works
- Manually test by modifying the WebSocket URL to an invalid endpoint, then restoring it
- Verify the connector's reconnect logic by reviewing the code and unit tests

### Step 4: Test with all panels active simultaneously

Run the dashboard with all panels rendering and updating:

1. Start in mock mode: `NEXT_PUBLIC_USE_MOCK=true npm run dev`
2. Open the dashboard
3. Let it run for 5 minutes
4. Check:
   - [ ] HCS feed continues auto-scrolling with new messages
   - [ ] Agent heartbeat indicators continue updating
   - [ ] No visible lag or frame drops when scrolling the HCS feed
   - [ ] DeFi chart updates without flickering
   - [ ] Inference gauge updates smoothly

### Step 5: Check memory stability

Monitor memory usage over a 10-minute session:

1. Open Chrome DevTools > Memory tab
2. Take a heap snapshot at start
3. Let the dashboard run for 10 minutes with mock data updating
4. Take another heap snapshot
5. Compare: memory should not grow by more than 50MB over 10 minutes

**If memory grows excessively:**
- Check that events arrays are bounded (1000 for WebSocket, 5000 for mirror node)
- Check that setInterval timers are cleaned up on unmount
- Check for React hook dependency issues causing re-subscriptions
- Check that old chart data points are pruned

### Step 6: Profile and optimize if needed

If any performance issues are found, apply targeted optimizations:

1. **Slow initial render**: Use `React.memo` on panel components, `useMemo` for derived data
2. **Slow chart updates**: Downsample chart data if > 500 points
3. **HCS feed lag**: Implement virtualized list with `react-window` if > 500 messages visible
4. **Large bundle**: Use `next/dynamic` to code-split heavy components (especially Recharts)
5. **Excessive re-renders**: Use React DevTools Profiler to identify and fix unnecessary renders

### Step 7: Final build verification

Run a production build to check for build-time errors:

```bash
cd $(fgo) && npm run build
```

This must succeed. Check for any warnings about large bundle sizes.

## Done When

- [ ] `npx tsc --noEmit` passes with zero errors across the entire project
- [ ] All five panels render within 2 seconds of page load
- [ ] WebSocket reconnection verified (or reconnect logic code-reviewed if no local server)
- [ ] Dashboard runs 5+ minutes without visible lag or jank
- [ ] Memory usage stable over 10 minutes (no significant growth)
- [ ] `npm run build` succeeds
- [ ] Any optimizations documented (what was slow, what was done)
