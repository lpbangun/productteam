# Critic debate — Build 3 (pre-implementation)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — follow owner direction; refuse silent scope expansion; smallest diff
**Against:** §7.3 Analyst/candidate minimal design (escalations.json lifecycle, pause.json + authorize-resume.json, inspect-pack.json, illustrative `consult escalate|resolve|pause|resume|inspect`) + §7.1 seam notes
**Authority:** `CONSTITUTION.md` (autonomy + authorization escalation) · `mission-benchmark.md` §7 (three owner pointers + §7.4 audit) · baseline `evidence/build-3-baseline.md` · merge-auth precedent `lib/github.sh` / `authorize-merge`
**Frozen:** §0 / Builds 1–2 verdicts + iter-0..5 + `state/harness-evolution/judgment/` — do not edit or re-score
**Out of scope:** Build 4 (role-envelope inspection; not inspected, not proposed)
**Stance:** An item survives only with a concrete pointer lift under §7.1. No product code. No validation commands run in this debate.

---

## Overall verdict

**AMEND the §7.3 candidate before implement.** Direction is right (plain per-engagement files; `bin/consult` remains the single entry; shared block predicate; file-derived inspect with explicit missing markers; `CONSULT_MEMORY_FILE` for isolated tests). As written, several Analyst choices **under-specify blocking**, **over-invent auth theater**, or **drift from Constitution authorization precedent / §7 pointer semantics**:

| Drift | Analyst / §7.3 says | Owner / Constitution / precedent require |
|-------|---------------------|------------------------------------------|
| Open escalation vs pause | Separate surfaces; escalate “blocks” and pause “blocks” described side-by-side without a single enforced predicate | Pointer 1: open escalation **blocks** score/check/implement until resolve. Pointer 2 + seam: `pause.json` blocks the **same** progress set, including `gate implement`. **Reject** any design where an open escalation does not pause progress. |
| Resolve “token” | Non-empty `token` recorded on resolve | Constitution / `authorize-merge` precedent is **manual owner artifact presence + explicit note**, not a crypto session. Token = durable opaque receipt (UUID/random), **not** a bearer credential that later resumes without `authorize-resume.json`. |
| Which commands pause | “Score/check/implement refuse” | Exact set: `consult checks`, `consult score` (and its provider path `bench … run`), and `consult gate … implement`. **Not** help/status/inspect/judge/writers themselves. |
| MEMORY update | Resume “writes the MEMORY pointer” | Append-only dated continuation under Lessons (or a dedicated Authorized-resume line); default `MEMORY.md`; tests **must** use `CONSULT_MEMORY_FILE`. Do not rewrite Escalations prose as the resume mechanism. |
| Inspect honesty | Missing → `{"missing": true}` | Empty vs absent must stay honest: **missing file** → missing marker; present empty/resolved-only state → structured present payload, never silent omission or fake history. |
| progress.json locus | Resume updates “progress.json” | Mission machine state is `state/harness-evolution/runs/iter-6/progress.json` **or** a per-engagement progress sibling — pick one and test it. Do **not** invent a second orchestrator journal. Prefer engagement-local `progress.json` (or `runs/…/resume.jsonl` entry) for client pause/resume; do not mutate harness `progress.json` build-order fields from a client resume. |

Constitution: delete-before-add favors **one** shared progress-block predicate (sourced lib beside `judgment-gate.sh` / `workspace.sh`), plain JSON under the engagement, no second orchestrator. Directive mode forbids inspecting or scaffolding Build 4. Baseline (all three pointers FAIL) is accepted.

---

## Proposed elements — rebuttal matrix

Lenses: **scope · Constitution auth fidelity · shared-block honesty · schema transitions · MEMORY duty · inspect missing honesty · idempotency/tamper · test realism**.

### E1. Schema / state transitions

| Verdict | **AMEND** (explicit transitions; single block truth) |
|---------|------------------------------------------------------|

**Pointer lift if amended:** P1 (durable escalations), P2 (pause/resume).

**Corrected lifecycle (binding semantics):**

