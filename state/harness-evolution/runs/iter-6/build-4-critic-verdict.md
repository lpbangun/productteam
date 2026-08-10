# Critic verdict — Build 4 (iter-6)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — active durable gate: `judgment/directive.json`
**Against:** Build 4 implementation (`lib/role-envelope.sh`, `bin/consult` role/score `--iter` wiring, `tests/role-envelope-smoke.sh`, eight harness role ids, README/ARCHITECTURE) + Advisor PASS (`evidence/build-4-advisor-verdict.json`)
**Acceptance:** `mission-benchmark.md` §8 (five owner pointers; §8.4 audit)
**Prior debate:** `build-4-debate.md` (pre-impl AMEND list)
**Principal:** `principal-build-4-decision.md` — ACCEPT amended role-envelope seam; OVERRULE no Critic amendments (binding corrections 1–8 adopted)
**Builder:** `build-4-builder-result.md` — Principal implemented after cancelled RoleEnvelopeBuilder; authorship disclosed
**Active Directive:** `state/harness-evolution/judgment/directive.json` — direction “Make unattended multi-iteration consulting operable under the Constitution”; `decision=allowed`
**Frozen:** §0 / §8.1 guard + iter-0..5 + Builds 1–3 verdicts — not edited by this verdict
**Method:** Evidence-backed file/code/docs audit only. No validation commands, tests, or product edits for this verdict. Skip all validation.

---

## Verdict: **ACCEPT-WITH-NITS**

Build 4 ships the Principal-accepted, debate-amended role-envelope seam: one `lib/role-envelope.sh`, `consult role … seal|invoke|status|close`, write-once Builder seal over real input bytes (no free Builder task), atomic request/result/manifest attempts including refusals, Analyst stamp + Critic close with role identities (not provider basenames), explicit `--iter N` score/bench gate, eight real-CLI markers plus authorship happy-path, README/ARCHITECTURE docs. Advisor’s five-pointer PASS is evidence-backed against §8.4 and the eight CLI markers. Nits below do **not** void Build 4; none is a precise acceptance blocker under the owner pointers as written in `mission-benchmark.md` §8.1.

**Do not treat this as harness-apc-v1 re-scoring.** Frozen APC remains converged at iter-5; iter-6 Build 4 scores only the five mission pointers. Completing Build 4 closes the mission `build_order` `[1,2,3,4]` for mission iteration 1.

---

## 1. Contract alignment (debate → Principal → code)

| Surface | Ruling |
|---------|--------|
| Single seam `lib/role-envelope.sh` + `bin/consult` only | **Met.** Sourced beside workspace/judgment/engagement-state; `bin/` contains only `consult`; no second CLI/orchestrator/daemon. |
| Invoke = single-turn `provider_ask` in isolated workspace | **Met.** `role_invoke` → `workspace_ensure` → one `provider_ask`; callsites: `lib/provider.sh:47` (def), `lib/role-envelope.sh:177`, `bin/consult:744` (bench). No second ask API, no mock provider. |
| Seal hashes Builder **input file bytes**; no divergent free task | **Met.** `role seal <iter> <file>` write-once; Builder invoke rejects any free task arg and replaces task with `cat` of sealed path after re-hash. |
| Target iteration shared by seal/stamp/score/close | **Met.** Paths under `roles/iter-<N>/…`; score/bench require `--iter N` and `role_stamp_refusal` for that same `N`; refuse overwrite of existing `runs/iter-N/scores.json`. |
| Failure envelopes always written | **Met.** Preflight (missing seal, hash mismatch, progress-block, gate, workspace) and provider non-zero all call `role_write_attempt` → request/result/manifest. Status reads only complete hash-verified attempts. |
| Identities = role-envelope `identity`, not provider binary | **Met.** `CONSULT_ROLE_IDENTITY` (defaults per role); same provider allowed; `implementer == evaluator` refused by name on score/close. |
| Close = Critic envelope + Analyst stamp + distinct identities → `close.json` | **Met.** Explicit `role close <iter>`; markdown Critic free-files are insufficient; already-closed refuses. |
| Builder order: pause → seal → implement gate → `provider_ask` | **Met.** `progress_blocked_reason` → `role_seal_refusal` → `judgment_implement_refusal` → workspace → ask. |
| Status file-only, byte-stable; inspect-pack not second role plane | **Met.** `asked`/`ran`/`produced`/`missing` from envelopes only; no inspect-pack schema expansion required or shipped as authority. |
| No Build 1–3 / frozen edits | **Met** in reviewed surfaces. Advisor frozen_guard claims only `runs/iter-6/` (+ pre-existing judgment/inspect-pack). This Critic did not re-hash locks (no validation commands). |

