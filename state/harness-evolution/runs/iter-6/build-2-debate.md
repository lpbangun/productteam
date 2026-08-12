# Critic debate — Build 2 (pre-implementation)

**Role:** Critic (adversarial)
**Mode:** Directive (`engagement.md`) — follow owner direction; refuse silent scope expansion; smallest diff
**Against:** Build2Analyst compressed handoff (mode truth table, `judgment/` JSON schema, `consult gate` writers, G1–G16 scenarios, stale/cross-mode mitigations) + §6 illustrative seam notes
**Authority:** `JUDGMENT.md` (mode semantics) · `mission-benchmark.md` §6 (five owner pointers + §6.4 audit) · baseline `evidence/build-2-baseline.md`
**Frozen:** §0 / §6.2 files + iter-0..5 + Build 1 verdicts — do not edit or re-score
**Out of scope:** Builds 3–4 (not inspected, not proposed)
**Stance:** An item survives only with a concrete pointer lift. No product code. No validation commands run in this debate.

---

## Overall verdict

**AMEND the Analyst proposal before implement.** Direction is right (plain-file gate beside `workspace.json`; `bin/consult` remains the single entry; implement is a reusable read-only predicate for later Build 4). As written, several Analyst choices **drift from JUDGMENT.md / §6 pointer semantics** or over-bind process that §6 does not require:

| Drift | Analyst says | Owner / JUDGMENT require |
|-------|--------------|--------------------------|
| Override artifact field | `waivers` list that must *not* contain non-waivable keys | Record **non-waivers** (critic / evidence / frozen-contract) as required present facts (§6.1 P3, §6.4 G3.2; `JUDGMENT.md:23-26`) |
| Check ids | `judgment-gate-predicates` + `judgment-gate-refuse-honest` wrapping G1–G16 | Exactly the eight ids in §6.4 G5.1 (`gate-guided-refuse` … `gate-override-pass`) |
| Directive implement | Always refuse until `directive.json` exists | Durable direction+decision required (P2), but §6.4 G1.2 shows Directive pass after mode set — reconcile via `direct` writer **or** first successful `implement <direction>` that archives `directive.json` |
| `implement` arity | Always requires `<direction>` arg matching payload | Guided/Directive may omit arg and use `payload.direction`; Challenge hard-binds to `.alternative` only |
| Mode-change process | Challenge writer errors if stale `override.json` unless dated run-report note | JUDGMENT mid-engagement note is org/report duty — not a Build 2 CLI gate; current-mode-only reads suffice |
| Frozen score claim | Gate lifts harness-apc-v1 product-judgment toward 9–10 | §6.2 forbids re-scoring frozen contract; Build 2 scores only the five mission pointers |

Constitution: one seam (`lib/judgment-gate.sh`), plain JSON under the engagement, no second orchestrator. Directive mode forbids inspecting or scaffolding Builds 3–4. Baseline (all five pointers FAIL) is accepted.

---

## Proposed elements — rebuttal matrix

Lenses: **scope · JUDGMENT fidelity · durable-file honesty · CLI compatibility · stale-state safety · override non-waiver semantics · test realism**.

### E1. Mode predicates (truth table)

| Verdict | **AMEND** |
|---------|-----------|

**Pointer lift if amended:** P1 (all four modes bind Implement), feeds P5 refuse/pass.

**Rebuttal by mode:**

| Mode | Analyst predicate | Critic ruling |
|------|-------------------|---------------|
| **Guided** | Refuse implement until `judgment/selection.json` has non-empty `direction` + `selected_by` | **ACCEPT.** Matches `JUDGMENT.md:8-11` (no implement until Principal/owner selects). |
| **Directive** | Refuse until `directive.json` has non-empty `direction` + `risks` array (may be empty) | **AMEND.** Empty `risks` array is faithful to Directive ("surface risks", not require them). Requiring a durable direction file is correct for P2, but §6.4's abbreviated G1.2 must not be read as "mode set alone ⇒ PASS". Surviving rule: Mode=Directive **and** durable direction on disk (via `direct` writer **or** `implement <direction>` that writes `directive.json` with `decision`+`ts`). Silent scope expansion remains a human/Critic concern — do not invent a second frozen-contract scanner inside the gate. |
| **Challenge** | Payload with rejected `direction`, non-empty `alternative` + `evidence`; implement **only** if proposed target == `.alternative` | **ACCEPT.** Matches seam note (§6.1) and `JUDGMENT.md:18-21` / `examples/challenge-refusal.md`. Challenged path always refuses. |
| **Override** | Non-empty `risks`, `critic_verdict`, `evidence`, plus `waivers` array | **AMEND** field semantics — see E6. Predicate shape (non-empty risks + critic + evidence + non-waiver record) **ACCEPT** in substance. |
| Missing / unknown Mode | Refuse implement; do not default to Guided | **ACCEPT.** `cmd_judge` may still display Guided (`bin/consult:288`); implement must not. |

