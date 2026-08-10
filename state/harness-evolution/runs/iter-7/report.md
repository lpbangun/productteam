# Harness evolution — iter 7

## Scope

Visual CLI items 9–14: grouped check progress, persistent Product Judgment badge, honest blocking/partial-output affordance, live slash-prefix hints, timestamped transcript export, and engagement score sparkline.

## Diff summary

- `lib/run-checks.sh`: collapsed 40 check rows into one live progress line and one JSON-derived final summary.
- `lib/repl.sh`: added Judgment/score chrome, honest interrupt cleanup, canonical slash palette, timestamped transcript, and `/export`.
- `tests/visual-cli.sh` and `state/harness-evolution/visual-contract.json`: extended the frozen executable contract from 8 to 14 criteria.
- `README.md` and `ARCHITECTURE.md`: documented the visible behavior and plain-file session layout.

## Iterations

1. 12/14. Interrupt PTY drain starved the SIGINT window; `/help` was outside the canonical verb array.
2. 14/14. Full harness then exposed non-allowlisted `setsid`/`pgrep` and a parser-visible case-pattern command token.
3. 14/14. Replaced external process-group tools with Bash job control; full harness dependency policy became green.
4. 14/14 final. Strengthened the interrupt probe to assert provider and child PID death plus post-interrupt wording; isolated `/c` from `/ch` in the palette probe.

## Verification

- `visual-checks-final.json`: visual-cli-v2 14/14, live provider proof pass, converged=true.
- `harness-cli-final/checks.json`: harness-cli-v1 49/49, overall 9.5, kind=full.
- The visual benchmark drove real PTY chat sessions, a real temporary provider executable, Ctrl+C, `/export`, history spark rendering, and the real OFC check runner fixture.

## Decision

Converged in four iterations. No architecture, security, autonomy-policy, or permanent-worker change.