Command/file naming (`roles/iter-N/…/attempt-N/`, `stamp.json` vs illustrative `analyst-stamp.json`): **ACCEPT** — §8.1 seam note binds semantics, not spelling.

---

## 2. Eight real CLI markers (P5 surface)

| Id | Smoke path (real `bin/consult`) | Critic |
|----|----------------------------------|--------|
| `role-invoke-provider-seam` | `runtime --check`; missing `CONSULT_PROVIDER` Analyst invoke → non-zero; complete failed envelope; refusal names provider | **PASS** |
| `role-builder-seal-refusal` | Builder without seal → non-zero; names seal path; refusal enveloped | **PASS** |
| `role-builder-seal-mismatch` | seal write-once; second seal refuses; mutate input → hash mismatch refuse | **PASS** |
| `role-envelope-request-result-manifest` | Analyst+Builder+Critic each leave request/result/manifest; sha256sum matches manifest | **PASS** |
| `role-score-no-analyst-stamp` | `bench … run --iter 3` without stamp → non-zero; names missing stamp | **PASS** |
| `role-close-no-critic` | close with stamp, no Critic → non-zero; names Critic path | **PASS** |
| `role-implementer-evaluator-rejected` | shared identity Builder+Analyst → score/close refuse naming both | **PASS** |
| `role-status-file-derived` | status JSON asked/ran/produced; `cmp` byte-stable; no chat/transcript refs | **PASS** |

Extra (not one of the eight, but exercised): `role-authorship-happy-path` — distinct identities, `bench run --iter 0` + `close 0`, scores bound to stamp, `close.json` written.

Transcript: `evidence/acceptance-build-4-role-envelope-smoke.txt`. Harness: `evidence/acceptance-build-4-harness-checks.txt` (50/0; eight role ids `real-provider-envelope`). Smoke suite: `evidence/acceptance-build-4-smoke.txt` (help lists role; role status missing honesty). Advisor pack: `evidence/build-4-advisor-verdict.json`.

Harness improvement vs Build 3: all eight role markers require `role_probe_rc == 0` **and** marker text (not marker-only on one id).

---

## 3. Pointer-by-pointer score re-audit (Advisor PASS × evidence sufficiency)

### Pointer 1 — Role invoke + status over the existing provider seam → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| R1.1 help discoverable | **PASS** — help lists `consult role <client> seal\|invoke\|status\|close`; smoke `help lists role`. |
| R1.2 real single-turn Analyst via `provider_ask` | **PASS** — Advisor independent invoke (`AUDIT_ANALYST_OK`) + smoke happy Analyst; envelopes under `roles/iter-*/Analyst/attempt-*`; sole model entry `provider_ask`. |
| R1.3 missing provider refuses, no mock | **PASS** — smoke marker; exit 127; complete failed envelope; refusal_reason contains provider. |
| R1.4 status machine JSON asked/ran/produced | **PASS** — smoke + consult-smoke missing honesty on OFC (three missing attempt paths). |

### Pointer 2 — Per-iteration sealed Builder input → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| R2.1 Builder without seal refuses + names seal | **PASS** — smoke; enveloped. |
| R2.2 write-once content-addressed seal | **PASS** — seal.json with sha256/role/iter/sealed_at/write_once; second seal refuses. |
| R2.3 sealed + gate allows Builder | **PASS** — smoke Builder exit 0 after `gate direct` + seal; code consults `judgment_implement_refusal`. Dedicated gate-refuse marker absent → nit (coverage), not FAIL. |
| R2.4 tamper → hash mismatch | **PASS** — smoke; names mismatch + seal path. |

