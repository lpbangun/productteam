# Reviewer gate — iter-2

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-2`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`). Missing, stale, or uncited evidence scores 0.0. Average does not compensate.

**Verdict: FAIL — not converged.**

Not every D01–D29 is ≥ 9.0. Iter-2 must not be called done.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D06`, `D08`, `D09`, `D12`, `D13`, `D16`, `D25`) |
| ≥ 9.0 | D02, D17, D18, D20, D22, D23, D27, D29 (8/29) |
| Native pytest | **1 failed, 35 passed** (`iter-2/pytest.txt:28`) |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Adversarial verification

### Scope

`iter-2/debate.md:165–207` bound A then B: retarget native boot waits, then focusable/clickable `RoleChip` Static chips (Button banned), `@Role` chrome not buffer, `ROOT PROMPT ROLE`, `activity_start "$ROLE"`, `prompt_export` else `agent_card_prompt_block`, interrupt re-proof, `@Builder` → `workers.tsv`. Activity, footer copy, compact/SIGWINCH, ask/confirm/evidence, splash, and mute Command rails were out.

Worker diffstat is nine `lib/tui/` files (`app.py`, `provider_turn.sh`, `theme.py`, four test modules, two SVGs). That matches the debate file list. It does **not** match a passing freeze: targeting/argv landed, then a real-PTY slash probe that was green in iter-1 went red.

### Focusable / clickable targets

Proven in native tests, not via Button:

- `RoleChip(Static)` with `can_focus = True` (`app.py:171–179`). Click / Enter / Space call `select_role`; Left/Right cycle (`app.py:210–220,445–465`).
- `test_role_chips_focusable_and_selectable` (`test_layout.py:223–256`): idle `_target_role == "Principal"`; four chips `can_focus`; Tab+Right+Enter selects Builder and restores composer focus; `pilot.click("#role-critic")` selects Critic and restores composer focus.
- Compose keeps one `#chips` Horizontal, height 1, no `$primary` (`app.py:76–90,256–258`). `test_four_sizes` still asserts `transcript < chips < composer` and dock above composer (`test_layout.py:47–51`).

### Composer prefix semantics

Chrome, not TextArea content — the debate CUT of buffer-prefix held:

- Visible `@Role` is `#role-prefix` Static sibling inside `#composer-region`; `Composer(id="composer")` remains the buffer (`app.py:103–118,260–262,439–443`).
- Idle snapshot shows `@Principal` on its own field row (`cockpit-80x24.svg:153`), not mixed into typed text.
- `submit_composer` strips a leading exact `@Role` token, updates `_target_role`, then routes remainder: empty → no-op; `/` → slash; else You body + provider (`app.py:467–477,600–633`).
- `test_typed_role_prefix_strips` (`test_layout.py:259–288`): `@Builder build the seam` You body is `build the seam` (no `@Builder` in delta); bare `@Critic` updates target and spawns nothing.
- `test_you_turn_chrome` still types `h`,`i` into an empty composer and gets You body `hi` (`test_layout.py:125–148`) — prefix-in-buffer would have broken this.
- Native slash still keys off composer-first-line `/` (`app.py:521–530`; `test_slash.py:110–118` `/sta` → `["status"]`).

### Card prompt path and no Analyst hardcode

- Signature `provider_turn.sh ROOT PROMPT [ROLE]`; `ROLE="${3:-Principal}"` (`provider_turn.sh:4–5,24`). Python `Popen` passes `self._active_turn_role` as argv[4] (`app.py:732–733`).
- Sources `lib/agent-cards.sh` only. Does **not** source `lib/role-envelope.sh` or call `role_invoke` (`provider_turn.sh:29–32,6–7`).
- Prepend: `jq -r '.prompt_export // empty'` when non-empty, else `agent_card_prompt_block`; captured in variables so `ARTIFACT=` stays first merged line (`provider_turn.sh:43–63`).
- `activity_start "$ROLE"` with the **user** prompt as mission (`provider_turn.sh:36`). `rg` finds **no** `activity_start Analyst`.
- Completion card uses `_active_turn_role`, not Analyst (`app.py:785–799`).
- Gap vs 10.0: prompt_export prepend is source-proven; no fixture captured the provider's received prompt. Workers row + ROLE argv are observed.

### Real Builder workers row

Isolated real-PTY proof passed (`iter-2/pty-test.txt`: 2 passed in 3.87s; `pty-note.md:4–8`):

