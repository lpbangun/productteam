# Critic debate — Build 4 (pre-implementation)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — follow owner direction; refuse silent scope expansion; smallest diff
**Against:** §8.3 Analyst/candidate minimal design (role invoke/status over `provider_ask`, write-once Builder seal, request/result/manifest envelopes, Analyst stamp + Critic close authorship gates) + §8.1 seam notes
**Authority:** `AGENTS.md` (Principal/Analyst/Builder/Critic; Principal never scores own work) · `CONSTITUTION.md` (evidence; delete-before-add; no silent high-impact) · `mission-benchmark.md` §8 (five owner pointers + §8.4 audit) · baseline `evidence/build-4-baseline.md` · reusable seams: `lib/provider.sh`, `lib/judgment-gate.sh`, `lib/engagement-state.sh` / `progress_blocked_reason`, `lib/workspace.sh`
**Frozen:** §0 / Builds 1–3 verdicts + iter-0..5 + `state/harness-evolution/judgment/` — do not edit or re-score
**Out of scope:** product code; daemons/DB/plugin/RAG/bus/swarm/second orchestrator; chat-log evidence; mock providers; multi-turn agent loops; replacing provider/implement/inspect seams
**Stance:** An item survives only with a concrete pointer lift under §8.1. No product code. No validation commands run in this debate.

---

## Overall verdict

**AMEND the §8.3 candidate before implement.** Direction is right (single `bin/consult` surface; reuse `provider_ask`; plain per-engagement envelopes; write-once Builder seal; file-derived status; authorship gates without a new identity service). As written, several Analyst choices **under-specify the iteration binding for score/check**, **leave seal vs free-text task ambiguous**, **omit failure-envelope honesty**, and **leave close/identity half-defined** — each of which would leave a §8.1 pointer FAIL under §8.4 even if verbs ship:

| Drift | §8.3 / candidate says | Owner / seams require |
|-------|----------------------|------------------------|
| Score vs role `iter` | Optional `[iter]` on role; score/bench validity gated by “Analyst stamp” | Today `cmd_bench_run` **always allocates `latest+1`** and writes `runs/iter-N/scores.json`; `cmd_checks` writes `runs/check-*` with **no iter**. Stamp/close/score must bind a **target iteration** explicitly or the gate is untestable (R4.1/R4.4). |
| Seal vs `<task>` | `seal <iter> <input>` then `invoke Builder <task>` | Pointer 2 is content-addressed Builder **input**. A free divergent `<task>` after seal fails R2.3/R2.4 honesty. Seal the input; Builder prompt is derived from / verified against that sealed bytes. |
| Failure artifacts | “successful or failed invocation writes …” | Preflight refusals (no seal, gate refuse, progress-block, bad provider path) vs provider non-zero must have **one** honest rule so status `asked`/`ran`/`produced` stay file-true (P3/P5). |
| Close happy path | Critic envelope + distinct implementer/evaluator | Must say what close **writes**, where identities live (role stamps, not provider binary names), and that same-provider is allowed while same recorded identity is not. |
| Progress-block / gate order | Builder “also calls implement gate” | Builder is progress work: `progress_blocked_reason` → seal match → `judgment_implement_refusal` / `gate implement` → `provider_ask` in workspace. Do not fork a second pause check. |
| Inspect-pack expansion | Status from envelopes | P5 is **`role … status`**, not a mandatory Build-4 inspect-pack schema. Reuse missing-marker precedent; do not make inspect the second role-status plane. |

Constitution: delete-before-add favors **one** role-envelope seam (sourced lib beside `judgment-gate.sh` / `engagement-state.sh`), plain JSON under the engagement, no second orchestrator, no mock provider. Baseline (all five pointers FAIL) is accepted.

---

## Proposed elements — rebuttal matrix

Lenses: **scope · provider-seam fidelity · seal/task honesty · iteration binding · failure-artifact honesty · authorship identity · gate/progress composition · status missing honesty · test realism**.

### E1. Role invoke + status over `provider_ask`

| Verdict | **ACCEPT** surface · **AMEND** cwd/workspace, single-turn, provider refuse |
|---------|-----------------------------------------------------------------------------|

**Pointer lift if amended:** P1 (and feeds P3/P5).

**Corrected public surface (names illustrative; semantics binding):**

