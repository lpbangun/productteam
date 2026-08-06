# Critic verdict — harness-apc-v1 Iter-2

**Role:** Critic (adversarial)  
**Against:** Principal Iter-2 report + shipped GitHub seam + PR #1  
**Contract:** `harness-apc-v1` (frozen)  
**PR:** https://github.com/lpbangun/product-consulting-harness/pull/1  
**Scores:** `runs/iter-2/scores.json` **absent** — bias re-audit deferred

---

## Verdict: **ACCEPT-WITH-NITS**

Iter-2 shipped the Critic-narrowed gated GitHub workflow. Merge path has
**no `--admin`**. Authorize-file gate refuses without authorization.
Lock hashes unchanged. Real PR evidence exists. Residual nits (evidence
packaging, authorize quality, working-tree skills preview, pending
scores) do not void the iteration if Iter-3 stays at **three skills only**
and Independent scoring stays out of Principal hands.

---

## 1. Mandatory safety checks

| Check | Result | Evidence |
|-------|--------|----------|
| No `--admin` in merge path | **PASS** | `lib/github.sh` `gh_pr_merge`: `args=(pr merge --merge)` only; `_gh "${args[@]}"`. No admin/force flags constructed. |
| Authorize gate | **PASS** | Missing `CONSULT_AUTHORIZE_MERGE` / authorize file → exit 2 + “merge refused”. Live probe confirmed. Auth file containing `--admin` / force language also refused. |
| Freeze intact | **PASS** | `lock-hashes-pre.txt` SHA256 matches current `HARNESS-BENCHMARK-CONTRACT.md`, `contract.json`, `LOCK.md`. Check `lock-hashes-stable` PASS in `checks.json`. |
| Scope creep (claimed Iter-2) | **LOW** | Single `consult gh …` verb with subcommands — matches Critic Iter-1 recommendation. Skills deferred in report. |

**Critical-failure magnets (force-merge, mock PR URL, secrets in PR body):** not observed.
PR URL is real (`pull/1`); preflight redacts token; `secrets-scan` PASS.

---

## 2. Diff review

### `lib/github.sh`

Sound, small, gated.

- Surface: `preflight` / `pr-create` / `status` / `checks` / `merge` / `validate`.
- Merge refuses when authorize path empty or file missing; rejects authorize text that asks for `--admin`, force-merge, force push, or bypass checks.
- Push is ordinary `git push -u` (not `--force`).
- Preflight redacts token lines.

**Nits (non-blocking):**

1. Authorize gate is **presence + ban-list**, not a required owner signature/note schema. A empty-ish file authorizes merge — weaker than “explicit owner authorization note” prose implies.
2. Merge does **not** require green checks / mergeable state before calling `gh pr merge`. Safety relies on authorize + non-admin `gh` behavior / branch protection. Acceptable for Directive iter; do not score as “checks-gated merge.”
3. `validate` is npm test/build only — thin on this harness repo (no `package.json` → skip). Fine as a stub artifact writer; not proof of post-merge harness health.

### `bin/consult` gh wiring

- One verb `consult gh` with subcommands — **not** three peer `pr`/`merge`/`validate` commands. Respects Iter-1 Critic cut.
- `CONSULT_ROOT` exported; default authorize path resolves under harness state.
- Help text states merge needs authorize-merge and no `--admin`.
- Side effect: writes `.last-pr-url` / `.last-validate.txt` under `runs/` — OK; prefer archiving under `runs/iter-N/evidence/` for closed iters (partially done via `pr-create.txt` / `pr-status.json`).

**Iter-1 nit closed:** `consult judge harness-evolution` now resolves — verified.

### `lib/harness-checks.sh` additions

| Check | Assessment |
|-------|------------|
| `github-seam` | PASS — file + `gh_pr_merge` present; negative grep for `--admin` in source. Fragile as a static pattern (comments must stay carefully phrased) but merge implementation is clean. |
| `merge-refuses-without-auth` | PASS — real refuse path via missing `CONSULT_AUTHORIZE_MERGE` target. |
| `lock-hashes-stable` | PASS — closes Iter-1 nit (hash equality, not mere presence). |
| `memory-harness-lesson` | PASS — MEMORY mentions harness-evolution (Iter-1 lesson). |

Suite 15/15 green in `checks.json`. Still objective/thin for band claims; correct as suite, not as scorer.

### PR https://github.com/lpbangun/product-consulting-harness/pull/1

