# MEMORY.md — Organizational Memory

Append-mostly. Newest entry per section on top. This file exists so a
future run continues instead of restarting. Keep entries short, dated,
and evidence-linked.

## Engagements

- **harness-cli** (opened + closed 2026-08-07) — Product Consulting Harness
  **CLI** (not JobOS). Mode: Directive · Contract: harness-cli-v1 · Scorer: checks.
  Baseline 3.4 → **9.5** in 1 iteration; all 9 dims ≥9.5; 49/49 checks live.
  CONVERGED. Evidence: `state/engagements/harness-cli/`. Mis-scope note: an
  early turn targeted JobOS; owner corrected to CLI-only before baseline.

## Validations (frozen harness)

- **2026-08-06 · harness CONVERGED** harness-apc-v1 iter-5 overall 8.4 ·
  freeze tip `4c7e226` · report `state/harness-evolution/FINAL-REPORT.md`
- **OFC** PR https://github.com/lpbangun/onboarding-flight-control/pull/2
  merged `6a8db8e` · `state/validations/ofc-2026-08-06/`
- **48h kit** PR https://github.com/lpbangun/48-hour-contributor-readiness-kit/pull/1
  merged `562a90e` · `state/validations/48h-2026-08-06/`
- **Skills Vector** PR https://github.com/lpbangun/skills-vector/pull/1
  OPEN (PR-only) · `state/validations/skills-vector-2026-08-06/`


- **onboarding-flight-control** (opened + closed 2026-08-06) — fictional
  People Ops onboarding portfolio demo (React/Vite, localStorage).
  Repo: `/home/logani/projects/onboarding-flight-control` · public
  https://github.com/lpbangun/onboarding-flight-control · branch
  `consult/engagement-2026-08-06`. Live copy not scored:
  `/home/logani/projects/Onboarding Flight Control`.
  Mode: Guided · Contract: ofc-v1 · Scorer: checks.
  **Result:** 5.8 → 9.5 in 1 iteration; all dims ≥9 via deterministic
  checks. Verifier ACCEPT / CONVERGED. See
  `state/engagements/onboarding-flight-control/convergence-report.md`.
  Client changes uncommitted pending owner PR request.
- **agcode-learning** (opened + closed 2026-08-05) — local-first
  agentic-coding learning system: tutor skill + plain-text files +
  research brief. Repo: `/home/logani/projects/agcode-learning` ·
  live working copy: `/home/logani/projects/AgCode Learning`.
  **Result:** 6.0 → 8.3 overall in 3 iterations; correctness 9.3,
  educational-quality 9.0, product-clarity 9.0 at/above target.
  Converged below strict target: residual capped by two owner
  decisions (data path, license) — see
  `state/engagements/agcode-learning/convergence-report.md`.
  **PR:** https://github.com/lpbangun/agcode-learning/pull/1
  (branch consult/engagement-2026-08-05). Vision never touched.
- **Harness published (2026-08-05):**
  https://github.com/lpbangun/product-consulting-harness (public).
  Future engagements: clone it, run `bin/consult` — memory carries.

## Client model — agcode-learning

- Product = `/learn-agentic` skill + `concepts.md`, `syllabus.md`,
  `meta-watch.md`, `journal.md`. Research docs justify the design.
  `index.html` is a research decision brief, not the product.
- Owner's intent (PLAN.md): no app, no TUI, no database; skill + files.
- Hard constraints: evidence-gated levels, predict-before-reveal,
  deterministic check scripts, absolute portability across harnesses.
- The live working copy held an **uncommitted SKILL.md refinement**
  (intent-first rule, terser portability section) dated 2026-08-02,
  ahead of GitHub. The engagement carries it forward, not over it.

## Lessons

- 2026-08-06 · harness-evolution iter-5: close memory/autonomy residuals via
  org self-reviews + phases.json + harness-checks — no new CLI verbs.
  Evidence: `state/harness-evolution/runs/iter-5/`.
- 2026-08-06 · harness-evolution iter-4: authorized non-force merge of
  https://github.com/lpbangun/product-consulting-harness/pull/1 →
  `2cb1a9f`; post-merge validate archived under runs/iter-4/evidence/.
- 2026-08-06 · harness-evolution iter-3: first-party skills under
  `skills/{critique,benchmark,design-sprint}/` via `consult skill`.
  Evidence: `state/harness-evolution/runs/iter-3/`.
- 2026-08-06 · harness-evolution iter-2: one `consult gh` seam (not three
  verbs); merge refuses without authorize-merge; never admin bypass.
  Real PR: https://github.com/lpbangun/product-consulting-harness/pull/1
- 2026-08-06 · harness-evolution iter-1: extend `lib/provider.sh` for runtime
  detect (do not add parallel `runtime.sh`); fold secrets into
  `harness-checks`; never invoke provider scoring inside smoke refuse tests
  (hang). Evidence: `state/harness-evolution/runs/iter-1/`.
