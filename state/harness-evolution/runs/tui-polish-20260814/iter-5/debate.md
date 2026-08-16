# Critic debate — iteration 5 (pre-implementation, final)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-5 proposal — Reviewer next-slice (`iter-4/reviewer-gate.md:72–90`) plus `iter-4/notes.md:23–25` / `iter-4/pty-note.md:10–13`: repair-only restore of green native tests (live artifact drain, SIGWINCH ANSI normalize, `/status` tail), with docks/splash “only after the suite is green.” Expected: native pytest 0 failed. Implied lift: D09/D11/D07/D18/D24/D28 move; no 9.0 promise.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`), `iter-4/reviewer-gate.md`, `iter-4/pytest.txt`, current `lib/tui/app.py`, `lib/tui/tests/test_pty.py`. Inspect.md is pre-iter-1 and is not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run. Iter-5 is the last implementation iteration (`GOAL-LOOP.md` stop at 5). Feature scope is closed, not deferred.

---

## Overall verdict

**REVISE-SLICE.**

The *direction* is the right iter-5: suite is red (4 failed / 35 passed), the landed UI stays, and the next work is three product/PTY repairs on the same `_provider_thread` / poll / ioctl surface. The Reviewer paragraph is not yet a Worker contract. It says “short sleep” without a bound, “flush per read” without placing the existing `_add_turn` / `proc.wait()` / interrupt reaper, “or otherwise normalize” as a second SIGWINCH mechanic, and “diagnose the poll/stream interference” as an open invention. The “after green, docks may be considered” clause is a feature back door on the final iteration.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Live drain | “re-drain while `proc.poll() is None` (short sleep, keep `size`, flush per read), then a final drain” | After `ARTIFACT=`, `_drain_artifact` runs **once**, then `_add_turn("provider", body)` (metadata), then **`proc.wait()` blocks** (`app.py:954–967`). Speech after the first empty read never reaches the transcript until exit. Interrupt never gets to send Ctrl+C because `partial analysis begins` never appears live (`iter-4/pytest.txt:34–38`). Sleep, flush-vs-metadata, and killpg interaction are unnamed. |
| SIGWINCH | “strip control sequences … or otherwise normalize” | First needle is raw contiguous `▣─▣─▣ ProductTeam` (`test_pty.py:220`). Textual splits styled header segments, so the byte string never appears (`iter-4/reviewer-gate.md:46`). Compact **absence** of `▣─▣─▣` on raw bytes can false-pass if heads are present but ANSI-split. “Otherwise” lets a Worker replace the three-head needle with `ProductTeam`. |
| Status tail | “diagnose poll/stream interference; serialize/slow-path **or** reduce poll overhead” | `_run_status_gate_session` already returned: title wait passed, gate usage wait passed (`pytest.txt` failure is post-hoc `harness-cli`, `test_pty.py:114`). Same test was green in iter-3. New 0.2s `_poll_activity` re-renders header+footer+activity every tick (`app.py:296,460–470`) on the same UI thread as `_append_cli_line` (`app.py:884–885`). Two product inventions plus a test-side wait are on the table. |
| Scope | “repair first; docks/splash after green” | `GOAL-LOOP.md` stops at iter-5. There is no iter-6. Ask/confirm/evidence/splash are **cut**, not queued. |
| Worker check | unnamed (Principal full suite only) | `GOAL-LOOP.md` rule 2: Worker may run one targeted pytest file. The four reds live in `test_pty.py`. |

Hand the Worker the bound slice below. Do not spawn until the Principal copies that boundary — not the Reviewer paragraph, not `notes.md:23–25`.

---

## Item-by-item rebuttal

### 1. Live artifact drain + stop/interrupt (D09 / D14 / D18 / D24)

