# Inspect — tui-cockpit-20260813

Recorded before any app code. No `lib/tui/` exists.

Worktree: `/home/logani/.herdr/worktrees/Product Consulting Harness/exp-tui-migration`
Branch: `exp/tui-migration`
Python: 3.12.3
`bin/productteam`: executable Bash CLI, sourced registry + REPL + theme + render + activity + provider.

## Live `help --json`

Command: `./bin/productteam help --json`

| field | live value |
|---|---|
| contract | `cli-interface-20260812-v3` |
| commands | 32 |
| chat_supported=true | 18 |
| chat_supported=false | 14 |
| chat_only | 6: `provider`, `workers`, `clear`, `export`, `exit`, `quit` |

Supported (execute in TUI via argv to `bin/productteam`):
`agents`, `bench`, `checks`, `gh`, `harness-checks`, `help`, `judge`, `memory`, `onboarding`, `org`, `report`, `run`, `runtime`, `score`, `skill`, `smoke`, `splash`, `status`

Unsupported (refuse with registry `chat_reason`; do not spawn):
`baseline`, `card`, `chat`, `direction`, `escalation`, `gate`, `inspect`, `open`, `pool`, `project-memory`, `role`, `run-loop`, `style`, `workspace`

There is no `tui` command yet. `productteam help` does not mention tui.

## Citations

### Registry — `lib/commands.sh`

- Header names contract `cli-interface-20260812-v3` (lines 1–6).
- `cmd_reg_add` schema: name aliases usage summary min_args handler chat_supported chat_reason (line 16).
- Frozen membership comment: 32-command table; 18 chat_supported; 14 chat_reason (lines 22–24).
- `CMD_CHAT_ONLY=(provider workers clear export exit quit)` (line 60).
- `cmd_help_json` emits `{contract, commands[{name,usage,chat_supported,chat_reason?}], chat_only}` (lines 108–121).
- No `tui` row. Adding `productteam tui` is new registry work (`chat_supported=0`).

### Dispatch — `bin/productteam`

- Theme sole ANSI literals: TTY and no `NO_COLOR` → bold/dim/reset + `G=$'\e[32m'` + `RD=$'\e[31m'`; else empty (lines 16–22). Two accents only; hex mapping is visualizer `#22c55e` / `#ef4444`.
- Sources `lib/provider.sh`, `lib/theme.sh`, `lib/activity.sh`, `lib/commands.sh`, `lib/repl.sh`, `lib/render.sh` before handlers (lines 24–32).
- `main()` looks up `cmd_reg_index`, enforces `REG_MIN`, invokes `"$REG_HANDLER" "$@"` as argv — no eval (lines 1421–1432).
- `dispatch_judge` / `dispatch_bench` stay wrappers around existing handlers (lines 1402–1418).

### Chat slash map — `lib/repl.sh`

- Palette derived from registry `REG_CHAT==1` plus `CMD_CHAT_ONLY` (lines 25–46). Fallback list matches the 18+6 membership.
- Session-local verbs (lines 391–442):
  - `/clear` — clear screen + reprint header; not durable state
  - `/exit` `/quit` — return 99, leave session
  - `/export` — write `${STATE_ROOT}/sessions/chat-<ts>.md`, print path
  - `/provider [name]` — set or `runtime_cycle` `CONSULT_PROVIDER` for this session
  - `/workers` — `activity_strip` over file-backed TSV
- Unsupported registry verbs print `unknown /verb — /help` plus `REG_REASON` and do not call the handler (lines 443–454).
- Supported verbs check `REG_MIN`, then run `"$REG_HANDLER" "${argv[@]}"` in a subshell (lines 455–464).
- Bare text → `repl_ask` → `provider_ask` in a job-control process group; first Ctrl+C `kill -TERM -- "-$pid"`, preserve artifact bytes, mark worker failed; session stays alive (lines 227–256, 291–356).
- `cmd_chat` requires TTY on stdin and stdout (lines 473–476). Nested `productteam chat` is already `chat_supported=0`.

### Theme / render / activity / provider

