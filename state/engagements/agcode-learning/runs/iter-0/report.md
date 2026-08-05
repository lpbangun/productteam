# iter-0 — Baseline (pre-change)

Date: 2026-08-05 · Contract v1 (frozen) · Overall: 6.0 / target 9.0

## Scores

| Area | Score | Weakest evidence |
|---|---|---|
| correctness | 8.0 | skill hardcodes divergent sibling-dir path |
| simplicity | 6.3 | 13 research docs flat at root; stale analysis files |
| maintainability | 6.0 | no conventions doc; two-copy sync by hand |
| usability | 4.5 | no README / entry point |
| educational-quality | 8.5 | PLAN.md checkbox stale; SKILL rule 8 omits P7 exception |
| developer-experience | 4.5 | no setup notes; one-machine absolute path |
| architecture | 5.5 | 5-file product buried under ~600KB research |
| documentation | 5.0 | README missing entirely |
| product-clarity | 6.0 | root reads as research repo; hybrid-TUI vs no-TUI split |

## Method

3-scorer panel (strict / fresh-eyes / skeptic), independent, file-path
evidence required per score. Spreads >2.0 on simplicity and
architecture → one tiebreak scorer with a clarified frame (repo
properties only; owner's sibling working copy is machine context).
Medians recorded. Principal re-verified every bash-checkable claim.

## Consensus defects (all three scorers)

1. No README — repo identity, entry point, and file map invisible.
2. Machine-bound data path — SKILL.md hardcodes
   /home/logani/projects/AgCode Learning/; fresh clone cannot run it.
3. Flat root — 5-file product buried under ~13 research artifacts.

Plus (skeptic, cross-audit confirmed): PLAN.md staleness (language
decision open but resolved in syllabus), SKILL rule 8 missing the
P7 check-script exception, index.html hybrid-TUI recommendation
unreconciled with v0's no-TUI decision.

## Context carried into iteration 1

The live working copy holds the owner's uncommitted SKILL.md
refinement (intent-first rule). GitHub is behind owner intent. The
engagement carries that refinement forward as its first commit.

This is the frozen baseline. These scores are never re-scored
retroactively; every later run is compared against this one.