| Verdict | **SURVIVE — this is the slice. Bind the exact poll loop, size offset, flush, metadata, and Ctrl+C reaper. CUT drain-once, drain-only-after-EXIT, and a second transcript body.** |
|---|---|
| Dimension lift | **D09** 7.4 → ~8.0 (live bytes reach the rail; 10.0 still wants a real-PTY empty-artifact citation). **D14** 4.0 → ~6.0 (interrupt toast re-exercised; done card still detached). **D18** 8.7 → ~9.0 if `@Builder` speech + `workers.tsv` re-proven. **D24** 7.0 → ~8.0 if process-group interrupt re-proven. **Not ≥ 9.0** on D09/D14. |

Exact failure (`iter-4/pytest.txt:20–65`; `app.py:944–967`):

- `ARTIFACT=` is read from provider stdout (keep this handshake).
- `size = _drain_artifact(art, 0)` runs **once**. Slow fixture writes `partial analysis begins\n` then `sleep 30` — first drain often sees an empty or not-yet-created file.
- `_flush_provider_buffer` + `_add_turn("provider", body)` then **`rc = proc.wait()`**. No further drain until the process exits.
- `test_pty_provider_interrupt` waits 25s for `partial analysis begins` **before** sending Ctrl+C (`test_pty.py:137–139`) → timeout.
- `test_pty_typed_role_records_builder` waits 25s for `builder analysis complete` (`test_pty.py:172`) → timeout. Fast fixture still loses the race to drain-once-then-wait.

`_drain_artifact` already seeks `size` and `_call`s `_append_provider_chunk` (`app.py:969–979`). `_append_provider_chunk` already opens one owned role turn on first non-empty bytes, then rail-continuations (`app.py:674–683`). `_add_turn` is export metadata only — it does **not** write the transcript (`app.py:702–704`). Keep that split. Do not also `_write_turn` / `_append_provider_line` the full body at exit.

**Exact live-drain loop (Worker may not invent a second one):**

After the existing `ARTIFACT=` readline and optional `Path(art).parent.parent` retarget (`app.py:943–953`), replace drain-once + blocking `proc.wait()` with:

1. `size = 0`.
2. **While `proc.poll() is None`:** if `art` is set, `size = self._drain_artifact(art, size)` (keep the byte offset; never re-seek 0). If `size` grew this iteration, `self._call(self._flush_provider_buffer)` so a last unterminated line still appears live. Then `time.sleep(0.05)` — not `0` (busy-spin), not `> 0.2` (misses the 25s PTY wait under load). Bound: **0.05s**.
3. **When `proc.poll() is not None` (process exited, including interrupt reap):** one final `_drain_artifact(art, size)` if `art` is set; always `_call(self._flush_provider_buffer)`; then metadata-only `_add_turn("provider", body)` from the artifact file if `body.strip()` (same as today — **no** transcript write). Then `rc = proc.wait()` (returns immediately), `self._provider_proc = None`, `self._provider_active = False`, `_call(self._provider_done, rc, art)`.

Loop lives in `_provider_thread` (background), not the UI thread. Speech still enters the transcript only through `_drain_artifact` → `_append_provider_chunk` → `_append_provider_line`. Empty artifact stays silent (no `Thinking…`, no fake role glyph) until first non-empty bytes — already proven natively (`test_layout.py` empty-artifact row); do not regress it.

**Exact stop / interrupt behavior (do not rewrite the reaper):**

| Event | Required behavior |
|---|---|
| First Ctrl+C while provider alive | Existing `action_interrupt_provider` (`app.py:1008–1020`): set `_provider_interrupted`, notify `interrupting provider`, `os.killpg(proc.pid, SIGINT)`, start `_ensure_stopped`. **Do not change this sequence.** |
| `_ensure_stopped` | Unchanged: wait up to 2s, then SIGTERM, wait 1s, then SIGKILL (`app.py:1024–1041`). |
| Drain loop during interrupt | **Must not `break` on `_provider_interrupted`.** Exit the `while proc.poll() is None` loop only when the process is actually dead, then do the **final drain + flush + metadata `_add_turn` + `_provider_done`**. Partial bytes already streamed stay; remaining on-disk bytes land once. |
| `_provider_done` on `rc == 130` | Unchanged: warning notify + `partial output left on disk` (`app.py:989–993`). No second full-body role turn. |
| Second Ctrl+C | Unchanged: `self.exit(130)` when already interrupted, or when no live provider (`app.py:1019–1022`). |
| First Ctrl+C during CLI (`_cli_busy`, no provider) | Still `exit(130)`. Do **not** treat `/status` as a `workers.tsv` turn. Do **not** drive busy footer from `_cli_busy`. |
| Drain thread itself | Must not call `exit(130)`, must not swallow the kill, must not replace `poll()` with a timeout-only sleep that assumes exit. |

