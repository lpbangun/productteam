# Reviewer gate — iter-1

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-1`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`). Missing, stale, or uncited evidence scores 0.0. Average does not compensate.

**Verdict: FAIL — not converged.**

Not every D01–D29 is ≥ 9.0. Iter-1 must not be called done.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D06`, `D08`, `D09`, `D12`, `D13`, `D16`, `D25`) |
| ≥ 9.0 | D17, D20, D23, D27, D29 (5/29) |
| Native pytest | **9 failed, 23 passed** (`iter-1/pytest.txt:437`) |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Adversarial verification

### Scope

`iter-1/debate.md:100–112` accepted a presentation-only identity/honest-state slice (D02/D03/D04/D05/D23 ± D19) and deferred targeting, role argv, activity, footer, compact/SIGWINCH, docks, and splash. Worker diffstat is exactly those five files (`lib/tui/app.py`, `theme.py`, `tests/test_layout.py`, two SVG snapshots). That matches the debate boundary.

It does **not** match a passing freeze. The slice landed filtered home + cwd header + You chrome + source tokens, then left the native suite red because `test_slash.py` / `test_all_verbs.py` still boot-wait on the removed prose-status seed. That is a D28 regression of the shipped 2026-08-13 green pytest, not a freeze win.

### Current visual snapshot

`lib/tui/tests/__snapshots__/cockpit-80x24.svg` and `palette-80x24.svg` (refreshed this iter; `test_snapshots_export` is among the 23 passes):

- Header is `▣─▣─▣ ProductTeam · exp-tui-migration · —`. No `Directive`. `harness-cli` is a **home row**, not the header (`notes.md:19–22`).
- Home shows three scored rows (`agcode-learning`, `harness-cli`, `onboarding-flight-control`); no `run-loop` / `smoke` / `Thinking…`.
- Chips render `◆ Principal ◇ Analyst ▸ Builder ◉ Critic`.
- Palette `/st` lists `/status` and `/style unsupported` above the composer.
- Footer is still `enter send · tab complete · ↑↓ choose · esc close` — not locked idle `enter send · / commands · tab agents` (`frozen-benchmark.md:145–147`; `app.py:188`).
- Exact role hexes `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` `#8a8a8a` occur **zero** times in either SVG. Neutral tokens `#0a0a0a` `#e4e4e4` `#737373` `#141414` `#2a2a2a` do appear. `#chips { color: MUTE }` (`app.py:74–78`) is the honest explanation: identity hues are source-defined and not in the current picture.
- No activity strip, no `@Role`, no compact `ProductTeam {score}`, no splash, no ask/confirm/evidence docks.

### Native pytest failures

`iter-1/pytest.txt:1` `...........F............FFFFFFFF` → 23 passed, then:

1. `test_all_verbs.py::test_all_18_supported_verbs_in_tui_transcript` — `assert False` waiting for `"Product Consulting"` in the transcript (`pytest.txt:42–45`; `test_all_verbs.py:77`). Home no longer dumps prose status.
2. Eight `test_slash.py` tests — `_boot` waits for `"Product Consulting Harness"` (`test_slash.py:94`), then `_wait_for` calls nonexistent `app.pause()` (`pytest.txt:86–88`). Latent helper bug, newly reachable because the seed changed.

Passed in the same run: all `test_adapter.py`, all seven `test_layout.py` (including filtered home, cwd header, You chrome, token/Bash contracts, four sizes, snapshots), both `test_nontty.py`, both `test_pty.py`, and `test_all_verbs.py::test_every_unsupported_verb_refuses_without_spawn` (boot wait is not asserted there).

`test_you_turn_chrome` stubs `_start_provider_turn` (`test_layout.py:130`). That is presentation-only, not a live-provider mock, but it is not role-speech evidence.

### Canonical gates