```text
consult role <client> invoke <Analyst|Builder|Critic> <task-or-input-ref> [iter]
consult role <client> status [iter]
consult role <client> seal <iter> <input-path>
consult role <client> close <iter>
```

**Rebuttal:**

- **ACCEPT** `provider_ask` as the **only** model entry point (`lib/provider.sh:47`; today sole callsite `bin/consult:664` in `cmd_bench_run`). Role invoke adds callsites; it must not add a second ask function, mock binary, or in-process model.
- **ACCEPT** single-turn only. Multi-turn loops are §8.5 automatic FAIL.
- **AMEND** cwd: invoke runs with `provider_ask "$prompt" "$repo"` where `$repo` is the **resolved isolated workspace** from `workspace_ensure` (Build 1) — never live `Repo:` fallback.
- **ACCEPT** missing/unauthenticated provider → non-zero, same honesty as `runtime --check` / bench (R1.3).
- **AMEND** default `[iter]`: if omitted on invoke/status, use a single documented default — **recommended:** highest existing `roles/<n>/` for that client, else `0`. Seal and close **require** explicit `<iter>` (no silent retarget).
- **REJECT** wiring Analyst invoke as a silent replacement of the entire `cmd_bench_run` prompt in this build unless needed for the stamp path — stamp gates **score validity**; they do not require rewriting the frozen client contract scorer in one step. (See E4.)
- Help must match `/role/` (R1.1). No new binary.

---

### E2. Seal / task relation (write-once, content-addressed)

| Verdict | **AMEND** (binding: sealed bytes are the Builder input; task may not diverge) |
|---------|------------------------------------------------------------------------------|

**Pointer lift if amended:** P2 (R2.1–R2.4).

**Corrected contract:**

| Step | Binding rule |
|------|--------------|
| `seal <iter> <input-path>` | Reads file bytes; writes seal artifact once with `sha256`, `role=Builder`, `iter`, `input_path` (or basename), `sealed_at`. Second seal for same iter → non-zero (“already sealed”), names seal path. |
| Builder invoke | **Requires** seal for that iter. Recomputes sha256 of the **same input path recorded in the seal** (or of an explicit `--input` that must match the sealed path). Mismatch or missing file → non-zero, names seal hash mismatch. |
| `<task>` argument | **AMEND:** either (a) omit free task and build the provider prompt strictly from sealed input bytes, or (b) treat `<task>` as a non-hashed wrapper **only if** the sealed input is still the sole Builder brief and is re-hashed. **REJECT** hashing the task string while sealing a different file (R2.4 becomes theater). |
| Analyst / Critic invoke | **No** seal required (P2 is Builder-only). |

**Rebuttal:**

- Pointer 2 text: “Builder input is sealed” / “input no longer matches the sealed hash” — the sealed object is the **input artifact**, not an unbound chat utterance.
- Seal is write-once per `(client, iter)` for Builder. No seal rewrite, no “reseal --force” in Build 4.
- Builder-without-seal refusal message must **name the expected seal path** (R2.1).

---

### E3. Request / result / manifest + failure artifact behavior

| Verdict | **ACCEPT** three-file envelope · **AMEND** when each is written |
|---------|----------------------------------------------------------------|

**Pointer lift if amended:** P3, P5 (`asked`/`ran`/`produced` honesty).

**Layout (illustrative):** `state/engagements/<client>/roles/<iter>/<Role>/{request,result,manifest}.json`
Atomic tmp+mv writers (same precedent as `judgment_atomic_write` / workspace evidence).

**Minimum fields:**

| File | Required fields |
|------|-----------------|
| `request.json` | `role`, `client`, `iter`, `provider` (resolved name/path), `task` or `input_ref`, `input_sha256`, `requested_at` |
| `result.json` | `role`, `provider`, `exit`, `output_ref` or summary, `ran_at`, optional `refusal_reason` |
| `manifest.json` | `role`, `provider`, `requested_at`, `ran_at`, `exit`, `sha256_request`, `sha256_result` |

**Failure / refusal matrix (binding):**

