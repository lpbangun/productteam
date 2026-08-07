# CHECK-CATALOG.md — harness-cli-v1 (FROZEN)

**Contract `harness-cli-v1` · FROZEN 2026-08-07 · 49 checks · 9 dimensions.**

Check ids are frozen with `BENCHMARK-CONTRACT.md`. The Test Engineer
implements them in `lib/harness-cli-checks.sh`; the runner writes
`runs/iter-N/checks.json` keyed by these exact ids. Adding, renaming, or
removing an id mid-engagement is a critical failure.

All commands run from the harness root:

```bash
cd "/home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui"
```

Legend:

| Mark | Meaning |
|------|---------|
| **GATE** | Failure caps its dimension at ≤5 (band table) |
| **LIVE** | Requires a real `agent` (or `CONSULT_PROVIDER`) LLM call |
| **EXEC** | Executes agent binaries (`--version`) but makes no LLM call |

## Testability requirements (implied by these checks)

The checks are implementation-agnostic but require three documented,
named seams so that cold-start behavior is observable without touching a
real user's home directory:

1. **A state-root override** that relocates first-run / onboarding state
   (marker file included) to an arbitrary directory. Needed by
   `onboarding-cold-start`, `onboarding-idempotent`, `splash-first-run-hook`.
2. **A non-interactive form** for onboarding (flag or `CONSULT_*` env var).
   Needed by `onboarding-cold-start`.
3. **A splash opt-out** (flag or `CONSULT_*` env var). Needed by
   `splash-bounded-noninteractive`, and by keeping `tests/consult-smoke.sh`
   instant.

Every one of these names must appear in the documentation set
(`README.md`, `ARCHITECTURE.md`, or `docs/`), which is what
`no-hidden-env-requirements` independently enforces.

**Frozen tmp-project names:** `proj-a` and `proj-b`. The Repository
Analyst's sketch (`subagents/repository-analyst.md` §6) called these
`proj-alpha` / `proj-beta`; the frozen names win. Their *content* proposal
(one Node project, one Python project) satisfies `tmp-projects-two-varying`.

---

## 1. visual-cli-clarity (5)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `cli-theme-single-source` | All ANSI escape literals in `bin/consult` + `lib/*.sh` are defined in exactly one theme block/file; no escape literal appears in a `printf` format string elsewhere | `rg -n $'\\\\e\\['` across `bin/ lib/`; every hit is inside the theme block or a variable reference |
| `cli-monochrome-chrome` | Structural chrome (titles, tables, separators, labels) uses only bold / dim / reset / reverse. Color codes appear only for semantic accent, never as the sole carrier of structure | Strip color codes from `bin/consult status`, `help`, `org`, `bench harness-cli`; output must still contain every heading and column label |
| `cli-accent-budget` | At most **2** distinct accent color codes across the whole CLI surface | Count distinct `\e[3Xm` / `\e[9Xm` codes defined in the theme block; ≤2 |
| `cli-no-color-clean` **GATE** | `NO_COLOR=1` produces zero escape sequences for every top-level command | `for c in status help org memory runtime agents bench report smoke splash onboarding; do NO_COLOR=1 bin/consult $c 2>&1 \| grep -c $'\e['; done` all zero |
| `cli-plain-pipe-safe` **GATE** | Piping to a non-TTY produces zero escape sequences and no truncated/misaligned rows | `bin/consult status > /tmp/hc-pipe.txt 2>&1; grep -c $'\e[' /tmp/hc-pipe.txt` == 0; longest line ≤ 100 cols |

## 2. splash-animation (5)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `splash-command-exists` **GATE** | A splash/login command exists, is listed in `bin/consult help`, and exits 0 | `bin/consult help \| grep -qE 'splash\|login'` and `bin/consult splash >/dev/null` |
| `splash-graph-nodes-edges` | The rendered frame is a **knowledge graph**: ≥6 computer-headed human node glyphs and ≥5 edge glyphs; the renderer source defines node and edge data (not a hard-coded ASCII blob) | Frame capture contains ≥6 node markers and ≥5 of `─ │ ╱ ╲ ┼ ·`; renderer source declares a nodes list and an edges list |
| `splash-frames-animate` | Renderer emits ≥3 distinct frames; frame count and inter-frame delay are named constants | Capture with a frame-dump flag/env; count distinct frames ≥3; grep the renderer for the two constants |
| `splash-bounded-noninteractive` **GATE** | Total wall time ≤ **2.0s**; never reads stdin; non-TTY / `NO_COLOR` / `CI` renders a single static frame; one **documented** opt-out (a flag or a `CONSULT_*` env var) disables it entirely | `timeout 3 bash -c 'time bin/consult splash < /dev/null'` under 2.0s; piped run yields exactly one frame; opt-out run yields no frame; opt-out name appears in the docs set |
| `splash-first-run-hook` | Splash is shown on the first-run / login path and recorded via a first-run marker, and is **not** replayed on every subsequent command | With the state-root override pointed at `mktemp -d`: first invocation renders a frame, second does not; the marker file exists under that root |

