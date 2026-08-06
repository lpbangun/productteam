# Critic verdict — harness-apc-v1 Iter-1

**Role:** Critic (adversarial)  
**Against:** Principal Iter-1 report + shipped diff (no implementation by Critic)  
**Contract:** `harness-apc-v1` (frozen)  
**Scores:** `runs/iter-1/scores.json` **absent** — bias re-audit deferred

---

## Verdict: **ACCEPT-WITH-NITS**

Iter-1 largely shipped the Critic-accepted four deliverables and stayed
inside the explicit out-of-scope list. Evidence spine exists
(`checks.json`, smoke/runtime/lock-hash artifacts, `lessons.md`,
`report.md`). Residual nits are real but not void-worthy if Iter-2 stays
narrow and Independent scoring remains out of Principal hands.

---

## 1. Diff review

### Scope creep

**Low–medium, mostly controlled.**

| Claimed / shipped | Creep? |
|-------------------|--------|
| Extend `lib/provider.sh` (no `lib/runtime.sh`) | No — respected |
| `lib/harness-checks.sh` + `consult harness-checks` | No — accepted item 2; new verb is the harness surface, not a rival product |
| `consult runtime` | Borderline — Critic asked for status/runtime *line*; a dedicated verb is slightly more surface than “line,” but it is detection + honest `--check`, not a parallel control plane |
| `docs/learning-schema.md` + run layout | No — accepted item 3; **no** `consult learn` |
| Mode on `engagement.md` + Challenge/Override examples | No — accepted item 4 |
| README / ARCHITECTURE updates | No — tax on shipped surface; no vapor (`evolve`/`learn` absent) |
| `LOOP-SEQUENCE.md` | Extra file vs the four-item list, but it is the *documented fixed sequence* Critic required when cutting `consult evolve` — **justified substitute**, not architecture inflation |

**Working-tree contamination (not in report, still a Critic flag):**  
`state/engagements/agcode-learning/runs/iter-4..9/`, agcode `history.jsonl`, and OFC `.checks-latest.json` sit dirty alongside Iter-1. They must **not** be attributed to harness-apc Iter-1 or baked into harness evidence. If committed with this iter, that is scope creep / noise.

**Explicitly out — and correctly absent:** `consult evolve`, `consult learn`, multi-runtime adapter matrix, `consult pr|merge|validate`, skill packs, rival `lib/runtime.sh`.

### Churn

- Core harness delta is small and purposeful (`provider.sh`, `bin/consult`, new `harness-checks.sh`, smoke, docs).
- Smoke change that removes hanging provider invoke on OFC `bench … run` is deletion of bad behavior — keep.
- Docs churn is proportional to shipped verbs.

### Correctness

**Mostly sound; several honesty gaps remain.**

1. **Runtime detection + refusal:** `runtime_detect` / `runtime_default` / `consult runtime --check` with missing provider refuse by name. Evidence: `evidence/runtime.txt`, smoke PASS on refusal. Good for ≤5→6+ band entry.
2. **Alternate path not exercised:** Non-`agent` branch still invokes `"$bin" -p "$prompt" --output-format text`. That is **not** proof claude|codex|opencode|gemini accept those flags. Critic’s Iter-0 warning stands: detection ≠ proven routing. Do not overclaim “routing” at score time.
3. **Lock freeze:** Pre/post SHA256 for contract + LOCK match current files (`evidence/lock-hashes-*.txt`). Freeze intact. **Gap:** harness check `lock-files-present` only tests *existence*, not hash equality — weaker than the evidence already collected by hand.
4. **Harness checks vs OFC:** Separate suite; does not call `run-checks.sh`. Good. Suite is heavily *presence* checks (schema file, example files, Mode grep) — objective but thin; still within Critic’s “minimal objective subset.”
5. **Secrets scan:** High-signal patterns over `runs/` + `MEMORY.md`; iter-1 artifacts clean on spot check. Not a secret-manager product — correct scope.
6. **Self-scoring channel:** `checks.json` records objective suite results with `"validation":"real-commands"`. It does **not** author dimension scores. Correct separation — so far.

---

## 2. Critic-accepted Iter-1 scope — respected?

| # | Accepted deliverable | Status |
|---|----------------------|--------|
| 1 | Provider-seam runtime detect + honest failure + alternate documented | **Met** (seam extended; ARCHITECTURE documents swap; check id `runtime-detect`) |
| 2 | Harness-level checks + archive to `runs/iter-N/` + secrets scan | **Met** (`checks.json` 11/11; secrets included) |
| 3 | Learning / run continuity without new verb | **Met** (schema + `history.jsonl` + `lessons.md`; no `consult learn`) |
| 4 | Judgment binding (mode + Challenge **or** Override example) | **Met** (Mode: Directive; both Challenge *and* Override examples) |

