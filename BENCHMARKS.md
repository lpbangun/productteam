# BENCHMARKS.md — Benchmark Contract v1 (FROZEN)

**Contract v1 · frozen 2026-08-05 · never amended mid-engagement.**
Every engagement is scored against this exact contract. Changing it
requires owner approval, bumps the version, and applies only to new
engagements. Scores are 0–10 per area, one decimal. A score without a
cited path or check result is void.

## Scoring protocol

1. Analyst scores each area independently of the Principal.
2. Each score must cite evidence: a file path, check output, or diff.
3. Critic re-audits for self-grading bias before the run is accepted.
4. Overall = mean of the nine areas, rounded to one decimal.
5. Convergence = every area ≥ 9.0. Target for every engagement.

## The nine areas

### 1. Correctness
Does what its docs and code claim. No broken links, dead paths,
contradictions between files, or claims the repo cannot back.
- 9–10: every checked claim holds; links/paths resolve; no known bugs.
- 6–8: minor inconsistencies, all non-functional.
- ≤5: broken behavior or false claims a user would hit.

### 2. Simplicity
Minimum structure for the job. No file, section, or mechanism whose
removal would go unnoticed.
- 9–10: nothing removable without loss; no duplication.
- 6–8: a few redundant or vestigial elements.
- ≤5: clear waste a reader must wade through.

### 3. Maintainability
A competent stranger can make a safe change quickly.
- 9–10: conventions explicit and consistent; change points obvious.
- 6–8: mostly consistent; a few undocumented conventions.
- ≤5: traps, magic values, or knowledge that lives in one head.

### 4. Usability
A first-time user succeeds without out-of-band help.
- 9–10: entry point obvious from first look; common paths work cold.
- 6–8: usable after minor digging.
- ≤5: first-run failure or confusion likely.

### 5. Educational quality
(For learning products; otherwise score teaching value of its docs.)
Pedagogy is sound: goals stated, evidence-gated progression, practice
over passive reading, honest about what is proven vs proposed.
- 9–10: learning loop coherent, complete, internally consistent.
- 6–8: strong core with gaps or rough sequencing.
- ≤5: pedagogy unclear, ungrounded, or self-contradicting.

### 6. Developer experience
Clone-to-value friction for someone building on or with it.
- 9–10: zero-setup where possible; errors explain themselves.
- 6–8: small, documented friction.
- ≤5: hidden prerequisites or silent failures.

### 7. Architecture
Structure matches purpose; seams where change is likely; nothing
over-built.
- 9–10: every layer justifies itself; swap points exist where needed.
- 6–8: sound with one questionable placement.
- ≤5: structure fights the purpose.

### 8. Documentation
Right documents, current, findable, honest.
- 9–10: README + role docs answer real questions; nothing stale.
- 6–8: good coverage with drift in places.
- ≤5: key questions unanswerable from the repo.

### 9. Product clarity
What it is, who it's for, what it deliberately is not — visible fast.
- 9–10: identity and non-goals graspable within a minute.
- 6–8: clear after reading around.
- ≤5: identity ambiguous or oversold.

## Baseline guard

The first scored run of an engagement (iter-0) is the baseline. It is
taken **before any change** and is never re-scored retroactively. All
later runs are compared against it. That is what "never move the
goalposts" means in practice.
