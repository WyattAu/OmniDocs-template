#!/usr/bin/env bash
# Non-nix fallback. Canonical env: flake.nix (bun + node).
set -euo pipefail
cat <<'MSG'
Manual toolchain (no nix):
  1. bun >= 1.1 (https://bun.sh) + Node 22 (astro check / sharp)
  2. bun install && bun run build
  3. make ci
Prefer zero setup? Open the repo in a devcontainer, or `nix develop`.
MSG
