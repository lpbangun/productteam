# BENCHMARK-CONTRACT.md — harness-cli (FROZEN)

**Contract `harness-cli-v1` · FROZEN 2026-08-07 · engagement-local.**

This contract scores the **Product Consulting Harness CLI itself**
(`bin/consult` + `lib/` + its docs and checks). It does not replace or
amend `BENCHMARKS.md` v1, `ofc-v1`, or `harness-apc-v1`. Those remain
frozen and untouched.

Scores are 0–10 per dimension, one decimal. A score without a cited
path, command output, or check id is **void**.

## Engagement metadata

| Field | Value |
|-------|-------|
| Subject (product under score) | Product Consulting Harness **CLI** — `bin/consult`, `lib/`, `docs/`, `tests/` |
| Harness / product root | `/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui` |
| Engagement dir | `state/engagements/harness-cli` |
| Contract id | `harness-cli-v1` |
| Frozen | **2026-08-07** |
| Mode | Directive (`engagement.md`) |
| Scorer | `checks` — deterministic runner `lib/harness-cli-checks.sh` |
| Target (per dimension) | **9.0** |
| Convergence | Every dimension ≥ 9.0 on the same scored iteration |
| Max iterations | **6** — iter-0 baseline + up to 5 improvement iterations |
| Dimensions | 9 |
| Check ids | 49 (catalog: `checks/CHECK-CATALOG.md`) |

**Terminology:** the product surface is a **CLI**. The word "TUI" is not
used to describe it anywhere in this engagement (see `docs-cli-not-tui`).

**Not in scope:** JobOS, Job App, or any sibling product. No sibling
product repo is modified by this engagement.

---

## Invariants (violating any of these voids the iteration)

1. **Local-first harness.** No daemon, server, database, network service,
   or cloud dependency added. State stays plain text under `state/`.
2. **No LLM mocks.** Every provider/skill verification path uses the real
   `agent` runtime (or the declared `CONSULT_PROVIDER` binary). Fixtures,
   stub replies, canned transcripts, and `echo`-based providers are
   forbidden as evidence.
3. **Sibling clients only.** Client product repos stay siblings referenced
   by `Repo:` in `engagement.md`. No nested `clients/` tree is created.
4. **Provider seam stays `lib/provider.sh`.** It remains the single place
   that knows which runtime runs. No second runtime/detection module.
5. **Client vision is a constraint.** No client contract or vision is
   edited to make a score easier.
6. **Freeze discipline.** `BENCHMARK-CONTRACT.md`, `contract.json`, and
   `checks/CHECK-CATALOG.md` are not edited during an active iteration.
   Proposals go only to `proposed-benchmark-changes.md`.

---

## Scoring protocol

1. **Independent scorer.** The Analyst (or Independent Verifier) authors
   `runs/iter-N/scores.json`. The Builder who implemented that iteration
   must not author or overwrite it.
2. **Deterministic first.** Each dimension's score is computed from its
   check results by the normative band table below. The scorer does not
   hand-adjust a band.
3. **Evidence rule.** Every dimension score cites the check ids that
   passed/failed plus at least one file path or command transcript.
   Missing evidence → score void → iteration void.
4. **Live checks are mandatory for a scored run.** A run where any
   `LIVE` check (see catalog) was skipped is recorded
   `"kind":"partial"` and **cannot** be a converging run.
5. **Critic re-audit.** Mandatory before a run is accepted; verdict in
   `runs/iter-N/report.md`. Conservative resolution: lower score wins.
6. **Overall** = mean of the nine dimensions, one decimal. Overall is
   informational; **convergence is per-dimension**.

### Normative band table (applies to every dimension)

`n` = number of checks in the dimension. `g` = the dimension's **gate**
check ids (named per dimension below). Gate failure caps the dimension.

