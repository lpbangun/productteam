# harness-cli iter-1 — report

**Contract:** harness-cli-v1 · **Kind:** iteration · **Overall:** 9.5
**Baseline:** 3.4 → **9.5** · **Converged:** yes (every dimension ≥ 9.0)
**Live:** full (provider + three skills against tmp-projects)

## Diff summary

- `bin/consult` — B&W theme (2 accents), `agents`/`splash`/`onboarding`, checks_runner routing, first-run splash hook, help/dispatch parity
- `lib/provider.sh` — ≥10-agent catalog, beyond-PATH scan, executable guard, versions, JSON
- `lib/splash.sh` — knowledge-graph nodes/edges animation
- `lib/onboarding.sh` — non-interactive cold start
- `lib/run-skill.sh` — real `provider_ask` (no template answers)
- `lib/harness-checks.sh` / `lib/run-checks.sh` — no local ANSI literals; skill evidence reuse
- `lib/theme.sh` — empty defaults for batch runners
- `README.md`, `ARCHITECTURE.md`, `docs/skills.md` — first-run, env vars, CLI wording, live skills
- Measurement (pre-baseline): `lib/harness-cli-checks.sh`, `tmp-projects/{proj-a,proj-b}`

## Scores

| Dimension | Baseline | Iter-1 |
|-----------|----------|--------|
| visual-cli-clarity | 4.0 | 9.5 |
| splash-animation | 2.0 | 9.5 |
| onboarding-ease | 2.0 | 9.5 |
| agent-detection | 2.0 | 9.5 |
| feature-reachability | 4.0 | 9.5 |
| skills-llm-reality | 4.0 | 9.5 |
| documentation | 2.0 | 9.5 |
| developer-experience | 7.0 | 9.5 |
| product-clarity | 4.0 | 9.5 |

## Critic notes

Builder subagent hit Opus usage limit mid-flight; Principal session completed the remaining surface. P8 REPL stayed CUT. No JobOS scope. Critic accept pending Independent Verifier spot-check of `runs/iter-1/checks.json` (49/49 pass, live).

## Org self-review

Temporary specialists (Benchmark Designer, Analyst, Test Engineer, Critic debate, Builder) were enough. No new permanent workers. Measurement scaffold before baseline held the freeze.
