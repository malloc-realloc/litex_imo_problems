# Litex × IMO Plane Geometry: What an Agent Solved, and Why It Matters vs. Lean

This directory is about one question:

> Can a general-purpose LLM learn Litex well enough to write **correct
> definitions** and **machine-checked proofs** for IMO plane geometry — and does
> that show something Lean/Mathlib currently does not?

The short answer is **yes, with clear scope**. In the archived agent experiment,
**11 of 12 IMO geometry problems and 14 of 15 solution packages passed strict
verification with zero `trust`**. The model was not a geometry-specific prover
and was not fine-tuned on Litex; it learned the language from a short guide and
from compiler feedback, then wrote the definitions, lemmas and proofs itself.

**Terminology.** “Without a library” here means **without a pre-existing,
Lean/Mathlib-scale external geometry library**. The agent still built and used a
small internal Litex library (39 declarations, ~7 KB). The new-format code goes
further and embeds the needed definitions in each problem package. This is not a
claim that the proof was written from a completely empty file.

## 1. The headline result

The 12 problems come from `IMO/Math_Problem/problems_natural_language.json`.
The agent worked in Litex **0.9.116-beta**, using a **7.3 KB, 200-line,
39-declaration** geometry library (`IMO/Litex/geo/library_final.lit`) that was
itself built inside Litex from coordinate definitions.

| IMO problem | Theme | Agent result | Strict evidence |
|---|---|---|---|
| 1960 P3 | Right triangle, hypotenuse subdivision, tangent identity | Passed (2 solutions) | strict success, 0 trust |
| 1960 P6 | Cone, inscribed sphere, volume ratio | Passed (2 solutions; one covers part (a)) | strict success, 0 trust |
| 1961 P4 | Interior point, cevian ratios, inequality | Passed | strict summary, 0 errors |
| 1961 P5 | Triangle construction from two sides and a median angle | Passed | strict success, 0 trust |
| 1962 P6 | Circumcenter/incenter Euler relation | Passed (2 solutions) | strict success, 0 trust |
| 1963 P3 | Equiangular polygon with monotone side lengths | Passed | strict success, 0 trust |
| 1966 P6 | Three side points cut off area ≤ 1/4 | Passed | strict success, 0 trust |
| 1967 P1 | Four unit disks cover a parallelogram | Passed | 92/92 strict documents success, 0 trust |
| 1968 P1 | Consecutive integer sides, doubled angle, uniqueness | Passed | strict success, 0 trust |
| 1969 P4 | Semicircle, incircle, two tangent circles | Passed | strict success, 0 trust |
| 1970 P1 | Cevian, inradius/exradius ratio identity | Passed | strict success, 0 trust |
| 1970 P6 | 100 points, at most 70% acute triangles | **Not completed in the archive** | archived strict report is an error |

**11/12 problems, 14/15 packages passed.** The only archive failure was
1970 P6. Per-package status, time and evidence are in
[`results/imo_runs.md`](results/imo_runs.md) and
[`results/imo_runs.csv`](results/imo_runs.csv).

## 2. What the agent actually did

This is the part that matters for the Litex-vs-Lean argument. The agent did not
receive a pre-written geometry library per problem, and it was not a specialized
geometry engine. The loop was:

1. Read a short Litex guide (`litex_short_guide.md`, about 25 KB) and the task.
2. Translate the natural-language statement into Litex definitions and a
   theorem statement.
3. Write helper definitions (`predicate.lit`) and lemmas (`theorem.lit`).
4. Compile with the Litex kernel.
5. Read the structured error, repair the proof step, and rerun.
6. Finish with ordinary and **strict** verification; strict mode forbids
   `trust`, `trust have` and user `axiom`.

The archived logs show the model **learning Litex from errors**, not replaying a
memorized proof script. Examples:

- It initially wrote proof steps that jumped over algebraic substitutions; the
  kernel rejected them; it then expanded the equalities into explicit chains.
- It hit Litex’s disjunction/parse rules, changed the encoding, and reran.
- It learned to use `prop`, `have fn`, `thm`, `by def`, `by thm`, `obtain`,
  `by cases`, and strict-mode well-definedness checks.
- It produced genuinely new local definitions and helper theorems for each
  problem, then had them checked by the kernel.

The logs show general-purpose models (mostly `gpt-5.6-sol`, with some sessions
also using `claude-opus-4-6`), not a geometry prover. That is the point:
**Litex is learnable by a general LLM, and the kernel makes “learned to write
the right expression” checkable.** The adjacent automated definition experiment
reports 39/39 definition tasks passed with zero axiom debt; the archived IMO
library is the same scale (39 declarations). The vocabulary is small and
machine-buildable, not a hand-written Mathlib import.

