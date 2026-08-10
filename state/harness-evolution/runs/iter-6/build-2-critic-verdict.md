# Critic verdict — Build 2 (iter-6)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — active durable gate: `judgment/directive.json`
**Against:** Build 2 implementation (`lib/judgment-gate.sh`, `bin/consult` `cmd_gate`, `tests/judgment-gate-smoke.sh`, harness-checks eight ids, README/ARCHITECTURE) + Advisor PASS (`evidence/build-2-advisor-verdict.json`)
**Acceptance:** `mission-benchmark.md` §6 (five owner pointers; §6.4 audit)
**Prior debate:** `build-2-debate.md` (pre-impl AMEND list; no Build 2 Principal overrule file)
**Active Directive:** `state/harness-evolution/judgment/directive.json` — direction “Make unattended multi-iteration consulting operable under the Constitution”; `decision=allowed`; status transcript agrees (`evidence/acceptance-build-2-status.txt`)
**Frozen:** §0 / §6.2 files + iter-0..5 + Build 1 verdicts — not edited by this verdict
**Method:** Evidence-backed file/code/docs audit only. No validation commands, tests, or product edits for this verdict. Skip all validation.

---

## Verdict: **ACCEPT-WITH-NITS**

Build 2 ships the debate-amended judgment-gate seam: one `lib/judgment-gate.sh`, `consult gate <client> status|implement|select|direct|challenge|override`, durable per-engagement `judgment/*.json`, Override required-true `non_waivers` (no waiver channel), current-mode-only reads, read-only `implement`, machine status JSON, eight real-CLI G5.1 ids, README/ARCHITECTURE docs. Advisor’s five-pointer PASS is evidence-backed against §6.4 and the eight CLI paths. Nits below do **not** void Build 2; none is a precise acceptance blocker under the owner pointers as written in `mission-benchmark.md` §6.1.

**Do not treat this as harness-apc-v1 re-scoring.** Frozen APC remains converged; iter-6 Build 2 scores only the five mission pointers.

---

## 1. Contract alignment (debate → code)

| Surface | Ruling |
|---------|--------|
| Single seam `lib/judgment-gate.sh` + `bin/consult` only | **Met.** Sourced beside workspace; no second CLI/orchestrator. |
| Mode authority = `engagement.md` `Mode:` | **Met.** `judgment_mode`; missing/unknown → implement refuse; writers are not a second mode store (`cmd_judge_set` unchanged). |
| Guided: refuse until `selection.json` direction+selected_by | **Met.** |
| Directive: refuse until durable direction; empty `risks` allowed | **Met** via `direct` writer + `judgment_directive_ok`. Implement does **not** archive (ARCHITECTURE correctly calls implement read-only). Debate’s `direct` **or** implement-archive was an OR — shipping `direct` alone is enough. |
| Challenge: harmful always refused; only safer alternative implementable | **Met.** Explicit harmful arg refused; pass requires `selection.json` direction == `safer_alternative` with Challenge mode stamp. |
| Override: non-empty risks + critic/evidence records + `non_waivers.{critic,evidence,frozen_contract}=true` | **Met.** Writer hardcodes non-waivers true (no waiver channel); empty risk dies with no durable write; tampered false non-waiver refuses implement. |
| Eight G5.1 check ids, real CLI | **Met.** `tests/judgment-gate-smoke.sh` + `lib/harness-checks.sh` marker recording; `checks.json` all eight `pass` / `real-cli-engagement`. |
| Stale cross-mode | **Met.** Current-mode file only; mode field on payloads blocks cross-mode reuse of selection; no auto-delete. |
| No Builds 3–4 / checks/score/bench wiring / frozen edits | **Met** in reviewed surfaces. |

Field spelling vs debate illustrative JSON (`critic_verdict` / `evidence[]` → shipped `critic_record` / `evidence_record`): **ACCEPT** — debate binds semantics, not spelling (§6.1 seam note).

---

## 2. Eight real CLI paths (P5 surface)

| Id | Smoke path (real `bin/consult`) | Critic |
|----|----------------------------------|--------|
| `gate-guided-refuse` | Guided `implement` before select → non-zero; names client | **PASS** |
| `gate-guided-pass` | `select` then `implement`; durable `selection.json`; status allowed | **PASS** |
| `gate-directive-refuse` | Directive `implement` before `direct` → non-zero | **PASS** |
| `gate-directive-pass` | `direct` then `implement`; status present flags | **PASS** |
| `gate-challenge-refuse` | Missing challenge and/or implement harmful → non-zero; status refused | **PASS** |
| `gate-challenge-alternative` | `select` safer then `implement` safer → 0; `selection_matches` | **PASS** |
| `gate-override-refuse` | `override` with empty risk → non-zero; `override.json` absent | **PASS** |
| `gate-override-pass` | Full override + implement → 0; durable non_waivers true (tamper refuse covered after) | **PASS** |

