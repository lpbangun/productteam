# Critic debate — iteration 6 (pre-implementation, owner-extended)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-6 proposal — one shared dock state machine (`ask` + `confirm`) extending the existing dock-above-composer: poll a structured `ask.json` beside the active provider artifact, validate the canonical §6 schema, render the exact role question as a real colored turn, single/multi selection with recommended and `k of n`, ↑↓/Space/Enter/Esc, composer retained; intercept exactly `/gh merge`, `/checks --allow-dirty`, `/onboarding --yes` before `run_argv_stream`, Run executes the original argv, Cancel/Esc executes nothing; ask/confirm footer states; evidence/splash/Command-rail/toast/card polish deferred to iter-7/8.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`) §6 ask schema, §7 Confirm/Ask rows, D01/D08/D13/D15/D25/D28 rubric; `extension.md` (owner-authorized iter-6/7/8); `iter-5/reviewer-gate.md` + `iter-5/scores.json` (D08=0.0, D13=0.0, D25=0.0, D15=8.0, D01=8.0, D28=7.2); current `lib/tui/app.py`, `lib/tui/session.py`, `lib/tui/tests/{test_slash.py,test_layout.py,test_pty.py}`. Inspect.md is pre-iter-1, not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE → ACCEPT the bound contract below only.**

The direction is exactly right and is the highest-leverage remaining work: two zero-score functional seams (D08 ask, D13 confirm) close on one existing surface (the `#dock` OptionList), and both are already named by the freeze with concrete schemas and §7 rows. The proposal is not yet a Worker contract. It leaves six load-bearing specifics unbounded — the exact ask-file path, the persisted answer shape, one-time consumption, validation/failure behavior, token-level confirm matching, and the no-spawn proof — and “extend the existing dock” is exactly where a Worker can ship a second `OptionList`, a `ModalScreen`, or a composer-bypass that zeros D01/D29 and replays the iter-2/3 dock-steal.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Ask path | “`ask.json` beside the active provider artifact” | `_provider_thread` already parses `ARTIFACT=` and retargets `self._activity_session_dir = Path(art).parent.parent` (`app.py:975–976`). The artifact is `{session}/artifacts/{id}.txt`, so “beside the artifact” is **`Path(art).parent / "ask.json"`** — but only the provider thread holds `art`. It must be surfaced as `self._active_artifact` or the poll will invent a glob / fixed path (both forbidden). |
| Answer shape | “persist a structured answer beside ask” | No filename, no fields, no atomicity, no cancel representation. Unbound. |
| One-time consumption | “poll only … beside the active provider artifact” | Poll-on-idle replays the same ask forever; nothing says how a consumed/invalid ask is retired. Unbound. |
| Validation/failure | “validate canonical schema” | Freeze §6 already lists required/denied; the honest-failure path (no fake question, no spawn, no retry-loop) is unbound. |
| Dock modality | “extend the existing dock … not another supervisor or modal” | Current `#dock` is one `OptionList` (`app.py:283`) driven only by slash (`_refresh_dock`/`_close_dock`). Nothing binds `kind`/state, nothing stops a Worker from adding a second widget or `ModalScreen`. |
| Input routing | arrows/Space/Enter/Esc | Composer already intercepts Enter/Esc/Tab/↑↓ while the dock is visible (`app.py:155–184`) and `submit_composer` (`app.py:799–823`) always routes to slash/provider. Space is unhandled. Unbound per kind. |
| Confirm matching | “intercept exactly `/gh merge` …” | “Exact” is unbound at the token level. `test_all_verbs.py` uses `/gh preflight` (`VALID_ARGS["gh"]`); a substring/intercept-everything Worker breaks it. |
| Argv preservation | “Run executes original argv” | Unbound whether Run re-tokenizes or reuses `[verb, *tokens]`; re-tokenization is a new parser and a D27 hazard. |
| Footer strings | “ask/confirm states” | Exact strings unbound; `_render_footer` (`app.py:445–458`) currently prints the slash string for every dock-open state. |
| No-spawn proof | “Cancel executes nothing” | Freeze §7 Confirm row requires an **argv log empty for that attempt**. Unbound mechanism (existing `test_gate_refused_without_spawn` recorder is the template). |

