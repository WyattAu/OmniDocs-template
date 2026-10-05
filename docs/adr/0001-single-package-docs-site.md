# 0001 — Single-package docs site (monorepo exception)

Date: 2026-10-04

## Status

Accepted

## Context

The Omni family is monorepo-first (contract #3), but a documentation site
has exactly one deployable unit and no internal reuse surface.

## Decision

OmniDocs is a single bun package: no workspaces, no internal-dependency
demo. The rest of the Omni Core Contract applies unchanged (scripts
canonical, flake, dual devcontainers, gates, bitrot cron).

## Consequences

- Simplest possible pipeline for docs; contract deviation is documented,
  bounded, and reversible if the site ever grows apps.
