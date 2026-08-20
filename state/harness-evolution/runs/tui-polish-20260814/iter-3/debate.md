# Critic debate — iteration 3 (pre-implementation)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-3 proposal — Reviewer next-slice (`iter-2/reviewer-gate.md:166–178`) plus `iter-2/notes.md:31–33`: restore real-PTY composer input so freeze §7 PTY slash is green, keep D18, then (notes) “the now-unblocked coupled live activity/speech/footer/compact slice,” with mute Command rails allowed to ride “if it stays local.” Expected lift named by the Reviewer: D11/D21/D28; D18 held. Goal named: native pytest **36 passed**.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`), `iter-2/reviewer-gate.md`, current `lib/tui/app.py` and `lib/tui/tests/test_pty.py`. Inspect.md is pre-iter-1 and is not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE.**

The *direction* is the right iter-3: unblock the one red native test (`test_pty_status_and_gate_refuse`) without dropping targeting. The proposal is not yet a Worker contract. It names the wrong primary mechanic (idle RoleChip-first-focus), leaves a `notes.md` back door into D06/D09/D15/D07 and mute Command rails, and treats a test-side wait as an equivalent of a product fix.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Primary mechanic | “`RoleChip` is the first `can_focus` widget; it eats `/status`” (`reviewer-gate.md:95,176`) | Same full-suite run: `/status\r` red, `@Builder…\r` green, bare `analyze the layout\r` green (`pytest.txt:28`; `pty-test.txt`; `test_pty.py:97,136,171`). Idle TTY *can* deliver printable input to the composer. The slash burst is the failing path. |
| First focusable | RoleChip | Compose order puts `#transcript` `RichLog(can_focus=True)` *before* the chips (`app.py:255–262`; Textual 8.2.8 `RichLog`/`OptionList` both `can_focus=True`). A Worker who only reorders chips can still lose to transcript or dock. |
| `/` vs `@` | unexplained | `/` opens `#dock` OptionList (`app.py:518–546`). OptionList Enter is bound to `action_select` (`textual/widgets/_option_list.py` BINDINGS). App has **no** option-selected handler. `@Builder` never opens the dock. That is the split. |
| Native slash green | implied equivalent to PTY slash | Native `_boot` re-focuses composer after seed (`test_slash.py:105–107`) and types with pilot pauses. Freeze §7 PTY slash is a **real TTY** row (`frozen-benchmark.md:253`). |
| Test-side wait | “unless a PTY wait-for-composer assertion is added” (`reviewer-gate.md:178`) | Header wait already passed (`pytest.txt:15–18`). Focus is lost *after* `/`. Sleeping before `/status\r` does not repair dock-steal and is a paper-over. |
| Scope | Reviewer “explicitly out: activity/footer/compact/rails”; notes.md then chains them and lets Command rails ride | Inserting `#activity` while PTY slash is red repeats iter-1 (new chrome, red suite). Mute rails are a render change, not the input regression. |
| Acceptance | “36 passed” named, needles “keep” named loosely | Needles, timeouts, `/gate` no-spawn, role/interrupt tests, and *who runs the suite* are not a closed contract. |

Hand the Worker the bound slice below. Do not spawn until the Principal copies that boundary — not the Reviewer paragraph, not `notes.md:31–33`.

---

## Item-by-item rebuttal

### 1. Restore real-PTY `/status` + `/gate` (D11/D21/D28 native sub-row)

| Verdict | **SURVIVE — this is the slice. Bind the dock-steal mechanic, not idle-chip-first.** |
|---|---|
| Dimension lift | **D11** ~6.8 → ~7.5 (PTY slash restored; mute Command rail still absent — `app.py:638`). **D21** ~7.8 → ~8.2 (freeze PTY `/status` row green; rail still absent). **D28** ~5.8 → ~6.5 (native pytest green is one §7 row). **Not D11/D21/D28 ≥ 9.0.** |

Exact failure (`iter-2/pytest.txt:17–21`; `test_pty.py:93–107`):