| Condition | Score |
|-----------|-------|
| All `n` checks pass | **9.5** |
| All gates pass, exactly one non-gate check fails | **8.0** |
| All gates pass, ≥ 60% of checks pass | **7.0** |
| All gates pass, < 60% of checks pass | **5.5** |
| Any gate fails, and ≥ 2 checks pass | **4.0** |
| Any gate fails, and < 2 checks pass | **2.0** |

Consequence: a dimension reaches the 9.0 target **only** when every one
of its checks passes. This is deliberate — it is why the checks are
objective and why the catalog is frozen with the contract.

---

## Baseline guard

- **iter-0** is scored before any CLI behavior change.
- Measurement-only scaffold (`lib/harness-cli-checks.sh`, the two dummy
  tmp projects, this contract) may be added **before** baseline, because
  it does not change what `bin/consult` does. Any commit that changes CLI
  behavior must land after iter-0 is recorded.
- iter-0 is never re-scored retroactively (`CONSTITUTION.md` §4).

---

## Required verification commands

Run from the harness root:

```bash
cd "/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui"

# CLI smoke
tests/consult-smoke.sh

# Frozen-contract check suite (writes checks.json in the iter dir)
bash lib/harness-cli-checks.sh state/engagements/harness-cli/runs/iter-N

# Same suite through the CLI once dispatch routes per engagement
bin/consult checks harness-cli

# Contract + history + latest scores
bin/consult bench harness-cli
bin/consult score harness-cli

# Live provider reality (no mocks) — required for a scored run
bin/consult runtime --check
bin/consult skill critique  state/engagements/harness-cli/tmp-projects/proj-a
bin/consult skill benchmark state/engagements/harness-cli/tmp-projects/proj-b
```

`CONSULT_SKIP_LIVE=1` exists only for fast local loops. A run produced
with it set is marked `partial` and is **not** eligible for convergence.

---

## Dimensions (9)

Band key: **≤5** missing/broken/mocked · **6–8** present with gaps ·
**9–10** complete, evidenced, operable cold.

### 1. visual-cli-clarity

**Success:** The CLI reads like Grok Build / Droid / OpenCode — calm
black-and-white terminal chrome (bold/dim/reset for all structure), with
sparse accent color used only for meaning, defined in one theme block,
and fully strippable.

| Band | Criteria |
|------|----------|
| ≤5 | Chrome depends on color to be readable; `NO_COLOR`/pipe leaks escapes; ANSI codes scattered across files |
| 6–8 | Monochrome chrome mostly holds; ≤2 checks fail; accent use inconsistent or over-budget in one place |
| 9–10 | All 5 checks pass: one theme source, monochrome structure, ≤2 accent hues, clean under `NO_COLOR` and when piped |

**Checks (5):** `cli-theme-single-source`, `cli-monochrome-chrome`,
`cli-accent-budget`, `cli-no-color-clean`, `cli-plain-pipe-safe`
**Gates:** `cli-no-color-clean`, `cli-plain-pipe-safe`

**Evidence:** `bin/consult` theme block; `NO_COLOR=1 bin/consult status | cat -v`;
`bin/consult status > /tmp/x && grep -c $'\e[' /tmp/x`

### 2. splash-animation

**Success:** A short login/splash animation draws a **knowledge graph of
computer-headed human nodes connected by edges**, bounded in time, and
never in the way of scripted or piped use.

| Band | Criteria |
|------|----------|
| ≤5 | No splash command; or it blocks, exceeds its time budget, or cannot be disabled |
| 6–8 | Splash renders a graph; 1–2 checks fail (e.g. only one frame, or no first-run hook) |
| 9–10 | All 5 checks pass: nodes + edges, ≥3 animated frames, ≤2.0s bounded, static single frame when non-TTY, first-run/login hook recorded |

**Checks (5):** `splash-command-exists`, `splash-graph-nodes-edges`,
`splash-frames-animate`, `splash-bounded-noninteractive`,
`splash-first-run-hook`
**Gates:** `splash-command-exists`, `splash-bounded-noninteractive`

