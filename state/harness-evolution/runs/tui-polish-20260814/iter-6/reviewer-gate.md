# Reviewer gate — iter-6

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-6`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`); owner schedule extension `extension.md` (iter-6…iter-10, freeze immutable). Missing, stale, or uncited evidence scores 0.0. Average does not compensate. PASS only if every score ≥ 9.0.

**Verdict: FAIL — not converged. D08, D13, and D15 now clear 9.0. Remaining zeros are D12 and D16.**

The bound ask+confirm dock machine landed. Native suite is 47/0. Real PTY is 5/0, including live `/gh merge` Esc. That is not freeze acceptance. Bordered evidence, TUI-owned splash, mute Command rails, attached cards, and session toasts are still absent.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D12`, `D16`) |
| ≥ 9.0 | D02, D08, D13, D15, D17, D18, D20, D22, D23, D27, D29 (11/29) |
| Native pytest | **47 passed, 0 failed** (`iter-6/pytest.txt`) — 8 new tests over iter-5's 39 |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Three required outputs

1. **Final verdict:** FAIL. Do **not** write `final-report.md`. Do **not** delete `lib/tui/` or the `tui` registry row. Continue only under `extension.md` into the bound iter-7 slice below.
2. **Scores:** `iter-6/scores.json` (this gate). Every D01–D29 has a current path or command citation.
3. **Explicit 9.0 decisions:**
   - **D08 clears 9.0** (9.1). File-backed §6 ask is consumed, rendered, answered, and retired.
   - **D13 clears 9.0** (9.2). All three locked writes intercept; Run is exact original argv; Cancel/Esc is proven no-spawn.
   - **D15 clears 9.0** (9.2). Idle / busy / slash / ask footers are exact. Confirm footer is extra, not a freeze gap. Evidence footer is D12, not D15.

---

## Adversarial inspections (required)

Scope bound by `iter-6/debate.md`: one `#dock` state machine (`slash` / `ask` / `confirm`); `ask.json` beside the live artifact; exact-argv confirm; composer retained. Product mtimes in the Worker window: `app.py` 21:48, `test_slash.py` 21:46, `test_pty.py` 21:47, `test_layout.py` 21:52. Snapshots rewritten 21:57 by Principal `test_snapshots_export` during the freeze table. `theme.py` (11:04), `provider_turn.sh` (11:46), `adapter.py`, `session.py`, and `test_all_verbs.py` needles were not retouched this iter.

### 1. Answer shape — HONEST, exact

Debate required atomic `ask.answer.json` beside the artifact:

```json
{"event": "ask-answer", "ask_id": "<id>", "answers": ["<option-id>", ...], "cancelled": false}
```

`app.py:707–730` writes that object via `ask.answer.json.tmp` then `os.replace`. Enter → `cancelled: false` and `answers = _ask_selection`. Esc → `cancelled: true` and `answers: []`.

Native proof (`test_layout.py:550–561, 621–632`):

- Single Space-then-Enter persists `ask_id=ask-single-1`, `answers=["label-only"]`, `cancelled=false`.
- Multi Esc persists `ask_id=ask-multi-1`, `answers=[]`, `cancelled=true`.
- Temp file is gone after replace.

Residual to 10.0, not a 9.0 fail: Enter in single mode confirms the **selection set** (default or Space-chosen), not the highlighted row. Freeze §6 says Space selects and Enter confirms the structured selection. That is the bound behavior.

### 2. Invalid-file retirement — HONEST, once

`_poll_ask` (`app.py:540–569`) reads only `Path(self._active_artifact).parent / "ask.json"` while `_provider_active` and `_dock_kind == "slash"`. No glob. No fixed path. No transcript scrape.

On any §6 violation, JSON error, or non-object: do **not** open the dock, do **not** write a question turn, emit one mute `ask ignored: <reason>`, `os.replace` → `ask.json.invalid` (`app.py:571–578, 564–568`). Same-id re-emit after consume → `ask.json.done` without reopen (`app.py:559–563`; `test_layout.py:565–571`).

