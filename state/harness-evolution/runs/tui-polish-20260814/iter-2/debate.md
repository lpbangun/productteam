# Critic debate — iteration 2 (pre-implementation)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-2 proposal — execute the Reviewer next-slice (`iter-1/reviewer-gate.md:105–113`) plus the `notes.md:42–44` “coupled live-work/control seam”: (1) retarget native boot waits so pytest is green; (2) session-local **focusable/clickable** chips; (3) composer `@Role` prefix with idle `@Principal`; (4) `provider_turn.sh ROOT PROMPT ROLE` + `activity_start "$ROLE"` + `state/agents/` `prompt_export` / `agent_card_prompt_block`; (5) “preserve” process-group interrupt; (6) one-line `#chips { color: MUTE }` fix. Expected lift named by the Reviewer: D28/D11/D21/D22 then D18/D24. Activity strip, busy footer, SIGWINCH/compact, ask/confirm/evidence, and splash claimed out — except `notes.md` still chains “honest activity/speech → dynamic footer → compact/SIGWINCH” into the same follow-on.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`), `iter-1/reviewer-gate.md`, current `lib/tui/**` source. Inspect.md is pre-iter-1 and is not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE.**

The *direction* is the right iter-2: unblock the red native suite, then land targeting + role argv so iter-3 can grow an honest activity strip. The proposal is not yet a Worker contract. It treats five distinct hazards as one-liners, over-claims dimension lifts that the freeze’s 10.0 standard still withholds, and leaves a `notes.md` back door into D06/D09/D15/D07.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Pytest unblock | “retarget boot waits” | `_boot` is only the first landmine. `test_slash.py:_wait_for` calls nonexistent `app.pause()` (`test_slash.py:84`; `pytest.txt:422–436`). `test_clear` and `test_export` still require the removed prose seed (`test_slash.py:172,199`). `test_all_verbs.py:77,114` boot-wait on `"Product Consulting"` / `"Product Consulting Harness"` |
| Focusable chips | “one-line CSS” + make chips targets | `#chips` is a non-focusable `Static` (`app.py:181,355–361`). Textual `Button` brings `$primary` cyan and padding that blows height 1. D18’s 10.0 standard requires focusable **and** clickable **and** `@Role` **and** argv **and** no Analyst hardcode — a partial chip restyle scores like today’s 2.0, not 9 |
| `@Role` prefix | “composer shows `@Role`” | Unspecified whether that is TextArea *content* or chrome. Content breaks slash detection (`app.py:409–414,502–507`), empty-send (`app.py:486–487`), and `test_you_turn_chrome` which types `h`,`i` into an empty composer (`test_layout.py:134–141`) |
| Card sourcing | “use prompt_export / agent_card_prompt_block” | Those are **two different strings**. `prompt_export` is a JSON field (`state/agents/principal.json:19`). `agent_card_prompt_block` does not read it (`lib/agent-cards.sh:199–209`). `role_invoke` (`lib/role-envelope.sh:195–255`) also pulls judgment/workspace/Builder seals — sourcing that module is a supervisor, which D08/D24 forbid |
| Interrupt | “preserving current argv/interrupt behavior” | The INT trap lives in the file whose signature and sourced modules are changing (`provider_turn.sh:14–44`). Iter-1 PTY green is against `ROOT PROMPT` + hardcoded Analyst (`reviewer-gate.md:61,91`; `pty-note.md:6–7`). Preserve is not evidence |
| Claimed lifts | D28/D11/D21/D22 then D18/D24 to gate-ready | D28 cannot reach 9.0 while SIGWINCH/ask/confirm/evidence/splash/activity §7 rows are absent. D11/D21 still lack mute Command rails (`app.py:512`). D24’s 10.0 standard includes activity row caps the proposal correctly deferred |
| Scope creep | Reviewer “explicitly out: activity/footer/compact”; notes.md still chains them | Inserting `#activity` re-opens unclaimed D01. Compact caps are vacuous without a live activity row (`iter-1/debate.md:76–78`; `reviewer-gate.md:115`) |

Hand the Worker the bound slice below. Do not spawn until the Principal copies that boundary — not the Reviewer paragraph, not `notes.md:42–44`.