| Artifact | Open / blocking state | Terminal / clear state | Writer |
|----------|----------------------|------------------------|--------|
| `escalations.json` | ≥1 entry with `status=open` → **block** | `resolve` sets `status=resolved`, non-empty `options[]`, non-empty `token`, `resolved_at` | `escalate` open; `resolve` |
| `pause.json` | file present (`reason`, `paused_at`) → **block** | `resume` deletes/renames away after auth | `pause`; `resume` |
| `authorize-resume.json` | manual owner file required for resume | consumed on successful resume (delete or stamp `consumed_at` + refuse reuse) | **owner manual create**; CLI must not auto-mint |
| Machine continuation | — | on resume: append engagement-local resume record **and** MEMORY pointer entry | `resume` |
| `inspect-pack.json` | regenerable derivation | rewrite on each `inspect` (idempotent content for same inputs) | `inspect` |

**Rebuttal:**

- **ACCEPT** per-engagement plain JSON under `state/engagements/<client>/` (mirrors `workspace.json`, `judgment/`).
- **AMEND** open-escalation block and pause block to share **one** predicate, e.g. `progress_blocked_reason <client_dir>` → non-empty reason iff any open escalation **or** `pause.json` present. Wire that reason into checks/score/`gate implement` before work proceeds.
- **REJECT** Analyst drift that records escalations as advisory prose (today’s `MEMORY.md` §Escalations style) without blocking. Pointer 1 is a machine gate, not a sticky note.
- **AMEND** `progress.json` target: do **not** flip harness-evolution build `status` fields from a client `resume`. Write an engagement-local continuation record (recommended: `state/engagements/<client>/progress.json` with `{ts, event:"resumed", reason, auth_path}` or append `runs/resume.jsonl`). Harness `runs/iter-6/progress.json` stays Principal/mission owned.
- Atomic tmp+mv for all writers (**ACCEPT**, same as `judgment_atomic_write`).
- Escalate while already paused: **ACCEPT** (both may be true; block reason may prefer pause message or concatenate — pick one stable message shape and test it).
- Resolve last open escalation while `pause.json` still present: block remains (**ACCEPT**).

---

### E2. Token / auth model

| Verdict | **AMEND** to Constitution + `authorize-merge` precedent |
|---------|--------------------------------------------------------|

**Pointer lift if amended:** P1 (options+token on resolve), P2 (authorized resume).

**Rebuttal by surface:**

| Surface | Analyst risk | Critic ruling |
|---------|--------------|---------------|
| Resolve `token` | Looks like auth credential / capability | **AMEND.** Token is a **durable receipt** proving resolve recorded options (opaque non-empty string, UUID ok). It does **not** authorize resume, merge, Override, or further autonomy. |
| Resolve `options[]` | Underspecified | **ACCEPT** ≥1 non-empty option strings; empty/`--options` missing → refuse, no status flip. |
| `authorize-resume.json` | Unspecified shape | **AMEND** to mirror `authorize-merge`: plain file with explicit owner authorization note; presence required; content must **not** request force/admin/bypass of frozen contract. Optional fields: `ts`, `client`, `note`. Env override for tests: `CONSULT_AUTHORIZE_RESUME` (path) — same pattern as `CONSULT_AUTHORIZE_MERGE`. |
| Who mints auth | CLI `resume --authorize` auto-write | **REJECT.** Owner (or test harness) creates the file manually. CLI only checks presence + basic refuse-on-bypass text. |
| Crypto / signed tokens / OTP | Tempting “real auth” | **REJECT.** Constitution escalations are human-owner artifacts; complexity must justify itself. |

Constitution mapping: Autonomy table already escalates architecture / security-auth / scope changes to the owner and records them in MEMORY — Build 3 makes that **machine-enforceable** for progress commands without inventing a new identity system.

---

### E3. Which commands pause (shared block set)

| Verdict | **ACCEPT** score/check/implement · **AMEND** exact wiring · **REJECT** escalation-without-pause |
|---------|--------------------------------------------------------------------------------------------------|

**Pointer lift if amended:** P1, P2 (including shared implement-gate predicate).

**Binding blocked set (progress commands):**

1. `consult checks <client> …`
2. `consult score <client> …` (includes provider path via `cmd_bench_run`)
3. `consult gate <client> implement …`