**Cross-mode:** engagement must exist (`client_dir`). Do **not** couple Build 2 `gate implement` to workspace dirty checks — Analyst correctly defers that to Build 4 invocation; keep the predicate read-only.

---

### E2. Artifact shape (`state/engagements/<client>/judgment/*.json`)

| Verdict | **ACCEPT** (four mode files + status derivation) · **AMEND** Override schema + required decision fields |
|---------|----------------------------------------------------------------------------------------------------------|

**Pointer lift if amended:** P2 (durable gates), P3 (Override record), P4 (status reads files).

**Rebuttal:**

- Four plain JSON files beside `engagement.md` / `workspace.json` — **ACCEPT** (no DB, no new top-level tree, atomic tmp+mv mirroring `lib/workspace.sh:84-95`).
- Every payload MUST carry `mode`, `ts` (ISO UTC), and enough fields for status to report a **decision** (`allowed`|`refused` derived, or explicit `decision` written by writers / successful implement archive). Pointer 2's "decision, mode, timestamp" is the acceptance unit — presence-only files without a decidable implement outcome fail G2.1.
- Optional fields (`alternatives` on Guided, `constraints` on Directive, `recorded_in` on Override) — **NARROW**: allowed as non-predicate metadata; never gate-blocking.
- **REJECT** placing `judgment/` under `state/harness-evolution/` for Build 2 writers (frozen-guard bleed). `client_dir` routing is mandatory.
- **Do not edit** `JUDGMENT.md` or example markdown under `examples/` as the runtime store — examples stay documentation; runtime state is JSON.

Corrected Override shape (replaces Analyst `waivers` inversion):

```json
{
  "ts": "…Z",
  "mode": "Override",
  "direction": "…",
  "risks": ["non-empty…"],
  "critic_verdict": "path or inline non-empty",
  "evidence": ["path:…"],
  "non_waivers": {
    "critic": true,
    "evidence": true,
    "frozen_contract": true
  }
}
```

All three `non_waivers.*` must be present and true; any false/missing → refuse. There is no channel to mark the frozen contract waived.

---

### E3. CLI writer + `cmd_gate` surface

| Verdict | **ACCEPT** verbs · **AMEND** implement arity, Directive archive path, exit convention |
|---------|----------------------------------------------------------------------------------------|

**Pointer lift if amended:** P1–P4 discoverability and writers; P4 machine status.

**Rebuttal:**

Surviving public surface (names may match §6.1 illustrative set — binding is semantics, not spelling):

```text
consult gate <client> status
consult gate <client> implement [<direction>]
consult gate <client> select <direction> …
consult gate <client> direct <direction> [--risks …]
consult gate <client> challenge … --alternative … --evidence …
consult gate <client> override … --risks … --critic-verdict … --evidence …
```

- **ACCEPT** keeping `consult judge … set` as the sole mode-verb store (`engagement.md`). Gate payloads are not a second mode authority.
- **ACCEPT** `status` + `implement` as read-mostly; writers mutate only `judgment/*.json`.
- **AMEND** `implement [<direction>]`: if omitted, use current mode payload's implementable direction (Guided/Directive: `.direction`; Challenge: `.alternative`; Override: `.direction`). If provided, must equal that binding or refuse with a message that names the client and the durable file path.
- **AMEND** Directive: either `direct` writer before implement, or `implement <direction>` that creates/updates `directive.json` (decision archived). Mode-only implement with no direction on disk → refuse (`no directive recorded`) — this supplies G5's Directive refuse path honestly.
- **AMEND** exit codes: any non-zero refuse is enough for §6.4; prefer `die`-consistent exit 1 unless the suite already standardizes on 2 — pick one and test it; do not treat exit 2 as a new protocol.
- Help must match `/gate/` (G1.1). No new binary. No wiring of `checks`/`score`/`bench` through the gate in Build 2 (Build 4 consumer).

---

### E4. Stale-file / cross-mode behavior

| Verdict | **ACCEPT** current-mode-only reads · **REJECT** run-report-note enforcement in writers · **ACCEPT** exact-direction stale guard |
|---------|--------------------------------------------------------------------------------------------------------------------------------|

