# Local verification of the new-format code

These files are produced by `../tools/verify_all.sh` on the copied
`code/2D_Geometry` tree. They are **not** the archived 0.9.116 IMO runs; the
archived runs are summarized in `imo_runs.md` and `../evidence/`.

- `local_verification_1.0.6-beta.tsv` — measured with a locally built
  Litex 1.0.6-beta.
- `local_verification_1.1.1-beta.tsv` — measured with a locally built
  Litex 1.1.1-beta (spot checks only; see `../code/STATUS.md`).

The TSV columns are: package, status, seconds, first error (if any).
A `timeout` row only means the per-package timeout was too small; it is not a
proof failure. Problem 13 and Problem 17 need a large timeout (≥ 900 s) on the
1.0.6 engine.
