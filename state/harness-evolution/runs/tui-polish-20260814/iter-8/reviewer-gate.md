# Reviewer gate — iter-8

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-8`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`); owner schedule extension `extension.md` (iter-6…iter-10, freeze immutable); Worker contract `iter-8/debate.md`. Missing, stale, or uncited evidence scores 0.0. Average does not compensate. PASS only if every score ≥ 9.0.

**Verdict: FAIL — not converged. D16 and D26 now clear 9.0. Remaining zeros: none.**

The bound TUI-owned splash machine landed. Native suite is 67/0 (15 splash rows over iter-7's 52). Real PTY is 5/0 with unweakened needles. That is not freeze acceptance. Sub-9 work is proof of already-implemented home/header/activity/speech/compact/provider seams, not a missing function.

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **7.5** (`D06`) |
| Zeros | **none** |
| ≥ 9.0 | D01, D02, D08, D10, D11, D12, D13, D14, D15, D16, D17, D18, D19, D20, D21, D22, D23, D25, D26, D27, D29 (21/29) |
| Native pytest | **67 passed, 0 failed** (`iter-8/pytest.txt`) — 15 new splash tests over iter-7's 52 |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Three required outputs

1. **Final verdict:** FAIL. Do **not** write `final-report.md`. Do **not** delete `lib/tui/` or the `tui` registry row. Continue only under `extension.md` into the bound iter-9 proof cluster below.
2. **Scores:** `iter-8/scores.json` (this gate). Every D01–D29 has a current path or command citation.
3. **Explicit 9.0 decisions (the two named dims):**
   - **D16 clears 9.0** (9.2). TUI-owned `#splash` Static paints the exact 11×7 three-head ASCII; idle spans are MUTE (brand TEXT); live glow is OK one head at a time Principal → Analyst → Builder → Principal; any-key skip (Enter/`/`/Esc/printable/Ctrl+C/Ctrl+Q/Ctrl+P) consumes without submit, dock, spawn, or exit 130; composer/footer/@Principal stay visible; compact 40×20 does not cover the composer; natural finish and skip share `_splash_finish`; once-only (no resize replay); banned graph/`ROBOTS_MARK`/Critic absent. Residual to 10.0: a live-PTY splash frame is optional 10-band proof, **not** a 9-threshold requirement.
   - **D26 clears 9.0** (9.2). TUI splash seam + `/splash` remains a mute Command `▣` turn that never reopens `#splash` + non-TTY exit 2 / empty stdout / `requires an interactive TTY` / no ESC under `NO_COLOR` held exactly. Residual to 10.0: live-PTY splash, **not** a 9 fail.

---

## Adversarial inspections (required)

Scope bound by `iter-8/debate.md`: `#splash` Static in the existing compose tree; `theme.splash_render` owns the 11×7 grid; idle MUTE / live OK; `_splash_advance` stepper; `_splash_consume_key` first; `CONSULT_NO_SPLASH` non-empty short-circuit; `/splash` Command separation; ten (landed fifteen) behavioral `test_layout.py` rows. Product mtimes in the Worker window: `theme.py` 00:11, `test_layout.py` 00:29, `app.py` 00:35. Snapshots rewritten 00:39 by Principal `test_snapshots_export` during the freeze table. `provider_turn.sh` (11:46), `adapter.py` (01:40), `session.py` (00:38), `__main__.py` (00:42), `test_pty.py` (21:47), `test_slash.py` (22:52), `test_all_verbs.py` NEEDLES (11:47), and `test_nontty.py` (00:43) were not retouched this iter.

### 1. Widget, compose tree, mount/seed, focus — HONEST

Compose is `header / rule / #splash / #transcript / #activity / #chips / #dock / #composer-region / footer` (`app.py:361-374`). `#splash` is `Static(id="splash", markup=False)` (`app.py:364`). Default CSS `display: none`; `.visible` → `display: block` with `height: 1fr` (`app.py:80-92`). `#transcript.splashed` → `display: none` (`app.py:116-118`) so two `1fr` children do not split the field. No second `Screen`, no `ModalScreen`, no `ProgressBar`, no `Button`.

`_seed` still starts from `on_mount` (`app.py:376-384`) and `_seed_home` may `transcript.write` Q1 rows while the RichLog is hidden. Skip/finish never `transcript.clear()`. Native: after five advances, `HOME_ROW_RE` or `No scored sessions yet` is in `transcript_text()` and `/^\` is absent (`test_layout.py:1205-1235`). Idle boot: `/^\` is on `#splash.render().plain` and **not** in `transcript_text()` (`test_layout.py:1150-1153`).

Focus: `on_mount` still `composer.focus()` (`app.py:380`). `#splash` `can_focus` is false (`test_layout.py:1111`). Finish and skip both `composer.focus()` (`app.py:663`; `test_layout.py:1226, 1256`).

Once: `_splash_active` is True only between `_splash_show` and `_splash_finish`. `_splash_finish` is idempotent (`app.py:651-664`). After skip, resize 80→40→80 keeps `#splash` hidden (`test_layout.py:1403-1421`). `/splash` CLI does not set `_splash_active` (`test_layout.py:1426-1459`).

### 2. Exact ASCII art — HONEST, debate grid byte-identical

`theme.py` owns the art. `SPLASH_ROLES` / `SPLASH_HEADS` / gaps match the debate constants exactly (`theme.py:369-402`). Each head line `len == 11`. Wide join 39 columns; compact join 35. `splash_render(width, glow)` returns one `Text`; `app.py` `Static.update`s it and does not restyle (`app.py:633, 649`).

Native idle frame at 80 (`test_layout.py:1123-1139`): 10 lines; line 0 `     |             |             |     `; line 1 carries `/^\`; line 5 `    / \            ◇             ▸     `; line 6 ` Principal      Analyst       Builder  `; brand `ProductTeam`; idle subtitle `principal · analyst · builder`. Compact 40×20 uses the 35-column join (`test_layout.py:1386-1393`).

Banned needles absent from `#splash` plain and from `transcript_text()` (`test_layout.py:1054-1067, 1154-1157`): `▣───────`, `6 people`, `14 links`, `shared evidence graph`, `Product Consulting Harness`, `Product Judgment Layer`, `▄██▄` / `█ ██ █` / `█▄▄▄▄█` / `▐▌▐▌`, `◉`, `Critic`.

### 3. Idle-neutral and live glow as widget spans — HONEST

Observation is `#splash.render()` spans (`test_layout.py:1070-1081`), not a helper-only unit test.

Idle (`glow is None`, step 0): brand TEXT; every other span MUTE; PRINCIPAL / ANALYST / BUILDER / CRITIC / YOU / OK / ERR absent (`test_layout.py:1140-1149`). Glyphs `◇` / `▸` stay MUTE at idle.

Live (steps 1–4, driven by `ProductTeamApp._splash_advance`): exactly eight OK spans = one head's seven rows + live subtitle `{glyph} {role}`; other two heads MUTE (`test_layout.py:1162-1200`). Order Principal → Analyst → Builder → Principal. Glow style is the `OK` constant (`#22c55e`), never `ROLE_STYLES` purple/blue. `BUILDER == OK` hex (`theme.py:25-27`); tests still pass `OK`, as bound.

No new hex. Token table and `ROLE_STYLES` unchanged.

### 4. Stepper, natural finish, skip precedence — HONEST

Step table matches the debate (`app.py:353-358, 629-649`): 0 idle, 1–4 glow, 5 `_splash_finish`. Production `set_interval(0.4, self._splash_advance)`; tests stop the timer and call `_splash_advance` directly (`test_layout.py:1084-1090, 1178-1183`). Fifth advance hides splash, restores idle footer `enter send · / commands · tab agents`, `composer.focus()`, home visible, further advance is a no-op (`test_layout.py:1205-1235`).

`_splash_consume_key` runs first in `Composer._on_key` and `RoleChip.on_key` (`app.py:190-191, 278-280, 666-676`). Skip is consumed: Enter → no You turn, `_turns == []`, `composer.text == ""` (`test_layout.py:1240-1260`); `/` → dock not visible, composer empty, **second** `/` opens slash (`test_layout.py:1264-1287`); Esc → idle footer, not ask/confirm/evidence (`test_layout.py:1292-1308`); printable `x` consumed (`test_layout.py:1313-1330`).

Ctrl+C: first lines of `action_interrupt_provider` finish splash and return (`app.py:1645-1649`); app stays running, no exit 130 (`test_layout.py:1464-1482`). Ctrl+Q and Ctrl+P priority bindings skip during splash and restore normal quit/palette after (`app.py:1655-1682`; `test_layout.py:1487-1552`). Existing `test_pty_provider_interrupt` still boots with `CONSULT_NO_SPLASH=1` (`test_pty.py:127`).

Splash footer while active: exact `enter continue · any key skip` (`app.py:556-558`; `test_layout.py:1122`). Idle/busy/ask/slash/confirm/evidence footers unchanged after finish.

### 5. `CONSULT_NO_SPLASH`, `/splash` CLI, non-TTY — HONEST

`on_mount`: non-empty `os.environ.get("CONSULT_NO_SPLASH")` skips `_splash_show` (`app.py:385-390`), same as `lib/splash.sh` `[[ -n ... ]]`. `test_layout.py` `setdefault("CONSULT_NO_SPLASH", "1")` (`test_layout.py:36`); splash tests `delenv` before `ProductTeamApp()`. Env-set boot: `#splash` never visible, idle footer, `/` opens dock (`test_layout.py:1335-1356`).

`/splash` after skip/env: `extra = {"CONSULT_NO_SPLASH": ""}` for argv `["splash"]` only (`app.py:1493`). Native mocked streamer: `_turns` cli delta contains `▣`; `#splash` stays hidden (`test_layout.py:1426-1459`). Real CLI `NEEDLES["splash"] == ("▣",)` still in the Command / `_turns` cli delta (`test_all_verbs.py:41`) — in the 67.

`test_nontty.py` unedited (mtime 00:43). `__main__.py:13-15` refuses non-TTY before `ProductTeamApp()`. Both rows still in the 67: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR`.

### 6. Compact 40×20 does not cover composer — HONEST

`test_splash_compact_40x20_does_not_cover` (`test_layout.py:1361-1398`): splash visible; composer `width >= 20` and `height > 0`; footer visible with splash hints; `splash.region.y + height <= composer.region.y`; compact 35-col join present; Enter still skips.

### 7. D01 / D08 / D13 / D15 re-audit — HOLD, still clear 9.0

Splash was boot-only. This Reviewer re-read the live seams.

**D01 holds and lifts to 9.2.** Every dock still sits above the composer; close restores focus; composer ≥20 at four sizes and slash/ask/confirm/evidence. `#splash` occupies the transcript `1fr` slot while visible and never covers `#composer-region`. Iter-7 residual “splash overlay unproven” is closed.

**D08 holds 9.1.** `_poll_ask` still reads only `Path(self._active_artifact).parent / "ask.json"` while `_provider_active` and `_dock_kind == "slash"` (`app.py:687`). Evidence kind cannot steal the poll. Native ask tests remain in the 67.

**D13 holds 9.2.** Exact tuple intercept of `("gh","merge")`, `("checks","--allow-dirty")`, `("onboarding","--yes")` (`app.py:884-888`). Cancel/Esc `spawns == []`. Live PTY `/gh merge` Esc still in the 5.

**D15 holds 9.2.** Splash footer is boot-only and yields to idle on finish. Ask/slash/confirm/evidence/busy/idle strings unchanged. Freeze D15 10.0 names idle/busy/ask/slash — all exact.

### 8. PTY regressions — NONE

`lib/tui/tests/test_pty.py` mtime 21:47 (iter-6). Assertions were not edited this iter. Isolated PTY **5 passed** (`iter-8/pty-test.txt`). Exact needles held:

| Row | Held |
|---|---|
| `test_pty_status_and_gate_refuse` | `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:171-179`) |
| `test_pty_provider_interrupt` | live `partial analysis begins`; `"interrupting provider"`; `"partial output left on disk"`; artifact bytes; `\tfailed\t`; second Ctrl+C exits 130 (`test_pty.py:182-215`) |
| `test_pty_typed_role_records_builder` | live `builder analysis complete`; Builder/`done`/`verify the seam` (`test_pty.py:218-260`) |
| `test_pty_confirm_cancel_keeps_composer` | `Run /gh merge`, `Cancel`, confirm footer, `@Principal`; Esc -> idle footer; `/exit` rc 0 (`test_pty.py:262-299`) |
| `test_pty_sigwinch_compact` | ioctl 80->40->80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads (`test_pty.py:302-369`) |