`test_ask_invalid_retires_once_and_refuses` (`test_layout.py:638–705`) covers wrong `event`, invalid role/mode, duplicate option id, two recommended in single, non-boolean recommended, default not in options, JSON-string prose, and raw non-JSON prose. Each case: `ask.json.invalid` exists, `ask.json` gone, no dock, no Builder question turn, one refusal line.

Residual to 10.0: invalid events do not record `_ask_seen_id`; a failed `os.replace` could retry the mute line. Not observed in the 47.

### 3. Exact confirmation / no-spawn — HONEST

Matching is `tuple([verb, *session.tokenize(args)]) in _CONFIRM_ARGVS` after classify==supported and **before** `_exec_cli` (`app.py:737–741, 1206–1211`). Exact lists only:

| Slash | argv |
|---|---|
| `/gh merge` | `["gh", "merge"]` |
| `/checks --allow-dirty` | `["checks", "--allow-dirty"]` |
| `/onboarding --yes` | `["onboarding", "--yes"]` |

`/gh preflight` is **not** intercepted (`test_slash.py:333–348` → `spawns == [["gh", "preflight"]]`). Unsupported `/gate` still refuses with zero spawns (`test_slash.py:124`; PTY `test_pty.py:171–179`).

Run reuses the stored original argv — no re-tokenize (`app.py:759–767`). Native Run log is exactly the three argvs in order (`test_slash.py:261–290`). Cancel (arrow+Enter) and Esc leave `spawns == []` for all three (`test_slash.py:293–329`). Live PTY `/gh merge` shows `Run /gh merge`, `Cancel`, confirm footer, `@Principal`; Esc restores idle footer; `/exit` rc 0 (`test_pty.py:262–299`; `pty-note.md:6–7`). The PTY row correctly does **not** claim an argv log; the recorder is the freeze §7 empty-log proof.

Residual to 10.0: live PTY Run of the three writes is not captured; native recorder is.

### 4. Visible composer — HONEST, repaired

A live defect: auto-width `#role-prefix` ate the Horizontal and left the composer an off-screen sliver. CSS now pins `#role-prefix { width: 12 }` and `#composer { width: 1fr }` (`app.py:123–136`).

Proof:

- `test_four_sizes` requires `composer.region.width >= 20` at 120×36 / 80×24 / 60×24 / 40×20, idle and with slash dock (`test_layout.py:46–58`).
- `test_composer_width_visible_in_dock_states` (`test_layout.py:708–767`) repeats ≥20 for idle / slash / ask / confirm at 80 and for confirm at 40; Esc closes confirm.
- Dock y-order: `dock.region.y + height <= composer.region.y` (`test_layout.py:514–518`).
- Real PTY confirm keeps `@Principal` on screen (`test_pty.py:289`; `pty-note.md:8`).
- Idle snapshot composer line is `@Principal` (`cockpit-80x24.svg:154`). Palette snapshot shows `@Principal` **and** typed `/st` (`palette-80x24.svg:155`) — the filter is in the composer, not a second search box.

Close restores `composer.focus()` (`app.py:1056–1060`; ask Enter/Esc `test_layout.py:553–554, 624–625`; confirm Esc PTY idle footer).

### 5. Snapshot scope — HONEST, not a needle weaken

Snapshots are idle cockpit + slash palette only. Principal rewrote them at 21:57 during `test_snapshots_export` (allowed as chrome evidence). They do **not** contain ask, confirm, or evidence chrome. They must not.

Held needles:

| Frame | Held |
|---|---|
| `cockpit-80x24.svg` | `▣─▣─▣ ProductTeam · exp-tui-migration · —`; no `Directive`; `harness-cli` is a **home row**, not the bar; `@Principal`; idle footer `enter send · / commands · tab agents` |
| `palette-80x24.svg` | `/st` filters `/status` + `/style unsupported`; slash footer; `@Principal` + `/st` |
| Both | role hues `#c084fc` `#60a5fa` `#22c55e` `#f59e0b`; canvas `#0a0a0a`; field `#141414`; no `#0178D4` |
| Four-size export | still asserts no cyan (`test_layout.py:63`) |

