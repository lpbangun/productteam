# Reviewer gate — iter-5 (final)

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-5`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`). Missing, stale, or uncited evidence scores 0.0. Average does not compensate. PASS only if every score ≥ 9.0.

**Verdict: FAIL — not converged. Write `not-converged.md`. Do not start iter-6.**

The repair slice restored a green native suite and the four real-PTY rows. That is not freeze acceptance. Structured ask, confirm interception, bordered evidence, TUI-owned splash, and mute Command rails are still absent. Five implementation iterations are exhausted.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D08`, `D12`, `D13`, `D16`, `D25`) |
| ≥ 9.0 | D02, D17, D18, D20, D22, D23, D27, D29 (8/29) |
| Native pytest | **39 passed, 0 failed** (`iter-5/pytest.txt`) — recovered from iter-4's 4 failed / 35 passed |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Three required outputs

1. **Final verdict:** FAIL. KEEP the shipped 2026-08-13 cockpit and the `tui` registry row. Do **not** write `final-report.md`. Do **not** delete `lib/tui/`.
2. **Scores:** `iter-5/scores.json` (this gate). Every D01–D29 has a current path or command citation.
3. **Stop artifact:** Principal must write `state/harness-evolution/runs/tui-polish-20260814/not-converged.md` naming every sub-9 dimension below. No sixth iteration (`GOAL-LOOP.md:53–55,253–254`; `frozen-benchmark.md:304–305`).

---

## Adversarial diff / behavior review

Scope bound by `iter-5/debate.md`: one Worker, `lib/tui/app.py` + `lib/tui/tests/test_pty.py` match path only. Product mtimes match that bound (`app.py` 14:01, `test_pty.py` 14:04). Snapshots were rewritten at 14:08 by Principal `test_snapshots_export` during the freeze table — allowed as chrome evidence, not a Worker feature ride-along. `provider_turn.sh`, `adapter.py`, `theme.py`, `test_layout.py` needles, and Bash modules were not retouched this iter.

### 1. Provider live drain — HONEST, restored

Iter-4 failed because `_drain_artifact` ran once, then `proc.wait()` blocked, so `partial analysis begins` and `builder analysis complete` never arrived live.

Current `_provider_thread` (`app.py:977–1003`):

- After `ARTIFACT=` readline and `Path(art).parent.parent` session retarget, `size = 0`.
- `while proc.poll() is None`: drain with kept byte offset, flush the rail buffer if `size` grew, `time.sleep(0.05)`.
- Loop does **not** break on `_provider_interrupted`.
- On process death: one final drain, flush, metadata-only `_add_turn("provider", body)` (no second transcript body), then `proc.wait()`, `_provider_done`.
- Speech still enters only through `_drain_artifact` → `_append_provider_chunk` → `_append_provider_line` (`app.py:659–690,1005–1015`). First non-empty bytes open one owned role rail; later chunks are continuations.

PTY proof now green (`iter-5/pty-test.txt` 4 passed; `pytest.txt` 39 passed):

- `test_pty_provider_interrupt` (`test_pty.py:182–215`): live `partial analysis begins`, first Ctrl+C → `interrupting provider` + `partial output left on disk` + artifact bytes + `workers.tsv` `failed`, second Ctrl+C → 130.
- `test_pty_typed_role_records_builder` (`test_pty.py:218–260`): live `builder analysis complete`; Builder/`done`/mission `verify the seam`.

Native empty-artifact row still holds (`test_layout.py:381–408`): running row + empty artifact → no `Thinking…`, no `◇ Analyst` until bytes; one owned turn; `_add_turn` is metadata only.

Residual vs 10.0: freeze §7 still wants a **real-PTY** empty-artifact window (worker running, artifact empty, transcript silent). The interrupt fixture writes immediately then sleeps, so that window is not captured on a TTY.

### 2. Bounded CLI exit — HONEST, inside the debate allowance

`_poll_activity` returns immediately while `_cli_busy` (`app.py:465–471`). It does not 5 Hz-repaint header/footer/activity on the UI thread during `run_argv_stream`. That is the named status-tail repair.

`/exit`/`/quit` while `_cli_busy` starts `_exit_after_cli` (`app.py:840–848,927–933`): wait up to **5.0s** at 0.05s ticks, then `exit`. Debate (`iter-5/debate.md:119–123`) allowed an additional “queued `_append_cli_line` must not be dropped when a later slash arrives” path **after** the poll-paint skip. This is that path, bounded, and it does **not** block `submit_composer` on `_cli_busy` (the forbidden serialize).

First Ctrl+C during CLI (no live provider) still `exit(130)` (`app.py:1057–1058`). Busy footer is still driven from provider/activity, not `_cli_busy` (`app.py:450–458`).

PTY proof: `test_pty_status_and_gate_refuse` (`test_pty.py:171–179`) now has `Product Consulting Harness`, **`harness-cli`**, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError`. Needles were not edited (`debate.md:137–139`).

