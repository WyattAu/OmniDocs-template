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

python3 - "$CURRENT" "$((end - start))" <<'PY'
import pathlib
import sys

out = pathlib.Path(sys.argv[1])
build_ms = int(sys.argv[2])
dist = pathlib.Path("dist")
total = sum(p.stat().st_size for p in dist.rglob("*") if p.is_file()) if dist.exists() else 0
if total == 0:
    raise SystemExit(f"bench: nothing built in {dist} - run the build first")
# Shipped bytes are exact, so they gate at 5%. Build wall-clock on a shared
# runner is not: two identical consecutive builds differed by 18-88%, so it is
# recorded and reported, never gated.
out.write_text(
    f"site-bytes\t{total}\tbytes\tgate\n"
    f"build-ms\t{build_ms}\tms\tinfo\n"
)
PY

python3 scripts/compare-bench.py "$BASELINE" "$CURRENT" \
  --threshold-pct "$THRESHOLD_PCT" "${UPDATE[@]+"${UPDATE[@]}"}"