| Outcome | request | result | manifest | status impact |
|---------|---------|--------|----------|---------------|
| Provider ran, exit 0 | write | write `exit=0` | write | asked + ran + produced |
| Provider ran, exit ≠0 / unparseable | write | write `exit≠0` (+ optional raw output ref, same spirit as `raw-provider-output.txt`) | write | asked + ran; produced may be empty/partial but files exist |
| Preflight refuse: missing seal / hash mismatch | **AMEND: write** request stating intent + `input_sha256` attempted | write `exit≠0`, `refusal_reason` naming seal | write | asked + ran(refused); proves R2 in files |
| Preflight refuse: progress-block or gate implement | write request | write refuse result naming block/gate artifact | write | same |
| Preflight refuse: provider binary missing **before** ask | write request with resolved provider attempt | write refuse result (no mock fallback) | write | R1.3 evidence on disk |
| Crash mid-write | leave prior complete envelopes; partial tmp files must not count as produced (status reads only final JSON) | | | |

**Rebuttal:**

- **REJECT** “failed invoke writes nothing” — that makes P3/P5 and R2.1 unverifiable after the process exits.
- **ACCEPT** hashes via sha256 of request/result file bytes in manifest (R3.1).
- **REJECT** chat/transcript paths as `output_ref`. Output refs stay under the engagement run/role dirs.

---

### E4. Score / check **target-iteration** semantics

| Verdict | **AMEND** (this is the largest §8.3 hole) |
|---------|-------------------------------------------|

**Pointer lift if amended:** P4 (R4.1, R4.3, R4.4) — without this, authorship gates cannot PASS.

**Problem (repository seam):**

- `cmd_bench_run` always creates `runs/iter-((latest+1))` and writes `scores.json` with no Analyst stamp and optional free-text `evaluator` nowhere enforced (`bin/consult:617–692`; baseline probe 4).
- `cmd_checks` archives under `runs/check-*`, **not** `roles/<iter>/` or `runs/iter-N` (`bin/consult:467–487`).
- §8.3’s optional role `[iter]` and score validity are therefore **unlinked**.

**Corrected binding rules:**

1. **Role-envelope iteration** (`roles/<iter>/…`) is the authorship unit for seal/stamp/close/status.
2. **Score target iteration** for P4:
   - Provider scorer path: `consult score` / `bench … run` publishes `runs/iter-N/scores.json` for a concrete `N`. **AMEND:** that `N` is the target iteration for stamp checks — either (a) score accepts `--iter N` / uses current sealed+stamped role iter, or (b) successful score **requires** an Analyst stamp already present for `N` before scores are treated valid. Recommended smallest diff: on score/bench completion (and on any “is this score valid?” read used by close), require `roles/<N>/Analyst/` stamp artifact (see E5) matching that same `N`; if missing → non-zero **or** write/keep `invalid:true` on scores and treat as invalid (R4.1). Pick **one** shipped behavior and test it; prefer refuse-to-accept-as-valid with named missing stamp.
   - Checks scorer path: deterministic checks do not produce Analyst contract scores. **AMEND:** P4 score gate applies to **score/bench score artifacts** (`runs/iter-N/scores.json`). Checks remain progress-blocked by Build 3 but are **not** required to carry an Analyst stamp. Close still keys off Critic envelope + identity rules for the role iter. Do not invent a fake Analyst stamp for OFC checks-only engagements inside Build 4 acceptance — use a **provider-scored temp engagement** (or agcode-learning-shaped fixture) in role smoke for R4.\*.
3. **Do not** silently stamp whatever `latest+1` happens to be after an unbound Analyst invoke on a different iter — stamp and scores must cite the **same** `iter` integer.
4. **REJECT** treating optional free-text `evaluator` in legacy `scores.json` as the Analyst stamp (baseline: it is not a gate).

---

### E5. Analyst stamp + close happy path + implementer≠evaluator

| Verdict | **AMEND** stamp shape, identity source, close artifact |
|---------|--------------------------------------------------------|

**Pointer lift if amended:** P4 (R4.1–R4.4).

**Analyst stamp (durable):**

- Produced by successful Analyst invoke for that iter **or** by an explicit `stamp` subcommand that only records an already-completed Analyst envelope — prefer **one**: successful Analyst invoke writes `roles/<iter>/Analyst/analyst-stamp.json` (or stamp fields inside result/manifest) with at least: `role=Analyst`, `iter`, `provider`, `identity`, `result_sha256`, `stamped_at`.
- Scores for `iter=N` without that stamp → **invalid** (R4.1).