- `_wait_for(..., "ProductTeam", 25)` **passed** — cockpit header rendered.
- `_send(fd, "/status\r")` then `_wait_for(..., "Product Consulting Harness", 25)` **failed**.
- `/gate` was never reached (`pty-note.md:10–12`).
- Native suite: **1 failed, 35 passed** (`pytest.txt:28`). Total collected tests = 36.

Same run, same `ProductTeam` wait, these PTY lines **did** reach the composer:

- `test_pty_provider_interrupt`: `_send(fd, "analyze the layout\r")` → `partial analysis begins` (`test_pty.py:135–138`).
- `test_pty_typed_role_records_builder`: `_send(fd, "@Builder verify the seam\r")` → Builder `workers.tsv` (`test_pty.py:170–197`; `pty-test.txt`).

So this is not a dead PTY, not a missing header wait, and not “chips always have idle focus.”

**Exact likely mechanic (Worker may not invent a second one):**

Burst `/status\r` on a real TTY is split by the slash dock.

1. Composer (focused after `on_mount` `composer.focus()`, `app.py:268`) receives `/`.
2. `on_text_area_changed` → `_refresh_dock` → `#dock` `OptionList.add_class("visible")` + `set_options` (`app.py:518–546,259`). CSS takes the dock from `display: none` to `display: block` (`app.py:91–102`).
3. `#dock` is `OptionList(can_focus=True)` with Enter bound to `action_select`. ProductTeamApp does **not** handle option-selected; slash execution lives in `Composer._on_key` enter → `submit_composer` (`app.py:139–146,600–628`) **only while the composer is focused**.
4. Real TTY/layout refresh after the OptionList appears can move focus to a focusable that is not the composer. Remaining `status\r` never becomes composer text + `submit_composer` slash routing. Transcript never gets `Product Consulting Harness`.
5. `@Builder…\r` and bare `analyze the layout\r` never take branch (2), so they stay green.

Focusable widgets that must not consume that slash burst (compose order, `app.py:252–262`):

| Widget | `can_focus` | Why it matters |
|---|---|---|
| `#transcript` RichLog | True (Textual 8.2.8) | First focusable in tree order if screen refocuses “first” |
| `RoleChip` × 4 | True (`app.py:179`) | `on_key` handles only enter/space/left/right (`app.py:214–220`); `/` and printables are dropped; Enter calls `select_role` instead of submit |
| `#dock` OptionList | True (Textual 8.2.8) | Becomes visible exactly on `/`; Enter selects a row, no app handler → no `/status` |
| `Composer` | True | Required TTY default **and** while the slash dock is open |

Native green is explained, not a counterexample: `test_slash.py:_boot` focuses composer after home seed (`test_slash.py:105–107`); pilot keypresses keep hitting Composer, whose `_on_key` already intercepts enter/tab/up/down when `dock_visible()` (`app.py:157–167`). Freeze §7 does not accept that as the PTY slash row.

**Normative repair (observable, not an invented widget):**

- After header `ProductTeam`, a real-PTY burst `/status\r` must stream live CLI output containing `Product Consulting Harness` within the existing 25s wait, then `/gate\r` must refuse with `use the CLI: productteam gate` / `owner-gated` and must not spawn (`test_pty.py:96–117`; no `no directive`).
- Composer remains the TTY input widget at idle **and while the slash dock is visible**. Dock keyboard stays composer-driven (already implemented). Do not require a new option-selected handler unless composer-focus retention is proven insufficient — prefer not inventing a second slash path.
- `on_mount` / `select_role` / Esc must still leave the composer accepting `/` and `@Builder` (`app.py:265–268,445–453,593–597`).
- Do **not** make `RoleChip.can_focus = False`. Do **not** use `textual.widgets.Button`. Do **not** add a second composer/TextArea. Do **not** forward keys into a shadow buffer. Do **not** put `@Role` into `composer.text`.

Worker may choose the smallest product change that satisfies the observable (examples the Worker is allowed to pick among, not required as a pile): keep composer focused at the end of `_refresh_dock`; stop `#dock` OptionList from taking focus; stop a post-layout first-focusable steal from transcript/chips. One mechanical path. Not all three plus chrome.

