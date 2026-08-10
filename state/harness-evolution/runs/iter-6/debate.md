# Critic debate — Build 1 (pre-implementation)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — follow owner direction; refuse silent scope expansion; smallest diff
**Against:** Principal Build 1 proposal (goal-loop “Engagement workspace isolation”) + Analyst gap map (`consult worktree ensure|status|remove`, `lib/workspace.sh`, dirty/`CONSULT_ALLOW_DIRTY`, evidence archive)
**Acceptance target:** exactly the five owner pointers in `mission-benchmark.md` §2 / §4
**Frozen:** §0 files + iter-0..5 — do not edit
**Out of scope:** Builds 2–4 (not inspected, not proposed)
**Stance:** An item survives only with a concrete pointer lift. No product code. No validation commands run in this debate.

---

## Overall verdict

**AMEND the proposal before implement.** The direction is right (isolate score/check/build from the live `Repo:` tree; fail closed; document + automate). As written, the Principal/Analyst package **does not yet satisfy the five owner pointers**:

| Drift | Proposal says | Owner pointer requires |
|-------|---------------|------------------------|
| CLI verbs | `ensure\|status\|remove` (or `worktree …`) | `create`, `list`, `enter/select`, `close/destroy` discoverable via help |
| Default path | Score when “configured”; refuse if missing / live dirty | **No selection → still isolated**; never the live tree |
| Dirty object | Live/`Repo:` dirty + env escape | **Workspace** dirty: refuse silent **reuse** and unescaped **destroy**; refusal **names** the workspace; escape **names** it |
| Evidence | `workspace.txt` / fields into engagement run or `runs/iter-6/` | **Under that workspace**, one set per run: exact command + exit + output |
| Skill path | Analyst wires `run-skill.sh` | Pointers are score/check/build only — skill is scope creep |

Constitution: delete-before-add favors **one** seam (`lib/workspace.sh`, same precedent as `lib/github.sh`), not a second orchestrator. Directive mode forbids expanding into judgment gates, escalations, or role envelopes (Builds 2–4). Architecture: CLI remains `bin/consult`; state stays plain directories; no DB/daemon/plugin/RAG.

Analyst baseline evidence (`mission-benchmark.md` §3, `evidence/baseline-notes.md`) is accepted: all five pointers FAIL today; smoke/harness-checks green only because they do not cover isolation.

---

## Proposed elements — rebuttal matrix

Lenses: **scope · correctness · git worktree safety · dirty semantics · evidence placement · test realism · CLI compatibility**.

### E1. `lib/workspace.sh` seam (ensure/status/resolve/dirty)

| Verdict | **ACCEPT** (mechanism) · **AMEND** (API surface) |
|---------|---------------------------------------------------|

**Pointer lift:** Enables P1–P4. Without a single module, wiring duplicates and invites a second control plane.

**Rebuttal:** Correct shape (thin sourced library). Rename mental model from “ensure-only” to lifecycle helpers matching P2. Prefer real `git worktree` (no mocks — mission hard gate). Worktree path: sibling-adjacent or `$CONSULT_WORKROOT` — **never** under `state/engagements/` or nested inside the harness tree (ARCHITECTURE sibling rule; Principal proposal already says this — keep it).

**Risks:** Mutates source repo `.git/worktrees` metadata; `close/destroy` must `git worktree remove` / prune or leaves orphans. Detached HEAD at pinned SHA is safer for score reproducibility than tracking a moving branch.

---

### E2. Per-engagement `workspace.json` metadata

| Verdict | **ACCEPT** (narrow) |
|---------|---------------------|

**Pointer lift:** Supports P1 (resolve isolation root) and P2 (list/status). Record at least: name, source `Repo:`, worktree path, created_ts, head_sha (or documented HEAD policy).

**Rebuttal:** Keep one JSON (or one file per named workspace under the isolation root). Do not invent a registry service. Do not store under frozen harness-evolution lock paths.

---

### E3. CLI `consult workspace|worktree <client> ensure|status|remove`

| Verdict | **AMEND** → owner verbs |
|---------|-------------------------|

**Pointer lift if amended:** P2 (and help discoverability for P1/C1.1, P5).

**Rebuttal:** `ensure|status|remove` fails C2.1/C2.2. Corrected surface (names may be `ws` alias):

