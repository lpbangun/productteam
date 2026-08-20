# Reviewer gate — iter-7

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-7`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`); owner schedule extension `extension.md` (iter-6…iter-10, freeze immutable); Worker contract `iter-7/debate.md`. Missing, stale, or uncited evidence scores 0.0. Average does not compensate. PASS only if every score ≥ 9.0.

**Verdict: FAIL — not converged. D01, D10, D11, D12, D14, D19, D21, and D25 now clear 9.0. Remaining zero is D16.**

The bound evidence+Command+toast+card machine landed. Native suite is 52/0. Real PTY is 5/0 with unweakened needles. That is not freeze acceptance. TUI-owned splash / skip / glow is still absent.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D16`) |
| ≥ 9.0 | D01, D02, D08, D10, D11, D12, D13, D14, D15, D17, D18, D19, D20, D21, D22, D23, D25, D27, D29 (19/29) |
| Native pytest | **52 passed, 0 failed** (`iter-7/pytest.txt`) — 5 new tests over iter-6's 47 |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Three required outputs

1. **Final verdict:** FAIL. Do **not** write `final-report.md`. Do **not** delete `lib/tui/` or the `tui` registry row. Continue only under `extension.md` into the bound iter-8 **TUI splash** slice below.
2. **Scores:** `iter-7/scores.json` (this gate). Every D01–D29 has a current path or command citation.
3. **Explicit 9.0 decisions (the eight named dims):**
   - **D01 clears 9.0** (9.1). Every dock — slash / ask / confirm / **evidence** — sits above the composer; close restores focus; composer ≥20 at 80 and 40.
   - **D10 clears 9.0** (9.1). Native owned-rail markdown-lite snapshot plus an append-only attached done card with no speech replay.
   - **D11 clears 9.0** (9.1). Mute Command rail owns slash echo, supported stream, and refuse+usage. PTY `/status` / `/gate` needles stay exact.
   - **D12 clears 9.0** (9.1). Bordered labelled `#dock` evidence panel; Command summary keeps `iter-1` / `Benchmark`; paths withheld from chat.
   - **D14 clears 9.0** (9.0). Done card on the role rail; one interrupt warning toast + error card carrying `partial output left on disk`; `/export` and `/provider` are observable session toasts, not extra transcript lines.
   - **D19 clears 9.0** (9.1). Dim timestamps held; copy/export is a session toast, not chrome.
   - **D21 clears 9.0** (9.1). Real executable argv + streamed markdown-lite as a mute Command turn; 18-verb per-turn needles still in `_turns` cli delta.
   - **D25 clears 9.0** (9.1). Ask + confirm + product-side evidence path parsing are all real. Residual to 10.0: live PTY `/report`.

---

## Adversarial inspections (required)

Scope bound by `iter-7/debate.md`: classify-at-stream for `report`/`bench` only; existing `#dock` evidence kind; mute Command helper; `_toasts` wrap; rail-continuation card; interrupt toast/card split; native markdown fixture. Product mtimes in the Worker window: `app.py` 22:54, `theme.py` 22:54, `test_slash.py` 22:52, `test_layout.py` 23:05. Snapshots rewritten 23:13-23:14 by Principal `test_snapshots_export` during the freeze table. `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` (21:47), and `test_all_verbs.py` NEEDLES (11:47) were not retouched this iter.

### 1. Evidence classifier vs real report/bench shapes — HONEST

`theme.split_evidence_line` (`theme.py:307-357`) is called from `_append_cli_line` only when `_cli_argv[:1]` is `report` or `bench` and the stream is not inside a fence (`app.py:1030-1048`). Other supported verbs stream every line to the Command rail. `/run` is not classified.

Native fixtures use the debate-bound non-TTY shapes (`test_slash.py:78-96`):

| Stream | Command-summary delta keeps | Panel payloads | Withheld from `transcript_text()` |
|---|---|---|---|
| `/report` | `iter-1`, `KEEP lib/tui/.` | `lib/tui/app.py: rail stays 2px`, `runs/iter-1/pytest.txt` | both paths (`test_slash.py:205-248`) |
| `/bench` | `Benchmark — harness-cli`, `visual-cli-clarity`, `9.5`, `overall`, `HISTORY` | `+5.5  lib/theme.py: headings stay ok`, trailing `scores.json` | `lib/theme.py`, `scores.json` (`test_slash.py:253-287`) |
| usage-only `/report` | `usage: productteam report <client>` | none | no dock, no labelled chrome (`test_slash.py:188-201`) |

