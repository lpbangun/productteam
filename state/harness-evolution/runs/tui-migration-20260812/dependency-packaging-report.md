# Dependency and packaging report

## OpenTUI

Pinned direct runtime dependencies: `@opentui/core==0.5.2`, `@opentui/solid==0.5.2`, `@opentui/keymap==0.5.2`, `solid-js==1.9.12`; dev: TypeScript 5.8.3 and bun-types 1.3.14. Exact `bun.lock` present. Installed tree: 124,379,136 allocated bytes and 111 unique package/version entries. Audit-clean package output: externalized 25.47 KB `main.js` plus source manifest archive; 65,536 allocated bytes total. Runtime still requires Bun and external OpenTUI/Solid dependencies, including platform-native OpenTUI core.

## Textual

Pinned direct runtime dependencies: `textual==8.2.8`, `rich==15.0.0`; dev: pytest 8.4.2, pytest-asyncio 1.3.0, pytest-textual-snapshot 1.1.0. Exact `uv.lock` present. Installed tree: 38,866,944 allocated bytes and 19 unique distributions. Source zip plus manifest: 28,672 allocated bytes; the zip is not a standalone runtime and requires the locked Python environment.

## Comparison limit

The frozen measurement runner did not produce installed/package measurements because the generated proxy became non-executable. Values above are deterministic static calls through the frozen `measure.py` helpers, not a completed benchmark measurement record. No startup, RSS, or replay-latency ratio exists.
