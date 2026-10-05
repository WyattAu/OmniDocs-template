#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec bunx biome check --write .