---

## Item-by-item rebuttal

### 1. Retarget native boot waits / green `lib/tui/tests`

| Verdict | **SURVIVE — first mechanical step, incomplete as stated** |
|---|---|
| Dimension lift | **D28** native-pytest *sub-row only* (3.5 → ~6 if the suite is green). **D22** can approach 9.0 once chat-only native tests actually run. **D11 / D21** unblock existing slash/18-verb evidence but stay **sub-9** (slash echo is still `Text(f"/{verb}")`, not a mute Command rail — `app.py:512`; `reviewer-gate.md:81,91`) |

This is the cheapest real lift and it is mandatory before any argv change: iter-1 scored D28 **3.5** because 9 tests never left `_boot` (`reviewer-gate.md:97`; `pytest.txt:437` `9 failed, 23 passed`). The Reviewer correctly named `test_layout.py:_boot_home` as the replacement needle (`reviewer-gate.md:111`; `_boot_home` at `test_layout.py:62–73`).

**Hidden landmines the proposal does not name:**

1. `test_slash.py:84` `await app.pause()` is an `AttributeError` on `ProductTeamApp`. Today it is reached only because the stale boot needle misses; after retarget, every slash test still dies here unless `_wait_for` uses `pilot.pause()`.
2. `test_clear_clears_transcript` asserts `"Product Consulting Harness" in app.transcript_text()` **after boot** (`test_slash.py:172`). That string is the removed prose seed (`app.py:242–265` seeds `status --json` only). Retargeting `_boot` without rewriting this assertion keeps the test red.
3. `test_export_writes_markdown` asserts `"Product Consulting Harness" in text` on the export file (`test_slash.py:199`). Under `fake_env`, `/status` streams the fake *report* usage (`test_slash.py:61–65,173–177`), so that string was coming from the seed, not from CLI output. Rewrite the assertion onto an actual session/CLI turn.
4. Do **not** change `NEEDLES["status"] = ("Product Consulting Harness",)` in `test_all_verbs.py:23`. That needle is live `/status` CLI output, which must still appear in the **per-turn** delta (`test_all_verbs.py:90–93`). Changing it would weaken a freeze needle.

**Do not claim D28 ≥ 9.0 this iteration.** Freeze D28’s 10.0 standard is *every* §7 row (`frozen-benchmark.md:291`, table at `:242–256`). Green native pytest is necessary and still leaves SIGWINCH, ask, confirm, evidence, splash, role-speech, and activity rows failing.

### 2. Textual focusable / clickable chips

| Verdict | **SURVIVE only as a Static/RoleChip rewrite with a hard Button ban** |
|---|---|
| Dimension lift | **D18** (focusable + clickable + session-local selection — *part* of D18; not 9.0 without items 3–4). **D02** 8.0 → **9.0** if snapshots contain exact role hexes. **D04** 7.0 → ~8.0 (chip identity hues + selected state; speaking rails stay deferred) |

Current chips are presentation-only: `compose()` yields `Static(id="chips")` (`app.py:181`); `_render_chips` writes four `role_tag` spans into that Static (`app.py:352–361`). CSS `#chips { color: MUTE }` (`app.py:74–78`) is why both current SVGs contain **zero** of `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` (`reviewer-gate.md:37`). Removing MUTE is required, but it is not targeting.

**Implementation bans / binds (Worker may not invent):**

