# Product critique — Product Consulting Harness

**Skill:** /critique · **Repo:** /home/logani/projects/Product Consulting Harness · **When:** 20260806T063218Z

## Method
Structured audit from README + shallow tree. Findings cite paths.

## Product clarity
README present — skim first 80 lines for identity/audience.

## Target user
Infer from README "Who" / audience sections; flag if absent.

## UX / navigation / onboarding
Inspect entry docs and primary UI/docs paths in the tree below.

## Accessibility
Note whether a11y tests or guidance exist in tree.

## Product direction / friction / priorities / risks
Prioritize by impact-per-change. Prefer deletion. Do not rewrite vision.

## Tree (depth 2, truncated)
```
/home/logani/projects/Product Consulting Harness/MEMORY.md
/home/logani/projects/Product Consulting Harness/.gitignore
/home/logani/projects/Product Consulting Harness/README.md
/home/logani/projects/Product Consulting Harness/lib/run-skill.sh
/home/logani/projects/Product Consulting Harness/lib/run-checks.sh
/home/logani/projects/Product Consulting Harness/lib/provider.sh
/home/logani/projects/Product Consulting Harness/lib/github.sh
/home/logani/projects/Product Consulting Harness/lib/harness-checks.sh
/home/logani/projects/Product Consulting Harness/bin/consult
/home/logani/projects/Product Consulting Harness/docs/learning-schema.md
/home/logani/projects/Product Consulting Harness/docs/skills.md
/home/logani/projects/Product Consulting Harness/CONSTITUTION.md
/home/logani/projects/Product Consulting Harness/BENCHMARKS.md
/home/logani/projects/Product Consulting Harness/tests/consult-smoke.sh
/home/logani/projects/Product Consulting Harness/AGENTS.md
/home/logani/projects/Product Consulting Harness/JUDGMENT.md
/home/logani/projects/Product Consulting Harness/ARCHITECTURE.md
```

## README excerpt
```
# Product Consulting Harness

A Product Judgment Layer that turns messy product intent into a clear
improvement mission, executes it, measures the result, and retains what
it learns. The CLI is the interface; judgment lives in modes, evidence,
and a frozen benchmark contract.

## Quickstart

```sh
bin/consult                  # org overview
bin/consult runtime          # detect coding runtimes (agent/claude/codex/…)
bin/consult judge <client>   # mode + mission (also: harness-evolution)
bin/consult checks <client>  # deterministic contract checks
bin/consult harness-checks   # harness-apc objective checks + secrets scan
bin/consult gh preflight     # GitHub auth + permissions (redacted)
bin/consult gh pr-create|status|checks|merge|validate
                             # gated PR workflow (merge needs authorize-merge)
bin/consult bench <client>   # scores + history
bin/consult report <client>  # latest iteration reasoning
bin/consult memory           # durable lessons
bin/consult org              # roles + autonomy
bin/consult smoke            # CLI smoke tests
bin/consult skill critique|benchmark|design-sprint <target>
```

Provider: authenticated Cursor `agent` CLI by default (`CONSULT_PROVIDER` to swap).
Detected runtimes: `bin/consult runtime`. No API keys. No mocks.

GitHub: `bin/consult gh …` wraps `gh` with gates — **never** `--admin` /
force-merge. Merge requires `state/harness-evolution/authorize-merge` (or
`CONSULT_AUTHORIZE_MERGE`).

Learning artifacts: `docs/learning-schema.md` · harness evolution under
`state/harness-evolution/` (locked contract `harness-apc-v1`).

## Product Judgment modes

| Mode | Behavior |
|------|----------|
| **Guided** | Propose high-leverage directions with tradeoffs |
| **Directive** | Follow a user direction; validate risks |
| **Challenge** | Push back with evidence when harm is likely |
| **Override** | Follow an explicit decision; document concerns |

Full text: `JUDGMENT.md`.

## How an engagement runs

1. Brief + mode in `state/engagements/<client>/engagement.md`
2. Freeze `contract.json` + engagement `BENCHMARK-CONTRACT.md` before changes
3. Build measurement tests; record iter-0 baseline
4. Loop (max 5 iterations unless converged earlier):

   Inspect → Measure → Prioritize → Implement → Real tests →
   Re-benchmark → Independently verify → Critique → Memory →
   Safe harness improvements

5. Convergence: every dimension ≥ 9.0 with evidence, verifier OK,
   no unresolved critical/high defects, no material regression.

## Layout

| Path | Purpose |
|------|---------|
| `CONSTITUTION.md` | Principles, autonomy, escalation |
| `AGENTS.md` | Permanent roles |
| `JUDGMENT.md` | Product Judgment modes + temporary specialists |
| `BENCHMARKS.md` | Harness-wide contract v1 (prior engagements) |
| `MEMORY.md` | Durable organizational memory |
| `docs/learning-schema.md` | Harness-evolution learning artifact schema |
| `bin/consult` | CLI |
| `lib/provider.sh` | Provider + runtime detection seam |
| `lib/github.sh` | Gated PR/merge/validate helpers (no `--admin`) |
| `lib/run-checks.sh` | Deterministic checks (`scorer=checks`) |
| `lib/harness-checks.sh` | Harness-apc objective checks + secrets scan |
| `tests/consult-smoke.sh` | CLI smoke |
| `state/` | Engagements, scores, history |
| `state/harness-evolution/` | APC self-improvement (locked `harness-apc-v1`) |
```

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