- `iter-1/cli-interface-parity.txt:35` `cli-interface parity v3: PASS` (33/18/15/6 intact).
- `iter-1/visual-cli.txt:16` `14/14 pass · 0 fail · 0 skipped · live provider proof missing`. Freeze §7 allows overall exit 1 **only** for that pre-existing hole. Do not mock the provider.
- `iter-1/pty-test.txt`: 2 passed. Real PTY `/status` streams CLI output; `/gate` refuses with registry reason and does not spawn; first Ctrl+C keeps partial artifact + `workers.tsv` `failed`; second Ctrl+C exits 130 (`test_pty.py:55–64, 121–154`; `pty-note.md:4–7`).
- Live ioctl/SIGWINCH `80→40→80`: **no proof** (`pty-note.md:12`). `on_resize` is gone from `app.py`.

### Preservation

- `productteam chat` / `lib/repl.sh` still has no TUI launch path.
- `provider_turn.sh` signature remains `ROOT PROMPT`; `activity_start Analyst` is still hardcoded (`provider_turn.sh:16,26`). Interrupt behavior of the shipped cockpit is preserved, not the freeze ROLE seam.
- Unrelated dirty OFC/spike/engagement files remain; TUI worker did not overwrite them (git diffstat is the five slice files only).
- Pins, registry `tui` unsupported row, and `spikes/shared/` are untouched.
- Forbidden cuts from `frozen-benchmark.md:354–383` are not implemented.
- Preservation does **not** include a green native suite: pytest was green at `tui-cockpit-20260813` and is red now.

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 7.0 | `app.py:177–184` compose is header/rule/transcript/chips/dock/composer/footer. `test_layout.py:47–54` proves four-size reachability, dock above composer, Esc closes. No `#activity` widget; ask/confirm/evidence docks absent (`pty-note.md:14–18`). Idle activity-absent is allowed; live activity cannot appear. |
| D02 | Exact cockpit tokens and glyphs | 8.0 | Exact hex + glyphs in `theme.py:13–47`; `test_cockpit_token_contract` + `test_bash_two_accent_budget` passed; snapshots have no cyan `#0178D4` and show role glyphs. Material gap: role/You hexes are absent from both current SVGs; chips CSS forces `MUTE` (`app.py:74–78`). Status glyphs exist in `STATUS_GLYPHS` only. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` passed (`test_layout.py:76–94`): ≤3 scored rows, exclusions, no `Product Consulting Harness` dump. Snapshots match. Honest empty copy is coded (`app.py:330–333`) but **not** fixture-proven this run. Home sort is mapped-first, not an explicit recency key (`app.py:328–329`). |
| D04 | Q2 identity | 7.0 | You rail/label/timestamp: `test_you_turn_chrome` (`test_layout.py:123–146`) isolated delta `│ You · HH:MM`. Four role glyphs in snapshots. No 11ch gutter. Material gaps: chip identity hues not in SVG; role-colored speaking rails deferred (`notes.md:31`; `_provider_done` still `role_tag("Analyst")` at `app.py:672`). |
| D05 | Q3 header | 8.0 | `test_header_cwd_projection` passed; snapshot header `▣─▣─▣ ProductTeam · exp-tui-migration · —`; no `harness-cli`/`Directive`/`Mode` in the bar (`test_layout.py:112–118`; `app.py:304–311`). Em dash is the honest no-Repo-match score (`notes.md:19`). Missing: middle-head pulse; compact `ProductTeam {score}`. |
| D06 | Q4 honest activity | 0.0 | No activity region, braille spinner, elapsed `m:ss`, or 3/2/1+N caps (`pty-note.md:14`; `notes.md:32`; compose has no `#activity`). |
| D07 | Q5 compact and resize | 5.0 | Static 120×36 / 80×24 / 60×24 / 40×20 widget reachability passed (`test_layout.py:10,22–24,57–59`). `_render_header` is one wide shape at every width (`app.py:304–311`). No compact mode, no SIGWINCH `80→40→80` (`pty-note.md:12`; no `on_resize`). |
| D08 | Q6 structured ask | 0.0 | No `ask.json` consumer, dock, single/multi, `k of n`, or fixture (`pty-note.md:15`; `notes.md:33`). |
| D09 | Thinking versus speech | 0.0 | Required case is empty-artifact **work** in activity, then a role turn on emitted text. No activity strip; provider chunks still stream as unowned `md_line` (`app.py:372–377,646–653`). Idle snapshots lacking `Thinking…` are vacuous. |
| D10 | R1 markdown-lite | 6.0 | `theme.py:115–187` implements heading/fence/+/-/evidence-path; CLI stream and You body call it (`app.py:367–370,385–387`; `theme.py:210–214`). No TUI snapshot or native test of those cases on a speaking turn. Completion card is a detached Analyst line (`app.py:658–676`). |
| D11 | R2 slash | 6.5 | Live `help --json` palette (`adapter.py:141–197`); `/st` snapshot filter; PTY `/status` + `/gate` (`test_pty.py:110–117`; `pty-test.txt`). Material gaps: slash echo is unstyled `Text(f"/{verb}")` not a mute Command rail (`app.py:512`); native slash tests red (`pytest.txt:429–436`). |
| D12 | R3 evidence | 0.0 | No bordered labelled panel; `/report`/`/bench` still stream into the transcript (`inspect.md:57`; `pty-note.md:17`; `notes.md:35`). |
| D13 | R4 confirm | 0.0 | No intercept for `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` (`inspect.md:56`; `pty-note.md:16`; `app.py:557–558` runs supported writes immediately). |
| D14 | R5 toasts and cards | 4.5 | Interrupt toast + partial artifact proven (`test_pty.py:139–154`; `app.py:663–667,687`). Fail uses `notify` (`app.py:678`). Done is a detached Analyst card, not on the originating role turn (`app.py:668–676`). `/export` writes a mute transcript line (`app.py:522–525`), not a session toast without an extra line. |
| D15 | R6 footer | 2.5 | Footer widget exists and is snapshotted, but copy is the shipped `enter send · tab complete · ↑↓ choose · esc close` (`app.py:188`). Locked idle/busy/ask/slash strings are absent; palette snapshot keeps the same footer while the dock is open. |
| D16 | R7 splash | 0.0 | No TUI-owned ASCII heads, skip, or glow cycle (`pty-note.md:18`). `/splash` remains a CLI Command turn (`app.py:571`). |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of at most three rows (`app.py:316–350`); compose has no picker (`app.py:177–184`); header uses process cwd (`app.py:255–264,307`). Snapshots have no switcher chrome. Non-material: rows live in the log, so they scroll with chat. |
| D18 | Targeting | 2.0 | Static chips render (`app.py:352–361`; snapshot glyphs). Not focusable/clickable; composer has no `@Role`; default Principal is not a target; `provider_turn.sh` is still `ROOT PROMPT` (`app.py:605–606`); Analyst remains hardcoded (`provider_turn.sh:26`; `app.py:672`). |
| D19 | Defaults | 8.0 | Dim timestamps proven on You (`test_layout.py:139–141`; `theme.py:199–209`). High-contrast tokens exist in `theme.py:13–24`. Copy is still a transcript line (`app.py:522–525`), not a session toast. |
| D20 | Palette backend seam | 9.7 | `adapter._Palette.load` is live `help --json` (`adapter.py:147–154,194–197`); `test_help_json_contract` / `test_palette_verbs` passed; prebuild `argv-dry-run.json:16–23` `["help","--json"]` rc 0. No second verb list. Non-10: this iter did not re-run a TUI-level palette dry-run folder. |
| D21 | Supported slash backend | 6.0 | Real executable argv + stream (`adapter.py:66–79,82–101`; `app.py:563–592`). PTY `/status` reached real CLI output (`test_pty.py:97–99,113`). Native 18-verb TUI transcript proof failed on the stale boot wait (`pytest.txt:42–45`). Slash rendering is not a mute Command rail (`app.py:512`). |
| D22 | Unsupported / chat-only | 7.5 | `test_every_unsupported_verb_refuses_without_spawn` passed (15 verbs, `spawns == []`). PTY `/gate` no-spawn (`test_pty.py:115–117`). Chat-only implementations exist (`app.py:515–544`) but native `/clear` `/export` `/exit` `/provider` tests never left `_boot` (`pytest.txt:434–436`). |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json` (`app.py:245–265`); header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd (`app.py:267–311`); never Mode/Directive (`test_layout.py:117–118`). Honest `—` when this worktree has no matching engagement (`notes.md:19`; snapshot). |
| D24 | Activity/provider seam | 5.5 | Process-group interrupt preserved (`test_pty.py:121–154`; `app.py:681–696`; `provider_turn.sh:38–44`). workers path/columns, row caps, `ROOT PROMPT ROLE`, `activity_start "$ROLE"`, and `agent_card_prompt_block` are **not** implemented (`provider_turn.sh:14–26`; `app.py:605–606`; `pty-note.md:13–14`). |
| D25 | Ask/confirm/evidence seams | 0.0 | No structured ask file/provider event, no pre-run write intercept, no evidence path parsing (`pty-note.md:15–17`; `notes.md:33–35`). |
| D26 | Splash / non-TTY seams | 5.0 | Non-TTY: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR` (`test_nontty.py:25–37` passed; `argv-dry-run.json:376–387` argv `["tui"]` rc 2). TUI-owned splash and `/splash` separation are absent (`pty-note.md:18`). |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run: `argv-dry-run.json:2–14` real `bin/productteam`, mode `0o775`, `shell` false, whole-token deny, `agents --json` allowed rc 0 (`:49–55`). Adapter `shell=False` + forbidden-token tests passed (`adapter.py:17,72–74`; `test_adapter.py`). Freeze-critic note still holds: this folder is CLI-level, not a TUI unsupported/role-argv trace. |
| D28 | Required test coverage | 3.5 | §7 native pytest is **not** green (`pytest.txt:437` 9 failed). PTY slash/interrupt preserved; four static sizes only; SIGWINCH/ask/confirm/evidence/splash/role-argv/activity rows fail or absent (`notes.md:26–40`; `pty-note.md:10–18`). Parity PASS; visual-cli 14/14 with allowed live-provider hole. |
| D29 | Preservation and failure behavior | 9.1 | No forbidden cuts; chat remains Bash; `lib/tui/` not deleted; unrelated dirty worktree not overwritten by the slice; freeze not edited; `tui` registry row kept. Analyst hardcode and pytest redness are scored on D18/D24/D28, not as a D29 cut. Non-10: shipped native suite is no longer green. |

