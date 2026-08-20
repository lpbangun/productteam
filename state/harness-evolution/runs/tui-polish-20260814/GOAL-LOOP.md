# Goal loop — ProductTeam TUI polish (owner-authorized, overnight)

Worktree: `/home/logani/.herdr/worktrees/Product Consulting Harness/exp-tui-migration`
Branch: `exp/tui-migration`
Mode: **Directive**. This prompt is the durable owner direction.
Model: **session default**. Do not pin a named model. Task subagents inherit default.

Copy everything below the line into a new Principal session in this worktree. Do not create a nested Goal. This *is* the Goal.

---

You are the Principal of the Product Consulting Harness in this worktree. Use the **session default model**. Do not select, name, or switch models. Run the org loop overnight until `lib/tui/` matches the locked cockpit, or stop after five implementation iterations and write non-convergence.

This is polish of the already-shipped optional Textual cockpit. Wiring already exists. Visual polish and remaining honest seams do not. Do not rebuild the TUI. Do not start a framework bake-off. Do not replace Bash.

## Mission

Make `productteam tui` look and behave like the locked visualizer, and finish the backend seams the live cockpit still fakes or skips, so the functions actually work.

Visual source of truth (locked, no alternatives):

- File: `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`
- URL: `http://vmi3361268.tail16837d.ts.net:8788/locked/?v=1`

Prior ship (do not re-litigate, do not delete on polish failure):

- `productteam tui` already exists in `lib/tui/` (Textual 8.2.8 + Rich 15.0.0).
- Evidence: `state/harness-evolution/runs/tui-cockpit-20260813/` — KEEP, mandatory dims ≥ 9.0.
- `productteam chat` is unchanged and must not launch the TUI.
- OpenTUI is closed. `spikes/opentui/` and the deleted spike Textual tree stay deleted.
- Do not edit `spikes/shared/` or replay the 2026-08-12 0444-proxy freeze.

If this polish does not converge: leave the shipped 2026-08-13 cockpit in place. Write `not-converged.md`. Do **not** delete `lib/tui/` or the `tui` registry row.

## Org (overnight, default model)

Permanent roles remain Principal / Analyst / Builder / Critic (`AGENTS.md`). Do not invent new permanent workers.

Operationally spawn **task subagents** only, as needed:

| spawn | agent | duty | writes |
|---|---|---|---|
| Advisor (once) | `task` | Benchmark Designer. Freeze the polish contract from the locked visualizer **before any app edit**. | freeze files only |
| Freeze Critic (once) | `critic` if available, else `task` | ACCEPT-FOR-FREEZE or REJECT. Read-only. | `reviewer-prebuild.md` only |
| Worker (per iter, one at a time) | `task` | Implement the accepted slice. Smallest diff. Attach a check. | `lib/tui/**` and tests named in freeze |
| Reviewer (per iter) | `critic` if available, else `task` | Independent scores against the freeze. Read-only. Must not edit app code. | `iter-N/reviewer-gate.md`, scores |

Principal (this session, default model) owns: inspect, test execution, iteration reports, stop/go. You may do small mechanical edits yourself. Spawn a Worker for any non-trivial slice.

Rules that keep an overnight loop alive:

1. **One Writer.** Never two Workers on `lib/tui/` at once. Prior Worker timed out at 30 minutes after writing the tree; do not relaunch a second writer on the same cwd.
2. **Principal runs the long tests.** pytest, PTY, `tests/cli-interface-parity.sh`, `tests/visual-cli.sh`. Workers skip project-wide formatters/linters/full suites; they may run a single targeted pytest file.
3. **Advisor freeze first.** No `lib/tui/` edits, no snapshot refreshes, no registry edits until `FREEZE-SHA.txt` exists.
4. **Stop at first all-pass**, or after **5** implementation iterations (iter-1 … iter-5). Then stop. Do not keep going. Do not call it done.
5. Subagents inherit the **default** model. Do not pin a slug.

## Why the live cockpit is unfinished

Read these, then the locked page. Do not trust the 2026-08-13 snapshots as the visual target.

Current defects (must be closed or honestly failed):

