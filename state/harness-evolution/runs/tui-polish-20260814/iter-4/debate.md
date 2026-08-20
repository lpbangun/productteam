# Critic debate — iteration 4 (pre-implementation)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-4 proposal — Reviewer next-slice (`iter-3/reviewer-gate.md:157–168`) plus `iter-3/notes.md:30–33`: honest live activity + thinking-versus-speech + state-dependent footer + explicit 40-col / live `80→40→80`, with compact caps riding the live row. Expected lift named by the Reviewer: D06/D09 leave 0; D15 leaves 2.5; D07 leaves 5.0; D01/D24/D28 move. Non-regression: Composer stays the TTY default after inserting `#activity` / `on_resize`. Goal implied: native pytest still green, with new activity/footer/SIGWINCH proofs.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`), `iter-3/reviewer-gate.md`, current `lib/tui/app.py`, `lib/tui/session.py`, `lib/tui/tests/test_layout.py`, `lib/tui/tests/test_pty.py`, `lib/activity.sh`. Inspect.md is pre-iter-1 and is not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE.**

The *direction* is the right iter-4: suite is green, ROLE argv exists, and the next freeze holes are D06/D09/D15/D07 on one compose/poll/resize surface. The proposal is not yet a Worker contract. It says “poll real `workers.tsv`” without naming **which session**, says “stop unowned `md_line`” without forbidding a **second copy** of the same artifact, and treats native resize and freeze §7 ioctl/SIGWINCH as the same proof.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Session selection | “poll `state/.cli/runs/session-*/workers.tsv`” | `session.workers_rows` globs **all** `session-*` by mtime (`session.py:131–160`). `provider_turn.sh` writes `session-$$` of the **bash child** (`provider_turn.sh:35–39`; `lib/activity.sh:16–26,49–57`). Glob-latest will paint stale CLI/PTY sessions into this cockpit. |
| Speech | “stop streaming unowned `md_line`” (`app.py:489–494`) | `_drain_artifact` already writes every byte (`app.py:776–783`). A Worker who also `_write_turn(role, full_body)` at done **duplicates** the stream. Interrupt still requires `partial analysis begins` to appear live (`test_pty.py:137–138`). |
| Footer | idle + busy + “slash replaces hints” | Exact locked strings are unnamed. Dock-open vs busy priority is unnamed. Current copy is the slash-shaped leftover `enter send · tab complete · ↑↓ choose · esc close` (`app.py:268`; `cockpit-80x24.svg`). |
| Compact / SIGWINCH | “prove static sizes **and** live ioctl `80→40→80`” | Static four sizes already pass (`test_layout.py:21–61`). There is **no** `on_resize`. Native `run_test` size change is not ioctl. Freeze §7 names ioctl/SIGWINCH (`frozen-benchmark.md:253`). |
| `#activity` in compose | implied | `compose()` is header/rule/transcript/`#chips`/dock/`#composer-region`/footer (`app.py:253–264`). A focusable activity widget repeats the iter-2/3 dock-steal. `test_four_sizes` y-order is `transcript < chips < composer` (`test_layout.py:51`) and will go red if the strip is always on. |
| Files | “`app.py` plus tests/snapshots named by the freeze” | Idle footer change **must** refresh both SVGs. `theme.py` may need a rail-continuation helper. `session.py` glob-latest must not become the live strip. `provider_turn.sh` stays closed. |
| Acceptance | “36 passed” leftover from iter-3 | New tests change the count. Green suite, not a frozen 36. |

Hand the Worker the bound slice below. Do not spawn until the Principal copies that boundary — not the Reviewer paragraph, not `notes.md:30–33`.

---

## Item-by-item rebuttal

### 1. Activity polling / session selection (D06 / D24 UI)

| Verdict | **SURVIVE — this is the slice. Bind one TUI-owned session file. Ban glob-latest for the live strip.** |
|---|---|
| Dimension lift | **D06** 0.0 → ~7.5 (strip + braille + `m:ss` + caps; 10.0 still wants PTY empty-artifact evidence). **D24** 7.8 → ~8.5 (poll UI + caps; provider signature already shipped). **D01** 7.0 → ~8.0 (conditional seventh region; ask/confirm/evidence docks still absent). **Not ≥ 9.0.** |

`lib/activity.sh` columns are already the freeze columns: `id role state mission provider start elapsed artifact` (`lib/activity.sh:9,76–77`; `frozen-benchmark.md:123,177`). `provider_turn.sh` already calls `activity_start "$ROLE"` and prints `ARTIFACT=` (`provider_turn.sh:36–41,63`). The missing product is the **conditional strip**, not a new Bash supervisor.