### 3. Activity session binding — HONEST, held

Re-verified; not glob-latest for the live strip:

- `app.py:267–269` `_activity_session_dir = session.state_root(ROOT) / "runs" / f"session-{os.getpid()}"`.
- `app.py:360–361` `_read_activity_rows` opens **that exact** `workers.tsv`.
- `app.py:951` `ACTIVITY_SESSION_DIR` in the provider `Popen` env; `lib/activity.sh` honors it; `provider_turn.sh:36` `activity_start "$ROLE"`.
- `app.py:976` retargets to `Path(art).parent.parent` after `ARTIFACT=` — same session dir, not a second picker.
- `session.workers_rows` still globs latest (`session.py:131–160`) and is only the `/workers` dump (`app.py:866–877`), never the live strip.

No stale cross-session paint. Caps 3 / 2 / 1+`+N` remain native-proven (`test_layout.py:312–358`).

### 4. Focus / resize / interrupt — HONEST, held

- `on_resize` (`app.py:478–482`) re-renders header/activity/footer and does not steal focus. Native 80→40→80 asserts `app.focused is app.composer` through the sequence (`test_layout.py:337–358`).
- Slash dock open/close still `composer.focus()` (`app.py:746,770`). Chip select restores composer (`app.py:616–624`; `test_layout.py:247–255`).
- Interrupt sequence unchanged: first Ctrl+C sets `_provider_interrupted`, notify, `os.killpg(..., SIGINT)`, `_ensure_stopped` 2s SIGTERM / 1s SIGKILL (`app.py:1044–1077`). Drain loop stays alive until `poll()` is not None, then final drain. Second Ctrl+C → 130. Re-proven this iter (`test_pty.py:182–215`; `pty-note.md:6`).

### 5. Scope / needle regressions — NONE that fail the freeze needle rule

Needles that must remain exact **are** exact:

