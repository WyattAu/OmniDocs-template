---
title: Getting started
description: From clone to deployed docs site.
---

This guide walks the three doors (nix, devcontainers, manual) and the
make targets. Replace the body; keep the structure.

## Gates

| Target | What it does |
|---|---|
| `make build` | `astro build` — Starlight content inspection + static output |
| `make typecheck` | `astro check` |
| `make ci` | contract + fmt-check + lint + typecheck + build |

## Deploy

Pushes to `main` build and deploy to GitHub Pages automatically
(`.github/workflows/deploy.yml`). Enable Pages once with
**Settings → Pages → Source: GitHub Actions**.