## Sub-9 dimensions (every one)

D01 7.0, D02 8.0, D03 8.5, D04 7.0, D05 8.0, D06 0.0, D07 5.0, D08 0.0, D09 0.0, D10 6.0, D11 6.5, D12 0.0, D13 0.0, D14 4.5, D15 2.5, D16 0.0, D18 2.0, D19 8.0, D21 6.0, D22 7.5, D24 5.5, D25 0.0, D26 5.0, D28 3.5.

## Smallest coherent next slice (by benchmark lift)

Do **not** open ask/confirm/evidence/splash. Do **not** insert an activity widget until role argv exists (debate already showed that is self-referential and scores 0).

**Iter-2 (one Worker):** retarget native boot waits, then the control/argv seam.

1. **Unblock D28/D11/D21/D22.** Change `test_slash.py:_boot` and `test_all_verbs.py` boot waits off `"Product Consulting Harness"` / `"Product Consulting"` onto the locked home/header projection (same needles as `test_layout.py:_boot_home`). Replace `app.pause()` with `pilot.pause()`. Goal: `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` green against current chrome. This is the cheapest lift: those tests already cover shipped slash/chat-only/18-verb behavior that iter-1 made unreachable.
2. **In the same `app.py` touch, only if (1) is done:** session-local targeting + `provider_turn.sh ROOT PROMPT ROLE` with Principal default, `activity_start "$ROLE"`, `agent_card_prompt_block`, and a `@Builder` → `workers.tsv` proof. Stop hardcoding Analyst. One-line CSS fix: do not set `#chips { color: MUTE }` so D02/D04 role hues can appear in snapshots. Re-prove interrupt after the signature change (`test_pty.py::test_pty_provider_interrupt`).
3. **Explicitly out of iter-2:** activity strip, busy footer, SIGWINCH/compact, ask/confirm/evidence, splash.

Iter-3 (already coherent once (2) exists): activity vs speech (D06/D09) + state-dependent footer (D15) + explicit 40-col / live `80→40→80` (D07). Compact caps are vacuous without a live activity row.

## Stop rule

KEEP polish only when every D01–D29 is ≥ 9.0 with current citations. Iter-1 is **FAIL**. Do not write `final-report.md`. Do not delete `lib/tui/`.
