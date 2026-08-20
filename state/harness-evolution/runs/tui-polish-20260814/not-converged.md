# TUI polish — not converged

> Historical checkpoint: this was the correct iter-5 stop verdict. The owner
> later authorized `extension.md`; iter-9 reached the first independent
> all-pass. The run's final outcome is `final-report.md`.

Date: 2026-08-14  
Run: `tui-polish-20260814`  
Final independent verdict: **FAIL** (`iter-5/reviewer-gate.md`)  
Implementation iterations used: **5/5** — no sixth iteration.

## Decision

Keep the already-shipped 2026-08-13 Textual cockpit, `lib/tui/`, and the `tui` registry row. Do not write `final-report.md`. Do not delete or replace the cockpit. Do not start another frontend.

The final implementation is runnable and its current behavioral suite is green, but the frozen acceptance rule is every D01–D29 >=9.0. Only 8/29 dimensions meet that bar. Five required seams remain entirely absent: structured ask, bordered evidence, write confirmation, TUI-owned splash, and the combined ask/confirm/evidence backend seam.

## Final proof

- Native TUI pytest + snapshots: **39 passed, 0 failed** — `iter-5/pytest.txt`.
- Real PTY: **4 passed** — status/gate, provider interrupt, typed Builder role, SIGWINCH 80→40→80 — `iter-5/pty-test.txt`, `iter-5/pty-note.md`.
- CLI interface parity: **PASS**, 33 commands / 18 supported / 15 unsupported / 6 chat-only — `iter-5/cli-interface-parity.txt`.
- Visual CLI: **14/14**; overall exit 1 only for the contract-allowed pre-existing missing live-provider proof — `iter-5/visual-cli.txt`.
- Freeze hash and executable argv dry-run: `FREEZE-SHA.txt`, `argv-dry-run/argv-dry-run.json`, `argv-dry-run/trace.jsonl`.
- Complete final scoring, diff critique, bias audit, and org critique: `iter-5/scores.json`, `iter-5/reviewer-gate.md`.

## Sub-9 dimensions

| ID | Score | Blocking failure |
|---|---:|---|
| D01 | 8.0 | Activity is conditional; ask, confirm, and evidence docks are absent. |
| D03 | 8.5 | Empty-home copy lacks fixture proof; ordering is mapped-first rather than explicit recency. |
| D04 | 8.6 | Live speaking rail works; no markdown-lite speaking-turn snapshot. |
| D05 | 8.5 | Wide/compact headers are proven; active middle-head pulse remains source-only. |
| D06 | 7.5 | Native activity strip/caps pass; no live-PTY braille, elapsed, and cap proof. |
| D07 | 8.4 | Native and PTY resize pass; live activity cap and score slot are not asserted on the real TTY. |
| D08 | 0.0 | No structured ask event, OMP-style dock, or file-backed ask fixture. |
| D09 | 8.2 | Owned speech is live; no real-PTY empty-artifact silent-work proof. |
| D10 | 6.0 | No speaking-turn markdown-lite snapshot; completion card remains detached. |
| D11 | 7.5 | Real PTY slash works; command echo is not a mute Command rail. |
| D12 | 0.0 | No bordered labelled evidence panel. |
| D13 | 0.0 | No confirm intercept before `/gh merge`, `/checks --allow-dirty`, or `/onboarding --yes`. |
| D14 | 5.8 | Interrupt toast is proven; done card is detached and `/export` adds a transcript line. |
| D15 | 8.0 | Idle/busy/slash footer states pass; ask/evidence footer states do not exist. |
| D16 | 0.0 | No TUI-owned angular splash, key skip, or boot glow cycle. |
| D19 | 8.0 | Copy remains a transcript line instead of a session toast. |
| D21 | 8.2 | Supported slash streams real output; Command rail is absent. |
| D24 | 8.6 | Exact-session activity/role/interrupt work; prompt export is not captured and live strip chrome is not PTY-proven. |
| D25 | 0.0 | Ask, confirm, and evidence backend seams are all absent. |
| D26 | 5.0 | Non-TTY behavior passes; TUI splash seam is absent. |
| D28 | 7.2 | Native, PTY, parity, and visual gates pass; ask/confirm/evidence/splash test rows remain absent. |

Zeros: **D08, D12, D13, D16, D25**. Full citations: `iter-5/reviewer-gate.md:175-203` and `iter-5/scores.json`.

## What remains shipped

- Filtered scored-session home and cwd/latest-score header.
- Exact cockpit identity tokens; gray You rail; role-colored chips and speaking rails.
- Session-local focusable/clickable target chips, idle `@Principal`, typed `@Role`, role argv, agent-card prompt prepend.
- Real argv-only registry palette, supported slash streaming, unsupported no-spawn refusal, chat-only verbs.
- Exact-session `workers.tsv` activity strip, braille/elapsed facts, width caps, and no `Thinking...` transcript message.
- Idle/busy/slash footer states; explicit 40-column header; live 80→40→80 restoration.
- Process-group interrupt with partial artifact preservation; complete live artifact drain without duplicated transcript body.
- Non-TTY refusal and canonical Bash CLI behavior.

This is a useful polish increment, not convergence against the locked visualizer contract.

## Later extension (2026-08-14)

The owner authorized `extension.md` after this checkpoint. An intermediate
owner exit paused iter-6; the owner then explicitly resumed and expanded the
same immutable-freeze extension through iter-10 maximum. Independent iter-9
scoring passed all D01-D29, so the loop stopped before iter-10. See
`final-report.md`; this file remains the historical iter-5 evidence.
