# MEMORY.md — Organizational Memory

Append-mostly. Newest entry per section on top. This file exists so a
future run continues instead of restarting. Keep entries short, dated,
and evidence-linked.

## Engagements

- **agcode-learning** (opened 2026-08-05) — local-first agentic-coding
  learning system: tutor skill + plain-text files + research brief.
  Repo: `/home/logani/projects/agcode-learning` (clone) ·
  live working copy: `/home/logani/projects/AgCode Learning`.
  Vision is frozen; we improve execution, not direction.

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
- 2026-08-05 · `claude -p` works headless with the session's auth —
  usable as the default swappable provider; no API keys needed.

## Org self-improvements applied

- 2026-08-05 · Founded with the minimal org: Principal + Analyst +
  Builder + Critic. No other permanent workers until evidence demands.

## Escalations (awaiting owner)

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