- Home seeds by dumping full `productteam status`, including smoke / run-loop engagements. Header shows `harness-cli` and `Directive`.
- Enter echoes unstyled text. No You rail, no role-colored turn, no markdown-lite on the speaking turn.
- `lib/tui/provider_turn.sh` hardcodes `activity_start Analyst`. Completion card hardcodes Analyst. Role is not argv.
- No activity strip. Silent work has nowhere honest to live, so it will leak into the transcript.
- No explicit 40-col mode. `on_resize` only re-renders chips. No SIGWINCH 80→40→80 proof.
- No OMP ask dock. No confirm dock. No bordered evidence panel.
- No futuristic splash. `/splash` still hits the CLI six-node graph.
- Footer is one static hint line. Busy facts (interrupt, elapsed, provider) are missing.
- Chips are not a target control. Composer has no `@Role`. Idle default is not Principal.
- `lib/tui/theme.py` still forbids role hues; `tests/test_layout.py` `test_two_accents_only_in_css_and_theme` will fail the owner-locked identity colors unless the freeze amends that test for the **cockpit only**. Canonical Bash CLI accent budget stays two hues.

## Canonical vs optional (unchanged)

Keep:

- `bin/productteam` as the only domain, judgment, workspace, provider, and durable-state authority.
- `productteam chat` (`lib/repl.sh`) as the fallback interactive session.
- Plain-file state under `state/`. No daemon, no database, no second writer.
- Pins: `textual==8.2.8`, `rich==15.0.0`, Python 3.12. Venv `lib/tui/.venv`, gitignored.

Add / finish:

- Visual polish of `productteam tui` to the locked page.
- Honest argv / file / activity / role seams listed below.

Refuse:

- Nested `productteam chat` or `/tui` from inside the TUI.
- Making `chat` launch the TUI.
- OpenTUI, Ink, a second framework, a rewrite of domain modules.

## Locked contract the Advisor must freeze

Copy these into `frozen-benchmark.md` as normative. Do not weaken. Do not re-open alternatives. The HTML mock is the picture; the freeze is the testable contract.

### Layout

header / transcript `1fr` / activity (only while work is live) / chips / dock-above-composer / composer / footer.

Overlays never cover the composer. Close restores composer focus.

### Tokens (cockpit)

Owner-locked override for the Textual cockpit only. Body text stays neutral.

| token | hex | use |
|---|---|---|
| canvas | `#0a0a0a` | field |
| field | `#141414` | composer + docks |
| rule | `#2a2a2a` | hairlines |
| text | `#e4e4e4` | copy, caret |
| mute | `#737373` | idle, footer, pending, Command |
| you | `#8a8a8a` | You label + 2px rail |
| principal | `#c084fc` | ◆ Principal label, rail, chip |
| analyst | `#60a5fa` | ◇ Analyst |
| builder | `#22c55e` | ▸ Builder |
| critic | `#f59e0b` | ◉ Critic |
| ok | `#22c55e` | score ≥9, ✓, +diff, headings, live glow |
| err | `#ef4444` | ✗, fail toast, −diff |

No Textual cyan `$primary`. No extra hues. Bash CLI (`bin/productteam`, `lib/theme.sh`, `chk_cli_accent_budget`) stays two accents. `NO_COLOR`: glyphs + bold/dim only.

Glyphs from `lib/theme.sh`: `◆ Principal` `◇ Analyst` `▸ Builder` `◉ Critic`. Status: `✓` `✗` `…` `○` `▲`.

### Product locks

