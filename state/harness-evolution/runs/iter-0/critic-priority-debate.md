# Critic priority debate — Iter 1–5 work list

**Role:** Critic (adversarial)  
**Contract:** `harness-apc-v1` (frozen) · target every dim ≥ 8.0 in ≤5 improvement iters  
**Against:** Principal’s proposed Iter 1–5 work list  
**Stance:** Argue against weak priorities. Do not implement.  
**Constitution lenses:** delete before adding; escalate architecture; prefer seams over plugins.

---

## Overall verdict

**Reject Iter 1 as proposed.** It packs five deliverables claiming lifts on six dimensions, introduces at least three new CLI verbs (`runtime`, `learn`, `evolve`), and a parallel `lib/runtime.sh` beside the existing provider seam. That is architecture inflation before baseline scores exist (iter-0 has preflight only — no `scores.json` yet). Convergence is per-dimension ≥8.0 with a real PR + gated merge on the checklist; front-loading ceremony does not buy github-integration or product-skills, and it risks an architecture-simplicity *drop*.

**Plan shape is also wrong:** Iter 5 as “whatever is still below 8.0” is not a work item — it is an admission that Iters 1–4 were not sequenced to the bottleneck dimensions. Judgment wiring and secrets gating are cheap and should not wait until Iter 4 / ride only on Iter 2.

---

## Item-by-item

### 1. `lib/runtime.sh` + `consult runtime` (multi-runtime detect + route)

| Verdict | **NARROW** (then SURVIVE as narrowed) |
|---------|----------------------------------------|

**Expected lift (narrowed):** `runtime-routing` ~≤5 → **6.5–7.5** (+1.5–2.5). Secondary: tiny `cli-onboarding` / `testing-evidence` if smoke includes `runtime-detect`.

**Rebuttal:** ARCHITECTURE.md already defines one provider seam (`lib/provider.sh` + `CONSULT_PROVIDER`). A second module + dedicated command is a parallel control plane unless it *is* the seam. Contract band 6–8 needs detection *or* an explicit routing table, one alternate path documented, and honest failures — not five-runtime feature parity (agent/claude/codex/opencode/gemini). Preflight already lists which binaries exist; detection should surface that through the existing seam, not invent a plugin router.

**Scope creep / critical-failure risk:** High architecture creep; Constitution escalates architecture changes. Over-claiming “routing” without an exercised alternate path invites void evidence later. Silent wrong-flag invocation across CLIs → opaque failures (≤5 band).

**Narrow to:** Extend `lib/provider.sh` (or a thin helper *sourced by* it — not a rival layer): detect available runtimes, print `consult status`/`runtime` line, refuse with named missing binary, document one alternate (`CONSULT_PROVIDER=…`). Smoke or check id `runtime-detect`. **No** multi-adapter matrix in Iter 1.

---

### 2. Learning schema + `consult learn` / run layout helpers

| Verdict | **NARROW** |
|---------|------------|

**Expected lift (narrowed):** `memory-learning` ≤5 → **6.5–8.0** (+1.5–3). Enables evidence for later iters (`lessons.md`, `history.jsonl`).

**Rebuttal:** Schema + required run-dir layout (already normative in the contract) is high leverage. A new `consult learn` verb is low leverage — learning is writing `lessons.md` / appending `history.jsonl` / updating `MEMORY.md`. Another command to document and smoke-test burns Iter-1 budget without unique score evidence beyond what file layout already provides.

**Scope creep risk:** Medium — “helpers” become a mini CMS for runs. Keep markdown/jsonl; avoid validation frameworks.

**Narrow to:** Document/implement schema + `history.jsonl` + per-iter `lessons.md` (and ensure layout matches contract). Optional tiny shell helpers used by checks — **no** `consult learn` unless help text would otherwise lie.

---

### 3. Harness-level checks script (not OFC-specific) + archive to `runs/`

| Verdict | **SURVIVE** |
|---------|-------------|

**Expected lift:** `testing-evidence` ≤5 → **7.0–8.5** (+2–3.5); supports `runtime-routing`, `cli-onboarding`, later dims via mapped check ids. Secondary: `safety-discipline` if freeze/secrets checks included.