**Seal/task honesty (assignment lens):** **Clear.** Free Builder task arg is hard-refused at CLI; sealed file bytes become the prompt body after re-hash. No seal-theater path observed.

### Pointer 3 — Request / result / manifest evidence → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| R3.1 three roles leave complete envelopes with role/provider/ts/exit/hashes | **PASS** — smoke verifies sha256sum MATCH for Analyst/Builder/Critic; Advisor also verified a refused Builder attempt’s hashes MATCH. |
| R3.2 status re-derives from files alone | **PASS** — fresh CLI processes; `cmp` identical. |

**Refusal envelope / manifest integrity (assignment lens):** **Clear.** Preflight and provider failures write the triple; `role_manifest_ok` requires parseable files + hash equality; status ignores incomplete/tmp attempts via `role_latest_complete`.

### Pointer 4 — Close / score authorship gates → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| R4.1 scores without Analyst stamp invalid | **PASS** — `bench run --iter 3` refuses before workspace/provider; names stamp path. |
| R4.2 close without Critic refuses | **PASS** — smoke; names Critic dir. |
| R4.3 implementer = evaluator rejected | **PASS** — score + close; names shared identity + iter. |
| R4.4 happy path score valid + close | **PASS** — `scores.json` carries `iter`, `evaluator`, `analyst_stamp` path; `close.json` decision=closed with critic/stamp hashes + distinct identities. |

**Target iteration (assignment lens):** **Clear.** Unbound `latest+1` score allocation is gone; `--iter N` is mandatory; stamp and `runs/iter-N/scores.json` share `N`.

**Same-identity gates (assignment lens):** **Clear.** Comparison uses envelope/stamp `identity`, not provider basename; same `agent` binary across roles is allowed and proven.

### Pointer 5 — File-derived status; Builder-without-seal + authorship proofs → **PASS** (Advisor upheld)

| Check | Critic |
|-------|--------|
| R5.1 asked/ran/produced from files only; byte-stable | **PASS** — smoke jq + `cmp`; no chat/transcript/conversation/process refs. |
| R5.2 eight automated real-CLI markers | **PASS** — smoke exit 0 + harness 50/0 with all eight ids. |
| R5.3 prohibitions | **PASS** — no chat-log evidence paths; daemon/bus/swarm only as smoke README prose; `provider_ask` sole model entry; single `bin/consult`. |

**Status asked/ran/produced (assignment lens):** **Clear.** `asked` ← request; `ran` ← result (incl. refuse); `produced` ← manifest when `exit==0` and hashes present; missing roles explicit.

**Would Critic flip any Advisor PASS to FAIL?** **No.**

---

## 4. Hazard review (assignment checklist)