**Identity (binding, anti-theater):**

| Side | Source of identity |
|------|--------------------|
| **Implementer** | Builder envelope for that iter: `result.json` / stamp field `identity` (CLI-supplied `--identity` or default `builder`, **not** the provider binary basename alone) |
| **Evaluator** | Analyst stamp `identity` (CLI-supplied `--identity` or default `analyst`) |

- **ACCEPT** same physical provider (`agent`) on both sides — AGENTS.md separates **roles**, not GPUs.
- **REJECT** using `provider` string equality as the implementer=evaluator check (would false-positive every real run).
- Close and score refuse when `implementer_identity == evaluator_identity` (R4.3), naming both identities and the iter.

**Close happy path (R4.4) — exact contract:**

```text
pre:  roles/<iter>/Analyst/ envelope + analyst-stamp present
pre:  roles/<iter>/Critic/  request+result+manifest present (free-file critic-verdict.md is NOT enough)
pre:  implementer_identity ≠ evaluator_identity
pre:  (recommended) Builder envelope present if implementation claimed; not required by P4 text for close — Critic record is the close gate
cmd:  consult role <client> close <iter>   → exit 0
writes: roles/<iter>/close.json (or equivalent) with
        {iter, closed_at, critic_manifest_sha256, analyst_stamp_sha256,
         implementer_identity, evaluator_identity, decision:"closed"}
```

| Refuse | Message names |
|--------|----------------|
| No Critic envelope | missing Critic request/result/manifest path |
| No Analyst stamp | missing stamp path (also keeps scores invalid) |
| implementer == evaluator | both identities + iter |
| Already closed (optional) | existing `close.json` — second close may no-op 0 or refuse; pick one and test |

**Rebuttal:**

- §8.1 P4: “Close refuses without a Critic **record**” + §8.3: Critic **envelope**, not markdown alone — **ACCEPT** envelope requirement; **REJECT** `critic-verdict.md` as sufficiency.
- **REJECT** auto-close from Critic invoke success — close is an explicit verb (discoverable; R4.2).

---

### E6. File-derived status (asked / ran / produced)

| Verdict | **ACCEPT** · **AMEND** derivation rules + byte-stability |
|---------|----------------------------------------------------------|

**Pointer lift if amended:** P1 (R1.4), P5 (R5.1).

**Derivation (files only):**

| Field | True when |
|-------|-----------|
| `asked` | `request.json` present for that role/iter |
| `ran` | `result.json` present (including refuse/non-zero exits) |
| `produced` | `manifest.json` present **and** `result.exit==0` with verifiable hashes **or** explicit produced artifact refs listed in result — pick one; recommended: manifest present + hash verify ⇒ produced entry exists; status may still show `exit` |
| missing roles | explicit empty arrays or per-role `missing:true` — never omit keys; never invent from chat |

**Rebuttal:**

- **ACCEPT** two consecutive `status` calls with unchanged files → byte-identical derived answer (no `status_at` wall-clock inside `asked`/`ran`/`produced`).
- **REJECT** reading transcripts, daemon state, or inspect-pack as the authority for role status.
- **AMEND** inspect-pack: Build 4 **may** later expose a role summary key, but §8.4 P5 PASS does **not** require inspect-pack schema expansion. Keep `consult role … status` as the pointer surface (Build 3 inspect remains precedent only).

---

### E7. Gate + progress-block composition (Builder)

| Verdict | **ACCEPT** reuse · **AMEND** call order · **REJECT** second block predicate |
|---------|------------------------------------------------------------------------------|

**Pointer lift if amended:** P2 (R2.3 gate respect), Constitution pause honesty, §6.1 later-consumer note.

**Builder invoke order (binding):**

1. Resolve client + workspace (`workspace_ensure`)
2. `progress_blocked_reason` → if non-empty, refuse (named path); still write failure envelope per E3
3. Seal present + hash match → else refuse (P2)
4. `judgment_implement_refusal` / equivalent read-only gate check (Build 2 surface) → else refuse
5. `provider_ask` single-turn in workspace cwd
6. Write result + manifest

**Rebuttal:**

