# Goal loop — TUI visual fidelity

Copy everything below the line into a new Pi session. Do not nest a Goal.

One-line objective:

> Make productteam tui match the locked visualizer as amended by the 2026-08-18 Ask locks; reviewer freezes from those pages, worker implements, gate each iter, stop at first all-pass or after 5.

---

You are the orchestrator. Stay on the session default. Spawn **`reviewer`** and **`worker`** only — not `task`.

Make `productteam tui` match the source of truth. Functions already work (73/73). Do not rebuild. Do not start another frontend. If this misses 9.0, keep `lib/tui/` and write `not-converged.md`.

## Source of truth

Work toward these. The reviewer freezes from them; this prompt is not a second spec.

- Locked cockpit: `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`  
  http://vmi3361268.tail16837d.ts.net:8788/locked/?v=1
- Ask locks (amend the mock where they conflict):  
  http://vmi3361268.tail16837d.ts.net:8788/decide/?v=1

Ask locks that amend the mock:

| ship | keep |
|---|---|
| splash until Enter/any key; splash-only plane | identical ASCII splash bodies |
| `#role-prefix` width 0 when unpinned | header `▣─▣─▣` |
| second click on the pinned chip unpins | always role-hued chips |
| home `● name …… score` | empty busy composer; facts in footer |
| no-provider first-run | evidence dock above composer |
| 40-col chips `{glyph} {role} +N` | live chrome pack (Command · HH:MM, corner toast, filled rule, no blink, `│` rail) |
| ✓/✗ on the chip row as well as the card | team chat: no idle `@Role` |
| OMP ask/confirm chrome (title, `k of n`, “recommended”, descriptions) | |

## Loop

Evidence: `state/harness-evolution/runs/tui-fidelity-20260818/`

1. **Inspect** live `lib/tui/` against the two pages. No app edits.
2. **`reviewer` freeze** `frozen-benchmark.md` from those pages. ACCEPT-FOR-FREEZE + `FREEZE-SHA.txt`. Then implement. Do not amend the freeze after hash.
3. **One `worker`** per slice, smallest diff, against the freeze.
4. **This session** runs the freeze’s tests.
5. **`reviewer` scores.** Every mandatory dim ≥ 9.0 → `final-report.md`, stop. Else next iter. After 5: `not-converged.md`, stop.
