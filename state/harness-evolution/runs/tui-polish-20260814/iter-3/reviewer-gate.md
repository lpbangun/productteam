# Reviewer gate — iter-3

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-3`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`). Missing, stale, or uncited evidence scores 0.0. Average does not compensate.

**Verdict: FAIL — not converged.**

Not every D01–D29 is ≥ 9.0. Iter-3 must not be called done. PTY slash repair held; targeting, role argv, interrupt, and canonical gates did not regress. That is not acceptance.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D06`, `D08`, `D09`, `D12`, `D13`, `D16`, `D25`) |
| ≥ 9.0 | D02, D17, D18, D20, D22, D23, D27, D29 (8/29) |
| Native pytest | **36 passed, 0 failed** (`iter-3/pytest.txt:2`) |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Adversarial verification

### Scope

`iter-3/debate.md:129–176` bound one `app.py` repair: keep Composer focused at idle **and while `#dock` is visible**, so burst `/status\r` reaches `submit_composer`. Needles frozen. D18 held. Explicitly out: `#activity`, thinking-vs-speech, footer copy, compact/SIGWINCH, ask/confirm/evidence, splash, mute Command rails, `provider_turn.sh`, snapshots, Button, `@Role` in the buffer, `RoleChip.can_focus = False`.

`iter-3/notes.md:5` and `pty-note.md:10` record that product change: `_refresh_dock` and `_close_dock` refocus Composer. Current source matches (`app.py:533–551,573–575`). Compose still has no `#activity` (`app.py:253–264`). RoleChip remains `Static` with `can_focus = True` (`app.py:172–180`). Imports still exclude Button (`app.py:27`). Needles for `Product Consulting Harness`, `/gate` usage, interrupt, and `@Builder` are unchanged (`test_pty.py:96–117,121–154,157–199`; `test_all_verbs.py:26`).

This is the bound slice, not a freeze pass. Activity, footer, compact, ask/confirm/evidence, and splash remain absent, as the debate required.

### PTY slash repair (the slice)

Isolated real-PTY file is green: `iter-3/pty-test.txt` **3 passed in 18.78s**. The same three tests sit inside the full native run: `iter-3/pytest.txt` **36 passed in 160.90s**.

`test_pty_status_and_gate_refuse` (`test_pty.py:93–118`; `pty-note.md:5–6`):

- After header `ProductTeam`, burst `/status\r` streams live CLI output containing `Product Consulting Harness`.
- `/gate\r` then refuses with `use the CLI: productteam gate` and `owner-gated`.
- `no directive` is absent — refuse did not spawn gate.
- Needles and 25s waits were not weakened.

Iter-2 failed this exact row (`iter-2/pytest.txt:17–21` `assert False` waiting for `Product Consulting Harness`). Iter-3 restores it on a real TTY. Native slash was already green in iter-2; freeze §7 PTY slash is the real-TTY row (`frozen-benchmark.md:253`) and is now satisfied.

Mechanic observed, not invented: Composer is the only Enter/Tab/arrow slash-routing path (`app.py:140–168,603–625`). After OptionList `add_class("visible")` / `set_options`, `_refresh_dock` calls `self.composer.focus()` (`app.py:547–551`). `_close_dock` does the same (`app.py:573–575`). No option-selected handler was added.

### Targeting / role argv / interrupt — no regression

All four non-regression proofs named by the debate (`debate.md:149–155`) are in the 36-passed suite, and the three PTY tests also pass in isolation (`pty-test.txt`):

| Constraint | Current citation |
|---|---|
| Four `RoleChip(Static)` `can_focus = True`; click/Enter/Space select; Left/Right cycle; select restores composer | `app.py:172–221,446–454`; `test_layout.py:223–256` |
| `@Role` is `#role-prefix` chrome, not `composer.text` | `app.py:104–118,261–263,440–444`; `cockpit-80x24.svg:153` `@Principal` |
| Typed `@Role` strip; bare `@Role` spawns nothing | `app.py:468–478,603–636`; `test_layout.py:259–288` |
| Idle default Principal | `app.py:249`; `test_layout.py:233` |
| `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; `prompt_export` else `agent_card_prompt_block`; no Analyst hardcode | `provider_turn.sh:24,32–36,47–59`; `rg` finds **no** `activity_start Analyst` |
| Real `@Builder verify the seam` → Builder `workers.tsv` `done`, mission contains the prompt | `test_pty.py:157–199`; `pty-note.md:8` |
| First Ctrl+C keeps partial artifact + `failed`; second Ctrl+C exits 130 | `test_pty.py:121–154`; `pty-note.md:7` |

`provider_turn.sh` was not retouched for this slice. Python still passes `self._active_turn_role` as argv (`app.py:735–736`). D18 stays ≥ 9.0.

### Snapshot hues (unchanged chrome)

`test_snapshot_role_hues_and_no_cyan` is among the 36. Idle SVGs still carry the four role identity hexes and no cyan:

| token | hex | in current SVGs |
|---|---|---|
| principal | `#c084fc` | yes; Principal chip bold + `@Principal` (`cockpit-80x24.svg:41–45,152–153`) |
| analyst | `#60a5fa` | yes |
| builder / ok | `#22c55e` | yes |
| critic | `#f59e0b` | yes |
| cyan | `#0178D4` | absent (asserted) |
| you | `#8a8a8a` | **absent** (idle frames have no You turn) |
| err | `#ef4444` | **absent** (idle frames) |

