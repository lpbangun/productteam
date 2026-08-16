# Reviewer gate — iter-4

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-4`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`). Missing, stale, or uncited evidence scores 0.0. Average does not compensate.

**Verdict: FAIL — native suite went red. Not converged.**

| | |
|---|---|
| `all_ge_9` | `false` |
| Lowest | **0.0** (`D08`, `D12`, `D13`, `D16`, `D25`) |
| ≥ 9.0 | D02, D17, D20, D22, D23, D27, D29 (7/29) |
| Native pytest | **4 failed, 35 passed** (`iter-4/pytest.txt`) — regression from iter-3's 36/0 |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

The slice landed its UI (activity strip, owned speech, footer states, compact/resize) natively, but the same touch broke live provider streaming and left the real-PTY proof red. This is a FAIL, not a freeze win.

## Three explicit audits

### 1. Exact-session activity seam — HONEST

The live strip does **not** glob-latest sessions. Verified:

- `app.py:267-269` initializes `_activity_session_dir = session.state_root(ROOT) / "runs" / f"session-{os.getpid()}"` — the TUI process owns it.
- `app.py:360-361` `_read_activity_rows` opens **that exact** `workers.tsv`; no `glob`, no mtime sort.
- `app.py:928` passes `ACTIVITY_SESSION_DIR` into the provider `Popen` env; `lib/activity.sh:16-19` `_act_session_dir` honors it before any per-PID default, so the bash child writes into the TUI session dir.
- `app.py:954` retargets `_activity_session_dir = Path(art).parent.parent` after `ARTIFACT=`; `art` is `$dir/artifacts/$id.txt`, so this resolves to the **same** session dir — a cross-check, not a second picker.
- `session.workers_rows` still globs latest (`session.py:131-160`), but it is only the `/workers` chat-only dump (`app.py:669`), never the live strip.

Verdict: the seam is honest. No stale cross-session paint.

### 2. Activity-vs-speech credit despite the provider stream timeout — PARTIAL, NOT ZERO

D09 scores **7.4**, not 0.0. The timeout is a *live-streaming* defect, not a *thinking-rendered-as-speech* defect.

- `test_empty_artifact_stays_activity_and_speech_is_owned` (`test_layout.py:381-411`, passed in the 35) proves the D09 core at file-backed level: with a `running` row and an **empty** artifact, the transcript delta has no `Thinking…` and no `◇ Analyst`; the first emitted bytes open exactly one owned role turn; later chunks do not duplicate; `_add_turn` records provider metadata only.
- Source matches: `app.py:679-690` `_append_provider_chunk` opens one role turn on first non-empty bytes, then rail-continuations; `app.py:962-967` adds provider metadata at exit without a second full-body transcript write.

What is **not** credited: the freeze §7 live "running worker + empty artifact → no fake message while speech streams" row. That requires real provider bytes to reach the transcript live, which the drain regression (below) prevents.

### 3. Compact — NATIVE proof yes, PTY proof NO

- Native: `test_activity_file_backed_caps_footer_and_resize` (`test_layout.py:340-358`, passed) proves 80→40→80 — compact header `ProductTeam —`, one activity line + `+N`, composer retained, wide heads/directory restored — plus the 3/2/1+N caps.
- PTY: `test_pty_sigwinch_compact` (`test_pty.py:220`) fails at its **first** needle `▣─▣─▣ ProductTeam`. The header is composed of differently-styled `Text` segments (`▣─` bold, `▣` bold+ok, `─▣ ProductTeam` bold), and Textual interleaves ANSI style sequences between them, so the contiguous byte string never appears in the raw PTY stream. The test needle is over-contiguous, not the product (the other PTY tests use the single-segment `ProductTeam` needle and pass).

Net: D07 = **7.3** (native proof complete; freeze §7 ioctl/SIGWINCH row still red).

## Findings (ordered by impact)

1. **Live provider streaming regressed — drain-once before blocking `proc.wait()`.** `app.py:955-967`: after `ARTIFACT=`, `_drain_artifact` runs **once** while the artifact is still empty, then `proc.wait()` blocks. A slow provider's later bytes (`partial analysis begins`) are never read until process exit. Trigger: `test_pty_provider_interrupt` (`test_pty.py:137`) and `test_pty_typed_role_records_builder` (`test_pty.py:172`) both time out at 25s. This reds two of the three non-regression proofs the slice was required to preserve, and also un-proves the interrupt toast (D14) and the live `@Builder → workers.tsv` row (D18). Remediation: re-drain the artifact repeatedly while the provider is alive (keep `size` offset; flush the rail buffer on each read); do **not** defer all presentation until `EXIT=`, and do **not** add a second full-body `_write_turn` at exit (that duplicates speech).

2. **PTY SIGWINCH test needle is not ANSI-normalized.** `test_pty.py:220` expects the multi-segment styled header as one contiguous byte string. Remediation: strip ANSI control sequences from the captured delta (or otherwise normalize) before matching compact/wide headers. This preserves what the test proves (compact header, no heads/cwd at 40, `@Principal`/composer retained, heads restored at 80) without weakening the needle.

3. **`/status` engagement needle regressed — `harness-cli` no longer reaches the stream.** `test_pty_status_and_gate_refuse` (`test_pty.py:114-115`): `Product Consulting Harness` passes but `harness-cli` (a later engagement row in the same status prose) is absent from the full captured stream. Root cause not settled from static inspection; `[INFERENCE]` the added 0.2s poll tick now re-renders header/footer/activity every 200ms, plausibly slowing `run_argv_stream` line rendering so the status tail is cut by the subsequent `/gate`/`/exit`. Remediation: reproduce live and restore full status streaming — serialize/slow-path the CLI stream so it completes before later input, or reduce poll overhead; do **not** weaken the needle.