## 3. onboarding-ease (5)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `onboarding-command-exists` **GATE** | An onboarding entry command exists, appears in `bin/consult help` and in `README.md` | `bin/consult help \| grep -qE 'onboard\|init'` and same string in `README.md` |
| `onboarding-cold-start` **GATE** | With a clean state root and no config, the documented **non-interactive form** (a flag or a `CONSULT_*` env var) completes with exit 0, reads no stdin, and prints no traceback | `<state-root-override>=$(mktemp -d) bin/consult onboarding <non-interactive-form> < /dev/null`; exit 0; stderr free of `Traceback\|line [0-9]+: `; both override names appear in the docs set |
| `onboarding-steps-explicit` | Output enumerates **≤5** numbered steps covering: detect agents → choose provider → first engagement → first score → next command | Count `^\s*[1-5][.)]` lines in the transcript (1–5); each of the five topics matched by keyword |
| `onboarding-idempotent` | Running twice is safe: the second run reports already-configured and the state root is byte-identical afterward | Two runs against the same temp state root; `diff -r` of a snapshot after run 1 vs run 2 is empty; exit 0 both times |
| `onboarding-next-action` | The final line names one concrete `consult …` command, and that command itself exits 0 (or refuses by name) when run | Extract the last `consult` invocation from the transcript and execute it |

## 4. agent-detection (6)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `detect-command-exists` **GATE** | A detection command exists, is in help, exits 0, and prints one row per catalog entry with found/missing status | `bin/consult agents` (or `runtime`) exit 0; row count == catalog size |
| `detect-covers-known-agents` | The detection catalog names **≥10** known coding agents, declared in exactly one place | Catalog list in `lib/provider.sh` has ≥10 entries; `rg` finds no second hard-coded agent-name list in `bin/` or `lib/` |
| `detect-beyond-path` | Detection also scans known install directories, so an agent absent from `PATH` but present on disk is still reported **with its path** | Run with a stripped `PATH` (`PATH=/usr/bin:/bin`); an agent installed under `~/.local/bin` / `~/.opencode/bin` is still reported found with an absolute path |
| `detect-no-false-positive` **GATE** | A fabricated agent name is reported missing; nothing is reported found unless it is executable | Inject a non-executable file named after a catalog agent into a temp `PATH` → must report missing; a fabricated catalog probe must never report found |
| `detect-machine-readable` | `--json` emits a valid JSON array of objects with `name`, `status`, `path` (and `version` when known), parseable by `jq -e` | `bin/consult agents --json \| jq -e '.[0].name and .[0].status'` |
| `detect-versions` **EXEC** | Every found agent shows a version string or an explicit `unknown`; version probes are individually time-bounded (≤3s) and never hang the command | Transcript: each found row has a version or `unknown`; total command time ≤ 10s with `< /dev/null` |

## 5. feature-reachability (5)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `help-lists-every-command` **GATE** | The set of dispatch cases in `bin/consult main()` equals the set of commands in `bin/consult help` — no orphan command, no phantom entry | Extract dispatch case labels and help command tokens; `comm -3` of the two sorted sets is empty |
| `every-command-exits-zero` **GATE** | Each documented command run with safe arguments either exits 0 or exits non-zero with a named refusal; none crashes, hangs, or emits a shell/Python traceback | Per-command table with `timeout 30`; no `unbound variable`, `command not found`, `Traceback`, or signal death |
| `core-features-reachable` | All core features are reachable from the CLI and the list matches `README.md`: status, judge, score, checks, bench, report, memory, org, agents/runtime, gh, skill, smoke, onboarding, splash, help | Each token present in `bin/consult help` **and** in `README.md`; each invocable per `every-command-exits-zero` |
| `unknown-command-honest` | An unknown command exits non-zero and the message suggests `consult help` (or the nearest command) | `bin/consult notacommand` exit ≠ 0 and stderr matches `help\|did you mean` |
| `no-hidden-env-requirements` | Every `CONSULT_*` (or other) env var read by `bin/consult` / `lib/*.sh` is documented in `README.md`, `ARCHITECTURE.md`, or `docs/` | Extract env var names via `rg -o '\$\{?CONSULT_[A-Z_]+'`; every name appears in the docs set |

## 6. skills-llm-reality (8)

