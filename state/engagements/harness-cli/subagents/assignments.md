# Subagent assignments — harness-cli 2026-08-07

Product under score: the Product Consulting Harness **CLI** (`bin/consult`).
Contract: `harness-cli-v1` — FROZEN 2026-08-07, 9 dimensions, 49 checks,
target 9.0 per dimension, max 6 iterations (iter-0 baseline + 5).

| Specialist | Status | Output |
|------------|--------|--------|
| Benchmark Designer | **done** | froze `harness-cli-v1`: `BENCHMARK-CONTRACT.md`, `contract.json`, `checks/CHECK-CATALOG.md`, `proposed-benchmark-changes.md` |
| Repository Analyst | **done** | `subagents/repository-analyst.md` — CLI surface, gaps G1–G9, risks, smallest-diff sketch |
| Critic (priority debate) | **done** | `subagents/critic-priority-debate.md` — P1–P7 survive (P6 split/redistributed), P8 cut (no benchmark backing, architecture-escalation risk), missing-P0 baseline-scaffold blocker flagged, 5-iteration sequencing recommended |
| Implementation Agent | **done*** | iter-1 CLI surface (*Opus usage limit mid-flight; Principal finished) → 49/49 |
| Test Engineer | **done** | `lib/harness-cli-checks.sh` (all 49 ids), `tmp-projects/proj-{a,b}` + `GUIDANCE.md`, `checks/claim-map.json`; iter-0 measured live (`kind:full`) |
| Independent Verifier | **done** | iter-1 `checks.json` 49 pass / 0 fail / live; ACCEPT |
| Harness Critic | **done** | `runs/iter-1/critic-verdict.md` · CONVERGED 3.4→9.5 |

## Benchmark Designer handoff (2026-08-07)

Frozen dimensions: `visual-cli-clarity`, `splash-animation`,
`onboarding-ease`, `agent-detection`, `feature-reachability`,
`skills-llm-reality`, `documentation`, `developer-experience`,
`product-clarity`.

Blocking deliverables for iter-0 (measurement-only, allowed before
baseline — must not change CLI behavior):

1. `lib/harness-cli-checks.sh` emitting all 49 ids to
   `runs/iter-0/checks.json`, exit non-zero on any failure.
2. `tmp-projects/proj-a` and `tmp-projects/proj-b` — deliberately
   different language and domain, disjoint source filenames, each with a
   `GUIDANCE.md`.
3. Claim→check mapping file under `checks/` for `no-overclaim`.

Checks needing real `agent` LLM calls: `provider-live-answer`,
`skill-critique-live-project-a`, `skill-benchmark-live-project-b`,
`skill-design-sprint-live`, `skills-outputs-project-specific`.
A run with any of these skipped is `partial` and cannot converge.
Live checks must **not** be added to `tests/consult-smoke.sh` — smoke stays
provider-free and instant (`MEMORY.md`; `tests/consult-smoke.sh:48`).

Alignment with the Repository Analyst: gaps G1–G9 all land inside the frozen
dimensions. G2 (skills emit templates, never call `provider_ask`) is the
`skills-llm-reality` gate `skill-uses-provider-seam`; G5 is
`visual-cli-clarity`; G3/G6 are `onboarding-ease` + `agent-detection`;
G4 is `splash-animation`; G8/G9 are `feature-reachability`. Its escalation
warning (no Node/Go TUI framework) is enforced by `no-new-runtime-deps` and
by contract invariant 1. Frozen tmp-project names are `proj-a` / `proj-b`,
not the analyst's `proj-alpha` / `proj-beta`.

## Test Engineer handoff (2026-08-07)

Measurement-only scaffold, added before baseline. No `bin/consult` behavior was
changed: no new command, no theme edit, no skill provider wiring.

Delivered:

1. `lib/harness-cli-checks.sh` — `bash lib/harness-cli-checks.sh <iter-dir>`.
   Emits all 49 frozen ids to `<iter-dir>/checks.json` with per-dimension band
   scores from `contract.json`, archives evidence under `<iter-dir>/evidence/`,
   and exits non-zero unless every check passes.
   - `CONSULT_SKIP_LIVE=1` records the 5 LIVE ids `fail` + `"skipped": true`
     and sets `kind: "partial"` — never converges.
   - `CONSULT_CHECKS_PROBE=1` is a self-test: all 49 ids fail deliberately and
     the runner exits 1. This is how `harness-cli-checks-runner` proves the
     writer and exit code are honest without recursing.
   - Not invoked from `tests/consult-smoke.sh`; smoke stays provider-free.
