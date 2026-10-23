#!/usr/bin/env bash
# Build a pinned Litex release from source.
# Usage: tools/build_litex.sh [tag] [output-dir]
#   tag defaults to 1.0.6-beta (the version named in the upstream 2D_Geometry README).
set -euo pipefail

TAG="${1:-1.0.6-beta}"
OUT_DIR="${2:-$(cd "$(dirname "$0")/.." && pwd)/.litex-build/$TAG}"
mkdir -p "$OUT_DIR"

if [[ -x "$OUT_DIR/litex" ]]; then
  echo "already built: $OUT_DIR/litex"
  "$OUT_DIR/litex" -version
  exit 0
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
echo "cloning litexlang/golitex at $TAG ..."
git clone --depth 1 --branch "$TAG" https://github.com/litexlang/golitex.git "$TMP/src"
echo "building (release) ..."
( cd "$TMP/src" && cargo build --release )
cp "$TMP/src/target/release/litex" "$OUT_DIR/litex"
chmod +x "$OUT_DIR/litex"
echo "built: $OUT_DIR/litex"
"$OUT_DIR/litex" -version