### 9. Snapshot scope — HONEST, not a needle weaken

Snapshots are still idle cockpit + slash palette only. Principal rewrote them at 00:39 during `test_snapshots_export` (allowed as chrome evidence). They do **not** contain splash art (`/^\` is a boot-only widget needle). They must not. No `splash-80x24.svg` was added; debate marked that optional and not required for 9.0.

Held needles:

| Frame | Held |
|---|---|
| `cockpit-80x24.svg` | `▣─▣─▣ ProductTeam`; no `Directive`; `harness-cli` is a **home row**, not the bar; `@Principal` |
| `palette-80x24.svg` | `/st` filters `/status` + `/style unsupported`; `@Principal` |
| Both | role hues `#c084fc` `#60a5fa` `#22c55e` `#f59e0b`; canvas `#0a0a0a`; field `#141414`; no `#0178D4` |

You `#8a8a8a` and err `#ef4444` remain absent from idle frames (D02 9-band residual, unchanged).

### 10. Org One Writer — HELD

Debate named one Worker and `app.py` + `theme.py` (splash helpers only) + `test_layout.py`. Those three files moved in one window. Principal ran the freeze table and refreshed snapshots. No second Worker on `lib/tui/`. `provider_turn.sh` / `adapter.py` / `session.py` / `__main__.py` / `test_pty.py` / `test_slash.py` / `test_all_verbs.py` NEEDLES / `test_nontty.py` mtimes predate this iter. Theme token table and `ROLE_STYLES` were not edited; only `SPLASH_*` + `splash_render` were added (`theme.py:360-431`). No new hex (`test_cockpit_token_contract` still in the 67).

---

## Self-grading bias re-audit

Prior gates were re-read against current evidence. Conservative resolution: disputed subjective items keep the lower score until new evidence. **A 9 threshold is not a 10-band demand:** live-PTY splash is unrequested for D16/D26 ≥9 once native `run_test` proves heads/skip/glow/composer/footer/`/splash` separation.

| Pattern | Finding |
|---|---|
| Iter-7 correctly left D16 at 0.0 / D26 at 5.0 | Closed. Both now ≥9 from widget behavior, not source comments. |
| Debate predicted D16 ~9.0, D26 ~9.0, D28 ~8.7 not 9.0 | Landed 9.2 / 9.2 / 8.7. D16/D26 are 9.2 rather than 10 because live-PTY splash is absent (optional 10-band). D28 stays 8.7 because freeze §7 empty-artifact **PTY** is still missing. |
| Green 67 != 9.0 | **Not inflated.** D03/D04/D05/D06/D07/D09/D24/D28 stay proof-gap sub-9. No zeros remain. |
| D01/D08/D13/D15 without being the slice | Re-audited live (inspections 6–7). All still clear 9.0. D01 lifts 9.1→9.2 because the splash-overlay residual closed. |
| No implementer-authored `scores.json` | This Reviewer did not edit app code. |

---

## Organization critique

**One Writer:** held. See inspection 10.

**Debate / reviewer friction:** the iter-8 Critic bound the 11×7 grid, OK-not-role-hue glow, test-firable stepper, consume-first skip (including Ctrl+C exit-130), `#splash` vs `RichLog`/`ModalScreen`, env short-circuit vs the existing 52, and `/splash` Command separation. The Worker copied that contract and added Ctrl+Q/Ctrl+P guards the debate implied (priority bindings that would otherwise bypass consume). That prevented a graph paste, a wall-clock flake, a boot-killing Ctrl+C, and a `/splash` that reopens `#splash`.

**Freeze coverage / blind spots carried forward:**

- No zero-score **function** remains. Remaining sub-9 are proof gaps on already-implemented home/header/activity/speech/compact/provider behavior, plus home recency sort (mapped-first today).
- Live-PTY splash is **10-band**, not a D16/D26 9 reopen. Do not fail iter-9 for omitting it.
- Live-PTY `/report` is **10-band** for D12/D25 (already ≥9). Compatible with a `test_pty.py` edit, not a 9-blocker.
- `/workers` glob-latest (`session.py`) remains a second reader beside the honest live strip. Harmless for D24 as scored.
- D28 cannot reach 9.0 until freeze §7 empty-artifact **PTY** lands. Native splash satisfies the boot/`CONSULT_NO_SPLASH` preamble; it does not replace that PTY row.

**Evidence completeness:** iter-8 has debate, pytest, isolated PTY, parity, visual-cli, notes, pty-note, this gate, and scores. Argv dry-run and freeze hashes unchanged.

---

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | **9.2** | Compose header/rule/`#splash`/transcript/`#activity`/`#chips`/`#dock`/`#composer-region`/footer (`app.py:361-374`). Activity CSS `display:none` until `.visible`. One `OptionList`; `_dock_kind` in slash/ask/confirm/evidence. Every dock above composer; Esc/Enter close restores focus. Composer >=20 at four sizes and slash/ask/confirm/evidence (`test_layout.py:93-95` plus held dock-width rows). Splash occupies transcript `1fr` while visible and does not cover composer at 80 or 40 (`test_layout.py:1114-1120, 1361-1398`). Residual: idle seventh-region count still treats splash as boot, not a missing chrome band. |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs `theme.py:17-60`; token/bash/snapshot tests in the 67. Both SVGs carry role hues and no `#0178D4`. No new hex this iter. Glow uses existing `OK`. Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`. |
| D03 | Q1 filtered home | 8.5 | `test_home_seed_filtered` (`test_layout.py:112`) <=3 rows, exclusions, no prose dump. Snapshot rows `agcode-learning` / `harness-cli` / `onboarding-flight-control`. Empty copy exists in source (`app.py:1065-1068`) and as a wait needle, **not** as a fixture that produces the empty state. Sort is mapped-first (`app.py:1063`), not recency. |
| D04 | Q2 identity | 8.8 | You rail (`test_layout.py:159`). Ask question is a real Builder/Analyst colored turn. Live Builder speech held (`test_pty.py:218`). Markdown fixture asserts Builder rail `#22c55e` and neutral body (`test_layout.py:806`). Not 9.0: four-role speaking-rail style matrix still incomplete (Critic speaking rail unasserted). |
| D05 | Q3 header | 8.5 | Wide `▣─▣─▣ ProductTeam · {cwd} · {score}`; compact `ProductTeam {score}`; no `harness-cli`/`Directive` in the bar. PTY 80->40->80 held. Middle-head pulse still source-only (`app.py:1041` restyles the middle `▣` while busy; no snapshot or native span assertion). |
| D06 | Q4 honest activity | 7.5 | Native braille/mission/`m:ss`/caps 3/2/1+N (`test_layout.py:345`). No `ProgressBar`. No live-PTY strip citation (braille / mission / `m:ss` / caps on the TTY). |
| D07 | Q5 compact and resize | 8.5 | Four sizes + native 80->40->80 + PTY ioctl row held. Composer >=20 at 40 with confirm, evidence, **and splash** (`test_layout.py:1361-1398`). Non-9: live activity cap and compact score slot still not asserted on the TTY. |
| D08 | Q6 structured ask | **9.1** | **Re-audit HOLD, still clears 9.0.** Sibling `ask.json` (`app.py:687`). Section 6 validation; exact `turn(role, question)`; atomic answer + id-keyed retire. Native single/multi/invalid tests still in the 67. Evidence kind cannot steal the poll. Residual: no live-PTY ask. |
| D09 | Thinking versus speech | 8.2 | Native empty-artifact silent + owned first-bytes (`test_layout.py:414`; markdown fixture also forbids `Thinking…` / `◇ Analyst` in transcript, `test_layout.py:821-823`). Live drain held. Freeze section 7 empty-artifact **PTY** still missing. |
| D10 | R1 markdown-lite | **9.1** | Heading/fence/+/-/evidence-path/neutral body asserted on the owned Builder rail (`test_layout.py:806`). Attached done card does not replay speech. Residual: not a live-PTY markdown row. |
| D11 | R2 slash | **9.1** | Live `help --json` palette. Native `/sta` + `/gate` no-spawn. PTY `/status`/`/gate` held. Mute Command rail. Splash `/` skip does not open the dock; second `/` does (`test_layout.py:1264-1287`). Residual: live PTY does not assert the `│ Command` string. |
| D12 | R3 evidence | **9.1** | Bordered labelled `#dock`. Report/bench Command summaries + withheld paths. Empty buffer paints no chrome. Residual: live PTY `/report` is 10-band, not a 9 fail. |
| D13 | R4 confirm | **9.2** | **Re-audit HOLD, still clears 9.0.** All three exact argvs intercepted; Run original argv; Cancel/Esc no-spawn. Residual: PTY proves cancel UI, not live Run. |
| D14 | R5 toasts and cards | **9.0** | Done card attached. Interrupt: one warning toast + error card with `partial output left on disk`; PTY needles held. `/export`/`/provider` information toasts. Residual: non-130 fail toast+card is source-only. |
| D15 | R6 footer | 9.2 | Idle / busy / slash / ask / confirm / evidence footers exact. Splash footer `enter continue · any key skip` is boot-only and yields to idle (`app.py:554-558`; `test_layout.py:1122, 1223-1225`). Freeze D15 10.0 names idle/busy/ask/slash — all exact. Residual: compact busy omits provider. |
| D16 | R7 splash | **9.2** | **Clears 9.0.** Widget heads + skip + idle-neutral spans + stepper glow + composer/footer visible + banned-art rejection, all from `run_test` (`test_layout.py:1093-1552`; `theme.py:360-431`; `app.py:619-676`). Residual to 10.0: live-PTY splash frame optional — **not required for 9.** |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of <=3 rows; compose has no picker; header follows cwd. Skip/finish do not `clear()` home. Snapshots have no switcher. |
| D18 | Targeting | 9.3 | Focusable chips, `@Role` chrome, Principal default, typed `@Role`, `ROOT PROMPT ROLE`, `prompt_export` else card block, live `@Builder` -> Builder `workers.tsv`. Enter during splash does not submit (`test_layout.py:1240-1260`). |
| D19 | Defaults | **9.1** | Dim timestamps held; copy/export is a session toast, not chrome. Token table unchanged. |
| D20 | Palette backend seam | 9.7 | Live `help --json` (`adapter.py`); dry-run `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | **9.1** | Real executable argv + stream. Native 18-verb per-turn proof (`test_all_verbs.py:70`). Live `/status` complete. Mute Command + `md_line` on the stream. |
| D22 | Unsupported / chat-only | 9.4 | 15-verb refuse no-spawn. Native + PTY `/gate`. Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit`. |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json`; header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd. Snapshot header has no Mode/Directive. |
| D24 | Activity/provider seam | 8.6 | Exact-session poll + caps. `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend. Process-group interrupt held (PTY 5/0). `prompt_export` still not captured; live PTY strip unasserted. |
| D25 | Ask/confirm/evidence seams | **9.1** | Ask file-backed + id-keyed retire + atomic answer (D08). Pre-run write intercept + empty Cancel argv log (D13). Evidence path parsing is product-side `split_evidence_line` at stream time (D12). Residual: live PTY evidence is 10-band. |
| D26 | Splash / non-TTY seams | **9.2** | **Clears 9.0.** TUI-owned splash + `/splash` Command `▣` separation (`test_layout.py:1335-1356, 1426-1459`; `test_all_verbs.py:41`) + non-TTY exit 2 / empty stdout / TTY remedy / no ESC under `NO_COLOR` (`test_nontty.py:25-37`, in the 67). Residual to 10.0: live-PTY splash — **not required for 9.** |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run unchanged: real `bin/productteam` 0o775, `shell` false, whole-token deny, `agents --json` allowed. Splash skip does not spawn. `/splash` still `_exec_cli` -> `run_argv_stream`. No new parser of argv. |
| D28 | Required test coverage | 8.7 | Native **67/0** (`iter-8/pytest.txt`). Isolated PTY **5/0** (`pty-test.txt`): all five prior rows, needles unweakened. Parity PASS 33/18/15/6. Visual-cli 14/14 with allowed live-provider hole. Splash §7 preamble lands natively (env short-circuit + delenv splash tests). **Empty-artifact-PTY row still fails.** Live-PTY splash is not a §7 row and is not required for this 9. |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash TTY; `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; PTY needles not replaced; One Writer held; Ctrl+C/Q during splash skip rather than kill the boot; unrelated dirty worktree not overwritten. Owner extension did not amend D01-D29. This slice does not claim KEEP. |

---

## Remaining zeros and every sub-9 blocker

Zeros: **none.**

Every sub-9:

| ID | score | Exact failure |
|---|---:|---|
| D03 | 8.5 | Honest empty-home copy not fixture-proven; sort is mapped-first, not recency. |
| D04 | 8.8 | Builder speaking rail style-asserted; four-role speaking matrix still incomplete. |
| D05 | 8.5 | Compact proven native+PTY; middle-head pulse is source-only. |
| D06 | 7.5 | Native strip/caps; no live PTY activity-strip (braille/`m:ss`/caps) citation. |
| D07 | 8.5 | PTY ioctl 80->40->80 green; composer >=20 at 40 including splash; live cap and compact score slot not asserted on the TTY. |
| D09 | 8.2 | Live owned speech held; freeze section 7 empty-artifact **PTY** citation missing. |
| D24 | 8.6 | Interrupt + exact-session + caps proven; `prompt_export` not captured; live PTY strip unasserted. |
| D28 | 8.7 | Native+PTY+parity+visual green; splash preamble native; empty-artifact-PTY still fails. |

Cleared this iter (no longer blockers): **D16, D26**. Re-audit holds: **D01 (lifts 9.1→9.2), D08, D13, D15**. Already-cleared ≥9 unchanged: **D02, D10, D11, D12, D14, D17, D18, D19, D20, D21, D22, D23, D25, D27, D29**.

Do **not** treat live-PTY splash or live-PTY `/report` as 9-blockers. Those are 10-band residuals on dimensions that already clear 9.0.

---

## Iter-9 bind (proof cluster on already-implemented seams)

Hand the Worker **this contract**, not `iter-7/reviewer-gate.md` splash text, not an unbound "polish remaining chrome" prompt, and not a demand for 10-band live-PTY splash to re-prove D16/D26. One Writer. Skip formatters, linters, and project-wide suites.

### Why this slice is the remaining 9-band cluster

No zero-score function remains. Every sub-9 above is a **proof gap** on code that already runs, except home recency (today `_seed_home` sorts mapped-first at `app.py:1063`). They are mechanically compatible:

1. **One live provider turn** can prove the activity strip, the empty-artifact silence window, and `prompt_export` prepend on the same `provider_turn.sh` invocation.
2. **SIGWINCH during that turn** can prove compact `ProductTeam {score}` and the 1+N activity cap on the TTY.
3. **Native fixtures** in `test_layout.py` can prove empty-home copy, recency ordering, header pulse spans, and a four-role speaking-rail matrix without a second live provider.
4. **Live evidence / live splash PTY rows** share `test_pty.py` and the existing PTY harness. They are **optional 10-band extras** in the same file. They must not reopen D16/D26/D12 9.0, and they must not crowd out the 9-band cluster.

Piling unrelated new features (glob-latest ask, substring confirm, Enter-to-open files, a second splash widget) is how a Worker times out. Cut those.

### Files the Worker may touch

| File | Why |
|---|---|
| `lib/tui/app.py` | `_seed_home` recency sort (replace mapped-first). Pulse already exists at `_render_header`; only touch if a deterministic test hook is required — **do not invent a second header**. Do not retouch splash/ask/confirm/evidence machines. |
| `lib/tui/provider_turn.sh` | **Only** if `prompt_export` capture needs an observable needle. Prefer asserting the existing prepend (`provider_turn.sh:50-52`) without a signature change. Preserve `ROOT PROMPT ROLE`, `activity_start "$ROLE"`, process-group INT. |
| `lib/tui/tests/test_layout.py` | Native empty-home fixture; recency fixture; header-pulse span assertion; four-role speaking-rail matrix. Keep `setdefault CONSULT_NO_SPLASH=1`. Do not weaken splash rows. |
| `lib/tui/tests/test_pty.py` | **Add** rows; **do not weaken or replace** the existing five. Target: live activity strip + empty-artifact window + compact score/caps while busy. Optional same-file extras: live `/report` evidence; live splash with env unset (10-band only). |

**May not touch:** `adapter.py`, `session.py`, `__main__.py`, `theme.py` token table / `ROLE_STYLES` / splash art, `test_all_verbs.py` NEEDLES, `test_slash.py` (evidence/Command/toast/confirm needles stay), `test_nontty.py`, Bash modules (`lib/splash.sh`, `lib/repl.sh`, `lib/activity.sh`), freeze files, unrelated dirty worktree. Snapshots: Principal-only refresh after green pytest; idle snapshot must remain the post-skip cockpit.

### Mechanics (bound)

**A. Real PTY activity + empty-artifact + compact score/caps (D06 / D09 / D07 / D28)**

One live provider turn (existing slow-provider pattern is in bounds). While the artifact is still empty: transcript has neither `Thinking…` nor a fake agent message; the activity region shows a real workers.tsv row (role, mission/provider fact, braille or equivalent spinner, elapsed `m:ss`). First emitted bytes open one owned role turn. Then ioctl 80→40 (and restore 80) **while work is live**: compact header matches `ProductTeam {score}` (honest `—` or a numeric slot — assert the slot, not only the word `ProductTeam`); activity caps to one line plus `+N` when ≥2 live rows (fixture extra rows into the same session `workers.tsv` if the single provider row cannot show `+N` alone). Do not stub `_start_provider_turn` on this row. Do not weaken interrupt / Builder / confirm / idle-SIGWINCH needles.

**B. `prompt_export` capture (D24)**

On a role-targeted turn (Builder is enough), prove the selected card's `prompt_export` (or `agent_card_prompt_block` fallback) was prepended. Observation must be an artifact/trace/argv-adjacent capture, not a source comment. Do not change the `ROOT PROMPT ROLE` signature.

**C. Home recency / empty (D03) — needed**

Native fixture: `status --json` with zero scored (non-banned) engagements → transcript contains the honest empty copy (`No scored sessions yet`) and no status prose dump; chips `@Principal` and idle footer remain. Second fixture: several scored rows with distinct recency → home shows at most three in recency order, mapped-cwd preference may still pin one slot **only if** recency among the rest is proven. Product change is `_seed_home` sort only.

**D. Header pulse / four-role rail (D05 / D04) — needed**

Native: while `_provider_active` or live activity rows exist, the wide-header middle `▣` uses `OK`; idle it does not. Native: Principal / Analyst / Builder / Critic speaking rails each carry that role's `ROLE_STYLES` hue on the rail/label with neutral body (You already proven). A `_append_provider_chunk` matrix is enough; do not mock the live provider for this row.

**E. Live evidence / splash (optional 10-band, same PTY file)**

- Live `/report` (or `/bench`): Command summary stays in chat; paths land in the labelled evidence dock. **Not** a D12/D25 9 reopen.
- Live splash: unset `CONSULT_NO_SPLASH` for **one** dedicated PTY row; assert `/^\` (or `ProductTeam` splash brand) then skip to idle `@Principal`. **Not** a D16/D26 9 reopen. Skip this row rather than risk weakening `CONSULT_NO_SPLASH=1` defaults on the other five.

### Worker check (one targeted file, then the PTY file)

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q
```

Necessary, not sufficient. Principal owns:

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

Export `CONSULT_NO_SPLASH=1` for the full suite except a dedicated live-splash PTY row.

### Non-regression needles (exact)

- All five PTY rows listed in inspection 8.
- All fifteen splash rows in `test_layout.py` (`test_splash_*`).
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`; `test_confirm_run_exact_argv_for_all_three_intercepts`.
- Ask tests: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer ≥20.
- Evidence: `test_report_stream_evidence_panel`, `test_bench_stream_evidence_panel`, `test_report_missing_args_prints_usage`.
- Command/toast/card: `test_command_rail_mute_no_role_hues`, `test_export_writes_markdown`, `test_provider_sets_session_env`, `test_provider_speech_markdown_and_attached_done_card`.
- `test_nontty_refusal`, `test_nontty_no_color_no_escapes`.
- `test_all_verbs.py` NEEDLES including `splash: ("▣",)` in the Command / `_turns` cli delta.
- `test_four_sizes`, `test_home_seed_filtered`, `test_you_turn_chrome`, `test_role_chips_focusable_and_selectable`, `test_empty_artifact_stays_activity_and_speech_is_owned`.

### Honest dimension lift after iter-9 (not a blanket 10.0)

| ID | After iter-9 | Why not higher / still out |
|---|---|---|
| **D06** | 7.5 → ~9.0 | Live PTY activity strip (braille/`m:ss`/caps). Residual to 10: determinate-bar absence already held. |
| **D09** | 8.2 → ~9.0 | Freeze §7 empty-artifact PTY window. |
| **D07** | 8.5 → ~9.0 | Compact `{score}` slot + live 1+N cap on the TTY. |
| **D24** | 8.6 → ~9.0 | `prompt_export` captured on a real role turn; live strip shares D06. |
| **D03** | 8.5 → ~9.0 | Empty-home fixture + recency order. |
| **D05** | 8.5 → ~9.0 | Middle-head pulse observed (native spans). Residual to 10: pulse snapshot optional. |
| **D04** | 8.8 → ~9.0 | Four-role speaking-rail matrix. Residual to 10: live-PTY Critic speech optional. |
| **D28** | 8.7 → ~9.0 | Empty-artifact PTY row lands; splash preamble already native. Live-PTY splash **not** required for this 9. |
| **D16 / D26 / D12 / D01 / D08 / D11 / D13 / D14 / D15 / D21 / D25 / D27 / D29** | hold ≥9 | Do not regress splash, ask, Command, evidence, confirm, toasts, argv-only, PTY needles. Optional live evidence/splash PTY may lift 10-band residuals only. |

**Explicitly out of iter-9 (feature-creep cut):** glob-latest ask, substring confirm, Enter-to-open files, a second `#splash` widget / `ModalScreen` / `RichLog` splash, `ROBOTS_MARK` / six-node graph, new hex, role-hue splash glow, weakened/replaced PTY or `/gate` or splash needles, constructor-only no-splash flag, two writers, formatters, demanding live-PTY splash as a D16/D26 9 reopen.

If the 9-band cluster lands, stop and write `final-report.md`. If anything in the sub-9 table remains, continue to iter-10 under `extension.md` with only the leftover blockers — do not invent new scope.

---

## Verdict

FAIL. D16 and D26 clear 9.0. No zeros remain. Do not write `final-report.md`. Keep the shipped cockpit and registry row. Under `extension.md`, spawn **one** Worker on the iter-9 proof cluster only. Stop early only when every D01–D29 is >= 9.0; otherwise continue through iter-10 and refresh `not-converged.md`.
