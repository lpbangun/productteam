# Iteration 6 report — core CLI visual features

**Contract:** `visual-cli-v1` · **Baseline:** 0/8 · **Final:** 8/8 · **Mode:** Directive · **Iterations:** 4/4 · **Result:** CONVERGED

## Debate

The Principal proposed all eight user-requested features. The Critic kept all eight but constrained the implementation: two accent hues, an honest per-turn status line instead of an alt-screen TUI, file-backed telemetry rather than a daemon, and score normalization for both flat and nested history schemas.

## Implementation and diff summary

- `lib/theme.sh`: distinct Principal / Analyst / Builder / Critic turn tags and shared semantic badges.
- `lib/activity.sh`: atomic `workers.tsv` session activity, spinner/elapsed/mission/provider, and completion cards.
- `lib/repl.sh`: activity lifecycle, markdown-lite provider replies, five-field status line, `/workers`, and session-only `/provider` cycling.
- `lib/render.sh`: markdown-lite headings/fences/verdicts and signed evidence-path rendering.
- `lib/provider.sh`: installed-provider cycling over the existing sole catalog.
- `bin/productteam`: normalized flat/nested scores; real deltas and evidence paths in bench/run/report; selected provider presence; role chrome.
- `lib/onboarding.sh`, `lib/github.sh`, and check renderers: shared pass/fail/progress/pending/escalate language.
- `tests/visual-cli.sh`: executable eight-criterion benchmark with required archived live proof.
- `README.md`, `ARCHITECTURE.md`: user controls, state paths, and spinner opt-out.

No daemon, database, mock provider, permanent worker, third accent hue, or second agent catalog was added.

## Four-iteration convergence

1. Initial implementation: focused criteria green; full suite 45/49. Failed on a renderer-source false positive, stale wildcard docs, and a new `script` test dependency.
2. Replaced permanent `script` use with Python stdlib PTY and repaired source/docs: full suite 47/49; one stale wildcard reference remained.
3. Full suite reached 49/49. Independent Analyst then rejected convergence because the live transcript had not exercised no-argument `/provider` cycling.
4. Added a real cycle transcript. Final Critic found and required two more same-iteration fixes: render missing-provider refusal text, and forbid benchmark convergence without live proof. Final Advisor, full suite, Analyst, and Critic all passed.

## Verification — real commands and runtime

- `tests/visual-cli.sh state/harness-evolution/runs/iter-6/visual-checks-final.json` → 8/8, zero fail/skip, live proof pass.
- Codex Advisor ran the focused benchmark, `bin/productteam smoke`, and `bash -n` → all exit 0; `advisor-runtime-final.txt` records `ADVISOR_VERDICT=PASS`.
- `bash lib/harness-cli-checks.sh state/harness-evolution/runs/iter-6/harness-cli-final` → 49/49, zero fail/skip, live provider checks executed, overall 9.5.
- `live-chat.typescript` → real authenticated `agent` spinner, elapsed mission/provider, completion card, markdown-lite reply, and status redraw.
- `live-chat-cycle.typescript` → `/provider` changed agent → claude, `/agents` marked claude selected, selection returned to agent, and the real reply `LIVE-CYCLE-OK` completed.
- Missing-provider PTY path renders the original refusal body plus the failure card.

## Independent score

`visual-scores.json` was authored by the independent Analyst: 8/8 pass, 0 failed, 0 skipped, converged true; baseline delta +8 criteria.

## Org self-review

Parallel Builders were useful for four independent seams, while the Principal owned interfaces and integration. The Advisor independently created the benchmark and ran final suites through the real Codex runtime. Critic review caught two paper-green defects after deterministic checks passed; preserving the Critic gate was necessary. No new permanent worker is justified.

## Operability mission addendum

The owner-directed operability mission also converged in one mission iteration
(maximum three), with Builds 1–4 completed strictly in order:

1. Workspace isolation — 5/5 Advisor PASS; Critic ACCEPT-WITH-NITS.
2. Judgment gates — 5/5 Advisor PASS; eight real mode refusal/pass paths.
3. Inspect pack and escalations — 5/5 Advisor PASS; seven real lifecycle paths.
4. Role envelope and inspection — 5/5 Advisor PASS; Critic
   ACCEPT-WITH-NITS, no blockers.

The additive diff introduces `lib/workspace.sh`, `lib/judgment-gate.sh`,
`lib/engagement-state.sh`, and `lib/role-envelope.sh`; wires their lifecycle,
gate, pause/resume, inspect, sealed-input, role-status, Analyst-score, and
Critic-close contracts through `bin/productteam`; and retains `bin/consult` as
the compatibility shim. The integrated operability harness records 50 passed,
0 failed in `checks.json`. Build-specific benchmark, debate, decision, Builder,
Advisor, Critic, and command evidence lives beside this report.

The `Fix/New-User-TUI` visual commit is the base of
`Upgrade/basic-funcionalities`; the operability changes are committed on the
destination branch. No daemon, database, plugin router, RAG layer, mock
provider, swarm/bus, or second orchestrator was added.

### Operability org self-review

Principal / Analyst / Builder / Critic remains the permanent organization.
Advisor was a temporary benchmark/evaluation label. Plain JSON plus one library
per state seam kept continuation inspectable without adding a control plane.
Early unbounded Builder prompts caused avoidable no-edit attempts; future role
requests must lead with exact files, symbols, and acceptance boundaries.