| Test | Held |
|---|---|
| `test_pty_status_and_gate_refuse` | `Product Consulting Harness`, `harness-cli`, gate usage, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:171–179`) |
| `test_pty_provider_interrupt` | live `partial analysis begins`; interrupt toast; partial on disk; `failed`; 130 |
| `test_pty_typed_role_records_builder` | live `builder analysis complete`; Builder/`done`/mission |
| `test_pty_sigwinch_compact` | ioctl `TIOCSWINSZ` 20×40 then 24×80; stripped wide/restore `▣─▣─▣ ProductTeam`; compact `ProductTeam` **without** `▣─▣─▣` / cwd; `@Principal` retained; 25s waits; `/exit` rc 0 (`test_pty.py:262–329`) |
| `test_all_verbs.py` `NEEDLES["status"]` | unchanged (`Product Consulting Harness`) |

SIGWINCH uses `_strip_ansi` **before** presence and absence checks. `wait_compact` then isolates the suffix after the last stale wide-header line so a still-buffered 80-col frame cannot false-fail “heads absent,” and `ProductTeam` **in that suffix** false-fails a still-wide compact header (heads line would have been excluded, taking `ProductTeam` with it). Glyph needles were not replaced with the compact `ProductTeam` token for the wide/restore rows.

Cuts held: no `ask.json`, no confirm intercept, no evidence panel, no TUI splash, no mute Command rail (`app.py:837` still unstyled `Text(f"/{verb}")`), no Button, no `ProgressBar`, no `activity_start Analyst`, no provider mock on the live PTY path, no second full-body turn.

`test_snapshots_export` rewrote idle SVGs during Principal pytest. Header remains `▣─▣─▣ ProductTeam · exp-tui-migration · —` with no `Directive`; home still three scored rows including `harness-cli` as a **row**, not the bar (`cockpit-80x24.svg:134–137,156`). Palette footer is the slash string (`palette-80x24.svg:157`). Not a needle weaken.

---

## Self-grading bias re-audit

Prior gates were re-read against current evidence. Conservative resolution: disputed subjective items keep the lower score until new evidence.

| Pattern | Finding |
|---|---|
| Iter-4 correctly **dropped** D07/D09/D11/D14/D18/D21/D22/D24/D28 when the suite went red | Held. This gate restores only dimensions whose missing proof was re-captured (D18 8.7→9.3, D22 9.0→9.4, D11 7.0→7.5, D14 4.0→5.8, D21 8.0→8.2, D07 7.3→8.4, D09 7.4→8.2, D24 7.0→8.6, D28 5.0→7.2). |
| Green suite ≠ 9.0 | **Not inflated.** D08/D12/D13/D16/D25 stay 0.0. D07/D09/D24/D28 stay **below 9** despite 39/0. |
| D02 9.3 since iter-2 | Hold. Role hexes are in both SVGs; You `#8a8a8a` and err `#ef4444` still absent from idle frames; Bash two-accent still separate. Residual is a 9-band gap, not a drop. |
| D18/D22 restored to iter-3 values | Evidence returned (live `@Builder`, full `/gate` refuse chain). Restoring a justified drop is not a new gift. |
| D09 7.4 in iter-4 (not 0) | Still the right split: thinking-vs-speech ≠ live-drain. Live drain is now proven; empty-artifact **PTY** is still missing, so D09 is 8.2 not 9. |
| Debate predicted D18 ~9.0, D07 ~8.0, D28 ~6.5 | D18 9.3 matches the restored iter-3 citation set. D07 8.4 (not 9) because PTY compact does not assert activity cap or `ProductTeam {score}` score slot. D28 7.2 (not 8) because four §7 rows are still fail. |
| D17 9.2 / D29 9.2 | Hold. Display-only home and preservation are true; they do not launder missing docks. |

No implementer-authored `scores.json`. This Reviewer did not edit app code.

---

## Organization critique

**One Writer:** held. Debate named one Worker and two files. Only those two product/test files moved in the Worker window. Principal ran the freeze table (`pytest.txt`, `cli-interface-parity.txt`, `visual-cli.txt`, `pty-note.md`). No second writer on `lib/tui/`.

**Debate / reviewer friction:** useful. Iter-4 Reviewer left an “after green, docks may be considered” clause (`iter-4/reviewer-gate.md:90`). Iter-5 Critic cut it (`debate.md:141–147`) because `GOAL-LOOP.md` stops at five. The Principal copied the bound drain / poll-skip / ANSI-strip contract, not the unbound paragraph. That friction prevented a last-iter dock pile-on that would have replayed the 30-minute timeout.

**Freeze coverage / blind spots:**

- The freeze required docks + splash + Command rails **and** live PTY drain/interrupt/SIGWINCH **and** every dim ≥ 9.0 in five iters. Iter-1–3 spent the budget on identity/targeting/focus; iter-4 landed activity/footer/compact and reddened PTY; iter-5 spent the last slot repairing that regression. Ask/confirm/evidence/splash never got a Worker.
- Freeze §7 did not name ANSI-split Textual headers. The ioctl row needed a match-path helper the product freeze did not anticipate.
- Drain-once-then-`wait()` was an unstated streaming hazard. Native empty-artifact tests could not catch it.
- Honest empty-home copy and middle-head pulse have been source-only since iter-1; no fixture was ever added. Freeze 10.0 language implied them; the test table did not force them.
- `/workers` glob-latest (`session.py:137–141`) remains a second reader beside the honest live strip. Harmless for D24 as scored, easy to misread.