Empty buffer opens no panel. `_turns` cli text still stores full stdout so `test_all_verbs.py` NEEDLES `iter-1` / `Benchmark` remain in the Command-summary / `_turns` delta (`test_all_verbs.py:31-32, 70-112` — passed in the 52).

Residual to 10.0, not a 9.0 fail: no live PTY `/report` row. File-backed CLI stream + native fixtures are the freeze-named evidence path (`frozen-benchmark.md:251`).

### 2. One `#dock`, display-only, composer retained — HONEST

Compose is still `header / rule / transcript / #activity / #chips / #dock OptionList / #composer-region / footer` (`app.py:329-341`). `_dock_kind` gains `"evidence"` on that same OptionList (`app.py:820-834`). CSS `#dock.evidence { border: solid {RULE} !important; }` reuses `#2a2a2a` (`app.py:128-130`). No second widget, `ModalScreen`, `Button`, or `ProgressBar`.

Label `evidence · {n} files` is mute and never a path id (`app.py:836-839`). Caps: 6 paths at 80, 3 at 40, remainder `+N` (`test_layout.py:888-973`: option_count 8 / 5). Enter/Esc close and restore `composer.focus()`; Space/Tab no-op; arrows highlight only; option ids `ev-{i}` are never passed to `_exec_cli`. Y-order: `dock.region.y + height <= composer.region.y` at 80 and 40. Composer >=20 with evidence at both widths. Footer while open is `↑↓ · esc close` — not the visualizer's `enter open`, and not the slash `enter run · tab complete` fall-through the debate forbade (`app.py:530-532`; `test_slash.py:235`).

`_refresh_dock` early-returns when kind != `"slash"` **or** `_cli_busy` (`app.py:1139-1140`). `_exec_cli` stores `_cli_argv` on the UI thread before the streamer and opens the panel via `_call` in `finally` (`app.py:1370-1406`).

### 3. Mute Command rail — HONEST

One helper pair (`theme.py:225-241`): `command_open` / `command_continue`. MUTE rail + MUTE `Command` + dim timestamp; body is already-`md_line` styled. Never `ROLE_STYLES`. Three product call sites only: slash echo, supported stream, refuse+usage (`app.py:1301-1308, 1039-1054, 1355-1359`). Session verbs are not Command (`app.py:1297-1300`).

Native (`test_layout.py:978-1030`): after `/status`, delta contains exactly one `│ Command`; Command label and every `│` span are MUTE; Principal/Analyst/Builder/Critic/You hues are absent from that strip. `/gate` refuse still prints `use the CLI: productteam gate` and `owner-gated durable decisions` with no `Directive: no directive` and no role hue. Recorder `spawns == []` held (`test_slash.py:165-185`).

### 4. Session toasts vs extra lines — HONEST

`ProductTeamApp.notify` appends `(message, severity)` to `self._toasts` then `super().notify` (`app.py:376-386`). `/export` success -> information toast starting `wrote `; `"wrote "` **not** in `transcript_text()`; export file still has `# TUI session`, `/export`, and the prior CLI turn (`test_slash.py:345-374`). `/provider` -> information toast `provider → agent` / `provider → claude`; those strings **not** in the transcript; `CONSULT_PROVIDER` still set (`test_slash.py:292-325`). Observation is the product `_toasts` log, not a Toast-widget scrape.

### 5. Append-only attached card — HONEST

`#transcript` remains `RichLog`. `_provider_done` appends one `completion_card` line on the speaking role's hue rail (`theme.py:244-267`; `app.py:1516-1534`). No `transcript.clear`, no `_write_turn` of the body, no detached unowned `status_tag` row. Native (`test_layout.py:794-883`): after owned Builder speech, `delta.count("plain body") == 1` both before and after `_provider_done(0, ...)`; card carries `✓ done`, bold `▸ Builder`, artifact basename; `_toasts == []` on clean done.