1. **Q1 home.** At most three recent scored sessions for this directory (or three distinct global scored projects). Exclude `*smoke*` `*run-loop*` `*gate-smoke*` `*overnight-rehears*`. Never seed full `productteam status`. Display only (R8). Header follows cwd. No project picker.
2. **Q2 identity.** You: gray 2px rail + mute label. Principal/Analyst/Builder/Critic: role-colored label + 2px rail + chip. Body text neutral. Not an 11ch gutter. Not two-accent-only in the cockpit.
3. **Q3 header.** `▣─▣─▣ ProductTeam · {cwd project} · {score}`. Middle head pulses while work is active. ≤40 cols: `ProductTeam {score}` — drop heads and directory. Never put `harness-cli` or `Directive` in the bar.
4. **Q4 work.** Braille spinner on the live activity line + elapsed `m:ss`. No determinate progress bar.
5. **Q5 compact.** Explicit 40-col mode, not wrapping. Prove 120×36 / 80×24 / 60×24 / 40×20 and live SIGWINCH 80→40→80. Composer stays.
6. **Q6 ask.** OMP-style dock above composer: exact question, labels, descriptions, recommended, single/multi, `k of n`, ↑↓, Space, Enter, Esc. The question is a real colored agent turn. Composer stays below. **Do not scrape prose.** Consume a structured ask event (schema in the freeze). If the installed provider already emits that schema, wire it. If it does not, pytest must still prove the dock via a file-backed control event (`ask.json` beside the provider artifact, or an equivalent existing seam). Inventing a second provider supervisor fails this dim. Faking questions from transcript text fails this dim.
7. **Thinking vs speech.** Silent work lives in the activity strip from real `workers.tsv` (`lib/activity.sh` columns: `id role state mission provider start elapsed artifact`). A colored transcript turn begins only when that role emits text. Never render `Thinking…` as a message.
8. **R1 markdown.** Markdown-lite inside speaking turns (`lib/tui/theme.py` / `lib/render.sh`): heading ok+bold, fences mute, `+/-` ok/err, evidence path bold. Body otherwise neutral.
9. **R2 slash.** Palette docks above composer. Composer is the filter. Run / refuse / usage are mute Command rails, never a role color. Unsupported verbs refuse with `chat_reason` + usage and do not spawn.
10. **R3 evidence.** Bordered labelled evidence panel, distinct from chat. Summary stays a Command turn. Long `/report` `/bench` file lists do not drown the transcript.
11. **R4 confirm.** Confirm dock before chat-supported writes: `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes`. Cancel spawns nothing. Other mutations stay refused.
12. **R5 toasts.** Done = card on the turn. Fail/interrupt = toast + error card. Session verbs (`/export`, provider cycle) = mute toast. Not extra transcript lines.
13. **R6 footer.** Idle = hints (`enter send · / commands · tab agents`). Busy = facts (`ctrl+c interrupt · m:ss · {provider}`). Ask/slash replace hints while those docks are open.
14. **R7 splash.** Futuristic angular line-art heads, once, then cockpit. Idle all-neutral. Live-boot glow cycles **Principal → Analyst → Builder → Principal** (one at a time). Ships as ASCII in Textual. Not the six-node `lib/splash.sh` graph. Not `ROBOTS_MARK` half-blocks in `lib/repl.sh` (those distort). Composer and footer stay visible during splash. Any key skips.
15. **Target.** Chips focusable/clickable. Composer shows `@Role`. Session-local. Idle home defaults to **@Principal**. Pass role as argv to `provider_turn.sh`. Use `state/agents/` `prompt_export` (`lib/agent-cards.sh` / `agent_card_prompt_block`). Stop hardcoding Analyst.
16. **Defaults.** Dim timestamps on turns. Copy is a session verb, not chrome. High-contrast is these tokens.

### Backend wiring the freeze must require (this is the umbrella)

Keep argv-only. Token-aware traces: allow `agents --json`; forbid `/bin/sh` `/bin/bash` `eval` `sqlite` `sqlite3`. No `shell=True`. No 0444 proxy. Dry-run against the real executable `bin/productteam`.

| seam | honest path |
|---|---|
| Palette | live `productteam help --json`. No second verb list. |
| Supported slash | argv array to `bin/productteam`; stream real stdout with markdown-lite as a mute Command turn |
| Unsupported slash | `chat_reason` + usage; argv log shows no spawn |
| Chat-only | `/provider /workers /clear /export /exit /quit` match `lib/repl.sh` |
| Home | scored sessions from files / `status --json` **filtered**; never dump `status` text into the transcript |
| Header score | latest `runs/iter-*/scores.json` overall for the cwd project; never Mode/Directive |
| Activity | poll `state/.cli/runs/session-*/workers.tsv`; cap 3 rows at 80, 2 at 60, 1+`+N` at 40 |
| Provider turn | `provider_turn.sh ROOT PROMPT ROLE`; `activity_start "$ROLE"`; prepend `prompt_export` for that role; process-group Ctrl+C unchanged |
| Ask | structured event only (see Q6) |
| Confirm | intercept write verbs before `run_argv`; Run then argv; Cancel no spawn |
| Evidence | parse report/bench file paths into the bordered panel; do not dump the full list as chat |
| Splash | TUI-owned ASCII; `/splash` CLI verb may still run the real command as a Command turn after skip/finish |
| Non-TTY | exit 2, stderr `requires an interactive TTY`, empty stdout, no ESC under `NO_COLOR` |