You `#8a8a8a` and err `#ef4444` remain absent from idle frames (D02 9-band residual, unchanged).

### 6. Org One Writer — HELD

Debate named one Worker and `app.py` + `test_layout.py` + `test_slash.py`, with a PTY confirm **row** allowed in `test_pty.py`. Those four files moved in one window. Principal ran the freeze table (`pytest.txt`, `pty-test.txt`, `cli-interface-parity.txt`, `visual-cli.txt`, `pty-note.md`, `notes.md`). No second Worker on `lib/tui/`. `provider_turn.sh` / `adapter.py` / `session.py` / `theme.py` / `test_all_verbs.py` mtimes predate this iter.

Composer-width CSS is in the Worker `app.py` mtime, not a parallel writer. PTY needles for status/gate, interrupt, `@Builder`, and SIGWINCH are still exact (`test_pty.py:171–179, 182–215, 218–260, 302–369`).

---

## Self-grading bias re-audit

Prior gates were re-read against current evidence. Conservative resolution: disputed subjective items keep the lower score until new evidence.

| Pattern | Finding |
|---|---|
| Iter-5 correctly left D08/D12/D13/D16/D25 at 0.0 | Held for D12/D16. D08/D13/D25 move only as far as new citations reach. |
| Debate predicted D08 ~9.0, D13 ~9.0, D15 ~9.0, D01 ~8.5, D25 ~6.5, D28 ~7.8 | Landed 9.1 / 9.2 / 9.2 / 8.7 / 6.7 / 7.9. D01 is 0.2 above the debate floor because composer width is now proven, not because evidence exists. |
| Green 47 ≠ 9.0 | **Not inflated.** D12/D16 stay 0.0. D11/D21 stay Command-rail-less. D10/D14 stay detached-card. |
| D15 was 8.0 for missing ask **and** evidence footers | Freeze D15 10.0 names idle / busy / ask / slash only. Evidence footer is a D12 surface. Ask footer now exact → D15 clears 9.0. Confirm footer is contract extra. |
| D08 without live-PTY ask | Freeze §7 names fixture **and** targeted test/PTY evidence. File-backed `ask.json` is the freeze-named equivalent (`frozen-benchmark.md:118–119, 249`). Native fixture tests are the targeted test. Residual is 10.0-band, not a 9.0 fail. |
| No implementer-authored `scores.json` | This Reviewer did not edit app code. |

---

## Organization critique

**One Writer:** held. See inspection 6.

**Debate / reviewer friction:** the iter-6 Critic bound the six load-bearing holes (ask path, answer shape, one-time retire, validation failure, token-exact confirm, argv-empty Cancel). The Worker copied that contract, not the unbound Principal prose. That prevented a second `OptionList` / `ModalScreen` / substring intercept. The composer-width sliver was an unstated dock-steal variant; catching it in the same slice protected D01.

**Freeze coverage / blind spots carried forward:**

- Evidence + Command/toast/card are one semantic family and must ship together (iter-7 bind below). Shipping evidence as extra transcript lines, or Command as toasts, would fail D12/D11/D14 at once.
- Empty-home copy, middle-head pulse, live-PTY activity strip, empty-artifact PTY, and `prompt_export` capture remain source-or-native-only. Still not this slice.
- `/workers` glob-latest (`session.py`) remains a second reader beside the honest live strip. Harmless for D24 as scored.

**Evidence completeness:** iter-6 has debate, pytest, isolated PTY, parity, visual-cli, notes, pty-note, this gate, and scores. Argv dry-run and freeze hashes unchanged. `not-converged.md` still describes the iter-5 close plus a stale owner-exit note; this gate is the current independent verdict. Do not treat `owner-exit.md` (which claimed missing notes/parity and 45/4) as this iter's score — those artifacts now exist and the suite is 47/5.