The dimension the owner brief calls out most explicitly. **No mocks.**

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `provider-live-answer` **GATE · LIVE** | A real provider roundtrip through `provider_ask` returns a non-empty reply containing a requested sentinel token; the artifact records the runtime binary and the timestamp | `source lib/provider.sh; provider_ask 'Reply with exactly: CONSULT-LIVE-OK'` → reply contains `CONSULT-LIVE-OK`; archived with `runtime=$(runtime_default)` |
| `tmp-projects-two-varying` | Two dummy projects exist under `state/engagements/harness-cli/tmp-projects/` (`proj-a`, `proj-b`), each with a `GUIDANCE.md`, and they **vary**: different primary language, different domain, and no shared source filename | Both dirs and both `GUIDANCE.md` present; language/domain fields differ; source filename sets disjoint |
| `skill-uses-provider-seam` **GATE** | `lib/run-skill.sh` calls `provider_ask` on every skill path; no skill can emit an artifact without a provider reply | `rg -c 'provider_ask' lib/run-skill.sh` ≥ 1 per skill branch; no `else` branch writes an artifact when the provider fails |
| `skill-critique-live-project-a` **LIVE** | `bin/consult skill critique …/tmp-projects/proj-a` produces an artifact citing **≥2 real paths from proj-a** and ≥1 term unique to `proj-a/GUIDANCE.md`; the artifact names the runtime binary | Every cited path exists under `proj-a`; guidance term present; runtime line present |
| `skill-benchmark-live-project-b` **LIVE** | `bin/consult skill benchmark …/tmp-projects/proj-b` produces a contract whose dimensions reference **proj-b specifics** (not the generic starter list) and cites ≥2 real proj-b paths | Dimension list differs from the generic six-item starter; cited paths exist under `proj-b` |
| `skill-design-sprint-live` **LIVE** | `bin/consult skill design-sprint` on either project produces a direction that cites ≥2 real repo paths and reflects that project's `GUIDANCE.md` | Cited paths exist; guidance term present; runtime named |
| `skills-outputs-project-specific` **LIVE** | Running the **same** skill against proj-a and proj-b yields materially different output: no shared boilerplate skeleton, and each output's cited paths belong only to its own project | Jaccard similarity of the two outputs' token sets < 0.6; zero cross-project path citations |
| `no-mock-provider` **GATE** | No mock, fixture, stub, or canned-reply provider path exists anywhere in `lib/`, `bin/`, or `tests/`, and every skill artifact records the runtime binary that produced it | `rg -in 'mock\|fixture\|canned\|FAKE_PROVIDER\|stub_reply' bin/ lib/ tests/` finds no provider-substitute code path; every artifact under `evidence/skills/` has a runtime line |

## 7. documentation (5)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `readme-matches-cli` **GATE** | Every command listed in `bin/consult help` appears in `README.md`, and `README.md` lists no command that does not exist | Token set from help ⊆ README tokens, and README command tokens ⊆ dispatch cases |
| `readme-onboarding-section` | `README.md` has a first-run section covering onboarding, the splash, and agent detection, with copy-pasteable commands | Section heading matching `First run\|Getting started\|Quickstart` containing all three command tokens in fenced blocks |
| `docs-cli-not-tui` | The product surface is never called a TUI. `\bTUI\b` appears **nowhere** in `README.md`, `ARCHITECTURE.md`, `AGENTS.md`, `JUDGMENT.md`, `CONSTITUTION.md`, `docs/`, `skills/`, `bin/`, `lib/`, `tests/`. Inside `state/engagements/harness-cli/` it may appear only on lines that negate it (line also matches `not\|Not\|no \|mis-scope\|out of scope`) | `rg -in '\bTUI\b'` over the product path set is empty; every engagement-dir hit satisfies the negation pattern |
| `docs-no-stale-paths` **GATE** | Every repo-relative path mentioned in `README.md`, `ARCHITECTURE.md`, `AGENTS.md`, and `docs/*.md` resolves on disk | Extract backtick-quoted paths matching a repo-path shape; `test -e` each |
| `docs-skills-live` | `docs/skills.md` states that skills make **real** provider calls (no mocks) and points at the tmp-project verification for this engagement | Keywords `real`/`no mocks` plus `tmp-projects` present |