- `test_pty_typed_role_records_builder` (`test_pty.py:157–199`): typed `@Builder verify the seam` against a real executable provider fixture (not a `_start_provider_turn` stub). `workers.tsv` records `parts[1] == "Builder"`, `done`, mission contains `verify the seam`. Transcript contains `Builder`.
- `test_pty_provider_interrupt` still green after the signature/card change: first Ctrl+C keeps partial artifact + `failed`; second Ctrl+C exits 130 (`test_pty.py:121–154`).

### Snapshot hues

`test_snapshot_role_hues_and_no_cyan` plus refreshed SVGs (`test_layout.py:292–299`; `cockpit-80x24.svg:41–45,152–153`):

| token | hex | in current SVGs |
|---|---|---|
| principal | `#c084fc` | yes; Principal chip bold + `@Principal` |
| analyst | `#60a5fa` | yes |
| builder / ok | `#22c55e` | yes (Builder chip and ≥9 home scores) |
| critic | `#f59e0b` | yes |
| cyan | `#0178D4` | absent (asserted) |
| you | `#8a8a8a` | **absent** (idle frames have no You turn) |
| err | `#ef4444` | **absent** (idle frames) |

Canvas `#0a0a0a`, field `#141414`, rule `#2a2a2a`, text `#e4e4e4`, mute `#737373` are in the SVG rects. `test_cockpit_token_contract` and `test_bash_two_accent_budget` passed as part of the 35. No Button / `$primary`.

### PTY slash regression (exact failure)

This is the iteration's blocking regression. Iter-1 PTY `/status` + `/gate` was green; iter-2 full native run is not.

`iter-2/pytest.txt:17–21`:

```
AssertionError: real status output reached the transcript
assert False
 +  where False = _wait_for(..., 'Product Consulting Harness', 25)
```

Header `ProductTeam` did render (`pytest.txt:15`). `/status\r` produced no CLI transcript within 25s. `/gate` was never reached (`pty-note.md:10–12`). Principal names this a real TTY focus/input regression after the composer-region / RoleChip change, not a flake, and not to be papered over (`notes.md:20,32`; `pty-note.md:12`).

Native (pilot) slash still works: `/sta` filter, `/gate` refuse no-spawn, 18 supported verbs per-turn, chat-only `/clear` `/export` `/exit` `/provider` (`test_slash.py`, `test_all_verbs.py` — those tests are among the 35 passes). Freeze §7 PTY slash is a **real TTY** row (`frozen-benchmark.md:253`). Native green does not satisfy it.

Likely mechanic: `RoleChip.can_focus = True` is composed **before** `#composer`. On a real PTY the first focusable chip can eat `/status`; `RoleChip.on_key` only handles enter/space/left/right (`app.py:214–220`). Isolated `@Builder` still reached the composer (`test_pty.py:171`), so this is focus/input routing, not a dead PTY.

### Canonical gate preservation