- 2026-08-06 · Owner approved: `scorer` field (`checks`|`provider`) +
  `consult score` dispatch with refuse-wrong-path; client repos as
  siblings only (OFC moved to `/home/logani/projects/onboarding-flight-control`).
  No plugin router; no nested `clients/`.
- 2026-08-06 · Deterministic `consult checks` as primary ofc-v1 scorer
  avoided LLM re-score drift; uniform 9.5 means “all objective checks
  pass,” not editorial excellence. Keep band mapping honest in
  `lib/run-checks.sh`.
- 2026-08-06 · Vitest measurement scaffold must exclude `*.test.ts` from
  app `tsc` or baseline `build-green` falsely fails.
- 2026-08-06 · Contract grep tests that assert strings live in `App.tsx`
  constrain extractions — leave disclaimer/STATUS_META where checks look.
- 2026-08-05 · Panel noise: identical states scored ±0.5 apart by
  different scorers. Report point estimates only for green areas;
  report ranges for amber. Never chase ±0.5 with a re-score.
- 2026-08-05 · A converged loop can still miss a strict target when
  the residual is owned outside the org. The honest close is a
  two-tier result plus an owner action list — not a papered-over 9.
- 2026-08-05 · Debate pays: Critic cut `scripts/verify.sh` (weak
  justification, would have baked in the broken path) and an index.html
  edit (frozen research artifact already framed correctly), and caught
  that a documentation-only fix would codify a bug instead of fixing it.
  Net: 2 files not created, 1 artifact untouched, scope sharpened.
- 2026-08-05 · When moving files in a client repo, grep for BOTH href
  patterns (`href="…"` in HTML) and markdown links (`](…)`) including
  `../` sibling links — the sibling links were the ones that would have
  broken silently.
- 2026-08-05 · Score client repos from a fresh clone, not the live
  working copy, so uncommitted owner work doesn't skew baseline.
  Carry the owner's uncommitted intent into scope explicitly.
- 2026-08-05 · LLM-judged benchmarks drift toward generosity on
  re-score; keep baseline frozen and require file-path evidence per
  score to hold the line.
- 2026-08-05 · Provider seam verified end-to-end: `consult bench
  <client> run` scored a scratch engagement via `claude -p` headless
  (valid JSON, history appended), then the scratch was deleted. A
  future session can re-score without the orchestrating session.
- 2026-08-05 · Record a run only AFTER the Critic's score audit. The
  iter-1 run was recorded before its audit and carried 0.2 of
  self-grading optimism; iter-2 onward records audited values with the
  panel medians preserved in `panel_raw`.
- 2026-08-05 · When an iteration fixes N-1 of N sibling facts (e.g.
  adds a link but not the count of links), the panel finds the stale
  one immediately. Sweep the doc for every mention of the changed fact
  in the same commit.
- 2026-08-05 · `claude -p` works headless with the session's auth —
  usable as the default swappable provider; no API keys needed.

## Org self-improvements applied

- 2026-08-06 · Product Judgment Layer: `JUDGMENT.md`, `consult judge`,
  modes Guided/Directive/Challenge/Override; provider default → Cursor
  `agent`; `consult checks` + smoke; contract-aware bench header;
  `scorer` field + `consult score`; sibling client repos only.
- 2026-08-05 · Audit-before-acceptance enforced from iter-2 (iter-1's
  late audit cost 0.2 of recorded optimism).
- 2026-08-05 · Scorer prompts hardened: "exactly one entry per area"
  after a duplicate-key emission in iter-1.
- 2026-08-05 · Tiebreak framing rule: machine-local context (owner's
  sibling working copy) is not a repo defect; repo properties are.
- 2026-08-05 · Two CLI bugs fixed in live use; provider seam proven
  end-to-end via scratch engagement (deleted after).
- 2026-08-05 · Founded with the minimal org: Principal + Analyst +
  Builder + Critic. Builder stayed dormant through 3 doc-scale
  iterations — right-sized, not missing. No other permanent workers
  until evidence demands.

## Escalations (awaiting owner)

- **agcode-learning · both escalations delivered in PR #1
  (2026-08-05)** — data path and license are surfaced in the PR body
  with recommendations. Status stays open here until the owner rules.
- **agcode-learning · SKILL.md data path (2026-08-05).** The skill
  hardcodes an absolute data directory (`/home/logani/projects/AgCode
  Learning/`) that is a *sibling* of the repo, so a fresh clone cannot
  run the skill without editing it, and the repo's own tracked data
  files are not what the shipped skill reads. Fixing this changes
  product behavior, so it is the owner's call. Options the org can
  implement on request, cheapest first:
  1. **Document-only** (done in iter-1 README): state the requirement
     and the shipped path; user edits on install.
  2. **Repo-relative data dir**: point SKILL.md at the repo's own data
     files so a clone is self-contained.
  3. **Per-harness override**: make the data dir a documented variable
     each harness sets, keeping portability without a fixed absolute
     path.
  The org recommends option 2 or 3 but will not apply either without
  owner sign-off (Constitution: product-behavior change = escalate).
