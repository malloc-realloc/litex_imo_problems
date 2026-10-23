# Litex vs. Lean: the IMO geometry engineering gap

This note is only about **formalization and automated proving of IMO plane /
analytic geometry**. It is not a general comparison of the two systems.

> Lean/Mathlib is strongest in algebra, number theory, combinatorics and
> general mathematical library engineering. Plane geometry — points, lines,
> circles, angles, similarity, concyclicity, area ratios — lacks a lightweight,
> unified, ready-to-use IMO pipeline. Mainstream work therefore either skips
> geometry or builds a geometry-specific DSL. Litex’s contribution is that
> geometry is ordinary mathematics in the same language as coordinates,
> inequalities and counting, and the library can be as small as ~7 KB.

## 1. The two mainstream routes

### 1.1 The Lean/Mathlib route

Lean 4 + Mathlib is the main infrastructure for large-scale mathematical
formalization. It is excellent for algebra, number theory, analysis and
combinatorics. But IMO geometry needs an operational layer, not just general
Euclidean-space theory:

- points, lines, segments, rays, circles, angles, similarity, congruence,
  concyclicity, tangency, area ratios;
- nondegeneracy conditions (distinct points, noncollinearity, positive radius,
  nonzero angle arms);
- bridges between coordinate computation and geometric predicates;
- automation for “construction + iff + case split + inequality”.

Mathlib has `EuclideanSpace`, affine spaces and inner-product spaces, but these
are not an out-of-the-box IMO geometry API. Lean can do geometry with enough
library engineering; the barrier for “reproduce one IMO geometry problem
quickly” is high.

### 1.2 The geometry-specific DSL route

AlphaGeometry is the canonical example: it does not hand geometry problems
directly to Lean; it designs a geometry language and a deduction engine, then
trains on synthetic data. That design choice is itself evidence that general
proof assistants do not provide enough ready-made geometry support.

LeanEuclid (“Autoformalizing Euclidean Geometry”, ICML 2024) points at the same
gap from another direction: it builds a dedicated Lean benchmark/library for
Euclidean geometry, formalizing problems from Euclid’s *Elements* and UniGeo.
Needing a dedicated benchmark and library shows that a ready-made Lean geometry
pipeline does not exist.

## 2. What Litex does differently

Litex geometry is not an external DSL. It is ordinary mathematics in the
language:

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

This defines points, vectors, dot product, determinant, squared distance,
collinearity and segment membership. There is no typeclass hierarchy, no
`MeasureTheory`/`Topology` dependency, and no geometry-only syntax. It is sets,
functions and predicates. For IMO geometry, this thinness is a feature:

- **Definitions are visible**: each concept fits in a few lines.
- **Nondegeneracy is explicit**: `a != b`, `0 <= t <= 1`, etc. are part of the
  definition.
- **Coordinates and geometry are one layer**: `vec`/`dot`/`det` are ordinary
  functions; geometric predicates call them directly.
- **The library is small**: the archived geometry library is 200 lines /
  7.3 KB / 39 declarations; the new code distributes definitions into each
  problem package, making each package self-contained.

## 2.5 Agent learnability: the part Lean makes expensive

The archived result is not only “Litex has geometry definitions.” It is also
that **a general-purpose LLM learned those definitions and produced checked
proofs**. The relevant comparison is the learning surface:

| What an agent must learn | Lean 4 + Mathlib | Litex |
|---|---|---|
| Core language | Dependent type theory, universes, typeclasses, tactics | Sets, functions, predicates, facts, proof steps |
| Geometry layer | Mathlib structures + a large search space of lemmas | A small, visible coordinate-based library; definitions can be written locally |
| Error feedback | Lean goals and messages; often requires library/tactic expertise | Structured error with failing statement/goal and phase |
| Trust boundary | Mathlib axioms and implementation details | `-strict` forbids `trust`/user `axiom`; explicit check |
| Agent strategy | Learn a large API and tactic language | Learn a small language, write definitions, iterate on compiler errors |

This is why a general model can get traction in Litex: the language is small,
the geometry layer is explicit, and the compiler feedback is directly actionable.
In Lean, the same agent must first find its way through a much larger library and
tactic surface before it can even state the geometry problem in the intended
form.

## 3. Comparison table

| Dimension | Lean 4 + Mathlib | Litex (this experiment) |
|---|---|---|
| Foundation | Dependent type theory + large Mathlib | Set theory + functions/predicates; geometry via coordinate pairs |
| Ready-made plane geometry API | Euclidean/affine foundations, but no unified IMO-level interface | 39 declarations cover points, lines, circles, angles, similarity, concyclicity, etc. |
| Geometry often skipped? | Common in mainstream Lean IMO work | 11/12 problems strictly verified in this archive |
| Geometry-specific DSL | AlphaGeometry and similar systems build one | Not needed; geometry is ordinary definitions |
| Proof automation | Strong in algebra/number theory; geometry needs manual work/strategies | Coordinate computation + explicit equality chains + case analysis; strict-checkable |
| Trust boundary | Depends on Mathlib axioms/implementation | Strict mode forbids `trust`/`axiom`; 0 trust here |
| Cost | High library engineering + compile cost | 26 min–14 h wall-clock per problem; also expensive |
| Best fit | General mathematical formalization | A lightweight geometry loop with real IMO coverage |

## 4. How to state the “Lean cannot do geometry” point accurately

Inaccurate:

> “Lean cannot do geometry at all, Litex can, so Litex is better overall.”

Accurate:

> “For the concrete engineering task of IMO plane geometry, Lean/Mathlib
> currently has no lightweight, unified, directly reusable loop. Mainstream work
> either skips geometry or builds a separate geometry DSL. Litex used a ~7 KB
> self-built library and one language to verify 11 problems. Lean can do
> geometry with more library engineering, but that is a different cost.”

This framing ties the achievement to **engineering reproducibility and
evidence**, not to an unfalsifiable “system superiority” claim.

## 5. References and further reading

- Trinh, Wu, Le, He, Luong. *Solving olympiad geometry without human
  demonstrations.* Nature 625, 476–482 (2024). AlphaGeometry: geometry-specific
  language + deduction engine, not Lean.
- DeepMind. *AI achieves silver-medal standard solving International
  Mathematical Olympiad problems.* 2024. AlphaProof: the Lean route; geometry
  is handled by a separate system.
- Murphy, Yang, et al. *Autoformalizing Euclidean Geometry.* ICML 2024.
  arXiv:2405.17216. LeanEuclid: a dedicated Lean benchmark for Euclidean
  geometry, showing the missing ready-made pipeline.
- Lean/Mathlib `Mathlib.Geometry.Euclidean.*`: Euclidean-space foundations, not
  an out-of-the-box IMO geometry API.
- `code/2D_Geometry/README.md`: upstream description of the 12 problems, 15
  packages, definitions and proofs.

> Note: these references explain why mainstream work avoids Lean geometry; they
> do not prove “Lean cannot do geometry.” The core evidence here remains the
> Litex strict reports in `results/` and `evidence/`.
