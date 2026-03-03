# CRE Demo Exploration

This directory captures exploration work for demonstrating the Chainlink CRE Risk Router functionality in the Obey Agent Economy campaign.

- `00-local-demo-investigation.md`: investigation of existing ETHDenver demo orchestration (dashboard + `just`), current CRE constraints, and recommended local demo runbooks.

## Implemented Command Surface

The campaign root now exposes a justfile-first Chainlink flow:

- `just chainlink up`
- `just chainlink demo`
- `just evidence collect`
- `just evidence validate`
- `just chainlink broadcast` (optional)
- `just chainlink down`
