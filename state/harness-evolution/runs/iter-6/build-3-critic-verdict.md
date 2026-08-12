# Critic verdict — Build 3 (iter-6)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — active durable gate: `judgment/directive.json`
**Against:** Build 3 implementation (`lib/engagement-state.sh`, `bin/consult` escalation/inspect + progress-block wiring, `tests/escalation-smoke.sh`, harness seven ids, README/ARCHITECTURE) + Advisor PASS (`evidence/build-3-advisor-verdict.json`)
**Acceptance:** `mission-benchmark.md` §7 (five owner pointers; §7.4 audit)
**Prior debate:** `build-3-debate.md` (pre-impl AMEND list; no Build 3 Principal overrule file)
**Active Directive:** `state/harness-evolution/judgment/directive.json` — direction “Make unattended multi-iteration consulting operable under the Constitution”; `decision=allowed`
**Frozen:** §0 / §7.1 guard + iter-0..5 + Builds 1–2 verdicts — not edited by this verdict
**Method:** Evidence-backed file/code/docs audit only. No validation commands, tests, or product edits for this verdict. Skip all validation.

---

## Verdict: **ACCEPT-WITH-NITS**

Build 3 ships the debate-amended escalation/pause/inspect seam: one `lib/engagement-state.sh`, `consult escalation … block|status|resume` + `consult inspect`, shared `progress_blocked_reason` on checks / provider score (`bench … run` via `cmd_score`) / `gate implement`, manual exact-match `authorize-resume.json` (token = receipt only), consumed auth + `continuation.json` + MEMORY pointer, regenerable file-derived `inspect-pack.json` with explicit missing markers, seven real-CLI G5 markers, README/ARCHITECTURE docs. Advisor’s five-pointer PASS is evidence-backed against §7.4 and the seven CLI markers. Nits below do **not** void Build 3; none is a precise acceptance blocker under the owner pointers as written in `mission-benchmark.md` §7.1.

**Do not treat this as harness-apc-v1 re-scoring.** Frozen APC remains converged; iter-6 Build 3 scores only the five mission pointers.

---

## 1. Contract alignment (debate → code)

| Surface | Ruling |
|---------|--------|
| Single seam `lib/engagement-state.sh` + `bin/consult` only | **Met.** Sourced beside workspace/judgment; no second CLI/orchestrator. |
| Block = one transition: escalations entry + active pause | **Met.** `escalation_block` writes blocked entry (options + resume_token) then `pause.json` `{paused:true,status:paused,…}`. |
| Shared progress-block predicate | **Met.** `progress_blocked_reason` wired in `cmd_checks`, `cmd_bench_run` (provider score path; `cmd_score` routes here), and `cmd_gate implement`. Help/status/inspect/gate writers remain available. |
| Token = receipt; auth = manual authorize file | **Met.** Comment + README + ARCHITECTURE; resume refuses without file / wrong id|token; CLI never mints auth. `CONSULT_AUTHORIZE_RESUME` override mirrors merge precedent. |
| Resume stamps + MEMORY + continuation | **Met.** Escalation `resolved`+`resolved_at` (options/token preserved); pause `paused:false`/`status:resumed`; auth `consumed`; `continuation.json`; append-only MEMORY under `## Lessons` via `CONSULT_MEMORY_FILE`. |
| Repeat resume refused | **Met.** Consumed auth dies; smoke `auth-reuse`. |
| Invalid/hand-edited “resolved” still blocks | **Met.** Open iff not fully stamped resolved (options array non-empty + token + resolved_at). Corrupt escalations.json → block reason. |
| Inspect file-derived + missing honesty + regenerable | **Met.** `inspect_derive_pack` / `inspect_write_pack`; no wall-clock; explicit `missing` list + per-component markers; smoke byte-`cmp` regeneration. |
| Paths with spaces | **Met.** Live pack under worktree `Product Consulting Harness/…` resolves six `runs/iter-*/scores.json` and `runs/iter-6/lessons.md` (Advisor + pack). Builder notes prior split bugs fixed at source. |
| No Build 4 / frozen edits / harness build-order mutate from resume | **Met** in reviewed surfaces. Client resume writes engagement-local `continuation.json` only; `runs/iter-6/progress.json` stays Principal-owned. |