Hand the Worker the bound slice below. Do not spawn until the Principal copies this boundary — not the prose proposal, not `iter-5/notes.md`.

---

## Item-by-item rebuttal

### 1. Structured ask seam (D08 / D25 / D01 / D15)

| Verdict | **SURVIVE — this is half the slice. Bind path, schema, consumption, rendering, routing, and footers. CUT any second widget, ModalScreen, or transcript scraping.** |
|---|---|
| Dimension lift | **D08** 0.0 → ~9.0 (exact structured consumption, colored turn, single/multi, `k of n`, all controls, fixture, no scraping/supervisor). **D25** 0.0 → ~6.5 (ask + confirm seams real; evidence parsing still absent). **D01** 8.0 → ~8.5 (ask dock above composer; evidence dock still absent). **D15** 8.0 → ~9.0 (ask footer completes R6). **Not ≥ 9.0** on D01/D25. |

**Exact ask-file path (no glob, no fixed path, no second picker):**

`_provider_thread` sets `self._active_artifact = art` immediately after the `ARTIFACT=` retarget (`app.py:975–976`). The poll reads **`Path(self._active_artifact).parent / "ask.json"`** — i.e. `{session}/artifacts/ask.json`, the sibling of the live provider artifact. Poll only while `self._provider_active` is True and `self._dock_kind == "slash"` (an ask/confirm dock must never be clobbered by a later slash refresh). The read happens in `_poll_activity` (0.2s, UI thread) as a cheap `read_text` + `json.loads`; it is not a daemon, not a watcher, not a supervisor.

**Persisted answer path + shape (atomic):**

After Enter (confirm) or Esc (cancel), write `Path(self._active_artifact).parent / "ask.answer.json"` via **temp-file + `os.replace`** (never a half-written file a concurrent reader can see):

```json
{
  "event": "ask-answer",
  "ask_id": "<same id as the ask>",
  "answers": ["<option-id>", ...],
  "cancelled": false
}
```

- Enter → `cancelled:false`; `answers` = selection (single: exactly the one selected id; multi: the toggled set, may be one or more).
- Esc → `cancelled:true`; `answers:[]`.

**Validation + honest failure (no fake question, no spawn, no retry-loop):**

Load `ask.json` only once per `id`. Validate against freeze §6 exactly: `event=="ask"`; non-empty `id`, `question`; `role` ∈ {Principal, Analyst, Builder, Critic}; `mode` ∈ {single, multi}; non-empty `options`; each option has unique non-empty `id`, non-empty `label`, non-empty `description`, boolean `recommended`; at most one `recommended` when `mode=="single"`; `default` is an array of option ids, obeys mode/option membership (single → ≤1, multi → ≥0). On **any** violation: do **not** open the dock, do **not** render a question turn, do **not** spawn; emit one mute line `ask ignored: <specific reason>` and retire the file (`os.replace` → `ask.json.invalid`). A missing/prose-only file never opens anything.

**One-time consumption (id-keyed + retired):**

Track `self._ask_seen_id: str | None`. Once an ask is answered, cancelled, or invalid, record its id and retire the file: `os.replace` `ask.json` → `ask.json.done` (answered/cancelled) or `ask.json.invalid` (malformed). The dock never re-opens for a retired id. A later provider turn writes a fresh `ask.json` in a fresh `{session}/artifacts/` directory, so no stale ask leaks across turns.

**Question turn (real, colored, exact):**

On a valid ask, render the exact `question` verbatim as one owned role turn using the existing `turn(role, question)` helper (`app.py:_write_turn`) — rail + role glyph/label + dim timestamp + neutral body, hue from `ROLE_STYLES[role]`. Never rewrite the question, never scrape transcript prose to synthesize one, never use `_echo`/`_echo_muted` for the question body.

**Dock state (one region, no modal):**

The single `#dock` `OptionList` (`app.py:283`) gains `self._dock_kind: str` ∈ {`"slash"`, `"ask"`, `"confirm"`}, default `"slash"`. No second `OptionList`, no `ModalScreen`, no `Screen` push, no new region between chips and dock. Opening ask/confirm closes the slash dock; `_refresh_dock` (slash) must early-return while `_dock_kind != "slash"`. Each ask option renders label (bold when `recommended` or in `default`) plus a second mute description line; the dock also surfaces the `k of n` counter (see footer).