**Prohibited:** drain-only-after-EXIT; a second full-body transcript write (`_write_turn` / unowned `_append_provider_chunk` plus full body); a second drain thread; `proc.wait()` as the live-speech condition; provider mocks / stubbing `_start_provider_turn` on PTY tests; editing `provider_turn.sh`; buffering until process exit.

This greens `test_pty_provider_interrupt` (`partial analysis begins` live, then first Ctrl+C → interrupt toast + `failed` + partial on disk, second → 130) and `test_pty_typed_role_records_builder` (`builder analysis complete` live, Builder `workers.tsv` `done`).

### 2. SIGWINCH PTY normalization without weakening compact/restore (D07)

| Verdict | **SURVIVE as a test-match repair only. Bind ANSI-strip-then-same-needles. CUT “otherwise normalize,” needle replacement, and timeout-only passes.** |
|---|---|
| Dimension lift | **D07** 7.3 → ~8.0 if ioctl 80→40→80 greens with compact forbids + restored heads. **Not 10.0** (live cap on a real TTY still thin). Native 80→40→80 already passed (`test_layout.py` activity/resize row) — do not re-implement compact in product. |

Exact failure (`iter-4/pytest.txt:88–91`; `test_pty.py:220,233–235`): `_wait_for(..., "▣─▣─▣ ProductTeam")` searches raw PTY bytes. Header is multiple styled `Text` segments (`▣─` bold, middle `▣` bold+ok, `─▣ ProductTeam` bold), so CSI sequences sit **between** glyphs. Compact `ProductTeam` wait can still pass; the three-head sequence never appears as one contiguous raw string.

**Exact safe mechanic (one, not “or otherwise”):**

In `test_pty.py`, add a helper that strips ANSI CSI / OSC / C1 control sequences from captured bytes and returns the remaining UTF-8 glyph payload. Use that stripped haystack **before every presence and every absence check** in `test_pty_sigwinch_compact` (initial wait, compact delta, restored delta). Shared use from `_wait_for` / `wait_delta` is allowed **only if** other tests keep their current needle strings (ASCII needles still match after strip).

**Needles that must remain exact (do not replace, do not shorten):**

| Phase | After ANSI-strip, must hold |
|---|---|
| Wide 80×24 (initial) | `▣─▣─▣ ProductTeam` **present** |
| Compact 40×20 delta | `ProductTeam` **present**; `▣─▣─▣` **absent**; cwd basename **absent**; `@Principal` **present** |
| Restored 80×24 delta | `▣─▣─▣ ProductTeam` **present** |
| ioctl | `TIOCSWINSZ` 20×40 then 24×80 unchanged (`test_pty.py:223,232`) |
| Timeouts | 25s waits unchanged |
| Exit | `/exit` → rc 0 |

**Why strip must precede absence checks:** matching compact “no `▣─▣─▣`” on **raw** bytes false-passes when heads **are** painted but CSI-split. Strip first, then forbid the three-head sequence at 40, then require it again at 80. That is the freeze §7 row (`frozen-benchmark.md:253`): compact header `ProductTeam {score}`, composer retained, restored heads.

**Prohibited weakenings:** replace wide/restore needle with `ProductTeam` (that is the compact needle and proves nothing about heads); drop compact forbids of `▣─▣─▣` or cwd; drop `@Principal`; drop restore of `▣─▣─▣ ProductTeam`; bump timeouts as the fix; piggy-back `/status` or a mocked provider onto this test; spawn work; change TIOCSWINSZ sizes; edit `test_four_sizes` / snapshots as a substitute for the ioctl row.

