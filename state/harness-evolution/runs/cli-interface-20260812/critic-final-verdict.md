# Critic final verdict — cli-interface-20260812-v3

**Role:** Vesper (Critic, permanent)  
**Against:** iteration-2 repair diff + `final-scores.json` (FinalAnalyst) + `architecture-decision.md` / framework evidence  
**Contract:** `CLI-BENCHMARK-CONTRACT.md` · `cli-interface-20260812-v3` · freeze `92f06ecd…` (`FREEZE-SHA.txt`)  
**Method:** Evidence-backed file/code/artifact audit only. No commands, tests, formatters, or product edits for this verdict.

---

## Explicit final verdict

| Axis | Ruling |
|------|--------|
| **Diff** | **ACCEPT** |
| **Scores** | **ACCEPT** |
| **Architecture (framework gate)** | **ACCEPT** |
| **Organization** | **ACCEPT** |

**Overall: ACCEPT.** Frozen defects D1–D7 are repaired under the thin-registry / non-destructive D1 / no-`eval` constraints; FinalAnalyst integers track the exact frozen band anchors; Ink/OpenTUI spikes were measured then deleted; Bash CLI/REPL retained. No required corrections block acceptance.

**Convergence stance:** Under the **frozen contract** checklist (`CLI-BENCHMARK-CONTRACT.md` “Minimum thresholds”: every dimension ≥ 8.0, parity green, freeze SHA intact, Analyst-authored scores, real verification, thin registry), the threshold is **met**. Under any stricter overlay that demands every dimension ≥ 9 (as FinalAnalyst’s `converged: false` reports), the sole blocker is dimension 10 at **8** — machine-pinned absolute paths still present in tracked engagement metadata. **That overlay must remain non-converged rather than “fixed” by deleting or rewriting immutable historical / valid machine-local engagement paths.** Do not scrub `state/engagements/*/workspace.json` (or sibling historical metadata) to chase the 9–10 anchor.

---

## 1. Diff audit — **ACCEPT**

### 1.1 Registry / argv / workspace safety

| Check | Finding | Evidence |
|-------|---------|----------|
| Thin registry, single source | **PASS.** `lib/commands.sh` is a data table + accessors; 32 `cmd_reg_add` rows; `CMD_CHAT_ONLY=(provider workers clear export exit quit)`; `cmd_help_json` emits frozen shape; no plugin host, no `eval`, no daemon. | `lib/commands.sh:1-122`; parity `evidence/parity-final.txt` probe “help --json registry membership… (32/18/14/6)” PASS |
| Unsupported reasons | **PASS.** All 14 unsupported entries carry non-empty safety/usefulness `chat_reason` matching the frozen §2 table. | `lib/commands.sh:27-57`; contract dim 2 table |
| Safe slash argv | **PASS.** `repl_tokenize` honors quotes/backslash; metacharacters inert; no `eval`; `/provider "codex"` path covered by parity. | `lib/repl.sh:349-389`; parity probes quoted argv + embedded `;$(…)` PASS |
| Slash forwarding | **PASS.** `/score … --iter` and `/bench … run --iter` reach Analyst-stamp refusal, not missing-iter. | `evidence/parity-final.txt` (CLI controls + slash forwarding rows) |
| D1 workspace policy | **PASS (non-destructive).** `workspace_ensure` recreates/repoints metadata; when a recorded foreign path still exists it is left byte-identical; never delete/relocate/reset/overwrite that worktree. Dirty path still refuses. | `lib/workspace.sh:54-105`; parity “checks … exits 0” + “workspace recovery is non-destructive” PASS |
| Durable style memory | **PASS.** `state/style/*` untouched (v1 D5 out of scope). | contract scope note; `evidence/style-dup-baseline.txt` retained; git status shows no `state/style` edits |

**Diff surface (in-scope):** `README.md`, `bin/productteam`, `lib/onboarding.sh`, `lib/repl.sh`, `lib/workspace.sh`, new `lib/commands.sh`, new `tests/cli-interface-parity.sh`. Contract / `FREEZE-SHA.txt` / baseline score artifacts untouched. HEAD still `1ebb52f` with uncommitted repair worktree — expected for this run.

### 1.2 Machine boundary

| Check | Finding | Evidence |
|-------|---------|----------|
| `help --json` | **PASS.** Registry metadata: 32 commands + 6 `chat_only`. | `lib/commands.sh:108-122`; parity PASS |
| `status --json` | **PASS.** Engagement list includes onboarding-flight-control and harness-evolution. | `bin/productteam:287-331`; parity PASS |
| Existing JSON seams | **PASS.** agents/card/style/pool/project-memory/escalation (+ gate/workspace/role) still parse. | parity “existing machine-readable surfaces emit valid JSON” PASS |
| No new durable authority | **PASS.** One-shot JSON only; inspect pack / plain files remain authoritative; no daemon/DB/server. | `architecture-decision.md`; `dependency-packaging-report.md` |

