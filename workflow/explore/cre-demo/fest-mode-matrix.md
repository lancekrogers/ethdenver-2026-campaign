# Fest Runtime Mode Matrix

Date: 2026-03-06
Festival: `FC0001`

## Case A: Demo mode with fest present

Command:
```bash
just demo run
```

Result:
- Exit code: `0`
- Outcome: PASS
- Notes: Approved and denied CRE scenarios returned expected JSON payloads.

## Case B: Demo mode with fest missing from PATH and fallback enabled

Command:
```bash
PATH="/opt/homebrew/bin:/usr/bin:/bin" FEST_FALLBACK_ALLOW_SYNTHETIC=true MODE=demo ENV_FILE=.env.demo just demo run
```

Result:
- Exit code: `0`
- Outcome: PASS
- Notes: Demo run succeeds under fallback-friendly settings.

## Case C: Live strict mode doctor

Command:
```bash
FEST_FALLBACK_ALLOW_SYNTHETIC=false just mode doctor
```

Result:
- Exit code: `1`
- Outcome: EXPECTED FAIL
- Failure reasons observed:
  - `live_mode_blocked_simulated_cre`
  - `insufficient_base_balance`

## Additional Negative Check: live preflight with fest binary removed from PATH

Command:
```bash
PATH="/usr/bin:/bin" MODE=live-testnet ENV_FILE=.env.live bash scripts/preflight-live.sh
```

Result:
- Exit code: non-zero (captured via `|| true` wrapper)
- Outcome: EXPECTED FAIL
- Failure reason observed: `fest_binary_missing`

## Evidence Artifacts

- `workflow/explore/cre-demo/runs/20260306-222932/preflight-live.json`
- `workflow/explore/cre-demo/runs/20260306-222933/preflight-live.json`
- `workflow/explore/cre-demo/runs/20260306-222938/preflight-live.json`
- `workflow/explore/cre-demo/runs/20260306-222952/preflight-live.json`