2. `tmp-projects/proj-a` — Node/ESM, coastal tide forecasting for harbour
   pilots (`src/tideWindow.js`, `src/harbourPilotBrief.js`).
   `tmp-projects/proj-b` — Python 3.11 stdlib, greenhouse irrigation
   scheduling (`irrigation/transpiration_model.py`,
   `irrigation/valve_schedule.py`). Disjoint source filenames; each
   `GUIDANCE.md` declares `Language:`/`Domain:` and lists what a skill should
   evaluate. Guidance terms used by the live skill checks are *derived* (terms
   in one guidance file and in neither the other nor `lib/run-skill.sh`), so a
   template cannot satisfy them by accident.
3. `checks/claim-map.json` — 22 claim rows for `no-overclaim`. A row activates
   only when its `marker` is present in its `source` (`README.md`, `docs/*`, or
   the literal `help`), so rows for capabilities the mission will add (splash,
   onboarding, `agents`) are pre-registered and self-activate on the commit that
   makes the claim. 16 rows were active at iter-0.

Baseline recorded in `runs/iter-0/checks.json` (`kind: "full"`,
`live_executed: true`, real `agent` runtime): **15 pass · 34 fail · 0 skip**,
overall 3.4. Eight of the nine dimensions have a failing gate, so only
`developer-experience` scores above the gate cap (7.0); the rest sit at 2.0–4.0.

Gates passing (6): `cli-no-color-clean`, `detect-command-exists`,
`every-command-exits-zero`, `provider-live-answer`, `smoke-green`,
`harness-cli-checks-runner`. Gates failing (12): `cli-plain-pipe-safe`,
`splash-command-exists`, `splash-bounded-noninteractive`,
`onboarding-command-exists`, `onboarding-cold-start`,
`detect-no-false-positive`, `help-lists-every-command`,
`skill-uses-provider-seam`, `no-mock-provider`, `readme-matches-cli`,
`docs-no-stale-paths`, `no-overclaim`.

Note for the Analyst: `contract.json` declares **18** gate ids across the nine
dimensions; the `CHECK-CATALOG.md` index table totals them as 16. The runner
uses `contract.json`, which is the machine-readable source.

Side effects found and contained (a scoring run now leaves zero tracked churn
and does not touch any sibling repo — verified with `git status` before/after):

- `tests/consult-smoke.sh` runs `consult checks onboarding-flight-control`,
  which builds the **sibling** client repo and leaves `tsconfig.tsbuildinfo`
  modified there. That is critical failure #6. The runner therefore invokes
  smoke with `CONSULT_SMOKE_SKIP_CLIENT=1`, exactly as
  `lib/harness-checks.sh:56` already does, and says so in the `smoke-green`
  detail.
- `consult harness-checks` writes into the hard-coded closed-iteration path
  `state/harness-evolution/runs/iter-3/evidence/skill-*`
  (`lib/harness-checks.sh:98-109`) whatever iter dir it is given. Exercising the
  command is required by `every-command-exits-zero`, so the runner snapshots and
  restores that directory. The proper fix — making `harness-checks.sh` honor its
  iter-dir argument — belongs to a Builder after baseline.

Three findings worth the Builder's attention beyond the obvious gaps:

- `runtime_have()` uses `command -v`, and bash reports a **non-executable**
  file on `PATH` as found (verified: `command -v` and `type -P` both return a
  mode-000 file that `[[ -x ]]` rejects). That is the real cause of
  `detect-no-false-positive` failing — an `[[ -x ]]` guard fixes it.
- `docs/skills.md` points at `state/harness-evolution/runs/skills/`, which does
  not exist until a skill runs — the only `docs-no-stale-paths` failure.
- `skills-outputs-project-specific` **passes** at baseline (Jaccard 0.529, no
  cross-project citations) even though skills are template-only, because the
  template interpolates each project's own file tree. That is the catalog's
  stated measure, implemented literally. The template loophole is closed by this
  dimension's gates (`skill-uses-provider-seam`, `no-mock-provider`) and by the
  per-project checks that require a named runtime and a derived guidance term,
  all of which fail. The Analyst should not read this single pass as evidence
  that skills do real work.

Interpretation choices are recorded in `proposed-benchmark-changes.md` (three
entries) rather than applied silently; each is also stated in the affected
check's `detail` string in `checks.json`.

**Mis-scope note (2026-08-07):** An earlier turn incorrectly targeted JobOS TUI.
Owner corrected: focus is Product Consulting Harness **CLI** only. JobOS
engagement artifacts and worktree were removed. (This is the only place the
historical term is retained; see check `docs-cli-not-tui`.)
