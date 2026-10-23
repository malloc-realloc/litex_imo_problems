#!/usr/bin/env bash
# Strict-verify every self-contained IMO package in code/2D_Geometry.
# Usage: tools/verify_all.sh /path/to/litex [timeout-seconds]
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="${1:-litex}"
PER_PKG_TIMEOUT="${2:-900}"
CODE="$ROOT/code/2D_Geometry"
TIMEOUT_BIN="timeout"
command -v gtimeout >/dev/null 2>&1 && TIMEOUT_BIN="gtimeout"
VER="$("$BIN" -version 2>&1 | head -1 | tr -cs 'A-Za-z0-9._-' '_')"
OUT="$ROOT/results/local_verification_${VER}.tsv"
mkdir -p "$ROOT/results"

echo "== $("$BIN" -version 2>&1 | head -1) =="
printf 'package\tstatus\tseconds\tfirst_error\n' | tee "$OUT"

while IFS= read -r cfg; do
  dir="$(dirname "$cfg")"
  rel="${dir#$CODE/}"
  start=$(date +%s)
  log="$(mktemp)"
  "$TIMEOUT_BIN" "$PER_PKG_TIMEOUT" "$BIN" -strict -r "$dir" >"$log" 2>&1
  rc=$?
  elapsed=$(( $(date +%s) - start ))
  status="$(python3 - "$log" "$rc" <<'PY'
import json,sys
path,rc=sys.argv[1],int(sys.argv[2])
text=open(path,errors='replace').read()
if rc==124:
    print('timeout'); sys.exit()
try:
    d=json.loads(text)
except Exception:
    print('parse_error'); sys.exit()
ok = d.get('success') is True or d.get('run_result')=='success' or d.get('result')=='success'
print('pass' if ok else 'fail')
PY
)"
  err="$(python3 - "$log" <<'PY'
import json,sys
try:
    d=json.loads(open(sys.argv[1],errors='replace').read())
except Exception:
    print(''); sys.exit()
term=d.get('termination') or {}
fails=term.get('failed_statements') or []
print((fails[0].split('\n')[0] if fails else term.get('message',''))[:160].replace('\t',' '))
PY
)"
  printf '%s\t%s\t%s\t%s\n' "$rel" "$status" "$elapsed" "$err" | tee -a "$OUT"
  rm -f "$log"
done < <(find "$CODE/IMO" -name litex.config -print | sort)

echo "== summary =="
awk -F'\t' 'NR>1{c[$2]++} END{for(k in c) print k, c[k]}' "$OUT"
echo "details: $OUT"