**Exact likely mechanic (Worker may not invent a second one):**

1. On mount, the cockpit owns `CONSULT_STATE_ROOT/runs/session-{os.getpid()}/` (create on demand). Pass `ACTIVITY_SESSION_DIR` in the `Popen` env of `_provider_thread` (`app.py:731–741`). `activity_init` already honors that variable (`lib/activity.sh:16–19`). **Do not edit `provider_turn.sh`.**
2. Poll **that** `workers.tsv` only (Textual `set_interval` ~0.2s, UI thread, file read). Hide `#activity` when there is no `pending`/`running` row. Show it only while work is live (`frozen-benchmark.md:22–27,38`).
3. Do **not** call `session.workers_rows()` for the live strip. That helper’s glob-latest (`session.py:137–160`) is the `/workers` chat-only dump (`app.py:662–673`) and stays that dump. A second glob is a second session picker.
4. Fallback if `ARTIFACT=` arrives first: `Path(art).parent.parent / "workers.tsv"` is the same session dir (`provider_turn.sh:38–39`). Still not a glob.
5. Render live rows only (`pending`/`running`). `done`/`failed` never keep the strip open. Braille spinner (`⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`), role glyph+name, mission from the TSV, elapsed `m:ss` computed from `start` so the clock ticks even when TSV `elapsed` is stale. No `ProgressBar`. No determinate bar. No `Thinking…`.

Row caps (`frozen-benchmark.md:177`; visualizer compact `+N`):

| terminal width | live rows shown |
|---|---|
| `>= 80` | 3 |
| `>= 61` and `< 80` | 3 |
| `>= 41` and `<= 60` | 2 |
| `<= 40` | 1 plus `+N` (N = hidden live count) |

`#activity` is a non-focusable `Static` (or equivalent). **Not** `RichLog`, **not** `OptionList`, **not** `Button`. `can_focus` must stay false so Tab/slash burst still matches iter-3. CSS: hidden while idle (`display: none` / height 0); visible only with live rows. Compose order becomes header / rule / transcript / `#activity` / `#chips` / dock / composer-region / footer.

`/workers` transcript dump is out of this slice except “do not break it.”

### 2. Speech ownership without a duplicated stream (D09 / D04)

| Verdict | **SURVIVE as the same drain path, retargeted. CUT a second full-body turn.** |
|---|---|
| Dimension lift | **D09** 0.0 → ~7.5 (empty artifact stays off-transcript; first bytes open one role turn). **D04** 8.2 → ~8.5 (speaking rail exists; markdown-lite snapshot still thin). **Not ≥ 9.0.** |

Today `_append_provider_chunk` writes unowned `md_line` into the log (`app.py:489–494,776–783`). `_add_turn("provider", body)` at exit is export metadata only (`app.py:770`). `_provider_done` still writes a detached card (`app.py:798–806`) — leave that card; attaching it is D14 and is **out**.

**Normative repair (observable, one stream):**

- While the live worker’s artifact is missing or empty: transcript delta has **no** `Thinking…`, **no** role glyph/label for that worker, **no** fake agent message. Silent facts live only in `#activity`.
- On the **first** non-empty artifact bytes: write **one** colored turn for `_active_turn_role` (rail + glyph + label + dim timestamp + markdown-lite body), using `theme.turn` / a rail continuation. Subsequent chunks append **rail-prefixed body lines** for that same role. They must not call the old unowned `_append_provider_chunk` writer **and** must not `_write_turn` the full body again at `EXIT=`.
- Streaming stays live: `test_pty_provider_interrupt` still sees `partial analysis begins` before Ctrl+C (`test_pty.py:137–138`). Buffering until process exit fails that row.
- CLI `_append_cli_line` stays unowned markdown-lite (`app.py:484–487,695–696`). That is Command output, not provider speech. Mute Command rails remain **out**.

Worker may add a tiny `theme.py` helper that paints one rail+body line with an existing role hue. **No new hex.** `test_cockpit_token_contract` still forbids extras (`test_layout.py:153–168`).

### 3. Footer states (D15)

| Verdict | **SURVIVE on the same compose touch. Bind exact strings and dock > busy > idle.** |
|---|---|
| Dimension lift | **D15** 2.5 → ~8.0 (idle/busy/slash proven; ask/evidence footers still absent so **not** 9.0). |