Do not reimplement a provider supervisor in Python. Reuse `lib/repl.sh` / `lib/activity.sh` / `lib/provider.sh` / `lib/agent-cards.sh`.

### Tests the freeze must name

Principal runs these every implementation iteration. First all-pass stops the loop.

| check | pass rule |
|---|---|
| Native pytest + snapshots | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` green. Snapshots match locked chrome (header without harness-cli/Directive; home three scored rows or empty; dock above composer). Role hues allowed in cockpit CSS. Bash CLI accent tests unchanged. |
| Home seed | transcript does not contain a full `productteam status` dump; excluded name patterns absent |
| Turn chrome | Enter of bare text writes a You turn (gray rail), not unstyled dump |
| Role argv | `provider_turn.sh` receives ROLE; `activity_start` is not hardcoded Analyst; a chip/composer `@Builder` turn records Builder in `workers.tsv` |
| Activity vs speech | while a worker is running with empty artifact, transcript has no `Thinking…` and no fake agent message |
| Ask dock | fixture `ask.json` (or freeze-named equivalent) opens OMP dock above composer; Esc closes; composer remains |
| Confirm | `/gh merge` opens confirm; Cancel does not spawn; argv log empty for that attempt |
| Evidence | a long `/report` keeps summary as Command turn and files in the bordered panel |
| PTY slash | `/` opens dock; `/sta` filters; Enter runs real `status`; `/gate` refuses and does not spawn gate |
| PTY sizes + SIGWINCH | 120×36, 80×24, 60×24, 40×20 reachable chrome; ioctl 80→40→80: 40-col header is `ProductTeam {score}`, composer stays, restore 80 restores heads |
| Provider interrupt | first Ctrl+C reaps process group, keeps partial artifact, worker `failed`; second Ctrl+C → 130 + termios restored |
| `tests/cli-interface-parity.sh` | PASS (33/18/15/6 already shipped; do not revert) |
| `tests/visual-cli.sh` | 14/14 visual ids. Overall exit 1 allowed **only** for the pre-existing missing live-provider proof. Do not mock the provider. |

Refresh snapshots as evidence of the new chrome. Do not weaken needles. Isolate per-invocation transcript deltas (2026-08-13 lesson: grepping the whole log false-passes).

`CONSULT_NO_SPLASH=1` hides CLI splash; unset only when testing `/splash` or the TUI boot splash.

## Loop (mandatory)

### 0. Inspect (this session)

Read, in order:

- `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`
- `lib/tui/{app.py,theme.py,adapter.py,session.py,provider_turn.sh,__main__.py}`
- `lib/tui/tests/*` and current snapshots
- `lib/{commands.sh,repl.sh,theme.sh,render.sh,activity.sh,provider.sh,agent-cards.sh,splash.sh}`
- `state/harness-evolution/runs/tui-cockpit-20260813/{final-report.md,frozen-benchmark.md,lessons.md}`
- `tests/cli-interface-parity.sh`, `tests/visual-cli.sh`

Confirm Python 3.12, pins, `productteam tui` already registered `chat_supported=0`. Record residual defects in `state/harness-evolution/runs/tui-polish-20260814/inspect.md`.

Do not edit app code in this step.

### 1. Advisor freeze (task subagent, before any app code)

Spawn Advisor with this exact job: write

`state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md`

from the locked contract above. Include scoring dimensions (mandatory, every one ≥ 9.0 to accept polish), the test table, argv dry-run requirement against the **real executable**, and cuts.

Cuts (implementing any fails the gate):

- settings, theme picker, plugins, session search
- OpenTUI / Ink / second framework
- replacing `productteam chat` or making it launch the TUI
- daemon / database / second state writer
- editing `spikes/shared/` or the 2026-08-12 freeze
- deleting `lib/tui/` on polish failure
- overwriting unrelated dirty worktree files
- scraping prose for ask-back
- determinate fake progress bars
- `ROBOTS_MARK` half-blocks or the six-node graph as the TUI splash

Then spawn Freeze Critic. It must ACCEPT-FOR-FREEZE citing a fresh argv dry-run (`argv-dry-run/` against `bin/productteam` mode executable, including `agents --json`) **or REJECT**. No post-freeze rubric edits.

On ACCEPT, hash:

```
sha256sum frozen-benchmark.md > FREEZE-SHA.txt
```

plus any freeze inputs the Advisor listed. Then implement. Never move the goalposts.

Worker must **not** freeze or score.

### 2–6. Implementation iterations (max 5)

Each iteration:

1. Principal proposes the smallest slice that the last Reviewer (or freeze) said is failing. Critic may rebut; contested items need a named benchmark lift.
2. Spawn **one** Worker `task` subagent. Point it at exact files. Tell it to skip formatters/linters/full suites.
3. Principal runs the freeze test table. Write `iter-N/{pytest.txt,cli-interface-parity.txt,visual-cli.txt,pty-note.md,notes.md}`.
4. Spawn Reviewer read-only. Scores every mandatory dim 0–10 one decimal, each citation a path or command result. Missing evidence = 0.
5. If **every** mandatory dim ≥ 9.0: KEEP polish, write `final-report.md`, stop.
6. Else: next iter, or stop at iter-5 with `not-converged.md` naming failing dims and commands.

Do not start iter-6.

## Code placement

- App stays in `lib/tui/`. Pins stay `textual==8.2.8` `rich==15.0.0`.
- Role hues live in `theme.py` and cockpit CSS. Update `test_two_accents_only_in_css_and_theme` to allow the owner-locked identity set **in the cockpit**. Add or keep a separate assertion that Bash CLI sources still have only ok/err hues.
- `provider_turn.sh` signature becomes `ROOT PROMPT ROLE`. Default ROLE if missing: Principal (not Analyst).
- Preserve unrelated dirty files (OFC check artifacts, spike evidence, `.gitignore`). Stop rather than overwrite.
- Do not vendor `.venv`, `__pycache__`, `node_modules`.

## Forbidden (voids the iteration)

- Pinning a non-default model
- Two writers on `lib/tui/`
- OpenTUI / Ink / framework bake-off
- Replaying `spikes/shared/pty_driver.py` 0444 proxy or substring `agent` ban
- Candidate-side argv/trace bypasses
- Provider mocks for the live path
- Secrets in artifacts
- Making tui the default for chat
- Theme/settings redesign
- Inventing extra permanent org roles
- Scraping transcript prose to fake ask-back
- Calling polish done without Reviewer citations
- Deleting the 2026-08-13 cockpit because polish missed 9.0

## Evidence this run must leave

Under `state/harness-evolution/runs/tui-polish-20260814/`:

- `inspect.md`
- `argv-dry-run/` (fresh, executable CLI, token-aware, `agents --json` allowed)
- `frozen-benchmark.md`
- `reviewer-prebuild.md` (ACCEPT-FOR-FREEZE or REJECT)
- `FREEZE-SHA.txt`
- `iter-N/` tests, PTY notes, scores, reviewer gate
- `diff-summary.md`, `lessons.md`, `final-report.md` **or** `not-converged.md`

Reference visualizer for humans and for Reviewer: the locked page, not v2–v6 galleries (those were decision pages).

## Acceptance (done)

- `productteam tui` on a TTY matches the locked frames: splash (if shown), home of three scored rows, You/role chrome, activity for silent work, markdown-lite speech, completion cards, slash/evidence/confirm/ask docks above the composer, 40-col compact, idle/busy footer.
- Header is `▣─▣─▣ ProductTeam · {cwd} · {score}` with no `harness-cli` and no `Directive`.
- Bare text targets `@Principal` by default; chip/`@Role` changes the argv role; `workers.tsv` records that role; Analyst is not hardcoded.
- Every chat-supported verb still produces real CLI output. Unsupported verbs still refuse. Canonical CLI tests still pass. Chat still does not launch the TUI.
- Reviewer cites every mandatory dim ≥ 9.0, or `not-converged.md` is written and the shipped cockpit remains.

Stop. Do not open a sixth iteration. Do not start a third frontend.