### 1.3 Scope / churn / regressions

- **Scope held:** repairs map to frozen D1–D7 + Principal accepted build list; no plugin framework retained; no interactive default swap.
- **No freeze mid-run:** `FREEZE-SHA.txt` == SHA-256 of `CLI-BENCHMARK-CONTRACT.md` (`92f06ecd…`); parity probe 1 PASS.
- **No silent baseline rewrite:** `baseline-scores.json` / `evidence/*-baseline*` remain the iter-1 record (mean 5.5); finals are additive.
- **No mocked provider path:** `evidence/live-chat-cycle.typescript` shows real `agent` → `LIVE-CYCLE-OK` (exit 0); `evidence/visual-final.json` `live_provider_proof: pass`.
- **Green suites cited:** parity 31/31 (`evidence/parity-final.txt`); smoke 41/41 (`evidence/smoke-final.txt`); visual 14/14 (`evidence/visual-final.json`); harness-apc `evidence/harness-checks-final/checks.json`.

**Missing-evidence gaps (non-blocking; already reflected in conservative scores):** `report`/`inspect` happy paths not archived in final evidence; literal `rc=130` not shown in an archived interrupt transcript (code sets `rc=130` at `lib/repl.sh:312`); standalone `tests/run-loop-smoke.sh` not archived as its own final run (covered via smoke overnight run-loop).

---

## 2. Scores audit (FinalAnalyst × exact frozen rubric) — **ACCEPT**

Evaluator separation holds: `final-scores.json` / `final-evidence.md` authored as FinalAnalyst; Principal did not score.

| Dim | Final | Critic | Rubric check |
|-----|------:|--------|--------------|
| 1 reachability | 9 | **UPHOLD** | Probes 2–3 PASS; D1 self-heal; 9 not 10 for thin happy-path gaps + repoint-vs-hard-refuse nuance — fair |
| 2 chat-reachability-classification | 10 | **UPHOLD** | Probes 5–9 PASS; registry-driven 24-verb palette; live chat cycle |
| 3 argument-usage-parity | 10 | **UPHOLD** | Probe 8/16 + `evidence/usage-parity-probes.txt` |
| 4 help-readme-onboarding-parity | 10 | **UPHOLD** | Probes 4, 12; `lib/onboarding.sh:51` prints `--iter` form |
| 5 argv-safety | 10 | **UPHOLD** | Probes 9, 14; tokenizer no-eval |
| 6 frontend-machine-boundary | 10 | **UPHOLD** | Probes 6, 10, 11 |
| 7 non-tty-redirect-nocolor-exit | 10 | **UPHOLD** | Probes 13, 15, 16; D7 raw-jq gone |
| 8 ctrl-c-child-cleanup-partial-artifacts | 9 | **UPHOLD** | Code + visual `honest-partial-output`; 9 for missing archived literal 130 — fair |
| 9 visual-smoke-contracts | 10 | **UPHOLD** | smoke 41/41; visual 14/14; probe 15 |
| 10 dependencies-cold-start | 8 | **UPHOLD** | Exact 6–8 anchor: “State pins absolute paths but commands self-heal”; 9–10 requires “No machine-pinned absolute paths in tracked state”. Pins remain: `state/engagements/onboarding-flight-control/workspace.json`, `state/engagements/overnight-rehearsal/workspace.json` (`/home/logani/...`). Probe 3 PASS proves command impact removed — top of 6–8, not 9–10 |
| 11 metadata-simplicity-deletion | 9 | **UPHOLD** | Minimal `state/.cli`; registry is source not state; style out of scope; 9 for archival nit on run-loop-smoke |

**Overall 9.5 (105/11)** and baseline guard (+4.0 from 5.5) — **ACCEPT.** No score flips. No voiding critical failures (1–6) observed.

**Convergence / evidence-corruption ruling (required by this assignment):**  
Chasing dimension 10 to ≥9 would require deleting or rewriting tracked machine-local engagement path records that are valid historical evidence of prior machine-bound worktrees. **Reject that repair path.** Prefer honest **dim 10 = 8** and, if a ≥9-all-dimensions overlay is applied, **remain non-converged** rather than corrupt immutable engagement metadata. The frozen contract’s own ≥8.0 checklist does not require that corruption.

