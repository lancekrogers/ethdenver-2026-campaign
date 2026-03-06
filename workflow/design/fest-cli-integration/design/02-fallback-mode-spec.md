# Fallback Mode Specification

## Why Fallback Exists
`fest` repository visibility and installation state may vary across judges, contributors, and CI environments. Demo reliability must remain high, but live testnet mode must remain strict.

## Fallback Modes

### Mode A: `source=fest` (primary)
Used when:
- `fest` binary is present.
- selector resolution succeeds.
- required CLI calls return parseable JSON.

Behavior:
- Coordinator emits real festival snapshots.
- Dashboard label: `Festival Source: fest`.

### Mode B: `source=synthetic` (controlled fallback)
Used when:
- `FEST_FALLBACK_ALLOW_SYNTHETIC=true`.
- Any primary condition fails (missing binary, selector, timeout, parse error).

Behavior:
- Coordinator emits deterministic synthetic festival snapshot.
- Payload includes `fallback_reason` and `fest_error_code`.
- Dashboard label: `Festival Source: synthetic (fallback)`.

### Mode C: `source=none` (hard fail)
Used when:
- `FEST_FALLBACK_ALLOW_SYNTHETIC=false` and primary conditions fail.

Behavior:
- Coordinator startup/preflight fails.
- `just live up` exits non-zero with actionable remediation.

## Mode Matrix

| Runtime Mode | FEST_FALLBACK_ALLOW_SYNTHETIC | Expected Behavior |
|---|---:|---|
| `demo` | `true` (default) | Always runs; uses synthetic if fest unavailable |
| `live-testnet` | `false` (default) | Fail fast if fest unavailable/misconfigured |
| `live-testnet` | `true` (explicit override) | Allowed only for controlled rehearsals; must be labeled non-production |

## Required Environment Keys
- `FEST_SELECTOR` (optional, preferred in live mode)
- `FEST_FALLBACK_ALLOW_SYNTHETIC` (`true|false`)
- `FEST_POLL_INTERVAL_SECONDS` (default `10`)
- `FEST_COMMAND_TIMEOUT_SECONDS` (default `8`)
- `FEST_ALLOW_COMPLETED` (default `false`)

## Preflight Rules

### Demo preflight
- Warn if `fest` missing.
- Continue with synthetic fallback.

### Live preflight
- Error if `fest` missing unless override enabled.
- Error if selector cannot be resolved to active/ready/planning/someday.
- Error if command timeouts exceed threshold twice consecutively.

## Public Repo Transition Strategy
Until `fest` repo is public:
- Depend only on installed `fest` binary.
- Pin a minimum CLI version via `fest version` parsing (e.g., commit or semver gate).

After repo is public:
- Add explicit install docs for reproducible setup.
- Keep CLI JSON contract tests to detect breaking output changes early.
