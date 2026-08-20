# Critic debate — iteration 8 (pre-implementation, owner-extended)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-8 proposal — `iter-8/principal-proposal.md` copying `iter-7/reviewer-gate.md` “Iter-8 bind (TUI-owned splash only)”. Expected: TUI-owned boot splash, skip, idle-neutral, exact live glow, composer/footer visible, `CONSULT_NO_SPLASH` short-circuit, `/splash` remains a CLI Command turn. Implied lift: D16 0.0 → ~9.0; D26 5.0 → ~9.0; D28 8.5 → ~8.7 (not 9.0). Proof-gap work cut.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`) R7, §2.2 Boot, §3 live-glow token, §5 Splash/Non-TTY seams, §7 `CONSULT_NO_SPLASH` row, D16/D26/D28 rubric; `extension.md` (iter-6…iter-10); `iter-7/reviewer-gate.md` + `iter-7/scores.json` (D16=0.0, D26=5.0, D28=8.5; native 52/0; PTY 5/0); current `lib/tui/{app.py,theme.py,__main__.py}`, `lib/tui/tests/{test_layout.py,test_slash.py,test_all_verbs.py,test_pty.py,test_nontty.py}`, `lib/splash.sh`, `lib/repl.sh` `ROBOTS_MARK`, locked visualizer `#boot`. Inspect.md is pre-iter-1, not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE → ACCEPT the bound contract below only.**

The direction is exactly right and is the last zero-score **function**: D16 is 0.0 because there is no TUI-owned splash widget, skip, or glow; D26 is 5.0 because only the non-TTY half exists. Freeze R7 / D26's splash half are one boot state. The Reviewer paragraph plus the Principal's eight named hazards are not yet a Worker contract. They leave ten load-bearing specifics unbounded — the exact ASCII grid and who owns it, step timing and natural finish, what “idle-neutral” and “live glow” mean as Rich `Text` spans, key-interception order against `Composer._on_key` / `RoleChip.on_key` / `ctrl+c` exit-130, `#splash` vs append-only `#transcript`, `_seed` racing the overlay, focus, `CONSULT_NO_SPLASH` vs the existing 52, snapshot ownership, and behavioral (not `rg`-source) proof — and “ASCII heads on the existing compose tree” is exactly where a Worker can write the Bash six-node graph into `RichLog`, `asyncio.sleep` a glow the test never fires, paint Principal purple and call it glow, or ship a `ModalScreen` that covers the composer.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| ASCII vocabulary | “three heads matching the glow roles. Not the six-node graph. Not `ROBOTS_MARK`.” | Unbound grid, width, compact form, brand/subtitle, and owner. A Worker can paste `lib/splash.sh` `▣───────▣` (4×24), `ROBOTS_MARK` half-blocks (`lib/repl.sh:11–16`), or a 20-line drawing that covers the composer at 40×20. Freeze R7: futuristic **angular** line-art, **ASCII in Textual**, three heads (visualizer `#boot` has Principal / Analyst / Builder only — no Critic). |
| Idle-neutral / live glow | “Idle all-neutral. Live glow uses existing role hues / `OK`.” | Unbound as Rich spans. Freeze §3 assigns **live glow to `ok` `#22c55e`**, not to `principal`/`analyst`. `BUILDER` and `OK` share that hex (`theme.py:25–27`) — a source comment that “uses OK” is not D16. Visualizer `.bot.on` is `var(--ok)`. |
| Timing / finish | “deterministic stepper, not wall-clock sleep. Exact order Principal → Analyst → Builder → Principal.” | Unbound step index, interval, when natural finish fires, and whether idle is step 0. A `set_interval` the test cannot fire is a flake or a static screenshot. |
| Skip vs composer | “Enter/Esc/`/` skip without submit, without opening slash, without spawning.” | `Composer._on_key` handles **enter → `submit_composer` first** (`app.py:172–176`) and **escape → `on_composer_escape`** (`app.py:182–186`). Printable `/` falls through to `super()._on_key` and inserts. `RoleChip.on_key` Enter/Space selects a role (`app.py:258–261`). `action_interrupt_provider` **exits 130** when no provider is live (`app.py:1550–1551`). Unbound precedence. |
| Overlay vs `RichLog` | “boot splash on the existing compose tree; splash must not leave art in the transcript.” | `#transcript` is append-only `RichLog` (`app.py:332`). `_seed_home` writes Q1 rows there (`app.py:943–963`). `transcript.clear()` on skip wipes home. A `ModalScreen` covers the composer (D01). Unbound widget. |
| `CONSULT_NO_SPLASH` | “Bind app-boot env short-circuit and how splash tests unset it.” | Bash skips on **any non-empty** value (`lib/splash.sh:77–78`). Native `ProductTeamApp()` does not read it. `test_layout.py` does not set it; `test_four_sizes` then presses `/` (`test_layout.py:63`). `test_slash.py` is **not** editable this iter. `test_pty.py:127` already sets `CONSULT_NO_SPLASH=1`. Unbound default-on vs 52. |
| `/splash` | “CLI Command turn (`▣` needle). Does not restart TUI boot splash.” | `_exec_cli` already clears the env for `["splash"]` (`app.py:1385–1386`). `NEEDLES["splash"] = ("▣",)` must stay in the **Command / `_turns` cli delta** (`test_all_verbs.py:41`). Unbound: a Worker who reopens `#splash` on `/splash` zeros D26's separation. |
| Proof | “native splash proofs” | Freeze §8: missing evidence = 0.0. `rg splash app.py` or a `theme.py` helper that `#splash` never paints is **not** D16. D16/D26 ≥9 require `run_test` behavior: widget spans, skip keys, stepper order, post-finish `/splash` delta. |

