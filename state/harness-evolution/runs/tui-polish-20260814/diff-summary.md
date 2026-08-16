# TUI polish diff summary

Scope: optional Textual cockpit and its native tests. `productteam chat`, command registry, canonical Bash theme/render/activity/provider/domain authority, prior ship evidence, and deleted spike trees were not replaced.

## Product changes

| File | Change |
|---|---|
| `lib/tui/app.py` | Filtered, recency-ordered scored home; cwd/latest-score header and live middle-head pulse; exact identity/turn chrome; focusable role chips and `@Role`; role-owned provider speech; exact-session activity strip; compact resize; structured ask, exact write confirmation, bordered evidence dock, Command rails, attached cards/toasts, TUI splash, footer states, streaming and interrupt lifecycle. |
| `lib/tui/provider_turn.sh` | `ROOT PROMPT ROLE`; Principal fallback; `activity_start "$ROLE"`; selected agent `prompt_export`/card block prepend; artifact-first and process-group behavior preserved. |
| `lib/tui/theme.py` | Locked cockpit tokens and four identity hues, neutral turn bodies, timestamps, markdown-lite headings/fences/diffs/evidence paths, completion cards, and TUI-owned angular splash rendering. Canonical Bash remains two-accent. |

No `adapter.py`, `session.py`, `__main__.py`, registry, or Bash authority change was required. Palette remains live `productteam help --json`; execution remains argv-only with `shell=False`.

## Test and visual evidence

| File | Change |
|---|---|
| `lib/tui/tests/test_layout.py` | Four-size chrome, filtered/empty/recency home, exact tokens and all role rails, targeting, header pulse, activity caps, silent empty artifact, owned speech, ask/confirm/evidence/splash/footer/toast/card states, and native resize. |
| `lib/tui/tests/test_pty.py` | Six real executable rows: status/gate refusal, interrupt/partial artifact/130, typed Builder row, confirm cancel, idle resize, and live activity + empty artifact + prompt export + compact score/1+N + restore + first speech. |
| `lib/tui/tests/test_slash.py` | Registry palette, supported streaming, unsupported no-spawn, session verbs/toasts, ask/confirm/evidence, Command rails, cards, and markdown-lite output. |
| `lib/tui/tests/test_all_verbs.py` | Native boot synchronization and per-turn real CLI streaming while retaining command needles. |
| `lib/tui/tests/__snapshots__/*.svg` | Locked idle cockpit and palette: wide header, filtered home, four role chips, `@Principal`, dock-above-composer, locked hues, no Textual cyan/Directive. |

Final `git diff --numstat -- lib/tui`: **4,142 inserted / 300 deleted across 9 files**. SVG source and extensive behavioral tests dominate the line count; this is not a semantic complexity measure.

## Deliberate omissions

No mandatory omission remains. Independent iter-9 scoring is 29/29 dimensions at or above 9.0.

The Reviewer names only optional 10-band residuals: live-PTY splash, live-PTY `/report`, live-PTY Critic speech, fallback agent-card capture, pulse/recency snapshots, and provider text in the compact busy footer. None is a frozen 9.0 blocker; no iter-10 work is authorized.

## Verification

Final evidence:

- `iter-9/pytest.txt`: **73 passed**.
- `iter-9/pty-test.txt`: **6 passed**.
- `iter-9/cli-interface-parity.txt`: **PASS 33/18/15/6**.
- `iter-9/visual-cli.txt`: **14/14**; exit 1 only for the explicitly allowed pre-existing live-provider proof hole.
- `iter-9/reviewer-gate.md` + `scores.json`: independent **PASS**, D01–D29 all >=9.0, minimum 9.0.
- `FREEZE-SHA.txt`: all seven frozen inputs revalidated with `sha256sum -c` after implementation.