**Evidence completeness:** iter-5 has pytest, isolated PTY, parity, visual-cli, notes, debate, this gate, and scores. Argv dry-run and freeze hashes are unchanged. Missing by design until Principal writes it: `not-converged.md` (required), plus run-level `diff-summary.md` / `lessons.md` (`frozen-benchmark.md:309–325`). This Reviewer does not write those.

**No sixth iteration:** `GOAL-LOOP.md:53–55,253–254`; freeze §9.7; debate `iter-5/debate.md:5,141–147`; notes `iter-5/notes.md:18–20`. There is no residual queue. Remaining zeros are the non-convergence record, not a next slice.

---

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 8.0 | `app.py:275–287` compose is header/rule/transcript/`#activity`/`#chips`/dock/`#composer-region`/footer. Activity CSS `display:none` until `.visible` (`app.py:69–82,398–404`). Four-size dock-above-composer + Esc close (`test_layout.py:47–57`, among 39 passed). Ask/confirm/evidence docks still absent. |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs `theme.py:17–60`; `test_cockpit_token_contract` + `test_bash_two_accent_budget` + `test_snapshot_role_hues_and_no_cyan` in the 39. Both SVGs carry `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` and no `#0178D4`. Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`; Rich window chrome still `#c5c8c6`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` (`test_layout.py:79–97`) ≤3 rows, exclusions, no prose dump. Snapshot rows `agcode-learning` / `harness-cli` / `onboarding-flight-control`; no `run-loop`/`smoke` (`cockpit-80x24.svg:135–137`). Empty copy coded (`app.py:581–584`) **not** fixture-proven. Sort is mapped-first (`app.py:579`). |
| D04 | Q2 identity | 8.6 | You rail/label/timestamp (`test_layout.py:126–148`). Speaking rail on first bytes (`app.py:659–679`; `test_layout.py:381–408`). Live Builder speech now streams (`test_pty.py:232–260`; `pty-note.md:7`). No 11ch gutter. Non-9: no speaking-turn markdown-lite snapshot; You hue still idle-SVG absent. |
| D05 | Q3 header | 8.5 | Wide `▣─▣─▣ ProductTeam · {cwd} · {score}` (`app.py:547–562`; `test_layout.py:102–121`; snapshot). Compact `ProductTeam —` native (`test_layout.py:347`) and PTY compact `ProductTeam` without heads/cwd (`test_pty.py:314–318`). No `harness-cli`/`Directive` in the bar. Middle-head pulse is source-only (`app.py:557`). |
| D06 | Q4 honest activity | 7.5 | File-backed strip: braille `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`, role, mission/provider, `m:ss`, caps 3/2/1+N, hide-on-done (`app.py:390–427`; `test_layout.py:312–363`). Exact-session path (audit §3). No `ProgressBar`. Residual: no real-PTY assertion of the strip itself (braille/`m:ss`/caps) during a live provider. |
| D07 | Q5 compact and resize | 8.4 | Four sizes (`test_layout.py:13,60–62`). Native 80→40→80: compact header, 1+N cap, composer focus, restored heads (`test_layout.py:339–358`). PTY ioctl row now green with stripped **same** glyph needles (`test_pty.py:262–329`; `pty-note.md:8`; `pty-test.txt`). Non-9: live activity cap and `ProductTeam {score}` score slot are not asserted on the real TTY resize. |
| D08 | Q6 structured ask | 0.0 | No `ask.json` consumer, OMP dock, single/multi, `k of n`, or fixture (`iter-5/notes.md:20`; compose has only the slash `OptionList`). |
| D09 | Thinking versus speech | 8.2 | Native empty-artifact silent + owned first-bytes (`test_layout.py:381–408`). Live drain restored; PTY speech is one owned stream (`test_pty.py:198–199,232–234`; `app.py:977–999`). `rg` finds no `Thinking` in `lib/tui/` except the test forbid. Residual: freeze §7 live empty-artifact **PTY** citation still missing. |
| D10 | R1 markdown-lite | 6.0 | `theme.py:144–174` heading/fence/+/-/evidence-path; CLI and provider lines call `md_line` (`app.py:654–662`). No speaking-turn snapshot of those cases. Completion card still a detached line (`app.py:1030–1038`). |
| D11 | R2 slash | 7.5 | Live `help --json` palette (`adapter.py:141–154`). Native `/sta` filter + `/gate` no-spawn (`test_slash.py:110–141`). **PTY slash restored:** `/status` includes `harness-cli`; `/gate` refuses and does not spawn (`test_pty.py:171–179`; `pty-note.md:5`). Material gap: slash echo is still unstyled `Text`, not a mute Command rail (`app.py:837`). |
| D12 | R3 evidence | 0.0 | No bordered labelled panel. `/report`/`/bench` still `_exec_cli` → `_append_cli_line` into the transcript (`app.py:890–891,654–657`; `notes.md:20`). |
| D13 | R4 confirm | 0.0 | No intercept. `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` run immediately through `_exec_cli` (`app.py:890–891`). |
| D14 | R5 toasts and cards | 5.8 | Interrupt toast + partial artifact + `failed` + 130 re-proven (`test_pty.py:182–215`; `app.py:1025–1028,1044–1058`). Done card still detached (`app.py:1030–1038`). `/export` still writes a mute transcript line (`app.py:855–858`). |
| D15 | R6 footer | 8.0 | Idle `enter send · / commands · tab agents`; busy `ctrl+c interrupt · m:ss · {provider}` / compact `ctrl+c · m:ss`; slash `enter run · tab complete · ↑↓ choose · esc close` (`app.py:445–458`; `test_layout.py:333–376`; `cockpit-80x24.svg:156`; `palette-80x24.svg:157`). Ask/evidence footers absent. |
| D16 | R7 splash | 0.0 | No TUI-owned ASCII heads, skip, or glow cycle (`notes.md:20`). `/splash` remains a CLI Command turn (`app.py:904`). |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of ≤3 rows (`app.py:567–587`); compose has no picker (`app.py:275–287`); header follows cwd (`app.py:498–507,547–562`). Snapshots have no switcher. |
| D18 | Targeting | 9.3 | Focusable `RoleChip(Static)` click/Enter (`test_layout.py:224–255`); `@Role` chrome not buffer (`app.py:610–614`; `cockpit-80x24.svg:153`); Principal default; typed `@Role` strip (`test_layout.py:260–288`); `ROOT PROMPT ROLE` (`app.py:953–954`; `provider_turn.sh:4–5,24,36`); `prompt_export` else `agent_card_prompt_block` (`provider_turn.sh:47–59`); no `activity_start Analyst`; live `@Builder` → Builder `workers.tsv` (`test_pty.py:218–260`; `pty-test.txt`). Non-10: card prepend is source-proven, not prompt-captured. |
| D19 | Defaults | 8.0 | Dim timestamps on You (`test_layout.py:141–143`). High-contrast tokens as chip hues. Copy remains a transcript line (`app.py:855–858`), not a session toast. |
| D20 | Palette backend seam | 9.7 | `adapter._Palette.load` is live `help --json` (`adapter.py:147–154`); adapter tests in the 39; prebuild `argv-dry-run.json:16–23` `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | 8.2 | Real executable argv + stream (`adapter.py:66–79,82–101`; `app.py:896–925`). Native 18-verb per-turn proof in the 39 (`test_all_verbs.py:70–112`). Live `/status` complete including `harness-cli` (`test_pty.py:174–175`). Remaining: not a mute Command rail (`app.py:837`). |
| D22 | Unsupported / chat-only | 9.4 | 15-verb refuse no-spawn (`test_all_verbs.py:115–141`). Native `/gate` (`test_slash.py:121–141`). **Real-PTY `/gate` chain restored:** usage + `owner-gated`, `no directive` absent (`test_pty.py:176–179`). Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit` (`app.py:840–877`). Non-10: session verbs still emit transcript lines (D14/D19). |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json` (`app.py:488–508`); header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd (`app.py:523–545`); never Mode/Directive (`test_layout.py:120–121`). Honest `—` when unmatched (snapshot). |
| D24 | Activity/provider seam | 8.6 | Exact-session poll + columns + caps (audit §3; `test_layout.py:312–358`). `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend (`provider_turn.sh:24,36,47–59`). Process-group interrupt re-proven (`test_pty.py:182–215`). Residual: `prompt_export` not fixture-captured; live PTY strip chrome unasserted. |
| D25 | Ask/confirm/evidence seams | 0.0 | All three seams absent (`notes.md:20`; no `ask.json`; no pre-run write intercept; no evidence path parsing). |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25–37` in the 39; `argv-dry-run.json` tui rc 2). TUI-owned splash absent. |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run: `argv-dry-run.json:2–14` real `bin/productteam`, mode `0o775`, `shell` false, whole-token deny; `agents --json` allowed rc 0 (`:49–55`). Adapter `shell=False` + forbidden-token tests (`adapter.py:23,72–74`; `test_adapter.py:87–109`). |
| D28 | Required test coverage | 7.2 | Native pytest **39 passed, 0 failed** (`iter-5/pytest.txt`). Isolated PTY **4 passed** (`pty-test.txt`): slash, interrupt, `@Builder`, SIGWINCH. Parity PASS 33/18/15/6 (`cli-interface-parity.txt:35`). Visual-cli 14/14 with allowed live-provider hole (`visual-cli.txt:16`; `notes.md:14`). §7 ask / confirm / evidence / splash rows still fail. Activity-vs-speech live empty-artifact PTY still missing. |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash TTY (`lib/repl.sh:473–476`); `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; PTY needles not replaced; One Writer held. Unrelated dirty worktree not overwritten. This slice did not claim KEEP. |