**Pointer lift if amended:** P1 correctness under mode switches; avoids false Override re-authorization.

**Rebuttal:**

| Analyst mitigation | Ruling |
|--------------------|--------|
| `status`/`implement` read **current** `Mode:` first; ignore other modes' JSON | **ACCEPT** (do not auto-delete; delete-before-add does not mean silent history wipe) |
| `implement` arg must match `payload.direction` | **ACCEPT** as stale-supersession guard (see E5) |
| Challenge writer errors if `override.json` exists unless dated run-report note | **REJECT** for Build 2. `JUDGMENT.md:30-32` is a report/MEMORY process rule. Gate rule: if Mode is Challenge, evaluate `challenge.json` only. |
| Empty `risks:[]` OK in Directive, refuse in Override | **ACCEPT** (G4 vs G8 substance) |
| Evidence is point-in-time (`ts`); no live re-verify in Build 2 | **ACCEPT** |
| Atomic tmp+mv; last-writer-wins | **ACCEPT** |

---

### E5. Exact-direction binding

| Verdict | **ACCEPT** with arity amendment |
|---------|--------------------------------|

**Pointer lift:** P1 Challenge semantics; stale Guided/Directive supersession; feeds P5 Challenge refuse/alternative paths.

**Rebuttal:**

- **Challenge:** proposed implement target MUST equal `.alternative`. Proposed target equal to challenged `.direction` → always refuse. **ACCEPT** (mission seam + JUDGMENT).
- **Guided / Directive / Override:** durable `.direction` is the bound scope. Optional CLI arg must match; omitted arg → use payload. **AMEND** Analyst's mandatory arg.
- Do not invent multi-direction menus inside the gate; selection already happened in Guided `select` / Challenge `alternative`.

---

### E6. Override non-waivers

| Verdict | **AMEND** (blocking semantics fix) |
|---------|------------------------------------|

**Pointer lift if amended:** P3 (and Override refuse/pass for P5).

**Rebuttal:** Analyst's `waivers` array that forbids listing non-waivable keys **inverts** the acceptance language and invites autonomy drift ("waiver channel exists"). JUDGMENT: Override documents unresolved concerns and **does not waive the contract**. §6.4 G3.2: durable file records non-empty risks **and** critic / evidence / frozen-contract **non-waivers**.

Required Build 2 behavior:

1. `override ''` / empty risks → non-zero; write nothing (G3.1).
2. Successful override archives non-empty `risks` + `critic_verdict` + `evidence` + `non_waivers.{critic,evidence,frozen_contract}=true`.
3. Any attempt to set a non-waiver false, or omit one → refuse (`non-waivable` / named field).
4. **REJECT** gate-enforced MEMORY.md / run-report writes (`recorded_in` may be advisory only). Constitution memory duty happens after real Override use, not as a pointer unlock.

---

### E7. Test plan (G1–G16 + harness ids)

| Verdict | **AMEND** to §6.4 pointer-shaped ids · keep Analyst scenarios as coverage map |
|---------|------------------------------------------------------------------------------|

**Pointer lift if amended:** P5 (and regressions for P1–P4).

**Rebuttal:** Owner audit G5.1 names eight check ids. Analyst's two umbrella ids + G1–G16 are useful internally but **do not satisfy** the verbatim pointer unless the eight ids exist and exercise real CLI (writers + implement + status), not hand-planted JSON alone.

| Required id (§6.4) | Maps from Analyst | Must prove |
|--------------------|-------------------|------------|
| `gate-guided-refuse` | G1 | Mode Guided; no selection; `implement` non-zero; names client |
| `gate-guided-pass` | G2 | Real `gate select` then `implement` → 0; durable `selection.json` |
| `gate-directive-refuse` | G3 | Mode Directive; no direction on disk; `implement` non-zero |
| `gate-directive-pass` | G4 | Durable direction (+ `risks` array, may be empty); `implement` → 0 |
| `gate-challenge-refuse` | G5/G6 | Missing alt/evidence **or** implement challenged path → non-zero |
| `gate-challenge-alternative` | G7 | Implement `.alternative` only → 0 |
| `gate-override-refuse` | G8/G9/G10 | Empty risks and/or missing/false non-waivers → non-zero |
| `gate-override-pass` | G11 | Full payload → 0; status JSON shows Override decision |

Extras G12–G16 (missing Mode, unknown mode, cross-mode writer refuse, status JSON, unknown verb) and help `grep -i gate` — **ACCEPT** as non-pointer smoke, not substitutes for the eight ids.

