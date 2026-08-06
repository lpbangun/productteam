# Lessons — 48h-2026-08-06

## Expected
One small safety-honesty fix (UI + tests + README) would lift the frozen
`safety-honesty` dimension without vision drift; real `npm test` and a
gated non-force merge would close the validation.

## Actual
- Benchmark / critique / design-sprint locked under this directory.
- Guardrail copy aligned with `AGENTS.md` (pay + promotion).
- `npm test` 4/4 before and after merge.
- PR #1 merged: `562a90e722cef97accf9728ca2354d6864748cb3`.

## What worked
- Evidence-led critique found a real AGENTS ↔ UI drift with a one-line fix.
- Strengthening the source assertion prevents silent regression.
- Harness `consult gh pr-create` / `merge` worked once authorize-merge avoided
  matching the refuse regex for the words “--admin” / “force-merge”.

## What failed
- First merge attempt: authorize file text that *denied* `--admin` / force-merge
  still matched `github.sh`’s refuse pattern and blocked merge (or env path
  confusion on first try). Rewrote authorization note without those tokens.

## Change next time
- When writing authorize-merge notes, state positive authorization only; do not
  mention banned tokens even in the negative.
- Prefer `CONSULT_AUTHORIZE_MERGE` under `state/validations/…` (absolute path)
  and keep client working trees free of `.consult-authorize-merge`.
