# Measured compatibility of the new-format code

This file records **our** measurements, separately from the upstream README’s
claim (“15 packages pass strict verification with Litex 1.0.6-beta”).

## How the test was run

From `code/2D_Geometry`:

```bash
/path/to/litex -strict -r IMO/problem_N
```

A package is marked `pass` only if the JSON output reports success for the
whole repository run. For Litex 1.0.x the field is `"success": true`; for
1.1.x it is `"run_result": "success"`. A timeout is not a failure of the proof,
but it is not a pass either.

Two binaries were built from the upstream repository:

| Binary | Tag | Commit |
|---|---|---|
| Litex 1.0.6-beta | `1.0.6-beta` | upstream tag |
| Litex 1.1.1-beta | `1.1.1-beta` | `fd62f2a` |

Build command: `cargo build --release` (see `../tools/build_litex.sh`).

## Results

### Litex 1.0.6-beta (the version named by upstream)

| Package | Result | Seconds | Note |
|---|---|---:|---|
| `IMO/problem_1/Solution-1` | pass | 97.5 | |
| `IMO/problem_1/Solution-2` | pass | 87.2 | |
| `IMO/problem_2/Solution-1` | pass | 0.7 | |
| `IMO/problem_2/Solution-2` | pass | 1.1 | |
| `IMO/problem_3` | pass | 6.6 | |
| `IMO/problem_4` | pass | 34.9 | |
| `IMO/problem_5/Solution-1` | pass | 8.1 | |
| `IMO/problem_5/Solution-2` | pass | 199.5 | |
| `IMO/problem_7` | pass | 6.1 | |
| `IMO/problem_12` | pass | 33.1 | |
| `IMO/problem_13` | pass | 431.8 | 92 strict documents; needs a >240 s timeout |
| `IMO/problem_15` | pass | 5.2 | |
| `IMO/problem_17` | not completed | > 6120 | 3,910-line package; ran for 1 h 42 min on 1.0.6 and was stopped. Not a proof failure, but not practically reproducible in this test. |
| `IMO/problem_18` | pass | 130.2 | |
| `IMO/problem_20` | pass | 56.2 | the later P20 proof closes under 1.0.6 |

### Litex 1.1.1-beta (all packages except the two long ones)

| Package | Result | Seconds | Note |
|---|---|---:|---|
| `IMO/problem_1/Solution-1` | pass | 24.3 | |
| `IMO/problem_1/Solution-2` | pass | 41.2 | |
| `IMO/problem_2/Solution-1` | pass | 0.8 | |
| `IMO/problem_2/Solution-2` | pass | 1.6 | |
| `IMO/problem_3` | pass | 6.4 | |
| `IMO/problem_4` | pass | 27.2 | |
| `IMO/problem_5/Solution-1` | pass | 3.5 | |
| `IMO/problem_5/Solution-2` | pass | 20.4 | |
| `IMO/problem_7` | pass | 6.0 | |
| `IMO/problem_13` | pass | 384.5 | 92 strict documents |
| `IMO/problem_12` | **fail** | 3.5 | `cyclic_quarter_nested` and `problem_12` rejected: the 1.1.x proof search no longer performs the same automatic reassociation of products (`((x*(1-x))*y)*(1-y)` vs `(x*(1-x))*(y*(1-y))`). This is a proof-search/normalization regression, not a wrong statement. |
| `IMO/problem_15` | pass | 7.8 | |
| `IMO/problem_18` | pass | 54.0 | |
| `IMO/problem_20` | **fail** | 52.7 | `three_plus_two_extension_20` and `three_vertex_five_extension_cardinality_20` rejected; again a proof-search/normalization difference, not a changed statement. |

`IMO/problem_17` was not run on 1.1.1 because it is long-running even on 1.0.6.
The P1/P2/P3/P4/P5/P7/P13/P15/P18 results show that the new **syntax** is
accepted by 1.1.1; the failures (P12 and P20) are localized to proof search.

## Interpretation

- The **new syntax** (`p(1)`, self-contained packages, `litex.config` with only
  `[export]`) is accepted by both 1.0.6 and 1.1.1.
- The **proof scripts** are not equally portable across proof-engine versions.
  1.1.1 appears stricter about explicit algebraic reassociation. If you need a
  reproducible full run today, use 1.0.6-beta, the version upstream names.
- A long runtime is not a failure. Problem 13 and Problem 17 have very large
  strict traces; give them a generous timeout (≥ 900 s) when running locally.

## Reproduce

```bash
# 1.0.6-beta
../tools/build_litex.sh 1.0.6-beta
../tools/verify_all.sh ../.litex-build/1.0.6-beta/litex 900

# 1.1.1-beta (expect P12 to fail on the current source)
../tools/build_litex.sh 1.1.1-beta
../tools/verify_all.sh ../.litex-build/1.1.1-beta/litex 900
```
