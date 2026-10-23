#!/usr/bin/env python3
"""Summarize the archived Litex IMO verification JSONs.

This script reads the original archived run directory (../../IMO/solutions
relative to this file) and emits a compact, auditable status table.  It does
not re-run Litex and does not modify the archive.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ARCHIVE = ROOT / "IMO" / "solutions"
OUT = Path(__file__).resolve().parents[1] / "evidence" / "archived_verification_status.json"

PROBLEM_ID = {
    "problem_1": 1, "problem_2": 2, "problem_3": 3, "problem_4": 4,
    "problem_5": 5, "problem_7": 7, "problem_12": 12, "problem_13": 13,
    "problem_15": 15, "problem_17": 17, "problem_18": 18, "problem_20": 20,
}


def parse_maybe_concat(path: Path):
    text = path.read_text(errors="replace")
    dec = json.JSONDecoder()
    docs, i = [], 0
    while True:
        while i < len(text) and text[i].isspace():
            i += 1
        if i >= len(text):
            break
        try:
            obj, j = dec.raw_decode(text, i)
        except json.JSONDecodeError:
            return {"parse": "error", "text_head": text[:300]}
        docs.append(obj)
        i = j
    return {"parse": "ok", "documents": docs}


def summarize(path: Path):
    parsed = parse_maybe_concat(path)
    if parsed.get("parse") != "ok":
        return {"file": str(path.relative_to(ROOT)), "parse": parsed}
    docs = parsed["documents"]
    first = docs[0] if docs else {}
    ok = all(
        (d.get("success") is True) or (d.get("result") == "success") or (d.get("run_result") == "success")
        or (d.get("verification_status") == "success")
        for d in docs
    ) if docs else None
    trace = first.get("trace", "")
    if not isinstance(trace, str):
        trace = json.dumps(trace)
    return {
        "file": str(path.relative_to(ROOT)),
        "documents": len(docs),
        "all_success": ok,
        "first_result": first.get("result", first.get("run_result", first.get("verification_status", first.get("success")))),
        "first_ok": first.get("ok", first.get("success")),
        "trace_chars": len(trace),
        "trust_mentions_in_trace": trace.count("trust"),
        "error_mentions_in_trace": trace.count('"result": "error"'),
        "strict": "strict" in path.name,
    }


def main():
    rows = []
    for problem_dir in sorted(ARCHIVE.glob("problem_*")):
        pid = PROBLEM_ID.get(problem_dir.name)
        if pid is None:
            continue
        candidates = [problem_dir] + sorted(
            p for p in problem_dir.iterdir() if p.is_dir() and not p.name.startswith(".")
        )
        for solution_dir in candidates:
            files = []
            for name in ("litex_verified.json", "litex_strict.json", "litex_strict_verified.json",
                         "litex_part_a_verified.json", "litex_part_a_strict.json",
                         "litex_part_b_verified.json", "litex_part_b_strict.json",
                         "production_problem20_strict.json"):
                p = solution_dir / name
                if p.exists():
                    files.append(summarize(p))
            if files:
                rows.append({
                    "problem_id": pid,
                    "problem_dir": problem_dir.name,
                    "solution_dir": solution_dir.name if solution_dir != problem_dir else ".",
                    "reports": files,
                })
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({"schema_version": 1, "rows": rows}, indent=2, ensure_ascii=False) + "\n")
    print(f"wrote {OUT} ({len(rows)} solution packages)")


if __name__ == "__main__":
    main()
