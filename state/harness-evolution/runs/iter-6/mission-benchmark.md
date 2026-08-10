# Mission Benchmark — Build 1: Workspace Isolation for Score/Check/Build Paths

| Field | Value |
|-------|-------|
| Mission | Owner-directed operability mission (iteration 1 of 3) |
| Iteration | `iter-6` (mission iteration 1) |
| Build | **Build 1 — workspace isolation for score/check/build paths** (§2–§5, closed) |
| Build 2 | **Judgment gates** — specified in §6 (additive; baseline: `evidence/build-2-baseline.md`) |
| Evidence dir | `state/harness-evolution/runs/iter-6/` |
| Frozen contract | `harness-apc-v1` (files listed in §0 MUST NOT be edited or re-scored) |
| Scorer | Advisor owns this benchmark + baseline evidence; Analyst independently maps implementation gaps |
| Auditability | Pass/fail MUST be decidable from this file + the artifact paths it cites — no chat required |

This file is a **mission-specific acceptance artifact** and lives only in the new
run directory `state/harness-evolution/runs/iter-6/`. It is additive to, and
does not amend, the frozen `harness-apc-v1` contract.

---

## 0. Frozen-file guard (invariants)

The following files are FROZEN and MUST NOT be edited, re-scored, or re-benchmarked
during this mission. A violation of this guard is an automatic Build failure:

- `state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md`
- `state/harness-evolution/contract.json`
- `state/harness-evolution/LOCK.md`
- `state/harness-evolution/FREEZE.md`
- `state/harness-evolution/FREEZE-SHA.txt`
- `state/harness-evolution/engagement.md`
- `state/harness-evolution/LOOP-SEQUENCE.md`
- `state/harness-evolution/authorize-merge`
- `state/harness-evolution/runs/iter-0/…iter-5/` (already-scored runs; never re-scored retroactively)

Audit: `git status --short state/harness-evolution/` shows no modifications outside
`runs/iter-6/` (pre-existing regenerated artifacts like `.checks-latest.json` and
iter-3 skill scaffolds are restored to committed state; see `evidence/baseline-notes.md`).

## 1. Mission constraints (hard gates)

1. **Iteration cap = 3.** This mission runs at most 3 improvement iterations.
   Builds remain ordered 1→2→3→4; an iteration may complete more than one build.
2. **No mocks.** Every acceptance point must be exercised by real commands against
   the real tree. Stubbed, faked, or simulated behavior fails the point.
3. **No second orchestrator.** Workspace isolation may not introduce a second
   control plane (daemon, scheduler, or orchestrator) alongside `bin/consult`.
   `bin/consult` remains the single CLI entry point.
4. **No product code.** This mission changes harness operation only; client-facing
   product behavior is untouched.
5. **Freeze preserved.** §0 guard holds. Builds 2–4 are NOT specified, inspected,
   or implemented in this iteration.
6. **No extra persistence machinery.** No database, plugin router, or RAG
   introduced for isolation; plain directories + existing `bin/consult` conventions.

## 2. Build 1 objective — five workspace-isolation pointers

Owner objective (verbatim pointers confirmed by Main): workspace isolation for
score/check/build paths, acceptance = exactly these five pointers:

| # | Pointer | Observable contract |
|---|---------|---------------------|
| 1 | **Default isolated workspace** | Score/check/build activity resolves a dedicated client worktree (or equivalent isolation) by default and never operates on the owner's dirty live tree implicitly. |
| 2 | **Lifecycle CLI** | `bin/consult` exposes `workspace <client> ensure`, `status`, and `remove`; metadata persists the source and resolved workspace so a later session can inspect and continue. |
| 3 | **Per-score/check evidence** | Every score/check archives the resolved workspace path, HEAD SHA, and dirty state into that invocation's run directory. |
| 4 | **Named dirty refusal/escape** | A dirty resolved workspace refuses score/check reuse by default and names the client workspace; proceeding requires an explicit `--allow-dirty <reason>` whose reason is archived. Removal also refuses a dirty workspace rather than deleting changes. |
| 5 | **Automated refusal/pass + documentation** | The workspace-isolation behaviors above are enforced by automated real-worktree checks (including refuse and pass paths) and documented in README/ARCHITECTURE. |

**Scoring rule (no chat needed):** each pointer is scored **PASS** or **FAIL**
against the concrete audit procedure in §4. Build 1 passes iff all five pointers
PASS. Partial credit is not a pass — the acceptance is exactly the five pointers.
The benchmark must be re-runnable after implementation; baseline evidence in
§3 records the pre-implementation state.

## 3. Baseline evidence (captured 2026-08-10, pre-implementation)

Baseline transcripts and machine-readable results, advisor-owned:

| Artifact | Command | Exit | Result |
|----------|---------|------|--------|
| `evidence/smoke.txt` | `bin/consult smoke` | 0 | all 28 smoke checks passed |
| `evidence/harness-checks.txt` | `bin/consult harness-checks state/harness-evolution/runs/iter-6` | 0 | 22 passed · 0 failed |
| `checks.json` | (written by harness-checks into iter-6) | — | 22/22 pass, `phases-artifact` = `loop-sequence-only` |
| `evidence/baseline-notes.md` | probes + honest gap inventory | — | see below |

### Baseline probe results (all probes re-runnable)

| Probe | Command | Finding |
|-------|---------|---------|
| Workspace verb in CLI | `bin/consult help \| grep -iE "ws\|workspace\|isolat"` | 0 matches — **no workspace concept in CLI** |
| Workspace in docs | `grep -rn -i "workspace\|isolat" README.md AGENTS.md ARCHITECTURE.md docs/` | 0 matches — **undocumented** |
| Dirty handling | `grep -rn -i "dirty" lib/ bin/consult` | 0 matches — **no dirty detection/refusal anywhere** |
| Isolation checks | `grep -c "workspace\|isolat\|dirty" lib/harness-checks.sh` | 0 — **no automated isolation checks** |
| Evidence location | `ls state/engagements/onboarding-flight-control/runs/iter-0/` | score/check evidence lands in the **shared live engagement dir** (`.checks-latest.json`, `iter-N/checks.txt`, `scores.json`) — no isolation |

### Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 Default isolated workspace | **FAIL** | no workspace concept; evidence written to shared `state/engagements/<client>/runs/` (probe: evidence-location) |
| 2 Lifecycle CLI | **FAIL** | `bin/consult help` lists no workspace verb (probe: workspace-verb-in-cli) |
| 3 Per-score/check evidence | **PARTIAL → FAIL (pointer-level)** | per-run evidence exists in shared dirs (`runs/iter-N/checks.txt`), but not per-run-under-workspace with command+exit+output co-located; no isolation |
| 4 Named dirty refusal/escape | **FAIL** | no dirty detection exists (probe: dirty-handling) |
| 5 Automated refusal/pass + documentation | **FAIL** | 0 isolation checks in `lib/harness-checks.sh`; 0 doc mentions (probes: isolation-checks, workspace-in-docs) |

`bin/consult smoke` and `bin/consult harness-checks` both exit 0 today — the
frozen contract suite is green — but neither covers any workspace-isolation
pointer, which is exactly the gap Build 1 exists to close.

## 4. Acceptance audit procedure (machine-runnable, pass/fail without chat)

A scorer (independent of the implementer, per the frozen scoring protocol) runs
the following from repo root. Every check is a real command; output and exit
status are captured to `state/harness-evolution/runs/iter-6/evidence/acceptance-*.txt`
for the final Build 1 verdict. Each pointer is judged only by its own checks.

### Pointer 1 — Default isolated workspace

```sh
# C1.1: workspace lifecycle is discoverable.
bin/consult help | grep -qi 'workspace'

# C1.2: ensure resolves a path distinct from Repo: at a pinned real Git HEAD.
bin/consult workspace <client> ensure
bin/consult workspace <client> status
# Assert status JSON: exists=true, path != source_repo, and sha is a Git commit.

# C1.3: checks/score use the resolved path; there is no live Repo: fallback.
```

PASS iff C1.1–C1.3 pass with real commands and a real detached worktree.

### Pointer 2 — Lifecycle CLI

```sh
# C2.1: exact public lifecycle is discoverable.
bin/consult help | grep -q 'workspace <client> ensure|status|remove'

# C2.2: lifecycle mutates and reports real state.
bin/consult workspace <client> ensure   # creates metadata + worktree
bin/consult workspace <client> status  # valid machine-readable live JSON
bin/consult workspace <client> remove  # removes clean worktree + metadata
```

PASS iff C2.1 and C2.2 all pass.

### Pointer 3 — Per-score/check evidence

```sh
# C3.1: each deterministic check invocation gets a distinct run directory.
bin/consult checks <checks-client>
# Assert its workspace evidence JSON contains resolved path, HEAD SHA, and dirty.

# C3.2: each provider score run archives the same fields beside scores.json.
bin/consult bench <provider-client> run
# Assert runs/iter-N/workspace.json has path, sha, and dirty.
```

PASS iff both score paths archive valid workspace provenance in their run dirs.

### Pointer 4 — Named dirty refusal/escape

```sh
bin/consult workspace <client> ensure
echo change > <resolved-workspace>/scratch.txt

# C4.1: dirty reuse refuses and names the client workspace.
bin/consult workspace <client> ensure              # non-zero expected
bin/consult checks <client>                        # non-zero expected

# C4.2: explicit reason is the only reuse escape and is archived.
bin/consult checks <client> --allow-dirty 'audit requested'
# Workspace evidence records dirty=true and allow_dirty_reason.

# C4.3: remove refuses dirty rather than destroying changes.
bin/consult workspace <client> remove              # non-zero expected
```

PASS iff C4.1–C4.3 pass.

### Pointer 5 — Automated refusal/pass + documentation

```sh
# C5.1: harness checks exercise real lifecycle, default isolation, dirty refusal,
# explicit dirty pass, evidence schema, and safe removal.
bin/consult harness-checks state/harness-evolution/runs/iter-6

# C5.2: seam documentation exists.
grep -i 'workspace' README.md ARCHITECTURE.md
```

PASS iff C5.1 and C5.2 pass.

### Final verdict

```
5 pointers × their checks, all PASS  →  Build 1 PASS
any pointer FAIL                      →  Build 1 FAIL (failing pointers cited)
```

## 5. Out of scope for iteration 1 (do not implement or propose)

- Builds 3–4 of the mission (not yet specified by the owner). Build 2 **is** specified
  in §6 below; §5's blanket "Builds 2–4" exclusion is superseded for Build 2 by §6.
- Client-facing product code, daemons, databases, plugin routers, RAG, or a
  second orchestrator alongside `bin/consult`.
- Formatters, linters, or unrelated project-wide suites (explicitly skipped).

---

# Build 2 — Judgment gates (additive section)

## 6.1 Objective — five judgment-gate pointers

Owner objective (verbatim pointers confirmed by Main): Guided/Challenge/Directive/Override
modes bind Implement per JUDGMENT.md through **durable files** and **machine status**.
Acceptance = exactly these five pointers:

| # | Pointer | Observable contract |
|---|---------|---------------------|
| 1 | **All four modes bind Implement per JUDGMENT** | Guided/Challenge/Directive/Override each decide whether implementation may proceed exactly as JUDGMENT.md prescribes — no silent deviation. |
| 2 | **Required gates are durable files** | Gate state (decision, mode, timestamp) persists in plain per-engagement judgment files; a later session can inspect and continue from files alone. |
| 3 | **Override risks + non-waivers** | Override requires non-empty recorded risks and records critic/evidence/frozen-contract non-waivers in the durable files. |
| 4 | **Machine status** | `consult gate <client> status` emits machine-readable JSON of the gate's current state, including the binding mode decision. |
| 5 | **Per-mode refuse and pass paths** | Each of the four modes has at least one automated refuse path and one automated pass path exercised against the real gate. |