Command/file naming vs debate illustrative verbs (`escalate`/`resolve`/`pause` → shipped `escalation block`/`resume`; `status=open` → `blocked`): **ACCEPT** — §7.1 seam note binds semantics, not spelling.

---

## 2. Seven real CLI markers (P5 surface)

| Id | Smoke path (real `bin/consult`) | Critic |
|----|----------------------------------|--------|
| `escalation-block-state` | `escalation block` → durable escalations.json + pause.json; options≥2; token non-empty | **PASS** |
| `escalation-pauses-progress` | `gate implement` + `checks` refuse while paused; name client / owner-1 / pause | **PASS** |
| `escalation-resume-refuse` | Resume without auth file; wrong-token auth → non-zero | **PASS** |
| `escalation-resume-authorized` | Exact-match auth → resolved/resumed/consumed/continuation; reuse refuse | **PASS** |
| `escalation-memory-continuation` | `CONSULT_MEMORY_FILE` Lessons pointer names client + resume | **PASS** |
| `inspect-pack-regenerable` | Two `inspect` runs byte-identical; post-resume pack coherent | **PASS** |
| `inspect-pack-missing-honest` | Fresh engagement → explicit missing for absent sources | **PASS** |

Transcript: `evidence/acceptance-build-3-escalation-smoke.txt`. Harness: `evidence/acceptance-build-3-harness-checks.txt` (42/0; seven escalation/inspect ids `real-cli-continuation`). Smoke suite: `evidence/acceptance-build-3-smoke.txt` (help lists escalation/resume/inspect; lifecycle ok). Live pack: `evidence/acceptance-build-3-inspect.txt` + `state/harness-evolution/inspect-pack.json`.

---

## 3. Pointer-by-pointer audit (Advisor PASS × evidence sufficiency)

### Pointer 1 — Engagement escalation state → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| B3.1.1 block writes durable blocked entry | **PASS** — smoke jq: length 1, status=blocked, options length 2, resume_token length > 0. |
| B3.1.2 status machine-readable | **PASS** — `escalation_status` emits client/paused/open/resolved/missing/artifacts; consult-smoke exercises OFC missing honesty. |
| B3.1.3 missing inputs explicit | **PASS** — no inventing open entries when file absent (`missing=true`, open=[]). |

### Pointer 2 — Inspectable pause → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| B3.2.1 pause artifact on block | **PASS** — smoke asserts paused=true, status=paused, id=owner-1. |
| B3.2.2 shared predicate blocks progress set | **PASS** — code wires all three: `cmd_checks`, `cmd_bench_run`, `cmd_gate implement`. Smoke proves implement+checks; Advisor records a separate real temp-engagement `bench run` refusal (exit 1, names escalations+pause) without producing scores. |
| B3.2.3 inspect allowed while paused | **PASS** — smoke `inspect-paused` during block. |

### Pointer 3 — Authorized resume + MEMORY → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| B3.3.1 missing/mismatched auth refuse | **PASS** — no file + wrong token; no partial clear of pause/escalation on refuse paths. |
| B3.3.2 authorized resume updates all stamps | **PASS** — resolved_at, pause resumed, auth consumed, continuation event=resumed with escalation_resolved/auth_consumed. |
| B3.3.3 consume + MEMORY pointer + progress unblocked | **PASS** — auth-reuse refuse; MEMORY override line; implement passes after resume. |

### Pointer 4 — File-derived inspect pack → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| B3.4.1 derives mode/gate/scores/history/escalations/lessons/next | **PASS** — live harness-evolution pack: Directive from engagement.md; gate allowed from judgment/directive.json; scores history 6 runs (paths with spaces); history.jsonl; lessons → iter-6/lessons.md; escalations/pause/continuation missing:true; next_suggested_action file-derived. |
| B3.4.2 regenerable / deterministic | **PASS** — smoke `cmp` identical; derive omits wall-clock. |
| B3.4.3 missing-input honesty | **PASS** — missing client pack marks escalations/pause/scores/history/lessons/continuation + missing[] indexes. |

### Pointer 5 — Real lifecycle proof → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| B3.5.1 escalation-smoke 7 markers exit 0 | **PASS** — acceptance transcript. |
| B3.5.2 consult smoke green with Build 3 surface | **PASS** — acceptance-build-3-smoke.txt. |
| B3.5.3 harness-checks 42/0 with seven ids | **PASS** — checks.json + harness transcript. |

