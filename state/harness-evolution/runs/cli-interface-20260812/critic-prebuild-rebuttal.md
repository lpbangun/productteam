# Critic pre-build rebuttal — cli-interface-20260812

**Role:** Vesper (Critic, permanent)  
**Against:** `principal-priorities.md` + frozen Advisor benchmark (`CLI-BENCHMARK-CONTRACT.md`, `tests/cli-interface-parity.sh`, `FREEZE-SHA.txt`)  
**Stance:** Pre-build only. No implementation assessment (none exists).  
**Baseline cited:** overall **6.6** (`baseline-scores.json`); parity **20 PASS / 3 FAIL** (`evidence/parity-test-baseline.txt`).

---

## Verdict

**Benchmark: REJECT** as build-ready freeze.  
**Work list: REJECT as proposed; accept a narrowed subset only after required pre-build corrections and re-freeze.**

The Principal correctly flags that the sealed contract/test green-lights known signature drift and freezes a hand-copied slash taxonomy. Building against that freeze would encode defects as success.

---

## Benchmark audit — REJECT

| Gate | Finding | Evidence |
|------|---------|----------|
| Captures mission’s known defects? | **No.** Slash `/score` and `/bench … run` drop required `--iter`; onboarding still prints stale `score <client>`; `bench`/`run` crash on non-contract `scores.json`. None are frozen failing probes. | `lib/repl.sh:386-397` usage `/score <client>` / `/bench <client> [run]` → `cmd_score`/`cmd_bench_run` without `--iter`; CLI requires `--iter` (`bin/productteam:140,215-221,1445-1454`); `lib/onboarding.sh:51`; Analyst additional defect + `evidence/bench-harness-evolution.txt`, `evidence/run-harness-evolution-7.txt`; `iter-7/scores.json` has `"scores": null`. Parity sections 1–11 never assert these. |
| Unsupported chat classes have safety/usefulness reasons? | **Partial — insufficient.** Contract table reasons are concrete for `chat` (self-ref), bootstrap/lifecycle (`open`/`baseline`/`workspace`/`run-loop`), and owner-gated writes (`gate`/`direction`/`escalation`). **Read-mostly** `inspect`, `card`, `pool` (and read paths of `style`/`project-memory`) are classified unsupported with “file-derived state managed via dedicated CLI commands” — that preserves palette omission, not a safety/usefulness bar. | `CLI-BENCHMARK-CONTRACT.md` dim 2 table; `tests/cli-interface-parity.sh:96-99` `out_verbs`; parity PASS “all 14 unsupported…classified honestly” only asserts `unknown /X — /help`, not why exclusion is warranted. |
| Duplicated slash list as expected end state? | **Yes — trap.** Palette asserted from a second hardcoded `in_verbs`/`out_verbs`, not derived from `repl_slash_verbs` or the help table. | `lib/repl.sh:26-29` vs `tests/cli-interface-parity.sh:93-99`. Drift between lists would still PASS if both wrong. |
| Argv/quoted forwarding in chat? | **Missing.** Argv-safety probe covers `style append` only; slash path uses `read` + unquoted `set -- $args` / `$args` expansion. | `tests/cli-interface-parity.sh:209-218`; `lib/repl.sh:333,347,381-397`. |
| D5 as CLI defect? | **Mis-aimed.** Duplicate is committed memory content, not dispatcher logic. Freezing “edit `state/style/style.md` to green probe” invites durable-state churn. | `evidence/style-dup-baseline.txt`; `state/style/style.md` / `style show --json`; Principal item 4 correctly warns. |
| Freeze integrity of the *file*? | Hash matches; content is the problem. | `FREEZE-SHA.txt` == SHA of contract (`7804c3dd…`). |

**Freeze rule implication:** amending contract/probes needs owner approval + version bump + new hash (`CLI-BENCHMARK-CONTRACT.md` Freeze rule; `CONSTITUTION.md` §4). Do **not** start Builder work on the current seal.

---

## Item-by-item rebuttal

### 1. Correct and re-freeze benchmark before production edits