---

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 8.7 | Compose is header/rule/transcript/`#activity`/`#chips`/`#dock`/`#composer-region`/footer (`app.py:305–317`). Activity CSS `display:none` until `.visible`. One `OptionList`; `_dock_kind` ∈ slash/ask/confirm (`app.py:289–302, 313`). Ask+confirm sit above composer; Esc/Enter close restores focus (`test_layout.py:514–518, 553–554`; `test_pty.py:293–294`). Composer ≥20 at four sizes and all dock states (`test_layout.py:46–58, 708–767`). **Evidence dock still absent.** |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs `theme.py:17–60`; token/bash/snapshot tests in the 47. Both SVGs carry role hues and no `#0178D4`. Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` (`test_layout.py:88`) ≤3 rows, exclusions, no prose dump. Snapshot rows `agcode-learning` / `harness-cli` / `onboarding-flight-control`. Empty copy still not fixture-proven. |
| D04 | Q2 identity | 8.6 | You rail (`test_layout.py:135`). Ask question is a real Builder/Analyst colored turn (`test_layout.py:520–526, 595`). Live Builder speech held (`test_pty.py:218`). No speaking-turn markdown-lite snapshot. |
| D05 | Q3 header | 8.5 | Wide `▣─▣─▣ ProductTeam · {cwd} · {score}`; compact `ProductTeam {score}`; no `harness-cli`/`Directive` in the bar. PTY 80→40→80 held. Middle-head pulse still source-only. |
| D06 | Q4 honest activity | 7.5 | Native braille/mission/`m:ss`/caps 3/2/1+N. No live-PTY strip citation. No `ProgressBar`. |
| D07 | Q5 compact and resize | 8.5 | Four sizes + native 80→40→80 + PTY ioctl row held. Composer now ≥20 at 40 (`test_layout.py:46–58, 751–763`). Non-9: live activity cap and compact score slot still not asserted on the TTY. |
| D08 | Q6 structured ask | **9.1** | **Clears 9.0.** Sibling `ask.json` of `_active_artifact` (`app.py:532–569, 1297–1300`). §6 validation (`app.py:580–633`). Exact question via `turn(role, question)` (`app.py:647`; hue proof `test_layout.py:520–526`). Labels/descriptions/recommended/`k of n`/↑↓/Space/Enter/Esc (`test_layout.py:501–581, 584–635`). Fixture seam; no scrape; no second supervisor. Atomic answer + id-keyed retire (inspections 1–2). Residual: no live-PTY ask; `k of n` lives in the footer (debate-bound). |
| D09 | Thinking versus speech | 8.2 | Native empty-artifact silent + owned first-bytes (`test_layout.py:390`). Live drain held. Freeze §7 empty-artifact **PTY** still missing. `rg` finds no `Thinking` in `lib/tui/` except the test forbid. |
| D10 | R1 markdown-lite | 6.0 | `theme.py:144–174` heading/fence/+/-/evidence-path. CLI/provider call `md_line`. Completion card still detached (`app.py:1354–1362`). No speaking-turn markdown snapshot. |
| D11 | R2 slash | 7.5 | Live `help --json` palette. Native `/sta` + `/gate` no-spawn. PTY `/status`/`/gate` held. Slash echo is still unstyled `Text`, not a mute Command rail (`app.py:1151–1153`). |
| D12 | R3 evidence | **0.0** | No bordered labelled panel. `/report`/`/bench` still `_exec_cli` → `_append_cli_line` into the transcript (`app.py:939–942, 1211, 1216`). |
| D13 | R4 confirm | **9.2** | **Clears 9.0.** All three exact argvs intercepted; Run original argv; Cancel/Esc no-spawn (inspection 3). Other mutations still registry-refused. Residual: PTY proves cancel UI, not live Run. |
| D14 | R5 toasts and cards | 5.8 | Interrupt toast + partial + `failed` + 130 held (`test_pty.py:182–215`). Done card still detached (`app.py:1354–1362`). `/export` still a mute transcript line (`app.py:1171–1177`; `test_slash.py:200–223`). |
| D15 | R6 footer | **9.2** | **Clears 9.0.** Idle `enter send · / commands · tab agents`; busy `ctrl+c interrupt · m:ss · {provider}` / compact `ctrl+c · m:ss`; slash `enter run · tab complete · ↑↓ choose · esc close`; ask single `{k} of {n} · ↑↓ choose · space select · enter confirm · esc cancel`; ask multi `space toggle` (`app.py:475–504`; `test_layout.py:321, 538–545, 597–619`; SVGs). Confirm `↑↓ choose · enter run · esc cancel` proven natively and on PTY (`test_slash.py:256`; `test_pty.py:284–294`). Freeze 10.0 names idle/busy/ask/slash — all exact. Residual: compact busy omits provider. |
| D16 | R7 splash | **0.0** | No TUI-owned ASCII heads, skip, or glow cycle. `/splash` remains a CLI turn. |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of ≤3 rows; compose has no picker; header follows cwd. Snapshots have no switcher. |
| D18 | Targeting | 9.3 | Focusable chips, `@Role` chrome, Principal default, typed `@Role`, `ROOT PROMPT ROLE`, `prompt_export` else card block, live `@Builder` → Builder `workers.tsv`. Composer prefix now width-bounded so `@Role` stays visible (inspection 4). |
| D19 | Defaults | 8.0 | Dim timestamps on You. Copy remains a transcript line (`app.py:1171–1177`), not a session toast. |
| D20 | Palette backend seam | 9.7 | Live `help --json` (`adapter.py:147–154`); dry-run `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | 8.2 | Real executable argv + stream. Native 18-verb per-turn proof. Live `/status` complete. Not a mute Command rail (`app.py:1153`). |
| D22 | Unsupported / chat-only | 9.4 | 15-verb refuse no-spawn. Native + PTY `/gate`. Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit`. Confirm intercept does not touch unsupported (`test_slash.py:124` still zero spawns). |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json`; header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd. Snapshot header has no Mode/Directive. |
| D24 | Activity/provider seam | 8.6 | Exact-session poll + caps. `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend. Process-group interrupt held. `prompt_export` not captured; live PTY strip unasserted. |
| D25 | Ask/confirm/evidence seams | 6.7 | Ask file-backed + id-keyed retire + atomic answer (D08). Pre-run write intercept + empty Cancel argv log (D13). **Evidence path parsing still absent** (D12). Debate floor was ~6.5; +0.2 for invalid-retire + exact answer shape. Not 9.0. |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25–37`). TUI-owned splash absent. |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run unchanged: real `bin/productteam` 0o775, `shell` false, whole-token deny, `agents --json` allowed. Confirm Run still `_exec_cli` → `run_argv_stream`. No new parser. |
| D28 | Required test coverage | 7.9 | Native **47/0** (`iter-6/pytest.txt`). Isolated PTY **5/0** (`pty-test.txt`): prior four plus confirm-cancel. Parity PASS 33/18/15/6. Visual-cli 14/14 with allowed live-provider hole. §7 ask + confirm rows now pass. **Evidence, splash, and empty-artifact-PTY rows still fail.** |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash TTY; `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; PTY needles not replaced; One Writer held; unrelated dirty worktree not overwritten. Owner extension did not amend D01–D29. This slice does not claim KEEP. |

---

## Remaining zeros and every sub-9 blocker

Zeros:

| ID | score | Exact failure |
|---|---:|---|
| D12 | 0.0 | No bordered labelled evidence panel. `/report`/`/bench` still drown the transcript. |
| D16 | 0.0 | No TUI-owned splash / skip / glow cycle. |

Every other sub-9:

| ID | score | Exact failure |
|---|---:|---|
| D01 | 8.7 | Ask+confirm docks and visible composer proven; evidence dock still absent. |
| D03 | 8.5 | Honest empty-home copy not fixture-proven; sort is mapped-first, not recency. |
| D04 | 8.6 | Ask question turn is identity-colored; no speaking-turn markdown-lite snapshot. |
| D05 | 8.5 | Compact proven native+PTY; middle-head pulse is source-only. |
| D06 | 7.5 | Native strip/caps; no live PTY activity-strip (braille/`m:ss`/caps) citation. |
| D07 | 8.5 | PTY ioctl 80→40→80 green; composer ≥20 at 40; live cap and compact score slot not asserted on the TTY. |
| D09 | 8.2 | Live owned speech held; freeze §7 empty-artifact **PTY** citation missing. |
| D10 | 6.0 | No speaking-turn markdown-lite snapshot; completion card detached. |
| D11 | 7.5 | PTY slash held; echo is not a mute Command rail (`app.py:1153`). |
| D14 | 5.8 | Interrupt toast held; done card detached; `/export` extra transcript line. |
| D19 | 8.0 | Copy remains a transcript line, not a session toast. |
| D21 | 8.2 | Live `/status` complete; Command rail absent. |
| D24 | 8.6 | Interrupt + exact-session + caps proven; `prompt_export` not captured; live PTY strip unasserted. |
| D25 | 6.7 | Ask+confirm seams real; evidence path parsing absent. |
| D26 | 5.0 | Non-TTY proven; TUI splash seam absent. |
| D28 | 7.9 | Native+PTY+parity+visual green; §7 evidence/splash/empty-artifact-PTY still fail. |

Cleared this iter (no longer blockers): **D08, D13, D15**.

---

## Iter-7 bind (evidence panel + only coherent Command/toast/card semantics)

Hand the Worker **this contract**, not `iter-5/notes.md` and not an unbound “polish remaining chrome” prompt. One Writer. Skip formatters, linters, and project-wide suites.

### Why these must ship together

Freeze R2 / R3 / R5 / R1 share one output vocabulary:

| Surface | Is | Is not |
|---|---|---|
| Mute **Command rail** | slash echo, supported summary, refusal+usage | a role turn, a toast, a file list |
| **Evidence panel** | bordered labelled dock of parsed report/bench paths | extra Command lines, a picker, a Modal |
| **Toast** | fail/interrupt; session verbs `/export` and provider cycle | a transcript line, a Command rail |
| **Card** | done/error attached to the originating role turn | a detached `transcript.write` status row |

Shipping evidence as more `_append_cli_line` output, or Command as `notify()`, or session verbs as rails, fails D12/D11/D14 in a circle. Splash, pulse, empty-home, and PTY activity-strip are **out**.

### Files the Worker may touch

| File | Why |
|---|---|
| `lib/tui/app.py` | evidence dock-kind or labelled panel in the existing dock-above-composer slot; Command-rail writer; attach done/error card; session toasts; report/bench path parse **before** transcript write |
| `lib/tui/theme.py` | **only** a mute Command-rail helper + optional card-on-turn helper reusing `MUTE` / `RAIL` / `status_tag`. **No new hex. No token table edits.** |
| `lib/tui/tests/test_layout.py` | evidence panel + Command rail + attached card + speaking-turn markdown-lite snapshot |
| `lib/tui/tests/test_slash.py` | `/report`/`/bench` summary-vs-files; `/export` toast without extra transcript line; `/gate` no-spawn needle **unchanged** |

**May not touch:** `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` assertions (existing five must stay exact), `test_all_verbs.py` `NEEDLES` (report still contains `iter-1`; bench still contains `Benchmark` **in the Command-summary delta**), Bash modules, freeze files, unrelated dirty worktree. Snapshots: Principal-only refresh after green pytest.

### Mechanics (bound)

1. **One dock slot.** `_dock_kind` gains `"evidence"` on the existing above-composer region. No `ModalScreen`, no second `OptionList` used as a picker, no `Button`, no `ProgressBar`. Slash/ask/confirm kinds unchanged. `_refresh_dock` still early-returns when kind ≠ `"slash"`.
2. **Evidence is display-only.** A labelled bordered `Static`/`RichLog` (or OptionList with **no** Enter-to-run) lists parsed file paths. Esc / close → `_close_dock(); composer.focus()`. Composer stays mounted and ≥20 columns (reuse `test_composer_width_visible_in_dock_states` pattern).
3. **Parse, do not dump.** In `_append_cli_line` / post-stream for argv[0] in `{report, bench}` only: path-shaped lines (reuse `theme._EVIDENCE_RE` or an equivalent `path: rest` / path-only rule named in the test) go to the panel buffer; all other lines are the mute Command summary. If the buffer is empty, do not open a fake panel. Long lists must be absent from `transcript_text()` after the Command summary.
4. **Command rail.** One helper, mute rail + mute `Command` label, never a role hue. Use it for: slash request echo (`app.py:1153` today), streamed supported summary, unsupported `chat_reason`+usage. `/gate` refuse text and no-spawn recorder must still pass.
5. **Toasts vs cards.** `/export` and `/provider` → mute `notify` toast **and** no extra transcript line (update `test_export_writes_markdown` to assert the file still exists and `"wrote "` is **not** required in `transcript_text()`). Provider done → `status_tag` **on the open speaking rail**, not a detached row (`app.py:1354–1362`). Fail/interrupt keep toast + error card on that turn; partial artifact path may live on the card, not as a second mute echo.
6. **Markdown-lite snapshot.** One native speaking-turn fixture (empty-artifact then bytes with heading / fence / `+` / `-` / evidence path) asserting `md_line` styles on the owned rail. Not a live-provider mock.

### Worker check (one targeted file)

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_slash.py -q
```