**Scores nit (not a required correction):** FinalAnalyst’s `converged: false` cites an assignment overlay (≥9 every dimension) rather than the frozen checklist (≥8). The integer scores themselves remain correct. Future `convergence-report.md` should state both thresholds explicitly so readers do not treat the overlay as a silent contract amendment.

---

## 3. Architecture / framework gate — **ACCEPT** (gate 9)

| Gate criterion | Result | Evidence |
|----------------|--------|----------|
| Demonstrated recurring TUI defect requiring a framework? | **No** | visual 14/14; repaired parity green |
| Spike consumed live CLI boundary without scraping? | **Yes** (both) | `framework-comparison.md` |
| Multiline / streaming / a11y / signal-ownership of provider? | **Not met** | comparison table: neither spike streams or owns provider children; no screen-reader contract |
| Packaging / cold-start cost acceptable? | **No** | Ink 22,860 KiB / Node ≥22; OpenTUI 81,468 KiB / Bun-or-Node-26.4 FFI (`dependency-packaging-report.md`) |
| Net deletion 25–30% of replaceable Bash UI? | **0%** | comparison: >1,100–1,400 lines added, zero Bash lines deleted |
| Deletion after evidence? | **Yes** | spikes absent from tree; only `evidence/ink-*.txt` / `evidence/opentui-*.txt` retained; no surviving framework `node_modules` for the spikes |
| Canonical subject retained? | **Yes** | `architecture-decision.md`: retain repaired Bash CLI/REPL; no `productteam tui` |

**Architecture ACCEPT.** “Not yet” is the correct retention decision. Framework disposal must not dock any frozen dimension (FinalAnalyst `framework_decision.impact_on_scores: None` — upheld).

---

## 4. Organization self-review — **ACCEPT**

| Lens | Finding |
|------|---------|
| Role fidelity | Critic rejected v1/v2 freezes pre-build (`critic-prebuild-rebuttal.md`; archived `evidence/contract-v*-rejected.md`). Principal accepted mandatory corrections and owner-authorized disposable spikes (`principal-decision.md`) without self-scoring. FinalAnalyst scored independently. Builders stayed inside registry/CLI/docs/test surface. |
| Friction | Pre-build required two re-freezes before production edits — correct cost, not role failure. Critic’s original CUT of Ink/OpenTUI was **overruled with explicit owner authority**; retention still failed the evidence gate — process worked. |
| Prompt / memory gaps | Dual convergence thresholds (≥8 frozen vs ≥9 overlay) should be named in any closing convergence report so a future Principal does not “fix” dim 10 by scrubbing engagement history. |
| Unnecessary complexity | Prefer-deletion held: no fifth permanent role, no daemon, no retained TUI stack, no style-memory churn. |
| Org decision | Keep four permanent roles. Temporary spike/score workers disband with this verdict. No autonomy change or architecture escalation. |

---

## 5. Required corrections vs future nits

### Required corrections (acceptance blockers)

**None.**

### Future nits (do not reopen acceptance; opportunistic only)

1. Archive a SIGINT transcript that shows literal exit/recording of `130` beside the existing visual `honest-partial-output` pass.
2. Archive one happy-path `report` and `inspect` invocation in run evidence (registry already routes them).
3. Archive a standalone `tests/run-loop-smoke.sh` final transcript (behavior already covered by smoke overnight run-loop).
4. When writing `convergence-report.md`, document frozen ≥8.0 checklist **and** any assignment ≥9 overlay; keep dim 10 honest at 8.
5. Optional: document the workspace “repoint when foreign recorded path still exists” branch as intentional (leave foreign tree untouched, use canonical, rewrite metadata, exit 0) vs a hard non-zero refuse — probe primary evidence already expects non-destructive success.

---

## 6. Formal close

| Item | Assessment |
|------|------------|
| **Diff** | **ACCEPT** — D1–D7 repaired; registry/argv/workspace/machine-boundary safe; scope held |
| **Scores** | **ACCEPT** — FinalAnalyst integers match exact frozen bands; no flips |
| **Architecture (framework gate)** | **ACCEPT** — spikes deleted; Bash retained; “not yet” |
| **Organization** | **ACCEPT** — roles faithful; friction was the freeze/correction loop working as designed |
| **Frozen ≥8 convergence checklist** | **Met** (pending this Critic re-audit record) |
| **≥9-all-dimensions overlay** | **Remain non-converged** — do not corrupt historical machine-local engagement paths to lift dim 10 |
| **Critical failures 1–6** | **None observed** |

**Bottom line:** Accept the iteration-2 CLI repair, the FinalAnalyst score pack, the framework non-retention decision, and the org as-run. Leave dimension 10 at 8; do not rewrite engagement workspace metadata for a green convergence sticker.