### 2. “Wait for composer” in `test_pty.py`

| Verdict | **CUT as the repair. Optional extra assertion only after the product fix, never instead of it.** |
|---|---|
| Dimension lift | none by itself |

The header needle already succeeded. The 25s status needle is the product failure. A pre-send sleep/focus wait cannot see dock-steal (focus is lost *after* `/`). Raising the 25s timeout, replacing `Product Consulting Harness`, dropping `/gate`, or stubbing `_start_provider_turn` / `CONSULT_PROVIDER` is a weakened freeze needle (`frozen-benchmark.md:240,253,376`).

**Needle freeze (do not edit):**

| Location | Must remain |
|---|---|
| `test_pty.py:96–102` | waits 25s; needles `ProductTeam`, `Product Consulting Harness`, `use the CLI: productteam gate` |
| `test_pty.py:110–118` | `Product Consulting Harness`, `harness-cli`, gate usage, `owner-gated`, `no directive` not in txt, no `AttributeError` |
| `test_all_verbs.py:26` | `NEEDLES["status"] = ("Product Consulting Harness",)` — live CLI output, per-turn delta |
| `test_pty.py:121–154` | interrupt: partial artifact, `failed`, second Ctrl+C → 130 |
| `test_pty.py:157–199` | typed `@Builder verify the seam` → Builder `workers.tsv` `done`, mission contains `verify the seam` |

Files: **`lib/tui/app.py` only.** Do not touch `test_pty.py` this iteration.

### 3. Keep D18 (chips + `@Role` chrome + ROLE argv)

| Verdict | **SURVIVE as a non-regression constraint on the same `app.py` touch, not as new targeting work** |
|---|---|
| Dimension lift | **D18 stays ≥ 9.0.** No new D18 bullets. A “fix” that unfocuses chips or puts `@Role` in the buffer drops D18 to 0 for those bullets. |

Must still hold after the focus/dock change:

- Four `RoleChip(Static)` `can_focus = True`; click/Enter/Space select; Left/Right cycle; select restores composer focus (`app.py:171–220,445–453`; `test_layout.py:223–256`).
- No Button, no `$primary`, no new hex, `#chips` height 1, one row, y-order `transcript < chips < composer`.
- `@Role` is `#role-prefix` chrome, not `composer.text` (`app.py:103–118,260–262,439–443`).
- Typed `@Role` strip on submit unchanged (`app.py:467–477,600–633`; `test_layout.py:259–288`).
- `ROOT PROMPT ROLE`, `activity_start "$ROLE"`, `prompt_export` else `agent_card_prompt_block`, no Analyst hardcode — **do not edit** `provider_turn.sh`.
- Re-proof (Principal, not Worker full-suite): `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`, `test_pty_typed_role_records_builder`, `test_pty_provider_interrupt`.

### 4. Activity / footer / compact / SIGWINCH / Command rails / docks / splash

| Verdict | **CUT — including `notes.md:31–33` “then activity…” and “Command rails can ride”** |
|---|---|
| Dimension lift | none this iteration |

Reviewer already closed this (`reviewer-gate.md:168,174`). `compose()` has no `#activity` (`app.py:252–263`). Inserting one re-opens unclaimed D01 and repeats the iter-1 pattern (new chrome while the suite is red). Mute Command rails (`app.py:638` still `Text(f"/{verb}")`) are a render dim, not the input regression; shipping them here inflates the diff and still leaves D11 sub-9 on the 10.0 standard (`frozen-benchmark.md:274`). Compact caps remain vacuous without a live activity row.

No “if it stays local.” No mechanical hook.

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. One Worker. Skip formatters, linters, and project-wide suites.

### Repair (mechanical, `app.py` only)

