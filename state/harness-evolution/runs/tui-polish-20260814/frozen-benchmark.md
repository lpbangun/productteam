# ProductTeam TUI polish — frozen benchmark

**Status:** FROZEN BEFORE APP EDITS  
**Run:** `tui-polish-20260814`  
**Authority:** `state/harness-evolution/runs/tui-polish-20260814/GOAL-LOOP.md` is the owner contract. The locked visualizer is the visual source of truth; this benchmark is its testable transcription. It is normative, not a proposal. There are no alternatives to choose and no post-freeze rubric edits.

## 1. Scope and non-negotiable ownership

This benchmark governs polish of the already-shipped optional Textual cockpit exposed by `productteam tui`. It does not authorize a rebuild, framework comparison, or replacement of Bash. The cockpit is a presentation client of `bin/productteam` and plain files:

- `bin/productteam` remains the only domain, judgment, workspace, provider, and durable-state authority.
- Plain files under `state/` remain the state authority. There is no second writer, daemon, database, or provider supervisor in Python.
- `productteam chat` remains the Bash REPL and must not launch the TUI. The TUI must not launch nested `productteam chat` or `/tui`.
- The shipped 2026-08-13 cockpit is retained if this polish fails to converge. A failed run writes `not-converged.md`; it never deletes `lib/tui/` or the `tui` registry row.
- Permanent roles remain **Principal / Analyst / Builder / Critic**. The session default model is used; no named model may be selected or pinned.
- Existing pins remain `textual==8.2.8`, `rich==15.0.0`, Python 3.12, and `lib/tui/.venv`.
- This file is the sole deliverable of the prebuild Advisor task. No app, test, snapshot, registry, Bash module, prior-run artifact, or unrelated file is part of this change.

## 2. Locked layout and visual states

### 2.1 Global layout

The vertical order is exactly:

```text
header / transcript 1fr / activity (only while work is live) / chips /
dock-above-composer / composer / footer
```

The transcript owns the flexible `1fr` area. The activity strip is absent while idle and present only while work is live. Chips are below activity. Ask, slash, evidence, and confirm overlays are docks **above** the composer; no overlay may cover, replace, or obscure the composer. Closing any overlay restores composer focus.

### 2.2 Locked dimensions and frames

The implementation and evidence must make these locked states reachable, with the composer present in every state where the visualizer shows it:

- **Boot / R7:** a TUI-owned futuristic angular ASCII line-art heads splash appears once, then the cockpit. Idle boot is all-neutral. During live boot, the glow cycles one head at a time **Principal → Analyst → Builder → Principal**. The live subtitle identifies the glowing head. Composer and footer remain visible. Any key skips. `/splash` may still run the real CLI command as a mute Command turn after boot/skip, but the TUI boot is not the Bash graph.
- **Open / idle home:** header, hairline, display-only home rows, role chips, composer, idle footer; no activity strip. Show at most three recent scored sessions for this directory, or three distinct global scored projects. If none exist, show the honest no-scored-sessions state; never show a full status dump.
- **Thinking:** the user's prompt is a You turn; silent workers appear only in the activity strip, with braille spinner, role, real mission/provider fact, and elapsed time. No fake agent turn and no `Thinking…` transcript message.
- **Speaking:** a colored role turn starts only when that role emits text. Body text remains neutral except locked markdown-lite. Activity may continue for another silent role. Completion is a card on the speaking turn.
- **Ask:** the exact colored agent question is a real transcript turn; the OMP-style structured ask dock is above the composer; the composer remains below it. Selection supports the locked keyboard and single/multi semantics.
- **Slash:** `/` opens the palette dock immediately above the composer; composer input is the filter. `/sta` filters; Enter runs a supported command or refuses an unsupported one. Run, refusal, and usage are mute Command rails.
- **Evidence:** command summary remains a mute Command turn; long report/bench file lists are in a bordered labelled evidence panel distinct from chat.
- **Confirm:** a dock above the composer intercepts each locked chat-supported write before execution. Run invokes the real CLI; Cancel spawns nothing.
- **Toast:** done is a card on the originating turn; fail/interrupt is a toast plus error card; session verbs are mute toasts, not extra transcript lines.
- **Compact:** explicit 40-column mode, not wrapping. At 40 columns, drop the heads and directory from the header, cap activity to one line plus `+N`, keep the composer, and use the compact footer. Restore the wide header after 80-column return.
- **Empty:** no provider and no scored sessions have honest explanatory copy and retain role chips, selected `@Principal` composer, and footer hints; they are not status dumps.