Interrupt split (`app.py:1512-1522, 1537-1551`): first Ctrl+C keeps the exact warning toast `Ctrl+C — interrupting provider, partial output kept` (one toast); `_provider_done` rc==130 writes the failed card with detail `partial output left on disk` and **no** second notify and **no** extra `_echo_muted`. PTY needles `"interrupting provider"` and `"partial output left on disk"` still pass (`test_pty.py:182-215`; `pty-test.txt` 5/0).

Residual to 10.0: no dedicated native fixture for `rc != 0` (not 130) beyond the source path `notify("provider failed")` + failed card.

### 6. Markdown-lite on the owned rail — HONEST

`test_provider_speech_markdown_and_attached_done_card` (`test_layout.py:794-883`) is a native `run_test` fixture, not a live-provider mock and not an `md_line()`-only unit test. Empty-artifact Analyst row: no `Thinking…`, no `◇ Analyst` in the transcript. Then Builder chunk of heading / `+` / `-` / evidence path / plain / fence. Asserted on painted spans: heading `Done when` is `bold`+`OK`; `+` is `OK`; `-` is `ERR`; path bold; `: rail stays 2px` mute; fence markers mute; `plain body` / `inside` carry no style span (neutral / unstyled). Builder rail `#22c55e`. Body copy count stays 1 after the card.

### 7. D08 / D13 re-audit — HOLD, both still clear 9.0

Ask and confirm were not the iter-7 slice. This Reviewer re-read the live seams against the freeze, not against iter-6 scores.

**D08 holds 9.1.** `_poll_ask` still reads only `Path(self._active_artifact).parent / "ask.json"` while `_provider_active` and `_dock_kind == "slash"` (`app.py:579-608`). No glob. No scrape. Atomic `ask.answer.json` shape `{event: ask-answer, ask_id, answers, cancelled}` (`app.py:746-769`). Invalid/prose -> `ask.json.invalid`, one mute `ask ignored:`, no question turn (`test_layout.py:650-716`). Same-id re-emit -> `ask.json.done` without reopen. Evidence kind cannot steal the poll: `_poll_ask` requires slash, and `_refresh_dock` early-returns while evidence/ask/confirm or `_cli_busy`. Native ask tests remain in the 52.

**D13 holds 9.2.** Exact tuple intercept of `("gh","merge")`, `("checks","--allow-dirty")`, `("onboarding","--yes")` before `_exec_cli` (`app.py:776-780, 1360-1364`). Run reuses the stored original argv (`app.py:798-806`). Cancel/Esc `spawns == []` for all three (`test_slash.py:444-481`). `/gh preflight` unintercepted (`test_slash.py:484-499`). Live PTY `/gh merge` Esc still shows `Run /gh merge`, `Cancel`, confirm footer, `@Principal`, then idle footer, `/exit` rc 0 (`test_pty.py:262-299`). Evidence Enter closes the panel; it does not run a write.

### 8. PTY regressions — NONE

`lib/tui/tests/test_pty.py` mtime 21:47 (iter-6). Assertions were not edited this iter. Isolated PTY **5 passed** (`iter-7/pty-test.txt`). Exact needles held:

| Row | Held |
|---|---|
| `test_pty_status_and_gate_refuse` | `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:171-179`) |
| `test_pty_provider_interrupt` | live `partial analysis begins`; `"interrupting provider"`; `"partial output left on disk"`; artifact bytes; `\tfailed\t`; second Ctrl+C exits 130 (`test_pty.py:182-215`) |
| `test_pty_typed_role_records_builder` | live `builder analysis complete`; Builder/`done`/`verify the seam` (`test_pty.py:218-260`) |
| `test_pty_confirm_cancel_keeps_composer` | `Run /gh merge`, `Cancel`, confirm footer, `@Principal`; Esc -> idle footer; `/exit` rc 0 (`test_pty.py:262-299`) |
| `test_pty_sigwinch_compact` | ioctl 80->40->80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads (`test_pty.py:302-369`) |

### 9. Snapshot scope — HONEST, not a needle weaken

Snapshots are still idle cockpit + slash palette only. Principal rewrote them at 23:13-23:14 during `test_snapshots_export` (allowed as chrome evidence). They do **not** contain ask, confirm, evidence, Command-turn, or splash chrome. They must not.