**Docs-only-for-accepted-surface:** Met.  
**Out-of-scope cuts:** Met.

**Partial nits vs accepted wording:**

- “Status/runtime line” → shipped as `consult runtime` (+ status provider line). Acceptable narrowing outcome, not a reopen.
- “MEMORY.md hook after first closed iter” — **not done** for this APC iter (MEMORY still OFC/agcode-centric). Tolerable while scores pending / iter not fully closed; **required before calling Iter-1 closed**.
- “Wire into status/judge if needed” — Mode lives on `state/harness-evolution/engagement.md`, but `consult judge harness-evolution` fails (engagement not under `state/engagements/`). Judgment is file-bound, not CLI-bound. Nit, not reject.

---

## 3. Safety

| Gate | Finding |
|------|---------|
| Secrets in artifacts | No matches in iter-1 run dir; suite includes `secrets-scan` PASS |
| Lock / freeze intact | Hashes unchanged vs pre/post evidence; LOCK.md freeze rule unbroken |
| No self-scoring | **scores.json pending** — Principal has not written dimension scores. Critic records: Evaluator alone may author `scores.json`. Harness checks must never become a surrogate scorer |
| Force-merge / admin / mock PR | Not introduced (correctly deferred) |
| Client check honesty | OFC path untouched by harness suite |

**Scores pending:** Bias re-audit of Iter-1 scores **cannot** run yet. When `scores.json` lands, Critic must re-open: reject lifts claimed for github-integration / product-skills / full alternate-runtime exercise; demand path-cited evidence; flag any score that cites only `checks.json` presence lines as if they were dimensional excellence.

---

## 4. Org review

**No new unjustified permanent worker or plugin layer.**

- Four roles unchanged.
- `lib/harness-checks.sh` is a justified seam (harness vs client checks) — Critic-survived.
- Runtime stays inside `provider.sh` — architecture escalation avoided.
- `LOOP-SEQUENCE.md` documents Principal-driven loop instead of a second orchestrator — preferred shape.
- Two new CLI verbs increase surface; both map to accepted deliverables. Watch Iter-2: do **not** add three peer `pr`/`merge`/`validate` verbs.

**Org friction noted:** harness-evolution is a parallel engagement tree (`state/harness-evolution/`) outside `consult judge`/`bench` client paths. Fine for now; do not invent a fifth permanent “Harness Manager” role to paper over it.

---

## 5. Formal verdict

### **ACCEPT-WITH-NITS**

Iteration is valid to proceed to Independent scoring and close **after**:

1. Evaluator writes `scores.json` (Principal does not).  
2. MEMORY.md gets a short, dated, path-linked APC Iter-1 lesson (schema contract).  
3. Critic (or same session after scores) re-audits scores for bias.  
4. Unrelated agcode/OFC dirty paths stay out of the harness-evolution narrative and any Iter-1 commit set.

Nits that do **not** block ACCEPT-WITH-NITS but must not be ignored at scoring:

- Lock check should eventually assert hashes, not only presence.  
- Do not score runtime-routing as if multi-CLI invoke were proven.  
- Presence-only judgment/schema checks are weak evidence for high bands.

---

## 6. Recommended Iter-2 scope (narrowed GitHub workflow)

**One gated workflow — not three peer verbs.**

Ship the smallest thing that can produce real checklist evidence:

1. **Single entry** (prefer `consult pr` with subcommands *or* one documented script under `bin/`/`lib/` — pick one shape):  
   - `create` → real `gh pr create`, archive URL to `runs/iter-N/pr.json` (no mock URLs)  
   - `status`/`checks` → view CI  
   - `merge` → **only** if `state/harness-evolution/authorize-merge` exists; **ban `--admin` / force**; record merge SHA or recorded denial  
   - `validate` → post-merge re-check artifact  
2. **Dry-run / smoke path** that exercises refusals (no authorize file → refuse merge) without requiring a live merge in every smoke run.  
3. **Owner escalation note** on authorize-file convention (Constitution: security/auth).  
4. **Do not** ship skills, `evolve`, or further runtime adapters in Iter-2.

**Expected lift:** `github-integration` toward 6.5–8.0; `safety-discipline` +1 if authorize + anti-force are real.  
**Critical-failure magnets:** fake PR URLs, force-merge, secrets in PR bodies — void the iter.

---

## Scores note

`runs/iter-1/scores.json` **does not exist** at verdict time.  
**Bias re-audit: pending.** This verdict covers diff, scope, safety, and org only.