4. **Middle-head pulse is source-only.** `app.py:336` paints the middle `▣` with `ok` when `_provider_active` or live activity, but no test/snapshot captures it. D05 is capped below 9.0 partly for this; attaching a snapshot proof would lift it.

5. **Completion card still detached; `/export` still an extra transcript line.** D10/D14/D19 stay capped; the debate kept card-attachment (D14) out of scope.

## Missing proof / untested behavior

- Freeze §7 live "running worker + empty artifact" (activity-vs-speech on a real PTY) — not capturable while the drain is broken.
- Live `@Builder` → `workers.tsv` Builder row — not re-proven (speech timeout precedes the poll).
- Process-group interrupt (partial artifact + `failed` + exit 130) — not re-exercised this iter.
- Live SIGWINCH `80→40→80` — not captured (needle normalization).
- Full `/gate` refusal chain (`owner-gated`, `no directive`, `AttributeError`) — not re-asserted this iter (outer test failed at `harness-cli` before those lines).
- Ask / confirm / evidence / splash — still absent (D08/D12/D13/D16/D25 = 0.0).
- Honest empty-home copy — still not fixture-proven (D03).

## Smallest coherent iter-5 contract (final iteration)

Iter-5 is a **repair iteration only**: restore green native tests before any remaining docks/splash work. One Worker, one writer, `lib/tui/app.py` + `lib/tui/tests/test_pty.py` (needle normalization only).

1. **Fix live artifact streaming** in `_provider_thread`: re-drain `art` in a loop while `proc.poll() is None` (short sleep, keep byte `size` offset, flush rail buffer per read), then a final drain after exit. This alone should green `test_pty_provider_interrupt` and `test_pty_typed_role_records_builder`. Prohibited: drain-only-after-EXIT, a second full-body transcript write, provider mocks.
2. **ANSI-normalize the SIGWINCH capture** in `test_pty_sigwinch_compact` (strip control sequences before matching compact/wide headers). Green the ioctl row without weakening what it asserts.
3. **Restore full `/status` streaming** so `harness-cli` reaches the transcript again (diagnose the poll/stream interference; do not weaken the needle). Green `test_pty_status_and_gate_refuse` fully, including `owner-gated` / `no directive`.

Acceptance the Principal must run (not the Worker full-suite):

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q   # must be 0 failed
tests/cli-interface-parity.sh                          # PASS (33/18/15/6)
tests/visual-cli.sh                                    # 14/14, allowed live-provider exit 1
```

Non-regression inside that green run: `test_pty_status_and_gate_refuse`, `test_pty_provider_interrupt`, `test_pty_typed_role_records_builder`, `test_pty_sigwinch_compact`, `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`, `test_four_sizes`, `test_activity_file_backed_caps_footer_and_resize`, `test_empty_artifact_stays_activity_and_speech_is_owned`.

**Explicitly out of iter-5** (only after the suite is green may any be considered, and the five-iteration stop means they are effectively declined for this run): `ask.json`/OMP dock, confirm intercept, bordered evidence panel, TUI splash, mute Command rails, `provider_turn.sh` edits, `adapter.py` edits, `role-envelope.sh`, Button, `ProgressBar`, focusable `#activity`, glob-latest strip, second full-body turn, weakened needles, provider mocks, two writers, formatters.

## Sub-9 dimensions

| ID | score | Exact failure |
|---|---:|---|
| D01 | 8.0 | Activity conditional; ask/confirm/evidence docks absent. |
| D03 | 8.5 | Empty-home copy not fixture-proven; mapped-first sort. |
| D04 | 8.4 | Speaking rail native-proven; live speech never streams. |
| D05 | 8.5 | Compact proven; pulse source-only. |
| D06 | 7.5 | Native strip/caps; no live PTY empty-artifact citation. |
| D07 | 7.3 | Native 80→40→80 proven; PTY ioctl needle times out. |
| D08 | 0.0 | No structured ask. |
| D09 | 7.4 | Native owned speech; live drain regression. |
| D10 | 6.0 | No speaking markdown-lite snapshot; detached card. |
| D11 | 7.0 | Live /gate usage holds; harness-cli needle regressed. |
| D12 | 0.0 | No evidence panel. |
| D13 | 0.0 | No confirm intercept. |
| D14 | 4.0 | Interrupt toast unproven; detached done card; /export line. |
| D15 | 8.0 | Idle/busy/slash proven; ask/evidence footers absent. |
| D16 | 0.0 | No TUI splash. |
| D18 | 8.7 | Native targeting + ROLE argv; live @Builder not re-proven. |
| D19 | 8.0 | Copy still a transcript line. |
| D21 | 8.0 | Native 18-verb; live /status partial. |
| D24 | 7.0 | Exact-session poll + caps; interrupt not re-proven. |
| D25 | 0.0 | Ask/confirm/evidence seams absent. |
| D26 | 5.0 | Non-TTY proven; splash absent. |
| D28 | 5.0 | Native pytest red (4 failed, 35 passed). |

## Verdict

**FAIL.** The exact-session activity seam is honest and compact/footer/owned-speech are natively proven, but live provider streaming regressed and the native suite is red — iter-4 must not be called done. Hand the Worker the three-repair iter-5 contract above; acceptance is **full native pytest green first**, and the remaining docks/splash work is out. If iter-5 does not return the suite green, the accepted outcome is `not-converged.md` with the shipped 2026-08-13 cockpit intact.