- `iter-2/cli-interface-parity.txt:35` `cli-interface parity v3: PASS` (33/18/15/6 intact; contract hash matches FREEZE-SHA).
- `iter-2/visual-cli.txt:16` `14/14 pass · 0 fail · 0 skipped · live provider proof missing`. Freeze §7 allows overall exit 1 **only** for that pre-existing hole. No provider mock.
- `lib/repl.sh` has no TUI launch path (only `productteam chat` TTY remedy at `:2,:475`).
- Freeze file hash unchanged. `spikes/shared/` remains untracked leftover, not edited by this slice.
- Pins, registry `tui` unsupported row, and forbidden cuts (`frozen-benchmark.md:354–383`) are not implemented.
- Unrelated dirty worktree was not overwritten; git short status under `lib/tui/` is the nine slice files only.

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 7.0 | `app.py:252–263` compose is header/rule/transcript/`#chips`/dock/`#composer-region`(prefix+composer)/footer. `test_layout.py:47–56` four-size dock-above-composer and Esc close. No `#activity`; ask/confirm/evidence docks absent (`pty-note.md:16–18`). Prefix wrapper is the debate-allowed composer sibling, not a new region between chips and dock. Live activity still cannot appear. |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs in `theme.py:17–60`; `test_cockpit_token_contract` + `test_bash_two_accent_budget` passed; `test_snapshot_role_hues_and_no_cyan` passed. Both SVGs contain `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` and no `#0178D4` (`cockpit-80x24.svg:41–45,152`). Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`; status glyphs remain source-only; Rich window chrome still uses `#c5c8c6`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` passed (`test_layout.py:78–96`): ≤3 scored rows, exclusions, no `Product Consulting Harness` dump. Snapshots: `agcode-learning` / `harness-cli` / `onboarding-flight-control`; no `run-loop` / `smoke`. Honest empty copy is coded (`app.py:410–413`) but **not** fixture-proven this run. Home sort is mapped-first, not an explicit recency key (`app.py:408`). |
| D04 | Q2 identity | 8.2 | You rail/label/timestamp: `test_you_turn_chrome` (`test_layout.py:125–148`). Four role glyphs + identity hues in snapshots; selected Principal is bold (`cockpit-80x24.svg:41,152`). No 11ch gutter. Material gap: speaking-turn role rails still deferred; provider chunks remain unowned `md_line` (`app.py:488–493,773–780`). |
| D05 | Q3 header | 8.0 | `test_header_cwd_projection` passed; snapshot header `▣─▣─▣ ProductTeam · exp-tui-migration · —`; no `harness-cli`/`Directive`/`Mode` in the bar (`test_layout.py:101–121`; `app.py:384–391`). Missing: middle-head pulse; compact `ProductTeam {score}`. |
| D06 | Q4 honest activity | 0.0 | No activity region, braille spinner, elapsed `m:ss`, or 3/2/1+N caps (`pty-note.md:17`; `notes.md:24`; compose has no `#activity`). |
| D07 | Q5 compact and resize | 5.0 | Static 120×36 / 80×24 / 60×24 / 40×20 widget reachability passed (`test_layout.py:12,21–61`). `_render_header` is one wide shape at every width (`app.py:384–391`). No compact mode, no SIGWINCH `80→40→80` (`pty-note.md:16`; no `on_resize`). |
| D08 | Q6 structured ask | 0.0 | No `ask.json` consumer, dock, single/multi, `k of n`, or fixture (`pty-note.md:18`; `notes.md:25`). |
| D09 | Thinking versus speech | 0.0 | Required case is empty-artifact **work** in activity, then a role turn on emitted text. No activity strip; provider chunks still stream as unowned `md_line` (`app.py:488–493,773–780`). Idle snapshots lacking `Thinking…` are vacuous. |
| D10 | R1 markdown-lite | 6.0 | `theme.py:121–144` implements heading/fence/+/-/evidence-path; CLI stream and You body call it (`app.py:483–486,501–503`). No TUI snapshot of those cases on a speaking turn. Completion card is still a detached line, now labelled with the turn role (`app.py:785–803`). |
| D11 | R2 slash | 6.8 | Live `help --json` palette (`adapter.py:141–197`); `/st` snapshot filter; native `/sta` + `/gate` no-spawn passed (`test_slash.py:110–141`). Material failures: freeze PTY slash row red — `/status` never reached the transcript; `/gate` not reached (`pytest.txt:17–21`; `pty-note.md:10–12`). Slash echo is still unstyled `Text(f"/{verb}")`, not a mute Command rail (`app.py:638`). |
| D12 | R3 evidence | 0.0 | No bordered labelled panel; `/report`/`/bench` still stream into the transcript (`pty-note.md:18`; `notes.md:25`; `_exec_cli` writes every line to the log at `app.py:689–693`). |
| D13 | R4 confirm | 0.0 | No intercept for `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` (`pty-note.md:18`; `app.py:683–684` runs supported writes immediately). |
| D14 | R5 toasts and cards | 5.5 | Interrupt toast + partial artifact re-proven after ROLE/card change (`test_pty.py:121–154`; `app.py:790–793,809–821`). Done card now uses `_active_turn_role` (`app.py:797–799`) but remains detached, not on the originating speaking turn. `/export` still writes a mute transcript line (`app.py:648–651`), not a session toast without an extra line. |
| D15 | R6 footer | 2.5 | Footer widget exists and is snapshotted, but copy is still `enter send · tab complete · ↑↓ choose · esc close` (`app.py:267`; `cockpit-80x24.svg:156`). Locked idle/busy/ask/slash strings are absent; palette snapshot keeps the same footer while the dock is open. Debate forbade footer copy this iter. |
| D16 | R7 splash | 0.0 | No TUI-owned ASCII heads, skip, or glow cycle (`pty-note.md:18`). `/splash` remains a CLI Command turn (`app.py:697`). |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of at most three rows (`app.py:396–416`); compose has no picker (`app.py:252–263`); header uses process cwd (`app.py:335–344,384–391`). Snapshots have no switcher chrome. Non-material: rows live in the log, so they scroll with chat. |
| D18 | Targeting | 9.3 | All freeze bullets have current citations: focusable/clickable chips (`test_layout.py:223–256`); `@Role` chrome not buffer (`app.py:439–443`; `cockpit-80x24.svg:153`); session-local Principal default; typed `@Role` strip (`test_layout.py:259–288`); ROLE argv (`app.py:732–733`; `provider_turn.sh:24,36`); card prepend `prompt_export` else `agent_card_prompt_block` (`provider_turn.sh:47–59`); no `activity_start Analyst`; real `@Builder` → Builder `workers.tsv` (`test_pty.py:157–199`; `pty-test.txt`). Non-10: card prepend is source-proven, not prompt-captured; PTY slash focus regression is scored on D11/D28. |
| D19 | Defaults | 8.0 | Dim timestamps proven on You (`test_layout.py:141–143`; `theme.py:199–209`). High-contrast tokens exist and now appear as chip hues. Copy is still a transcript line (`app.py:648–651`), not a session toast. |
| D20 | Palette backend seam | 9.7 | `adapter._Palette.load` is live `help --json` (`adapter.py:147–154,194–197`); `test_help_json_contract` / `test_palette_verbs` passed; prebuild `argv-dry-run.json:16–23` `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | 7.8 | Real executable argv + stream (`adapter.py:66–79,82–101`; `app.py:688–718`). Native 18-verb per-turn proof now runs and is among the 35 passes (`test_all_verbs.py:70–112`; `NEEDLES["status"]` kept as live CLI output). Material gaps: freeze PTY `/status` failed (`pytest.txt:17–21`); slash rendering is not a mute Command rail (`app.py:638`). |
| D22 | Unsupported / chat-only | 9.1 | `test_every_unsupported_verb_refuses_without_spawn` passed (15 verbs, `spawns == []`; `test_all_verbs.py:115–150`). Native `/gate` refuse no-spawn (`test_slash.py:121–141`). Chat-only `/provider` `/clear` `/export` `/exit` now leave `_boot` and pass (`test_slash.py:156–232`). Implementations of all six including `/workers` `/quit` match the REPL split (`app.py:641–670`). Non-10: real-PTY `/gate` was not reached this run. |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json` (`app.py:325–345`); header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd (`app.py:360–391`); never Mode/Directive (`test_layout.py:119–121`). Honest `—` when this worktree has no matching engagement (snapshot). |
| D24 | Activity/provider seam | 7.8 | `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend; INT trap kept (`provider_turn.sh:24,32–36,47–59,66–72`). Process-group interrupt re-proven (`test_pty.py:121–154`). Builder workers row uses `lib/activity.sh` columns (`test_pty.py:194–197`; `lib/activity.sh:76–77`). Not ≥9.0: freeze D24 10.0 still requires workers path poll UI and row caps 3/2/1+N (`frozen-benchmark.md:287`); no activity widget. |
| D25 | Ask/confirm/evidence seams | 0.0 | No structured ask file/provider event, no pre-run write intercept, no evidence path parsing (`pty-note.md:18`; `notes.md:25`). |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25–37` passed; `argv-dry-run.json:376–387` argv `["tui"]` rc 2). TUI-owned splash and `/splash` separation are absent (`pty-note.md:18`). |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run: `argv-dry-run.json:2–14` real `bin/productteam`, mode `0o775`, `shell` false, whole-token deny, `agents --json` allowed rc 0 (`:49–55`). Adapter `shell=False` + forbidden-token tests passed (`adapter.py:17,72–74`; `test_adapter.py:87–109`). Freeze-critic note still holds: this folder is CLI-level, not a TUI unsupported/role-argv trace. |
| D28 | Required test coverage | 5.8 | §7 native pytest is **not** green (`pytest.txt:28` 1 failed, 35 passed). Role-argv and interrupt PTY rows pass in isolation (`pty-test.txt`). PTY slash **regressed**. Four static sizes only; SIGWINCH/ask/confirm/evidence/splash/activity rows fail or absent (`notes.md:20–29`; `pty-note.md:14–18`). Parity PASS; visual-cli 14/14 with allowed live-provider hole. |
| D29 | Preservation and failure behavior | 9.0 | No forbidden cuts; chat remains Bash; `lib/tui/` not deleted; unrelated dirty worktree not overwritten by the slice (git short status under `lib/tui/` is the nine files); freeze hash unchanged; `tui` registry row kept; interrupt re-proof holds. Analyst hardcode removal is scored on D18. Non-10: shipped real-PTY `/status`/`/gate` probe is no longer green; native suite is not fully green. |

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
| D11 | 6.8 | **PTY `/status` did not reach transcript** (`pytest.txt:17–21`); `/gate` not reached; echo is not a mute Command rail (`app.py:638`). |
| D12 | 0.0 | No bordered labelled evidence panel. |
| D13 | 0.0 | No confirm intercept; writes run immediately. |
| D14 | 5.5 | Done card detached; `/export` is an extra transcript line. |
| D15 | 2.5 | Footer is still the shipped hint line, not locked idle/busy/ask/slash. |
| D16 | 0.0 | No TUI-owned splash / skip / glow cycle. |
| D19 | 8.0 | Copy remains a transcript line, not a session toast. |
| D21 | 7.8 | Freeze PTY `/status` failed; Command rail absent. |
| D24 | 7.8 | No workers poll UI or 3/2/1+N caps. |
| D25 | 0.0 | Ask/confirm/evidence seams all absent. |
| D26 | 5.0 | Non-TTY proven; TUI splash seam absent. |
| D28 | 5.8 | Native pytest red (1 failed); PTY slash / SIGWINCH / ask / confirm / evidence / splash / activity §7 rows fail. |

