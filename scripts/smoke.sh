#!/usr/bin/env bash
# Post-build smoke gate: the docs site's "unit test" is that the built site is
# complete and internally consistent.
#
# Checks, in order of how embarrassing each is to get wrong:
#   1. the pages that must exist do (landing, 404, sitemap);
#   2. every internal link/asset referenced from the built HTML resolves to a
#      file in dist (a broken guide link ships to users otherwise);
#   3. no HTML page is an empty stub.
set -euo pipefail
cd "$(dirname "$0")/.."
DIST="${DIST:-dist}"

if [ ! -f "$DIST/index.html" ]; then
  echo "smoke: no build output at $DIST - building first"
  bun run build >/dev/null
fi

fail=0

for required in index.html 404.html sitemap-index.xml; do
  if [ ! -f "$DIST/$required" ]; then
    echo "smoke: FAIL - missing $required" >&2
    fail=1
  fi
done

# Internal references: href="..." and src="..." must exist under dist.
# The site builds with Astro's `base` (GitHub Pages project path), so built URLs
# carry that prefix - read the same value the build used and strip it before
# resolving. External (http/https), mailto, anchor-only and data: refs skipped.
BASE="$(sed -n "s/.*base:[ '\"]*\([^'\"]*\).*/\1/p" astro.config.mjs | head -1)"
BASE="${BASE%/}"
broken="$(
  python3 - "$DIST" "$BASE" <<'PY'
import pathlib
import re
import sys

dist = pathlib.Path(sys.argv[1])
base = sys.argv[2].rstrip("/")
pattern = re.compile(r'(?:href|src)="([^"#?]*?)(?:[?#].*)?"')
broken = []
seen = set()
for page in sorted(dist.rglob("*.html")):
    for target in pattern.findall(page.read_text(errors="replace")):
        if target.startswith(("http://", "https://", "mailto:", "data:", "#")):
            continue
        if base and target.startswith(base):
            target = target[len(base):] or "/"
        if not target.startswith("/"):
            continue
        if target in seen:
            continue
        seen.add(target)
        candidate = dist / target.lstrip("/")
        if not (candidate.is_file() or (candidate / "index.html").is_file()):
            broken.append(f"  {page.relative_to(dist)} -> {target}")
if broken:
    print("\n".join(broken))
sys.exit(1 if broken else 0)
PY
)" || fail=1
[ -z "$broken" ] || {
  echo "smoke: FAIL - broken internal references:" >&2
  printf '%s\n' "$broken" >&2
}

stubs="$(find "$DIST" -name '*.html' -size -200c | head -5 || true)"
if [ -n "$stubs" ]; then
  echo "smoke: FAIL - suspiciously empty pages:" >&2
  printf '%s\n' "$stubs" >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "smoke: FAIL" >&2
  exit 1
fi

pages="$(find "$DIST" -name '*.html' | wc -l)"
echo "smoke: OK - $pages pages, all internal references resolve"
