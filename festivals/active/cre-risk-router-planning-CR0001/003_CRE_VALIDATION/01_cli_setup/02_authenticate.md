---
fest_type: task
fest_id: 01_authenticate.md
fest_name: authenticate
fest_parent: 01_cli_setup
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-03-01T17:42:44.223535-07:00
fest_updated: 2026-03-02T00:10:12.930089-07:00
fest_tracking: true
---


# Task: authenticate

## Objective

Run the CRE authentication flow (`cre login`, `cre account link-key` if needed) and verify identity with `cre whoami`.

## Requirements

- [ ] `cre login` completes successfully (Req 0.2)
- [ ] `cre whoami` returns authenticated user identity
- [ ] If key linking is required, `cre account link-key` is executed
- [ ] All auth requirements are documented

## Implementation

1. **Run CRE login**:

   ```bash
   cre login
   ```

   Follow any browser-based OAuth flow or API key prompts. Document exactly what credentials or accounts are needed.

2. **Check if key linking is required**:

   ```bash
   cre account link-key
   ```

   This may be needed to link a wallet/signing key for EVM writes. If the command does not exist or is not needed, document that.

3. **Verify identity**:

   ```bash
   cre whoami
   ```

   Expected output: Your authenticated identity (email, account ID, or similar).

4. **Document the auth flow**:
   - What credentials are required (API key, OAuth, wallet key, etc.)
   - Whether `link-key` is needed for EVM write operations
   - Whether auth persists across sessions or requires re-login
   - Any environment variables needed (e.g., `CRE_API_KEY`, `CRE_PRIVATE_KEY`)
   - Whether a funded wallet is required for simulation vs. broadcast

5. **Update `.env.example`** with any required auth-related environment variables.

## Done When

- [ ] All requirements met
- [ ] `cre whoami` returns a valid authenticated identity
- [ ] Auth flow is fully documented with exact commands and expected outputs
- [ ] Any required environment variables are documented in `.env.example` template