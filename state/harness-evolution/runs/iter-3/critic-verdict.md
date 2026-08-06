# Critic verdict — harness-apc-v1 Iter-3

**Role:** Critic (adversarial)  
**Against:** Principal Iter-3 report + shipped skills seam  
**Contract:** `harness-apc-v1` (frozen)  
**Scores:** `runs/iter-3/scores.json` **absent** — bias re-audit deferred

---

## Verdict: **ACCEPT-WITH-NITS**

Iter-3 shipped exactly the Critic-narrowed trio: three SKILL.md files,
`lib/run-skill.sh`, `consult skill`, docs pointer, smoke + harness-checks
invocation coverage, and real artifacts under `runs/iter-3/evidence/skill-*`.
Freeze intact. No fourth skill, no `evolve`, no authorize weakening, no
lock edits.

**Honesty gate:** the runnable skills are **scaffolding** — they fill
structured markdown from a depth-2 `find` tree and a README head excerpt.
They are not LLM-backed product audits, not client-specific judgment, and
not frozen engagement contracts tailored by evidence. Lessons.md already
admits this; the Principal report’s expected lift (`product-skills` → ≥8.0)
must be scored against the **contract band text** (exist / invoke /
artifacts / docs / smoke-or-check), not against “deep product consulting.”
That distinction is the main nit. It does not void the iteration.

---

## 1. Mandatory safety / freeze

| Check | Result | Evidence |
|-------|--------|----------|
| Lock freeze | **PASS** | `evidence/lock-hashes-pre.txt` SHA256 matches live `HARNESS-BENCHMARK-CONTRACT.md`, `contract.json`, `LOCK.md`. Suite `lock-hashes-stable` PASS. |
| No `--admin` / authorize weakening | **PASS** | Skills iter did not touch `lib/github.sh` merge path. Authorize file still absent (correct). |
| Secrets | **PASS** | `secrets-scan` PASS in `checks.json`; skill artifacts are tree/README text. |
| No self-scoring | **PASS so far** | Principal did not write `scores.json`. Evaluator only. |
| Scope vs Critic Iter-2 cut | **Met** | Three skills only + minimal `consult skill` wiring. |

Critical-failure magnets (force-merge, mock PR, lock edit, Principal-authored scores): not observed in this iter’s claimed surface.

---

## 2. Diff review

### `skills/{critique,benchmark,design-sprint}/SKILL.md`

Thin but real entry docs: purpose, covers/produces, invoke command, rules.
Discoverable via `docs/skills.md` + README help listing. **Not** stubs with
no runnable entry — `consult skill` is the entry.

### `lib/run-skill.sh` + `consult skill`

- Allowlist: `critique | benchmark | design-sprint` only — correct hard cut.
- Resolves path / engagement / `harness-evolution` / sibling under projects.
- Copies SKILL.md into out-dir; writes named artifacts; prints path.
- Checks exercise each skill against harness-evolution and archive under
  `runs/iter-3/evidence/skill-*`. Suite 19/19 in `checks.json`.

**Scaffolding call-out (blocking for overclaim, not for ACCEPT):**

| Skill | What it actually does | What it is not |
|-------|----------------------|----------------|
| `/critique` | Template sections + tree + README excerpt; prioritized recommendations are placeholders (“Fill from evidence…”) | An evidence-backed product audit with ranked findings |
| `/benchmark` | Generic six-dimension draft contract + `contract.json` stamped “FROZEN draft” | A tailored, engagement-ready freeze derived from client inspection |
| `/design-sprint` | Framed plan skeleton + tree dump | A scoped improvement plan with concrete in/out lists |

Contract `product-skills` 9–10 text is met *literally* (all three artifacts,
docs pointer, smoke/check invocation). Do **not** narrate that as deep
skill quality. Upper-band scores are about operability of entrypoints, not
consulting depth.

**Nits (non-blocking):**

1. Hardcoded sibling root `/home/logani/projects/$TARGET` — machine-local;
   fine for this owner harness, fragile elsewhere.
2. Harness skill-run checks hardcode `runs/iter-3/evidence/skill-*` out-dirs
   — couples the objective suite to Iter-3 paths; later iters will overwrite
   or need retargeting. Prefer a tmp/out under `runs/skills/` or `$RUN_DIR`.
3. Critique SKILL.md mentions “optional JSON summary”; runner never writes
   JSON for critique — doc drift.
4. `benchmark` stamps “FROZEN draft” while also saying implementers must not
   amend — scaffolding honesty is good; do not treat these drafts as the
   harness-apc freeze (that freeze is untouched lock files).

### Checks / smoke / docs