Transcript: `evidence/acceptance-build-2-gate-smoke.txt`. Harness: `evidence/acceptance-build-2-harness-checks.txt` (35/0; eight gate ids present).

---

## 3. Pointer-by-pointer audit (Advisor PASS × evidence sufficiency)

### Pointer 1 — All four modes bind Implement per JUDGMENT → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| G1.1 help discoverable | **PASS** — help lists full `gate` surface (`evidence/acceptance-build-2-help.txt`; consult-smoke `help lists gate`). |
| G1.2 per-mode decisions + durable state | **PASS** — smoke exercises all four modes’ refuse/pass against JUDGMENT semantics; payloads carry mode+decision+ts. Stricter than abbreviated §6.4 G1.2 “Directive implement after mode set alone”: durable `direct` required (debate amendment). Advisor did **not** rubber-stamp mode-only Directive pass. |

### Pointer 2 — Required gates are durable files → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| G2.1 plain per-engagement judgment files | **PASS** — writers under `client_dir` (`state/engagements/<client>/judgment/` or harness-evolution special root). Live artifact `state/harness-evolution/judgment/directive.json` has mode, decision, ts, direction, risks. |
| G2.2 later session re-derives | **PASS** — Advisor: two consecutive `gate harness-evolution status` byte-identical; status re-derives via `judgment_implement_refusal`, not chat. |

`judgment/` under `state/harness-evolution/` is correct `client_dir` routing for that engagement — not the rejected “global gate store” anti-pattern from debate E2.

### Pointer 3 — Override risks + non-waivers → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| G3.1 empty risks refuse + no write | **PASS** — smoke `override 'ship anyway' '' …`; Advisor discloses literal `override ''` is arity/`die` rather than the durable-no-write form. Substance of G3.1 met. |
| G3.2 archive risks + non-waivers | **PASS** — writer emits `non_waivers` all true; jq asserts; tamper `frozen_contract=false` → implement refuse with `non-waivable`, no rewrite. |

### Pointer 4 — Machine status → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| G4.1 valid JSON | **PASS** — live status: client, mode Directive, allowed, decision, reason, bound_direction, artifact, artifact_ts, required/present (`acceptance-build-2-status.txt`). Always exits 0 on status path. |
| G4.2 reflects durable decision | **PASS** — Challenge refused status asserted in smoke; live Directive status matches `directive.json`. |

### Pointer 5 — Per-mode refuse and pass paths → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| G5.1 eight ids real CLI | **PASS** — harness-checks runs `tests/judgment-gate-smoke.sh` (temp `gate-smoke-$$` + cleanup trap; no fixtures/mocks) and records exact §6.4 ids. |

**Would Critic flip any Advisor PASS to FAIL?** **No.**

---

## 4. Hazard review (assignment checklist)

| Hazard | Finding | Severity |
|--------|---------|----------|
| **Pointers** | All five §6.1 pointers met with durable files + real CLI evidence. | Clear |
| **Shell safety** | `bin/consult` `set -euo pipefail`; `die` → exit 1 (debate: pick one — consistent). Atomic tmp+`mv` mirrors workspace. `harness-checks` uses `set -uo pipefail` **without** `-e` so smoke rc is captured. `judgment_atomic_write` leaves `.tmp.$$` on mid-write kill; no fsync. Whitespace-only risk/direction passes `[[ -n ]]`. | Nit |
| **Mode / stale artifacts** | Current-mode-only reads; payload `mode` must match expected mode for ok predicates; stale files ignored not deleted; cross-mode writers refuse (`select` only Guided/Challenge, etc.). | Clear |
| **Challenge semantics** | Harmful path always refused when requested; safer requires matching Challenge-stamped selection; status after challenge-only is refused. Edge: `harmful == safer` still always refuses that string via harmful branch. | Clear (edge = nit) |
| **Override tamper / non-waivers** | No CLI waiver channel; non_waivers hardcoded true on write; false/missing → `judgment_override_ok` fail → refuse. Empty risk: no file. Tamper covered in smoke. | Clear |
| **Status honesty** | Re-derives allow/refuse from predicates; exit 0 when refused/legacy. **Nit:** Challenge `present.selection_matches` checks direction==alt only, not selection `mode==Challenge` — can read true while implement still refuses on mode mismatch. Override pass never asserts `allowed=true` status before tamper (implement exit 0 is the pass proof). | Nit |
| **Test validity** | Smoke is real CLI, not planted JSON. Harness layer is marker-grep thin (trusts smoke); `gate-override-pass` uniquely also requires smoke rc=0. Directive **empty** `risks:[]` allowed in code/docs but smoke always passes a non-empty risk — coverage gap, not pointer fail. Optional debate extras (unknown mode, cross-mode writer, legacy OFC status) absent from smoke. | Nit |
| **Scope churn** | Touches only permitted surfaces; Builds 3–4 unwired; no checks/score/bench through gate; JUDGMENT.md/examples not used as runtime store; no provider invocation. Builder-result claims Directive “implement that archives” — **not in code**; ARCHITECTURE tells the truth. | Nit (builder honesty) |
| **Advisor bias** | Independent pack; honest_limits disclose G3.1 form, no provider, frozen pre-noise, read-only live status. Did not accept abbreviated Directive mode-only pass. Closest soft spot: override-pass marker printed after post-pass tamper refuse — pass still exercised mid-script. | Clear (no flip) |
| **Frozen guard** | Reviewed artifact set shows no edits to §0 files; Advisor claims clean short-status on frozen paths; `judgment/` additive/untracked. This Critic did not re-hash locks (no validation commands). | Clear (as claimed) |

