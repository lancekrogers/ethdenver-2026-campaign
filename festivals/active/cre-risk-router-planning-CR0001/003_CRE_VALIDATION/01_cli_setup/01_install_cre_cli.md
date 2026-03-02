---
fest_type: task
fest_id: 01_install_cre_cli.md
fest_name: install cre cli
fest_parent: 01_cli_setup
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:42:44.206273-07:00
fest_updated: 2026-03-02T00:06:49.214758-07:00
fest_tracking: true
---


# Task: install cre cli

## Objective

Install the CRE (Chainlink Runtime Environment) CLI and verify it is accessible and returns a valid version string.

## Requirements

- [ ] CRE CLI binary installed on the development machine (Req 0.1)
- [ ] `cre --version` returns a valid version string without errors
- [ ] Installation method documented for reproducibility

## Implementation

1. **Install the CRE CLI** using the official installer:

   ```bash
   curl -sSL https://cre.chain.link/install | sh
   ```

   If the above URL does not work, check the hackathon skills repo at `github.com/smartcontractkit/chainlink-agents-hackathon-skills` for alternative installation instructions.

2. **Verify the installation**:

   ```bash
   cre --version
   ```

   Expected output: A version string (e.g., `cre version 0.x.x`).

3. **Check available commands**:

   ```bash
   cre --help
   ```

   Document the available subcommands, especially `workflow`, `account`, `login`, and `generate-bindings`.

4. **Add to PATH** if not automatically added:

   ```bash
   # Add to ~/.zshrc or equivalent
   export PATH="$PATH:<cre-install-directory>"
   ```

5. **Document the installation** in the Phase 001 findings. Note:
   - Exact install command used
   - Version installed
   - Any prerequisites required (Go version, etc.)

## Done When

- [ ] All requirements met
- [ ] `cre --version` outputs a valid version string
- [ ] `cre --help` shows available commands
- [ ] Installation steps documented for team reference