- **Do not use `textual.widgets.Button`.** Textual 8.2.8 Button chrome uses `$primary` (freeze-forbidden cyan `#0178D4`, `frozen-benchmark.md:72, D02`) and default padding that will push `#chips` off `height: 1`, breaking `test_four_sizes` reachability (`test_layout.py:33–41,49`).
- Keep **one** `#chips` region in `compose()`. A `Horizontal` container may replace the Static *if and only if* it keeps `id="chips"`, `height: 1`, and the existing y-order assertion `transcript < chips < composer` (`test_layout.py:49`). Do not add a second chip row. Do not insert `#activity`.
- Four child `Static` widgets (or a tiny `RoleChip(Static)` subclass) with `can_focus = True`. Click, Enter, and Space select. Left/Right cycle while the chips row is focused. After select, restore **composer** focus (D01 close-restores-focus analogue; overlays already promise this at `frozen-benchmark.md:30`).
- Focus/selected styling: bold (and only existing role hues). **No border, no outline, no `$primary`, no new hex.** `test_cockpit_token_contract` will fail any extra literal (`test_layout.py:151–166`).
- Tab: while the slash dock is visible, Composer already intercepts Tab for complete (`app.py:136–141`) — do not break that. While the dock is hidden, Tab may move focus to the chips row (locked idle hint is `tab agents`, `frozen-benchmark.md:147`). **Do not change footer copy this iteration** (D15 is out; current footer stays the shipped hint line at `app.py:188`).
- Selected role is session-local on the app (`_target_role`), default `"Principal"`. Chips must show which role is selected (bold is enough). Idle home defaults to Principal even with no click.

A Worker that only removes `color: MUTE` and leaves `Static` unfocusable has not done D18. A Worker that ships Buttons has failed D02/D01.

### 3. Composer-prefix semantics

| Verdict | **SURVIVE only as chrome + parse-on-submit; CUT as TextArea buffer content** |
|---|---|
| Dimension lift | **D18** (`@Role` visible, Principal default, typed `@Role` override). Coupled to item 2; not independently 9.0 |

Freeze text: “The composer shows `@Role`.” “Bare text defaults to `@Principal`.” “A selected chip changes the target” (`frozen-benchmark.md:68,157–159,393`). It does **not** say the TextArea buffer *is* `@Principal `.

**If `@Role` is inserted as TextArea content, these ship-regressed behaviors are guaranteed:**

- Slash dock: `_dock_prefix` / `submit_composer` key off `first.startswith("/")` (`app.py:409–414,502–507`). A leading `@Principal ` makes `/status` look like bare text and will spawn a provider turn.
- Empty send: `if not text: return` (`app.py:486–487`) never fires.
- `test_you_turn_chrome` types `h`,`i`,`enter` into a focused empty composer and asserts You body `hi` (`test_layout.py:134–141`). Prefix-in-buffer either yields `hi@Principal` (cursor at 0) or `@Principal hi` as the You body.

**Normative semantics the Worker must implement:**

1. Source of truth is `_target_role: str = "Principal"`. Chip select writes it. Typed leading `@Principal` / `@Analyst` / `@Builder` / `@Critic` (word-boundary, case-sensitive locked names) on **submit** overrides it for this turn and the rest of the session.
2. Visible `@Role` is **chrome**, not buffer content. Allowed: a prefix `Static` sibling in a height-3 Horizontal that still contains `Composer(id="composer")`. Forbidden: a new D01 region between chips and dock; forbidden: prefix as the first characters of `composer.text`.
3. On submit, strip a leading `@Role` token from the typed buffer (if the user typed one). The remainder is the user prompt. `@Role` is never appended to `_turns` user text and never passed as the PROMPT argv.
4. After strip: empty → no-op (no spawn). Remainder starting with `/` → existing slash routing, not provider. Remainder bare text → You turn of that remainder + provider turn with `_target_role`.
5. 40-col: composer region stays reachable (`test_four_sizes`). Prefix width is the `@Role` token only.

This is the difference between D18 ≥ 9 and a pytest-red targeting attempt.

### 4. Provider prompt / card sourcing + ROLE argv

| Verdict | **SURVIVE as a bash prepend inside `provider_turn.sh`; CUT `role_invoke` / `role-envelope.sh` / Python supervisor** |
|---|---|
| Dimension lift | **D18** (ROLE argv, no Analyst hardcode, `@Builder` → `workers.tsv` Builder). **D24** 5.5 → **~7.5–8.0** (signature, `activity_start "$ROLE"`, card prepend, interrupt). **Not D24 ≥ 9.0**: freeze D24 10.0 still requires workers path/columns *and row caps* (`frozen-benchmark.md:287`), which need the deferred activity widget |

