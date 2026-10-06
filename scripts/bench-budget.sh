#!/usr/bin/env bash
# Perf budget gate: measure, emit bench/current.tsv, compare to the committed
# baseline with the shared comparator. `make bench-update` re-baselines
# deliberately - it is the only way a baseline moves.
set -euo pipefail
cd "$(dirname "$0")/.."
BASELINE=bench/baseline.tsv
CURRENT=bench/current.tsv
THRESHOLD_PCT="${OMNI_BENCH_THRESHOLD_PCT:-5}"
UPDATE=()
[ "${1:-}" = "--update" ] && UPDATE=(--update)
mkdir -p bench

# For a site template the honest metrics are what users feel: shipped bytes and
# how long the build takes. Microbenchmarks of trivial components would be noise
# on shared runners, so they are deliberately absent here (see the ADR).
now_ms() {
  python3 -c 'import time; print(int(time.time() * 1000))'
}

start="$(now_ms)"
bun run build >/dev/null
end="$(now_ms)"

python3 - "$CURRENT" "$((end - start))" <<'PYBODY'
import pathlib
import sys

out = pathlib.Path(sys.argv[1])
build_ms = int(sys.argv[2])
dist = pathlib.Path("dist")
if not dist.exists():
    raise SystemExit(f"bench: {dist} does not exist - the build did not run")

# Total shipped bytes plus a per-type breakdown, so when the budget trips the
# report says *what* grew instead of only that something did.
buckets = {"js": 0, "css": 0, "html": 0, "other": 0}
for path in dist.rglob("*"):
    if path.is_file():
        suffix = path.suffix.lstrip(".").lower()
        buckets[suffix if suffix in buckets else "other"] += path.stat().st_size

total = sum(buckets.values())
if total == 0:
    raise SystemExit(f"bench: {dist} is empty - the build produced nothing to measure")

lines = [
    f"site-bytes\t{total}\tbytes\tgate",
    f"site-bytes/js\t{buckets['js']}\tbytes\tgate",
    f"site-bytes/css\t{buckets['css']}\tbytes\tgate",
    f"site-bytes/html\t{buckets['html']}\tbytes\tgate",
    f"site-bytes/other\t{buckets['other']}\tbytes\tgate",
    # Build wall-clock on a shared runner is not gateable (18-88% swings across
    # identical runs); it is recorded so a trend is visible in the baseline.
    f"build-ms\t{build_ms}\tms\tinfo",
]
out.write_text("\n".join(lines) + "\n")
PYBODY

python3 scripts/compare-bench.py "$BASELINE" "$CURRENT" \
  --threshold-pct "$THRESHOLD_PCT" "${UPDATE[@]+"${UPDATE[@]}"}"