**Must NOT block (read / control / recovery):**

- `consult help`, `status`, `judge`, `gate status`, `gate` writers, `escalate|resolve|pause|resume|inspect`
- `consult memory`, `report`, `run`, `bench` (history view without `run`), `harness-checks`, `smoke`, `workspace status`
- Frozen-contract tooling and org overview

**Rebuttal:**

- §7.1 seam note is binding: while paused, progress commands **and** the Build 2 implement gate refuse via the **same** predicate. Extend `judgment_implement_refusal` **or** call a shared `progress_block_refuse` before `die` — do not fork two divergent pause checks.
- Open escalation **must** hit that same predicate. If Analyst ships escalate-as-log-only, **REJECT** as P1 FAIL and Constitution silent-drop risk.
- Named refusals: message must name the client and the blocking artifact path (`…/escalations.json` open id, or `…/pause.json`).
- **Do not** couple Build 3 block to workspace dirty checks (Build 1 owns dirty). Order: resolve client → progress-block check → existing workspace/gate logic.

---

### E4. MEMORY update on authorized resume

| Verdict | **ACCEPT** pointer write · **AMEND** path, section, and test override |
|---------|------------------------------------------------------------------------|

**Pointer lift if amended:** P2 (MEMORY pointer reflects authorized continuation).

**Rebuttal:**

- Default path: repo-root `MEMORY.md` (**ACCEPT**, §7.1).
- Isolated real tests: `CONSULT_MEMORY_FILE` (**ACCEPT** — baseline probe 7 shows it is missing today; Build 3 must add the seam to `cmd_memory` **and** resume’s writer).
- Write shape: append-only dated line under `## Lessons` (or a short `## Authorized resumes` section if kept tiny) naming client, reason, auth artifact basename, and continuation note. **REJECT** rewriting historical Escalations entries as “resolved” via resume — resolve owns escalation status; resume owns pause clearance + continuation pointer.
- **REJECT** gate-enforcing MEMORY as a predicate for unrelated commands; only resume performs the write (Constitution “Memory is a duty” after real authorized continuation).
- Resume without writable MEMORY path → non-zero; leave `pause.json` in place (no partial clear).

---

### E5. Inspect missing honesty

| Verdict | **ACCEPT** file-derived pack · **AMEND** missing vs empty semantics |
|---------|---------------------------------------------------------------------|

**Pointer lift if amended:** P3.

**Required pack components (file-derived only, no chat):**

| Component | Source files | Missing marker when |
|-----------|--------------|---------------------|
| mode | `engagement.md` `Mode:` | no Mode / unparseable |
| implement gates | `judgment/*` + gate status derivation | no judgment payloads / mode unknown → structured refused/absent, not invented “allowed” |
| scores history | `runs/iter-*/scores.json` | no score files |
| escalations | `escalations.json` | **file absent** → `{"missing": true}`; file present → emit entries (open/resolved), even if `[]` |
| lessons | engagement `lessons.md` / run lessons | file absent → missing marker |
| next action | engagement `progress.json` or latest lessons/next_action field | absent → missing marker |

**Rebuttal:**

- **ACCEPT** `consult inspect <client> [--out <path>]`; default out under the engagement (e.g. `inspect-pack.json`).
- **ACCEPT** regenerable: second run with same inputs yields same semantic derivation (timestamps inside pack may update only if explicitly sourced; prefer omitting wall-clock unless read from files).
- **AMEND** honesty rule: never omit a key; never substitute chat; never claim escalations “none” by deleting the key when the file is missing — use explicit `missing`.
- **REJECT** Build 4 role-envelope fields inside the pack.
- Precedent: `gate status` JSON + `bench` history derivation — reuse patterns; one new `cmd_inspect`, not a dashboard service.

---

### E6. Idempotency / tamper risks

| Verdict | **AMEND** consume-on-resume + refuse forged clears |
|---------|-----------------------------------------------------|

**Pointer lift if amended:** P1–P2 safety (feeds real §7.4 paths).

