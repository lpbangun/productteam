# learning.md — skills-vector-2026-08-06

## What worked
- README + `docs/goal-loop.md` + `domain.py`/`workflow.py` were enough to infer product, users, and hard boundaries without harness engagement history.
- Highest leverage was a **domain invariant hole**, not DX chrome: briefs could omit the medium-term horizon and collide claim ids while still constructing.
- README verification path (`uv` + unittest + compileall) is the real gate; installing `uv` locally unblocked an otherwise clean offline suite.

## What was constrained / risky
- Minimal context invites over-building (providers, sample data, UI). Stop condition in goal-loop correctly steers away.
- `HUMAN_GATED_CHANGES` remains a named constant with set-equality tests only—not wired into a callable gate. Deferred deliberately to keep one coherent change.
- Starter skill-generated benchmark under `state/validations/skills-vector/benchmark/` was too generic; this run locked a tailored contract under `skills-vector-2026-08-06/`.

## Carry forward
- Prefer product-rule enforcement in `validate_brief` over new modules when the MVP is “one brief contract.”
- Always PR-only for frozen validation runs; never merge from the Implementation agent.
- Record lock SHA256 before implementation; keep evidence paths absolute under the validation dir.