**Rebuttal:** Strongest Iter-1 item. Today `lib/run-checks.sh` is OFC-bound; harness claims cannot be evidenced without a separate runner. Must stay **out of** the client OFC path (critical failure: fake/mocked validation / dishonest client checks).

**Scope creep risk:** Medium — mapping “all objective contract items” can become a second full scorer. Iter 1 should map a **minimal objective subset** (smoke green, runtime-detect, lock files unchanged, run-dir presence, no secrets grep) and archive under `state/harness-evolution/runs/iter-N/`. Subjective dims stay evaluator-scored.

**Do not** fold OFC checks into harness checks or vice versa.

---

### 4. Minimal loop runner `consult evolve` (phase checklist)

| Verdict | **CUT** from Iter 1 · **NARROW** if revived later |
|---------|-----------------------------------------------------|

**Expected lift if cut from Iter 1:** none lost if Principal instead records phase artifacts manually under a **documented fixed sequence** (autonomy-loop 6–8 explicitly allows that). Premature `consult evolve` claims `autonomy-loop` +2–3 while mostly printing checklists → paper lift, architecture-simplicity −0.5 to −1.5.

**Rebuttal:** AGENTS.md already defines the loop. A CLI that “records a phase checklist” without driving Inspect→…→Org-improve is ceremony. A CLI that *does* drive workers is an architecture change and a second control plane next to the Principal session. Band 6–8 needs an executable documented sequence + ≥1 full iter with phase artifacts — achievable without a new verb.

**Scope creep / CF risk:** High. Name `evolve` invites autonomy-policy escalation. Fake phase ticks without real debate/scores → critical failure (fake validation / missing Critic).

**If revived (Iter 3+):** thin recorder that writes phase timestamps into the run report — not an agent orchestrator. Prefer documenting `bin/consult` sequence over new command until ≥2 full harness-evolution iters prove friction.

---

### 5. README / ARCHITECTURE / help updates for new commands

| Verdict | **NARROW** · **REORDER** last within Iter 1 |
|---------|-----------------------------------------------|

**Expected lift:** `cli-onboarding` +0.5–1.5 **only for commands that actually ship**; can **hurt** architecture-simplicity / cli-onboarding if docs advertise vapor (`evolve`, `learn`, five runtimes).

**Rebuttal:** Docs are not a peer product deliverable — they are the tax on accepted surface area. Listing this as item 5 encourages inventing commands so README has something to say.

**Narrow to:** Update help/README/ARCHITECTURE **only** for the 3–4 accepted Iter-1 deliverables; delete stale claims. Cold-path note in run evidence.

---

### 6. `consult pr` / `consult merge` / `consult validate` (gh wrappers + gates)

| Verdict | **SURVIVE** for Iter 2 · **NARROW** |
|---------|-------------------------------------|

**Expected lift (narrowed):** `github-integration` ≤5 → **6.5–8.0** (+1.5–3); `safety-discipline` +1–2. **Required** for convergence checklist (real PR URL, authorized merge or recorded denial, post-merge validate).

**Rebuttal:** Three new verbs before one end-to-end dry-run is bloat. Contract evidence allows harness subcommands **or** documented `gh` workflow wrappers. Prefer one gated workflow (`consult pr` lifecycle with subcommands, or documented script) over three peer commands. **Must** ban `--admin`, require authorize file, refuse force-push — but over-automation that auto-merges is a CF magnet.

**Scope creep / CF risk:** **Critical.** Fake PR URLs, force-merge, secrets in PR bodies → void iteration. Narrow: create + view/checks + merge-only-with-authorize-file + validate artifact; dry-run mode for smoke; no admin bypass; no mock URLs.

**Escalate:** security/auth aspects of merge gating per Constitution — record owner acknowledgment of authorize-file convention.

---

### 7. Secrets scan gate on `state/` artifacts

| Verdict | **SURVIVE** · **REORDER** into Iter 1 (or same PR as harness checks) |
|---------|----------------------------------------------------------------------|

**Expected lift:** `safety-discipline` +1–2; prevents CF #1 (secrets in artifacts). Cheap.