Do not touch product `_render_header` in this item unless a named layout test goes red — native compact already passed. This item is the match path.

### 3. `/status` tail — diagnosis constraint, then one product repair (D11 / D21)

| Verdict | **SURVIVE as a product streaming repair. Bind the observed split and the allowed mechanic. CUT test-side waits, needle edits, and “serialize or reduce poll” as a free choice.** |
|---|---|
| Dimension lift | **D11** 7.0 → ~7.5 (engagement row restored; mute Command rail still absent). **D21** 8.0 → ~8.2. **Not ≥ 9.0.** |

Exact failure (`iter-4/pytest.txt:5–13`; `test_pty.py:93–118`):

- `_wait_for(..., "Product Consulting Harness", 25)` **passed** (session helper returned).
- `_wait_for(..., "use the CLI: productteam gate", 25)` **passed** (same — post-hoc gate usage assert is not the traceback).
- Post-hoc full capture **lacks** `harness-cli`.
- Iter-3: this test was green. Iter-4 added 5 Hz `_poll_activity` chrome paints (`app.py:296,460–470`) on the UI thread that also runs `_append_cli_line` (`app.py:647–650,884–885`).
- The test still sends `/gate\r` as soon as the **title** appears (`test_pty.py:97–100`) — same as iter-3. The regression is that the **later engagement row** never reaches the PTY byte stream.

**Diagnosis constraint (Worker may not skip this and edit the test):**

The defect is product completeness: title streamed, `harness-cli` did not. PTY capture is append-only; if the product had written `harness-cli` to the terminal, it would be in `out`. This is not a missing wait, not an ANSI-split ASCII needle, and not a `/gate` refuse failure. Worker reproduces that split against the existing test, then repairs **`app.py`**.

**Allowed repair (one mechanical path, not a pile):**

While `_cli_busy` is True, `_poll_activity` must **not** call `_render_header`, `_render_footer`, or `_render_activity`. The 0.2s timer may still exist; it may still read the TUI-owned `workers.tsv`. It must not 5 Hz-repaint chrome on the UI thread during `run_argv_stream` line delivery. Idle/provider-live polling when `_cli_busy` is False stays as today.

If and only if that skip is in place and `harness-cli` still never appears, Worker may additionally ensure queued `_call(self._append_cli_line, line)` work is not dropped when a later slash arrives. The status thread must run to `finally: self._cli_busy = False` (`app.py:907–908`). Do **not** cancel `run_argv_stream` on `/gate`.

Keep streaming via `adapter.run_argv_stream` + `_append_cli_line`. Do not replace the stream with a single `_echo(full_stdout)` dump.

**Prohibited:**

- Wait for `harness-cli` in `_run_status_gate_session` before sending `/gate` (test-side serialize).
- Drop, replace, or ANSI-invent the `harness-cli` assertion.
- Drop `owner-gated`, `no directive` (must remain absent), `AttributeError` (must remain absent), or `use the CLI: productteam gate`.
- Bump the 25s timeouts as the fix.
- Stub `_start_provider_turn` / mock `run_argv_stream` / change `test_all_verbs.py` `NEEDLES["status"]`.
- Drive busy footer from `_cli_busy`.
- Block `submit_composer` on `_cli_busy` as the primary fix (that retargets first Ctrl+C during CLI).

Needle freeze for this test (`test_pty.py:110–118` — do not edit):

`Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` not in txt, no `AttributeError`.

### 4. Ask / confirm / evidence / splash / Command rails / pulse snapshot / card attach / `provider_turn.sh`

| Verdict | **CUT — including Reviewer “only after the suite is green.”** |
|---|---|
| Dimension lift | none this iteration |

Iter-5 is the last implementation iteration. Docks/splash/rails are not a residual queue. Pulse-as-snapshot (D05), attached completion cards (D10/D14), mute Command rails, `ask.json`, confirm intercept, evidence panel, TUI splash, `role-envelope.sh`, and `provider_turn.sh` / `adapter.py` edits are **out**. Layout/activity/footer/compact product chrome already landed in iter-4 and is green in `test_layout.py` — do not reopen it.

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. One Worker. Skip formatters, linters, and project-wide suites. Do not run `tests/cli-interface-parity.sh` or `tests/visual-cli.sh`.