## Smallest coherent next slice (by benchmark lift)

Do **not** insert `#activity`, busy footer, compact/SIGWINCH, ask/confirm/evidence, splash, or mute Command rails. Those stay out until the native suite is green on a real TTY. Inserting activity while PTY slash is red repeats the iter-1 pattern (new chrome, red suite).

**Iter-3 (one Worker):** restore real-PTY composer input so freeze §7 PTY slash is green again, without dropping D18.

1. **Unblock D11/D21/D28.** Make `test_pty_status_and_gate_refuse` pass: after header `ProductTeam`, `/status\r` must stream `Product Consulting Harness`; `/gate` must refuse with registry reason and not spawn. Keep `NEEDLES["status"]` and the 25s PTY needles. Goal: `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` → **36 passed**. This is the cheapest lift: native slash/18-verb/chat-only evidence already exists; only the real TTY path regressed.
2. **Keep D18 green in the same `app.py` touch.** Chips stay focusable/clickable Static (no Button). `@Role` stays chrome, not buffer. After any focus-order fix, `on_mount` / select / Esc must leave the composer accepting `/` and `@Builder`. Re-run `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`, `test_pty_typed_role_records_builder`, and `test_pty_provider_interrupt`.
3. **Explicitly out of iter-3:** `#activity`, thinking-vs-speech gating, footer string change, compact header / `on_resize` / SIGWINCH, ask/confirm/evidence docks, TUI splash, mute Command rails, sourcing `role-envelope.sh`.