**Scoring rule (no chat needed):** each pointer is scored **PASS** or **FAIL**
against the concrete audit procedure in §6.4. Build 2 passes iff all five pointers
PASS. Partial credit is not a pass. Build 1's five workspace-isolation pointers are
already scored in §4 and are not re-scored here.

**Seam note:** candidate command names (`consult gate <client> status|implement|select|direct|
challenge|override`, per-engagement `judgment/` JSON files) are **illustrative**, not binding.
The implementing Build may choose equivalent names, but it MUST NOT change the semantics of
the pointers above or of JUDGMENT.md. Challenge allows only a selected safer alternative
(JUDGMENT.md: offer safer alternatives — the gate's Challenge path must name one); Override
requires non-empty risks and records critic/evidence/frozen-contract non-waivers
(JUDGMENT.md Override: document unresolved concerns; Override never waives the contract).

**Later consumer:** Build 4's Builder invocation calls the same implement gate, so its
surface (durable `judgment/` files + machine status) is specified here rather than left to
Build 4. This section is additive to the frozen `harness-apc-v1` contract and does not amend it.

## 6.2 Frozen-file guard (unchanged, re-stated for Build 2)

The §0 guard applies unchanged: frozen `harness-apc-v1` files and already-scored
`runs/iter-0/…iter-5/` MUST NOT be edited, re-scored, or re-benchmarked by Build 2.
Build 1 verdicts in §4 and its evidence files are not amended. A violation is an
automatic Build 2 failure.

Audit: `git status --short state/harness-evolution/` shows no modifications outside
`runs/iter-6/` (pre-existing regenerated artifacts restored per `evidence/baseline-notes.md`).

## 6.3 Baseline evidence (captured 2026-08-10, pre-implementation)

Advisor-owned baseline: `evidence/build-2-baseline.md` (same conventions as the Build 1
baseline). Summary of the re-runnable probes and findings:

| Probe | Command | Finding |
|-------|---------|---------|
| Implement gate verb | `bin/consult help \| grep -ic gate` | 0 — **no gate command in CLI** |
| Gate dispatch | `grep -n "gate)" bin/consult` | none — **no dispatch branch** |
| Durable gate artifacts | `find . -type d -name judgment`; `find state -name "*.json" \| grep -i "gate\|judgment"` | 0 dirs, 0 files — **no `judgment/` gate state anywhere** |
| Judge show/set exists | `bin/consult help` → `consult judge <client> [set <mode>]`; `tests/consult-smoke.sh:17,30,56` | **present** — mode selectable via `engagement.md` text only |
| Override risks (runtime) | `ls state/harness-evolution/examples/` | only static `override-risks.md` + `challenge-refusal.md` examples; `run_check judgment-examples` (`lib/harness-checks.sh:93`) checks presence only — **no run-time risks/non-waiver recording** |
| Machine status | `bin/consult status` = org overview (`cmd_status`, `bin/consult:208`); `judge show` prints mode+mission as text | **no machine-readable gate status** |
| Per-mode refuse/pass checks | `grep -c "gate\|implement" tests/consult-smoke.sh tests/workspace-smoke.sh lib/harness-checks.sh` | 0 each — **no automated gate refusal/pass tests** |

### Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 All four modes bind Implement per JUDGMENT | **FAIL** | modes documented (JUDGMENT.md) + selectable (`consult judge … set`) but nothing decides/records implementability per mode |
| 2 Required gates are durable files | **FAIL** | no `judgment/` files or gate JSON in `state/` |
| 3 Override risks + non-waivers | **FAIL** | only static example artifact; no run-time risk/non-waiver requirement |
| 4 Machine status | **FAIL** | no `consult gate <client> status`; `status` is org overview; judge show is text |
| 5 Per-mode refuse and pass paths | **FAIL** | 0 gate checks in harness-checks and both smoke tests (Build 1's dirty refuse/pass are isolation paths, not judgment gates) |

`bin/consult smoke` and `bin/consult harness-checks` both exit 0 today — the frozen
contract suite is green — but neither covers any Build 2 pointer. Full probe inventory
and command citations: `evidence/build-2-baseline.md`.

## 6.4 Acceptance audit procedure (machine-runnable, pass/fail without chat)

A scorer (independent of the implementer) runs the following from repo root. Every check
is a real command; output and exit status are captured to
`state/harness-evolution/runs/iter-6/evidence/acceptance-build-2-*.txt`. Each pointer is
judged only by its own checks. Gate verbs below are the illustrative candidate names from
§6.1; if the implementation ships equivalent names, the scorer substitutes the shipped
names without changing pointer semantics.

### Pointer 1 — All four modes bind Implement per JUDGMENT

```sh
# G1.1: implement gate is discoverable.
bin/consult help | grep -qi 'gate'

# G1.2: each mode's decision matches JUDGMENT.md, recorded in durable gate state.
bin/consult judge <client> set Guided
bin/consult gate <client> implement          # REFUSE — Guided requires selection first
bin/consult gate <client> select <direction> # choose a direction (Guided pass path)
bin/consult gate <client> implement          # PASS — direction selected, scope recorded
bin/consult judge <client> set Directive
bin/consult gate <client> implement          # PASS — smallest diff per direction
bin/consult judge <client> set Challenge
bin/consult gate <client> implement          # REFUSE — harmful path refused
bin/consult judge <client> set Override
bin/consult gate <client> override <risks>   # PASS — explicit decision + risks recorded
```

PASS iff G1.1–G1.2 pass with real commands and durable gate state.

### Pointer 2 — Required gates are durable files

```sh
# G2.1: gate state persists as plain files under the client engagement.
bin/consult gate <client> status
# Assert per-engagement judgment/ files exist and contain mode + decision + timestamp.

# G2.2: a later session re-derives the same gate decision from files alone.
bin/consult gate <client> status   # second invocation, same JSON decision
```

PASS iff G2.1 and G2.2 pass.

### Pointer 3 — Override risks + non-waivers

```sh
# G3.1: Override with empty risks refuses and records nothing.
bin/consult gate <client> override ''          # non-zero expected

# G3.2: Override requires non-empty risks and records non-waivers.
bin/consult gate <client> override 'flaky lint may hide a regression'
# Assert durable file records: non-empty risks, critic consulted, evidence required,
# frozen-contract harness-apc-v1 NOT waived.
```

PASS iff G3.1 and G3.2 pass.

### Pointer 4 — Machine status

```sh
# G4.1: machine-readable gate status.
bin/consult gate <client> status
# Assert valid JSON: client, mode, decision, gate state, updated timestamp.

# G4.2: status reflects the last durable decision without chat.
bin/consult judge <client> set Challenge
bin/consult gate <client> implement            # non-zero expected (refusal)
bin/consult gate <client> status
# Assert JSON decision == refused and mode == Challenge.
```

PASS iff G4.1 and G4.2 pass.

### Pointer 5 — Per-mode refuse and pass paths

```sh
# G5.1: automated checks exercise each mode's refuse and pass paths on the real gate.
bin/consult harness-checks state/harness-evolution/runs/iter-6
# Assert check ids: gate-guided-refuse, gate-guided-pass, gate-directive-refuse,
# gate-directive-pass, gate-challenge-refuse, gate-challenge-alternative,
# gate-override-refuse, gate-override-pass.
```

PASS iff G5.1 passes with real refusals and passes per mode (every mode: ≥1 refuse, ≥1 pass).

### Final verdict

```
5 pointers × their checks, all PASS  →  Build 2 PASS
any pointer FAIL                      →  Build 2 FAIL (failing pointers cited)
```

## 6.5 Out of scope for Build 2 (do not implement or propose)

- Builds 3–4 of the mission (not yet specified by the owner).
- Client-facing product code, daemons, databases, plugin routers, RAG, or a
  second orchestrator alongside `bin/consult`.
- Formatters, linters, or unrelated project-wide suites (explicitly skipped).
- Any edit to frozen `harness-apc-v1` files or re-scoring of Build 1 verdicts.

---

# Build 3 — Durable escalations, pause/authorized resume, and file-derived inspect (additive section)

## 7.1 Objective — five Build 3 pointers

Acceptance is exactly the owner's five pointers:

| # | Pointer | Observable contract |
|---|---------|---------------------|
| 1 | **Engagement escalation state** | Per-engagement `escalations.json` records blocked and resolved states, non-empty options, and a resume token. |
| 2 | **Inspectable pause** | Blocking an escalation also writes a durable pause artifact; score/check/Implement refuse while it is paused. |
| 3 | **Authorized resume + MEMORY** | Resume requires a separate owner authorization artifact matching the escalation/token, then records resolved machine state and appends a durable MEMORY continuation pointer. |
| 4 | **File-derived inspect pack** | `consult inspect <client>` regenerates mode/gates, scores/history, escalations, lessons pointer, and next suggested action from files only. Missing inputs are explicit, never invented from chat. |
| 5 | **Real lifecycle proof** | Automated real CLI evidence proves block → pause → refuse without authorization → authorized resume, plus honest pack regeneration with missing inputs. |

Build 3 passes iff all five pointers PASS under §7.4. Partial credit is not a
pass. Builds 1–2 are already scored and are not re-scored here.

**Real-proof rule:** no mocks. Acceptance uses real CLI commands and real files.

**Seam note:** command/file names in §7.3 are illustrative; their semantics are
binding. A blocked escalation and its pause are one state transition, not
advisory prose. The resume token is a correlation receipt, not authorization;
the separate manual authorization file is mandatory. The default MEMORY target
is repo-root `MEMORY.md`; `CONSULT_MEMORY_FILE` isolates real tests.

**Frozen-file guard (unchanged, re-stated for Build 3):** the §0 guard applies
unchanged; `runs/iter-0/…iter-5/` and frozen `harness-apc-v1` files MUST NOT be
edited, re-scored, or re-benchmarked by Build 3. Build 1 and Build 2 verdicts and
evidence are not amended. A violation is an automatic Build 3 failure.

Audit: `git status --short state/harness-evolution/` shows no modifications
outside `runs/iter-6/` (pre-existing regenerated artifacts restored per
`evidence/baseline-notes.md`; `state/harness-evolution/judgment/` is Build 2's
own durable gate state and is not touched by Build 3).

## 7.2 Baseline evidence (captured 2026-08-10, pre-implementation)

Advisor-owned baseline: `evidence/build-3-baseline.md` (same conventions as the
Build 1 and Build 2 baselines). Summary of the re-runnable probes and findings:

| Probe | Command | Finding |
|-------|---------|---------|
| Escalation/pause/inspect verbs | `bin/consult help \| grep -iE "escalat\|pause\|resume\|inspect"` | 0 matches — **no Build 3 verbs in CLI** |
| Escalation artifacts | `find . -name "escalations.json"` (and `*escalat*` under `state/engagements/`) | 0 files — **no durable per-engagement escalation state**; escalations exist only as prose in `MEMORY.md` §Escalations |
| Escalation blocking/enforcement | `grep -rniE "escalat" bin/ lib/ tests/` | only role prose (`bin/consult:279` "Escalate: …") — **no block/options/token mechanics** |
| Pause / resume artifacts | `find . \( -name "pause.json" -o -name "authorize-resume.json" \)` | 0 files — **no pause or resume concept** |
| Pause predicate shared with gate | `grep -rn "pause" lib/judgment-gate.sh bin/consult` | 0 — **no shared block predicate** |
| File-derived inspect | `bin/consult help \| grep inspect`; `find . -name "inspect-pack*"` | 0 matches, 0 files — **no `consult inspect`, no pack** |
| MEMORY override for isolated tests | `grep -rn "CONSULT_MEMORY_FILE" bin/ lib/ tests/` | 0 matches — **no override seam**; memory commands read `$ROOT/MEMORY.md` (`cmd_memory`, `bin/consult:485-488`) |

### Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 Engagement escalation state | **FAIL** | no per-engagement escalation JSON, options, blocked/resolved state, or token |
| 2 Inspectable pause | **FAIL** | no pause artifact or shared progress-block predicate |
| 3 Authorized resume + MEMORY | **FAIL** | no authorize-resume artifact, resume transition, machine continuation, or MEMORY override/writer |
| 4 File-derived inspect pack | **FAIL** | no inspect command/pack combining the required file sources or explicit missing markers |
| 5 Real lifecycle proof | **FAIL** | the green 35-check suite has no block/pause/resume/inspect path |

`bin/consult smoke` and `bin/consult harness-checks` both exit 0 today — 35/35
harness checks pass — but none of those checks exercises any Build 3 pointer.
Full probe inventory, command citations, and the suite-state table:
`evidence/build-3-baseline.md`.

## 7.3 Candidate minimal design (illustrative seams, NOT binding)

- `consult escalation <client> block <id> <summary> <option> [option...]`
  atomically adds a blocked entry with options + resume token to
  `escalations.json` and writes `pause.json`.
- One shared predicate blocks `checks`, `score`/provider bench, and
  `gate … implement` while an entry is blocked or pause state is active.
- The owner manually creates `authorize-resume.json` containing matching
  escalation id/token, authorization identity, and decision. `consult
  escalation <client> resume <id> <token>` validates it, marks the entry
  resolved, stamps pause + authorization consumed, writes engagement
  continuation state, and appends a MEMORY pointer. Resume without the file or
  on mismatched values refuses without partial state changes.
- `consult inspect <client>` rewrites engagement `inspect-pack.json` from
  `engagement.md`, judgment files, score files/history, escalations/pause, and
  latest lessons. Every required component is present or explicitly
  `{missing:true}`. `next_suggested_action` follows the derived pause/gate/score
  state.

## 7.4 Acceptance audit procedure (machine-runnable, pass/fail without chat)

A scorer (independent of the implementer) runs the following from repo root.
Every check is a real command; output and exit status are captured to
`state/harness-evolution/runs/iter-6/evidence/acceptance-build-3-*.txt`. Each
pointer is judged only by its own checks. Seam names below are the illustrative
candidates from §7.1/§7.3; if the implementation ships equivalent names, the
scorer substitutes the shipped names without changing pointer semantics.

### Pointer 1 — Engagement escalation state

```sh
bin/consult escalation <client> block e1 '<summary>' '<option 1>' '<option 2>'
# escalations.json entry: status=blocked, options non-empty, resume_token non-empty
bin/consult escalation <client> status
```

PASS iff blocked/resolved state, options, and token are durable and machine
readable.

### Pointer 2 — Inspectable pause

```sh
# The block command above also writes pause.json.
bin/consult gate <client> implement
bin/consult checks <client>
# both non-zero and name the blocking engagement artifact
```

PASS iff pause state is inspectable and the shared predicate blocks progress.

### Pointer 3 — Authorized resume + MEMORY

```sh
bin/consult escalation <client> resume e1 <token>  # refuses: no authorization
# Owner manually writes authorize-resume.json with matching id/token + decision.
bin/consult escalation <client> resume e1 <token>  # exit 0
# Assert escalation resolved, pause resumed, authorization consumed,
# engagement continuation state written, MEMORY pointer appended.
```

PASS iff missing/mismatched auth cannot resume and successful resume updates all
machine/MEMORY state without partial clear.

### Pointer 4 — File-derived inspect pack

```sh
bin/consult inspect <client>
# Assert mode/gates, scores/history, escalations, lessons pointer, next action.
bin/consult inspect <client-with-missing-inputs>
# Assert every absent required source has an explicit missing marker.
```

PASS iff both packs are derived entirely from files and regenerate honestly.

### Pointer 5 — Real lifecycle proof

```sh
tests/escalation-smoke.sh
bin/consult harness-checks state/harness-evolution/runs/iter-6
# Required markers cover block, pause, unauthorized refusal, authorized resume,
# MEMORY/continuation update, pack regeneration, and missing-input honesty.
```

PASS iff the complete real CLI lifecycle passes without mocks.

### Final verdict

```
5 pointers × their checks, all PASS  →  Build 3 PASS
any pointer FAIL                      →  Build 3 FAIL
```

## 7.5 Out of scope for Build 3 (do not implement or propose)

- Build 4 (role-envelope inspection; not specified by the owner) — untouched.
- Client-facing product code, daemons, databases, plugin routers, RAG, or a
  second orchestrator alongside `bin/consult`.
- Formatters, linters, or unrelated project-wide suites (explicitly skipped).
- Any edit to frozen `harness-apc-v1` files, `runs/iter-0/…iter-5/`, or
  re-scoring of Build 1/Build 2 verdicts.

---

# Build 4 — Role envelope: invoke + status, sealed Builder input, request/result/manifest evidence, authorship close/score gates (additive section)

## 8.1 Objective — five Build 4 pointers

Acceptance is exactly the owner's five pointers:

| # | Pointer | Observable contract |
|---|---------|---------------------|
| 1 | **Role invoke + status over the existing provider seam** | A single CLI surface invokes Analyst / Builder / Critic as **single-turn** role calls through the existing authenticated provider seam (`lib/provider.sh` `provider_ask` / `runtime_detect` / `runtime_default`; real `CONSULT_PROVIDER` or detected coding runtime — no mocks). A matching status command answers asked / ran / produced. |
| 2 | **Per-iteration sealed Builder input** | Before any Builder run, the iteration's Builder input is sealed (write-once, content-addressed). Builder invocation refuses when the seal is missing or the input no longer matches the sealed hash. |
| 3 | **Request / result / manifest evidence** | Every Analyst / Builder / Critic invocation leaves plain-file request, result, and manifest (or equivalent) artifacts recording **role, provider, timestamps, exit, and content hashes**. |
| 4 | **Close / score authorship gates** | Scores without an Analyst stamp are **invalid**. Close refuses without a Critic record. The implementer is never the evaluator of the same work (`implementer = evaluator` is rejected). |
| 5 | **File-derived status; Builder-without-seal + authorship proofs** | Status answers asked / ran / produced **from the envelope files only** — no chat logs, no transcripts. Automated real CLI evidence proves Builder-without-seal refusal and the authorship close/score gates. |

Build 4 passes iff all five pointers PASS under §8.4. Partial credit is not a
pass. Builds 1–3 are already scored and are not re-scored here. §5's and §6.5's /
§7.5's "Build 4 not yet specified / untouched" exclusions are superseded for
Build 4 by this section; those earlier sections themselves are not edited.

**Real-proof rule:** no mocks, no chat-log evidence. Acceptance uses real CLI
commands against a real authenticated coding runtime resolved by the existing
provider seam. Single-turn role calls are sufficient (no multi-turn agent loop).

**Seam note:** command and file names in §8.3–§8.4 are **illustrative**, not
binding. The implementing Build may choose equivalent names, but it MUST NOT
change pointer semantics. Required reuse (not replacement):

- `bin/consult` remains the single CLI entry point.
- `lib/provider.sh` (`provider_ask`, `runtime_detect`, `runtime_default`,
  `CONSULT_PROVIDER`) is the **only** model entry point — no second provider,
  no mock provider, no in-process model.
- Build 2's implement gate (`consult gate <client> implement`, durable
  `judgment/` files + machine status) is the surface Build 4's Builder
  invocation calls (see §6.1 later-consumer note); Build 4 does not re-implement
  the gate.
- Build 3's engagement-state / inspect seams remain the file-derived status
  precedent; Build 4 adds role envelopes beside them, not a second status plane.

**Prohibitions (automatic FAIL if introduced):** chat-log or transcript evidence;
mocks / stub providers; daemons; databases; plugin routers; RAG; message buses;
swarms; auto-orchestrators; a second orchestrator alongside `bin/consult`.

**Frozen-file guard (unchanged, re-stated for Build 4):** the §0 guard applies
unchanged; `runs/iter-0/…iter-5/` and frozen `harness-apc-v1` files MUST NOT be
edited, re-scored, or re-benchmarked by Build 4. Build 1, Build 2, and Build 3
verdicts and evidence are not amended. A violation is an automatic Build 4
failure.

Audit: `git status --short state/harness-evolution/` shows no modifications
outside `runs/iter-6/` (pre-existing regenerated artifacts restored per
`evidence/baseline-notes.md`; `state/harness-evolution/judgment/` is Build 2's
own durable gate state and is not touched by Build 4).

## 8.2 Baseline evidence (captured 2026-08-10, pre-implementation)

Advisor-owned baseline: `evidence/build-4-baseline.md` (same conventions as the
Build 1–3 baselines). Summary of the re-runnable probes and findings:

| Probe | Command | Finding |
|-------|---------|---------|
| Role invoke/status verbs | `bin/consult help \| grep -icE "role invoke\|role-invoke\|envelope\|request\|manifest"`; `bin/consult role analyst invoke 'x'` | 0 help matches; `error: unknown command 'role'` — **no role invoke/status surface** |
| Dispatch branch | `grep -cE '^[[:space:]]+(invoke\|role)\)' bin/consult` | 0 — **no role/invoke dispatch** |
| Request/result/manifest artifacts | `find . -path ./.git -prune -o \( -name request.json -o -name result.json -o -name manifest.json \) -print` | 0 files; `find state/engagements -type d -name roles` → 0 — **no envelope artifacts** |
| Seal concept | `grep -rni "seal" bin/ lib/ tests/` | 0 — **no sealed Builder input, no Builder-without-seal refusal** |
| Analyst stamp | `grep -rni "stamp" bin/ lib/ tests/`; `jq .evaluator state/harness-evolution/runs/iter-5/scores.json` | only escalation/timestamp prose; `evaluator` is optional free text (`"independent-analyst"` or `null`) — **no stamp gate, scores never invalidated for missing Analyst stamp** |
| Close / authorship gates | `bin/consult help \| grep -ci close`; `grep -rniE "close.*gate\|closeout" bin/consult lib/*.sh` | 0 / 0 — **no close verb, no Critic-required close, no implementer≠evaluator rejection** |
| Provider seam (reuse target) | `bin/consult runtime`; `grep -rn provider_ask bin/ lib/` | real authenticated `agent` active (`/home/logani/.local/bin/agent`); sole `provider_ask` callsite is `bin/consult:664` (`cmd_bench_run`) — **seam exists; role-envelope invoke over it does not** |
| Chat logs / daemon-bus | `find state -iname "*chat*" -o -iname "*transcript*"`; `grep -rniE "daemon\|message bus\|swarm\|auto-orchestrat" bin/ lib/ tests/` | 0 / 0 — no chat-log evidence and no bus/swarm machinery (constraint already holds; Build 4 must keep it) |
| File-derived status precedent | `jq -r 'keys \| join(", ")' state/harness-evolution/inspect-pack.json` | Build 3 pack keys cover mode/gates/scores/escalations/lessons — **no role asked/ran/produced** |

### Honest baseline verdict (pre-implementation)

| Pointer | Baseline status | Evidence |
|---------|----------------|----------|
| 1 Role invoke + status over the existing provider seam | **FAIL** | provider seam is real and authenticated, but there is no role invoke/status verb and no dispatch branch; the only model call is the hard-coded Analyst bench prompt |
| 2 Per-iteration sealed Builder input | **FAIL** | zero seal references; no write-once seal; no Builder-without-seal refusal |
| 3 Request / result / manifest evidence | **FAIL** | 0 request/result/manifest files and 0 role dirs; worker output is only `scores.json` / optional `raw-provider-output.txt` — no envelope with role/provider/ts/exit/hashes |
| 4 Close / score authorship gates | **FAIL** | no Analyst stamp; `evaluator` is optional free text; no close verb; no Critic-required close; no implementer≠evaluator rejection |
| 5 File-derived status; Builder-without-seal + authorship proofs | **FAIL** | inspect-pack is file-derived but answers no role asked/ran/produced; the green 42-check suite has no seal-refusal or authorship-gate path |

`bin/consult smoke` and `bin/consult harness-checks` both exit 0 today — 42/42
harness checks pass — but none of those checks exercises any Build 4 pointer.
Full probe inventory, command citations, and the suite-state table:
`evidence/build-4-baseline.md`.

## 8.3 Candidate minimal design (illustrative seams, NOT binding)

- `consult role <client> invoke <Analyst\|Builder\|Critic> <task> [iter]`
  performs a **single-turn** prompt via `provider_ask` (existing seam) against
  the resolved workspace. Missing / unauthenticated provider refuses (non-zero)
  the same way `runtime --check` and `bench … run` already do. No multi-turn
  agent loop, no second provider.
- Every successful or failed invocation writes, under the engagement (e.g.
  `roles/<iter>/<role>/` or equivalent):
  - `request.json` — role, client, iter, provider, task/input, input hash, requested_at
  - `result.json` — role, provider, exit, output summary / artifact refs, ran_at
  - `manifest.json` — indexes request+result with role, provider, timestamps,
    exit, and sha256 of both files
  Atomic writers (tmp + rename), plain JSON, no database.
- **Builder seal (write-once, content-addressed):** before any Builder invoke,
  `consult role <client> seal <iter> <input-path-or-payload>` writes a seal
  artifact recording the sealed input hash, role=Builder, iter, sealed_at.
  Second seal for the same iter refuses. Builder invoke recomputes the input
  hash against the seal and refuses on missing seal or hash mismatch (Builder-
  without-seal refusal). Builder invoke also calls the existing implement gate
  (`gate … implement`) so Build 2 authorship of the direction is preserved.
- **Analyst stamp:** a successful Analyst invoke (or an explicit stamp step)
  leaves a durable stamp on the iteration (e.g. `analyst-stamp.json` or a
  non-empty stamp field on the score envelope) carrying role=Analyst, provider,
  identity, and the stamped result hash. Score / bench paths treat scores
  without that stamp as **invalid** (refuse or mark `invalid:true` — never
  silently accept).
- **Close gate:** `consult role <client> close <iter>` (or equivalent) refuses
  when no Critic request/result/manifest exists for the iteration, and refuses
  when the implementer identity equals the evaluator identity for that work.
  Critic verdict free-files alone are not sufficient — the Critic envelope must
  be present.
- **Status:** `consult role <client> status [iter]` emits machine JSON whose
  `asked` / `ran` / `produced` fields are derived **only** from the envelope
  files above. Explicit missing markers when envelopes are absent. Status never
  reads chat logs, transcripts, or live process memory; repeated status with
  unchanged files is byte-stable (no wall-clock drift in the derived answer).

## 8.4 Acceptance audit procedure (machine-runnable, pass/fail without chat)

A scorer (independent of the implementer) runs the following from repo root.
Every check is a real command against a real authenticated coding runtime
resolved by the existing provider seam; output and exit status are captured to
`state/harness-evolution/runs/iter-6/evidence/acceptance-build-4-*.txt`. Each
pointer is judged only by its own checks. Seam names below are the illustrative
candidates from §8.1/§8.3; if the implementation ships equivalent names, the
scorer substitutes the shipped names without changing pointer semantics.

### Pointer 1 — Role invoke + status over the existing provider seam

```sh
# R1.1: role invoke/status are discoverable.
bin/consult help | grep -qi 'role'

# R1.2: single-turn Analyst invoke goes through the existing provider seam with
# a real authenticated runtime (CONSULT_PROVIDER or runtime_default must resolve).
bin/consult runtime --check                              # exit 0 — real runtime present
bin/consult role <client> invoke Analyst '<single-turn task>' [iter]
# Assert exit 0; request.json + result.json + manifest.json exist under the
# engagement; each records role=Analyst, provider (resolved binary name),
# timestamps, exit; the only model entry point used is provider_ask
# (lib/provider.sh) — audit: no new ask function, no mock provider binary.

# R1.3: missing / unauthenticated provider refuses honestly (no mock fallback).
CONSULT_PROVIDER=/nonexistent/no-such-provider \
  bin/consult role <client> invoke Analyst '<task>'      # non-zero expected

# R1.4: role status is machine-readable JSON.
bin/consult role <client> status [iter]
# Assert valid JSON answering asked / ran / produced from the envelope files.
```

PASS iff R1.1–R1.4 pass with real single-turn calls over the existing
authenticated provider seam (no mocks).

### Pointer 2 — Per-iteration sealed Builder input

```sh
# R2.1: Builder invoke without a seal refuses and names the missing seal.
bin/consult role <client> invoke Builder '<task>' [iter] # non-zero expected; names seal

# R2.2: seal is write-once and content-addressed.
bin/consult role <client> seal <iter> <input-path>       # exit 0; seal records sha256 + role + iter + sealed_at
bin/consult role <client> seal <iter> <input-path>       # non-zero expected (already sealed)

# R2.3: sealed, unchanged input allows Builder invoke (which also respects the
# existing implement gate — Build 2 surface).
bin/consult role <client> invoke Builder '<task>' [iter] # exit 0 when gate allows + seal matches

# R2.4: tampered input after seal refuses (hash mismatch).
# mutate <input-path>
bin/consult role <client> invoke Builder '<task>' [iter] # non-zero expected; names seal hash mismatch
```

PASS iff R2.1–R2.4 pass: missing seal refuses, seal is write-once, matching
seal allows, tampered input refuses.

### Pointer 3 — Request / result / manifest evidence

```sh
# R3.1: Analyst, Builder, and Critic each leave request + result + manifest.
bin/consult role <client> invoke Analyst  '<task>' [iter]
bin/consult role <client> seal <iter> <builder-input> && \
  bin/consult role <client> invoke Builder '<task>' [iter]
bin/consult role <client> invoke Critic   '<task>' [iter]
# Assert each role's envelope directory contains:
#   request.json  — role, provider, timestamps, input/task, input hash
#   result.json   — role, provider, timestamps, exit
#   manifest.json — role, provider, timestamps, exit, sha256(request), sha256(result)
# All three roles present for the iteration; hashes verify (sha256sum).

# R3.2: status / inspect can re-derive the envelope inventory from files alone
# after a fresh process (no in-memory state required).
bin/consult role <client> status [iter]
# Assert asked/ran/produced enumerate the three roles' envelopes.
```

PASS iff every role invocation leaves complete request/result/manifest (or
equivalent) artifacts with role, provider, timestamps, exit, and hashes, and
status re-derives them from files alone.

### Pointer 4 — Close / score authorship gates

```sh
# R4.1: scores without an Analyst stamp are invalid.
# Prepare an iteration with no Analyst stamp (or with stamp removed).
bin/consult score <client>                               # or bench <client> run / shipped score path
# non-zero expected OR scores marked invalid:true — never silently accepted.
# Assert the refusal/invalidation names the missing Analyst stamp.

# R4.2: close refuses without a Critic envelope for the iteration.
bin/consult role <client> close <iter>                   # non-zero expected; names missing Critic

# R4.3: implementer = evaluator is rejected.
# Stamp the same identity as both Builder (implementer) and Analyst/evaluator
# on the iteration, then:
bin/consult score <client>                               # non-zero / invalid
bin/consult role <client> close <iter>                   # non-zero expected
# Assert the refusal names the implementer=evaluator collision.

# R4.4: happy path — Analyst stamp present, Critic envelope present, distinct
# implementer vs evaluator identities → score valid and close succeeds.
bin/consult role <client> invoke Analyst '<task>' [iter] # produces stamp
bin/consult role <client> invoke Critic  '<task>' [iter]
bin/consult score <client>                               # exit 0 / scores valid
bin/consult role <client> close <iter>                   # exit 0
```

PASS iff R4.1–R4.4 pass: no Analyst stamp → scores invalid; no Critic → cannot
close; implementer = evaluator rejected; honest happy path closes.

### Pointer 5 — File-derived status; Builder-without-seal + authorship proofs

```sh
# R5.1: status answers asked / ran / produced from envelope files only.
bin/consult role <client> status [iter]
# Assert JSON fields asked[], ran[], produced[] (or equivalent) are populated
# exclusively from request/result/manifest files; the JSON references no chat
# transcript, conversation log, or live process path. Two consecutive status
# invocations with unchanged files produce byte-identical derived answers
# (no wall-clock drift in asked/ran/produced).

# R5.2: automated real-CLI checks cover the refusal and authorship gates.
# Required markers (or equivalent shipped ids) in harness-checks / role smoke:
#   role-invoke-provider-seam
#   role-builder-seal-refusal
#   role-builder-seal-mismatch
#   role-envelope-request-result-manifest
#   role-score-no-analyst-stamp
#   role-close-no-critic
#   role-implementer-evaluator-rejected
#   role-status-file-derived
tests/role-envelope-smoke.sh                             # or equivalent real-CLI suite
bin/consult harness-checks state/harness-evolution/runs/iter-6

# R5.3: prohibition audit — no chat-log evidence, no mocks, no daemon/DB/
# router/RAG/bus/swarm/auto-orchestrator introduced by Build 4.
find state -iname '*chat*' -o -iname '*transcript*'      # still 0 new chat-log evidence paths required by status/close/score
grep -rniE 'daemon|message bus|swarm|auto-orchestrat' bin/ lib/ tests/
# no new matches that Build 4 relies on; provider_ask remains the sole model entry point
grep -rn 'provider_ask' bin/ lib/                        # still only lib/provider.sh definition + consult callsites
```

PASS iff R5.1–R5.3 pass: status is fully file-derived, the refusal/authorship
gates are exercised by real automated CLI evidence, and the prohibitions hold.

### Final verdict

```
5 pointers × their checks, all PASS  →  Build 4 PASS
any pointer FAIL                      →  Build 4 FAIL (failing pointers cited)
```

## 8.5 Out of scope for Build 4 (do not implement or propose)

- Client-facing product code, daemons, databases, plugin routers, RAG, message
  buses, swarms, auto-orchestrators, or a second orchestrator alongside
  `bin/consult`.
- Chat-log or transcript evidence; mock / stub providers; multi-turn agent loops
  required for acceptance (single-turn is sufficient and required).
- Formatters, linters, or unrelated project-wide suites (explicitly skipped).
- Any edit to frozen `harness-apc-v1` files, `runs/iter-0/…iter-5/`, or
  re-scoring of Build 1 / Build 2 / Build 3 verdicts.
- Replacing the existing provider seam, implement gate, or engagement-state /
  inspect seams — Build 4 reuses them.