**Rebuttal:** Waiting until Iter 2 while Iter 1 writes run artifacts is negligent. Fold a deterministic secrets grep into the harness checks suite (item 3). Standalone “gate product” unnecessary.

**CF risk if skipped early:** High (void on leak). Implementation risk: low if scoped to high-signal patterns (not a general secret-manager product).

---

### 8. First-party skills (`critique`, `benchmark`, `design-sprint`) + `consult skill`

| Verdict | **SURVIVE** for Iter 3 · **NARROW** |
|---------|-------------------------------------|

**Expected lift:** `product-skills` ≤5 → **6.5–8.0** (+1.5–3). Docs pointer → small `cli-onboarding` lift.

**Rebuttal:** Correct sequencing (after evidence/runtime/gh spine). Wrong shape if this becomes a skill *platform*. Contract 6–8: three skill files exist; ≥2 leave artifacts. Prefer `skills/<name>/SKILL.md` + thin `consult skill <name>` that runs the skill via provider seam and writes under `runs/iter-N/` — **no** plugin registry, no skill marketplace.

**Scope creep risk:** High if “design-sprint” balloons into multi-day workshop engine. Cap: each skill produces one named artifact file; smoke checks presence + one invocation path.

---

### 9. Smoke coverage for skill presence

| Verdict | **NARROW** — fold into item 8 / testing-evidence; not a standalone iter item |
|---------|-----------------------------------------------------------------------------|

**Expected lift:** absorbed into `product-skills` / `testing-evidence` (+0.5). Zero alone.

**Rebuttal:** Padding the work list. Smoke lines are part of shipping skills, not Iter-3 theater.

---

### 10. Wire judgment mode into harness-evolution + Challenge/Override example

| Verdict | **SURVIVE** · **REORDER** earlier (Iter 1 or 2) |
|---------|--------------------------------------------------|

**Expected lift:** `product-judgment` ≤5 → **6.5–8.0** (+1.5–3). Cheap if `consult judge` already exists for engagements.

**Rebuttal:** Principal parked this in Iter 4 while Iter 1 invents `evolve`. Judgment is already a seam (`JUDGMENT.md`, `consult judge`). Harness-evolution needs a mode field + one Challenge or Override example artifact — not a new subsystem. Doing this late wastes easy points and leaves autonomy-loop reports unbound.

**Scope creep risk:** Low if limited to engagement/harness-evolution mode record + one example artifact. High if redefining modes.

---

### 11. Ensure smoke + checks cover runtime, skills, gh dry-run

| Verdict | **CUT** as a numbered work item · **SURVIVE** as standing Definition of Done |
|---------|------------------------------------------------------------------------------|

**Expected lift:** none as a separate iter — it is the verification clause of items 1, 6, 8.

**Rebuttal:** Meta-work masquerading as a deliverable. Each surviving item must attach verification when built; Iter 4 should not be a cleanup tax for skipped evidence.

---

### 12. “Whatever Critic/evaluator still flags below 8.0”

| Verdict | **CUT** |
|---------|---------|

**Expected lift:** Unspecified → planning failure. Wastes the fifth iteration’s only remaining degrees of freedom.

**Rebuttal:** Residuals must be **predicted** after Iter 0 baseline scores. Likely late bottlenecks: `github-integration` (real PR+merge evidence), `product-skills` artifacts, `autonomy-loop` stop conditions, `architecture-simplicity` if Iter 1 bloated. Iter 5 should be pre-allocated to the highest residual after Iter 0 scoring — not a blank check.

---

## Cross-cutting risks

| Risk | Why it matters |
|------|----------------|
| Architecture escalation without owner | New `runtime.sh` + `evolve` + `learn` + `skill` ≈ plugin surface; Constitution says escalate |
| Dimension starvation | Iter 1 ignores github + skills; checklist needs real PR before convergence |
| Paper autonomy | Checklist CLI without Critic/scores/diff → CF #4/#6 |
| Self-scoring temptation | Harness checks must not author `scores.json`; evaluator remains independent |
| Iter-1 “six dimension” fantasy | Realistic Iter-1 lifts: testing-evidence, runtime-routing, memory-learning (partial), safety (secrets), maybe judgment — **not** autonomy-loop 8 or architecture + |