Canvas `#0a0a0a`, field `#141414`, rule `#2a2a2a`, text `#e4e4e4`, mute `#737373` remain. Rich window chrome still uses `#c5c8c6`. `test_cockpit_token_contract` and `test_bash_two_accent_budget` passed. No Button / `$primary`.

### Still absent (debate CUT, freeze still red)

`iter-3/pty-note.md:12` and `notes.md:22–28` match compose/source:

- No `#activity`, braille spinner, `m:ss`, or 3/2/1+N caps.
- No thinking-vs-speech gating; provider chunks remain unowned `md_line` (`app.py:489–494,776–783`).
- No structured ask / confirm / evidence docks.
- No TUI-owned splash.
- No explicit 40-col header / live `80→40→80` (`_render_header` is one wide shape at `app.py:385–392`; no `on_resize`).
- Slash echo is still unstyled `Text(f"/{verb}")`, not a mute Command rail (`app.py:641`).
- Footer is still `enter send · tab complete · ↑↓ choose · esc close` (`app.py:268`; `cockpit-80x24.svg:156`).

### Canonical gate preservation

- `iter-3/cli-interface-parity.txt:35` `cli-interface parity v3: PASS` (33/18/15/6 intact; contract hash matches FREEZE-SHA).
- `iter-3/visual-cli.txt:16` `14/14 pass · 0 fail · 0 skipped · live provider proof missing`. Freeze §7 allows overall exit 1 **only** for that pre-existing hole. No provider mock.
- `lib/repl.sh:2,:475` is still the Bash `productteam chat` TTY path; no TUI launch.
- Freeze file hash unchanged. Pins, registry `tui` unsupported row, and forbidden cuts (`frozen-benchmark.md:354–383`) are not implemented.
- Unrelated dirty worktree was not overwritten by this slice.

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 7.0 | `app.py:253–264` compose is header/rule/transcript/`#chips`/dock/`#composer-region`(prefix+composer)/footer. `test_layout.py:47–56` four-size dock-above-composer and Esc close. `_refresh_dock`/`_close_dock` restore composer focus (`app.py:551,575`) — overlay-close analogue holds. No `#activity`; ask/confirm/evidence docks absent (`pty-note.md:12`). Live activity still cannot appear. |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs in `theme.py:17–60`; `test_cockpit_token_contract` + `test_bash_two_accent_budget` passed in the 36; `test_snapshot_role_hues_and_no_cyan` passed. Both SVGs contain `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` and no `#0178D4` (`cockpit-80x24.svg:41–45,152`). Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`; status glyphs remain source-only; Rich window chrome still uses `#c5c8c6`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` passed (`test_layout.py:78–96`): ≤3 scored rows, exclusions, no `Product Consulting Harness` dump. Snapshots: `agcode-learning` / `harness-cli` / `onboarding-flight-control`; no `run-loop` / `smoke` (`cockpit-80x24.svg:136–138`). Honest empty copy is coded (`app.py:411–414`) but **not** fixture-proven this run. Home sort is mapped-first, not an explicit recency key (`app.py:409`). |
| D04 | Q2 identity | 8.2 | You rail/label/timestamp: `test_you_turn_chrome` (`test_layout.py:125–148`). Four role glyphs + identity hues in snapshots; selected Principal is bold (`cockpit-80x24.svg:41,152`). No 11ch gutter. Material gap: speaking-turn role rails still deferred; provider chunks remain unowned `md_line` (`app.py:489–494,776–783`). |
| D05 | Q3 header | 8.0 | `test_header_cwd_projection` passed; snapshot header `▣─▣─▣ ProductTeam · exp-tui-migration · —`; no `harness-cli`/`Directive`/`Mode` in the bar (`test_layout.py:101–121`; `app.py:385–392`). Missing: middle-head pulse; compact `ProductTeam {score}`. |
| D06 | Q4 honest activity | 0.0 | No activity region, braille spinner, elapsed `m:ss`, or 3/2/1+N caps (`pty-note.md:12`; `notes.md:22`; compose has no `#activity`). |
| D07 | Q5 compact and resize | 5.0 | Static 120×36 / 80×24 / 60×24 / 40×20 widget reachability passed (`test_layout.py:12,21–61`). `_render_header` is one wide shape at every width (`app.py:385–392`). No compact mode, no SIGWINCH `80→40→80` (`pty-note.md:12`; no `on_resize`). |
| D08 | Q6 structured ask | 0.0 | No `ask.json` consumer, dock, single/multi, `k of n`, or fixture (`pty-note.md:12`; `notes.md:23`). |
| D09 | Thinking versus speech | 0.0 | Required case is empty-artifact **work** in activity, then a role turn on emitted text. No activity strip; provider chunks still stream as unowned `md_line` (`app.py:489–494,776–783`). Idle snapshots lacking `Thinking…` are vacuous. `rg` finds no `Thinking` in `lib/tui/`. |
| D10 | R1 markdown-lite | 6.0 | `theme.py:144–174` implements heading/fence/+/-/evidence-path; CLI stream and You body call it (`app.py:484–487,502–504`). No TUI snapshot of those cases on a speaking turn. Completion card is still a detached line labelled with the turn role (`app.py:788–806`). |
| D11 | R2 slash | 7.5 | Live `help --json` palette (`adapter.py:141–197`); `/st` snapshot filter (`palette-80x24.svg:152–153`); native `/sta` + `/gate` no-spawn passed (`test_slash.py:110–141`). **PTY slash restored:** `/status` streams `Product Consulting Harness`; `/gate` refuses with registry reason and does not spawn (`test_pty.py:93–118`; `pty-test.txt`; `pytest.txt:2`). Material remaining gap vs 10.0: slash echo is still unstyled `Text(f"/{verb}")`, not a mute Command rail (`app.py:641`). |
| D12 | R3 evidence | 0.0 | No bordered labelled panel; `/report`/`/bench` still stream into the transcript (`pty-note.md:12`; `notes.md:25`; `_exec_cli` writes every line to the log at `app.py:695–696`). |
| D13 | R4 confirm | 0.0 | No intercept for `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` (`pty-note.md:12`; `app.py:686–687` runs supported writes immediately). |
| D14 | R5 toasts and cards | 5.5 | Interrupt toast + partial artifact re-proven after the dock-focus change (`test_pty.py:121–154`; `pty-note.md:7`; `app.py:793–796,812–826`). Done card uses `_active_turn_role` (`app.py:802`) but remains detached, not on the originating speaking turn. `/export` still writes a mute transcript line (`app.py:651–654`), not a session toast without an extra line. |
| D15 | R6 footer | 2.5 | Footer widget exists and is snapshotted, but copy is still `enter send · tab complete · ↑↓ choose · esc close` (`app.py:268`; `cockpit-80x24.svg:156`). Locked idle/busy/ask/slash strings are absent; palette snapshot keeps the same footer while the dock is open. Debate forbade footer copy this iter. |
| D16 | R7 splash | 0.0 | No TUI-owned ASCII heads, skip, or glow cycle (`pty-note.md:12`). `/splash` remains a CLI Command turn (`app.py:700`). |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of at most three rows (`app.py:397–417`); compose has no picker (`app.py:253–264`); header uses process cwd (`app.py:335–344,385–392`). Snapshots have no switcher chrome. Non-material: rows live in the log, so they scroll with chat. |
| D18 | Targeting | 9.3 | All freeze bullets have current citations **after** the dock-focus repair: focusable/clickable chips (`test_layout.py:223–256`); `@Role` chrome not buffer (`app.py:440–444`; `cockpit-80x24.svg:153`); session-local Principal default; typed `@Role` strip (`test_layout.py:259–288`); ROLE argv (`app.py:735–736`; `provider_turn.sh:24,36`); card prepend `prompt_export` else `agent_card_prompt_block` (`provider_turn.sh:47–59`); no `activity_start Analyst`; real `@Builder` → Builder `workers.tsv` (`test_pty.py:157–199`; `pty-test.txt`). Non-10: card prepend is source-proven, not prompt-captured. |
| D19 | Defaults | 8.0 | Dim timestamps proven on You (`test_layout.py:141–143`; `theme.py:199–209`). High-contrast tokens exist and appear as chip hues. Copy is still a transcript line (`app.py:651–654`), not a session toast. |
| D20 | Palette backend seam | 9.7 | `adapter._Palette.load` is live `help --json` (`adapter.py:147–154,194–197`); `test_help_json_contract` / `test_palette_verbs` passed in the 36; prebuild `argv-dry-run.json:16–23` `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | 8.2 | Real executable argv + stream (`adapter.py:66–79,82–101`; `app.py:691–721`). Native 18-verb per-turn proof is among the 36 (`test_all_verbs.py:70–112`; `NEEDLES["status"]` kept). **Freeze PTY `/status` now green** (`test_pty.py:96–99`; `pty-note.md:5`). Remaining vs 10.0: slash rendering is not a mute Command rail (`app.py:641`). |
| D22 | Unsupported / chat-only | 9.4 | `test_every_unsupported_verb_refuses_without_spawn` passed (15 verbs, `spawns == []`; `test_all_verbs.py:115–150`). Native `/gate` refuse no-spawn (`test_slash.py:121–141`). **Real-PTY `/gate` now reached:** usage + `owner-gated`, `no directive` absent (`test_pty.py:100–117`; `pty-note.md:6`). Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit` match the REPL split (`app.py:644–673`). Non-10: session verbs still emit transcript lines rather than mute toasts (scored on D14/D19). |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json` (`app.py:325–345`); header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd (`app.py:360–392`); never Mode/Directive (`test_layout.py:119–121`). Honest `—` when this worktree has no matching engagement (snapshot). |
| D24 | Activity/provider seam | 7.8 | `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend; INT trap kept (`provider_turn.sh:24,32–36,47–59,66–72`). Process-group interrupt re-proven after dock-focus (`test_pty.py:121–154`; `pty-note.md:7`). Builder workers row uses `lib/activity.sh` columns (`test_pty.py:194–197`; `lib/activity.sh:76–77`). Not ≥9.0: freeze D24 10.0 still requires workers path poll UI and row caps 3/2/1+N (`frozen-benchmark.md:287`); no activity widget. |
| D25 | Ask/confirm/evidence seams | 0.0 | No structured ask file/provider event, no pre-run write intercept, no evidence path parsing (`pty-note.md:12`; `notes.md:23–25`). |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25–37` passed in the 36; `argv-dry-run.json:376–387` argv `["tui"]` rc 2). TUI-owned splash and `/splash` separation are absent (`pty-note.md:12`). |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run: `argv-dry-run.json:2–14` real `bin/productteam`, mode `0o775`, `shell` false, whole-token deny, `agents --json` allowed rc 0 (`:49–55`). Adapter `shell=False` + forbidden-token tests passed (`adapter.py:17,72–74`; `test_adapter.py:87–109`). Freeze-critic note still holds: this folder is CLI-level, not a TUI unsupported/role-argv trace. |
| D28 | Required test coverage | 6.6 | §7 native pytest is now green (`pytest.txt:2` 36 passed). PTY slash, role-argv, and interrupt rows pass in isolation (`pty-test.txt` 3 passed) and inside the 36. Four static sizes pass; **SIGWINCH / ask / confirm / evidence / splash / activity §7 rows still fail or absent** (`notes.md:22–28`; `pty-note.md:12`). Parity PASS; visual-cli 14/14 with allowed live-provider hole. |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash (`lib/repl.sh:2,475`); `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; needles not weakened; interrupt + `@Builder` re-proof hold after the focus change. Unrelated dirty worktree not overwritten. Non-10: polish is still incomplete (scored on other dims); this slice did not claim KEEP. |