**Would Critic flip any Advisor PASS to FAIL?** **No.**

---

## 4. Hazard review (assignment checklist)

| Hazard | Finding | Severity |
|--------|---------|----------|
| **Atomicity / partial state** | Per-file writers are tmp+`mv`. Block writes escalations then pause — mid-kill still blocks via open escalation. Resume order: continuation → MEMORY → resolve stamp → pause clear → auth consume. MEMORY failure fail-closes pause (good) but leaves a continuation.json that already claims success. Kill after resolve stamp and before pause/auth clear can leave **active pause with no open escalation**, so CLI resume cannot clear it (manual file repair). Happy-path and refuse-path §7.4 checks still pass. | Nit (not pointer FAIL) |
| **Token vs auth** | Token is opaque receipt (`escalation_token`); never sufficient alone. Auth requires exact id+token, non-empty authorized_by/decision, refuse on force/admin/waiver text, consume-on-success. | Clear |
| **Repeat resume** | Consumed auth refused; smoke asserts. Fresh auth required. Multi-open: resolving one re-points pause to remaining open id (keeps paused). | Clear |
| **All progress paths** | checks + bench/provider score + gate implement share one predicate and name blocking artifacts. Smoke covers implement+checks only; score-path refuse is code-audited + Advisor-claimed without a dedicated acceptance transcript file. | Nit (coverage) |
| **Paths with spaces** | Iter/lessons globs use line-oriented `read -r` / `printf '%s\n'`; live pack under spaced worktree resolves all six score runs + iter-6 lessons. | Clear |
| **Missing / corrupt data** | Absent files → missing markers; invalid escalations.json blocks; incomplete “resolved” still open; invalid pause (neither paused true nor false) blocks; inspect surfaces invalid flags when jq fails. | Clear |
| **Inspect determinism** | No wall-clock in derive; smoke regeneration byte-identical. Empty `ts`/`kind`/`weakest` on older iters when `scores.json` schema lacks those fields — honest empty, not invented. | Clear (empty fields = nit quality) |
| **Scope drift** | No Build 4 envelope fields/worker hooks; no frozen iter-0..5 / contract / LOCK edits claimed; no harness `progress.json` mutation from client resume; no provider invocation for its own sake; no daemon/DB. README/ARCHITECTURE mention Build 4 *consuming* the implement gate later — documentation of composition, not Build 4 scope. | Clear |
| **Shell safety** | `set -euo pipefail` in consult/smoke; `nonblank` rejects whitespace-only ids/summary/options/token. `atomic_write` can leave `.tmp.$$` on mid-write kill; no fsync. Harness marker loop is grep-thin; only `inspect-pack-missing-honest` also requires smoke rc=0. | Nit |
| **Advisor bias** | Independent pack; honest_limits disclose no provider, CONSULT_SMOKE_SKIP_CLIENT, Build 3-only scope, temp engagements cleaned. Closest soft spot: score-path pause refuse asserted in prose without a dedicated evidence txt (code + smoke still cover the binding set for P2 with Advisor’s claimed CLI probe). | Clear (no flip) |
| **Frozen guard** | Advisor: status only under `runs/iter-6/` (+ additive inspect-pack / pre-existing judgment/); lock-hashes-stable unchanged. This Critic did not re-hash locks (no validation commands). | Clear (as claimed) |

---

## 5. Diff / scores stance

**Diff (conceptual):** Smallest amended seam — new `lib/engagement-state.sh` (~343 LOC), `cmd_escalation` / `cmd_inspect` + help/dispatch, progress-block calls on three progress commands, `CONSULT_MEMORY_FILE` on `cmd_memory` + resume, `tests/escalation-smoke.sh`, seven harness ids, consult-smoke Build 3 lines, README Escalations section + ARCHITECTURE seam/layout. Matches `build-3-debate.md` survival list (shared predicate, token≠auth, manual authorize-resume, honest missing, no Build 4). Does not implement rejected crypto auth, CLI self-minted authorize, or harness build-order mutation.

