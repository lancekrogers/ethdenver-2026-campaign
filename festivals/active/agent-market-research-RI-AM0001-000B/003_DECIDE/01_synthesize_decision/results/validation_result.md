# Decision Validation

Status: PASS

- [x] decision json valid
- [x] decision field binary
- [x] confidence between 0 and 1
- [x] timestamp recent
- [x] rationale object present
- [x] no-go has blocking factors
- [x] vault constraints present
- [x] guardrails present
- [x] artifact paths canonical
- [x] agent log exists
- [x] confidence below 0.5 implies NO_GO
- [x] position within remaining capacity
- [x] position within max swap
- [x] token pair whitelisted
- [x] rationale deviation matches findings
- [x] confidence matches formula within 0.01

Spot check: rationale deviation 39.913% matches aggregated finding 39.913%.
Spot check: confidence 0.75 with 6/8 gates and net profit $197.5651 is internally consistent.
Spot check: position $500 is within remaining capacity $9999 and max swap $1000.
