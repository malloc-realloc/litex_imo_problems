# Archived IMO runs: per-package status and wall-clock time

**This is the core evidence for the agent result.** Source of status: the original `litex_verified.json` / `litex_strict.json` files under `../../IMO/solutions/`.
The compact machine index is `../evidence/archived_verification_status.json`.

**Important:** the archived run is Litex **0.9.116-beta** with a **shared 7.3 KB, 39-declaration** geometry library. The new-format 1.x code is a separate reading/reproduction reference; see `../code/STATUS.md` for its measured compatibility.

| ID | IMO | Theme | Package | Archived status | Strict evidence | Wall-clock | Time source |
|---:|---|---|---|---|---|---:|---|
| 1 | 1960 P3 | Right triangle, hypotenuse subdivision, tangent identity | Solution-1 | verified | success; 0 trust in strict trace | n/a | legacy log has no prompt/response timestamps |
| 1 | 1960 P3 | same | Solution-2 | verified | success; 0 trust in strict trace | n/a | legacy log has no prompt/response timestamps |
| 2 | 1960 P6 | Cone, inscribed sphere, volume ratio | Solution-1 | verified | success; parts (a)+(b); 0 trust | 26 min | agent-reported in session log |
| 2 | 1960 P6 | same | Solution-2 | verified | success; part (a) only; 0 trust | 41 min | metadata start/finish |
| 3 | 1961 P4 | Interior point, cevian ratios, inequality | main | verified | strict summary: 0 errors, 9 theorems | 11 h 00 min | log first/last timestamp |
| 4 | 1961 P5 | Triangle construction, median angle | main | verified | success; 0 trust in strict trace | 2 h 44 min | metadata start/finish |
| 5 | 1962 P6 | Circumcenter/incenter Euler relation | Solution-1 | verified | success; 0 trust in strict trace | 46 min | log first/last timestamp |
| 5 | 1962 P6 | same | Solution-2 | verified | success; 0 trust in strict trace | 2 h 07 min | log first/last timestamp |
| 7 | 1963 P3 | Equiangular polygon, monotone sides | main | verified | success; 0 trust in strict trace | 8 h 42 min | metadata start/finish |
| 12 | 1966 P6 | Three side points, area ≤ 1/4 | main | verified | success; 0 trust in strict trace | 1 h 43 min | first prompt to next-task timestamp |
| 13 | 1967 P1 | Four unit disks cover a parallelogram | main | verified | 92/92 strict documents success; 0 trust | 14 h 25 min | log first/last timestamp |
| 15 | 1968 P1 | Consecutive integer sides, doubled angle | main | verified | success; 0 trust in strict trace | 3 h 45 min | metadata start/finish |
| 17 | 1969 P4 | Semicircle, incircle, tangent circles | main | verified | success; 0 trust in strict trace | ≥ 1 h | capture log truncated; exact start/finish not recoverable |
| 18 | 1970 P1 | Cevian, inradius/exradius ratio | main | verified | success; 0 trust in strict trace | 48 min | metadata start/finish |
| 20 | 1970 P6 | 100 points, acute triangle bound | main | **not verified in archive** | production strict report is an error | 11 h 03 min | log first/last timestamp |

## Totals

- **Verified:** 14 packages covering 11 problems.
- **Failed in archive:** 1 package (IMO 1970 P6).
- **Wall-clock sum of the 14 verified packages:** ≈ **48.1 hours**.
- **Including the failed P20 run:** ≈ **59.2 hours**.

These are wall-clock numbers from an interactive agent session. They include model latency, API rate limits, retries and human corrections. They are **not** pure proof-search time and should not be compared directly with a Lean compile benchmark.

## Why some timestamps are “n/a”

The archived logging harness captured prompts/responses, but not every legacy log has timestamped `=== Prompt ===` / `=== Response ===` headers, and some logs were rotated or truncated. For those packages the exact duration cannot be recovered without guessing. We mark them `n/a` or `≥ 1 h` instead of inventing a number.

## Token usage

Not recorded. The archived logs contain no numeric `prompt_tokens`, `completion_tokens` or `total_tokens` fields. See `token_availability.md`.