**AMEND** OFC note: `gate status` on existing Guided OFC may report no `judgment/` payload (`present:false`) and must exit 0 — Build 2 must not mutate client engagements to pass tests.

No mocks. No provider invocation. Template: `tests/workspace-smoke.sh` temp engagement + cleanup trap → `tests/judgment-gate-smoke.sh` (or harness-checks embedding the eight ids).

Docs: README Product Judgment table + ARCHITECTURE state-layout one row for `judgment/` — enough for operators; help alone is insufficient for discoverability beyond G1.1.

---

## Pointer-by-pointer decisions

### Pointer 1 — All four modes bind Implement per JUDGMENT

| Decision | **AMEND** then implement |
|----------|--------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E1 amended predicates; E3 `cmd_gate implement`; Challenge alternative-only; Guided selection required; Override after risks+non-waivers |
| Reject / cut | Mode-set-alone Directive pass without durable direction; defaulting missing Mode to Guided on implement |
| Risks | Over-encoding "silent scope expansion" as a gate scanner — refuse; keep human Critic for that |

### Pointer 2 — Required gates are durable files

| Decision | **ACCEPT** `judgment/*.json` · **AMEND** decision/ts visibility |
|----------|----------------------------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E2 schema; writers; status re-derives same decision from files alone (G2.1–G2.2) |
| Reject / cut | Chat-only decisions; harness-evolution-located gate state; editing `JUDGMENT.md` as runtime store |
| Risks | Orphan cross-mode files — mitigated by current-mode-only reads (E4) |

### Pointer 3 — Override risks + non-waivers

| Decision | **AMEND** schema to `non_waivers` |
|----------|----------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E6 corrected shape; G3.1 empty-risks refuse; G3.2 archive |
| Reject / cut | `waivers` inversion; MEMORY/run-report write as gate predicate |
| Risks | Product/autonomy drift if a waiver channel exists — eliminated by required-true non-waivers only |

### Pointer 4 — Machine status

| Decision | **ACCEPT** `consult gate <client> status` JSON |
|----------|-----------------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | JSON fields at least: `client`, `mode`, `decision` (`allowed`\|`refused` or equivalent), gate/payload state, `updated`/`ts` |
| Reject / cut | Reusing org `consult status` overview; text-only `judge show` as sufficiency |
| Risks | Status must not fail closed on legacy engagements lacking `judgment/` (report absent/refused, exit 0) |

### Pointer 5 — Per-mode refuse and pass paths

| Decision | **AMEND** check ids to §6.4 G5.1 set |
|----------|--------------------------------------|
| Expected lift | FAIL → **PASS** |
| Surviving work | E7 eight ids + real CLI paths; README/ARCHITECTURE `judgment/` mention |
| Reject / cut | Two umbrella ids as the only harness surface; JSON fixtures without invoking writers |
| Risks | Inflating to G1–G16 as blocking scope — extras are optional smoke |

---

## Product / autonomy semantics drift flags

1. **`waivers` vs non-waivers (blocking).** Analyst field invents a waiver list. Override must not expose a waivable-contract path. Fix: required `non_waivers` booleans only.
2. **Frozen product-judgment band claim.** Citing Build 2 as moving harness-apc-v1 scores toward 9–10 violates §6.2 / §0. Score only the five mission pointers; leave frozen contract untouched.
3. **Run-report / MEMORY enforcement inside writers.** JUDGMENT process duties ≠ Build 2 machine predicates. Drift toward org-process automation — cut.
4. **Challenge "implement alternative" vs pure refusal.** Mission seam explicitly requires a named safer alternative as the only Challenge implementable path — **not drift**; do not "fix" Challenge into refuse-only (that would fail `gate-challenge-alternative`).
5. **Build 4 pre-wiring.** Shipping a reusable read-only `implement` predicate is required by §6.1 later-consumer note. Wiring Builder/checks/score now would be Build 4 bleed — **refuse**.

---

## Cross-cutting risks

| Risk | Mitigation |
|------|------------|
| Second orchestrator / architecture inflation | One `lib/judgment-gate.sh`; Principal still owns the loop |
| Freeze violation | Touch only non-frozen harness code + `runs/iter-6/` artifacts; never contract/LOCK/FREEZE*/engagement.md/LOOP-SEQUENCE/authorize-merge/iter-0..5; do not amend Build 1 verdicts |
| Stale cross-mode authorization | Current-mode-only payload selection |
| Directive empty-risks confusion with Override | Distinct predicates (array allowed empty vs length>0) |
| Client engagement mutation in tests | Temp `gate-smoke-$$` engagements only; OFC status read-only |
| Scope bleed into Builds 3–4 | Explicit refuse list below |