Current seam: Python launches `["bash", PROVIDER_TURN_SH, ROOT, prompt]` (`app.py:605–606`); script requires only ROOT+PROMPT (`provider_turn.sh:14–16`); `activity_start Analyst` is hardcoded (`provider_turn.sh:26`); completion card is `role_tag("Analyst")` (`app.py:672`).

**Card-source ambiguity the Worker will otherwise invent:**

| Source | What it actually is |
|---|---|
| `state/agents/*.json` `prompt_export` | Short one-line field (`principal.json:19`, `builder.json:19`; schema in `state/agents/README.md:36`) |
| `agent_card_prompt_block` | jq template from display_name/traits/voice/duties — **does not read `prompt_export`** (`lib/agent-cards.sh:199–209`) |
| `role_invoke` | Engagement supervisor: judgment blocks, workspace snapshot, Builder seal, style-memory, experience-pool (`lib/role-envelope.sh:195–255`) |

Freeze provider-turn seam: `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; prepend selected role’s `prompt_export` / `agent_card_prompt_block`; default missing ROLE = Principal; reuse `lib/agent-cards.sh`; **do not reimplement a provider supervisor in Python** (`frozen-benchmark.md:167,178`).

**Normative bash path (smallest honest):**

1. Signature `provider_turn.sh ROOT PROMPT ROLE`. ROLE optional; default `Principal`. Do not `exit 2` on missing ROLE (that would break any leftover two-arg call during the same pass).
2. `export CONSULT_ROOT` first (already `provider_turn.sh:17`), then `source "$ROOT/lib/agent-cards.sh"`. **Do not source `lib/role-envelope.sh`.** **Do not call `role_invoke`.** Chat is not a sealed engagement turn.
3. `card=$(agent_card_for_role "$ROLE" 2>/dev/null || true)`. Prepend `jq -r '.prompt_export // empty'` when non-empty; else `agent_card_prompt_block "$card" "$ROLE" "-" 0`. Missing card or jq → user PROMPT only; the turn still runs.
4. Prepend into the variable passed to `provider_ask`, **never** onto stdout/stderr. Python merges stderr into stdout (`app.py:607–608`) and the first line must remain `ARTIFACT=...` (`provider_turn.sh:35`). Capture jq/function output in variables; redirect their stderr to `/dev/null`.
5. `activity_start "$ROLE" "$PROMPT" "${CONSULT_PROVIDER:-}" ''` using the **user** prompt as mission (80-char truncation in `lib/activity.sh:73`), not the card block.
6. Keep `set -m`, INT trap, `kill -TERM -- "-$pid"`, `activity_update failed`, `exit 130` (`provider_turn.sh:38–44`).
7. Python `_provider_thread` passes role as argv[4]. `_provider_done` labels the **turn’s** role, not Analyst. Do not attach the card onto the speaking turn this iteration (D10/D14/D09 — deferred with activity vs speech). Do not change streaming from `_append_provider_chunk` / `md_line` (`app.py:372–377,646–653`).

**Python must not** load cards, call `productteam card`, or spawn a second provider. Reuse is bash `source`.

### 5. Interrupt “preservation”

| Verdict | **SURVIVE as a named re-proof, not an assertion. CUT the word “preserve.”** |
|---|---|
| Dimension lift | **D24** interrupt clause; **D29** non-regression. The §7 “Provider interrupt” row (`frozen-benchmark.md:255`) |

Iter-1 already proved first Ctrl+C keeps partial artifact + `workers.tsv` `failed`, second Ctrl+C exits 130 (`test_pty.py:121–154`; `pty-note.md:6–7`; `reviewer-gate.md:55`). That proof is against the **old** `ROOT PROMPT` script that does not source `agent-cards.sh`. Sourcing a jq-using module before `ARTIFACT=` / `set -m` is exactly where the trap and the protocol line regress.

**Named acceptance units (both required):**

1. Existing `test_pty.py::test_pty_provider_interrupt` stays green after the signature/card change (default role Principal; still uses `CONSULT_PROVIDER` slow script — that is the shipped live-path fixture, not a TUI provider mock; freeze forbids mocking the live path, `frozen-benchmark.md:376`).
2. New `@Builder` proof: chip click **or** typed `@Builder` override, then a turn, records `Builder` in `workers.tsv` (freeze Role-argv row, `frozen-benchmark.md:247`). Same `CONSULT_PROVIDER` fixture pattern. Do not stub `_start_provider_turn` for this test (`test_you_turn_chrome` may keep its presentation stub).

If card loading prints anything before `ARTIFACT=`, the Python reader never finds the artifact (`app.py:618–626`) and interrupt evidence collapses to 0.

### 6. Tests beyond boot retarget (targeting + argv proofs)

| Verdict | **SURVIVE as listed files; CUT snapshot-weakening, provider mocks, and full-suite Worker runs** |
|---|---|
| Dimension lift | Enables D18/D24 citations. Does not by itself score them |

Worker may edit and may run **one** targeted pytest file (`GOAL-LOOP.md` / `frozen-benchmark.md:301`). Principal runs the freeze table.

**Add (or extend), do not weaken:**

- `test_layout.py`: chips `can_focus`; click/Enter selects Builder; `@Builder` chrome visible; default Principal; You body still `hi` with prefix chrome present; snapshots contain the four role hexes and no `#0178D4`.
- `test_pty.py`: interrupt re-proof (existing) + Builder `workers.tsv` row.
- `test_slash.py` / `test_all_verbs.py`: boot + pause + clear/export landmines from item 1.