**Scores:** No harness-apc-v1 `scores.json` for Build 3 (correct). Build 3 score = Advisor five-pointer PASS/FAIL only.

| Pointer | Advisor | Critic |
|---------|---------|--------|
| P1 Engagement escalation state | PASS | **PASS** |
| P2 Inspectable pause | PASS | **PASS** |
| P3 Authorized resume + MEMORY | PASS | **PASS** |
| P4 File-derived inspect pack | PASS | **PASS** |
| P5 Real lifecycle proof (7 ids) | PASS | **PASS** |

Baseline → acceptance lift: all five were FAIL at `evidence/build-3-baseline.md`; all five PASS post-impl.

---

## 6. Org self-review (mandatory)

| Lens | Finding |
|------|---------|
| Role redundancy | Four permanents unchanged. “Advisor” remains a mission scoring label (Build3Acceptance), not a fifth permanent worker. Pre-impl Critic debate amended Analyst §7.3; Builder/Principal completed the amended seam after a partial subagent failure (`build-3-builder-result.md` discloses). |
| Orchestration friction | Low. Debate → builder-result → Advisor pack is coherent. Risk: readers treating debate’s older three-pointer framing or illustrative `escalate`/`status=open` names as the contract — **§7.1 five pointers + shipped semantics are authoritative**. |
| Prompt gaps | Builder-result correctly defers verification to Advisor/Critic. `progress.json` / MEMORY still show Build 3 as `next` until Principal closes. Lessons.md still titled Build 1 with Build 2 addendum only — no Build 3 lesson yet. |
| Memory gaps | After acceptance: append authorized-resume consume rule, token≠auth, shared progress-block set, seven marker ids, inspect missing honesty, `CONSULT_MEMORY_FILE` test seam. |
| Benchmark blind spots | Smoke omits provider-score pause refuse (code+Advisor cover); resume multi-file crash window (resolved-without-pause-clear); continuation written before MEMORY on fail-closed path; harness marker-thin trust of smoke; inspect weakest/ts empty on APC score schema. |
| CLI UX | Escalation/inspect surface is small and help-discoverable. Auth file shape documented in README. Operator must understand token is correlation only. |
| Unnecessary complexity | **Prefer deletion held:** one library, plain JSON, stamp-don’t-delete pause/auth (more inspectable than debate’s delete option), no daemon/identity service. Double execution of escalation-smoke (direct + via harness-checks + via consult-smoke) is slight redundancy, not architecture bloat. |

---

## 7. Formal verdict

### **ACCEPT-WITH-NITS**

Build 3 may proceed as pointer-complete under `mission-benchmark.md` §7. Precise non-blockers to clean up opportunistically (not Build 3 re-opens unless owner expands scope):

1. Resume transactional ordering: write continuation only after MEMORY succeeds, or write a provisional continuation and stamp success fields last; ideally clear pause + consume auth in one fail-closed sequence so a mid-kill cannot leave paused-with-no-open-escalation.
2. Add smoke (or a dedicated acceptance transcript) for `bench … run` / provider score refuse while paused — today only implement+checks are marker-proven.
3. Harness: require escalation-smoke rc=0 for all seven ids (not only `inspect-pack-missing-honest`), matching the substance of “suite green.”
4. Inspect quality: derive weakest/ts/kind from the APC `dimensions` schema (or document empty when absent) without inventing values.
5. Append Build 3 lesson + close `progress.json` Build 3 when Principal records acceptance; keep MEMORY pointer duty noted.

**Blockers for REJECT:** none under the five owner pointers.

**Reject magnets not observed:** open escalation that does not pause progress; token-as-capability resume; CLI-minted authorize-resume; mocks/fixtures as sole lifecycle proof; silent missing-key omission in inspect; Build 4 role-envelope pre-wiring; mutating harness `progress.json` build-order from client resume; frozen-file edits; Advisor PASS without durable/CLI evidence; second orchestrator / daemon / crypto auth theater.

---

## 8. Out of scope (reaffirmed)

Build 4 (role-envelope inspection); Builder invocation beyond composing with the existing implement gate; product/client application code; provider invocation for its own sake; formatters/linters; re-opening harness-apc-v1 dimensions; editing frozen iter-0..5 / contract / LOCK / FREEZE* / authorize-merge; amending Builds 1–2 verdicts.