---

## Refusal paths that must be tested

Automated (smoke and/or harness-checks), real commands, named messages:

1. **Guided refuse** — no `selection.json`; `gate implement` → non-zero; names client.
2. **Guided pass** — `gate select <direction>` then `implement` → 0; file on disk with `ts`+`direction`+`selected_by`.
3. **Directive refuse** — Mode Directive, no durable direction → non-zero.
4. **Directive pass** — durable direction archived; `risks:[]` allowed → 0.
5. **Challenge refuse** — implement challenged direction or missing alternative/evidence → non-zero.
6. **Challenge alternative pass** — implement `.alternative` → 0.
7. **Override empty-risks refuse** — no durable write.
8. **Override non-waiver refuse** — missing/false `non_waivers.*` → non-zero.
9. **Override pass** — full payload → 0; status JSON decision reflects Override allowed.
10. **Cross-mode writer refuse** — e.g. `select` under Directive → non-zero (extra, recommended).
11. **Help discoverability** — `consult help` matches `gate`.
12. **Keep existing wrong-path refusals** — OFC refuses provider run; agcode refuses checks (no regression).

---

## Final implementable scope (smallest corrected work list)

Build 2 ships **only** the following. Expected outcome: all five §6.1 pointers PASS under §6.4.

1. **Add `lib/judgment-gate.sh`** — `judgment_mode`, per-mode payload predicates (E1/E2 amended), read-only `judgment_gate` / status JSON; current-mode-only file selection; Challenge alternative binding; Override `non_waivers` required-true set; atomic writers helper (tmp+mv).
2. **Extend `bin/consult`** — `source` the lib; `cmd_gate` with `status|implement|select|direct|challenge|override`; help + dispatch beside `judge`; do not change `cmd_judge_set`; do not wire checks/score/bench.
3. **Durable files** — `state/engagements/<client>/judgment/{selection,directive,challenge,override}.json` per corrected schema; decision+mode+ts observable via `status`.
4. **Tests** — `tests/judgment-gate-smoke.sh` (or equivalent) driving the **eight** §6.4 G5.1 ids through real CLI; optional G12–G16 extras; extend consult-smoke help/status lightly.
5. **Docs** — README Judgment section + ARCHITECTURE state-layout `judgment/` row only.

**Explicitly out of Build 2:** Builds 3–4 surfaces; Builder invocation wiring; workspace-dirty coupling inside `gate implement`; MEMORY/run-report gate enforcement; `waivers` channel; editing `JUDGMENT.md` or frozen harness-apc-v1 files; re-scoring Build 1 or contract bands; daemon/DB/plugin/RAG/second CLI; product/client application code; provider invocation for probes.

**Owner escalation note:** New `lib/judgment-gate.sh` is an architecture seam addition under an owner-directed Build 2 (Directive). If implementers propose a daemon, DB, waiver API, or Build 4 Builder wiring now, Critic records **Challenge** and refuses.

---

## Survival summary

| Element | Verdict | Concrete pointer lift |
|---------|---------|------------------------|
| Mode predicates truth table | **AMEND** (Directive archive rule; Override field) | P1, P5 |
| `judgment/*.json` artifact shape | **ACCEPT** + **AMEND** Override `non_waivers` + decision/ts | P2, P3, P4 |
| CLI `gate` + writers | **ACCEPT** verbs · **AMEND** implement arity / Directive write path | P1–P4 |
| Stale/cross-mode behavior | **ACCEPT** current-mode-only · **REJECT** run-report gate | P1 safety |
| Exact-direction binding | **ACCEPT** · **AMEND** optional arg | P1 Challenge; stale guard |
| Override non-waivers | **AMEND** (blocking) | P3 |
| Test plan G1–G16 / harness ids | **AMEND** → eight §6.4 ids | P5 |
| Frozen score / MEMORY-as-gate / Build 4 wire | **REJECT** | none (anti-drift) |
| Builds 3–4 items | **REJECT** (not debated further) | n/a |

**Critic bottom line:** Implement the amended list — nothing larger. The Analyst handoff survives as a **corrected plain-file judgment gate** (read-only implement predicate + durable per-mode JSON + machine status), not as a waiver-shaped Override artifact, not as umbrella check theater, and not as a foothold for Builds 3–4 or frozen-contract re-scoring.