Necessary, not sufficient. Principal owns:

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 5 pass
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

### Non-regression needles (exact)

- `test_pty_status_and_gate_refuse` — `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError`.
- `test_pty_provider_interrupt` — live `partial analysis begins`; first Ctrl+C keeps partial + `failed`; second Ctrl+C exits 130.
- `test_pty_typed_role_records_builder` — live `builder analysis complete`; Builder/`done`/`verify the seam`.
- `test_pty_confirm_cancel_keeps_composer` — `Run /gh merge`, `Cancel`, confirm footer, `@Principal`, Esc → idle footer, `/exit` rc 0.
- `test_pty_sigwinch_compact` — ioctl 80→40→80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads.
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`.
- Ask tests: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer ≥20.
- `test_all_verbs.py` `NEEDLES["status"]`, `NEEDLES["report"]` (`iter-1`), `NEEDLES["bench"]` (`Benchmark`), `gh preflight`.

### Honest dimension lift after iter-7 (not a blanket 9.0)

| ID | After iter-7 | Why not higher / still out |
|---|---|---|
| **D12** | 0.0 → ~9.0 | Bordered labelled panel + Command summary + files withheld. Residual to 10: live PTY `/report`. |
| **D25** | 6.7 → ~9.0 | Ask + confirm + evidence path parsing all real. |
| **D01** | 8.7 → ~9.0 | Evidence dock completes “every dock above composer”. Splash is boot, not a seventh-region miss. |
| **D11 / D21** | → ~9.0 | Mute Command rail for run/refuse/usage; PTY slash needles still exact. |
| **D10 / D14 / D19** | → ~9.0 | Markdown snapshot + attached done/error card + session toasts without extra lines. |
| **D15** | hold ≥9 | Evidence footer optional; freeze 10.0 already satisfied. |
| **D08 / D13 / D22 / D27 / D29** | hold ≥9 | Do not regress answer shape, retire, exact confirm, no-spawn, argv-only. |
| **D16 / D26** | stay 0 / 5 | Splash is iter-8. |
| **D28** | 7.9 → ~8.5 | Evidence §7 row lands; splash + empty-artifact PTY still fail. |

**Explicitly out of iter-7:** TUI splash, middle-head pulse, empty-home fixture, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot, glob-latest ask, substring confirm, re-tokenizing Run argv, second writer, formatters, weakened/replaced PTY or `/gate` needles.

---

## Verdict

**FAIL.** Iter-6 implemented the bound ask+confirm dock machine: exact `ask-answer` shape, invalid-file retirement, exact three-write confirm with proven empty Cancel argv log, and a materially visible composer under every dock. **D08, D13, and D15 clear 9.0.** Remaining zeros: **D12, D16**. Remaining sub-9 blockers are listed above.

Principal: do not write `final-report.md`. Keep the shipped cockpit and registry row. Under `extension.md`, spawn **one** Worker on the iter-7 bind only. Stop early only when every D01–D29 is ≥ 9.0; otherwise continue through iter-10 and refresh `not-converged.md`.
