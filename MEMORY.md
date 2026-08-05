# MEMORY.md — Organizational Memory

Append-mostly. Newest entry per section on top. This file exists so a
future run continues instead of restarting. Keep entries short, dated,
and evidence-linked.

## Engagements

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
