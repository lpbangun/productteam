# Goal loop — ProductTeam Textual cockpit (owner-authorized)

Worktree: `/home/logani/.herdr/worktrees/Product Consulting Harness/exp-tui-migration`
Branch: `exp/tui-migration`
Mode: **Directive**. This prompt is the durable owner direction.

Copy everything below the line into a new Principal session in this worktree.

---

You are the Principal of the Product Consulting Harness in this worktree. Run the org loop until the Textual cockpit is a working optional frontend of the real CLI, or write a non-convergence report.

## Mission

Ship a **Textual 8.2.8 + Rich 15.0.0** cockpit as an optional presentation client of `bin/productteam`. Wire every chat-supported slash verb to the real command registry so the functions actually run. Match the visualizer we already built. Do not replace Bash as domain/state/process authority.

This is **not** another OpenTUI-vs-Textual spike. OpenTUI is closed. The 2026-08-12 spike deleted both prototypes after a broken freeze. Reuse only framework-neutral lessons and the visualizer. Do not revive `spikes/opentui/` or the deleted Textual tree.

## Why this is authorized

Owner explicit: implement the migration in this worktree, complete with wiring, so functionalities work. Architecture-change escalation is granted for this optional frontend only.

Prior evidence (do not re-litigate):
- Spike outcome: `delete-both` / non-convergence. Cause was frozen proxy mode 0444 and substring `agent` forbidding `agents --json`. Not a Textual loss.
- Static lean: Textual 812 LOC / 19 packages / ~39 MB vs OpenTUI 1371 / 111 / ~124 MB.
- Visualizer: `state/harness-evolution/runs/tui-migration-20260812/visualizer/index.html` served at `http://vmi3361268.tail16837d.ts.net:8788/`
- Live mock already maps the 32-command registry + chat-only verbs, with slash list docked **above the composer**.

## Canonical vs optional

Keep:
- `bin/productteam` Bash CLI as the only domain, judgment, workspace, provider, and durable-state authority.
- `productteam chat` readline REPL as the fallback interactive session (`lib/repl.sh`).
- Plain-file state under `state/`. No daemon, no database, no second writer.

Add:
- `productteam tui` — Textual cockpit. Optional. TTY required.
- `productteam chat` must **not** silently become the TUI in this loop. After TUI acceptance, a later owner step may alias. Not this goal.

Refuse nested `productteam chat` from inside the TUI (registry already marks `chat` unsupported in session).

## Visual spec (source of truth)

Implement the visualizer, not the empty 2026-08-12 tmux dumps.

**Look:** ruthless-minimal, mixed-case, two-accent, hairline separators. Futuristic = precision and negative space, not HUD.

Tokens (hex = ANSI 32/31):
| token | hex | use |
|---|---|---|
| canvas | `#0a0a0a` | field |
| field | `#141414` | composer + slash dock |
| rule | `#2a2a2a` | 1px hairlines |
| text | `#e4e4e4` | copy, caret |
| mute | `#737373` | idle roles, footer, pending |
| ok | `#22c55e` | score ≥9, live role, ✓, +diff, headings |
| err | `#ef4444` | ✗, ▲ escalate/Override, −diff, fail toast |

No Textual cyan `$primary`. No third hue. No sparkline, no boxed turns, no WORKERS title, no macOS chrome, no explainer rail. `NO_COLOR` / non-TTY: glyphs + bold/dim only.

CLI chrome from `lib/theme.sh` + `bin/productteam`:
- Roles: ◆ Principal, ◇ Analyst, ▸ Builder, ◉ Critic. Active worker = ok+bold; others mute.
- Status: ✓ done/success, ✗ failed, … running, ○ pending, ▲ escalate/Override.
- Modes: Guided/Directive/Challenge mute; Override = ▲ err.
- Markdown-lite from `lib/render.sh`: heading ok+bold, fences mute, verdicts bold, +/- ok/err, evidence paths bold.

