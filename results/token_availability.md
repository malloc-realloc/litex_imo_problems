# Token-usage availability

## Short answer

**Per-IMO-problem token usage is not available.** The archived IMO session logs record prompts, responses, tool calls and verification output, but they do **not** record the API usage object (`prompt_tokens`, `completion_tokens`, `total_tokens`). Therefore this directory does not report fabricated token counts.

## What was checked

The following fields/patterns were searched in the archived logs:

- `prompt_tokens`
- `completion_tokens`
- `total_tokens`
- `input_tokens`
- `output_tokens`
- `token_usage`
- `usage_metadata`

The only matches were either (a) source-code snippets that mention these names, (b) the agent auditing whether such fields existed, or (c) unrelated text. No numeric usage record was found.

One archived session explicitly states this (IMO 1960 P6 / problem 2): the log interval is 1,573 seconds (26 min 13 s), but the log contains no numeric `prompt_tokens`, `completion_tokens` or `total_tokens`, so the agent refused to infer token counts from log size.

## The only reliable token data in the parent workspace

The adjacent automatic geometry-library construction experiment did record API usage. It is **not** per-IMO-problem data:

| Experiment | Success | Wall-clock | Total tokens | Axiom debt |
|---|---:|---:|---:|---:|
| 39 definition tasks, before guide/retry improvements | 35/39 (89.7%) | 135.9 min | 744,996 | 0 |
| 39 definition tasks, after guide/retry improvements | 39/39 (100%) | 37.8 min | 562,910 | 0 |
| First 5 theorem tasks (smoke test) | 5/5 (100%) | 0.8 min | 25,361 | 0 |

Source: `../../litex_auto_build_system/litex_auto_validated_250tasks/definitions_only/COMPARISON.md` and `SUCCESS_SUMMARY.md`, plus `THEOREM_CONFIG_SUMMARY.md`.

These numbers show that token accounting is technically possible in the automated pipeline. The IMO runs used a different interactive harness that did not persist usage. A future rerun should log the API usage object per turn if token cost is a first-class metric.

## Recommendation for future runs

Record, for every model call:

```json
{
  "problem_id": 12,
  "turn": 37,
  "model": "gpt-5.6-sol",
  "prompt_tokens": 0,
  "completion_tokens": 0,
  "total_tokens": 0,
  "wall_clock_seconds": 0
}
```

Then aggregate per problem. Without this, wall-clock time and log size are the only available cost proxies, and neither is a token count.