**Input routing + focus (composer retained, close restores focus):**

- `submit_composer` (`app.py:799–823`) must **early-route before any slash/provider logic**: `_dock_kind == "ask"` → `_confirm_ask(); return`; `_dock_kind == "confirm"` → `_run_confirm(); return`.
- Composer `_on_key` while `dock_visible()`: Enter → `submit_composer` (routes per kind above); Esc → `on_composer_escape` (routes per kind); ↑/↓ → existing `dock_move` (all kinds); Tab → slash completion **only** (no-op for ask/confirm); Space → literal space for slash, **toggle** current option for ask (multi: toggle membership; single: select the highlighted id), no-op for confirm.
- `_close_dock`/confirm/cancel always end `self._close_dock(); self.composer.focus()` (D01 close-restores-focus; composer never hidden or replaced).

**Footer (dock > busy > idle priority already holds in `_render_footer`):**

| Kind | Exact footer string |
|---|---|
| slash | `enter run · tab complete · ↑↓ choose · esc close` (unchanged) |
| ask single | `{k} of {n} · ↑↓ choose · space select · enter confirm · esc cancel` |
| ask multi | `{k} of {n} · ↑↓ choose · space toggle · enter confirm · esc cancel` |
| confirm | `↑↓ choose · enter run · esc cancel` |

`{k}`/`{n}` are the current selection index/count and option count respectively (live, per freeze §6 “`k of n`”). These replace idle/busy while the corresponding dock is open.

### 2. Confirm interception (D13 / D25 / D27)

| Verdict | **SURVIVE — the other half. Bind token-exact matching, original-argv reuse, and the no-spawn proof. CUT substring matching and any second parser.** |
|---|---|
| Dimension lift | **D13** 0.0 → ~9.0 (three writes intercepted; Run real argv; Cancel no-spawn; other mutations still refused by the registry). **D25** (with §1) → ~6.5. **D27** holds (still argv-only through `adapter.run_argv_stream`). |

**Matching is exact-argv, not substring, not “all writes”:**

In `_run_slash` (`app.py:830–892`), after `kind = adapter.classify(verb)` and **before** the `supported → self._exec_cli([verb, *tokens])` branch, intercept only when `kind == "supported"` **and** the tokenized argv is exactly one of:

| Slash text | `verb` | `tokens` (exact list) |
|---|---|---|
| `/gh merge` | `gh` | `["merge"]` |
| `/checks --allow-dirty` | `checks` | `["--allow-dirty"]` |
| `/onboarding --yes` | `onboarding` | `["--yes"]` |

`tokens = session.tokenize(args)` (`app.py:834`) — list equality, no substring. `/gh preflight` (`test_all_verbs.py` `VALID_ARGS["gh"]`), `/gh status`, `/checks`, `/onboarding`, and every other argv are **not** intercepted and take the existing path. Unsupported verbs still refuse via the registry (unchanged); other supported mutations still run immediately (unchanged — freeze R4 only names these three writes).

**Confirm dock + argv preservation:**

When intercepted, open `_dock_kind == "confirm"` with exactly two options — `Run /{verb} {args}` (default highlighted) and `Cancel` — and do **not** call `_exec_cli` yet. On Run: `self._exec_cli([verb, *tokens])` reusing the **original** `tokens` — no re-tokenize, no flag rewrite, no string re-parse (D27 argv-only; `adapter.run_argv_stream` already token-audits). On Cancel/Esc: call nothing — no `_exec_cli`, no `run_argv`, no `Popen`, no side effect.

**Cancel/no-spawn proof (freeze §7 Confirm row — argv log empty for that attempt):**

Native: in `test_slash.py`, reuse the existing recorder pattern (`test_gate_refused_without_spawn`, `adapter.run_argv_stream = recorder`): drive `/gh merge` → choose `Cancel` → assert `spawns == []` and the confirm dock rendered; then drive `/checks --allow-dirty` → `Run` → assert `spawns == [["checks","--allow-dirty"]]` (exact argv). Principal additionally records a PTY note + argv trace showing the cancelled attempt left the argv log empty. Do **not** mock `CONSULT_PROVIDER` on the live PTY path.

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. One Worker. Skip formatters, linters, and project-wide suites. Do not run `tests/cli-interface-parity.sh` or `tests/visual-cli.sh`.

