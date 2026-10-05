# 0002 — Starlight on Astro, deploy from main

Date: 2026-10-04

## Status

Accepted

## Context

The estate's doc sites (starlight-sites, engineering-standards site) are
Astro Starlight with bun; a docs template should match them exactly.

## Decision

- Starlight provides the theme, sidebar, search, i18n hooks; content is
  MDX/Markdown in `src/content/docs/`.
- Deploys are continuous from `main` to GitHub Pages — docs have no
  versioning choreography (docs are versioned by git, not by releases).
- Custom estate theming enters through Starlight's `customCss` hook
  (`src/styles/custom.css`).

## Consequences

- Zero release ceremony: merge = live docs.
- Estate design tokens propagate by copying the token CSS block.