Refresh `cockpit-80x24.svg` / `palette-80x24.svg` as evidence of new chrome. Do not drop `Directive` / `run-loop` / `smoke` / cyan assertions (`test_layout.py:197–200`).

### 7. Activity strip, busy footer, compact/SIGWINCH, docks, splash

| Verdict | **CUT — including the `notes.md:42–44` chain** |
|---|---|
| Dimension lift | none this iteration |

Reviewer already closed this (`reviewer-gate.md:107,113,115`). `compose()` has no `#activity` (`app.py:177–184`). Inserting one re-opens **D01** (unclaimed). D06/D09 require a live empty-artifact worker **and** a dedicated strip; streaming still dumps unowned `md_line` (`app.py:372–377`) — that is iter-3 once ROLE argv exists. Compact `+N` is vacuous with zero activity rows. Footer copy change without busy/ask/slash states cannot take D15 to 9.0.

No “mechanical hook.” Iter-1 already cut that escape (`iter-1/debate.md:88–94`).

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. Sequence A then B in **one** Worker. Do not start a second writer. Skip formatters, linters, and project-wide suites.

### A — Unblock native pytest (do this first)

| Change | File | Why |
|---|---|---|
| Boot wait → locked home/header projection (`_boot_home` needles) | `lib/tui/tests/test_slash.py`, `lib/tui/tests/test_all_verbs.py` | D28 native sub-row; unblocks D11/D21/D22 evidence |
| `_wait_for` uses `pilot.pause()`, not `app.pause()` | `lib/tui/tests/test_slash.py` | latent AttributeError |
| `test_clear` / `test_export` drop prose-seed assertions | `lib/tui/tests/test_slash.py` | seed no longer contains `Product Consulting Harness` |
| Keep `NEEDLES["status"]` as live CLI output | `lib/tui/tests/test_all_verbs.py` | do not weaken freeze needles |

### B — Targeting + ROLE argv + card prepend + interrupt re-proof

| Change | File | Dimension lift |
|---|---|---|
| Focusable/clickable `Static`/`RoleChip` row; no Button; no `$primary`; height 1; remove `#chips { color: MUTE }`; `_target_role="Principal"` | `lib/tui/app.py` | D18, D02, D04 |
| `@Role` chrome sibling (not buffer); parse/strip typed `@Role` on submit; slash/empty/You-body unchanged | `lib/tui/app.py` | D18 |
| `Popen([bash, script, ROOT, prompt, role])`; completion card uses turn role | `lib/tui/app.py` | D18, D24 |
| `ROOT PROMPT ROLE`; default Principal; `activity_start "$ROLE"`; source `agent-cards.sh` only; prepend `prompt_export` else `agent_card_prompt_block`; capture all card I/O; keep INT trap | `lib/tui/provider_turn.sh` | D18, D24 |
| Chip/prefix/hex snapshot tests | `lib/tui/tests/test_layout.py`, `__snapshots__/*.svg` | D02, D18 evidence |
| Interrupt re-proof + `@Builder` → `workers.tsv` Builder | `lib/tui/tests/test_pty.py` | D18, D24, D29 |