| Change | File | Why |
|---|---|---|
| `self._dock_kind` state on the existing `#dock` OptionList; ask/confirm open/close; no second widget/Modal | `lib/tui/app.py` | D01 / D08 / D13 dock-above-composer, close restores focus |
| `_provider_thread` sets `self._active_artifact = art`; `_poll_activity` reads `Path(art).parent/"ask.json"` only while `_provider_active` and kind==slash | `lib/tui/app.py` | D08/D25 file-backed ask beside the active artifact |
| §6 validation; exact `turn(role, question)`; single/multi + recommended + `k of n`; ↑↓/Space/Enter/Esc; atomic `ask.answer.json`; id-keyed retire | `lib/tui/app.py` | D08 |
| Exact-argv intercept of the three writes; `Run → _exec_cli([verb,*tokens])`; Cancel/Esc executes nothing | `lib/tui/app.py` | D13 / D27 |
| Ask/confirm footer strings (dock > busy > idle) | `lib/tui/app.py` | D15 |
| Ask dock + footer + one-time consumption native tests | `lib/tui/tests/test_layout.py` | D08 / D15 / D01 |
| Confirm Run/Cancel no-spawn recorder tests (exact argv) | `lib/tui/tests/test_slash.py` | D13 |

**Worker check (one targeted file only):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_slash.py -q
```

That file holds the confirm no-spawn/spawn contract (D13) and the existing `/gate` no-spawn needle. Passing it is necessary and not sufficient; the Principal owns the full `lib/tui/tests` run, including the new `test_layout.py` ask-dock rows and the PTY rows.

**Acceptance the Principal will run (Worker does not):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q          # 0 failed (do NOT freeze the count — new tests are added)
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 4 pass; plus any new PTY confirm row
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

**Non-regression needles (must remain exact — do not weaken, replace, or re-route):**

- `test_pty_status_and_gate_refuse` — `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:171–179`).
- `test_pty_provider_interrupt` — live `partial analysis begins`; first Ctrl+C keeps partial + `failed`; second Ctrl+C exits 130.
- `test_pty_typed_role_records_builder` — live `builder analysis complete`; Builder/`done`/`verify the seam`.
- `test_pty_sigwinch_compact` — ioctl 80→40→80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads.
- `test_gate_refused_without_spawn` — unsupported `/gate` still refuses with zero spawns (confirm intercept must not touch the unsupported path).
- `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`, `test_four_sizes`, `test_you_turn_chrome`, `test_activity_file_backed_caps_footer_and_resize`, `test_empty_artifact_stays_activity_and_speech_is_owned`.
- `test_all_verbs.py` `NEEDLES["status"]` and the `gh preflight` supported-verb stream — unchanged.

**Exact surviving dimension lift (honest, not a blanket 9.0 promise):**

| ID | After this slice | Why not higher |
|---|---|---|
| **D08** | 0.0 → ~9.0 | Full schema + colored turn + single/multi + `k of n` + controls + file-backed fixture, no scraping/supervisor. Residual to 10.0: none required by the freeze (file-backed seam is the freeze-named equivalent). |
| **D13** | 0.0 → ~9.0 | Three writes intercepted; Run real argv; Cancel no-spawn (recorder + PTY argv trace). Residual: PTY trace is Principal-owned evidence. |
| **D01** | 8.0 → ~8.5 | Ask + confirm docks above composer, close restores focus; evidence dock still absent (iter-7) so not 9.0. |
| **D15** | 8.0 → ~9.0 | Ask footer completes R6 (`idle/busy/ask/slash` all exact); confirm footer is contract-added, not a freeze row. |
| **D25** | 0.0 → ~6.5 | Ask file + pre-run write intercept real and file-backed; evidence path parsing absent (iter-7). |
| **D28** | 7.2 → ~7.8 | Ask + confirm §7 rows land; evidence + splash + activity-vs-speech-PTY rows still absent. |
| **D27 / D22 / D29** | hold ≥9 / ≥9 / ≥9 | Confirm Run still argv-only; unsupported refuse unchanged; no forbidden cuts; no second writer. |

**Explicitly out of iter-6 (feature-creep cut):** bordered evidence panel (D12), mute Command rails (D11/D21), session toasts + attached completion cards (D10/D14/D19), TUI splash (D16/D26), middle-head pulse (D05), speaking-turn markdown-lite snapshot (D10), `provider_turn.sh` edits, `adapter.py` edits, `role-envelope.sh`/`role_invoke`, a second `OptionList`/`ModalScreen`/`Screen`, `Button`, provider mocks on the live path, glob-latest ask discovery, substring confirm matching, re-tokenizing Run argv, weakened/replaced PTY or `/gate` needles, two writers, formatters.

**Files the Worker may touch:**

- `lib/tui/app.py` (required — dock kind/state, ask poll/validate/render/answer, confirm intercept, footers)
- `lib/tui/tests/test_layout.py` (ask dock + footer + one-time consumption native tests)
- `lib/tui/tests/test_slash.py` (confirm Run/Cancel no-spawn recorder tests)
- `lib/tui/theme.py` — **only** if a pure helper is needed that reuses existing `turn`/`ROLE_STYLES`/`MUTE`; **no new hex, no token changes**

**Files the Worker may not touch:** `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` assertions (may add a PTY confirm row **only** with the same needles and 25s waits), `test_all_verbs.py` needles, Bash modules, freeze files, snapshots, unrelated dirty worktree.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Glob or fixed-path ask discovery** → a stale `ask.json` from another session opens a fake question; D08/D25 fail the “beside the active artifact” row.
2. **No id-keyed retire** → the same ask re-opens on every 0.2s poll; Enter/Esc spawn loop; PTY hangs.
3. **Malformed `ask.json` opens a dock or writes a fake turn** → freeze §6 “honest failure/refusal and no provider spawn” violated; D08 not 9.0.
4. **Second `OptionList` / `ModalScreen`** → D01 y-order `dock above composer` and close-restores-focus regress; replay of iter-2/3 dock-steal.
5. **`submit_composer` not early-routed** → Enter in an ask/confirm dock spawns a provider turn or re-runs slash; D13 no-spawn proof falsified.
6. **Substring / intercept-everything confirm** → `/gh preflight` (a supported test verb) breaks; D13/D27 drift.
7. **Run re-tokenizes or rewrites argv** → a second parser; whole-token audit and `agents --json` allowance diverge from D27.
8. **Cancel path calls anything** → argv log non-empty for a cancelled attempt; freeze §7 Confirm row fails.
9. **Evidence/Command-rail/splash/toast riding along** → 30-minute timeout replay on the extension; D12/D11/D16/D14 claimed without evidence.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT this bound ask+confirm dock-state-machine contract only.** A Worker pointed at (1) `ask.json` at `Path(self._active_artifact).parent/ask.json`, validated against §6, rendered as one exact colored `turn(role, question)`, single/multi + recommended + `k of n`, ↑↓/Space/Enter/Esc, atomic `ask.answer.json`, id-keyed retire, honest invalid refusal; (2) exact-argv intercept of `/gh merge`/`/checks --allow-dirty`/`/onboarding --yes`, Run → `_exec_cli([verb,*tokens])` original argv, Cancel/Esc → nothing, recorder-proven no-spawn; one `#dock` with `_dock_kind`, composer retained and focus restored; ask/confirm footers; files = `app.py` + `test_layout.py` + `test_slash.py` (+ optional token-neutral `theme.py` helper); Worker check = `test_slash.py`; Principal acceptance = full native suite green + existing 4 PTY rows + parity/visual gates, with evidence/Command-rail/splash/toast/card polish cut to iter-7/8, is a bounded verifiable pass.

### Iter-7 / iter-8 (named for convergence, not in this slice)

- **iter-7:** bordered evidence panel (D12; D25→9.0, D01→9.0), mute Command rails (D11/D21→9.0), session toasts + attached done card + speaking-turn markdown-lite snapshot (D10/D14/D19→9.0).
- **iter-8:** TUI splash + non-TTY seam (D16/D26→9.0), middle-head pulse + honest empty-home fixture + `prompt_export` capture + live-PTY activity-strip/empty-artifact/compact-cap-and-score-slot assertions (D03/D05/D06/D07/D09/D24→9.0), then D28→9.0 and `final-report.md`.