| Risk | Ruling |
|------|--------|
| Double `resolve` on same id | Second resolve refuses (already resolved) or no-ops with non-zero; token/options immutable after first success |
| Hand-edit `status=resolved` without options/token | Block predicate treats as still open **or** invalid entry → still block; resolve CLI is the only honest unblock for escalations |
| Delete `pause.json` without authorize | Human can always rm files; machine path: `resume` without auth refuses; document that bypassing files is an owner filesystem act outside CLI honesty — do not add DAC/crypto |
| Reuse stale `authorize-resume.json` | **AMEND:** successful resume must consume auth (delete or `consumed_at`); subsequent resume without a fresh auth refuses |
| Plant auth + never pause | `resume` with no `pause.json` → non-zero (“not paused”) |
| Tamper inspect-pack by hand | Next `inspect` regenerates from sources — pack is not authoritative state |
| Forge resolve token to unlock pause | Token never unlocks pause; only `authorize-resume.json` does |

---

### E7. Real block → resume tests

| Verdict | **AMEND** to §7.4 pointer-shaped checks · real CLI · temp engagement + `CONSULT_MEMORY_FILE` |
|---------|----------------------------------------------------------------------------------------------|

**Pointer lift if amended:** all three pointers under §7.4.

Map Analyst scenarios onto owner audit ids (names illustrative; semantics binding):

| §7.4 check | Must prove with real commands |
|------------|-------------------------------|
| E1.1 | `consult help` matches escalat |
| E1.2 | open escalation → `checks` non-zero; durable `status=open` |
| E1.3 | resolve with options → options+token on disk; checks proceed **unless** paused |
| P2.1 | pause → checks non-zero **and** `gate implement` non-zero; `pause.json` has reason+paused_at |
| P2.2 | resume without authorize file → non-zero; names auth path |
| P2.3 | manual authorize → resume 0; pause gone; engagement progress/MEMORY updated via override path; checks proceed |
| I3.1 | help matches inspect; inspect twice regenerates pack with required keys |
| I3.2 | client lacking lessons/escalations file → explicit missing markers |

Extras (recommended smoke, not substitutes): open-escalation blocks `gate implement`; consume-on-resume reuse refuse; `CONSULT_MEMORY_FILE` isolation (org `MEMORY.md` untouched); help lists pause/resume.

No mocks. No provider invocation. Template: temp engagement + cleanup trap (as `tests/workspace-smoke.sh` / `tests/judgment-gate-smoke.sh`).

Docs: README + ARCHITECTURE one row each for escalations/pause/inspect — enough for operators.

---

## Five decision pointers (concrete lift)

Acceptance of this debate: five decision units below, each with expected baseline→PASS lift into the §7.1 owner pointers they serve. Build 3 still passes iff **all three** §7.1 pointers PASS under §7.4 — these five decisions are the Critic’s corrected implement contract.

### Decision 1 — Schema / state transitions

| Decision | **AMEND** then implement |
|----------|--------------------------|
| Expected lift | P1/P2 FAIL → **PASS** |
| Surviving work | E1 tables; shared `progress_blocked_reason`; engagement-local resume record (not harness build-order mutation) |
| Reject / cut | Advisory-only escalations; auto-clear pause on resolve; mutating `runs/iter-6/progress.json` build statuses from client resume |
| Risks | Dual sources of truth if pause and escalation use different block checks — eliminated by one predicate |

### Decision 2 — Token / auth model

| Decision | **AMEND** token=receipt; auth=`authorize-resume` file precedent |
|----------|------------------------------------------------------------------|
| Expected lift | P1 options+token · P2 authorized resume → **PASS** |
| Surviving work | E2; resolve writes options+token; resume requires manual auth file; optional `CONSULT_AUTHORIZE_RESUME`; consume-on-success |
| Reject / cut | Crypto/OTP; CLI-minted self-authorization; treating resolve token as resume capability |
| Risks | Auth theater inflation — cut; follow `authorize-merge` simplicity |

### Decision 3 — Which commands pause

