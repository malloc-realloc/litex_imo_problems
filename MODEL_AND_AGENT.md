# What the model learned, and why Litex made it possible

This note isolates the part of the experiment that matters for the Litex-vs-Lean
argument: **a general-purpose LLM learned Litex from a short guide and compiler
feedback, then wrote correct definitions and proofs.** The archived verification
reports are the evidence; the current golitex binary’s compatibility with the
example files is a separate, secondary question.

## 1. The model was not a geometry prover

- Models in the logs: mostly `gpt-5.6-sol`, with some sessions also showing
  `claude-opus-4-6`. Both are general-purpose models.
- Neither is AlphaGeometry, a geometry-specific deduction engine, or a model
  fine-tuned on Litex.
- It was given a short Litex guide (`litex_short_guide.md`, about 25 KB), the
  problem statement, the workflow, and the compiler’s structured errors.
- It had to produce actual `.lit` source: definitions, predicates, helper
  theorems, theorem statements and proof bodies.

This is the key point: **Litex was learnable by a general LLM.** The model did
not need a bespoke geometry DSL or a huge Mathlib-style library to get started.

The geometry vocabulary was also not a hand-written Mathlib import. The adjacent
automated definition experiment reports **39/39 definition tasks passed with zero
axiom debt**, and the archived IMO geometry library is the same scale (**39
declarations**). This shows that the vocabulary is small and machine-buildable;
the exact archived file is curated, not byte-identical to the pipeline output.

## 2. The loop: write, compile, read the error, repair

The archived sessions follow a consistent pattern:

1. **Read the guide and the problem.** The agent inspected the Litex syntax
   reference and the geometry library.
2. **Write definitions.** It created local predicates and functions, e.g.
   `is_strictly_inside_segment`, `is_cevian_ratio`, `is_inside_triangle`,
   `is_subtended_tangent`.
3. **Write helper lemmas.** It created `theorem.lit` entries for algebraic
   bounds, determinant factorizations, ratio identities, etc.
4. **Write the main theorem and proof.** It used `thm`, `? forall`, `=>:`,
   `by def`, `by thm`, `obtain`, `by cases`, equality chains and inequality
   chains.
5. **Compile.** The Litex kernel returned a structured error with the failing
   statement, the failed goal and the phase (well-definedness, proof process,
   etc.).
6. **Repair.** The agent changed the proof step, added an intermediate equality,
   or changed the encoding, then reran.
7. **Finish with strict verification.** Strict mode forbids `trust`,
   `trust have` and user `axiom`; the final report is machine-checked.

This is not “the model already knew the proof and typed it once.” The logs show
many failed compilations and targeted repairs per problem.

## 3. Concrete examples of learning Litex

These are representative patterns visible in the archived logs:

- **Explicit equality chains.** The kernel rejected proof steps that jumped over
  algebraic substitutions. The agent learned to expand them into step-by-step
  equalities (`A = B = C`) and rerun.
- **Well-definedness conditions.** Strict mode checks division, square roots and
  function domains. The agent learned to supply nonzero/positivity facts before
  using a division or a geometric function.
- **Disjunction and case analysis.** Three-way disjunctions were not accepted in
  the form first written; the agent switched to a `by cases` encoding and
  completed the proof.
- **Predicate design.** The agent wrote new predicates when the library lacked
  the exact concept, instead of expanding everything into raw coordinates in the
  theorem statement.
- **Cross-file structure.** It learned `litex.config` exports, namespaces
  (`predicate::`, `theorem::`, `geo::`), and the difference between ordinary and
  strict verification.

The important property is that these are **language-level lessons**, not
problem-specific math hints. Once learned, they transfer across problems. That
is exactly what “the model learned Litex” means.

## 4. What the agent produced

For each problem, the archive typically contains:

- `predicate.lit` — new geometric predicates;
- `theorem.lit` — helper lemmas;
- `solution.lit` — the main formal statement and proof;
- `litex.config` — module/export wiring;
- `litex_verified.json` and `litex_strict.json` — machine reports;
- `agent_session.log` — the full prompt/response/tool trace.

The agent was not filling a fixed template with a known proof. It chose the
definitions, the helper lemmas, the proof strategy and the final formal
statement. The kernel then accepted or rejected the result.

## 5. The quantitative result

| Metric | Result |
|---|---|
| IMO geometry problems solved in the archive | **11 / 12** |
| Solution packages passed | **14 / 15** |
| Strict `trust` in passing packages | **0** |
| Wall-clock for the 14 verified packages | **≈ 48 h** |
| Wall-clock including failed P20 | **≈ 59 h** |
| Model type | general-purpose LLMs (`gpt-5.6-sol`, some `claude-opus-4-6`), no Litex fine-tuning |
| Human role | constraints and corrections, not writing the proofs |

Per-problem times and evidence: `results/imo_runs.md`.

## 6. Why this is a Litex advantage over Lean for this task

Lean is a mature proof assistant, but its geometry layer is heavy:

- Mathlib is large; learning the relevant typeclasses, structures and lemmas is
  a significant burden.
- IMO plane geometry does not have a lightweight, unified, ready-made API in
  Mathlib.
- Mainstream Lean IMO work often avoids geometry or uses a separate geometry
  system (AlphaGeometry) / dedicated benchmark (LeanEuclid).
- An LLM must learn a large library and a tactic language before it can produce
  a checkable geometry proof.

Litex’s design reduces the learning surface:

- The language is small: sets, functions, predicates, facts, proofs.
- Geometry is ordinary definitions over `cart(R, R)`, not a separate DSL.
- The compiler errors are structured and point at the failing statement/goal.
- The strict kernel gives a clear trust boundary.
- A general LLM can start from a ~25 KB guide and improve by compiler feedback.

This is the sense in which Litex “has the ability to perform well with models
that are not geometry specialists”: the language and the feedback loop do a lot
of the work.

## 7. Honest caveats

- **The model is not “dumb.”** `gpt-5.6-sol` is a capable general model. The
  claim is “general-purpose, not geometry-specific and not Litex-fine-tuned,”
  not “a weak model solved IMO geometry unaided.”
- **Humans constrained the process.** They forbade `trust`, required
  sentence-by-sentence translation, forbade whole-problem wrappers, and asked
  the agent to continue. Some messages also gave strategic nudges (for example,
  try a case split). They did not write the proof, but “self-learned” here means
  the agent learned the language and wrote/repaired the formal proof; it does not
  mean every strategic choice was autonomous.
- **P20 failed in the archive.** The 11/12 number is the honest one.
- **Cost is high.** Hundreds of model calls and hours of wall-clock per hard
  problem. “Learnable” does not mean “cheap” or “one-shot.”
- **The new-format code is a moving target.** The golitex examples are being
  updated; version-to-version proof-search behavior changes. The agent result is
  evidenced by the archived reports, not by whether today’s binary accepts every
  file unchanged.

## 8. One-sentence takeaway

> Litex gave a general-purpose LLM a small, uniform language in which geometry
> is just definitions and checked facts; the model learned it from a short guide
> and compiler feedback, and produced 14 strict-verified IMO geometry packages.
> That is the capability Lean/Mathlib currently does not expose in a comparably
> lightweight form.