## Sub-9 dimensions (every one) and exact failures

| ID | score | Exact failure |
|---|---:|---|
| D01 | 7.0 | No `#activity`; no ask/confirm/evidence docks; live activity cannot appear. |
| D03 | 8.5 | Honest empty home copy not fixture-proven; sort is mapped-first, not recency. |
| D04 | 8.2 | No role-colored speaking rails; provider text is unowned `md_line`. |
| D05 | 8.0 | No middle-head pulse; no compact `ProductTeam {score}`. |
| D06 | 0.0 | No activity region / braille / `m:ss` / row caps. |
| D07 | 5.0 | No explicit 40-col mode; no live `80→40→80`. |
| D08 | 0.0 | No structured ask event, dock, or fixture. |
| D09 | 0.0 | No empty-artifact activity-vs-speech proof; chunks still unowned. |
| D10 | 6.0 | No speaking-turn markdown-lite snapshot; completion card detached. |
| D11 | 7.5 | PTY slash restored; echo is not a mute Command rail (`app.py:641`). |
| D12 | 0.0 | No bordered labelled evidence panel. |
| D13 | 0.0 | No confirm intercept; writes run immediately. |
| D14 | 5.5 | Done card detached; `/export` is an extra transcript line. |
| D15 | 2.5 | Footer is still the shipped hint line, not locked idle/busy/ask/slash. |
| D16 | 0.0 | No TUI-owned splash / skip / glow cycle. |
| D19 | 8.0 | Copy remains a transcript line, not a session toast. |
| D21 | 8.2 | Command rail absent. |
| D24 | 7.8 | No workers poll UI or 3/2/1+N caps. |
| D25 | 0.0 | Ask/confirm/evidence seams all absent. |
| D26 | 5.0 | Non-TTY proven; TUI splash seam absent. |
| D28 | 6.6 | Native pytest green and PTY slash restored; SIGWINCH / ask / confirm / evidence / splash / activity §7 rows still fail. |

