# Upstream source of `2D_Geometry`

- Repository: <https://github.com/litexlang/golitex>
- Path: `showcases/2D_Geometry`
- Tag: `1.1.1-beta`
- Commit: `fd62f2afa5e91e12178126a3a0cf85edceb76c80`
- Commit title: `feat(new): enhance error report, version 1.1.1-beta`
- Copied into this directory: verbatim (no source edits).

The upstream `showcases/2D_Geometry/README.md` says:

> All fifteen packages pass strict verification with Litex 1.0.6-beta, checked at these paths on 2026-10-11.

That claim is upstream’s; this directory records its own measured results separately in `STATUS.md`. The full upstream repository is Apache-2.0; see `LICENSE`.

## Updating

```bash
git clone --depth 1 --branch 1.1.1-beta https://github.com/litexlang/golitex.git /tmp/golitex
rm -rf code/2D_Geometry
cp -R /tmp/golitex/showcases/2D_Geometry code/2D_Geometry
```

If you want the latest `main` instead of the 1.1.1 tag, change the branch to `main`; the directory layout is the same, but the code may have moved on.

## What changed relative to the archived 0.9.x solutions

- `p[1]` indexing became `p(1)` function application.
- Each problem package is self-contained: `solution.lit` includes the definitions it needs, and `litex.config` exports only that package’s files.
- The global 7.3 KB geometry library is no longer required for the IMO packages; `geo.lit` / `geo_definitions.lit` remain as a standalone library entrypoint.
- Some proof steps were rewritten to the newer syntax and to explicit equality chains.
