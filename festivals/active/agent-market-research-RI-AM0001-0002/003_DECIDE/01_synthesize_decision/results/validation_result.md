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
- [x] paused implies NO_GO
- [x] net profit below $1 implies NO_GO
- [x] position within remaining capacity
- [x] position within max swap
- [x] token pair whitelisted
- [x] rationale deviation matches findings
- [x] confidence matches formula within 0.01

Spot check: rationale deviation 1.1745% matches aggregated finding 1.1745%.
Spot check: confidence 0.0000 matches recomputed final confidence 0.0000 within ±0.01.