**Layout (80×24 default; also 120×36, 60×24, 40×20):**
1. Header 1 line: `ProductTeam · {engagement} · {mode} · {score}`
2. Hairline
3. Transcript `1fr` — always seeded from real session / workers / last CLI output. Never a grey void.
4. Worker chips 1 row: `{badge} {role}` ; at 40 cols running chip + `+N`
5. **Slash dock** (hidden until `/` or overlay): sits **immediately above the composer**, like Codex/Pi. Transcript stays visible. Composer is the filter; do not duplicate the query in the dock.
6. Unlabelled multiline composer (`TextArea`)
7. Footer once: `enter send · tab complete · ↑↓ choose · esc close`

Overlays (evidence, permission/diff) use the same bottom dock. They never cover or undock the composer. Close restores composer focus and transcript scroll.

Toast: fail = err, interrupt = mute. Not a transcript line.

Widgets: Textual `Header`/`Static`, `RichLog`, `Horizontal` chips, dock `OptionList`/`Input` not required if composer is the filter, `TextArea`, native `Footer`, `App.notify`. Invert Textual Enter (Enter send, Shift+Enter newline).

## Wiring contract (the actual work)

The TUI is a presentation client. Every function that the CLI already owns must go through **argv arrays** to `bin/productteam`. No `shell=True`, no `eval`, no concatenating a command string.

Derive the palette from `productteam help --json` (contract `cli-interface-20260812-v3`). Do not hardcode a second verb list. If JSON and `lib/commands.sh` disagree, the CLI is right.

### Chat-supported — execute in the TUI

Run the real command, stream stdout/stderr into the transcript with markdown-lite, update worker chips from `state/.cli/runs/session-*/workers.tsv`.

`/help` `/status` `/agents` `/runtime` `/org` `/memory` `/report` `/bench` `/score` `/run` `/judge` `/checks` `/harness-checks` `/skill` `/gh` `/onboarding` `/splash` `/smoke`

Pass through args (`/report harness-cli`, `/score harness-cli --iter 1`, `/skill critique …`). Missing required args: print `usage` from the registry, do not guess.

### Chat-only — session local, same semantics as `lib/repl.sh`

`/provider [name]` cycle `AGENT_CATALOG` for this session only (`CONSULT_PROVIDER`)
`/workers` render the file-backed strip
`/clear` clear transcript (not state)
`/export` write markdown under `${STATE_ROOT}/sessions/` and print the path
`/exit` `/quit` leave the TUI, restore termios

### Chat-unsupported — refuse, do not run

Show mute reason + `use the CLI: {usage}` from `chat_reason`.

`/gate` `/inspect` `/workspace` `/direction` `/escalation` `/role` `/open` `/baseline` `/style` `/card` `/pool` `/project-memory` `/run-loop` `/chat`

Read-only *display* of gate/workspace/role **status** may use `productteam gate <client> status`, `workspace <client> status`, `role <client> status` as header/evidence projections. Never `direct`/`ensure`/`invoke`/`seal` from the TUI.

### Provider path

Bare composer text is a provider turn, same as `productteam chat`:
- `activity_start` / spinner fields / completion card
- process-group kill+reap on first Ctrl+C
- preserve partial artifact bytes
- mark worker failed
- second Ctrl+C exits 130 and restores termios
Reuse `lib/repl.sh` / `lib/activity.sh` / `lib/provider.sh` ownership. Do not reimplement a provider supervisor in Python.

### Header projections (read-only argv or files)

Engagement, mode (`engagement.md` Mode:), latest overall from `runs/iter-*/scores.json` via existing helpers, selected provider, gate status JSON, workspace status JSON. Poll/watch files; do not invent a bus.

## Code placement

- App: `lib/tui/` (Python). Dependencies pinned in `lib/tui/requirements.txt`: `textual==8.2.8`, `rich==15.0.0`. Venv local to `lib/tui/.venv`, gitignored.
- Entrypoint: `productteam tui` in `lib/commands.sh` registry, `chat_supported=0` (do not nest). Handler launches the venv python module.
- Adapter: argv-only subprocess to `bin/productteam` with `CONSULT_ROOT` / `CONSULT_STATE_ROOT` inherited.
- Do not edit `spikes/shared/` freeze files. That spike is closed.
- Do not vendor `node_modules`, `.venv`, `__pycache__`, `dist`.
- Preserve unrelated dirty worktree files (OFC check artifacts, etc.). Stop rather than overwrite.