| Decision | **ACCEPT** checks/score/implement · **REJECT** open-escalation-without-block |
|----------|-------------------------------------------------------------------------------|
| Expected lift | P1 block-until-resolved · P2 pause including implement gate → **PASS** |
| Surviving work | E3 wiring before existing workspace/gate work; named refusals |
| Reject / cut | Blocking inspect/help/status; escalate-as-MEMORY-prose-only; divergent pause vs implement checks |
| Risks | Analyst ships escalate log without pause — **automatic Challenge/refuse** |

### Decision 4 — MEMORY update

| Decision | **ACCEPT** append on authorized resume · **AMEND** `CONSULT_MEMORY_FILE` |
|----------|--------------------------------------------------------------------------|
| Expected lift | P2 MEMORY pointer → **PASS** |
| Surviving work | E4 append-only continuation line; resume fails closed if MEMORY unwritable |
| Reject / cut | Using resume to rewrite Escalations section; writing org MEMORY from tests |
| Risks | Partial resume (MEMORY fail after pause delete) — order: validate auth → write MEMORY+progress → clear pause last (or transactionally fail closed) |

### Decision 5 — Inspect missing honesty

| Decision | **ACCEPT** regenerable pack · **AMEND** missing vs empty |
|----------|----------------------------------------------------------|
| Expected lift | P3 FAIL → **PASS** |
| Surviving work | E5 component table; `cmd_inspect`; explicit missing markers; no chat |
| Reject / cut | Silent key omission; Build 4 envelopes; treating hand-edited pack as source of truth |
| Risks | Collapsing “no open escalations” with “no escalations file” — forbidden |

---

## Owner-pointer mapping (score surface)

| §7.1 Pointer | Decisions that unlock PASS | §7.4 audit |
|--------------|----------------------------|------------|
| 1 Durable escalations | D1, D2, D3 | E1.1–E1.3 |
| 2 Pause / authorized resume | D1–D4, E6–E7 | P2.1–P2.3 |
| 3 File-derived `consult inspect` | D5, E7 | I3.1–I3.2 |

---

## Product / autonomy semantics drift flags

1. **Open escalation does not pause (blocking).** If Analyst leaves progress runnable while `status=open`, that is Constitution silent-progress on an escalated matter and a hard P1 miss — **REJECT** / Challenge.
2. **Resolve token as capability.** Turns a receipt into auth — autonomy drift. Token never substitutes for `authorize-resume.json`.
3. **CLI self-authorize resume.** Breaks owner-manual precedent from `authorize-merge` / Challenge example (`examples/challenge-refusal.md`).
4. **Harness `progress.json` build-order edits from client resume.** Couples engagement pause to mission scheduler — second-orchestrator smell; keep mission progress Principal-owned.
5. **Inspect as chat/summary service.** Pointer 3 is files-only; any model call fails the real-proof rule.
6. **Build 4 pre-wiring.** Role-envelope inspection fields or worker spawn hooks — **refuse**.

---

## Cross-cutting risks

| Risk | Mitigation |
|------|------------|
| Second orchestrator / architecture inflation | One small lib (e.g. `lib/progress-block.sh` or escalate/pause helpers in one file); Principal still owns the loop |
| Freeze violation | Touch only non-frozen harness code + `runs/iter-6/` artifacts; never contract/LOCK/FREEZE*/engagement.md/LOOP-SEQUENCE/authorize-merge/iter-0..5; do not amend Build 1/2 verdicts or `judgment/` Directive payload |
| Auth file bypass text | Refuse authorize files that request force/admin/contract waiver (copy merge precedent) |
| Org MEMORY pollution in tests | Require `CONSULT_MEMORY_FILE` in smoke/harness paths that exercise resume |
| Partial state on failed resume | Clear pause only after MEMORY + continuation record succeed |
| Scope bleed into Build 4 | Explicit refuse list below |

---

## Refusal paths that must be tested

Automated (smoke and/or harness-checks), real commands, named messages:

