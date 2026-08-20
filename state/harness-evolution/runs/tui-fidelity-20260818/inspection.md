# Pre-freeze inspection — 2026-08-18

## Scope and provenance

Read-only inspection of the existing `lib/tui/` against:

- `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`
- `http://vmi3361268.tail16837d.ts.net:8788/locked/?v=1`
- `state/harness-evolution/runs/tui-migration-20260812/visualizer/decide/index.html`
- `http://vmi3361268.tail16837d.ts.net:8788/decide/?v=1`

The local and remote locked pages both hashed `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121`. The local and remote decision pages both hashed `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63`.

No app file was edited during this inspection. The worktree was already dirty at inspection start, including existing modifications to `lib/tui/app.py`, `lib/tui/theme.py`, tests, and snapshots; those changes are treated as the live baseline and must not be discarded.

## Existing matches

- Identical pure-ASCII 11×7 splash bodies are present in `lib/tui/theme.py`.
- Any-key splash consumption already exists.
- Wide header uses `▣─▣─▣`; compact header drops the heads and cwd.
- Idle chips are always role-hued.
- Team chat defaults to no visible idle `@Role`.
- Busy composer remains empty and busy facts are rendered in the footer.
- Evidence uses the existing bordered dock above the composer.
- Command rails include `Command · HH:MM`; turn rails use `│`; the rule is a filled terminal row; Textual notifications provide corner toasts; the active header head changes hue without blink.
- Functional seams for asks, confirms, completion cards, evidence classification, provider streaming, activity rows, and compact layout already exist.

## Mandatory gaps against the amended source of truth

| Ask lock / source requirement | Live finding | Evidence seam |
|---|---|---|
| Splash persists until Enter/any key | Splash auto-finishes on the fifth 0.4s tick | `lib/tui/app.py::_splash_advance` |
| Splash-only plane | Header, rule, activity, and chips remain mounted/visible while only the transcript is hidden | `lib/tui/app.py` CSS and `_splash_show` |
| `#role-prefix` width 0 unpinned | Prefix content is empty, but CSS width remains 12 | `lib/tui/app.py` CSS and `_render_role_prefix` |
| Second click pinned chip unpins | `select_role` always sets `_pinned = True` | `lib/tui/app.py::select_role` |
| Home `● name …… score` | Live rows render score first plus iter/trend metadata | `lib/tui/app.py::_home_row` |
| No-provider first-run | Only the no-scored-sessions empty state is rendered | `lib/tui/app.py::_seed_home`; no dedicated provider check/copy |
| 40-col chips `{glyph} {role} +N` | All four role widgets remain and are merely clipped | `lib/tui/app.py::compose`, `_render_chips` |
| ✓/✗ on chip row and completion card | Completion cards exist, but role chips carry identity/focus only | `lib/tui/theme.py::completion_card`; `lib/tui/app.py::RoleChip` |
| OMP ask chrome | Options have descriptions but use `★`; no dock title or in-dock `k of n` | `lib/tui/app.py::_render_ask_dock`, `_ask_option_row` |
| OMP confirm chrome | Confirm is two compact rows without title/count/descriptions | `lib/tui/app.py::_open_confirm` |

## Verification baseline

`lib/tui/.venv/bin/pytest --collect-only -q` collected exactly 73 tests. The suite was not executed during this no-app-edit inspection; execution begins only after the reviewer freezes the benchmark.