### Repair (mechanical)

| Change | File | Why |
|---|---|---|
| Live-drain loop in `_provider_thread`: `while proc.poll() is None` drain with kept `size`, flush if `size` grew, `sleep(0.05)`; final drain + flush + metadata `_add_turn` + `_provider_done` after exit | `lib/tui/app.py` | D09 / interrupt / `@Builder` speech |
| Leave `action_interrupt_provider` + `_ensure_stopped` sequences unchanged; drain loop does not break on `_provider_interrupted` | `lib/tui/app.py` | D14 / D24 process-group Ctrl+C |
| `_poll_activity` skips header/footer/activity **paints** while `_cli_busy`; CLI lines still `_append_cli_line` via `run_argv_stream` | `lib/tui/app.py` | D11 `harness-cli` tail |
| ANSI-strip helper; `test_pty_sigwinch_compact` matches compact/wide/restore on stripped bytes with the **same** glyph needles | `lib/tui/tests/test_pty.py` | D07 ioctl row |

**Acceptance the Principal will run (Worker does not):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
```

**Expected: green (0 failed).** Do not freeze the count at 35 or 36 or 39 — this slice must not add feature tests; it may only keep the existing collected set green.

Then Principal also runs (Worker does not):

```
tests/cli-interface-parity.sh
tests/visual-cli.sh
```

Parity **PASS** (33/18/15/6). Visual-cli **14/14**; overall exit 1 allowed **only** for the pre-existing missing live-provider proof. Do not mock the provider.

Preserved in that same native run (not optional, not isolated-only):

- `test_pty_status_and_gate_refuse` — `Product Consulting Harness`; **`harness-cli`**; `/gate` usage + `owner-gated`; no `no directive`; no `AttributeError`
- `test_pty_provider_interrupt` — live `partial analysis begins`; first Ctrl+C keeps partial + `failed` + interrupt toast; second → 130
- `test_pty_typed_role_records_builder` — live `builder analysis complete`; Builder `workers.tsv` `done`; mission contains `verify the seam`
- `test_pty_sigwinch_compact` — ioctl 80→40→80; stripped compact `ProductTeam` without `▣─▣─▣` / cwd; `@Principal` retained; stripped restore `▣─▣─▣ ProductTeam`
- `test_role_chips_focusable_and_selectable`
- `test_typed_role_prefix_strips`
- `test_four_sizes` / `test_header_cwd_projection` / `test_you_turn_chrome`
- `test_activity_file_backed_caps_footer_and_resize`
- `test_empty_artifact_stays_activity_and_speech_is_owned`

**Worker check (one targeted file only):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q
```

That file is the four currently red PTY rows. Passing it is necessary and not sufficient; Principal owns full `lib/tui/tests` plus the two canonical scripts above.

**Exact surviving dimension lift (honest, not a 9.0 promise):**

| ID | Expected after this slice | Why not higher |
|---|---|---|
| **D09** | 7.4 → ~8.0 | Live owned speech restored; empty-artifact PTY citation still missing |
| **D11** | 7.0 → ~7.5 | `harness-cli` restored; Command rail still absent |
| **D21** | 8.0 → ~8.2 | Live `/status` complete; rail still absent |
| **D07** | 7.3 → ~8.0 | PTY ioctl row greens; 10.0 wants live cap on a real TTY |
| **D18** | 8.7 → ~9.0 | Live `@Builder` re-proven; no new targeting |
| **D24** | 7.0 → ~8.0 | Interrupt re-proven; ROLE argv already held |
| **D14** | 4.0 → ~6.0 | Interrupt toast re-exercised; done card still detached |
| **D04** | 8.4 → ~8.5 | Live speech streams; markdown-lite snapshot still thin |
| **D28** | 5.0 → ~6.5 | Native pytest green is one §7 row; ask/confirm/evidence/splash still fail |
| **D06 / D15 / D05** | hold ~7.5 / ~8.0 / ~8.5 | Do not reopen activity/footer/compact product |
| **D08 / D12 / D13 / D16 / D25** | stay 0.0 | Cut |