## 8. developer-experience (6)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `smoke-green` **GATE** | `tests/consult-smoke.sh` exits 0 | `tests/consult-smoke.sh` exit code 0; transcript archived |
| `harness-cli-checks-runner` **GATE** | `lib/harness-cli-checks.sh` exists, accepts an iter dir, writes `checks.json` containing all 49 ids, and exits non-zero when any check fails | Run against a temp iter dir; `jq -e '.checks \| length == 49'`; deliberately failing probe returns non-zero |
| `checks-dispatch-routes-engagement` | `bin/consult checks harness-cli` runs **this** suite, not the `ofc-v1` suite, and `bin/consult score harness-cli` reaches it too | Output names contract `harness-cli-v1`; contains no `ofc-v1` check id such as `maya-intro-flow` |
| `no-new-runtime-deps` | Only allowlisted tools are required: `bash awk sed grep find sort jq python3 git gh` plus detected agent runtimes | Extract external command invocations from `bin/consult` and `lib/*.sh`; every name is allowlisted or a shell builtin/function |
| `errors-name-the-fix` | Every refusal names both the cause and a remedy (a command, path, or env var to set). Probed on ≥4 failure paths | Probe: unknown command, missing engagement, missing provider (`CONSULT_PROVIDER=/nonexistent`), merge without authorization. Each stderr message contains a cause noun and a remedy token |
| `scripts-parse-clean` | Every shell script parses (`bash -n`) with no error; if `shellcheck` is installed, no error-severity findings | `bash -n` over `bin/consult` and `lib/*.sh` and `tests/*.sh`; optional `shellcheck -S error` |

## 9. product-clarity (4)

| Check id | Pass condition | How it is verified |
|----------|----------------|--------------------|
| `status-states-identity` | `bin/consult` with no arguments states what the harness **is** within its first 6 output lines: a CLI-first product judgment layer | First 6 lines (color-stripped) contain the product name and an identity phrase |
| `non-goals-visible` | Non-goals are visible from the CLI and `README.md`: not a client-product redesign, not an IDE, no daemon/database/plugin system | `bin/consult help` or `org` plus `README.md` both contain an explicit non-goals statement |
| `engagement-scope-explicit` | `state/engagements/harness-cli/engagement.md` keeps in-scope / out-of-scope sections, names the CLI as the surface, and excludes sibling products | Both scope markers present; `CLI` present; sibling-product exclusion present |
| `no-overclaim` **GATE** | Every capability claim in `README.md` and `bin/consult help` maps to a check id that **passes** in this run, via a claim→check mapping file kept under `state/engagements/harness-cli/checks/` | Mapping file parses; every claim row names ≥1 check id; every named id has status `pass` |

---

## Dimension → check id index

| Dimension | n | Gates | Live |
|-----------|---|-------|------|
| visual-cli-clarity | 5 | `cli-no-color-clean`, `cli-plain-pipe-safe` | — |
| splash-animation | 5 | `splash-command-exists`, `splash-bounded-noninteractive` | — |
| onboarding-ease | 5 | `onboarding-command-exists`, `onboarding-cold-start` | — |
| agent-detection | 6 | `detect-command-exists`, `detect-no-false-positive` | — (1 EXEC) |
| feature-reachability | 5 | `help-lists-every-command`, `every-command-exits-zero` | — |
| skills-llm-reality | 8 | `provider-live-answer`, `skill-uses-provider-seam`, `no-mock-provider` | 5 |
| documentation | 5 | `readme-matches-cli`, `docs-no-stale-paths` | — |
| developer-experience | 6 | `smoke-green`, `harness-cli-checks-runner` | — |
| product-clarity | 4 | `no-overclaim` | — |
| **Total** | **49** | 16 | **5** |

## Checks requiring live agent LLM calls

`provider-live-answer` · `skill-critique-live-project-a` ·
`skill-benchmark-live-project-b` · `skill-design-sprint-live` ·
`skills-outputs-project-specific`

These call the real runtime through `lib/provider.sh`. `detect-versions`
executes agent binaries with `--version` but makes no LLM call. A scored
run with any live check skipped is `kind: partial` and cannot converge.

## Runner contract

`lib/harness-cli-checks.sh` (Test Engineer deliverable):

- Usage: `bash lib/harness-cli-checks.sh [iter-dir]`
- Writes `<iter-dir>/checks.json`:
  `{"ts","contract":"harness-cli-v1","checks":{"<id>":{"status":"pass|fail","detail":"…"}},"passed","failed","live_executed"}`
- Emits every one of the 49 ids on every run — a check that cannot run
  records `fail` with the reason, never a missing key.
- Exit 0 only when `failed == 0`.
- Honors `CONSULT_SKIP_LIVE=1` by recording live checks as `fail` with
  detail `skipped` and setting `live_executed:false` (run is `partial`).
- Never writes into a sibling product repo; all temp state under `mktemp -d`.
- **Is never invoked from `tests/consult-smoke.sh`.** Smoke must stay
  instant and provider-free (`MEMORY.md`: smoke hangs when it calls a
  provider; `tests/consult-smoke.sh` comments the same rule). The live
  checks belong to this explicitly-invoked scoring runner only. A commit
  that puts a live check inside smoke fails `smoke-green` by regressing
  runtime, and is a scope breach of that lesson.