- **ACCEPT** Builder consumes existing implement gate; does not re-implement modes.
- Analyst/Critic invoke: **not** implement — do **not** require gate allow. They **should** still honor progress-block if Principal wants scoring frozen under pause — **AMEND smallest:** block Builder always; block Analyst invoke only when it is used as the score path; Critic/status/seal/close remain available for recovery (mirrors Build 3 “read/control remain available”). If Analyst invoke is separate from `cmd_score`, do not double-block unless score itself is called.
- **REJECT** daemon “role runner” or auto-orchestrator that chains Analyst→Builder→Critic without Principal.

---

### E8. Automated proofs (smoke + harness ids)

| Verdict | **ACCEPT** §8.4 R5.2 marker set · **AMEND** fixture = temp provider-shaped engagement |
|---------|----------------------------------------------------------------------------------------|

**Pointer lift if amended:** P5 (and regressions for P1–P4).

| Required marker (§8.4) | Must prove with real CLI |
|------------------------|--------------------------|
| `role-invoke-provider-seam` | help + Analyst invoke via `provider_ask`; envelopes on disk; `runtime --check` green |
| `role-builder-seal-refusal` | Builder without seal → non-zero; names seal |
| `role-builder-seal-mismatch` | seal then mutate input → Builder refuse |
| `role-envelope-request-result-manifest` | Analyst+Builder+Critic each leave three files with role/provider/ts/exit/hashes |
| `role-score-no-analyst-stamp` | score/bench target iter without stamp → invalid/non-zero |
| `role-close-no-critic` | close without Critic envelope → non-zero |
| `role-implementer-evaluator-rejected` | same identity both sides → score/close refuse |
| `role-status-file-derived` | status JSON asked/ran/produced; byte-stable; no chat paths |

Template: temp engagement + cleanup trap (`tests/workspace-smoke.sh` / `judgment-gate-smoke.sh` / `escalation-smoke.sh`). Real authenticated provider for at least one Analyst invoke path (R1.2); seal/mismatch/close refuse paths must not require mocks — they fail before ask or use the real seam’s missing-provider refuse.

Docs: README + ARCHITECTURE one row each for `roles/` envelopes, seal, stamp, close — enough for operators.

---

## Pointer-by-pointer decisions

### Pointer 1 — Role invoke + status over the existing provider seam

| Decision | **ACCEPT** · **AMEND** workspace cwd + iter default |
|----------|-----------------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E1; `cmd_role` invoke/status; `provider_ask` only; R1.1–R1.4 |
| Reject / cut | Second ask API; mock provider; multi-turn loop; live `Repo:` cwd |
| Risks | Replacing `cmd_bench_run` wholesale — out of scope; add callsites, gate scores via stamp (E4/E5) |

### Pointer 2 — Per-iteration sealed Builder input

| Decision | **AMEND** seal/task relation (E2) |
|----------|-----------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | write-once seal; Builder-without-seal + mismatch refuses; gate+progress order (E7) |
| Reject / cut | Free divergent `<task>` as the hashed object while sealing another file; reseal/--force |
| Risks | Seal of prompt wrapper only — forbidden; seal the Builder input bytes |

### Pointer 3 — Request / result / manifest evidence

| Decision | **ACCEPT** three-file schema · **AMEND** failure writes (E3) |
|----------|--------------------------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | per-role envelopes under engagement; hashes; all three roles in R3.1 |
| Reject / cut | Success-only writes; chat/transcript evidence; DB/bus |
| Risks | Crash partial JSON counted as produced — status must require complete parseable files |

### Pointer 4 — Close / score authorship gates

| Decision | **AMEND** target-iter + stamp + identity + close.json (E4/E5) |
|----------|---------------------------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | Analyst stamp required for valid scores; close needs Critic envelope; identity inequality; R4.1–R4.4 happy path |
| Reject / cut | Legacy `evaluator` free text as stamp; provider-basename identity; markdown-only Critic; auto-close on Critic invoke |
| Risks | Checks-scored clients — do not fake stamps; prove R4 on provider-scored fixtures |

### Pointer 5 — File-derived status; Builder-without-seal + authorship proofs