**Evidence:** splash renderer source (node/edge data structure);
`time bin/consult splash`; `bin/consult splash | cat` transcript.

### 3. onboarding-ease

**Success:** A new user with no prior state reaches a first successful
command as easily as with OpenCode or Droid: one entry command, few
explicit steps, no hidden prerequisites, safe to re-run.

| Band | Criteria |
|------|----------|
| ≤5 | No onboarding entry point; or cold start fails / blocks on an unhandled prompt |
| 6–8 | Onboarding runs cold; 1–2 checks fail (e.g. not idempotent, or next action not verified) |
| 9–10 | All 5 checks pass: entry command in help, cold non-interactive success, ≤5 explicit steps, idempotent re-run, final next-action command itself exits 0 |

**Checks (5):** `onboarding-command-exists`, `onboarding-cold-start`,
`onboarding-steps-explicit`, `onboarding-idempotent`,
`onboarding-next-action`
**Gates:** `onboarding-command-exists`, `onboarding-cold-start`

**Evidence:** onboarding transcript from a temp state root archived under
`runs/iter-N/evidence/onboarding-cold.txt`.

### 4. agent-detection

**Success:** The CLI cleanly detects **all coding agents present on the
device** — not just a hard-coded PATH probe of six names — reports where
each was found, never claims one it cannot execute, and can emit machine
-readable output.

| Band | Criteria |
|------|----------|
| ≤5 | Detection absent, or reports an agent it cannot exec (false positive), or the catalog is under 10 known agents |
| 6–8 | PATH detection works and is honest; 1–2 checks fail (e.g. no `--json`, or install-dir scan missing) |
| 9–10 | All 6 checks pass: ≥10-agent catalog in one table, install-dir scan beyond PATH with the path shown, no false positives, `--json` parseable, version-or-`unknown` per found agent |

**Checks (6):** `detect-command-exists`, `detect-covers-known-agents`,
`detect-beyond-path`, `detect-no-false-positive`,
`detect-machine-readable`, `detect-versions`
**Gates:** `detect-command-exists`, `detect-no-false-positive`

**Evidence:** detection table in `lib/provider.sh`; `bin/consult agents --json | jq -e`;
temp-PATH transcript proving a fabricated name reports missing.

### 5. feature-reachability

**Success:** Every core harness feature is callable from the CLI, listed
in help, and either succeeds or refuses by name. Help and dispatch do not
drift apart.

| Band | Criteria |
|------|----------|
| ≤5 | Documented commands crash or are unreachable; help and dispatch disagree on ≥2 commands |
| 6–8 | Core commands reachable; 1–2 checks fail (e.g. one orphan command, or one undocumented env var) |
| 9–10 | All 5 checks pass: help ↔ dispatch exact match, every command exits 0 or refuses by name, full core feature list reachable and matching README, unknown command exits non-zero with a suggestion, no undocumented env requirement |

**Checks (5):** `help-lists-every-command`, `every-command-exits-zero`,
`core-features-reachable`, `unknown-command-honest`,
`no-hidden-env-requirements`
**Gates:** `help-lists-every-command`, `every-command-exits-zero`

**Evidence:** diff of `cmd_*` dispatch cases in `bin/consult` against
`bin/consult help`; per-command exit-code table archived in the run dir.

### 6. skills-llm-reality

**Success:** Skills do real work through the provider seam against **two
varying dummy tmp projects with guidance**, using **real agent LLM
calls**. No mocks, no template-only output, and honest refusal when no
runtime exists.

| Band | Criteria |
|------|----------|
| ≤5 | Skills emit templates without a provider call; or any mock/fixture provider is used as evidence; or only one tmp project exists |
| 6–8 | Provider seam called and ≥1 skill produces real, project-specific output; 1–3 checks fail |
| 9–10 | All 8 checks pass: live provider answer, two varying guided projects, all three skills produce project-specific live output that differs across projects, no mock path anywhere, honest refusal without a runtime |

