# One-page comparison: Litex vs. Lean on IMO geometry

## The question

Can a general-purpose LLM learn a formal language well enough to write **correct
definitions** and **machine-checked proofs** for IMO plane geometry?

## The result

- **11 / 12** IMO geometry problems solved in the archived agent run.
- **14 / 15** solution packages passed strict verification.
- **0** `trust` in the strict traces.
- General-purpose models, **not** a geometry-specific prover, **not** Litex
  fine-tuning.
- The 39-declaration geometry library itself came from an automated definition
  pipeline (39/39 tasks, zero axiom debt).

## What the agent learned

The model read a short Litex guide, wrote definitions and helper lemmas, compiled,
read the structured error, repaired the proof, and repeated until strict
verification passed. The logs show it learning:

- explicit equality chains instead of algebraic jumps;
- nonzero/positivity facts for well-definedness;
- disjunction/case encodings;
- `prop`, `have fn`, `thm`, `by def`, `by thm`, `obtain`, `by cases`;
- cross-file namespaces and `litex.config` exports.

That is the capability: **Litex is learnable, and the kernel checks that the
learned expression is actually correct.**

## Why Lean is different here

- Lean/Mathlib is excellent for algebra, number theory and combinatorics.
- Plane/analytic geometry lacks a lightweight, unified, ready-made IMO API.
- Mainstream work either skips geometry or builds a separate geometry DSL
  (AlphaGeometry) / dedicated benchmark (LeanEuclid).
- An agent must learn a large library and tactic language before it can state a
  geometry problem in the intended form.

Litex’s geometry is ordinary definitions over `cart(R, R)`. The language is
small, the definitions are readable, and compiler feedback is directly
actionable. That is why a general LLM can get traction.

## The fair claim

**Say:**

> For IMO plane geometry, Litex has a complete agent loop: learn the language,
> define the vocabulary, write the proof, and have a strict kernel check it.
> Lean/Mathlib currently has no equally lightweight, directly reusable loop for
> the same scope; mainstream work skips geometry or builds a separate DSL.

**Do not say:**

> “Lean cannot do geometry at all.” Lean can, with more library engineering.

**Also do not say:**

> “12/12 passed” or “zero human help.” The archive is 11/12; humans constrained
> the process and sometimes told the agent to continue.

## Evidence to show

| Claim | Where |
|---|---|
| 11/12, 14/15, zero trust | `results/imo_runs.md`, `results/imo_runs.csv` |
| Raw strict reports | `evidence/archived_verification_status.json`, `evidence/archived_reports.sha256` |
| Agent learning loop | `MODEL_AND_AGENT.md`, archived `agent_session.log` files |
| Lean/Mathlib gap | `LEAN_VS_LITEX.md` |
| Reproducible new-format code | `code/2D_Geometry/` |

## Cost

≈ 48 hours wall-clock for the 14 verified packages (≈ 59 h including the failed
P20). Individual packages: 26 min to 14 h. Token usage was not recorded in the
archived IMO logs. “Learnable” does not mean “cheap” or “one-shot.”
