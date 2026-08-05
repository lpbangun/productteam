# Engagement: agcode-learning

Opened: 2026-08-05 · Contract: v1 (frozen) · Client owner: lpbangun

Repo: /home/logani/projects/agcode-learning
Public: https://github.com/lpbangun/agcode-learning
Live working copy: /home/logani/projects/AgCode Learning
Branch: consult/engagement-2026-08-05
Vision: Local-first agentic-coding learning system — tutor skill plus plain-text learning files; research artifacts justify the design

## What this product is

A learning system for agentic engineering: the `/learn-agentic` tutor
skill plus `concepts.md` (evidence-gated ledger), `syllabus.md`
(7-project build ladder), `meta-watch.md` (terminology map),
`journal.md` (append-only log). `index.html` is a research decision
brief. Six audits + two advisor reviews + three research docs back the
design decisions.

## Invariants (do not touch)

- Vision: skill + plain-text files. No app, no TUI, no database.
- Pedagogy: evidence-gated levels, predict-before-reveal, assistance
  tracking, deterministic check scripts, harness portability.
- Owner's uncommitted SKILL.md refinement (2026-08-02, intent-first
  rule) in the live working copy is owner intent — carry it forward.

## Known findings at intake (2026-08-05)

1. No README.md — repo identity and entry points invisible.
2. GitHub is behind the live working copy (uncommitted SKILL.md).
3. ~640KB of research docs flat at repo root; product files and
   research artifacts interleaved.
4. `journal.md`, `meta-watch.md`, `concepts.md` are healthy but the
   relationship between root files is never explained in one place.
5. `index.html` links research docs by root-relative names — any file
   move must update those links.