**Checks (8):** `provider-live-answer`, `tmp-projects-two-varying`,
`skill-uses-provider-seam`, `skill-critique-live-project-a`,
`skill-benchmark-live-project-b`, `skill-design-sprint-live`,
`skills-outputs-project-specific`, `no-mock-provider`
**Gates:** `provider-live-answer`, `skill-uses-provider-seam`,
`no-mock-provider`

**Evidence:** skill artifacts under `runs/iter-N/evidence/skills/`, each
recording the runtime binary used, the target repo, and the reply;
`state/engagements/harness-cli/tmp-projects/proj-{a,b}/GUIDANCE.md`.

**Reality rule:** an artifact that does not name the runtime binary that
produced it is not evidence for this dimension.

### 7. documentation

**Success:** README and `docs/` describe the CLI that actually exists —
including first-run, splash, and agent detection — with no stale paths
and no "TUI" framing.

| Band | Criteria |
|------|----------|
| ≤5 | README omits or contradicts the CLI surface; broken relative paths; product described as a TUI |
| 6–8 | Coverage good with drift; 1–2 checks fail |
| 9–10 | All 5 checks pass: README ↔ help parity, first-run section, no TUI framing, every referenced path resolves, `docs/skills.md` states skills make real provider calls |

**Checks (5):** `readme-matches-cli`, `readme-onboarding-section`,
`docs-cli-not-tui`, `docs-no-stale-paths`, `docs-skills-live`
**Gates:** `readme-matches-cli`, `docs-no-stale-paths`

**Evidence:** `README.md`, `ARCHITECTURE.md`, `docs/skills.md`;
`rg -in '\bTUI\b'` output.

### 8. developer-experience

**Success:** Clone-to-value is frictionless for someone extending the
CLI: smoke green, this contract's suite runnable through the CLI, errors
that name the remedy, no new runtime dependencies, scripts that parse.

| Band | Criteria |
|------|----------|
| ≤5 | Smoke red; no runner for this contract; or a new runtime dependency introduced |
| 6–8 | Smoke green and a runner exists; 1–2 checks fail (e.g. dispatch still routes to the wrong suite) |
| 9–10 | All 6 checks pass: smoke green, `lib/harness-cli-checks.sh` writes `checks.json` with honest exit code, `consult checks harness-cli` runs **this** suite, dependency allowlist held, refusals name cause + remedy, all scripts pass `bash -n` |

**Checks (6):** `smoke-green`, `harness-cli-checks-runner`,
`checks-dispatch-routes-engagement`, `no-new-runtime-deps`,
`errors-name-the-fix`, `scripts-parse-clean`
**Gates:** `smoke-green`, `harness-cli-checks-runner`

**Dependency allowlist (frozen):** `bash`, `awk`, `sed`, `grep`, `find`,
`sort`, `jq`, `python3`, `git`, `gh` (GitHub seam only), plus the
detected agent runtimes. Anything else is a new dependency.

**Evidence:** `tests/consult-smoke.sh` exit 0 transcript;
`runs/iter-N/checks.json`; refusal transcripts.

### 9. product-clarity

**Success:** Within a minute of running `bin/consult`, a reader knows what
the harness is, who it is for, and what it deliberately is not — and
every capability claim is backed by a passing check.

| Band | Criteria |
|------|----------|
| ≤5 | Identity ambiguous; or the CLI/README claims a capability no check backs |
| 6–8 | Identity clear after reading around; 1 check fails |
| 9–10 | All 4 checks pass: identity in the first lines of `bin/consult`, non-goals visible, engagement scope explicit and CLI-worded, every claim mapped to a passing check id |

**Checks (4):** `status-states-identity`, `non-goals-visible`,
`engagement-scope-explicit`, `no-overclaim`
**Gates:** `no-overclaim`

**Evidence:** `bin/consult` status header; `README.md` non-goals;
`state/engagements/harness-cli/engagement.md`; claim→check mapping file.

---