### 2.3 Header

Wide header is exactly the shape:

```text
▣─▣─▣ ProductTeam · {cwd project} · {score}
```

The middle head pulses while work is active. The project is the cwd project projection, not `harness-cli`, and the score is the latest overall score for that project. At `<=40` columns the header is exactly the compact form:

```text
ProductTeam {score}
```

The header must never contain `harness-cli` or `Directive`. The compact proof must show the heads and directory return after restoring 80 columns.

### 2.4 Turns and role identity

Every turn uses a 2px rail and a role label. You uses a gray rail and mute label. Principal, Analyst, Builder, and Critic use their locked identity color for label, rail, and chip. Body copy remains neutral. This is not an 11-character gutter and is not constrained by the two-accent Bash rule. Turn timestamps are dim.

Bare text defaults to `@Principal`. The selected role is session-local, visible in the composer as `@Role`, and is passed as an explicit argument to `provider_turn.sh`. A selected chip changes the target; a completed role remains identifiable in its card and chip. Analyst must not be hardcoded.

## 3. Exact cockpit token and glyph contract

The cockpit may use the owner-locked role identity hues below. These values are exact and case-sensitive. No Textual cyan `$primary`, no additional hues, and no hue substitutions are allowed. Body text stays neutral. `NO_COLOR` removes color only; glyphs and bold/dim semantics remain.

| Token | Exact hex | Required use |
|---|---|---|
| `canvas` | `#0a0a0a` | cockpit field/background |
| `field` | `#141414` | composer and docks |
| `rule` | `#2a2a2a` | hairlines and panel borders |
| `text` | `#e4e4e4` | copy and caret |
| `mute` | `#737373` | idle, footer, pending, and Command |
| `you` | `#8a8a8a` | You label and 2px rail |
| `principal` | `#c084fc` | `◆ Principal` label, rail, and chip |
| `analyst` | `#60a5fa` | `◇ Analyst` label, rail, and chip |
| `builder` | `#22c55e` | `▸ Builder` label, rail, and chip |
| `critic` | `#f59e0b` | `◉ Critic` label, rail, and chip |
| `ok` | `#22c55e` | score >=9, `✓`, additions, headings, and live glow |
| `err` | `#ef4444` | `✗`, failures, fail toast, and deletions |

The canonical Bash CLI (`bin/productteam`, `lib/theme.sh`, and `chk_cli_accent_budget`) retains its two-accent `ok`/`err` budget. The cockpit-only role identity allowance must not weaken that Bash assertion.