---

## Sub-9 dimensions (every one) and exact failures

These **must** be named in `not-converged.md`:

| ID | score | Exact failure |
|---|---:|---|
| D01 | 8.0 | Activity region present and conditional; ask/confirm/evidence docks still absent. |
| D03 | 8.5 | Honest empty-home copy not fixture-proven; sort is mapped-first, not recency. |
| D04 | 8.6 | Live speaking rail restored; no speaking-turn markdown-lite snapshot. |
| D05 | 8.5 | Compact proven native+PTY; middle-head pulse is source-only. |
| D06 | 7.5 | Native strip/caps; no live PTY activity-strip (braille/`m:ss`/caps) citation. |
| D07 | 8.4 | PTY ioctl 80→40→80 green; live cap and compact score slot not asserted on the TTY. |
| D08 | 0.0 | No structured ask event, dock, or fixture. |
| D09 | 8.2 | Live owned speech restored; freeze §7 empty-artifact **PTY** citation missing. |
| D10 | 6.0 | No speaking-turn markdown-lite snapshot; completion card detached. |
| D11 | 7.5 | PTY slash restored; echo is not a mute Command rail (`app.py:837`). |
| D12 | 0.0 | No bordered labelled evidence panel. |
| D13 | 0.0 | No confirm intercept; writes run immediately. |
| D14 | 5.8 | Interrupt toast re-proven; done card detached; `/export` extra transcript line. |
| D15 | 8.0 | Idle/busy/slash proven; ask/evidence footers absent. |
| D16 | 0.0 | No TUI-owned splash / skip / glow cycle. |
| D19 | 8.0 | Copy remains a transcript line, not a session toast. |
| D21 | 8.2 | Live `/status` complete; Command rail absent. |
| D24 | 8.6 | Interrupt + exact-session + caps proven; `prompt_export` not captured; live PTY strip unasserted. |
| D25 | 0.0 | Ask/confirm/evidence seams all absent. |
| D26 | 5.0 | Non-TTY proven; TUI splash seam absent. |
| D28 | 7.2 | Native+PTY+parity+visual green; §7 ask/confirm/evidence/splash still fail. |

Zeros that dominate non-convergence: **D08, D12, D13, D16, D25**.

---

## Verdict

**FAIL.** Iter-5 repaired live provider drain, bounded CLI exit so `/status` tails survive, kept exact-session activity binding, and restored focus/resize/interrupt plus the four PTY rows without weakening freeze needles. Every mandatory dimension is **not** ≥ 9.0.

Principal: write `state/harness-evolution/runs/tui-polish-20260814/not-converged.md` listing the 21 sub-9 dimensions above (and the commands/paths cited). Leave the shipped 2026-08-13 cockpit and the `tui` registry row in place. Do not write `final-report.md`. Do not start iter-6. Do not start a third frontend.