Held needles:

| Frame | Held |
|---|---|
| `cockpit-80x24.svg` | `▣─▣─▣ ProductTeam`; no `Directive`; `harness-cli` is a **home row**, not the bar; `@Principal`; idle footer `enter send · / commands · tab agents` |
| `palette-80x24.svg` | `/st` filters `/status` + `/style unsupported`; slash footer; `@Principal` + `/st` |
| Both | role hues `#c084fc` `#60a5fa` `#22c55e` `#f59e0b`; canvas `#0a0a0a`; field `#141414`; no `#0178D4` |

You `#8a8a8a` and err `#ef4444` remain absent from idle frames (D02 9-band residual, unchanged).

### 10. Org One Writer — HELD

Debate named one Worker and `app.py` + `theme.py` (helpers only) + `test_layout.py` + `test_slash.py`. Those four files moved in one window. Principal ran the freeze table and refreshed snapshots. No second Worker on `lib/tui/`. `provider_turn.sh` / `adapter.py` / `session.py` / `test_pty.py` / `test_all_verbs.py` NEEDLES mtimes predate this iter. Theme token table and `ROLE_STYLES` were not edited; only `command_open` / `command_continue` / `completion_card` / `split_evidence_line` were added (`theme.py:218-357`). No new hex (`test_cockpit_token_contract` still in the 52).

---

## Self-grading bias re-audit

Prior gates were re-read against current evidence. Conservative resolution: disputed subjective items keep the lower score until new evidence.

| Pattern | Finding |
|---|---|
| Iter-6 correctly left D12/D16 at 0.0 | Held for D16. D12 moves only as far as new citations reach. |
| Debate predicted D12 ~9.0, D25 ~9.0, D01 ~9.0, D11/D21 ~9.0, D10/D14/D19 ~9.0, D16 stay 0 | Landed 9.1 / 9.1 / 9.1 / 9.1 / 9.1 / 9.0 / 9.1 / 0.0. D14 is 9.0 rather than 9.1 because the non-130 fail card is source-cited, not fixture-proven. |
| Green 52 != 9.0 | **Not inflated.** D16 stays 0.0. D03/D05/D06/D07/D09/D24 stay proof-gap 8.x. |
| D08/D13 without this-iter edits | Re-audited live (inspections 7-8). Both still clear 9.0. PTY confirm and ask native tests still in the 52/5. |
| No implementer-authored `scores.json` | This Reviewer did not edit app code. |

---

## Organization critique

**One Writer:** held. See inspection 10.

**Debate / reviewer friction:** the iter-7 Critic bound the classifier against real `cmd_report`/`cmd_bench` shapes, forbade a second widget / Enter-to-open, required `_toasts` as the toast observation, and forbade dropping `partial output left on disk` from the RichLog. The Worker copied that contract. That prevented a placeholder panel, a test-only parser, and a PTY-interrupt red. Composer width under evidence was proven in a dedicated test rather than by stretching the iter-6 confirm-width fixture; that is in-bounds.

**Freeze coverage / blind spots carried forward:**

- TUI splash is the last zero-score **function**. Iter-8 must implement it and nothing else unless a proof is mechanically coupled to that boot state (composer/footer visibility, skip, `/splash` remaining a Command turn, non-TTY unchanged).
- Empty-home fixture, middle-head pulse, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap, and live-PTY `/report` remain source-or-native-only. They are **not** mechanically coupled to splash. Do not pile them onto iter-8.
- `/workers` glob-latest (`session.py`) remains a second reader beside the honest live strip. Harmless for D24 as scored.
- D28 cannot reach 9.0 on splash alone: freeze section 7 still names empty-artifact **PTY**.

**Evidence completeness:** iter-7 has debate, pytest, isolated PTY, parity, visual-cli, notes, pty-note, this gate, and scores. Argv dry-run and freeze hashes unchanged.