- **OPEN**, real URL, created via harness path (`evidence/pr-create.txt`).
- Body documents gated merge / no `--admin` — consistent with code.
- Bundle is large (iters 0–2 + lock scaffolding). Acceptable as first publish of freeze; **not** mid-iter lock edit (hashes stable).
- Merge of this PR correctly deferred pending authorize-merge (owner gate). Do not merge from Iter-2 narrative without that file.

---

## 3. Scope vs Critic-accepted Iter-2 list

| # | Accepted / expected | Status |
|---|---------------------|--------|
| 1 | One gated GH workflow (create/status/checks/merge/validate) | **Met** — `lib/github.sh` + `consult gh` |
| 2 | Merge only with authorize-merge; ban `--admin`/force | **Met** |
| 3 | Dry-run / smoke refuse without live merge every run | **Met** — harness-check refuse path |
| 4 | No skills / evolve / further runtime adapters | **Met in claimed scope** |
| 5 | MEMORY + judge harness-evolution (Iter-1 leftovers) | **Met** (judge fixed; MEMORY has iter-1 lesson) |
| 6 | Lock hash stability check | **Met** |

**Working-tree contamination (flag, not report claim):**

- Untracked `skills/{critique,benchmark,design-sprint}/` already exists — **must not** be attributed to Iter-2.
- `runs/iter-3/evidence/lock-hashes-pre.txt` already present — premature spine OK only if Iter-3 has not silently expanded scope.
- Dirty agcode/OFC paths remain — keep out of harness-evolution commits and narrative (same Iter-1 flag).

---

## 4. Org review

- No new permanent worker. No plugin layer. No rival runtime module.
- GitHub helpers live in `lib/github.sh` — justified seam parallel to `provider.sh` / `harness-checks.sh`.
- CLI surface grew by one verb with subcommands — within Critic allowance.
- Do **not** add skill-orchestration permanence or a fifth role in Iter-3.

---

## 5. Formal verdict

### **ACCEPT-WITH-NITS**

Iteration valid to proceed to Independent scoring and close **after**:

1. Evaluator (not Principal) writes `runs/iter-2/scores.json` with path-cited evidence.  
2. Do **not** claim force-proof beyond “no `--admin` in harness merge args + authorize refuse.”  
3. Do **not** score `product-skills` on the untracked `skills/` preview.  
4. Keep lock files untouched; merge PR #1 only with owner `authorize-merge` (and never `--admin`).

Nits that do not block ACCEPT-WITH-NITS:

- Prefer `runs/iter-N/evidence/pr.json` (or equivalent) as the canonical PR artifact; current txt/json split is adequate but messy.  
- Strengthen authorize convention (required one-line owner note) without automating merge.  
- MEMORY still lacks a dated Iter-2 lesson path — add at close, not as scope expansion.  
- `validate` should eventually call harness-checks or record an explicit skip reason for non-npm repos.

---

## 6. Recommended Iter-3 scope — **three skills only**

Ship **exactly** the contract trio. Nothing else.

1. **`/critique`** — `skills/critique/SKILL.md` (+ invocable entry that leaves an artifact under `runs/iter-3/` or documented skills out-dir).  
2. **`/benchmark`** — `skills/benchmark/SKILL.md` (+ artifact).  
3. **`/design-sprint`** — `skills/design-sprint/SKILL.md` (+ artifact).

**Hard cuts for Iter-3:**

- No lock / contract / LOCK.md edits.  
- No new CLI verbs beyond minimal `consult skill …` (or equivalent) wiring required to invoke the three.  
- No auto-merge, no `--admin`, no authorize-file weakening.  
- No fourth skill, no `evolve`, no multi-runtime adapter matrix, no org role changes.  
- Do not merge PR #1 from the skills iter unless `state/harness-evolution/authorize-merge` exists and merge stays non-admin.

**Expected lift:** `product-skills` into 6–8 if ≥2 skills leave real artifacts; docs pointer for invocation.  
**Void magnets:** stub-only SKILL.md with no runnable entry; scoring skills from Principal; lock drift.

---

## Scores note

`runs/iter-2/scores.json` **does not exist** at verdict time.  
**Bias re-audit: pending.** This verdict covers diff, safety gates, freeze, scope, PR #1, and org only.

When scores land, reject any lift that cites only check presence as dimensional excellence; require the real PR URL and refuse-without-auth evidence for `github-integration` / `safety-discipline`.