Locked copy (freeze R6 + locked visualizer; do not invent a fourth idle line):

| State | Footer text |
|---|---|
| Idle (no live work, dock closed) | `enter send · / commands · tab agents` |
| Busy (`_provider_active` or live TSV row; dock closed; width `> 40`) | `ctrl+c interrupt · m:ss · {provider}` |
| Busy at `<= 40` | `ctrl+c · m:ss` |
| Slash dock visible | `enter run · tab complete · ↑↓ choose · esc close` |

Priority: **slash dock replaces idle/busy.** Ask/confirm/evidence footers are out (those docks do not exist). `{provider}` is the TSV `provider` field or `CONSULT_PROVIDER` basename; if unset, `—`. Elapsed is the same `m:ss` as the strip (unpadded minutes, visualizer `0:04`).

Do **not** drive busy footer from `_cli_busy` (`app.py:693,719`). `/status` is not a `workers.tsv` turn; first Ctrl+C during CLI still exits 130 (`app.py:812–826`).

Idle footer change **will** shift both snapshots. Refresh them as evidence. Palette snapshot is slash-open, so its footer must be the slash string, not idle.

### 4. Compact header + SIGWINCH (D07 / D05)

| Verdict | **SURVIVE. Split native caps/header from real-PTY ioctl. CUT pulse-as-a-new-widget.** |
|---|---|
| Dimension lift | **D07** 5.0 → ~8.0 if native 80→40→80 + PTY ioctl header hold. **D05** 8.0 → ~8.5 (compact shape; middle-head pulse may ride `_render_header` only). **Not ≥ 9.0** without the PTY row in Principal evidence. |

`_render_header` is one wide shape at every width (`app.py:385–392`). Freeze compact form is exactly `ProductTeam {score}` with heads **and** directory dropped (`frozen-benchmark.md:56–62`). Score slot stays `N.N` or `—`. Never `harness-cli` / `Directive`.

`on_resize` must re-render header, activity caps, and footer. **It must not move focus.** Forcing `composer.focus()` on every resize breaks chip Tab (`test_layout.py:239–248`).

Middle-head pulse is allowed **only** as a `_render_header` variant while work is live (middle `▣` uses `ok`). No animation library, no extra widget.

**Two proofs, not one:**

1. **Native (Worker-owned, `test_layout.py`):** `run_test` 80×24 → 40×20 → 80×24 with a **file-backed** three-row live TSV in the TUI session dir. At 80: wide header `▣─▣─▣ ProductTeam · {cwd} · {score}` and 3 activity lines. At 40: header `ProductTeam {score}` (no `▣─▣─▣`, no cwd basename), one activity line plus `+N`, composer region still reachable (`height > 0`, still below chips). Restore 80: heads + directory + 3 lines return. Also hit 60×24 → 2 lines and the existing four static sizes.
2. **Real PTY ioctl (Principal-run, Worker still **adds** the test):** new `test_pty_sigwinch_compact` in `test_pty.py`. After header `ProductTeam` at 80×24, `TIOCSWINSZ` 40×20, wait for compact `ProductTeam` without `▣─▣─▣` and without the cwd basename; `@Principal` / composer still in the stream; `TIOCSWINSZ` back to 80×24 restores `▣─▣─▣ ProductTeam`. Do **not** piggy-back `/status` onto this test. Do **not** spawn a mocked provider. Caps at 40 are proven natively (item 1); PTY here is the freeze ioctl row (`frozen-benchmark.md:253`).

Do not weaken existing PTY needles (`test_pty.py:96–117,121–154,157–199`).

### 5. Focus / targeting non-regression (D18 / D11 PTY)

| Verdict | **SURVIVE as a constraint on the same `app.py` touch, not new targeting work.** |
|---|---|
| Dimension lift | **D18 stays ≥ 9.0.** **D11 PTY slash stays green.** A “fix” that focuses `#activity` or drops `RoleChip.can_focus` zeros those bullets. |

Must still hold after compose/resize:

- `_refresh_dock` / `_close_dock` still end on `self.composer.focus()` (`app.py:551,575`).
- Composer is the real-TTY input at idle **and** while `#dock` is visible. Burst `/status\r` still reaches `submit_composer`.
- Four `RoleChip(Static)` `can_focus = True`; no Button; `@Role` stays `#role-prefix` chrome (`app.py:172–180,440–444`).
- `test_four_sizes` y-order: idle → `transcript < chips < composer` still; live → `transcript < activity < chips < composer`; dock never covers composer (`test_layout.py:49–51`).
- Do not make `RichLog` unfocusable “to be safe” unless a named test requires it — that is extra focus-graph churn.