```text
consult workspace create <name>
consult workspace list
consult workspace enter <name>    # select; subsequent score/check/build use it
consult workspace close <name>    # destroy; dirty → named refuse unless escaped
```

`status` may fold into `list` detail — not a substitute for `enter`. Help text must match `/workspace|\bws\b/` and list create/list/enter/close|destroy.

**CLI compatibility:** Extend `cmd_help` + dispatch in `bin/consult` only. No new top-level binary.

---

### E4. Wire `checks` / `score` / `bench … run` through workspace resolution

| Verdict | **ACCEPT** · **AMEND** default behavior |
|---------|------------------------------------------|

**Pointer lift:** P1 (mandatory), P3 (evidence hook), P4 (reuse gate).

**Rebuttal:** Today `cmd_checks` reads live `Repo:` and `lib/run-checks.sh` `cd`s there, writing `EDIR/runs/.checks-latest.json` (Analyst risk c — confirmed at `lib/run-checks.sh:8`). That is the contamination baseline.

**Required amendment (P1):** With **no** workspace selected, auto-create/use a **default isolated workspace** and run against it — do **not** fall through to live `Repo:`, and do **not** write score/check artifacts into the live engagement runs dir (C1.2). “Refuse if workspace missing” is the **wrong** default; it preserves live-tree scoring pressure and fails the pointer.

`consult score` must follow the engagement scorer into the same resolution path. `bench … run` same.

---

### E5. Archive `workspace.txt` into active engagement run dir

| Verdict | **AMEND** (insufficient alone) · optional secondary |
|---------|-----------------------------------------------------|

**Pointer lift if amended:** P3.

**Rebuttal:** Pointer 3 / C3.1 require `<workspace>/evidence/<run-id>/` containing **exact command line, exit status, stdout/stderr**, distinct per run (no overwrite). A single `workspace.txt` (path + HEAD + porcelain) in the engagement run dir is useful provenance but **does not** satisfy P3. Primary evidence lives **under the workspace**; copying a pointer into harness `runs/iter-6/evidence/` for the mission audit is fine and additive.

Also: stop treating `.checks-latest.json` in the live engagement as the score artifact for isolated runs — redirect or dual-write only into the workspace evidence set.

---

### E6. Dirty refuse + `CONSULT_ALLOW_DIRTY=1`

| Verdict | **AMEND** (semantics + escape shape) |
|---------|--------------------------------------|

**Pointer lift if amended:** P4 (and feeds P5 refuse probes).

**Rebuttal:** Proposal dirty = live source tree. Owner dirty = **uncommitted changes inside the named workspace**. Required behaviors:

1. **Silent reuse refuse:** score/check against a dirty workspace → exit ≠ 0, message **names** the workspace.
2. **Unescaped destroy refuse:** `workspace close <name>` on dirty → exit ≠ 0, names workspace.
3. **Named escape:** explicit flag/confirm that **includes the workspace name** (e.g. `--force-dirty=<name>` or `--force` requiring `--workspace=<name>`). Env-only `CONSULT_ALLOW_DIRTY=1` does **not** name the workspace → fails C4.2 spirit; may exist as an additional loud override but **cannot** be the sole escape.

Source-repo dirty at `create` time may still refuse (Analyst safety) — optional extra, **not** a substitute for workspace-dirty rules.

---

### E7. Worktree location policy (sibling / `$CONSULT_WORKROOT`, not under `state/`)

| Verdict | **ACCEPT** |
|---------|------------|

**Pointer lift:** P1 isolation + architecture honesty.

**Rebuttal:** Aligns with ARCHITECTURE (clients are siblings). Mission’s example roots under `state/harness-evolution/workspaces/` are illustrative only — Critic **rejects** nesting client worktrees under harness `state/` (contaminates harness tree; confuses freeze audits). Prefer `$CONSULT_WORKROOT/<name>` or `<repo>.consult-ws/<name>`.

---

### E8. Smoke + harness-checks for ensure / dirty / help

| Verdict | **ACCEPT** · **AMEND** to pointer-shaped check ids |
|---------|-----------------------------------------------------|

**Pointer lift:** P5 (and regressions for P1–P4).

