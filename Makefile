# Thin wrapper over scripts/ — the same verbs in every Omni template.
.PHONY: bench bench-update repro build test lint fmt fmt-check typecheck contract ci clean

build:
	./scripts/build.sh

test:
	bun run test

lint:
	./scripts/lint.sh

fmt:
	./scripts/fmt.sh

fmt-check:
	bunx biome check .

typecheck:
	./scripts/typecheck.sh

contract:
	./scripts/check-contract.sh

## What CI gates before merge (mirror of .github/workflows/ci.yml):
ci: contract fmt-check lint typecheck build

repro:
	./scripts/repro-check.sh

bench:
	./scripts/bench-budget.sh

bench-update:
	./scripts/bench-budget.sh --update

clean:
	rm -rf dist .astro node_modules