| Surface | Assessment |
|---------|------------|
| `skills-present` | Presence only — thin, correct as gate. |
| `skill-*-runs` | Real `bin/consult skill …` + artifact file exists — stronger than presence. |
| Smoke | Lists `consult skill` + three SKILL.md files. |
| `docs/skills.md` | Minimal table — enough for contract doc pointer. |

Suite remains objective/thin for band claims; correct as suite, not scorer.

---

## 3. Scope vs Critic-accepted Iter-3 list

| # | Accepted / expected | Status |
|---|---------------------|--------|
| 1 | `/critique` SKILL.md + artifact | **Met** (scaffold artifact) |
| 2 | `/benchmark` SKILL.md + artifact | **Met** (scaffold artifact) |
| 3 | `/design-sprint` SKILL.md + artifact | **Met** (scaffold artifact) |
| 4 | Minimal `consult skill` (no extra verbs) | **Met** |
| 5 | No lock / contract / LOCK.md edits | **Met** |
| 6 | No auto-merge / `--admin` / authorize weaken | **Met** |
| 7 | No fourth skill / evolve / multi-runtime matrix / org role changes | **Met** |
| 8 | Do not merge PR #1 without authorize-merge | **Met** (authorize file still absent) |

**Report nit:** Expected lift line is fine as a hypothesis; Independent
Evaluator must cite paths and may score 6–8 if treating scaffolding as
“usable with gaps,” or 9–10 if applying the contract’s literal operability
bands. Critic prefers **conservative resolution** on depth: if disputed,
lower score wins until provider-backed or evidence-filled runs exist.
Contract text itself supports high band on existence+invocation — Evaluator
should say so explicitly if scoring ≥9.

---

## 4. Org review

- No new permanent worker. No plugin layer. No rival runtime module.
- One CLI verb `consult skill` with three allowlisted names — within
  Critic allowance; do not grow a skill-orchestration permanence layer.
- Skills live as first-party tree + thin runner — justified seam; do **not**
  deepen via provider in Iter-4 unless Independent scores show
  `product-skills` still &lt; 8.0 after honest band application.
- Loop still Principal-driven; skills are tools, not a fifth role.

---

## 5. Formal verdict

### **ACCEPT-WITH-NITS**

Iteration valid to proceed to Independent scoring and close **after**:

1. Evaluator (not Principal) writes `runs/iter-3/scores.json` with
   path-cited evidence.  
2. Score `product-skills` against contract bands; **state in evidence that
   artifacts are tree/README scaffolds**, not deep audits.  
3. Do not claim skill depth, LLM critique, or client-tailored freeze.  
4. Keep lock files untouched; do not merge PR #1 without owner
   `authorize-merge` (never `--admin`).

Nits that do not block ACCEPT-WITH-NITS:

- Retarget skill-run checks off hard-coded `iter-3/evidence` paths when
  convenient (Iter-4 only if it blocks suite honesty).  
- Drop or implement critique “optional JSON” claim.  
- Prefer non-machine-local target resolution later — not Iter-4 scope.

---

## 6. Recommended Iter-4 scope — **close the GitHub / autonomy evidence**

Do **not** deepen skills unless Independent scoring shows `product-skills`
still below **8.0** after literal contract application.

Ship only:

1. **Authorize-merge** — owner places `state/harness-evolution/authorize-merge`
   when ready; harness merge path stays non-admin.  
2. **Merge harness PR #1** — only if CI/checks green; record merge SHA /
   evidence under `runs/iter-4/evidence/`.  
3. **Post-merge validate** — `consult gh validate` (or harness-checks archive)
   as the validation artifact.  
4. **Close autonomy-loop evidence** — phase artifacts + lessons + MEMORY
   pointer for the converging iter; no new loop orchestrator verb unless
   scores prove autonomy-loop &lt; 8.0 and Critic re-opens that cut.

**Hard cuts for Iter-4:**

- No lock / contract / LOCK.md edits.  
- No skill deepening, fourth skill, `evolve`, or provider_ask wiring by
  default.  
- No `--admin`, no force-merge, no authorize-file weakening.  
- No org role changes.

**Expected lift:** `github-integration` toward authorized merge + validate;
`autonomy-loop` / convergence checklist closure; `safety-discipline` if
gates stay clean.  
**Void magnets:** merge without authorize; `--admin`; lock drift; Principal
self-scoring; claiming skill depth that Iter-3 did not ship.

---

## Scores note

`runs/iter-3/scores.json` **does not exist** at verdict time.  
**Bias re-audit: pending.** This verdict covers diff, scaffolding honesty,
freeze, scope, checks, and org only.

When scores land, reject any narrative that equates scaffold templates with
deep `/critique` product judgment; accept high `product-skills` only if
evidence cites invocable entrypoints + artifacts + docs/smoke per contract.