Hand the Worker the bound slice below. Do not spawn until the Principal copies **this** boundary — not `principal-proposal.md`, not the Reviewer paragraph alone.

---

## Item-by-item rebuttal

### 1. Widget, compose tree, mount/seed, focus (D16 / D01 / D03)

| Verdict | **SURVIVE. Bind a `#splash` Static in the existing compose tree occupying the transcript `1fr` slot while visible. CUT `RichLog` writes, `transcript.clear()`, `ModalScreen`, a second `Screen`, and any overlay that covers `#composer-region`.** |
|---|---|
| Dimension lift | **D16** 0.0 → ~9.0 (heads + skip + glow + composer/footer). **D01** holds ≥9 (composer still below; splash is boot, not a seventh idle region). **D03** holds if skip/finish does not wipe home. |

**Compose (exact order, one new widget):**

```text
#header / #rule / #splash / #transcript / #activity / #chips / #dock /
#composer-region / #footer
```

`#splash` is `Static(id="splash", markup=False)`. Default CSS `display: none`. Class `visible` → `display: block; height: 1fr`. While splash is visible, `#transcript` takes class `splashed` → `display: none` so two `1fr` children do not split the field. `#composer-region` and `#footer` stay `display` unchanged. Do **not** replace `compose()` with a second `Screen`. Do **not** `ModalScreen`. Do **not** `ProgressBar` / `Button`.

Header, chips, activity, dock may remain mounted. Activity and dock stay hidden at boot (already). Chips and header **may** stay visible (less D01 churn than hiding them). Freeze R7 only requires composer + footer visible; the locked `#boot` frame hides header/chips, but hiding them is optional, not required.