**Exact surviving dimension lift (honest, not a 9.0 promise except where named):**

| ID | Expected after this slice | Why not higher |
|---|---|---|
| **D18** | **2.0 → ≥ 9.0** | All freeze bullets: focusable chips, `@Role` chrome, session-local, Principal default, ROLE argv, card prepend, no Analyst hardcode, `@Builder` workers.tsv |
| **D02** | **8.0 → ≥ 9.0** | Role hexes in snapshots; no cyan; token contract unchanged |
| **D04** | 7.0 → ~8.0 | Chip hues + selected state; speaking-turn rails still deferred |
| **D22** | 7.5 → ~9.0 if chat-only native tests pass | Depends on A actually running `/clear` `/export` `/exit` `/provider` |
| **D11** | 6.5 → ~7.0–7.5 | Native slash tests run; mute Command rail still absent |
| **D21** | 6.0 → ~7.5–8.0 | 18-verb transcript proof unblocked; Command rail still absent |
| **D24** | 5.5 → ~7.5–8.0 | Signature + ROLE activity + card prepend + interrupt. Row caps/poll UI remain iter-3 |
| **D28** | 3.5 → ~6 | Native pytest green is one §7 row. SIGWINCH/ask/confirm/evidence/splash/activity still fail |
| **D29** | stays ≥ 9 if interrupt re-proof holds and no forbidden cuts | Do not treat pytest-green as D29 work |

**Explicitly out of iter-2:** `#activity` widget, thinking-vs-speech gating, busy/ask/slash footer strings, compact header / `on_resize` / SIGWINCH `80→40→80`, ask/confirm/evidence docks, TUI splash, mute Command rails, attaching completion cards to speaking turns, sourcing `lib/role-envelope.sh`, editing `lib/agent-cards.sh` / `lib/activity.sh` / `lib/repl.sh` / `lib/provider.sh`, provider mocks, weakening needles, two writers, formatters.

**Files the Worker may touch:** `lib/tui/app.py`, `lib/tui/provider_turn.sh`, `lib/tui/tests/test_slash.py`, `lib/tui/tests/test_all_verbs.py`, `lib/tui/tests/test_layout.py`, `lib/tui/tests/test_pty.py`, `lib/tui/tests/__snapshots__/cockpit-80x24.svg`, `lib/tui/tests/__snapshots__/palette-80x24.svg`. Theme.py only if a chip helper is strictly required; prefer app.py.

**Worker check:** `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q` (single targeted file). Principal runs the rest of the freeze table.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Focusable chips via Button** → cyan `$primary` and height-1 failure; D02/D01 drop.
2. **`@Role` as TextArea content** → slash routes to provider; `test_you_turn_chrome` red; D11/D18 both fail.
3. **`role_invoke` / `role-envelope.sh`** → judgment/workspace side effects on a chat turn; D24/D29 cut; possible interrupt protocol corruption.
4. **Card jq printed to the merged pipe** → `ARTIFACT=` never parsed; interrupt and workers.tsv proofs go to 0.
5. **Boot retarget without `app.pause` / clear / export fixes** → native suite stays red; D28 stays 3.5; A’s cheap lift is lost.
6. **No `@Builder` workers.tsv test** → D18’s freeze Role-argv row is uncited → score 0 for that bullet → D18 cannot be 9.
7. **Activity/footer/compact riding along** → 30-minute timeout replay (`GOAL-LOOP.md` prior Worker; `tui-cockpit-20260813/lessons.md:10`); D01/D06/D07/D15 claimed without evidence.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT the A-then-B boundary above only.** A Worker pointed at the files and mechanics in that table, with D18 and D02 as the only ≥9.0 targets and D24/D28 named as partial, is a bounded verifiable pass. Anything that uses Button, buffer-prefix, `role_invoke`, or the `notes.md` activity chain re-enters the recorded timeout and a 0 on the dims this iteration exists to lift.