1. **Escalation open blocks checks** — durable open entry; `checks` non-zero; names client + escalations path/id.
2. **Escalation open blocks gate implement** — same predicate; non-zero.
3. **Resolve refuses empty options** — no status flip; no token.
4. **Resolve pass** — options+token+resolved_at on disk; progress unblocked if not paused.
5. **Pause blocks checks + implement** — `pause.json` reason+paused_at; both commands non-zero.
6. **Resume without authorize** — non-zero; message names authorize file path.
7. **Resume with authorize** — exit 0; pause consumed; auth consumed; engagement continuation record written; `CONSULT_MEMORY_FILE` has continuation line; checks proceed.
8. **Resume auth reuse** — second resume without fresh auth → non-zero.
9. **Resume when not paused** — non-zero.
10. **Inspect missing markers** — absent lessons/escalations file → `missing: true` (or equivalent explicit marker).
11. **Inspect regenerable** — two runs, required keys present, file-derived only.
12. **Help discoverability** — matches escalat / pause|resume / inspect.
13. **Keep existing refusals** — OFC provider path, agcode checks scorer path, gate mode refusals, merge-without-authorize (no regression).

---

## Final implementable scope (smallest corrected work list)

Build 3 ships **only** the following. Expected outcome: all three §7.1 pointers PASS under §7.4.

1. **Add one progress-block seam** (new `lib/progress-block.sh` **or** tightly scoped helpers sourced by `bin/consult`) — `progress_blocked_reason` over open `escalations.json` entries **or** present `pause.json`; shared by checks/score/`gate implement`.
2. **Extend `bin/consult`** — `escalate` / `resolve` / `pause` / `resume` / `inspect` (+ help/dispatch); wire block into `cmd_checks` / score provider path / `cmd_gate implement`; add `CONSULT_MEMORY_FILE` read in `cmd_memory` and resume writer.
3. **Durable files** — per engagement: `escalations.json`, `pause.json`, owner-manual `authorize-resume.json`, regenerable `inspect-pack.json`, engagement-local continuation/`progress` record on resume.
4. **Tests** — real-CLI smoke covering E1.1–E1.3, P2.1–P2.3, I3.1–I3.2 (and recommended extras above); temp engagement + `CONSULT_MEMORY_FILE`; extend harness-checks with pointer-shaped ids.
5. **Docs** — README + ARCHITECTURE rows for escalation/pause/inspect only.

**Explicitly out of Build 3:** Build 4 role envelopes; daemons/DB/plugin/RAG/second CLI; crypto auth; CLI self-minted authorize files; mutating harness-evolution build-order `progress.json` from client resume; editing frozen harness-apc-v1 files / iter-0..5 / `authorize-merge` contents; re-scoring Builds 1–2; product/client application code; provider invocation for probes; using resolve token as resume capability; escalate-without-block designs.

**Owner escalation note:** Shared progress-block + pause/resume authorization is an architecture seam under an owner-directed Build 3 (Directive). If implementers propose a daemon, identity service, waiver API, or Build 4 envelope wiring now, Critic records **Challenge** and refuses. If open escalations do not pause progress commands, Critic **rejects** the implementation as Autonomy-policy drift.

---

## Survival summary

| Element | Verdict | Concrete pointer lift |
|---------|---------|------------------------|
| Schema / state transitions | **AMEND** (shared block; engagement-local resume record) | P1, P2 |
| Token / auth model | **AMEND** (token=receipt; authorize-resume file) | P1, P2 |
| Which commands pause | **ACCEPT** set · **REJECT** escalate-without-pause | P1, P2 |
| MEMORY update | **ACCEPT** · **AMEND** `CONSULT_MEMORY_FILE` | P2 |
| Inspect missing honesty | **ACCEPT** · **AMEND** missing vs empty | P3 |
| Idempotency / tamper | **AMEND** consume-on-resume; invalid resolve still blocks | P1, P2 safety |
| Real block→resume tests | **AMEND** → §7.4 real CLI | P1–P3 |
| Crypto auth / self-authorize / Build 4 / harness build-order mutate | **REJECT** | none (anti-drift) |

**Critic bottom line:** Implement the amended list — nothing larger. The §7.3 handoff survives as a **corrected plain-file escalation + pause/authorize-resume + file-derived inspect** seam (shared progress block, authorize-merge-shaped owner auth, honest missing markers), not as advisory escalation prose, not as token-as-capability theater, and not as a foothold for Build 4 or frozen-contract re-scoring. **Open escalation that does not pause is a hard reject.**