| Verdict | **SURVIVE — mandatory gate, not optional polish** |
|---------|-----------------------------------------------------|

**Lift if done:** Unblocks honest scoring of argument/usage parity, chat reachability/classification, argv safety; prevents false greens.  
**Rebuttal:** Correct diagnosis. Current freeze omits D-score/bench signature drift and the bench/run jq crash while treating hand-copied unsupported verbs as the end state.  
**Trap:** “Re-freeze” mid-mission without owner bump voids the iteration (contract critical failure #1). Sequence: owner-approved correction → new SHA → then build.

### 2. One descriptive command registry (help, validate/dispatch, slash palette/dispatch)

| Verdict | **NARROW — after corrected freeze only** |
|---------|------------------------------------------|

**Lift (narrowed):** Concrete for reachability + chat classification + usage parity **if** the registry is the single source the parity test consumes (kills duplicated `in_verbs`/`out_verbs`).  
**Rebuttal:** Building the registry against today’s slash signatures would permanently encode `/score <client>` without `--iter`. Aliases (`runtime`, `worktree`, `-h`) are fine; a second metadata parallel to help text is not.  
**Scope trap:** “Descriptive registry” becoming a plugin/framework layer → architecture escalation (`CONSTITUTION.md` autonomy table). Keep a data table + existing handlers; no `eval`.

### 3. Expose minimum frontend boundary (command metadata JSON + engagement status JSON)

| Verdict | **NARROW hard / mostly CUT from iter-1 build** |
|---------|-----------------------------------------------|

**Lift claimed:** frontend-machine-boundary, help/README/onboarding parity.  
**Rebuttal:** Dim 6 already scores **8** with existing `--json` surfaces parsing (`baseline-scores.json`; parity §7). 9–10 needs **documented shapes**, not new APIs. Engagement-list / “current transient selection” JSON is greenfield scope without a failing probe.  
**Accept only:** document authoritative shapes for surfaces already probed (`agents`, `card list`, `style show`, `pool list`, `project-memory show`, escalation/gate/workspace/role status, inspect pack).  
**Reject:** new command-metadata server surface or duplicate durable state for “frontend.”

### 4. Fix verified canonical defects (not cosmetics)

| Verdict | **SURVIVE with cuts** |
|---------|----------------------|

| Sub-item | Critic call | Evidence / reason |
|----------|-------------|-------------------|
| Slash signatures (`/score`, `/bench run` + `--iter`) | **ACCEPT** | `lib/repl.sh:386-397` vs CLI `--iter` requirement — concrete usage-parity + chat-classification lift once probes exist. |
| Stale onboarding `score <client>` | **ACCEPT** | `lib/onboarding.sh:51` vs help/README `--iter` — docs/onboarding parity lift. |
| README missing 5 commands (D3) | **ACCEPT** | `evidence/readme-parity-diff.txt`; parity §4 FAIL — concrete dim4 lift. |
| `bench`/`run` non-contract scores shape | **ACCEPT** | exit 5 raw jq on `iter-7/scores.json` (`scores: null`) — concrete usability/DX/frontend-boundary lift; **must be added as frozen probe** or it can regress silently. |
| Cold-checkout workspace mismatch (D1) | **NARROW + ESCALATE if destructive** | `workspace_ensure` hard-fails on path pin (`lib/workspace.sh:61-68`; `workspace.json` pins `…/test-rapid-basics/tmp/workspaces/…`). Self-heal that rewrites metadata/worktrees is a **destructive/state** action — owner gate. Prefer honest remedy + non-zero exit over silent overwrite of dirty/foreign worktrees. |
| Style duplicate (D5) | **CUT from CLI work** | Committed taste duplicate is org memory, not introduced by this CLI surface. Do not mutate `state/style/*` to satisfy probe; demote or re-aim the probe if the mission is CLI dispatcher quality. |
| `pool list` missing `error:` prefix | **Optional nit** | Analyst additional; tiny consistency — only if touched anyway. |

### 5. Isolated Ink and OpenTUI spikes after boundary stable

| Verdict | **CUT from accepted build list · ESCALATE** |
|---------|-----------------------------------------------|

**Lift claimed:** evidence for deps/cold-start and architecture decision.  
**Rebuttal:** No failing dimension requires a TUI framework. Dim 10 (deps/cold-start) is capped by **D1 path pins**, not missing React/Ink. Spikes expand dependency/packaging/signal-ownership surface against “No plugin framework… / framework prototypes disposable” while burning iteration budget.  
**Constitution:** architecture change + new dependency class → owner escalation. Disposable spikes only under explicit owner approval, **after** freeze correction and canonical CLI fixes; default = do not run.

### 6. Preserve signal and automation contracts

| Verdict | **CONSTRAINT — not a scored work item** |
|---------|------------------------------------------|

Real provider only, frozen parity, smoke/visual, PTY/signal, transcript — keep as verification gates. No independent benchmark lift. Do not treat “run all the suites” as a deliverable that substitutes for missing probes in item 1.

---

## Required pre-build corrections (owner-approved re-freeze)

1. **Add failing probes** for: `/score <client> --iter <n>` and `/bench <client> run --iter <n>` forwarding (PTY); CLI+slash misuse without `--iter`; quoted multi-word slash argv; `bench`/`run` honest handling of null/`scores`-missing summaries (no raw jq exit 5).
2. **Derive** chat supported/unsupported sets from one registry/source (or generate the parity lists from it) — delete hand-maintained twin lists as the success condition.
3. **Rewrite unsupported-class reasons** so every `out_verbs` entry has an explicit safety or usefulness rationale; either justify read-mostly exclusions (`inspect`/`card`/`pool`) or move them into the supported palette with honest dispatch.
4. **Decouple D5** from “edit durable style memory”: probe CLI dedupe behavior on isolated `CONSULT_STYLE_DIR`, or mark committed duplicate as out-of-scope memory hygiene with owner decision.
5. **Record D1 policy:** mismatch → remedy text + non-zero **or** owner-approved self-heal that refuses dirty/foreign worktrees; never silent overwrite.
6. Bump contract version / refresh `FREEZE-SHA.txt` / keep `tests/cli-interface-parity.sh` hash-coupled per freeze rule.

Until 1–6 land: **stop Builder**.

---

## Accepted work list (only after re-freeze)

1. Slash + CLI argument/usage repairs for `score` / `bench run` (and matching onboarding string).
2. README parity for the five omitted help commands (D3).
3. `bench`/`run` guard for non-contract score summaries (honest message, non-jq exit).
4. Single command registry consumed by help, top-level dispatch validation, slash palette, and parity — **handlers stay in existing modules**; no plugin framework; no `eval`.
5. Document existing machine-readable JSON shapes (no new engagement-selection API).
6. D1: remedy-first mismatch handling; self-heal **only** under owner approval with dirty-workspace refusal.

**Explicitly not accepted now:** Ink/OpenTUI spikes; style.md dedupe-as-fix; new frontend status/command-metadata services; framework retention; any production edit against the current freeze.

---

## Stop / escalation findings

| Finding | Action |
|---------|--------|
| Current freeze omits known signature + score-summary defects | **STOP** implementation; **REJECT** freeze |
| Ink/OpenTUI / any TUI framework prototype | **ESCALATE** (architecture / dependency) |
| Workspace metadata self-heal that can relocate/remove worktrees or clobber dirty state | **ESCALATE** (destructive) |
| Editing committed `state/style/*` to green D5 | **STOP** as false fix / durable-state side effect |
| Registry that becomes a plugin host | **ESCALATE** (architecture); narrow to a table |
| Contract/probe amendment | **ESCALATE** to owner for version bump + new freeze hash |
| Preserve three untracked paths in `baseline-evidence.md` | **STOP** if any accepted work dirties them |

**Bottom line:** Advisor benchmark is useful as a draft probe harness, not as a sealed truth. Rebuttal stands until the freeze captures the mission’s real defects and unsupported chat classes rest on safety/usefulness, not omission preservation.