Re-proof (Principal, not Worker full-suite): `test_pty_status_and_gate_refuse`, `test_pty_provider_interrupt`, `test_pty_typed_role_records_builder`, `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`.

### 6. Ask / confirm / evidence / splash / Command rails / provider_turn.sh

| Verdict | **CUT — including any `notes.md` “final iteration” ride-along.** |
|---|---|
| Dimension lift | none this iteration |

Reviewer already closed this (`reviewer-gate.md:159,168`). Mute Command rails (`app.py:641` still `Text(f"/{verb}")`) are a render dim, not this dependency chain. Editing `provider_turn.sh` is forbidden unless a one-line activity-column bug is proven — none is: ROLE argv and `activity_start "$ROLE"` already shipped (`provider_turn.sh:24,36`; `iter-3/reviewer-gate.md:55–59`). Sourcing `role-envelope.sh` is a supervisor (`frozen-benchmark.md:167`). No `ask.json`, no confirm intercept, no evidence panel, no TUI splash, no `ROBOTS_MARK`.

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. One Worker. Skip formatters, linters, and project-wide suites. Do not run `tests/cli-interface-parity.sh` or `tests/visual-cli.sh`.

### Repair (mechanical)

| Change | File | Why |
|---|---|---|
| Conditional non-focusable `#activity` from the **TUI-owned** `workers.tsv`; braille + mission + `m:ss`; caps 3/2/1+`+N`; hide when idle | `lib/tui/app.py` | D06 / D24 / D01 |
| Pass `ACTIVITY_SESSION_DIR` into `provider_turn.sh` env; poll that file (or `ARTIFACT=` session dir). Never glob-latest for the strip | `lib/tui/app.py`; optional `lib/tui/session.py` helper that takes an **explicit dir** | session selection |
| First artifact bytes open one role turn; later bytes are rail continuations; no unowned `md_line` **and** no full-body second write | `lib/tui/app.py`; optional `lib/tui/theme.py` rail helper | D09 without duplication |
| Idle / busy / slash footers, exact strings, dock > busy > idle | `lib/tui/app.py` | D15 |
| Compact `_render_header` at `<=40`; `on_resize` without focus steal | `lib/tui/app.py` | D07 / D05 |
| Native activity / footer / 80→40→80 / cap tests; refresh idle+palette SVGs | `lib/tui/tests/test_layout.py`, `__snapshots__/*.svg` | Worker-checkable §7 rows |
| Add `test_pty_sigwinch_compact`; do not touch existing PTY needles | `lib/tui/tests/test_pty.py` | freeze ioctl row |

**Acceptance the Principal will run (Worker does not):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
```

**Expected: green (0 failed).** Do not freeze the count at 36 — this slice adds tests.

Preserved in that same run (not optional, not isolated-only):

- `test_pty_status_and_gate_refuse` — `/status` needle `Product Consulting Harness`; `/gate` refuse no-spawn
- `test_pty_provider_interrupt` — live `partial analysis begins`; first Ctrl+C keeps partial + `failed`; second → 130
- `test_pty_typed_role_records_builder`
- `test_pty_sigwinch_compact` — ioctl 80→40→80 compact header + composer + restored heads
- `test_role_chips_focusable_and_selectable`
- `test_typed_role_prefix_strips`
- `test_four_sizes` / `test_header_cwd_projection` / `test_you_turn_chrome`

**Worker check (one targeted file only):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q
```

That file is four-size y-order, compact header, activity caps, idle/busy/slash footer, empty-artifact (no `Thinking…` / no fake role turn), and native 80→40→80. Passing it is necessary and not sufficient; Principal owns full `lib/tui/tests` including the new PTY SIGWINCH test.

Native activity tests **must** be file-backed (`CONSULT_STATE_ROOT` + TUI `session-{pid}` TSV). They must not mock `CONSULT_PROVIDER` on the live PTY path. Stubbing `_start_provider_turn` remains allowed only where `test_you_turn_chrome` already does it (`test_layout.py:132`).

**Exact surviving dimension lift (honest, not a 9.0 promise):**