**Fairness note.** The archived Lean/Litex benchmark contract used the same
general-purpose model (`gpt-5.6-sol`), the same budget and the same task
families for both platforms. The IMO logs likewise show general models, not a
geometry specialist. So the Litex result is not “a stronger model was used”; it
is the language/feedback loop that made the difference.

More detail: [`MODEL_AND_AGENT.md`](MODEL_AND_AGENT.md).

## 3. Why this is the Lean/Mathlib gap

Mainstream IMO formalization/automation splits into two routes:

- **Lean/Mathlib.** Excellent for algebra, number theory and combinatorics.
  Plane/analytic geometry is either skipped or needs substantial extra library
  and automation work. Mathlib has Euclidean/affine foundations, but no
  lightweight, unified, ready-to-use IMO geometry layer for points, lines,
  circles, angles, similarity and concyclicity.
- **Geometry-specific systems.** AlphaGeometry invents a geometry DSL and a
  deduction engine rather than handing geometry directly to Lean. LeanEuclid
  builds a dedicated Lean benchmark/library for Euclidean geometry. Both are
  evidence that a ready-made Lean geometry pipeline is missing.

Litex’s difference is that **geometry is not an external DSL; it is ordinary
mathematics in the same language**:

```litex
have points set = cart(R, R)

have fn vec(A, B cart(R, R)) cart(R, R) = (B(1) - A(1), B(2) - A(2))
have fn dot(u, v cart(R, R)) R = u(1) * v(1) + u(2) * v(2)
have fn det(u, v cart(R, R)) R = u(1) * v(2) - u(2) * v(1)
have fn distance_sq(a, b cart(R, R)) R = dot(vec(a, b), vec(a, b))

prop is_collinear(p, q, r cart(R, R)):
    det(vec(p, q), vec(p, r)) = 0

prop is_on_segment(p, a, b cart(R, R)):
    a != b
    exist t R st {0 <= t, t <= 1,
        p(1) = (1 - t) * a(1) + t * b(1),
        p(2) = (1 - t) * a(2) + t * b(2)}
```

No typeclass hierarchy, no `MeasureTheory`/`Topology` dependency, no
geometry-only syntax. Points, vectors, lines, circles, angles, congruence and
similarity are sets/functions/predicates. The archived geometry library is
200 lines / 7.3 KB; the new-format code goes further and makes every problem
package self-contained.

| Dimension | Lean 4 + Mathlib | Litex (this experiment) |
|---|---|---|
| Geometry layer | Euclidean/affine foundations + a large lemma search space | 39 explicit coordinate definitions; ~7 KB |
| Agent learning surface | Typeclasses, structures, tactics, large library | Small language; definitions readable in a few lines |
| IMO geometry evidence | Mainstream work skips it or uses a separate DSL / benchmark | 11/12 problems, 14/15 packages strict-verified |
| Trust boundary | Mathlib axioms/implementation | `-strict` forbids `trust`/user `axiom`; 0 trust |
| Error feedback | Lean goals/messages; needs library/tactic expertise | Failing statement/goal + phase; directly actionable |
| Cost | High library/compile cost | High wall-clock cost, but a small learning surface |

The defensible claim is:

> For IMO plane geometry, Litex has a complete loop: a general LLM can learn the
> language, define the vocabulary, write the proof, and have a strict kernel
> check it. The Lean/Mathlib ecosystem currently has no equally lightweight,
> directly reusable loop for the same scope; mainstream work either skips
> geometry or builds a separate geometry DSL.

The claim should **not** be “Lean is incapable of geometry in principle.” Lean
can formalize geometry with more library engineering. This is a comparison of
**engineering reproducibility and agent learnability**, not kernel capability.

## 4. Evidence and trust boundary

- Archived strict reports are indexed in
  [`evidence/archived_verification_status.json`](evidence/archived_verification_status.json),
  generated by [`tools/summarize_archived_runs.py`](tools/summarize_archived_runs.py).
- The strict traces contain **0** `trust` mentions. Ordinary traces contain one
  expected “imported module not verified in ordinary mode” warning; that is not
  a proof step and disappears in strict mode.
- Raw report hashes: [`evidence/archived_reports.sha256`](evidence/archived_reports.sha256).
- The one archive failure (1970 P6) is reported as a failure, not hidden.

## 5. Cost and model behavior

- **Time.** The 14 verified packages sum to roughly **48 hours of wall-clock
  time**; including the unfinished P20, roughly **59 hours**. Individual
  packages range from 26 minutes to 14 hours. See `results/imo_runs.csv`.
