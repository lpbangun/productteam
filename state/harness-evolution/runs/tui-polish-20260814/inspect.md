# Inspect — TUI polish 2026-08-14

Status: pre-freeze inspection complete. No `lib/tui/`, snapshot, registry, or app-code edits were made during inspection.

## Sources read in required order

1. Locked visualizer: `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`
2. Current cockpit: `lib/tui/app.py`, `theme.py`, `adapter.py`, `session.py`, `provider_turn.sh`, `__main__.py`
3. Native tests and current SVG snapshots under `lib/tui/tests/`
4. Canonical Bash seams: `lib/commands.sh`, `repl.sh`, `theme.sh`, `render.sh`, `activity.sh`, `provider.sh`, `agent-cards.sh`, `splash.sh`
5. Prior ship evidence: `state/harness-evolution/runs/tui-cockpit-20260813/{final-report.md,frozen-benchmark.md,lessons.md}`
6. Canonical gates: `tests/cli-interface-parity.sh`, `tests/visual-cli.sh`

The locked visualizer—not the 2026-08-13 snapshots—is the polish target.

## Confirmed shipped baseline

- `lib/tui/requirements.txt`: `textual==8.2.8`, `rich==15.0.0`.
- `lib/tui/.venv/bin/python --version`: Python 3.12.3.
- Installed packages: Textual 8.2.8, Rich 15.0.0.
- `bin/productteam` mode: 0775.
- Live `productteam help --json`: contract `cli-interface-20260812-v3`, 33 commands / 18 supported / 15 unsupported / 6 chat-only.
- Registry `tui`: usage `productteam tui`, `chat_supported=false`, non-empty TTY/nesting reason.
- `cmd_tui` is isolated in `bin/productteam`; `lib/repl.sh` contains no TUI launch path. `productteam chat` remains the Bash REPL.
- Adapter already uses argv arrays, `shell=False`, the real executable, and a whole-token deny set that permits `agents --json`.
- Non-TTY refusal already specifies exit 2, empty stdout, the interactive-TTY remedy, and no color escapes.

## Residual defects against the locked contract

### Layout, home, header

- `app.py:_seed` runs both `status --json` and full prose `status`, then writes the prose into the transcript. Current snapshots contain `run-loop-*` and smoke rows.
- `_pick_engagement` explicitly prefers `harness-cli`; home is not a filtered three-row scored-session projection.
- `_render_header` renders `ProductTeam · {engagement} · {mode} · {score}`. Current snapshots show `harness-cli` and `Directive`; there are no `▣─▣─▣` heads, cwd projection, active pulse, or explicit `ProductTeam {score}` 40-column header.
- `on_resize` only rerenders chips. There is no compact-mode state or live 80→40→80 proof.

### Turns, roles, targeting

- Bare Enter records a user turn but `_echo` writes plain unstyled text. There is no gray 2px You rail, mute label, or timestamp.
- Provider output is streamed as unowned lines. No role-colored label/rail starts when speech begins; completion is a detached line.
- `theme.py` defines only neutral + ok/err colors; `role_tag` makes any active role green. Locked Principal/Analyst/Builder/Critic identity hues are absent.
- Chips are a file-backed status display, not focusable/clickable target controls. Composer has no `@Role`; idle target state is absent.
- `_provider_thread` launches `provider_turn.sh ROOT PROMPT` with no role. `provider_turn.sh` hardcodes `activity_start Analyst`; `_provider_done` hardcodes Analyst.
- `provider_turn.sh` does not source `lib/agent-cards.sh` or prepend the selected role's `prompt_export` / `agent_card_prompt_block` content.

### Activity and honest speech

- The app polls `workers.tsv` into chips only. There is no dedicated activity strip, braille spinner, elapsed `m:ss`, provider fact, or width cap of 3/2/1+N.
- Silent work therefore has no locked-contract surface. There is no explicit assertion preventing `Thinking…` or a fake agent turn before artifact text.
- Footer is static (`enter send · tab complete · ↑↓ choose · esc close`) and does not switch among idle, busy, ask, slash, and evidence facts.

### Docks and evidence

- The existing `OptionList` dock handles slash filtering only.
- No structured ask schema/event consumer, file-backed `ask.json` control seam, single/multi selection, recommendation, descriptions, `k of n`, or ask key handling.
- No confirm interception for `/gh merge`, `/checks --allow-dirty`, or `/onboarding --yes`; supported writes currently run immediately through `_exec_cli`.
- No bordered evidence panel. `/report` and `/bench` stream long file lists directly into the transcript.
- Slash command request/output/refusal are plain lines, not mute Command rails. Session verbs add transcript lines rather than locked mute toasts where required.

### Splash and polish state

- No TUI-owned splash widget or angular ASCII heads. `/splash` invokes the canonical six-node Bash graph as a Command turn.
- No any-key boot skip, idle-neutral splash, or Principal→Analyst→Builder→Principal live glow cycle while composer/footer remain visible.
- Fail and interrupt use Textual notifications, but cards remain detached/plain and role identity is hardcoded.

### Tests and snapshots

- `test_two_accents_only_in_css_and_theme` forbids the owner-locked cockpit role hues; it needs a cockpit-only identity allowance while retaining a separate Bash two-accent assertion.
- Existing native tests cover argv safety, slash routing, four static sizes, non-TTY, and interrupt. They do not cover filtered home, You/role turn chrome, role argv/card prompt, activity-vs-speech, ask, confirm, evidence, TUI splash, busy/footer states, or live SIGWINCH 80→40→80.
- Current `cockpit-80x24.svg` shows `harness-cli`, `Directive`, and a detached `✗ ◇ Analyst` line.
- Current `palette-80x24.svg` shows full status prose including excluded `run-loop-*` smoke engagements.

## Constraints carried into freeze

Keep Bash as authority; no second supervisor, daemon, database, framework, provider mock, transcript scraping, determinate fake progress, project picker, settings/theme/plugin/search work, `spikes/shared/` edit, 2026-08-12 freeze replay, or deletion of the shipped cockpit on polish failure.