Required role glyphs are exactly `◆ Principal`, `◇ Analyst`, `▸ Builder`, and `◉ Critic`. Required status glyphs are `✓`, `✗`, `…`, `○`, and `▲`. The activity spinner is braille (the visualizer's `⠋` through `⠏` sequence is acceptable). Do not use `Thinking…` as a transcript message.

## 4. Product locks (all mandatory)

### Q1 — Filtered home

Seed the home with **at most three** recent scored sessions for the current directory, or three distinct global scored projects. Exclude every engagement whose name matches `*smoke*`, `*run-loop*`, `*gate-smoke*`, or `*overnight-rehears*`. Do not seed or render full `productteam status` prose. Home rows are display-only (R8); there is no project picker or workspace switcher. Header follows the cwd project.

### Q2 — Identity chrome

You is a gray 2px rail with a mute label. Principal, Analyst, Builder, and Critic each have a role-colored label, 2px rail, and chip. Body text remains neutral. The cockpit may use the four role hues; the Bash CLI remains two-accent-only. No 11-character role gutter.

### Q3 — Header

Render `▣─▣─▣ ProductTeam · {cwd project} · {score}` at wide sizes. Pulse the middle head while work is active. At `<=40` columns render `ProductTeam {score}` and drop heads and directory. Never put `harness-cli` or `Directive` in the bar.

### Q4 — Honest work activity

The live activity line has a braille spinner and elapsed `m:ss`, plus a provider/mission fact sourced from real worker state. No determinate progress bar and no fake progress.

### Q5 — Explicit compact mode

Compact is a deliberate 40-column mode, not wrapping. Prove reachable chrome at `120x36`, `80x24`, `60x24`, and `40x20`, plus a live SIGWINCH/terminal resize sequence `80 -> 40 -> 80`. At 40, preserve the composer, compact the header, and cap activity to one line plus `+N`.

### Q6 — Structured OMP ask

Show an OMP-style dock above the composer with the exact question, option labels, descriptions, recommendation, single/multi selection semantics, `k of n`, and `↑↓`, Space, Enter, and Esc behavior. The question is a real colored agent turn. The composer remains below. Never scrape transcript prose to create an ask.

Consume a structured ask event. If the installed provider emits the schema, wire that event. If it does not, tests must prove the dock through a file-backed control event at `ask.json` beside the provider artifact (or an equivalent existing seam). Inventing a second provider supervisor fails Q6.

### Thinking versus speech

Silent work must remain in the activity strip from real `workers.tsv` (`lib/activity.sh` columns: `id role state mission provider start elapsed artifact`). A colored transcript turn begins only once that role emits text. There must be no fake agent message and no `Thinking…` in the transcript.

### R1 — Markdown-lite speaking turns

Within speaking turns only: headings are `ok` plus bold; fences are mute; `+` lines are `ok`; `-` lines are `err`; evidence paths are bold. Other body text is neutral. Completion cards remain attached to the originating role turn.

### R2 — Slash palette and refusal

The palette is a dock above the composer and the composer is its filter. Supported commands execute via the real CLI and stream as mute Command rails. Run, refusal, and usage are never role-colored. Unsupported verbs refuse with `chat_reason` plus usage and do not spawn.

### R3 — Evidence panel

Render a bordered, labelled evidence panel distinct from chat. Keep the report/bench summary as a mute Command turn. Parse long report/bench file paths into the panel instead of drowning the transcript in a file list.

### R4 — Confirm writes

Intercept and confirm before each chat-supported write: `/gh merge`, `/checks --allow-dirty`, and `/onboarding --yes`. The Run choice invokes the real CLI; Cancel spawns nothing. Other mutations remain refused.

### R5 — Toasts and completion

A successful completion is a card on its role turn. Failure or interrupt produces a toast and an error card, retaining partial artifact output where applicable. Session verbs such as `/export` and provider cycling produce a mute toast, not an extra transcript line.

### R6 — State-dependent footer

Idle footer shows hints (`enter send · / commands · tab agents`). Busy footer shows facts (`ctrl+c interrupt · m:ss · {provider}`). Ask and slash docks replace the idle hints with their keyboard instructions while open.

### R7 — TUI-owned splash

Show futuristic angular line-art heads once, then the cockpit. Idle is all-neutral. Live boot glow cycles Principal -> Analyst -> Builder -> Principal one at a time. Ship it as ASCII in Textual. It is not the six-node `lib/splash.sh` graph and not `ROBOTS_MARK` half-blocks from `lib/repl.sh`. Any key skips; composer and footer remain visible.

### R8 — Display-only home

Home rows are display-only, header follows cwd, and there is no project picker.

### Target

Chips are focusable/clickable. The composer shows `@Role`. Selection is session-local. Idle home defaults to `@Principal`. Pass role as argv to `provider_turn.sh`; use `state/agents/` `prompt_export` and `lib/agent-cards.sh` / `agent_card_prompt_block` for the selected role. Stop hardcoding Analyst.

### Defaults

Turn timestamps are dim. Copy is a session verb rather than chrome. High contrast means exactly the token table above.

## 5. Backend seams and honest data paths

The following seams are mandatory. Keep argv-only execution, `shell=False`, and the real executable. Reuse `lib/repl.sh`, `lib/activity.sh`, `lib/provider.sh`, and `lib/agent-cards.sh`; do not reimplement a provider supervisor in Python.

| Seam | Required honest path and observable proof |
|---|---|
| Palette | Read the live `productteam help --json`; do not maintain a second verb list. |
| Supported slash | Build an argv array to the real executable `bin/productteam`; stream real stdout with markdown-lite as a mute Command turn. |
| Unsupported slash | Render `chat_reason` plus usage; argv trace proves no spawn. |
| Chat-only | `/provider`, `/workers`, `/clear`, `/export`, `/exit`, `/quit` match `lib/repl.sh`; session verbs follow the locked toast rule. |
| Home | Use scored sessions from files or filtered `status --json`; never dump `status` text into transcript. |
| Header score | Use latest `runs/iter-*/scores.json` overall for cwd project; never show Mode or Directive. |
| Activity | Poll `state/.cli/runs/session-*/workers.tsv`; cap at 3 rows at 80, 2 at 60, and 1 plus `+N` at 40. |
| Provider turn | Signature is `provider_turn.sh ROOT PROMPT ROLE`; call `activity_start "$ROLE"`; prepend selected role's `prompt_export` / `agent_card_prompt_block`; preserve process-group Ctrl+C behavior. Default missing ROLE is Principal, never Analyst. |
| Ask | Structured event only, using the schema in §6; fixture `ask.json` is a file-backed control seam if provider output lacks it. No transcript scraping. |
| Confirm | Intercept write verbs before `run_argv`; Run then executes the real argv; Cancel produces no spawn. |
| Evidence | Parse report/bench file paths into the bordered panel; do not dump the full list as chat. |
| Splash | TUI-owned ASCII splash; `/splash` CLI verb may still run the real command as a Command turn after skip/finish. |
| Non-TTY | Exit 2, stderr contains `requires an interactive TTY`, stdout is empty, and no ESC bytes are emitted under `NO_COLOR`. |

### Argv and trace safety

Every process invocation is represented as an argv array. No `shell=True`, shell string interpolation, `/bin/sh`, `/bin/bash`, `eval`, `sqlite`, or `sqlite3` is permitted in the execution path or token-aware trace. The deny rule is whole-token, not a substring ban: `agents --json` is explicitly allowed and must appear in the fresh dry-run evidence. There is no 0444 proxy and no candidate-side trace or argv bypass.

The dry-run is mandatory **before build/implementation acceptance** and must exercise the real executable `bin/productteam` in executable mode (not a wrapper, mock, proxy, or fake provider). The fresh evidence directory is:

```text
state/harness-evolution/runs/tui-polish-20260814/argv-dry-run/
```

It must contain token-aware invocation traces/argv arrays for representative palette/help, supported command, unsupported refusal (with no spawn), `agents --json` (allowed), and a role-targeted provider path. The evidence must show the executable mode and permissions for `bin/productteam`; it must show that shell metacharacters are not interpreted. Forbidden whole tokens are `/bin/sh`, `/bin/bash`, `eval`, `sqlite`, and `sqlite3`. Do not substitute a 0444 proxy. This dry-run is evidence, not permission to mock the live provider path.

## 6. Structured ask event schema

The only accepted ask control is a structured event, either emitted by the installed provider or written to `ask.json` beside that provider artifact (or an equivalent existing provider seam). The event is not inferred from transcript text. The canonical shape is:

```json
{
  "event": "ask",
  "id": "ask-<stable-id>",
  "role": "Principal",
  "question": "Where should each role’s color appear?",
  "mode": "single",
  "options": [
    {
      "id": "label-rail",
      "label": "Label + rail",
      "description": "Color the role label, chip, and 2px turn rail.",
      "recommended": true
    },
    {
      "id": "label-only",
      "label": "Label only",
      "description": "Keep the rail neutral.",
      "recommended": false
    }
  ],
  "default": ["label-rail"]
}
```

Required validation and behavior:

- `event` is exactly `ask`; `id`, `role`, `question`, `mode`, and non-empty `options` are required.
- `role` is one of Principal, Analyst, Builder, Critic and controls the colored question turn; it is not inferred from prose.
- `question` is displayed exactly, without rewriting or transcript scraping.
- `mode` is exactly `single` or `multi`. Single permits one selected option; multi permits a set of one or more option IDs.
- Each option has unique `id`, non-empty `label`, non-empty `description`, and boolean `recommended`; at most one option is recommended for a single ask. The recommended option is visibly marked.
- `default` is an array of option IDs and must obey mode/options membership. The dock displays `k of n` where `k` is the current selection index/count appropriate to the mode and `n` is the option count.
- `↑`/`↓` changes the focused option, Space toggles (or selects in single mode), Enter confirms the structured selection, and Esc cancels/skips without spawning. The composer remains mounted below the dock throughout.
- A malformed, missing, or prose-only event does not open a fake question. It produces an honest failure/refusal path and no provider spawn.
- The test fixture must prove open, exact question/labels/descriptions/recommendation, single/multi handling, keyboard behavior, `k of n`, Esc close, and composer focus/visibility.

## 7. Required test table

The Principal runs every check below on every implementation iteration. The first iteration in which every mandatory score is at least 9.0 stops the loop. Tests must isolate per-invocation transcript deltas; grepping a whole accumulated log is not a pass. Refresh snapshots only as evidence of the new locked chrome; never weaken needles. Set `CONSULT_NO_SPLASH=1` except while testing `/splash` or the TUI boot splash.

| Check | Pass rule | Required evidence |
|---|---|---|
| Native pytest + snapshots | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` is green. Snapshots match locked chrome: header has no `harness-cli`/`Directive`, home has three scored rows or honest empty state, and docks are above composer. Role hues are allowed in cockpit CSS; Bash two-accent tests remain unchanged. | `iter-N/pytest.txt`, snapshot diffs/paths |
| Home seed | Transcript has no full `productteam status` dump; excluded `*smoke*`, `*run-loop*`, `*gate-smoke*`, and `*overnight-rehears*` names are absent. | `iter-N/notes.md` with isolated transcript assertion |
| Turn chrome | Bare-text Enter writes a You turn with gray rail and mute label, not an unstyled dump. | targeted PTY note or test result |
| Role argv | `provider_turn.sh` receives ROLE; `activity_start` is not hardcoded Analyst; a chip/composer `@Builder` turn records Builder in `workers.tsv`. | argv trace, workers row, `iter-N/pty-note.md` |
| Activity vs speech | With a running worker and empty artifact, transcript has neither `Thinking…` nor a fake agent message; real worker state appears in bounded activity only. | PTY/activity evidence |
| Ask dock | `ask.json` (or the freeze-named equivalent) opens the OMP dock above composer; exact schema fields and controls work; Esc closes; composer remains visible/focused. | fixture and targeted test/PTY evidence |
| Confirm | `/gh merge` opens confirm; Cancel does not spawn; argv log is empty for that attempt. Same interception applies to `/checks --allow-dirty` and `/onboarding --yes`. | argv trace and PTY note |
| Evidence | A long `/report` keeps summary as a Command turn and puts files in the bordered labelled panel. `/bench` follows the same rule. | snapshot/PTY evidence |
| PTY slash | `/` opens dock; `/sta` filters; Enter runs real `status`; `/gate` refuses and does not spawn gate. | PTY note and argv trace |
| PTY sizes + SIGWINCH | `120x36`, `80x24`, `60x24`, and `40x20` each reach the locked chrome; ioctl/SIGWINCH sequence `80→40→80` proves compact header `ProductTeam {score}`, composer retention, and restored heads/directory. | `iter-N/pty-note.md`, snapshots |
| Provider interrupt | First Ctrl+C reaps the process group, retains partial artifact, and marks worker `failed`; second Ctrl+C exits 130 with termios restored. | PTY note and worker/artifact evidence |
| `tests/cli-interface-parity.sh` | PASS; shipped contract remains 33 commands / 18 supported / 15 unsupported / 6 chat-only and is not reverted. | `iter-N/cli-interface-parity.txt` |
| `tests/visual-cli.sh` | 14/14 visual IDs. Overall exit 1 is allowed only for the pre-existing missing live-provider proof. Do not mock the provider. | `iter-N/visual-cli.txt` and note naming the pre-existing proof if applicable |

## 8. Mandatory scoring rubric

A Reviewer scores every dimension independently from **0.0 through 10.0**, in one-decimal increments. Every numeric score must cite concrete evidence by path, snapshot, PTY note, argv trace, or command result. A missing, unreadable, stale, or uncited evidence item scores **0.0** for that dimension. No score may be inferred from implementation intent. The acceptance threshold is **>=9.0 for every mandatory dimension**; an average or compensating high score never overrides a failing dimension.

| ID | Mandatory dimension | 10.0 evidence standard |
|---|---|---|
| D01 | Exact global layout | All seven regions appear in locked order; activity is conditional; every dock is above and never covers composer; close restores focus. |
| D02 | Exact cockpit tokens and glyphs | All exact hex values, role glyphs, status glyphs, no cyan/extra hue, neutral body, NO_COLOR semantics, and Bash two-accent separation are proven. |
| D03 | Q1 filtered home | At most three cwd/global scored rows, all exclusions enforced, no status prose dump, display-only rows, and honest empty state proven. |
| D04 | Q2 identity | You and all four permanent roles have exact label/rail/chip treatment, neutral body, and no 11ch gutter. |
| D05 | Q3 header | Wide exact header, cwd project, latest score, active pulse, compact exact header, and absence of `harness-cli`/`Directive` proven. |
| D06 | Q4 honest activity | Real workers.tsv activity, braille spinner, mission/provider fact, elapsed m:ss, bounded rows, and no determinate/fake progress proven. |
| D07 | Q5 compact and resize | Explicit 40 mode, all four sizes, live `80→40→80`, composer retention, compact cap, and restoration proven. |
| D08 | Q6 structured ask | Exact structured event consumption, real colored question turn, labels/descriptions/recommendation, single/multi, `k of n`, all controls, fixture seam, and no scraping/supervisor proven. |
| D09 | Thinking versus speech | Empty-artifact work stays solely in activity; role turn starts only on emitted text; no `Thinking…`/fake agent message. |
| D10 | R1 markdown-lite | Heading, fence, plus/minus, evidence path, neutral body, and attached completion cards match. |
| D11 | R2 slash | Live help palette, filter, real supported argv/output, mute Command rails, refusal `chat_reason`+usage, and no unsupported spawn. |
| D12 | R3 evidence | Bordered labelled panel is distinct from chat; report/bench summaries stay Command and long lists do not drown transcript. |
| D13 | R4 confirm | All three locked writes are intercepted; Run uses real argv; Cancel is proven no-spawn; other mutations refuse. |
| D14 | R5 toasts and cards | Done card, failure/interrupt toast+error card with partial artifact, and mute session toasts are each proven without extra lines. |
| D15 | R6 footer | Idle hints, busy facts, and ask/slash replacement hints are exact and state-dependent. |
| D16 | R7 splash | TUI-owned angular ASCII heads, once/skip, neutral idle, exact live glow cycle, composer/footer visibility, and rejection of graph/ROBOTS_MARK are proven. |
| D17 | R8 display-only home | Home cannot select/switch project; cwd header follows and rows remain display-only. |
| D18 | Targeting | Focusable chips, `@Role` composer, session-local selection, Principal default, role argv, prompt export/card block, and no Analyst hardcode are proven. |
| D19 | Defaults | Dim timestamps, copy as session verb, and exact high-contrast token defaults are proven. |
| D20 | Palette backend seam | `help --json` is live and no second command registry/list exists. |
| D21 | Supported slash backend seam | Real executable argv arrays, streamed output, mute Command rendering, and markdown-lite are proven. |
| D22 | Unsupported/chat-only seam | Refusal and no-spawn behavior plus all six chat-only verbs matching `lib/repl.sh` are proven. |
| D23 | Home/header data seam | Filtered file/status JSON home and latest `runs/iter-*/scores.json` cwd score are proven; no prose status seed. |
| D24 | Activity/provider seam | Correct workers path/columns, row caps, provider signature, role activity start, card prompt export, and process-group interrupt are proven. |
| D25 | Ask/confirm/evidence seams | Structured ask file/provider event, pre-run write interception, and evidence path parsing are all real and file-backed where required. |
| D26 | Splash/non-TTY seams | TUI-owned splash and `/splash` separation plus exact non-TTY exit/stderr/stdout/NO_COLOR behavior are proven. |
| D27 | Argv safety and dry-run | Fresh real-`bin/productteam` executable dry-run has argv arrays, whole-token policy, allowed `agents --json`, forbidden token proof, no shell/no proxy/no bypass. |
| D28 | Required test coverage | Every row in §7 passes under its stated rule, including native snapshots, PTY, interrupts, CLI parity, and visual CLI exception only as specified. |
| D29 | Preservation and failure behavior | No forbidden changes; chat remains Bash; prior cockpit remains on failure; unrelated dirty worktree is preserved; no deletion or goalpost movement. |

Reviewer output must include a score and citation for **all D01–D29**, even when the implementation is incomplete. Any missing citation is a zero. Acceptance requires every D score `>=9.0`, fresh argv dry-run evidence, required hashes, and all applicable test/evidence files.

## 9. Overnight loop and stop rules

1. **Inspect (complete before freeze):** read the locked HTML, the current TUI files and tests/snapshots, canonical Bash seams, prior ship evidence, and canonical CLI gates; record residual defects in `inspect.md`. No app edits occur during inspection.
2. **Advisor freeze:** this benchmark is written before any app edit. A Freeze Critic reads it and either writes `ACCEPT-FOR-FREEZE` (citing a fresh `argv-dry-run/` against executable `bin/productteam`, including allowed `agents --json`) or writes `REJECT`. No post-freeze rubric edits.
3. **After ACCEPT-FOR-FREEZE:** write `FREEZE-SHA.txt` and hashes for the freeze inputs listed in §10. Only then may a Worker edit `lib/tui/**` and tests named by this benchmark.
4. **Implementation iterations:** at most five, `iter-1` through `iter-5`, one Worker at a time and one Reviewer per iteration. The Principal owns long test execution and iteration reports. Workers skip formatters, linters, and project-wide suites; they may run a single targeted pytest file.
5. Each iteration addresses the smallest failing slice identified by the previous Reviewer/freeze, runs the complete §7 table, writes the iteration evidence, and gets an independent Reviewer score of all D01–D29.
6. **Stop immediately on first all-pass:** if every mandatory dimension is at least 9.0, keep the polish, write `final-report.md`, and stop. Do not start another iteration.
7. **Stop at iter-5:** if any dimension remains below 9.0 after iter-5, write `not-converged.md` naming each failing dimension and commands/evidence, and leave the shipped 2026-08-13 cockpit in place. Never start iter-6 and never call the result done.
8. A Reviewer citation is mandatory for claiming done. No all-pass claim without the complete score set.

## 10. Evidence and freeze-input hashes

Required run evidence under `state/harness-evolution/runs/tui-polish-20260814/`:

```text
inspect.md
argv-dry-run/                         # fresh, executable, token-aware traces
frozen-benchmark.md
reviewer-prebuild.md                 # ACCEPT-FOR-FREEZE or REJECT
FREEZE-SHA.txt
iter-N/pytest.txt
iter-N/cli-interface-parity.txt
iter-N/visual-cli.txt
iter-N/pty-note.md
iter-N/notes.md
iter-N/scores.json
iter-N/reviewer-gate.md
(diff-summary.md, lessons.md, final-report.md OR not-converged.md)
```

The following freeze inputs must be listed and hashed after `ACCEPT-FOR-FREEZE` (the Advisor may add no rubric-changing input after acceptance):

```text
state/harness-evolution/runs/tui-polish-20260814/GOAL-LOOP.md
state/harness-evolution/runs/tui-polish-20260814/inspect.md
state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html
state/harness-evolution/runs/tui-cockpit-20260813/frozen-benchmark.md
state/harness-evolution/runs/tui-cockpit-20260813/final-report.md
state/harness-evolution/runs/tui-cockpit-20260813/lessons.md
```

The Principal writes `FREEZE-SHA.txt` from those exact inputs, including the benchmark itself, using SHA-256 after the Freeze Critic accepts:

```sh
sha256sum \
  state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md \
  state/harness-evolution/runs/tui-polish-20260814/GOAL-LOOP.md \
  state/harness-evolution/runs/tui-polish-20260814/inspect.md \
  state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html \
  state/harness-evolution/runs/tui-cockpit-20260813/frozen-benchmark.md \
  state/harness-evolution/runs/tui-cockpit-20260813/final-report.md \
  state/harness-evolution/runs/tui-cockpit-20260813/lessons.md \
  > state/harness-evolution/runs/tui-polish-20260814/FREEZE-SHA.txt
```

The dry-run evidence and hashes are immutable acceptance inputs. A changed benchmark, source visualizer, inspection, or prior-run input after acceptance invalidates the freeze and requires a new owner-authorized run rather than a rubric edit.

## 11. Cuts and forbidden changes

Implementing any cut below fails the gate; these are not future options:

- settings, theme picker, plugins, or session search;
- OpenTUI, Ink, or a second framework;
- replacing `productteam chat` or making it launch the TUI;
- a daemon, database, or second state writer;
- editing `spikes/shared/` or the 2026-08-12 freeze;
- deleting `lib/tui/` on polish failure;
- overwriting unrelated dirty worktree files;
- scraping prose for ask-back;
- determinate fake progress bars;
- `ROBOTS_MARK` half-blocks or the six-node graph as the TUI splash.

The following are also forbidden and void an iteration:

- pinning a non-default model;
- two writers on `lib/tui/` at once;
- OpenTUI, Ink, or any framework bake-off;
- replaying `spikes/shared/pty_driver.py`'s 0444 proxy or using a substring `agent` ban;
- candidate-side argv/trace bypasses;
- provider mocks for the live path;
- secrets in artifacts;
- making `tui` the default for `chat`;
- theme/settings redesign;
- inventing extra permanent organization roles;
- scraping transcript prose to fake ask-back;
- calling polish done without Reviewer citations for every mandatory dimension;
- deleting the 2026-08-13 cockpit because polish missed 9.0.

Preserve unrelated dirty files (including OFC check artifacts, spike evidence, and `.gitignore`). Do not vendor `.venv`, `__pycache__`, or `node_modules`. Do not weaken test needles, mock the provider, or alter the canonical CLI contract. Do not edit app code, tests, snapshots, registry, Bash modules, prior run evidence, or unrelated files as part of the freeze task.

## 12. Acceptance gate

The polish is accepted only when all of the following are true:

- `productteam tui` on an interactive TTY matches the locked frames: boot splash when shown, filtered three-row home, You/role chrome, real activity for silent work, markdown-lite speech, completion cards, slash/evidence/confirm/ask docks above the composer, explicit 40-column compact mode, and idle/busy footer.
- Wide header is `▣─▣─▣ ProductTeam · {cwd} · {score}` with no `harness-cli` and no `Directive`; compact header is `ProductTeam {score}`.
- Bare text targets `@Principal` by default; chip/`@Role` selection changes argv role; `workers.tsv` records it; Analyst is not hardcoded.
- Every chat-supported verb still produces real CLI output; unsupported verbs refuse; canonical CLI gates pass; `productteam chat` remains the Bash REPL and does not launch TUI.
- The fresh executable dry-run proves whole-token-aware argv safety, allows `agents --json`, forbids `/bin/sh`, `/bin/bash`, `eval`, `sqlite`, `sqlite3`, and uses no 0444 proxy.
- The complete test table is evidenced, the Freeze Critic accepted before app edits, freeze inputs are hashed, and a Reviewer cited every D01–D29 at `>=9.0`.
- If any mandatory dimension is below 9.0 by iter-5, the only accepted outcome is `not-converged.md` with failing dimensions/evidence and the shipped 2026-08-13 cockpit intact.

**No post-freeze rubric edits. No alternative framework or design proposal.**