---

## Accepted Iter-1 scope (max 4 deliverables)

Maximize expected lift toward ≥8.0 **without** architecture bloat:

1. **Provider-seam runtime detection + honest failure**  
   Extend existing `lib/provider.sh` (no rival `lib/runtime.sh` control plane). Status/runtime line + documented alternate + check/`runtime-detect`.  
   → `runtime-routing` toward 6.5–7.5; architecture-neutral or + if docs match.

2. **Harness-level checks runner (non-OFC) + archive to `runs/iter-N/`**  
   Minimal objective map: smoke, runtime-detect, lock-file freeze proof, run-dir required files, **secrets scan on `state/harness-evolution/`**.  
   → `testing-evidence` toward 7–8.5; `safety-discipline` +1+.

3. **Learning / run continuity without a new verb**  
   Schema note + `history.jsonl` + `lessons.md` template/layout for harness-evolution; MEMORY.md hook after first closed iter.  
   → `memory-learning` toward 6.5–8. **No** `consult learn`.

4. **Judgment binding for harness-evolution (cheap)**  
   Mode field on harness-evolution engagement (or equivalent) + Challenge **or** Override example artifact path. Wire into status/judge if needed.  
   → `product-judgment` toward 6.5–8.

**Explicitly out of Iter 1:** `consult evolve`, `consult learn`, multi-runtime adapter matrix, `consult pr|merge|validate`, skill packs, README-as-primary (docs only for the four above).

**Owner escalation note:** Treat any new top-level `lib/runtime.sh` *or* loop orchestrator as architecture — escalate before build; Critic recommends **refusal** in favor of provider-seam extension.

---

## Suggested reorder (Iters 2–5) after this cut

| Iter | Focus | Why |
|------|--------|-----|
| **2** | Gated gh PR → review/checks → authorize-merge → validate (narrow wrappers); dry-run in smoke | Unblocks checklist; pairs with safety |
| **3** | Three first-party skills + artifacts + smoke; optional thin phase-recorder if autonomy-loop still &lt;8 | Skills are a whole dim; loop only if docs+artifacts insufficient |
| **4** | Close evidence gaps: smoke/gh dry-run/skills coverage; architecture deletion pass; real PR if not done | Verification + simplification |
| **5** | Pre-declared residual chase from post-Iter-0 / mid-run scores — **not** “whatever” | Preserve last iter for true bottlenecks |

---

## Survival summary

| # | Item | Verdict | Rough lift |
|---|------|---------|------------|
| 1 | runtime.sh + consult runtime | **NARROW** → provider-seam detect | runtime-routing +1.5–2.5 |
| 2 | learn schema + consult learn | **NARROW** → schema/layout, no verb | memory-learning +1.5–3 |
| 3 | harness checks | **SURVIVE** | testing-evidence +2–3.5; safety + |
| 4 | consult evolve | **CUT** (Iter 1) | avoid false autonomy / arch hit |
| 5 | README/help/ARCH | **NARROW** / last | cli-onboarding +0.5–1.5 if honest |
| 6 | pr/merge/validate | **SURVIVE** Iter 2, **NARROW** | github +1.5–3; safety +; CF risk high |
| 7 | secrets scan | **SURVIVE**, **REORDER** → Iter 1 w/ checks | safety +1–2; CF prevention |
| 8 | skills + consult skill | **SURVIVE** Iter 3, **NARROW** | product-skills +1.5–3 |
| 9 | skill smoke | **NARROW** → fold into 8 | absorbed |
| 10 | judgment wire | **SURVIVE**, **REORDER** → Iter 1–2 | product-judgment +1.5–3 |
| 11 | ensure coverage | **CUT** as item / DoD instead | — |
| 12 | residual filler | **CUT** | replace with scored residual plan |

**Critic bottom line:** Iter 1 should ship **evidence spine + seam honesty + judgment bind**, not a new product surface. If the Principal insists on `consult evolve` and `lib/runtime.sh` in Iter 1, Critic records **overruled risk**: architecture-simplicity regression and ≤5 autonomy-loop paper score — escalate to owner before implement.
)