| Decision | **ACCEPT** status derivation · **AMEND** proofs to R5.2 ids (E6/E8) |
|----------|---------------------------------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | `role status` JSON; eight harness/smoke markers; prohibition audit R5.3 |
| Reject / cut | Chat-log status; mandatory inspect-pack role schema as PASS condition; mocks |
| Risks | Wall-clock drift breaking byte-stability — omit status clocks from derived fields |

---

## Exact contract corrections (patch list against §8.3)

These corrections are binding for implement; §8.1/§8.4 pointer semantics unchanged:

1. **Seal/task:** Seal hashes Builder **input file bytes**. Builder invoke re-hashes that file; free task text must not be an alternate unbound brief.
2. **Target iteration:** Stamp, seal, close, and score validity share one integer `iter`. Score/bench validity checks `roles/<iter>/…` for that same `iter` as `runs/iter-<iter>/scores.json` (or refuse). No unbound “latest” stamp.
3. **Failure artifacts:** Preflight and provider failures still write request+result+manifest with `exit≠0` and `refusal_reason` when applicable.
4. **Identities:** Compare stamp/envelope `identity` fields (role-level), not provider binary names.
5. **Close:** Explicit `close <iter>` writes durable `close.json`; requires Critic envelope + Analyst stamp + distinct identities.
6. **Builder order:** progress-block → seal → implement gate → `provider_ask`.
7. **Status:** Derive only from envelopes; byte-stable; explicit missing; no chat.
8. **Checks vs scores:** Analyst-stamp gate applies to score artifacts; deterministic checks path is not the R4 vehicle.

---

## Product / autonomy semantics drift flags

1. **Unbound score iter vs role iter.** Shipping invoke/seal without target-iter binding leaves R4 unprovable — **REJECT** as P4 FAIL.
2. **Seal theater.** Sealing path A while Builder runs task B — **REJECT** (P2).
3. **Provider-as-identity.** Collapsing implementer=evaluator to “same `agent` binary” either always fails or never fails — autonomy/evidence drift; use role identities.
4. **Markdown Critic close.** Free `critic-verdict.md` without envelope — fails §8.3 and P4.
5. **Second orchestrator.** Auto pipeline Analyst→Builder→Critic daemon/bus — §8.5 automatic FAIL.
6. **Mock provider for CI.** Forbidden by mission hard gate and P1.
7. **Frozen re-score / inspect-pack takeover.** Do not amend Builds 1–3 verdicts; do not make inspect the role-status authority.

---

## Cross-cutting risks

| Risk | Mitigation |
|------|------------|
| Second orchestrator / architecture inflation | One `lib/role-envelope.sh` (or equivalent); Principal still owns the loop |
| Freeze violation | Touch only non-frozen harness code + `runs/iter-6/` artifacts; never contract/LOCK/FREEZE*/engagement.md/LOOP-SEQUENCE/authorize-merge/iter-0..5; do not amend Build 1–3 verdicts or harness `judgment/` |
| Score/stamp iter skew | E4 binding; tests assert same `iter` on stamp and scores |
| Partial envelopes | Status ignores unparseable/tmp; writers atomic |
| Real provider cost/flakes in smoke | One real Analyst invoke proof; refusal paths fail closed before ask; no mocks |
| Progress-block bypass on Builder | Shared `progress_blocked_reason` before seal/gate |
| Scope bleed into product | Explicit refuse list below |

---

## Refusal paths that must be tested

Automated (smoke and/or harness-checks), real commands, named messages:

1. **Help discoverability** — `consult help` matches `role`.
2. **Provider missing** — `CONSULT_PROVIDER=/nonexistent/…` Analyst invoke → non-zero; envelope refuse recorded.
3. **Builder without seal** — non-zero; names seal path.
4. **Double seal** — second seal → non-zero.
5. **Seal mismatch** — mutate input; Builder → non-zero; names hash mismatch.
6. **Builder while progress-blocked** — open escalation or pause → non-zero; names block artifact.
7. **Builder while gate refuses** — Guided with no selection → non-zero (implement gate).
8. **Envelope completeness** — each role leaves request/result/manifest with required fields + verifying hashes.
9. **Score without Analyst stamp** — non-zero or `invalid:true`; names stamp.
10. **Close without Critic envelope** — non-zero; names Critic path.
11. **implementer = evaluator** — non-zero on score/close; names identities.
12. **Close happy path** — stamp + Critic + distinct identities → close 0; `close.json` on disk; scores valid.
13. **Status file-derived + byte-stable** — asked/ran/produced from files only; two runs identical.
14. **Prohibitions** — no new chat-log evidence requirement; no daemon/bus/swarm; `provider_ask` remains sole model entry.
15. **Keep existing refusals** — workspace dirty, gate modes, escalation/pause blocks, merge-without-authorize (no regression).

