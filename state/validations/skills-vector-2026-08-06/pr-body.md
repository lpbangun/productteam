## Summary

- Tighten `validate_brief` so a role brief must include **both** near-term (`0_to_12_months`) and medium-term (`12_to_36_months`) scenarios.
- Reject duplicate claim ids so evidence-led drafts stay referentially sound.
- Extend offline domain contract tests; record the increment in `docs/goal-loop.md`.

## Why

Occupational briefs that only describe the next year (or collide claim ids) undercut the private-first People Ops MVP promise of time-bound, inspectable role uncertainty—without expanding into providers, UI, or schedulers.

## Test plan

- [x] `uv venv .venv && uv pip install --python .venv/bin/python -e .`
- [x] `.venv/bin/python -m unittest discover -s tests -v` (16 OK)
- [x] `.venv/bin/python -m compileall -q src tests`

## Status

**PR-only — do not merge.** Opened by Product Consulting Harness validation run `skills-vector-2026-08-06`.