| Hazard | Finding | Severity |
|--------|---------|----------|
| **Provider fidelity** | Real authenticated `agent` runtime; missing-provider refuse; no mock binary; role + bench share `provider_ask`. Advisor happy-path score (overall 6.4 on tiny temp repo) is real provider output, disclosed as non-product. | Clear |
| **Seal / task honesty** | Seal = file bytes + abs path; Builder CLI forbids free task; invoke re-hashes sealed path and cats those bytes into the prompt. | Clear |
| **Refusal envelope / manifest integrity** | Always-write attempt triple; manifest indexes request/result sha256; status requires `role_manifest_ok`. Mid-write kill can leave `.tmp.$$` (atomic_write precedent). | Nit (tmp hygiene) |
| **Target iteration** | `--iter` required; stamp/score/close/seal bind same integer; refuse re-score when `scores.json` already exists for that iter. | Clear |
| **Same-identity gates** | Role identities via `CONSULT_ROLE_IDENTITY`; collision named on score/close; provider equality not used. | Clear |
| **Status asked/ran/produced** | File-derived; byte-stable; missing honesty in consult-smoke; produced excludes non-zero exits (honest). | Clear |
| **No second orchestrator** | One library, one CLI, no scheduler; Principal owns loop; ARCHITECTURE: “adds no scheduler.” | Clear |
| **Progress-block / gate composition** | Builder honors pause then seal then implement gate. **Stricter than debate E7:** *all* role invokes (incl. Critic) and `close` also hit `progress_blocked_reason` — recovery under pause is seal/status only, not Critic invoke/close. | Nit (stricter recovery surface) |
| **Coverage gaps** | Required eight markers omit dedicated Builder-while-paused and Builder-while-gate-refuses paths (code present; debate refusal list items 6–7). Stamp overwrite on later Analyst success is intentional (smoke supersession) but not write-once like seal. | Nit |
| **Checks scorer via `score --iter`** | Stamp required even for `scorer=checks`, but checks still archive under `runs/check-*` without embedding `analyst_stamp` — stricter gate, weaker artifact bind. Debate said checks are not the R4 vehicle; provider path is proven. | Nit |
| **Shell safety** | `set -euo pipefail` in smoke; blank identity rejected; `role_iter_ok`; atomic tmp+mv. Harness marker loop trusts smoke rc=0 for all eight (good). | Clear / prior nits |
| **Scope drift** | No inspect-pack takeover; no multi-turn loop; no daemon/DB/bus; bench Analyst prompt left as separate scorer (debate: do not rewrite wholesale) — stamp gates validity. | Clear |
| **Advisor bias** | Independent pack; honest_limits disclose temp engagements cleaned, CONSULT_SMOKE_SKIP_CLIENT, Build 4-only scope, real provider cost. Closest soft spot: R2.3 gate-respect asserted from code + successful Builder under pre-directed gate, without a refuse-path marker. | Clear (no flip) |
| **Frozen guard** | Advisor: changes under `runs/iter-6/` (+ additive judgment/inspect-pack); temp engagements removed. This Critic did not re-hash locks. | Clear (as claimed) |
| **Builder authorship honesty** | `build-4-builder-result.md` correctly attributes Principal implementation after cancelled subagent — no misattribution. | Clear |

---

## 5. Diff / scores stance

**Diff (conceptual):** Smallest amended seam — new `lib/role-envelope.sh` (~268 LOC), `cmd_role` + help/dispatch, score/bench `--iter` + `role_stamp_refusal` before provider/workspace work, scores.json gains `evaluator`/`analyst_stamp` binding, `tests/role-envelope-smoke.sh`, eight harness ids (+ happy-path marker), consult-smoke role lines, README Role envelopes + ARCHITECTURE role seam/layout. Matches `build-4-debate.md` survival list and `principal-build-4-decision.md` corrections 1–8. Does not implement rejected mock provider, chat-log status, second orchestrator, reseal/--force, provider-as-identity, or markdown-only Critic close.

**Scores:** No harness-apc-v1 `scores.json` for Build 4 (correct). Build 4 score = Advisor five-pointer PASS/FAIL only.

| Pointer | Advisor | Critic |
|---------|---------|--------|
| P1 Role invoke + status over provider seam | PASS | **PASS** |
| P2 Per-iteration sealed Builder input | PASS | **PASS** |
| P3 Request / result / manifest evidence | PASS | **PASS** |
| P4 Close / score authorship gates | PASS | **PASS** |
| P5 File-derived status + proofs (8 ids) | PASS | **PASS** |

Baseline → acceptance lift: all five were FAIL at `evidence/build-4-baseline.md`; all five PASS post-impl.

---

## 6. Org self-review (mandatory)