## Convergence

The engagement converges when, on **one** scored iteration:

- [ ] `runs/iter-N/scores.json` has all nine dimensions, one decimal
- [ ] **Every dimension ≥ 9.0** (i.e. every check in every dimension passes)
- [ ] Independent scorer authored the scores; Critic re-audit recorded
- [ ] iter-0 baseline exists and was not rewritten
- [ ] Contract, `contract.json`, and `checks/CHECK-CATALOG.md` unmodified during the run
- [ ] All `LIVE` checks actually executed (`kind` is not `partial`)
- [ ] No critical failure below
- [ ] No sibling product repo modified

### Stop conditions

- Converged, **or**
- **6 iterations** consumed (iter-0 baseline + 5 improvement iterations)
  → write `state/engagements/harness-cli/convergence-report.md`: what was
  tried, what blocked ≥ 9.0 per dimension, and what would unblock it.

---

## Critical failures (void the iteration)

1. **Mocked LLM/agent evidence** — fixture replies, stub provider, or a
   skill artifact that names no runtime binary.
2. **Benchmark moved mid-run** — any content change to this file,
   `contract.json`, or `checks/CHECK-CATALOG.md` during an active iteration.
3. **Self-scoring** — the iteration's Builder authored `scores.json`.
4. **Missing Critic verdict** on the diff, the scores, and the org.
5. **Fabricated check output** — results not produced by the stated
   command against this repo.
6. **Scope breach** — a JobOS / sibling product file changed, a nested
   `clients/` tree created, or a second runtime-detection module added.
7. **Invariant breach** — daemon/server/database added, or the provider
   seam moved out of `lib/provider.sh`.
8. **Secrets in artifacts** — tokens, keys, or `.env` contents under
   `state/engagements/harness-cli/`.

Void iteration ⇒ record `"kind":"void"` in `history.jsonl`; do not
advance it as success.

---

## Run directory layout

```
state/engagements/harness-cli/
  BENCHMARK-CONTRACT.md          # FROZEN (this file)
  contract.json                  # FROZEN
  checks/CHECK-CATALOG.md        # FROZEN check ids ↔ dimensions
  proposed-benchmark-changes.md  # only place for rubric proposals
  tmp-projects/proj-a/           # dummy project + GUIDANCE.md
  tmp-projects/proj-b/           # second, deliberately different
  history.jsonl                  # one line per scored run
  subagents/assignments.md
  runs/iter-N/
    scores.json                  # independent scorer, 9 dimensions
    checks.json                  # runner output, all 49 check ids
    report.md                    # debate, diff, Critic verdict, org review
    lessons.md
    evidence/
      onboarding-cold.txt
      skills/                    # live skill artifacts (runtime named)
```

### `scores.json` shape (normative)

```json
{
  "contract": "harness-cli-v1",
  "iter": 0,
  "kind": "baseline",
  "ts": "2026-08-07",
  "evaluator": "Analyst",
  "live_checks_executed": true,
  "scores": {
    "visual-cli-clarity":   { "score": 0.0, "evidence": "x/5 pass; fail: …" },
    "splash-animation":     { "score": 0.0, "evidence": "…" },
    "onboarding-ease":      { "score": 0.0, "evidence": "…" },
    "agent-detection":      { "score": 0.0, "evidence": "…" },
    "feature-reachability": { "score": 0.0, "evidence": "…" },
    "skills-llm-reality":   { "score": 0.0, "evidence": "…" },
    "documentation":        { "score": 0.0, "evidence": "…" },
    "developer-experience": { "score": 0.0, "evidence": "…" },
    "product-clarity":      { "score": 0.0, "evidence": "…" }
  },
  "overall": 0.0,
  "void": false,
  "critical_failures": []
}
```

---

## Version control

- **Id:** `harness-cli-v1`
- **Frozen:** 2026-08-07
- Amendments require owner approval, a new contract id, and apply only to
  engagements opened after the successor is frozen.