---

## 5. Diff / scores stance

**Diff (conceptual):** Smallest amended seam — new `lib/judgment-gate.sh` (~271 LOC), `cmd_gate` + help/dispatch, `tests/judgment-gate-smoke.sh`, eight harness ids, consult-smoke help line, README Judgment gates + ARCHITECTURE seam/layout. Matches `build-2-debate.md` survival list; does not implement rejected waiver channel, run-report gates, or Build 4 wiring.

**Scores:** No harness-apc-v1 `scores.json` for Build 2 (correct). Build 2 score = Advisor five-pointer PASS/FAIL only.

| Pointer | Advisor | Critic |
|---------|---------|--------|
| P1 All four modes bind Implement | PASS | **PASS** |
| P2 Durable judgment files | PASS | **PASS** |
| P3 Override risks + non-waivers | PASS | **PASS** |
| P4 Machine status | PASS | **PASS** |
| P5 Per-mode refuse/pass (8 ids) | PASS | **PASS** |

---

## 6. Org self-review (mandatory)

| Lens | Finding |
|------|---------|
| Role redundancy | Four permanents unchanged. “Advisor” remains a mission scoring label (Build2Acceptance), not a fifth permanent worker. Pre-impl Critic debate amended Analyst handoff; Builder followed amendments; no Principal Build 2 overrule needed. |
| Orchestration friction | Low. Debate → builder-result → Advisor pack is coherent. Risk: readers treating abbreviated §6.4 G1.2 Directive line as acceptance — **debate + shipped durable-`direct` rule are authoritative**. |
| Prompt gaps | README annotates `select` as “Guided only” but Challenge **requires** `gate select` for the safer alternative — operator doc bug. Builder-result overclaims implement-archive for Directive. |
| Memory gaps | `MEMORY.md` / progress still show Build 2 as `next` until close. After acceptance: append Override non-waivers, current-mode-only stale rule, eight gate ids, no waiver channel. |
| Benchmark blind spots | Directive empty-risks untested; Override status-allowed before tamper unasserted; whitespace-only risk; Challenge `selection_matches` mode-blind; harness marker-thin trust of smoke. |
| CLI UX | Gate surface is discoverable and small. Challenge flow is two-step (challenge → select safer → implement) — correct, but README must say so. Single-risk Override arity is enough for P3. |
| Unnecessary complexity | **Prefer deletion held:** one library, plain JSON, no daemon/DB/waiver API. Double execution of gate-smoke (direct acceptance + via harness-checks) is slight redundancy, not architecture bloat. |

---

## 7. Formal verdict

### **ACCEPT-WITH-NITS**

Build 2 may proceed as pointer-complete under `mission-benchmark.md` §6. Precise non-blockers to clean up opportunistically (not Build 2 re-opens unless owner expands scope):

1. README: fix `select` comment — Guided **or** Challenge (safer alternative only).
2. Align `build-2-builder-result.md` with code/ARCHITECTURE: implement is read-only; Directive durability is via `direct` only.
3. Optional smoke: Directive `direct` with zero risks (`risks:[]`); status `allowed=true` immediately after Override implement (before tamper).
4. Status: make `selection_matches` require selection `mode==Challenge` (or document the weaker flag).
5. Trim/reject whitespace-only risk and direction at writer boundaries.
6. MEMORY.md + `progress.json` Build 2 close note when Principal records acceptance.

**Blockers for REJECT:** none under the five owner pointers.

**Reject magnets not observed:** waiver channel; mode-default-to-Guided on implement; live-tree/Build 4 pre-wiring; mocks/fixtures as sole gate proof; umbrella check ids instead of the eight; frozen-file edits; Advisor PASS without durable/CLI evidence; silent scope scanner inventing a second contract engine inside the gate.

---

## 8. Out of scope (reaffirmed)

Builds 3–4; Builder invocation wiring; workspace-dirty coupling inside `gate implement`; MEMORY/run-report enforcement as gate predicates; product/client application code; provider invocation for its own sake; formatters/linters; re-opening harness-apc-v1 dimensions; editing `JUDGMENT.md` as runtime store.
