# Convergence report — agcode-learning

Contract v1 (frozen 2026-08-05) · target ≥9.0 every area · 3 iterations run

## Verdict

**Converged, below strict target.** The loop converged — overall deltas
by iteration were **+2.3, −0.1, +0.1** — and further iterations within
org authority would only re-score noise. The strict target (every area
≥9) was **not** reached. This report names exactly why, so the gap is
an owner action list, not a failure.

## History

| Area | iter-0 | iter-1 | iter-2* | iter-3 | Δ (0→3) | ≥9? |
|---|---|---|---|---|---|---|
| correctness | 8.0 | 9.0 | 8.0 | **9.3** | +1.3 | ✅ |
| simplicity | 6.3 | 8.5 | 8.5 | 8.0 | +1.7 | — |
| maintainability | 6.0 | 8.0 | 8.0 | 7.5 | +1.5 | — |
| usability | 4.5 | 8.5 | 8.0 | 7.8 | +3.3 | — |
| educational-quality | 8.5 | 9.0 | 9.0 | **9.0** | +0.5 | ✅ |
| developer-experience | 4.5 | 7.5 | 7.5 | 7.0 | +2.5 | — |
| architecture | 5.5 | 8.0 | 8.5 | 8.5 | +3.0 | — |
| documentation | 5.0 | 7.5 | 7.5 | 8.5 | +3.5 | — |
| product-clarity | 6.0 | 9.0 | 9.0 | **9.0** | +3.0 | ✅ |
| **overall** | **6.0** | **8.3** | **8.2** | **8.3** | **+2.3** | 3/9 |

\* iter-2 shown as Critic-audited values (panel medians preserved in
`runs/iter-2/scores.json` → `panel_raw`).

## Two-tier result

**Green (≥9, within org authority, evidence-verified):** correctness,
educational-quality, product-clarity.

**Amber (below target, ceiling owned outside the org):** simplicity,
maintainability, usability, developer-experience, architecture,
documentation.

## Why the amber areas cannot reach 9 from inside

1. **Escalation 1 — SKILL.md absolute data path.** The skill reads its
   data files from the author's machine directory; a clone's own data
   files are inert until the user repoints the path. This single design
   decision caps developer-experience, usability, maintainability, and
   architecture. The org documented and warned (README) but may not
   change skill behavior without owner sign-off. Options a/b/c are in
   MEMORY.md.
2. **Escalation 2 — no LICENSE.** Choosing reuse terms is the owner's
   rights decision; the org flagged and recommended (MIT) but did not
   apply. Caps a fully clean documentation sign-off.
3. **Intrinsic property — the research corpus.** ~640KB of dated
   evidence is the product's stated provenance ("evidence-based
   design"). Scorers who weight a lean surface see it as removable-
   adjacent; it is not removable without loss. Simplicity converges
   ~8.0 by construction.

## What would unblock green

- Owner approves data-path option (b) or (c) → developer-experience,
  usability, maintainability, architecture each gain ~1–1.5.
- Owner chooses a license → documentation completes.
- Nothing further is required of the org.

## Method note

Amber areas show ±0.5 iteration-to-iteration movement between
functionally identical states — scorer temperament, not product change.
Point estimates are reported for green areas; amber areas are best read
as ranges (e.g. DX 7.0–7.5). The frozen contract was never amended;
the baseline was never retroactively re-scored.