- **Turns.** The logs show hundreds of model calls on the harder problems (for
  example, about 467 visible prompt/response pairs for 1963 P3, 400 for 1967 P1,
  and 283 for 1961 P4). This is an error-feedback loop, not one-shot generation.
- **Tokens.** The archived IMO logs do **not** record API token usage. This
  directory does not invent token counts; see
  [`results/token_availability.md`](results/token_availability.md).
- **Human role.** Humans corrected constraints (forbid `trust`, require
  sentence-by-sentence translation, forbid whole-problem wrappers) and sometimes
  asked the agent to continue. This is “AI formalization under strict human
  constraints,” not an unsupervised mathematician.

## 6. Where the code is

The readable new-format code is a complete copy of upstream
`litexlang/golitex` `showcases/2D_Geometry` (tag `1.1.1-beta`, commit
`fd62f2a`):

```
code/2D_Geometry/
├── README.md                 # upstream description: 12 problems, 15 packages
├── geo.lit                   # 227 declarations: 40 definitions + 186 theorems + distance
├── geo_definitions.lit       # 40 foundational definitions
├── IMO/problem_1/ ...        # self-contained package per problem
└── IMO/problem_20/           # includes the later P20 proof
```

This code is the **reading/reproduction reference**. The authoritative evidence
for the agent result is the archived strict reports, not whether a particular
current golitex binary happens to accept every file today. The upstream code is
being updated; version-compatibility measurements are kept separately in
[`code/STATUS.md`](code/STATUS.md) and are not the headline.

Legacy 0.9.x code used `p[1]`; new code uses `p(1)` and embeds definitions in
each package:

```litex
# Legacy (0.9.x)
have fn vec(A, B cart(R, R)) cart(R, R) = (B[1] - A[1], B[2] - A[2])

# New (1.x)
have fn vec(A, B cart(R, R)) cart(R, R) = (B(1) - A(1), B(2) - A(2))
```

Verify one package:

```bash
cd litex_geo_imo/code/2D_Geometry
litex -strict -r IMO/problem_12
```

`tools/verify_all.sh` runs every package; `tools/build_litex.sh` builds a pinned
Litex tag from source. The archived 0.9.116 library is kept in
`code/legacy/` for provenance only.

**Version note.** Toolchain compatibility of the example files is tracked
separately in `code/STATUS.md`. It is a snapshot of the current binaries, not a
verdict on the agent result; the golitex examples are expected to be updated.

## 7. Limits of the conclusion

1. **Not “zero library.”** The archive used a 7.3 KB, 39-declaration Litex
   geometry library. The new code distributes definitions into each package.
   Both are small and self-built, not Lean/Mathlib-scale external libraries.
2. **Not “zero human intervention.”** The logs show human constraints and
   corrections. The achievement is that the agent wrote and repaired the
   formal proofs, not that no human was involved.
3. **P20 failed in the archive.** Do not write 12/12 for the archived run. The
   new-format code contains a later P20 proof; its measured status is in
   `code/STATUS.md`.
4. **Lean is not at zero capability.** Lean can formalize geometry with more
   library work. The fair claim is about the missing lightweight, unified,
   ready-made pipeline and the agent-learnability of Litex.
5. **The cost is high.** Tens of minutes to more than ten hours per problem.
   “Can do it” does not mean “cheap” or “stable.”

## 8. Directory map

```
litex_geo_imo/
├── README.md                  # this file
├── CONCLUSIONS.md             # claims, evidence, counterexamples and scope
├── LEAN_VS_LITEX.md           # detailed Lean/Mathlib vs Litex comparison
├── PRESENTATION.md            # one-page, slide-ready summary
├── MODEL_AND_AGENT.md         # what the model learned, how the loop worked
├── results/
│   ├── imo_runs.md            # archived per-problem table
│   ├── imo_runs.csv           # machine-readable version
│   ├── local_verification_*.tsv  # local checks of the new-format code (secondary)
│   └── token_availability.md  # why per-problem tokens are missing
├── data/
│   └── imo_problems.json      # the 12 IMO statements used by the runs
├── evidence/
│   ├── archived_verification_status.json  # machine index of archived strict reports
│   └── archived_reports.sha256            # hashes of raw reports
├── code/
│   ├── 2D_Geometry/           # upstream 1.1.1-beta new-format code
│   ├── legacy/                # 7.3 KB 0.9.x library, archival only
│   ├── STATUS.md              # measured version compatibility (secondary)
│   └── LICENSE                # Apache-2.0
└── tools/
    ├── build_litex.sh         # build a pinned Litex tag
    ├── verify_all.sh          # strict-verify every package
    └── summarize_archived_runs.py  # regenerate archived-evidence index
```
# litex_imo_problems