## Smallest coherent next slice (by benchmark lift)

PTY slash is green and ROLE argv exists. Do **not** open ask/confirm/evidence/splash. Do **not** ship mute Command rails in the same touch — that is a render dim, not this dependency chain, and it inflates the compose/focus surface that just got repaired.

**Iter-4 (one Worker):** honest live activity + thinking-versus-speech + state-dependent footer + explicit 40-col / live `80→40→80`. Compact activity caps are vacuous without a live activity row, so they belong in the same slice as `#activity`.

1. **D06 / D09 / D24 UI.** Add a conditional `#activity` strip from real `workers.tsv` (`lib/activity.sh` columns). Braille spinner, role, mission/provider fact, elapsed `m:ss`. Caps 3 at 80, 2 at 60, 1 plus `+N` at 40. Empty-artifact work stays solely in the strip. A colored role turn begins only when that role emits text — stop streaming unowned `md_line` chunks (`app.py:489–494`). No `Thinking…`. No determinate bar.
2. **D15 in the same compose touch.** Idle footer `enter send · / commands · tab agents`. Busy footer `ctrl+c interrupt · m:ss · {provider}`. Slash dock replaces idle hints while open (ask dock still out).
3. **D07 with the live row.** Explicit 40-col header `ProductTeam {score}`; drop heads and directory; keep composer. Prove static 120×36 / 80×24 / 60×24 / 40×20 **and** live ioctl/SIGWINCH `80→40→80` with restored heads/directory. Activity cap at 40 is the reason this rides with (1).
4. **Non-regression on the same `app.py` touch.** After inserting `#activity` / `on_resize`, Composer must remain the TTY default **and** while the slash dock is visible (`app.py:551,575` must still hold). Re-run `test_pty_status_and_gate_refuse`, `test_pty_provider_interrupt`, `test_pty_typed_role_records_builder`, `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`. Do not make `RoleChip.can_focus = False`. Do not use Button. Do not put `@Role` in the buffer. Do not weaken needles.

**Explicitly out of iter-4:** ask.json / OMP dock, confirm intercept, bordered evidence panel, TUI splash, mute Command rails, sourcing `role-envelope.sh`, editing `provider_turn.sh` unless a one-line activity-column bug is proven, provider mocks.

**Files:** `lib/tui/app.py` plus the tests/snapshots named by the freeze for activity, footer, and SIGWINCH (`lib/tui/tests/test_layout.py`, `test_pty.py`, SVG snapshots). Skip formatters/linters/full-suite in the Worker; Principal re-runs the freeze table.

Honest lift if (1)–(4) hold: D06/D09 leave 0; D15 leaves 2.5; D07 leaves 5.0; D01/D24/D28 move with the new regions and §7 rows. **Do not promise any new 9.0** — ask/confirm/evidence/splash/Command-rail still cap several dims. Inserting `#activity` while forgetting composer-focus repeats the iter-2 PTY slash regression.

## Stop rule

KEEP polish only when every D01–D29 is ≥ 9.0 with current citations. Iter-3 is **FAIL**. Do not write `final-report.md`. Do not delete `lib/tui/`.
