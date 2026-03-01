---
fest_type: task
fest_id: 03_compute_metrics.md
fest_name: compute_metrics
fest_parent: 06_zerog_track2_package
fest_order: 3
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-18T14:00:00-07:00
fest_updated: 2026-02-21T12:12:45.827957-07:00
fest_tracking: true
---


# Task: Gather and Document Compute Metrics

**Task Number:** 03 | **Sequence:** 03_zerog_track2_package | **Autonomy:** medium

## Objective

Gather compute performance metrics from the inference agent's 0G Compute usage and document them in `docs/compute-metrics.md`. Metrics include inference latency, GPU utilization, cost per inference, and throughput. This is key evidence for the 0G Track 2 bounty.

## Requirements

- [ ] Inference latency measured across multiple runs (minimum 10 inference calls)
- [ ] GPU utilization documented (if available from 0G APIs)
- [ ] Cost per inference calculated (gas costs, 0G fees)
- [ ] Throughput measured (inferences per minute/hour)
- [ ] Methodology documented so results are reproducible
- [ ] Document saved at `projects/agent-inference/docs/compute-metrics.md`

## Implementation

### Step 1: Prepare the test environment

Ensure the inference agent is running and connected to 0G Compute:

```bash
cd $(fgo)
# Start the inference agent or verify it is already running
just run
```

### Step 2: Run inference benchmarks

Execute a minimum of 10 inference calls, recording timing for each:

```bash
# Use the project's benchmark command if available
just benchmark
# Or manually trigger inferences and time them
```

For each inference call, record:

- **Call number**: Sequential ID
- **Start time**: When the request was sent
- **End time**: When the result was received
- **Latency**: End - Start (in milliseconds)
- **Model**: Which model was used
- **Input size**: Size of the input payload
- **Output size**: Size of the output payload
- **Cost**: Gas or 0G fees for this call (if measurable)

### Step 3: Collect GPU utilization data

If the 0G Compute API provides GPU utilization metrics:

```bash
# Query 0G Compute for job metrics
# This depends on the 0G SDK capabilities
```

If GPU utilization is not directly available, document this limitation and provide inference job completion data as a proxy.

### Step 4: Calculate summary statistics

From the raw data, calculate:

- **Average latency**: Mean inference time
- **P50 latency**: Median inference time
- **P95 latency**: 95th percentile (captures outliers)
- **P99 latency**: 99th percentile
- **Min/Max latency**: Range
- **Throughput**: Number of successful inferences per minute
- **Average cost per inference**: Total costs divided by number of inferences
- **Success rate**: Successful inferences / total attempts

### Step 5: Write the compute metrics document

Create `docs/compute-metrics.md`:

```markdown
# Compute Metrics Report

## Test Environment
- Date: [date]
- 0G Compute endpoint: [endpoint]
- Model: [model name/version]
- Inference agent version: [commit hash]
- Number of test runs: [N]

## Methodology
[Describe how measurements were taken, what was timed,
and how costs were calculated]

## Raw Data

| Run | Latency (ms) | Input Size | Output Size | Cost | Status |
|-----|--------------|------------|-------------|------|--------|
| 1 | | | | | |
| 2 | | | | | |
...

## Summary Statistics

| Metric | Value |
|--------|-------|
| Average Latency | ms |
| P50 Latency | ms |
| P95 Latency | ms |
| P99 Latency | ms |
| Min Latency | ms |
| Max Latency | ms |
| Throughput | inferences/min |
| Avg Cost/Inference | |
| Success Rate | % |

## GPU Utilization
[GPU utilization data if available, or note the limitation]

## Analysis
[Brief analysis: Is latency acceptable? Is cost viable for production?
How does decentralized inference compare to centralized alternatives?]
```

## Done When

- [ ] Minimum 10 inference runs measured and recorded
- [ ] Summary statistics calculated (average, P50, P95, P99, throughput, cost)
- [ ] Methodology documented for reproducibility
- [ ] Document saved at `projects/agent-inference/docs/compute-metrics.md`
- [ ] Metrics demonstrate viable inference performance through 0G Compute