Likely mechanic to bind (Worker may not invent a second composer): `RoleChip` is the first `can_focus` widget in compose order (`app.py:256–262,179`). On a real PTY that can steal `/status` because `RoleChip.on_key` ignores `/` (`app.py:214–220`). Native tests pass because `_boot` / `on_mount` force `composer.focus()` (`app.py:268`; `test_slash.py:105`). Fix focus so the composer is the TTY default without making chips unfocusable.

**Files:** `lib/tui/app.py` only unless a PTY wait-for-composer assertion is added in `lib/tui/tests/test_pty.py`. Do not weaken needles. Skip formatters/linters/full-suite in the Worker; Principal re-runs the freeze table.

Honest lift if (1)+(2) hold: D11 ~6.8→~7.5 (PTY slash restored; Command rail still absent); D21 ~7.8→~8.2; D28 ~5.8→~6.5 (native pytest green is one §7 row; SIGWINCH/ask/confirm/evidence/splash/activity still fail). D18 stays ≥9.0. No dim reaches a new 9.0 except by accident of rounding — this slice exists to stop the regression, not to claim convergence.

Iter-4 (already coherent once pytest is 36/36 and ROLE argv exists): activity vs speech (D06/D09) + state-dependent footer (D15) + explicit 40-col / live `80→40→80` (D07). Compact caps are vacuous without a live activity row.

## Stop rule

KEEP polish only when every D01–D29 is ≥ 9.0 with current citations. Iter-2 is **FAIL**. Do not write `final-report.md`. Do not delete `lib/tui/`.