**Explicitly out of iter-5:** `ask.json` / OMP dock, confirm intercept, bordered evidence panel, TUI splash, mute Command rails, sourcing `role-envelope.sh`, editing `provider_turn.sh`, editing `adapter.py`, Button, `ProgressBar`, `@Role` in the buffer, `RoleChip.can_focus = False`, focusable `#activity`, glob-latest as the live strip, a second full-body provider turn, provider mocks on the live path, weakened/replaced PTY needles (including replacing `▣─▣─▣ ProductTeam` with `ProductTeam`, dropping `harness-cli`, dropping `/gate` asserts), timeout-only “fixes”, test-side wait-for-tail before `/gate`, drain-only-after-EXIT, busy footer from `_cli_busy`, pulse snapshot work, completion-card attach, two writers, formatters, any “after green” feature ride-along.

**Files the Worker may touch:**

- `lib/tui/app.py` (required — drain loop + `_cli_busy` poll-paint skip)
- `lib/tui/tests/test_pty.py` (ANSI-strip helper + `test_pty_sigwinch_compact` match path only; **do not edit** assertions of `test_pty_status_and_gate_refuse`, `test_pty_provider_interrupt`, `test_pty_typed_role_records_builder`)

**Files the Worker may not touch:** `lib/tui/tests/test_layout.py`, `__snapshots__/*`, `theme.py`, `session.py`, `provider_turn.sh`, `adapter.py`, `test_all_verbs.py` needles, Bash modules, freeze files, unrelated dirty worktree.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Keep `proc.wait()` and only add a sleep after the first drain** → `partial analysis begins` still never arrives live; interrupt/builder stay red.
2. **Drain-only-after-EXIT / break drain on `_provider_interrupted` without a final drain** → interrupt needle false-passes or loses partial speech; D09/D14 stay red.
3. **Second full-body `_write_turn` at done** → doubled speech; empty-artifact native test may still pass; D09 fails the freeze “one stream” row.
4. **Replace SIGWINCH wide/restore needle with `ProductTeam`** → compact and wide become the same proof; freeze §7 restored-heads row is a lie.
5. **Strip ANSI only for presence, not for compact absence of `▣─▣─▣`** → heads can remain at 40 while the test greens.
6. **Wait for `harness-cli` in the test before `/gate`, or drop the needle** → forbidden freeze-needle cut (`frozen-benchmark.md:240,376`); D11 papered.
7. **Serialize composer on `_cli_busy` as the status fix** → first Ctrl+C during `/status` no longer exits 130; D29/interrupt contract drifts.
8. **Ask/confirm/evidence/splash riding “after green”** → 30-minute timeout replay on the last iteration; suite still the acceptance bar; `GOAL-LOOP.md` forbids iter-6.
9. **Worker runs full `lib/tui/tests` or project formatters** → one-writer / Principal-owns-long-tests rule (`GOAL-LOOP.md`).

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT the bound drain / interrupt / ANSI-strip / status-tail contract above only.** A Worker pointed at (1) `poll()`-loop drain with `size` offset, 0.05s sleep, grow-flush, final drain, unchanged killpg reaper, no second transcript body, (2) ANSI-strip then the **same** compact/restore needles, (3) `_cli_busy` poll-paint skip so `harness-cli` reaches the existing test, files = `app.py` + `test_pty.py` match path only, Worker check = `test_pty.py`, Principal acceptance = **full native suite green (0 failed)** plus parity/visual-cli, with all feature docks/splash/rails cut, is a bounded verifiable pass. Anything that waits until EXIT to speak, weakens `▣─▣─▣ ProductTeam` or `harness-cli`, edits layout/snapshots, or opens ask/confirm/evidence/splash re-enters the recorded timeout and leaves iter-5 unconverged (`not-converged.md`, shipped 2026-08-13 cockpit intact).
