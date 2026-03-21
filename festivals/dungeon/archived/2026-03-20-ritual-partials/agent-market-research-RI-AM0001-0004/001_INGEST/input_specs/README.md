# Input Specifications

This directory is optional for runtime use. Place any static ritual inputs here that should be copied into each active run before ingest starts.

## Runtime Expectations

- Inputs must be machine-readable by an unattended agent.
- Inputs must not require human approval before the ritual can continue.
- Runtime execution should succeed even when this directory is empty.

## Appropriate Inputs

- Static symbol or pair metadata
- Reference constraints that do not change per run
- Notes about fallback data sources
- Any fixed contract addresses or identifiers that are useful to the ritual

## Not Appropriate Here

- Human approval checklists
- Planner-template prompts
- Any instruction that requires waiting for a person before `fest workflow advance`