`.gitignore` already excludes spike venvs; extend it for `lib/tui/.venv` and `__pycache__`.

## Loop (mandatory)

1. **Inspect.** Read `lib/commands.sh`, `lib/repl.sh`, `lib/theme.sh`, `lib/render.sh`, `lib/activity.sh`, `lib/provider.sh`, `bin/productteam` theme block, visualizer `index.html`, `tests/cli-interface-parity.sh`, `tests/visual-cli.sh`, spike `final-report.md` + `non-convergence-report.md`. Confirm Python 3.12 and that `productteam help --json` still emits 32 commands + chat_only.
2. **Benchmark (new, this loop).** Write `state/harness-evolution/runs/tui-cockpit-20260813/frozen-benchmark.md` **before any app code**. Freeze:
   - visual layout + two-accent + bottom slash dock
   - registry parity (help --json is the palette)
   - chat-supported verbs invoke real argv and show real output
   - unsupported verbs refuse with reason
   - provider Ctrl+C process-group + partial artifact
   - non-TTY: `productteam tui` exit 2, stderr `requires an interactive TTY`, empty stdout, no ESC under `NO_COLOR`
   - sizes 120×36, 80×24, 60×24, 40×20: header, transcript, chips, composer reachable; dock never covers composer
   - `tests/cli-interface-parity.sh` still PASS; `tests/visual-cli.sh` 14/14 (live-provider proof may still exit 1 for the pre-existing reason — do not “fix” by mocking)
   Dry-run the argv adapter against real `bin/productteam` (executable, not a 0444 proxy). Token-aware traces: allow `agents --json`; forbid shell strings / eval / sqlite.
   Critic must ACCEPT-FOR-FREEZE citing that dry run. Then hash. Then implement. No post-freeze benchmark edits.
3. **Prioritize + Critic debate** before build. Cuts: settings, theme picker, plugins, session search, OpenTUI, daemon, replacing `productteam chat`.
4. **Build** the cockpit to the freeze.
5. **Test.** Native pytest + Textual snapshots for layout/dock. PTY: slash filter `/sta` → `/status`; Enter runs real status; `/gate` refuses; `/provider` cycles; Ctrl+C reaps provider; Esc closes dock. Four sizes. CLI parity + visual-cli regression.
6. **Independent Analyst scores** the freeze. Critic verdict. If every mandatory dim ≥ 9 with citations, keep the TUI. Else non-convergence — delete `lib/tui/` and the registry entry, leave CLI untouched.

## Acceptance (done)

- `productteam tui` on a TTY shows the visualizer layout with real engagement data.
- Typing `/` opens the command list **above** the composer; prefix filter, ↑↓, Tab complete, Enter runs.
- Every chat-supported verb from `help --json` produces real CLI output in the transcript (not fixture copy).
- Every unsupported verb refuses with the registry reason and does not spawn the command.
- `/provider`, `/workers`, `/clear`, `/export`, `/exit` match REPL semantics.
- Bare text runs a real provider turn with worker chip + interrupt safety.
- Composer stays docked under palette/evidence/permission.
- Non-TTY refusal and `NO_COLOR` as specified.
- Canonical CLI tests still pass. No `productteam chat` rewrite.

## Forbidden

- OpenTUI, Ink, or a second framework.
- Replaying the 2026-08-12 freeze (`pty_driver.py` 0444 proxy, substring `agent` ban).
- Candidate-side bypasses of argv/trace rules.
- Durable writes except what the invoked CLI already writes (`/export` session markdown, provider artifacts).
- `productteam tui` as default for `chat` in this loop.
- Theme/settings/onboarding redesign beyond rendering existing `onboarding` output.
- Secrets in artifacts; force-merge; mocks of providers for the live path.

## Evidence

Write under `state/harness-evolution/runs/tui-cockpit-20260813/`: freeze, freeze sha, critic prebuild, tests, PTY notes, scores, critic verdict, diff-summary, lessons, final-report or non-convergence.

Stop when the cockpit is accepted or after one honest non-convergence. Do not start a third framework comparison.