---

## Final implementable scope (smallest corrected work list)

Build 4 ships **only** the following. Expected outcome: all five §8.1 pointers PASS under §8.4.

1. **Add `lib/role-envelope.sh`** (name illustrative) — seal write-once + hash verify; envelope atomic writers; stamp read/write; identity helpers; status JSON derivation (`asked`/`ran`/`produced`); close writer/predicates; failure-envelope helper.
2. **Extend `bin/consult`** — `role` dispatch: `invoke|status|seal|close` (+ help); invoke uses `workspace_ensure` + `provider_ask` only; Builder path calls `progress_blocked_reason` then seal then existing implement-gate refusal then ask; wire score/bench **validity** to Analyst stamp for target `iter` (E4); do not replace provider seam, judgment writers, or engagement-state machine.
3. **Durable files** — per engagement `roles/<iter>/<Role>/{request,result,manifest}.json`, Builder `seal.json` (or equivalent), `Analyst/analyst-stamp.json`, `close.json`.
4. **Tests** — `tests/role-envelope-smoke.sh` (or harness embedding) covering R1–R5 marker ids above; temp engagement; real provider for invoke seam proof; refusal paths without mocks.
5. **Docs** — README + ARCHITECTURE rows for role envelopes / seal / stamp / close only.

**Explicitly out of Build 4:** client product code; daemons/DB/plugin/RAG/message-bus/swarm/auto-orchestrator; chat-log or transcript evidence; mock/stub providers; multi-turn agent loops; replacing `lib/provider.sh` / implement gate / inspect seams; editing frozen harness-apc-v1 files / iter-0..5 / `authorize-merge`; re-scoring Builds 1–3; mandatory inspect-pack role schema; treating provider basename as authorship identity; reseal/--force; silent live-tree invoke.

**Owner escalation note:** Role-envelope + authorship gates are an architecture seam under an owner-directed Build 4 (Directive). If implementers propose a daemon, mock provider, chat-log status plane, or waiver of Critic-envelope close, Critic records **Challenge** and refuses. If score validity is not bound to a target iteration’s Analyst stamp, Critic **rejects** the implementation as P4 miss.

---

## Survival summary

| Element | Verdict | Concrete pointer lift |
|---------|---------|------------------------|
| Role invoke/status over `provider_ask` | **ACCEPT** · **AMEND** workspace cwd + iter default | P1 FAIL→PASS |
| Seal / task relation | **AMEND** (sealed input bytes; no divergent brief) | P2 FAIL→PASS |
| Request/result/manifest + failures | **ACCEPT** · **AMEND** always-write refuse envelopes | P3, P5 FAIL→PASS |
| Score/check target-iteration | **AMEND** (bind stamp ↔ `runs/iter-N`) | P4 FAIL→PASS |
| Close happy path + identities | **AMEND** (`close.json`; role identities; Critic envelope) | P4 FAIL→PASS |
| File-derived status | **ACCEPT** · **AMEND** byte-stable derivation | P1, P5 FAIL→PASS |
| Gate + progress-block on Builder | **ACCEPT** · **AMEND** order | P2 (R2.3) |
| Automated R5.2 proofs | **ACCEPT** markers · **AMEND** provider-scored fixtures for R4 | P5 FAIL→PASS |
| Mock provider / chat logs / second orchestrator / inspect-as-authority / provider-as-identity | **REJECT** | none (anti-drift) |

**Critic bottom line:** Implement the amended list — nothing larger. The §8.3 handoff survives as a **corrected plain-file role envelope** (single-turn `provider_ask`, write-once Builder seal over real input bytes, request/result/manifest including refusals, target-iter Analyst stamp + Critic close with role identities, file-derived status), not as unbound score theater, not as seal/task ambiguity, and not as a foothold for mocks, chat-log evidence, or a second orchestrator. **Score validity without a target-iteration Analyst stamp is a hard reject.**