| Change | File | Why |
|---|---|---|
| Keep `Composer` as the real-TTY input target at idle **and while `#dock` is visible**, so burst `/status\r` reaches `submit_composer` slash routing | `lib/tui/app.py` | Unblock D11/D21/D28 PTY slash row |
| Do not steal that focus to `#transcript`, `RoleChip`, or `#dock` OptionList on dock-open / layout refresh | `lib/tui/app.py` | Exact `/` vs `@` split |
| Leave RoleChip focusable/clickable Static; `@Role` chrome; select/Esc restore composer | `lib/tui/app.py` | Hold D18 |

**Acceptance the Principal will run (Worker does not):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
```

**Expected: 36 passed, 0 failed.** (Today: 35 passed, 1 failed — the one failure is `test_pty_status_and_gate_refuse`.)

Preserved in that same run (not optional, not isolated-only):

- `test_pty_status_and_gate_refuse` — `/status` needle `Product Consulting Harness`; `/gate` refuse no-spawn
- `test_pty_provider_interrupt`
- `test_pty_typed_role_records_builder`
- `test_role_chips_focusable_and_selectable`
- `test_typed_role_prefix_strips`

**Worker check (one targeted file only):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q
```

That file is three tests: slash, interrupt, builder. Passing it is necessary and not sufficient; Principal owns the 36.

**Exact surviving dimension lift (honest, not a 9.0 promise):**

| ID | Expected after this slice | Why not higher |
|---|---|---|
| **D11** | ~6.8 → ~7.5 | PTY `/status`+`/gate` restored; echo still not a mute Command rail |
| **D21** | ~7.8 → ~8.2 | Freeze PTY status row green; Command rail still absent |
| **D28** | ~5.8 → ~6.5 | Native pytest 36/36 is one §7 row. SIGWINCH/ask/confirm/evidence/splash/activity still fail |
| **D18** | stays ≥ 9.0 | No new targeting; chips/`@Role`/ROLE argv must not regress |
| **D22** | stays ~9.1 if `/gate` PTY now reached | Native refuse already green; real-PTY `/gate` was the hole |
| **D29** | stays ≥ 9 if interrupt still holds and no forbidden cuts | Do not treat pytest-green as D29 work |

**Explicitly out of iter-3:** `#activity`, thinking-vs-speech gating, footer string change, compact header / `on_resize` / SIGWINCH `80→40→80`, ask/confirm/evidence docks, TUI splash, mute Command rails, sourcing `role-envelope.sh`, editing `provider_turn.sh` / `adapter.py` / `theme.py` / snapshots, Button, `@Role` in the buffer, `RoleChip.can_focus = False`, second composer, provider mocks, weakened/replaced PTY needles, timeout-only “fixes”, two writers, formatters.

**Files the Worker may touch:** `lib/tui/app.py` only.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Idle-chip-first “fix” only** (reorder chips / auto-focus composer on mount again) → `/` still opens OptionList, burst still dies, suite stays 35/1. D11/D28 stay red.
2. **`RoleChip.can_focus = False`** → native `test_role_chips_focusable_and_selectable` red; D18 targeting bullet 0.
3. **Button chips** → cyan `$primary` + height-1 failure; D02/D01 drop.
4. **Wait/sleep in `test_pty.py` instead of product repair** → freeze PTY slash still false on a real TTY; needles papered; Reviewer scores D11/D28 on product behavior.
5. **Weaken `Product Consulting Harness` / drop `/gate` / bump 25s / change `NEEDLES["status"]`** → forbidden freeze-needle cut (`frozen-benchmark.md:240`).
6. **Command rails or `#activity` riding along** → 30-minute timeout replay; D01/D06/D15 claimed without evidence; suite still red if input is unfixed.
7. **No interrupt / `@Builder` re-proof** → D18/D24/D29 collapse on the same `app.py` touch that changes focus.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT the `app.py`-only dock/composer focus repair above only.** A Worker pointed at that mechanic, with needles frozen, D18 held, activity/rails cut, Worker check = `test_pty.py`, and Principal acceptance = **36 passed** including role/interrupt tests, is a bounded verifiable pass. Anything that disables chip focus, weakens PTY needles, or opens the `notes.md` activity chain re-enters the recorded timeout and leaves the one red test red.