**Rebuttal:** Analyst risk (a) is real: `tests/consult-smoke.sh` currently runs live `checks onboarding-flight-control`. After isolation, that path must use the default workspace (or an explicit escape in the probe). Harness-checks should add real refuse/pass ids, e.g.:

- `ws-lifecycle-cli`
- `ws-default-isolated`
- `ws-dirty-refusal`
- `ws-evidence-per-run`

No mocks; exercise real `git worktree` + real commands. Keep existing wrong-path refusals.

Docs: `README.md` + `ARCHITECTURE.md` must describe the seam (P5 / C5.2). Help alone is not documentation.

---

### E9. Wire `lib/run-skill.sh` / skill path

| Verdict | **REJECT** (Build 1) |
|---------|----------------------|

**Pointer lift:** None of the five pointers name skill. “Build” in the mission title means score/check/**build** activity on the client measurement path (e.g. build-green via checks), not `consult skill`.

**Rebuttal:** Directive — refuse silent scope expansion. Revisit only if a later owner pointer says so.

---

### E10. SHA-drift refuse / MEMORY.md lesson / iter-6-only evidence packaging as primary design

| Verdict | **REJECT** SHA-drift as Build 1 requirement · **NARROW** MEMORY to post-implement org note · **AMEND** evidence packaging |
|---------|------------------------------------------------------------------------------------------------------------------------|

**Rebuttal:** SHA-drift is not a pointer. MEMORY lesson is Constitution duty after ship, not a pointer unlock. Mission evidence for *acceptance audit* may land under `runs/iter-6/evidence/acceptance-*.txt` later — that is scorer work, not a reason to skip workspace-local evidence (P3).

---

## Pointer-by-pointer decisions

### Pointer 1 — Default isolated workspace

| Decision | **AMEND** then implement |
|----------|--------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E1, E2, E4 (amended default), E7 |
| Reject / cut | “Refuse if unconfigured” as the default story; live `Repo:` fallback for score/check/build |
| Risks | Auto-create surprise worktrees — mitigate with stable default name + `list` visibility; must not write `.checks-latest.json` into live engagement runs |

### Pointer 2 — Lifecycle CLI

| Decision | **AMEND** verbs, then **ACCEPT** |
|----------|----------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E3 amended: create / list / enter / close (destroy); help discoverable |
| Reject / cut | ensure/status/remove as the only public verbs; `worktree` as sole help keyword if `workspace`/`ws` absent |
| Risks | Alias sprawl — one canonical noun (`workspace`, optional `ws`) |

### Pointer 3 — Per-score/check evidence

| Decision | **AMEND** placement + payload |
|----------|-------------------------------|
| Expected lift | PARTIAL/FAIL → **PASS** |
| Surviving work | On each score/check inside a workspace: write `<workspace>/evidence/<run-id>/{command,exit,output}` (or one transcript file with all three); second run → new run-id |
| Reject / cut | `workspace.txt`-only in engagement run dir as sufficiency claim |
| Risks | `run-checks.sh` today only keeps latest JSON — must change output targeting without editing frozen contracts |

### Pointer 4 — Named dirty refusal/escape

| Decision | **AMEND** dirty object + escape |
|----------|--------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | Porcelain check on **workspace** tree; refuse reuse + refuse close; escape names workspace |
| Reject / cut | Env-only `CONSULT_ALLOW_DIRTY=1` as sole escape; dirty-live-Repo-only design |
| Risks | Dirty detection false positives (untracked harness noise inside worktree) — keep worktree contents minimal; define dirty = `git status --porcelain` non-empty in workspace |

### Pointer 5 — Automated refusal/pass + documentation

| Decision | **ACCEPT** with pointer-shaped checks |
|----------|--------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E8 amended check ids + README/ARCHITECTURE |
| Reject / cut | Docs for Builds 2–4; check theater without real refuse paths |
| Risks | Harness-checks must remain non-OFC and must not rewrite frozen lock hashes |

---

## Cross-cutting risks

| Risk | Mitigation |
|------|------------|
| Second orchestrator / architecture inflation | One `lib/workspace.sh`; Principal still owns the loop; no daemon |
| Freeze violation | Touch only non-frozen harness code + `runs/iter-6/` artifacts; never HARNESS-BENCHMARK-CONTRACT / contract.json / LOCK / FREEZE* / engagement.md / LOOP-SEQUENCE / authorize-merge / iter-0..5 |
| Live OFC smoke breakage | Update smoke to default-workspace path or explicit named escape in the probe |
| Orphan git worktrees | `close` must remove worktree; document recovery (`git worktree prune`) |
| Paper isolation (copy tree / mock) | Forbidden — real `git worktree` or equivalent real checkout |
| Scope bleed into Builds 2–4 | Explicit refuse list below |

---

## Refusal paths that must be tested

Automated (smoke and/or harness-checks), real commands, named messages:

1. **Dirty reuse refuse** — workspace with local uncommitted change; `consult checks <client>` → non-zero; stderr/stdout contains workspace name.
2. **Dirty close refuse** — `consult workspace close <name>` without escape → non-zero; names workspace.
3. **Dirty close escape** — close with escape that names the same workspace → zero; workspace gone from `list`.
4. **Default isolation** — no prior `enter`; run checks; artifacts under isolation root; live engagement `runs/.checks-latest.json` not updated as the primary write (C1.2).
5. **Lifecycle happy path** — create → list → enter → close (clean workspace).
6. **Help discoverability** — `consult help` matches workspace/ws and lifecycle verbs.
7. **Keep existing wrong-path refusals** — OFC refuses provider run; agcode refuses checks (no regression).

Optional (not pointer-blocking): source-repo dirty at `create` time refuse — only if implemented.

---

## Final implementable scope (smallest corrected work list)

Build 1 ships **only** the following. Expected outcome: all five pointers PASS under `mission-benchmark.md` §4.

1. **Add `lib/workspace.sh`** — real git worktree create/list/enter/close; default workspace resolution; dirty porcelain; named refusals; named escape for destroy/reuse override.
2. **Extend `bin/consult`** — `workspace`/`ws` lifecycle verbs in help + dispatch; wire `checks` / `score` / `bench … run` through resolution so the **default is isolated**, never live `Repo:`.
3. **Adjust `lib/run-checks.sh` output targeting** — when running inside a workspace, record per-run evidence (command + exit + output) under `<workspace>/evidence/<run-id>/`; do not treat live engagement `.checks-latest.json` as the isolation sink.
4. **Tests** — extend `tests/consult-smoke.sh` + `lib/harness-checks.sh` with the refusal/pass paths listed above (pointer-shaped ids).
5. **Docs** — `README.md` + `ARCHITECTURE.md` workspace seam only (no Builds 2–4 preview as deliverable).

**Explicitly out of Build 1:** judgment gates; inspect-pack/escalations; role envelopes; `consult skill` workspace wiring; SHA-drift productization; env-only dirty escape as sole path; nesting worktrees under `state/`; any frozen-file edit; product/client application code.

**Owner escalation note:** Introducing `lib/workspace.sh` is an architecture seam addition. Owner already directed Build 1 under Directive mode — treat as authorized. If implementers propose a daemon, DB, or second CLI entrypoint, Critic records **Challenge** and refuses.

---

## Survival summary

| Element | Verdict | Concrete pointer lift |
|---------|---------|------------------------|
| `lib/workspace.sh` | **ACCEPT** (API amended) | P1–P4 substrate |
| `workspace.json` metadata | **ACCEPT** | P1, P2 |
| CLI ensure/status/remove | **AMEND** → create/list/enter/close | P2 |
| Wire checks/score/bench | **ACCEPT** + **AMEND** default-isolated | P1, P3, P4 |
| `workspace.txt` in engagement run | **AMEND** — secondary only | P3 only if workspace-local evidence exists |
| Dirty + `CONSULT_ALLOW_DIRTY` only | **AMEND** — workspace dirty + named escape | P4 |
| Worktree location policy | **ACCEPT** | P1 / architecture |
| Smoke + harness-checks + docs | **ACCEPT** (pointer ids) | P5 |
| Skill path wiring | **REJECT** | none |
| SHA-drift refuse | **REJECT** | none |
| Builds 2–4 items | **REJECT** (not debated further) | n/a |

**Critic bottom line:** Implement the amended list above — nothing larger. The proposal survives as a **corrected isolation seam**, not as the Analyst’s ensure/remove + env-dirty sketch and not as a foothold for Builds 2–4.