**Never write splash bytes into `#transcript`.** `_seed` still starts from `on_mount` (`app.py:351`) and `_seed_home` may `transcript.write` Q1 rows while the RichLog is `display: none`. That is allowed and desired. Skip/finish **must not** `transcript.clear()` (that wipes Q1 and reds `_boot_home`). After skip/finish, `transcript_text()` contains home rows or the honest empty copy and **must not** contain splash art (needle `/^\` is unique to the TUI heads).

**Focus:** `on_mount` still `composer.focus()` (`app.py:347`). `#splash` is `can_focus = False` (Static default). Skip and natural finish both call `composer.focus()` again. After finish, `app.focused` is the composer (or the focused widget is `#composer`). Do not leave focus on a chip.

**Once:** `self._splash_active` is True only between `_splash_show` and `_splash_finish`. `_splash_finish` is idempotent. `on_resize`, slash, provider start, and a later `/splash` CLI verb **must not** set `_splash_active` True again on this app instance. A new `ProductTeamApp()` in the next test is a new boot.

### 2. Exact ASCII art — `theme.py` owns content and dimensions (D16)

| Verdict | **SURVIVE. Bind the 11-column three-head grid below as the only splash vocabulary. CUT six-node `▣` graphs, `ROBOTS_MARK` half-blocks, Critic/`◉`, SVG, and Worker-invented art.** |
|---|---|
| Dimension lift | D16 cannot reach 9.0 without an exact, testable grid. Visualizer `#boot` SVG is the picture; Textual ships ASCII (`frozen-benchmark.md:149–151`). |

**Owner:** `theme.py` is the only place the art strings live. `app.py` calls `theme.splash_render(width, glow)` and `Static.update`s `#splash`. No second copy of the grid in `app.py` or in tests (tests may import the helper and the constants).

**No new hex. No token-table edits. No `ROLE_STYLES` edits.** Helpers only, same rule as iter-7's `command_open` / `split_evidence_line`.

**Exact head cells (11 columns, 7 rows including label). Count every character:**

```text
Principal              Analyst               Builder
     |                      |                      |
    /^\                    /^\                    /^\
   | · · |                | · · |                | · · |
   |  ─  |                |  ─  |                |  ─  |
     |                      |                      |
    / \                     ◇                      ▸
 Principal               Analyst               Builder
```

Python constants the Worker must spell identically (each line `len == 11`):

```python
SPLASH_ROLES = ("Principal", "Analyst", "Builder")  # glow order without the wrap
SPLASH_HEADS = {
    "Principal": (
        "     |     ",
        "    /^\\    ",
        "   | · · | ",
        "   |  ─  | ",
        "     |     ",
        "    / \\    ",
        " Principal ",
    ),
    "Analyst": (
        "     |     ",
        "    /^\\    ",
        "   | · · | ",
        "   |  ─  | ",
        "     |     ",
        "     ◇     ",
        "  Analyst  ",
    ),
    "Builder": (
        "     |     ",
        "    /^\\    ",
        "   | · · | ",
        "   |  ─  | ",
        "     |     ",
        "     ▸     ",
        "  Builder  ",
    ),
}
SPLASH_GAP_WIDE = 3      # width >= 41
SPLASH_GAP_COMPACT = 1   # width <= 40
```

Wide join is `gap.join(head[row] for head in three)` → 11+3+11+3+11 = **39** columns. Compact join → 11+1+11+1+11 = **35** columns. Both fit 80 and 40 with `#splash` padding `0 1`. Do not stack heads vertically (that eats the 40×20 `1fr` and risks covering the composer). Do not scale below 11 columns.

**Brand + subtitle (two extra lines under the 7-row join, after one blank line):**

- Brand (always): exact `ProductTeam`. Style `TEXT`.
- Idle subtitle: exact `principal · analyst · builder`. Style `MUTE`.
- Live subtitle: exact `◆ Principal` / `◇ Analyst` / `▸ Builder` (glyph + space + locked name, matching `ROLE_STYLES`). Style `OK`. This **identifies** the glowing head. Do **not** append `is working · m:ss` (that is the visualizer “Work already live” frame — activity/busy, out of this slice).

**Banned needles — must be absent from `#splash` plain text and from `transcript_text()`:**

- CLI graph: `▣───────`, `6 people`, `14 links`, `shared evidence graph`, `Product Consulting Harness`, `Product Judgment Layer`
- `ROBOTS_MARK`: `▄██▄`, `█ ██ █`, `█▄▄▄▄█`, `▐▌▐▌`
- Critic: `◉`, `Critic` as a splash label
- Determinate bars, `Thinking…`

**Allowed unique splash needle:** `/^\` appears in `#splash` while active and **never** in `transcript_text()`.

`theme.splash_render(width: int, glow: str | None) -> Text` builds one `Text`: three heads joined, brand, subtitle. `glow is None` → idle. `glow in SPLASH_ROLES` → that head live. `app.py` does not restyle the `Text`.

### 3. Idle-neutral and live glow as Rich/Textual segments (D16 / D02)

| Verdict | **SURVIVE. Bind span styles on `#splash`, not comments. CUT role-hue glow (Principal purple / Analyst blue) and any proof that only reads source.** |
|---|---|
| Dimension lift | D16 10.0 names “neutral idle, exact live glow cycle”. Freeze §3: `ok` is **live glow**. D02 holds: no new hex, no cyan. |

**Idle-neutral (`glow is None`, step 0):** every span on the three heads (art + labels) and the idle subtitle is `MUTE`. Brand is `TEXT`. The `#splash` widget's styled runs **must not** include `PRINCIPAL`, `ANALYST`, `BUILDER`, `CRITIC`, `YOU`, `OK`, or `ERR` as a style (string-equal to those constants). Glyphs `◇` / `▸` on Analyst/Builder body rows stay `MUTE` at idle — they are drawing, not identity chrome.

**Live glow (steps 1–4):** the **one** active head's seven rows (six art + label) are styled `OK`. The other two heads stay `MUTE`. Live subtitle (glyph + name) is `OK`. Brand stays `TEXT`. At most one head is `OK` at a time.

Do **not** paint the glowing head in `PRINCIPAL` / `ANALYST` / `BUILDER`. Freeze token table: live glow = `ok`. `BUILDER == OK` hex (`#22c55e`) so Builder-glow vs OK is the same color; tests still pass the `OK` constant as the style, never `ROLE_STYLES["Builder"][1]` as a distinct glow rule.

**Observation (behavioral, required):** tests read spans off the **widget**, not only off a helper. Pattern: `theme.splash_render` is the source of the `Text`; `#splash` `update`s it; the test walks that `Text.spans` (or `Static.render()` equivalent) the same way `test_provider_speech_markdown_and_attached_done_card` walks `_all_spans` (`test_layout.py:784–791, 844–866`). A green `splash_render()` unit test that `#splash` never displays scores **0.0** on D16.

`NO_COLOR`: Textual's monochrome filter already applies (`__main__.py:4–5`). Splash stays ASCII; glow degrades to bold/dim. No dedicated `NO_COLOR` splash test this iter (non-TTY never reaches `ProductTeamApp`).

### 4. Timing, stepper, natural finish (D16)

| Verdict | **SURVIVE. Bind a test-firable `_splash_advance` and a 4-step glow then finish. CUT wall-clock `sleep` as the proof, and CUT an infinite cycle with no natural finish.** |
|---|---|
| Dimension lift | “Once, then the cockpit” (`frozen-benchmark.md:36, 151`). |

**Step index `self._splash_step`:**

| step | visible state | `glow` arg |
|---:|---|---|
| 0 | idle-neutral | `None` |
| 1 | Principal live | `"Principal"` |
| 2 | Analyst live | `"Analyst"` |
| 3 | Builder live | `"Builder"` |
| 4 | Principal live (cycle wrap) | `"Principal"` |
| 5 | finished — `_splash_finish()` | — |

`_splash_show` paints step 0 immediately (no wait). Production `set_interval(0.4, self._splash_advance)` (0.4s is named so a human sees four glows; tests **must not** wait on it). `_splash_advance` increments step, repaints, and on the transition **into** 5 calls `_splash_finish`. After finish the timer is stopped; further `_splash_advance` is a no-op.

Tests call `_splash_advance()` directly (and may stop the interval). **Forbidden as D16 evidence:** `await asyncio.sleep(2)`, `pilot.pause(3)`, waiting for the interval to finish the cycle. One `pilot.pause()` after an advance to let Textual layout settle is allowed.

**Natural finish and skip share `_splash_finish`:** hide `#splash` (`remove_class("visible")`), remove `splashed` from `#transcript`, idle footer `enter send · / commands · tab agents`, `composer.focus()`, `_splash_active = False`. Home rows already in the RichLog become visible. Composer text stays empty.

### 5. Key interception precedence (D16 / D11 / D18 / D29)

| Verdict | **SURVIVE. Bind one `_splash_consume_key` that runs before submit, escape, slash insert, chip select, and Ctrl+C exit-130. CUT forwarding the skip key into the composer.** |
|---|---|
| Dimension lift | Freeze R7: **any key skips**. A skip that submits a You turn or opens `/` is a D16 fail and a D11/D18 regression. |

**One helper, first in every key path:**

```text
_splash_consume_key(event) -> bool
  if not self._splash_active: return False
  event.prevent_default(); event.stop()
  _splash_finish()
  return True
```

Call **before** every other branch in:

1. `Composer._on_key` — currently enter/escape run first (`app.py:172–186`). Splash must beat `submit_composer`, `insert("\n")`, `on_composer_escape`, dock Tab/↑↓/Space, and `super()._on_key` (printable `/`, letters).
2. `RoleChip.on_key` — Enter/Space must not `select_role` during splash (`app.py:258–261`).
3. `ProductTeamApp.on_key` if added — belt for keys that miss the composer.

The skip key is **consumed**, not forwarded. After skip: `composer.text == ""` (no `hi`, no `/`, no newline). A following `/` then opens the slash dock as today.

**Keys that skip:** every `events.Key` while `_splash_active`, including `enter`, `escape`, `tab`, `space`, `up`/`down`/`left`/`right`, `backspace`, printable, `/`, `shift+enter`.

**Ctrl+C:** `BINDINGS` `ctrl+c` → `action_interrupt_provider` with `priority=True` (`app.py:273–275`). Today the no-provider branch **`self.exit(130)`** (`app.py:1550–1551`). During splash that would kill the boot. Bind: **first lines** of `action_interrupt_provider`:

```text
if self._splash_active:
    self._splash_finish()
    return
```

Then the existing first-Ctrl+C / second-Ctrl+C / idle-exit-130 machine. Native proof: splash active → `action_interrupt_provider()` → app still running, splash hidden, no exit 130. Do not weaken `test_pty_provider_interrupt` (PTY boots with `CONSULT_NO_SPLASH=1`).

### 6. `CONSULT_NO_SPLASH` semantics (D16 / D26 / D28)

| Verdict | **SURVIVE. Bind Bash-identical non-empty skip at `on_mount`, splash tests that delete the env, and Principal-suite export so uneditable `test_slash.py` stays green.** |
|---|---|
| Dimension lift | Freeze §7: set `CONSULT_NO_SPLASH=1` except while testing `/splash` or the TUI boot splash. Default-on splash reds `test_four_sizes` (`/` would skip) and every `_boot_home` wait that never sees home because keys were eaten. |

**App:** at `on_mount`, if `os.environ.get("CONSULT_NO_SPLASH")` is **non-empty** (same as `lib/splash.sh:77–78` `[[ -n "${CONSULT_NO_SPLASH:-}" ]]`), do **not** call `_splash_show`. Boot is today's idle home. Empty string or unset → show splash. Do not invent a constructor flag `ProductTeamApp(no_splash=True)` as the only seam (tests that forget it red the 52).

**`test_layout.py` (Worker may edit):**

```python
os.environ.setdefault("CONSULT_NO_SPLASH", "1")
```

near the imports, so existing rows in this file keep landing on idle home. Splash tests **must** `monkeypatch.delenv("CONSULT_NO_SPLASH", raising=False)` **before** `ProductTeamApp()`. Do not rely on a session autouse (that would hide splash from the splash tests).

**`test_slash.py` / `test_all_verbs.py` / `test_pty.py`:** Worker **must not** edit them. `test_pty.py:127` already sets the env. `test_all_verbs.py:74` `setdefault`. `test_slash.py` has no setdefault — Principal's freeze-table run **exports `CONSULT_NO_SPLASH=1`** (already §7). Worker check is `test_layout.py` only; that file's setdefault is sufficient for the Worker.

**`/splash` CLI after skip/finish:** keep `extra = {"CONSULT_NO_SPLASH": ""} if argv[:1] == ["splash"]` (`app.py:1385–1386`) so the real CLI graph streams. That empty-string override is **only** for the argv subprocess, not for re-enabling `#splash`. `NEEDLES["splash"] == ("▣",)` stays in the Command / `_turns` cli **delta**, not as TUI boot art.

### 7. Snapshots, native tests, non-TTY (D16 / D26 / D28)

| Verdict | **SURVIVE. Bind behavioral needles in `test_layout.py`. CUT snapshot-as-splash-frame on the two idle SVGs, source-only proof, live-PTY splash this iter, and `test_nontty.py` edits.** |
|---|---|
| Dimension lift | D16 ~9.0 from native `run_test`. D26 ~9.0 from TUI splash + `/splash` separation + existing non-TTY rows. D28 ~8.7 not 9.0 (empty-artifact PTY still missing). Residual to 10.0: live-PTY splash frame. |

**Do not touch** `lib/tui/tests/__snapshots__/cockpit-80x24.svg` or `palette-80x24.svg`. They remain **post-skip idle** chrome. Principal-only refresh after green pytest if something else drifted (it should not). Worker **may** add a **new** `splash-80x24.svg` as optional evidence; it is not required for 9.0 and must not replace the two existing files.

**`test_nontty.py`:** do not edit. `__main__.py:13–15` refuses non-TTY **before** `ProductTeamApp()` — splash cannot run. Existing two rows stay exact: exit 2, empty stdout, `requires an interactive TTY`, no ESC under `NO_COLOR`.

**Required native rows in `test_layout.py` (names may vary; needles may not):**

1. **Idle-neutral + chrome.** Unset env, `run_test(80,24)`, `#splash` visible, composer `region.width >= 20` and `height > 0`, footer visible, `@Principal` on `#role-prefix`, footer exact `enter continue · any key skip`, idle spans as §3, `/^\` in splash plain, `/^\` **not** in `transcript_text()`, no banned needles (§2).
2. **Stepper glow order.** From step 0, `_splash_advance` ×1..4: glowing head is Principal, Analyst, Builder, Principal; one-at-a-time `OK`; live subtitle exact; other heads `MUTE`. Fifth advance: `#splash` not visible, idle footer `enter send · / commands · tab agents`, `composer.focus()`, home rows or `No scored sessions yet` in `transcript_text()`, `/^\` still absent from transcript.
3. **Enter skips, no submit.** During splash `pilot.press("enter")` → splash hidden, no You turn, no `submit_composer` spawn, `composer.text == ""`, idle footer.
4. **`/` skips, no dock.** During splash `pilot.press("/")` → splash hidden, `dock` not `visible`, composer empty (no inserted `/`). A **second** `/` after skip opens the slash dock (existing behavior).
5. **Esc skips.** During splash `pilot.press("escape")` → splash hidden, dock not visible, idle footer (not ask/confirm/evidence strings).
6. **Env short-circuit.** `CONSULT_NO_SPLASH=1`, `#splash` never `visible`, `_boot_home` succeeds, idle footer immediately, `/` opens dock.
7. **Compact 40×20.** Unset env, splash visible, composer `>= 20`, footer visible, `#splash.region.y + height <= #composer.region.y` (does not cover), compact gap (35-col join present), skip still works.
8. **Once / no replay.** After skip, resize 80→40→80 (`on_resize`), `#splash` stays hidden.
9. **`/splash` CLI separation.** After skip (or env short-circuit), run `/splash`; Command / `_turns` cli delta contains `▣`; `#splash` stays hidden; no second `_splash_show`.
10. **Ctrl+C skips, no exit 130.** During splash `action_interrupt_provider()`; app still alive; splash hidden.

Tests isolate **this boot's** widget/transcript delta. Grepping an accumulated log is not a pass (freeze §7).

### 8. Allowed files, Worker check, Principal acceptance, dimension lift

**Files the Worker may touch:**

| File | Why |
|---|---|
| `lib/tui/app.py` | `#splash` in compose; `_splash_show` / `_splash_advance` / `_splash_finish` / `_splash_consume_key`; `on_mount` env short-circuit; key-path + Ctrl+C guard; composer/footer stay visible |
| `lib/tui/theme.py` | **only** `SPLASH_HEADS` / `splash_render` (and tiny helpers they need). **No new hex. No token table. No `ROLE_STYLES`.** |
| `lib/tui/tests/test_layout.py` | `setdefault` for existing rows; the ten behavioral splash tests |

**Files the Worker may not touch:** `provider_turn.sh`, `adapter.py`, `session.py`, `__main__.py`, `test_pty.py` assertions (five rows stay exact), `test_all_verbs.py` `NEEDLES`, `test_slash.py`, `test_nontty.py`, `conftest.py`, Bash modules (`lib/splash.sh`, `lib/repl.sh`), freeze files, existing two SVG snapshots, unrelated dirty worktree. Optional new `splash-80x24.svg` only; do not rewrite idle snapshots as splash frames.

**Worker check (one targeted file):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q
```

Necessary, not sufficient.

**Acceptance the Principal will run (Worker does not). Export `CONSULT_NO_SPLASH=1` for the full suite (freeze §7); splash tests delenv themselves:**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q          # 0 failed (do NOT freeze the count — new tests are added)
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 5 pass
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

**Non-regression needles (must remain exact — do not weaken, replace, or re-route):**

- All five PTY rows (`test_pty.py:171–369`): `/status`+`/gate`, provider interrupt (`interrupting provider` + `partial output left on disk` + `\tfailed\t` + second Ctrl+C → 130), typed `@Builder`, confirm Esc, ioctl 80→40→80.
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`; `test_confirm_run_exact_argv_for_all_three_intercepts`.
- Ask: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer ≥20.
- Evidence: `test_report_stream_evidence_panel`, `test_bench_stream_evidence_panel`, `test_report_missing_args_prints_usage` (no fake panel).
- Command/toast/card: `test_command_rail_mute_no_role_hues`, `test_export_writes_markdown`, `test_provider_sets_session_env`, `test_provider_speech_markdown_and_attached_done_card`.
- `test_nontty_refusal`, `test_nontty_no_color_no_escapes`.
- `test_all_verbs.py` `NEEDLES["splash"] == ("▣",)` in the **Command / `_turns` cli delta**; `NEEDLES["report"]` `iter-1`; `NEEDLES["bench"]` `Benchmark`.
- `test_four_sizes`, `test_home_seed_filtered`, `test_you_turn_chrome`, `test_role_chips_focusable_and_selectable`, `test_empty_artifact_stays_activity_and_speech_is_owned`.

**Honest dimension lift after this slice (not a blanket 9.0):**

| ID | After this slice | Why not higher / still out |
|---|---|---|
| **D16** | 0.0 → ~9.0 | Widget heads + skip + idle-neutral spans + stepper glow + composer/footer visible + banned-art rejection, all from `run_test`. Residual to 10.0: live-PTY splash frame. |
| **D26** | 5.0 → ~9.0 | TUI splash seam + `/splash` Command separation + non-TTY rows held. Residual: live-PTY splash. |
| **D01 / D15** | hold ≥9 | Splash must not cover composer or steal ask/confirm/evidence/slash footers. Splash footer is boot-only. |
| **D02 / D08 / D11 / D12 / D13 / D14 / D18 / D21 / D25 / D27 / D29** | hold ≥9 | No new hex; do not regress ask, Command, evidence, confirm, toasts, chips, argv-only, PTY needles. |
| **D28** | 8.5 → ~8.7 | Splash §7 row lands natively; empty-artifact **PTY** still fails. **Not 9.0.** |
| **D03 / D04 / D05 / D06 / D07 / D09 / D24** | hold | Proof-gap work is **out**. |

**Explicitly out of iter-8 (feature-creep cut):** middle-head pulse, empty-home fixture, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot, live-PTY `/report`, live-PTY splash, glob-latest ask, substring confirm, Enter-to-open files, `ModalScreen` / second `Screen` / `#splash` covering composer, writing splash into `RichLog`, `transcript.clear()` on skip, six-node graph / `ROBOTS_MARK` / Critic head, new hex, role-hue glow instead of `OK`, wall-clock-only glow proof, constructor-only no-splash flag, weakened/replaced PTY or `/gate` needles, two writers, formatters.

Those proof gaps belong in iter-9/10 **after** splash converges as a function, and only if the Reviewer still reports them as sub-9.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Splash written into `RichLog`** → `/^\` or `▣───────` drowns Q1; `_boot_home` flakes or false-passes; D03/D16 fail.
2. **`transcript.clear()` on skip** → home wiped; `test_home_seed_filtered` red.
3. **`ModalScreen` / second `Screen`** → composer covered or unmounted; D01 <9; `test_four_sizes` composer ≥20 fails.
4. **Enter not intercepted first** → You turn + provider spawn on boot; D16 skip fail; D18/D24 noise.
5. **`/` not intercepted** → slash dock opens under splash or `/` remains in composer; D11.
6. **Ctrl+C still `exit(130)`** → boot dies; D16/D29.
7. **Default-on splash, no env short-circuit** → existing 52 red (`test_four_sizes` `/` skips; `test_slash.py` uneditable).
8. **Glow is `asyncio.sleep` / interval-only** → flake or uncited; Reviewer scores D16 0.
9. **Idle “neutral” as unstyled source comment** → Principal purple glow; freeze §3 live-glow = `ok` unproven.
10. **Helper-only `splash_render` never mounted** → D16 0 (static source, not behavior).
11. **Six-node / `ROBOTS_MARK` art** → freeze R7 cut; D16 0.
12. **`/splash` reopens `#splash`** → D26 separation fails; `NEEDLES["splash"]` may leave the Command delta.
13. **40-col art taller than `1fr`** → composer covered; D07/D01 hold breaks.
14. **Piling pulse / empty-home / PTY-strip onto this slice** → 30-minute timeout; D16 claimed without evidence.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT this bound splash-only contract.** A Worker pointed at (1) `#splash` Static in the existing compose tree, never `RichLog` / `ModalScreen`, `_seed` may fill home underneath, skip/finish never `clear()`; (2) `theme.splash_render` owning the exact 11×7 three-head ASCII + `ProductTeam` + idle/live subtitles, gaps 3/1, banned graph/`ROBOTS_MARK`/Critic; (3) idle spans all `MUTE` (brand `TEXT`), live glow `OK` one head at a time Principal→Analyst→Builder→Principal, observed on the widget; (4) `_splash_advance` stepper, natural finish on step 5, 0.4s interval not used as proof; (5) `_splash_consume_key` first in composer/chip/Ctrl+C, skip consumed, composer empty, idle footer restored, `composer.focus()`; (6) non-empty `CONSULT_NO_SPLASH` skips at `on_mount`, `test_layout.py` setdefault + splash tests `delenv`; (7) `/splash` stays Command `▣` and does not replay `#splash`; (8) ten behavioral `test_layout.py` rows, existing two SVGs untouched, `test_nontty.py` / PTY / slash / NEEDLES untouched; files = `app.py` + `theme.py` (splash helper only) + `test_layout.py`; Worker check = `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q`; Principal acceptance = full native suite green under `CONSULT_NO_SPLASH=1` + existing 5 PTY rows + parity/visual gates, with pulse/empty-home/PTY-strip/live-PTY-splash cut to iter-9/10, is a bounded verifiable pass that can put **D16 and D26 at ≥9 from actual `run_test` behavior**, not static source.

### Iter-9/10 (named for convergence, not in this slice)

- middle-head pulse + honest empty-home fixture + `prompt_export` capture + live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot (D03/D05/D06/D07/D09/D24 → 9.0)
- live-PTY splash frame optional for D16/D26 10.0
- then D28 → 9.0 and `final-report.md`