| ID | Expected after this slice | Why not higher |
|---|---|---|
| **D06** | 0.0 → ~7.5 | Strip + caps exist; 10.0 wants live PTY empty-artifact citation |
| **D09** | 0.0 → ~7.5 | Owned speech, no `Thinking…`; completion card still detached (D14) |
| **D15** | 2.5 → ~8.0 | Idle/busy/slash exact; ask/evidence footers absent |
| **D07** | 5.0 → ~8.0 | Compact + native resize + PTY ioctl header; 10.0 wants all four sizes **and** live cap on a real TTY |
| **D05** | 8.0 → ~8.5 | Compact header; pulse only if it rides `_render_header` |
| **D01** | 7.0 → ~8.0 | Activity conditional; ask/confirm/evidence docks still missing |
| **D24** | 7.8 → ~8.5 | Poll + caps; interrupt/ROLE already held |
| **D04** | 8.2 → ~8.5 | Speaking rail on first bytes; markdown-lite snapshot still thin |
| **D28** | 6.6 → ~7.5 | Activity + SIGWINCH rows land; ask/confirm/evidence/splash §7 still fail |
| **D18** | stays ≥ 9.0 | No new targeting; chips/`@Role`/ROLE argv must not regress |
| **D11 / D21** | stay ~7.5 / ~8.2 | PTY slash held; Command rail still absent |

**Explicitly out of iter-4:** `ask.json` / OMP dock, confirm intercept, bordered evidence panel, TUI splash, mute Command rails, sourcing `role-envelope.sh`, editing `provider_turn.sh`, editing `adapter.py`, Button, `ProgressBar`, `@Role` in the buffer, `RoleChip.can_focus = False`, focusable `#activity`, glob-latest as the live strip, a second full-body provider turn, provider mocks on the live path, weakened/replaced PTY needles, timeout-only “fixes”, two writers, formatters.

**Files the Worker may touch:**

- `lib/tui/app.py` (required)
- `lib/tui/tests/test_layout.py` (required)
- `lib/tui/tests/test_pty.py` (add SIGWINCH only)
- `lib/tui/tests/__snapshots__/cockpit-80x24.svg`
- `lib/tui/tests/__snapshots__/palette-80x24.svg`
- `lib/tui/theme.py` — optional rail-continuation helper; **no new hex**
- `lib/tui/session.py` — optional explicit-dir reader; **do not** change `/workers` glob-latest semantics

**Files the Worker may not touch:** `provider_turn.sh`, `adapter.py`, `test_all_verbs.py` needles, Bash modules, freeze files, unrelated dirty worktree.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Glob-latest `workers_rows` as the strip** → stale `session-*` from prior PTY/CLI runs appear while idle; D06 is a lie; empty-home snapshots grow activity chrome.
2. **Keep `_append_provider_chunk` and also `turn(role, full_body)` at done** → doubled speech; D09 fails; interrupt needle still “passes” on the first copy.
3. **Stop draining until EXIT=** → `test_pty_provider_interrupt` red (`partial analysis begins` never arrives live).
4. **Focusable `#activity` / always-visible strip** → Tab count in `test_role_chips_focusable_and_selectable` drifts; `test_four_sizes` y-order red; PTY `/status` dock-steal replay.
5. **`on_resize` always `composer.focus()`** → chip keyboard selection regresses (D18).
6. **Native size-change only, no `test_pty_sigwinch_compact`** → freeze §7 ioctl row still missing; D07/D28 stay capped.
7. **Busy footer driven by `_cli_busy`** → `/status` shows `ctrl+c interrupt` while Ctrl+C would exit the app.
8. **Command rails, ask/confirm/evidence, or `provider_turn.sh` riding along** → 30-minute timeout replay (`GOAL-LOOP.md` one-writer rule; `tui-cockpit-20260813/lessons.md`).
9. **Weaken `Product Consulting Harness` / drop `/gate` / stub `_start_provider_turn` on PTY tests** → forbidden freeze-needle cut (`frozen-benchmark.md:240,376`).

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT the bound activity/speech/footer/compact contract above only.** A Worker pointed at TUI-owned session polling (not glob-latest), one owned speech stream (not a second dump), exact idle/busy/slash footers, 3/2/1+`+N` caps, compact `ProductTeam {score}`, native 80→40→80 plus a new PTY ioctl test, D18/PTY slash held, Worker check = `test_layout.py`, and Principal acceptance = **full native suite green** including the five non-regression tests plus `test_pty_sigwinch_compact`, is a bounded verifiable pass. Anything that glob-picks sessions, duplicates artifact text, focuses `#activity`, weakens PTY needles, or opens ask/confirm/evidence/splash/Command rails re-enters the recorded timeout and leaves D06/D09 at 0.