| Lens | Finding |
|------|---------|
| Role redundancy | Four permanents unchanged. “Advisor” remains a mission scoring label (Build4Acceptance), not a fifth permanent worker. Pre-impl Critic debate amended Analyst §8.3; Principal accepted amendments without overrule; cancelled RoleEnvelopeBuilder → Principal direct implement (disclosed). |
| Orchestration friction | Low. Debate → principal-decision → builder-result → Advisor pack is coherent. Risk: readers treating §8.3 illustrative names or unbound optional `[iter]` as the contract — **§8.1 five pointers + Principal corrections + shipped `--iter`/seal semantics are authoritative**. |
| Prompt gaps | `progress.json` still shows Build 4 `status: next` until Principal closes; `lessons.md` has Builds 1–3 addenda only — no Build 4 lesson yet; MEMORY has no Build 4 pointer. |
| Memory gaps | After acceptance: append seal=bytes-not-task, `--iter` stamp gate, identity≠provider, refusal envelopes always-write, eight marker ids, no second orchestrator, Critic-envelope close. |
| Benchmark blind spots | Pause/gate refuse on Builder not marker-proven; Critic/close blocked under pause (stricter than debate recovery); stamp overwrite; checks-scorer stamp-without-score-bind; harness still marker-grep over a real suite (now with suite rc=0). |
| CLI UX | Role surface is small and help-discoverable. Operators must pass `--iter` on score/bench and set `CONSULT_ROLE_IDENTITY` when proving authorship separation. Builder has no free task — correct, document-first. |
| Unnecessary complexity | **Prefer deletion held:** one library, plain JSON attempts, no identity service, no daemon, no inspect-pack dual authority. Attempt directories + superseding Analyst stamp are justified for refusal evidence and collision→happy-path proofs. Double execution of role-envelope-smoke (direct + harness) is slight redundancy, not architecture bloat. |

---

## 7. Formal verdict

### **ACCEPT-WITH-NITS**

Build 4 may proceed as pointer-complete under `mission-benchmark.md` §8. Precise non-blockers to clean up opportunistically (not Build 4 re-opens unless owner expands scope):

1. Align pause recovery with debate intent: keep Critic invoke and/or `close` available while paused (status/seal already are), **or** document the stricter “all role mutators pause” rule as intentional.
2. Add smoke (or acceptance transcript) for Builder refuse under open escalation/pause and under gate-implement refuse — today code-audited, not marker-proven.
3. Decide stamp write policy: document overwrite-on-success Analyst stamp (current) vs write-once-with-explicit-restamp.
4. For `scorer=checks`, either stop requiring Analyst stamp on `score --iter` or archive the stamp path beside check evidence when the gate fires.
5. Append Build 4 lesson + close `progress.json` Build 4 when Principal records acceptance; MEMORY pointer duty noted.

**Blockers for REJECT:** none under the five owner pointers.

**Reject magnets not observed:** unbound score iter / missing `--iter` theater; seal/task divergence; success-only envelopes; markdown-only Critic close; provider-basename identity equality; mock provider; chat-log status; inspect-pack as role-status authority; second orchestrator / daemon / bus / swarm; multi-turn agent loop; frozen-file edits; Advisor PASS without durable/CLI evidence; silent live-tree invoke.

---

## 8. Critic close / target iteration / convergence

| Item | Assessment |
|------|------------|
| **Critic close** | This file is the mission Critic acceptance record for Build 4. It is **not** a substitute for the product `consult role … close` envelope gate (that gate is proven separately by smoke/Advisor). |
| **Target iteration** | Mission iteration 1 of 3 (`progress.json`); Build 4 of ordered builds `[1,2,3,4]`. All four mission builds are now pointer-complete pending Principal progress close. |
| **Convergence** | **Mission Build 4: ACCEPT-WITH-NITS (converged on owner pointers).** Frozen `harness-apc-v1` remains **CONVERGED** at iter-5 (`convergence-report.md`) and is not re-opened. Residual mission work is bookkeeping (progress/MEMORY/lessons) and optional nits — not pointer failures. |
| **Status asked/ran/produced** | Proven file-derived and byte-stable under P1/P5; Critic upholds Advisor. |
| **No second orchestrator** | Held. |
| **Org review** | §6 above — no fifth permanent role; Principal-owned loop preserved. |

---

## 9. Out of scope (reaffirmed)

Product/client application code; daemons/DB/plugin/RAG/message-bus/swarm/auto-orchestrator; chat-log or transcript evidence; mock/stub providers; multi-turn agent loops; replacing `lib/provider.sh` / implement gate / engagement-state / inspect seams; formatters/linters; re-opening harness-apc-v1 dimensions; editing frozen iter-0..5 / contract / LOCK / FREEZE* / authorize-merge / engagement.md / LOOP-SEQUENCE; amending Builds 1–3 verdicts.