---

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | **9.1** | Compose header/rule/transcript/`#activity`/`#chips`/`#dock`/`#composer-region`/footer (`app.py:329-341`). Activity CSS `display:none` until `.visible`. One `OptionList`; `_dock_kind` in slash/ask/confirm/**evidence** (`app.py:313-317, 820-834`). Every dock above composer; Esc/Enter close restores focus (`test_layout.py:72-73, 888-973`; `test_slash.py:230-247, 281-287`; `test_pty.py:262-299`). Composer >=20 at four sizes and slash/ask/confirm/evidence (`test_layout.py:81-83, 720-777, 917-964`). Splash is boot, not a missing seventh region. Residual: splash overlay unproven (D16). |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs `theme.py:17-60`; token/bash/snapshot tests in the 52. Both SVGs carry role hues and no `#0178D4`. No new hex this iter. Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` (`test_layout.py:100`) <=3 rows, exclusions, no prose dump. Snapshot rows `agcode-learning` / `harness-cli` / `onboarding-flight-control`. Empty copy still not fixture-proven; sort is mapped-first. |
| D04 | Q2 identity | 8.8 | You rail (`test_layout.py:147`). Ask question is a real Builder/Analyst colored turn (`test_layout.py:513, 596`). Live Builder speech held (`test_pty.py:218`). Same markdown fixture now asserts Builder rail `#22c55e` and neutral body (`test_layout.py:842-866`). Not 9.0: Analyst/Critic speaking rails are still ask-or-PTY, not a four-role style matrix. |
| D05 | Q3 header | 8.5 | Wide `▣─▣─▣ ProductTeam · {cwd} · {score}`; compact `ProductTeam {score}`; no `harness-cli`/`Directive` in the bar. PTY 80->40->80 held. Middle-head pulse still source-only (`app.py:931-938` restyles the middle head while busy; no snapshot). |
| D06 | Q4 honest activity | 7.5 | Native braille/mission/`m:ss`/caps 3/2/1+N (`test_layout.py:333`). No live-PTY strip citation. No `ProgressBar`. |
| D07 | Q5 compact and resize | 8.5 | Four sizes + native 80->40->80 + PTY ioctl row held. Composer >=20 at 40 with confirm and evidence (`test_layout.py:81-83, 763-775, 955-968`). Non-9: live activity cap and compact score slot still not asserted on the TTY. |
| D08 | Q6 structured ask | **9.1** | **Re-audit HOLD, still clears 9.0.** Sibling `ask.json` (`app.py:579-608`). Section 6 validation; exact `turn(role, question)`; atomic answer + id-keyed retire (inspection 7). Native single/multi/invalid tests still in the 52. Evidence kind cannot steal the poll. Residual: no live-PTY ask. |
| D09 | Thinking versus speech | 8.2 | Native empty-artifact silent + owned first-bytes (`test_layout.py:402`; markdown fixture also forbids `Thinking…` / `◇ Analyst` in transcript, `test_layout.py:810-811`). Live drain held. Freeze section 7 empty-artifact **PTY** still missing. |
| D10 | R1 markdown-lite | **9.1** | **Clears 9.0.** Heading/fence/+/-/evidence-path/neutral body asserted on the owned Builder rail (`test_layout.py:794-873`). Attached done card does not replay speech (`test_layout.py:873-883`). Residual: not a live-PTY markdown row; fence body is unstyled (freeze allows mute or unstyled). |
| D11 | R2 slash | **9.1** | **Clears 9.0.** Live `help --json` palette. Native `/sta` + `/gate` no-spawn. PTY `/status`/`/gate` held. Mute Command rail for echo/stream/refuse (`theme.py:225-241`; `test_layout.py:978-1030`). Residual: live PTY does not assert the `│ Command` string. |
| D12 | R3 evidence | **9.1** | **Clears 9.0.** Bordered labelled `#dock` (`app.py:128-130, 820-858`). Report/bench Command summaries + withheld paths (inspection 1). Empty buffer paints no chrome. Display-only keys; compact 6/3+`+N`; composer >=20; y-order above composer (inspection 2). Residual: live PTY `/report`. |
| D13 | R4 confirm | **9.2** | **Re-audit HOLD, still clears 9.0.** All three exact argvs intercepted; Run original argv; Cancel/Esc no-spawn (inspection 7). Other mutations still registry-refused. Evidence Enter does not run a write. Residual: PTY proves cancel UI, not live Run. |
| D14 | R5 toasts and cards | **9.0** | **Clears 9.0.** Done card attached (`test_layout.py:873-883`). Interrupt: one warning toast + error card with `partial output left on disk`; PTY needles held (`app.py:1512-1551`; `test_pty.py:182-215`). `/export`/`/provider` information toasts, no extra `wrote ` / `provider →` transcript lines (`test_slash.py:292-374`). Residual: non-130 fail toast+card is source-only (`app.py:1533-1534`). |
| D15 | R6 footer | 9.2 | Idle / busy / slash / ask footers exact (held). Confirm footer extra, proven. Evidence footer `↑↓ · esc close` is honest and does not fall through to slash `enter run` (`app.py:530-532`; `test_layout.py:920`; `test_slash.py:235`). Freeze D15 10.0 names idle/busy/ask/slash — all exact. Residual: compact busy omits provider. |
| D16 | R7 splash | **0.0** | No TUI-owned ASCII heads, skip, or glow cycle. `/splash` remains a CLI Command turn (`app.py:1385`). `rg` finds no splash widget in `lib/tui/app.py`. |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of <=3 rows; compose has no picker; header follows cwd. Snapshots have no switcher. Evidence panel is not a project picker. |
| D18 | Targeting | 9.3 | Focusable chips, `@Role` chrome, Principal default, typed `@Role`, `ROOT PROMPT ROLE`, `prompt_export` else card block, live `@Builder` -> Builder `workers.tsv`. Unchanged this iter; PTY Builder row held. |
| D19 | Defaults | **9.1** | **Clears 9.0.** Dim timestamps on You (`test_layout.py:163-165`) and Command (`theme.py:225-234`). `/export` is a session toast, not a transcript line (`test_slash.py:345-367`). Token table unchanged. Residual: no `/copy` verb exists; freeze means copy is not chrome, which is now held. |
| D20 | Palette backend seam | 9.7 | Live `help --json` (`adapter.py`); dry-run `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | **9.1** | **Clears 9.0.** Real executable argv + stream. Native 18-verb per-turn proof (`test_all_verbs.py:70`). Live `/status` complete. Mute Command + `md_line` on the stream (`app.py:1039-1054`; `test_layout.py:978-1007`). Residual: PTY does not assert Command chrome. |
| D22 | Unsupported / chat-only | 9.4 | 15-verb refuse no-spawn. Native + PTY `/gate`. Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit`. Confirm intercept does not touch unsupported. Refuse is now a Command turn; needles still in `transcript_text()`. |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json`; header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd. Snapshot header has no Mode/Directive. |
| D24 | Activity/provider seam | 8.6 | Exact-session poll + caps. `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend. Process-group interrupt held (PTY 5/0). `prompt_export` not captured; live PTY strip unasserted. |
| D25 | Ask/confirm/evidence seams | **9.1** | **Clears 9.0.** Ask file-backed + id-keyed retire + atomic answer (D08). Pre-run write intercept + empty Cancel argv log (D13). Evidence path parsing is product-side `split_evidence_line` at stream time against real report/bench shapes (D12; inspection 1). Residual: live PTY evidence. |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25-37` — in the 52). TUI-owned splash absent. |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run unchanged: real `bin/productteam` 0o775, `shell` false, whole-token deny, `agents --json` allowed. Confirm Run still `_exec_cli` -> `run_argv_stream`. Evidence classifier does not spawn. No new parser of argv. |
| D28 | Required test coverage | 8.5 | Native **52/0** (`iter-7/pytest.txt`). Isolated PTY **5/0** (`pty-test.txt`): all five prior rows, needles unweakened. Parity PASS 33/18/15/6. Visual-cli 14/14 with allowed live-provider hole. Section 7 evidence row now passes natively. **Splash and empty-artifact-PTY rows still fail.** |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash TTY; `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; PTY needles not replaced; One Writer held; unrelated dirty worktree not overwritten. Owner extension did not amend D01-D29. This slice does not claim KEEP. |

---

## Remaining zeros and every sub-9 blocker

Zeros:

| ID | score | Exact failure |
|---|---:|---|
| D16 | 0.0 | No TUI-owned splash / skip / glow cycle. |

Every other sub-9:

| ID | score | Exact failure |
|---|---:|---|
| D03 | 8.5 | Honest empty-home copy not fixture-proven; sort is mapped-first, not recency. |
| D04 | 8.8 | Builder speaking rail now style-asserted; four-role speaking matrix still incomplete. |
| D05 | 8.5 | Compact proven native+PTY; middle-head pulse is source-only. |
| D06 | 7.5 | Native strip/caps; no live PTY activity-strip (braille/`m:ss`/caps) citation. |
| D07 | 8.5 | PTY ioctl 80->40->80 green; composer >=20 at 40; live cap and compact score slot not asserted on the TTY. |
| D09 | 8.2 | Live owned speech held; freeze section 7 empty-artifact **PTY** citation missing. |
| D24 | 8.6 | Interrupt + exact-session + caps proven; `prompt_export` not captured; live PTY strip unasserted. |
| D26 | 5.0 | Non-TTY proven; TUI splash seam absent. |
| D28 | 8.5 | Native+PTY+parity+visual green; section 7 splash + empty-artifact-PTY still fail. |

Cleared this iter (no longer blockers): **D01, D10, D11, D12, D14, D19, D21, D25**. Re-audit holds: **D08, D13, D15**.

---

## Iter-8 bind (TUI-owned splash only)

Hand the Worker **this contract**, not `iter-6/notes.md`, not `extension-blockers.md` iter-8 "header/home reachability", and not an unbound "polish remaining chrome" prompt. One Writer. Skip formatters, linters, and project-wide suites.

### Why this slice is splash and only splash

D16 is the last zero-score **function**. Freeze R7 / D26's splash half are one boot state. Empty-home, middle-head pulse, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap, and live-PTY `/report` are proof gaps on **already-implemented** functions. They are not mechanically coupled to drawing ASCII heads. Piling them on is how a Worker times out or ships a fake glow.

Mechanically coupled (must be part of the splash implementation, not extra features):

- Composer and footer remain mounted and visible during splash; `@Principal` stays on screen.
- Any key skips to idle cockpit without submitting composer text and without spawning.
- Idle boot is all-neutral; live glow uses existing role hues / `OK` (no new hex).
- `CONSULT_NO_SPLASH=1` must skip the TUI boot splash so the existing 52 tests still land on idle home.
- `/splash` after skip/finish remains the real CLI Command turn (already a Command rail).
- Non-TTY `productteam tui` remains exit 2 / empty stdout / `requires an interactive TTY` / no ESC under `NO_COLOR`.

### Files the Worker may touch

| File | Why |
|---|---|
| `lib/tui/app.py` | boot splash state on the existing compose tree; skip; glow cycle; `CONSULT_NO_SPLASH` short-circuit; composer/footer stay visible |
| `lib/tui/theme.py` | **only** ASCII head helper(s) reusing existing tokens/glyphs. **No new hex. No token table edits. No ROLE_STYLES changes.** |
| `lib/tui/tests/test_layout.py` | native splash: once, skip, idle-neutral, exact glow order, composer/footer visible, not graph / not `ROBOTS_MARK` |
| `lib/tui/tests/test_nontty.py` | only if a splash change would otherwise regress the existing two non-TTY rows — do not weaken them |

**May not touch:** `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` assertions (existing five must stay exact), `test_all_verbs.py` NEEDLES, `test_slash.py` (evidence/Command/toast/confirm needles stay), Bash modules (`lib/splash.sh`, `lib/repl.sh`), freeze files, unrelated dirty worktree. Snapshots: Principal-only refresh after green pytest; idle snapshot must remain the post-skip cockpit, not a splash frame unless a **new** named splash snapshot is added without weakening the two existing files.

### Mechanics (bound)

1. **Existing compose tree.** Do not replace `compose()` with a second `Screen` that drops composer/footer. Do not cover the composer with `ModalScreen`. A boot overlay on the transcript, or a `splash` class on `Screen` that paints ASCII heads **above** the still-mounted composer/footer, is in bounds. Close/skip restores idle home and `composer.focus()`.
2. **Once.** Splash runs at boot (when `CONSULT_NO_SPLASH` is unset). It does not replay on resize, slash, or provider start.
3. **ASCII heads, not the Bash graph.** Futuristic angular line-art heads. Idle = all-neutral (no role hue glow). Live boot glow cycles **one head at a time** Principal -> Analyst -> Builder -> Principal. Live subtitle names the glowing head. Glyphs stay `◆ Principal` `◇ Analyst` `▸ Builder`. Do not render `lib/splash.sh` six-node output. Do not use `ROBOTS_MARK` half-blocks from `lib/repl.sh`.
4. **Skip.** Any key (including Enter, Esc, `/`) skips immediately to idle cockpit. Enter during splash must **not** `submit_composer`. After skip, idle footer is `enter send · / commands · tab agents` and `@Principal` is visible.
5. **`CONSULT_NO_SPLASH=1`.** When set (current native/PTY default), boot goes straight to idle home. Existing tests must not start failing because splash ate the first seconds.
6. **`/splash`.** After skip or natural finish, typing `/splash` still runs the real CLI verb as a mute Command turn. It does not restart the TUI boot splash as a second framework.
7. **No new hex, no ProgressBar, no determinate bar, no second `#dock` steal.** Glow uses `PRINCIPAL` / `ANALYST` / `BUILDER` / `OK` already in `theme.py`.

### Worker check (one targeted file)

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q
```

Necessary, not sufficient. Principal owns:

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 5 pass
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

### Non-regression needles (exact)

- All five PTY rows listed in inspection 8.
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`; `test_confirm_run_exact_argv_for_all_three_intercepts`.
- Ask tests: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer >=20.
- Evidence: `test_report_stream_evidence_panel`, `test_bench_stream_evidence_panel`, `test_report_missing_args_prints_usage` (no fake panel).
- Command/toast/card: `test_command_rail_mute_no_role_hues`, `test_export_writes_markdown`, `test_provider_sets_session_env`, `test_provider_speech_markdown_and_attached_done_card`.
- `test_nontty_refusal`, `test_nontty_no_color_no_escapes`.
- `test_all_verbs.py` NEEDLES including `splash: ("▣",)` in the **Command / `_turns` cli delta**, not as TUI boot art.

### Honest dimension lift after iter-8 (not a blanket 9.0)

| ID | After iter-8 | Why not higher / still out |
|---|---|---|
| **D16** | 0.0 -> ~9.0 | TUI-owned heads + skip + idle-neutral + exact glow + composer/footer visible. Residual to 10: live-PTY splash frame optional. |
| **D26** | 5.0 -> ~9.0 | Splash seam + `/splash` Command separation + non-TTY held. Residual: live-PTY splash. |
| **D01 / D15** | hold >=9 | Splash must not cover composer or steal the evidence/ask/confirm footer machine. |
| **D08 / D11 / D12 / D13 / D14 / D21 / D25 / D27 / D29** | hold >=9 | Do not regress ask, Command, evidence, confirm, toasts, argv-only, PTY needles. |
| **D28** | 8.5 -> ~8.7 | Splash section 7 row lands; empty-artifact PTY still fails. **Not 9.0.** |
| **D03 / D04 / D05 / D06 / D07 / D09 / D24** | hold | Proof-gap work is **out** of iter-8. |

**Explicitly out of iter-8 (feature-creep cut):** middle-head pulse, empty-home fixture, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot, live-PTY `/report` evidence, glob-latest ask, substring confirm, Enter-to-open files, a second `#splash` widget that covers the composer, `ModalScreen` splash, `ROBOTS_MARK` / six-node graph, new hex, weakened/replaced PTY or `/gate` needles, two writers, formatters.

Those proof gaps belong in iter-9/10 **after** splash converges as a function, and only if the Reviewer still reports them as sub-9.

---

## Verdict

**FAIL.** Iter-7 implemented the bound evidence+Command+toast+card machine: product-side report/bench split, bordered labelled `#dock`, mute Command rails, observable session toasts, append-only attached cards, and a speaking-turn markdown-lite snapshot. **D01, D10, D11, D12, D14, D19, D21, and D25 clear 9.0.** D08/D13 re-audit holds. PTY 5/0 with exact needles. Remaining zero: **D16**.

Principal: do not write `final-report.md`. Keep the shipped cockpit and registry row. Under `extension.md`, spawn **one** Worker on the iter-8 splash bind only. Stop early only when every D01-D29 is >= 9.0; otherwise continue through iter-10 and refresh `not-converged.md`.