- `lib/theme.sh`: glyphs `◆ Principal`, `◇ Analyst`, `▸ Builder`, `◉ Critic`; status `✓ ✗ … ○ ▲`. Active = success+bold; idle = dim.
- `lib/render.sh`: markdown-lite — heading ok+bold, fences mute, verdicts bold, `+/-` ok/err, evidence paths bold. Degrades under `NO_COLOR`.
- `lib/activity.sh`: `state/.cli/runs/session-*/workers.tsv` columns `id role state mission provider start elapsed artifact`. Atomic temp+rename. Not a supervisor.
- `lib/provider.sh`: `AGENT_CATALOG=(agent claude codex opencode gemini cursor droid aider goose crush amp copilot plandex qwen)`. Session provider is `CONSULT_PROVIDER`.

### Visualizer — look + slash map

Path: `state/harness-evolution/runs/tui-migration-20260812/visualizer/index.html`

Tokens (CSS `:root`): canvas `#0a0a0a`, field `#141414`, rule `#2a2a2a`, text `#e4e4e4`, mute `#737373`, ok `#22c55e`, err `#ef4444`.

Layout grid: header → 1px rule → transcript `1fr` → worker chips → dock → unlabelled composer → footer.

Header live markup: `ProductTeam · {engagement} · {mode} · {score}` (`agcode-learning`, Directive, 9.5).

Footer: `enter send · tab complete · ↑↓ choose · esc close` (visualizer also shows `^e evidence`; cockpit footer spec is the four keys).

Sizes: 120×36, 80×24 (default), 60×24, 40×20. At 40 cols, engagement clip + running chip `+N`.

`VERBS` array maps the 32-command registry + 6 chat-only verbs with `chat` 0/1 and refuse reasons. Palette docks **above** the composer; composer is the filter.

Toast: fail = err, interrupt/export = mute. Not a transcript line.

No sparkline, no boxed-turn chrome title, no WORKERS heading, no third hue.

### Prior spike — why delete-both, not Textual loss

Dir: `state/harness-evolution/runs/tui-migration-20260812/`

- `final-report.md`: no winner; both prototypes deleted. Cause = frozen benchmark, not framework inferiority.
- `non-convergence-report.md`: (1) generated proxy chmod 0555 then recursive 0444 so required seams cannot exec; (2) substring `agent` ban rejects required `agents --json`.
- `critic-final-verdict.md`: same two contradictions in `spikes/shared/pty_driver.py` lines 176 and 189–190, plus `audit_trace_text` forbidden tuple including `"agent"` at line 105 while required seams include `("agents", "--json")` at line 361.
- Static lean (prioritization only): Textual 812 LOC / 19 pkgs / ~39 MB vs OpenTUI 1371 / 111 / ~124 MB.
- OpenTUI is closed. Do not revive `spikes/opentui/` or the deleted Textual tree. Do not edit `spikes/shared/`.

### Canonical tests (must still pass after TUI)

- `tests/cli-interface-parity.sh`: D6a derives 32/18/14/6 from live `help --json` and cross-checks frozen chat_only. Adding `tui` as a 33rd registry command will require the parity table to know about it — handle inside the freeze, do not silently break the 32-command contract.
- `tests/visual-cli.sh`: 14/14 visual checks; overall exit 1 is allowed for the pre-existing missing live-provider proof. Do not “fix” by mocking the provider.

### Dirty tree to preserve

- `M .gitignore` — already adds spike venv/node_modules ignores. Extend later for `lib/tui/.venv` only.
- `?? spikes/` — closed spike fixtures. Do not edit `spikes/shared/`.
- `?? state/harness-evolution/runs/tui-migration-20260812/` — prior evidence + visualizer. Leave intact.

### Header read-only projections (allowed)

Engagements present under `state/engagements/`: `agcode-learning`, `harness-cli`, `onboarding-flight-control`, `osint-loop-research`, `overnight-rehearsal`.

Read-only status argv permitted later: `productteam gate <client> status`, `workspace <client> status`, `role <client> status`. Never `direct` / `ensure` / `invoke` / `seal` from the TUI.

## Inspect conclusion

Live registry still matches the owner contract. Visualizer is the look + slash map. Prior freeze is unsafe to replay. Ready for reviewer to write a **new** freeze under this directory, dry-run argv against the **executable** `bin/productteam`, ACCEPT-FOR-FREEZE, then hash. No app code until that hash exists.
