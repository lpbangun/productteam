# Critic debate — iteration 9 (pre-implementation, owner-extended)

**Role:** Critic (adversarial, read-only)
**Against:** Principal / Reviewer iter-9 proposal — `iter-8/reviewer-gate.md` “Iter-9 bind (proof cluster on already-implemented seams)” and `iter-8/notes.md:23–25` (“close Reviewer-named proof gaps … preferably with real PTY rows”). Expected: one live provider turn proving activity strip + empty-artifact silence + `prompt_export` prepend; SIGWINCH during that turn proving compact `ProductTeam {score}` and 1+N cap; native fixtures for empty-home, recency, header pulse, four-role speaking rails. Optional same-file 10-band extras: live `/report`, live splash. Implied lift: D03/D04/D05/D06/D07/D09/D24/D28 → ≥9. Hold every already-cleared ≥9.0 dimension.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`) Q1–Q5, Thinking-versus-speech, Target/`prompt_export`, §5 Activity/Provider-turn/Header-score seams, §7 Activity-vs-speech / Role-argv / PTY-sizes rows, D03/D04/D05/D06/D07/D09/D24/D28 rubric; `extension.md` (iter-6…iter-10); `iter-8/reviewer-gate.md` + `iter-8/scores.json` (D03=8.5, D04=8.8, D05=8.5, D06=7.5, D07=8.5, D09=8.2, D24=8.6, D28=8.7; zeros none; native 67/0; PTY 5/0); current `lib/tui/{app.py,provider_turn.sh,theme.py}`, `lib/tui/tests/{test_layout.py,test_pty.py}`, `bin/productteam` `cmd_status_json`, `lib/provider.sh` `provider_ask`, `state/agents/builder.json`. Inspect.md is pre-iter-1, not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE → ACCEPT the bound contract below only.**

The direction is exactly right and is the remaining 9-band cluster: no zero-score **function** remains. Every sub-9 is a proof gap on code that already runs, except home recency (today `_seed_home` sorts mapped-first at `app.py:1063`). Freeze §7 empty-artifact is a **PTY** row; D06/D07 9.0 name live TTY activity/caps/score-slot; D24 9.0 names captured `prompt_export`; D03 9.0 names honest empty + recency; D04/D05 9.0 name four-role rails and middle-head pulse as **observed spans**. The Reviewer paragraph is not yet a Worker contract. It leaves eight load-bearing specifics unbounded — how a PTY test sees activity/absence on a screen that also paints chips, which `workers.tsv` to inject into, what “recency” means against a status JSON that has **no mtime field**, how `prompt_export` is observed without opening speech or changing `ROOT PROMPT ROLE`, which widget spans prove pulse and the four-role neutral body, and whether optional 10-band extras may steal the eight 9-blockers.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Empty-artifact PTY | “while the artifact is still empty: transcript has neither `Thinking…` nor a fake agent message” | PTY evidence is the **full TTY byte stream**. Chips always paint `◆ Principal` / `◇ Analyst` / `▸ Builder` / `◉ Critic` (`app.py:367–369`). A whole-screen `◇ Analyst not in txt` false-fails. Native proof uses `transcript_text()` (`test_layout.py:428–430`), which the PTY harness does not have. Unbound observation. |
| Activity on TTY | “activity region shows a real workers.tsv row (braille / mission / `m:ss`)” | `#activity` is a `Static` (`app.py:366`). PTY sees ANSI + UTF-8 glyphs after `_strip_ansi` (`test_pty.py:55–113`). Raw CSI greps miss braille. Unbound needles and delta marks. |
| TSV injection | “fixture extra rows into the same session `workers.tsv` if the single provider row cannot show `+N`” | App starts `_activity_session_dir = state_root/runs/session-{os.getpid()}` (`app.py:333–335`) and exports `ACTIVITY_SESSION_DIR` into `provider_turn.sh` (`app.py:1545`). After `ARTIFACT=` it retargets to `Path(art).parent.parent` (`app.py:1570`). Glob-latest (`session.workers_rows`, `session.py:131–141`) is a **different reader**. Overwriting the TSV drops the live provider row. Unbound path + atomicity. |
| Recency | “several scored rows with distinct recency → home shows at most three in recency order; mapped-cwd preference may still pin one slot” | `cmd_status_json` emits `{selected, engagements:[{client, scored, last_iter, overall, areas_ge_9, trend, desc}]}` (`bin/productteam:317–329`). **No `mtime`, `scored_at`, or `updated`.** `_seed_home` sorts mapped-first (`app.py:1063`). A Worker who adds a fake JSON field, sorts `last_iter` lexicographically (`iter-10` < `iter-9`), or keeps mapped-first with a comment “recency” scores D03 8.5. Unbound key. |
| `prompt_export` | “artifact/trace/argv-adjacent capture; only if capture needs a needle, prefer not changing the signature” | Prepend already happens (`provider_turn.sh:50–52`). `provider_ask` invokes non-`agent` as `"$bin" -p "$prompt" --output-format text` (`lib/provider.sh:142`). Existing PTY fixtures `printf` and **ignore argv** (`test_pty.py:186–191`). “Only if needed” is a signature-change hole. Printing the card onto the artifact **opens speech** and zeros the empty-artifact window. Unbound observation. |
| Compact `{score}` | “assert the slot, not only the word `ProductTeam`” | Idle SIGWINCH row asserts `ProductTeam` without heads/cwd (`test_pty.py:354–358`) and never the score token. Header glyphs are CSI-split; `_strip_ansi` is required (`test_pty.py:305–307`). Unbound compact regex and live-vs-idle. |
| Pulse / four-role | “native spans; `_append_provider_chunk` matrix is enough” | Pulse already restyles the middle `▣` (`app.py:1041`). Builder rail is asserted (`test_layout.py:854–855`); Critic/Principal/Analyst speaking rails are not. A source comment or helper-only unit test is D05/D04 0. Unbound widget observation. |
| 10-band extras | “optional same-file live `/report` and live splash; skip splash rather than risk `CONSULT_NO_SPLASH=1` defaults” | `_open_session` **always** sets `CONSULT_NO_SPLASH=1` (`test_pty.py:127`). A dedicated unset-env row in the same file is how the other five skip splash or flake. Live `/report` is a long real CLI stream (D12 already 9.1). Both risk the eight 9-blockers. **Cut.** |

Hand the Worker the bound slice below. Do not spawn until the Principal copies **this** boundary — not `iter-8/reviewer-gate.md` alone, not `iter-8/notes.md`.

---

## Item-by-item rebuttal

### 1. Deterministic real-PTY timeline + workers.tsv injection (D06 / D09 / D07 / D28)

| Verdict | **SURVIVE — this is the freeze §7 empty-artifact PTY row and the D06/D07 TTY citations. Bind one new test, one hold-then-speak fixture, `_strip_ansi` deltas, same-session TSV inject. CUT glob-latest TSV, clobbering the live row, stubbing `_start_provider_turn`, wall-clock-only sleeps as the pass, and any edit to the existing five PTY rows.** |
|---|---|
| Dimension lift | **D06** 7.5 → ~9.0 (braille / mission / provider / `m:ss` / caps on the TTY). **D09** 8.2 → ~9.0 (empty-artifact **PTY** window). **D07** 8.5 → ~9.0 (compact `{score}` + live 1+N while work is live). **D28** 8.7 → ~9.0 (that §7 row lands). Residual to 10.0: live-PTY splash / live `/report` (cut). |

**One new test only**, appended after the existing five, name stable:

```text
test_pty_activity_empty_artifact_compact_and_prompt_export
```

Do **not** rename, split into a second live-provider PTY, or restub `_start_provider_turn`. Reuse `_open_session` / `_strip_ansi` / `_wait_for` / `_drain` / `_send` / `_close_session`. Keep `CONSULT_NO_SPLASH=1` (default of `_open_session`). Pass `CONSULT_STATE_ROOT` to a `tmp_path` tree and `CONSULT_PROVIDER` to the fixture below.

**Hold-then-speak fixture** (tmp_path, `chmod 0o755`). It must **not** print to stdout until after the absence window. Non-`agent` `provider_ask` calls `"$bin" -p "$prompt" --output-format text"` (`lib/provider.sh:142`) — parse `-p` then the next argument as the combined prompt. Distinctive basename (`hold-provider.sh`):

```bash
#!/usr/bin/env bash
prompt=""
while (($#)); do
  if [[ "$1" == "-p" && $# -ge 2 ]]; then prompt="$2"; shift 2; continue; fi
  shift
done
mkdir -p "${CONSULT_STATE_ROOT:-/tmp}"
printf '%s\n' "$prompt" > "${CONSULT_STATE_ROOT}/prompt-capture.txt"
sleep 8
printf 'owned speech begins\n'
sleep 25
printf 'owned speech continues\n'
```

`sleep 8` is the **hold**, not the proof. The test waits on files/needles (below). `sleep 25` keeps the process alive through inject + SIGWINCH + restore. Do not `printf` the card or the user prompt onto stdout (that is the artifact / speaking turn). Capture **must** land in `prompt-capture.txt` **before** the first stdout byte. That is the D24 observation (item 3) — argv-adjacent, not a `provider_turn.sh` edit.

**Numbered timeline (Worker may not reorder):**

| Step | Wait / act | Pass |
|---|---|---|
| T0 | `_open_session(hold-provider, {CONSULT_STATE_ROOT})`; wait `ProductTeam` | idle header |
| T1 | mark = `len(_strip_ansi(joined))`; send `@Builder verify the seam\r` | You turn may appear; role argv is Builder |
| T2 | poll until `CONSULT_STATE_ROOT/runs/session-*/workers.tsv` has a **Builder** row with `state` in `{pending,running,progress}` **and** that row's artifact path is missing, empty, or size 0. Timeout 15s | live exact-session TSV, still silent |
| T3 | **absence + activity window** on `_strip_ansi(joined)[mark:]` (see §2) | D09 + D06 |
| T4 | atomic inject of **two extra live rows** into **that same** `workers.tsv` (see below) | 3 live rows |
| T5 | `_drain` 0.5s (one 0.2s poll); ioctl 24×80 → 20×40; reuse `wait_compact` from `test_pty_sigwinch_compact` | compact header + 1+N |
| T6 | ioctl 20×40 → 24×80; wait_delta `▣─▣─▣ ProductTeam` | heads restored **while still live** |
| T7 | wait_for `owned speech begins` (25s); stripped delta now contains **one** Builder speaking opener | D09 speech-on-bytes |
| T8 | `/exit\r`; rc 0 | do **not** Ctrl+C (that is `test_pty_provider_interrupt`) |

**Same-session TSV inject (T4), exact:**

- Target file = the TSV discovered at T2 (the app-owned session: `ACTIVITY_SESSION_DIR` / post-`ARTIFACT=` parent.parent). **Not** `session.workers_rows` glob-latest. **Not** a second `session-*` directory.
- Read existing bytes. Keep the header and the live Builder row. Append two rows with unused `id` values, `state` in `{pending,running,progress}`, roles `Analyst` and `Critic`, missions `evidence` and `checking`, providers `gpt` and `local`, `start` = now-4, `elapsed` = `4`, `artifact` empty. Columns exactly `id role state mission provider start elapsed artifact` (`lib/activity.sh:9`, `app.py:481–490`).
- Write via temp + `os.replace` (same atomicity as `activity.sh` `_act_append`). Never truncate-then-write the live row away.
- After T5, compact activity must show **one** live line plus `+2` (width ≤40 cap is 1, `app.py:499–505, 534–535`). Native `test_activity_file_backed_caps_footer_and_resize` already names `+2`; the PTY row must show `+2` on the stripped compact delta.

**Reject:** stubbing `_start_provider_turn`; mocking `provider_ask`; a Python supervisor; determinate `ProgressBar`; injecting into a TSV the app is not polling; waiting only `time.sleep(8)` with no T2 file predicate.

### 2. Normalized screen observations and absence windows (D06 / D09 / D07)

| Verdict | **SURVIVE. Bind `_strip_ansi` deltas and chip-safe absence needles. CUT raw-CSI greps, whole-log greps, and “no role glyph on screen”.** |
|---|---|
| Dimension lift | Freeze §7: isolate per-invocation deltas; grepping an accumulated log is not a pass. |

Every new PTY assertion runs on `_strip_ansi(b"".join(out))` (UTF-8 glyphs kept, CSI/OSC/C1 dropped — already in `test_pty.py:55–113`). Presence uses `wait_delta(fd, out, mark, needle)` as in the confirm/SIGWINCH rows. Never search the raw byte stream for `ProductTeam {score}` or `▣─▣─▣`.

**T3 absence window** (stripped delta from T1, **before** T7 speech). Unique to fake agent speech — chips may still show glyphs **without** a rail:

- `Thinking…` **absent**
- agent speaking openers **absent**: `│ ◆`, `│ ◇`, `│ ▸`, `│ ◉` (RAIL + role glyph; `theme.py:196`, `app.py:1181–1188`)
- `│ You` **may** be present (the user turn). That is not a D09 fail
- chips `◆ Principal` without a leading `│` do **not** count as a fake agent turn

**T3 activity presence** (same stripped delta, or a 0.5s drain after T2 if the first 5Hz paint landed just after the mark):

- at least one braille spinner codepoint from `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` (`app.py:517`)
- mission needle `verify the seam` (stripped user prompt; `activity_start` mission, `provider_turn.sh:36`)
- provider basename of the fixture (`hold-provider.sh`)
- elapsed `m:ss` matching `\d+:\d{2}` (`app.py:462–467`)
- busy footer substring `ctrl+c interrupt` **or** compact `ctrl+c ·` once resized

**T5 compact header** (stripped compact frame from `wait_compact`, work still live):

- matches `ProductTeam (—|\d+\.\d)` — the **score slot**, not only the word `ProductTeam`
- `▣─▣─▣` absent; cwd basename absent; `@Principal` present (composer retained)
- activity `+2` present

**T6 restore:** `▣─▣─▣ ProductTeam` present on the stripped delta after ioctl back to 80, still before T8.

**T7 speech:** after `owned speech begins`, the stripped delta contains `│ ▸` (Builder rail) **once** as the speaking opener. `Thinking…` still absent. Do not require the full `▸ Builder` string to be unique against chips — the **rail** is the turn needle.

**Reject:** grepping `b"".join(out)` without `_strip_ansi`; asserting `Builder not in txt` (chips + card); using the idle SIGWINCH row as D07 live-cap evidence.

### 3. `prompt_export` capture from hold-provider argv (D24)

| Verdict | **SURVIVE. Bind argv capture into `prompt-capture.txt` **before** fixture stdout. Assert the exact `state/agents/builder.json` `prompt_export` string **and** the user prompt. CUT any `provider_turn.sh` signature change, any stdout/artifact print of the card, and any source-comment “proof”.** |
|---|---|
| Dimension lift | **D24** 8.6 → ~9.0 (prepend observed on a real Builder turn). Residual to 10.0: live-PTY Critic/`agent_card_prompt_block` fallback (out). |

Prepend already happens (`provider_turn.sh:50–52`):

```bash
prompt=$(printf '%s\n\n%s' "$exported" "$PROMPT")
```

`provider_ask` then calls `"$bin" -p "$prompt" --output-format text` (`lib/provider.sh:142`). The hold-provider fixture in item 1 **is** the capture: it writes `$prompt` to `${CONSULT_STATE_ROOT}/prompt-capture.txt` **before** `sleep 8` and **before** `printf 'owned speech begins'`. That file is argv-adjacent evidence. It is not the artifact and it is not speech.

**Do not edit `provider_turn.sh`.** Signature stays `ROOT PROMPT ROLE` (`provider_turn.sh:22–24`; Popen argv `app.py:1548`). `activity_start "$ROLE"` stays. Process-group INT trap stays. Do not add a debug `printf` of the card onto stdout, stderr, or the artifact — that opens speech during T3 and zeros D09. Do not change `provider_ask` / `lib/provider.sh`. Do not invent a second capture path in Python.

**When to read the file:** after T2 (the fixture has started and parsed `-p`) and **before** T7. Poll `CONSULT_STATE_ROOT/prompt-capture.txt` exists and size > 0 (timeout 15s, same as T2). Do not wait on `owned speech begins` to prove prepend — capture precedes output by contract.

**Exact asserted contents** (read as UTF-8 text, trailing newline from the fixture `printf '%s\n'` is required):

1. The **entire** `prompt_export` string from live `state/agents/builder.json`, byte-identical, currently:

```text
You are Forge, the Builder. Smallest correct diff. Delete before adding. Every change has verification.
```

   Tests **must** load that string from the file at runtime (`json.loads(... )["prompt_export"]`), not hardcode a stale paraphrase. If the card is missing or `prompt_export` is empty, fail the test — do not silently accept `agent_card_prompt_block` on this Builder row (Builder's card is non-empty).

2. A blank line (`\n\n` between export and user prompt), matching `provider_turn.sh:52`.

3. The user prompt exactly `verify the seam` (the remainder after `@Builder `).

Whole-file equality:

```text
{prompt_export}\n\nverify the seam\n
```

`Thinking…`, `│ ▸`, and `owned speech begins` **must not** appear in `prompt-capture.txt`. The artifact (T2 path) stays empty through T3.

**Reject:** changing `ROOT PROMPT ROLE`; printing the card onto the artifact; asserting only that `provider_turn.sh` contains the word `prompt_export`; capturing after first stdout; a Python supervisor that wraps `provider_ask`.

### 4. Home recency from real scores.json mtimes + empty fixture (D03)

| Verdict | **SURVIVE. Bind recency to filesystem `st_mtime` of each engagement's latest **valid** `scores.json`. Numeric-iter fallback, stable client tie-break, optional mapped pin only if the rest stay mtime-sorted. Native empty fixture. CUT a fake JSON mtime field, lexicographic `last_iter`, mapped-first-as-recency, and mutating live `state/engagements/`.** |
|---|---|
| Dimension lift | **D03** 8.5 → ~9.0 (honest empty copy + recency order, both fixture-proven). Residual to 10.0: live-tree recency snapshot (out). |

`cmd_status_json` has **no** mtime field (`bin/productteam:317–329`). Do **not** edit `bin/productteam`. Recency is a TUI sort of already-filtered JSON rows, keyed off the same files `_read_overall` already opens (`app.py:1007–1029`).

**Latest valid `scores.json` (same scan as `_read_overall`):**

For client `c`, walk `ROOT/state/engagements/{c}/runs/iter-*` directories. A candidate is valid when: the path is a directory; `iter-N` parses `N` as `int` (reject `iter-10b`, `iter-`); `scores.json` is a file; JSON parses; `overall` is `int` or `float`. The **latest** valid file is the one with the **largest numeric** `N` (not lexicographic: `iter-10` beats `iter-9`). Recency key = that file's `Path.stat().st_mtime` (float). Do not take max-mtime across older iters if a newer numeric iter is valid — “latest valid” is the `_read_overall` file, then that file's mtime.

**Sort key, in order (all descending except client):**

1. `st_mtime` of that latest valid file (newer first).
2. **Numeric iter fallback** when mtimes are equal **or** the file is missing/unreadable (`OSError` / invalid JSON / no numeric overall): use the numeric `N` from the latest valid iter, else parse `e["last_iter"]` as `iter-N` → `int(N)`, else `-1`. Never sort the string `"iter-10"` / `"iter-9"`.
3. **Stable client tie-break:** `client` name ascending (`str`). Same mtime + same numeric iter → alphabetical, deterministic. Do not use JSON array order.

**Optional mapped slot:** `_seed` still finds `mapped` via `Repo:` == cwd (`app.py:982–988`). After the mtime sort:

- If `mapped` is absent from the filtered scored/non-banned set, take `[:3]` in mtime order. No pin.
- If `mapped` is already inside the top 3 by mtime, take `[:3]` in mtime order. Pin is a no-op.
- If `mapped` is scored+eligible but **outside** the top 3, pin it into **one** slot (slot 0) and fill the other two from the mtime-sorted remainder (the two newest non-mapped). The non-mapped displayed rows **must** remain mtime-desc among themselves.

Do **not** `sort(key=mapped-first)` over the whole list (today `app.py:1063`) — that leaves the rest in JSON order and scores D03 8.5. Filter (scored, not banned, numeric overall) stays exactly as now (`app.py:1052–1062`). Cap remains 3. Product change is `_seed_home` sort (+ a small helper that `_read_overall` may share for “latest valid path”). Do not retouch splash/ask/confirm/evidence.

**Native empty fixture** — name stable:

```text
test_home_empty_copy_when_no_scored
```

Monkeypatch `adapter.run_argv` so `["status", "--json"]` returns rc 0 and `{"selected": null, "engagements": []}` **or** only `scored: false` / banned-name rows (`smoke`, `run-loop`, `gate-smoke`, `overnight-rehears`). Do **not** empty the live tree. After `_boot_home`:

- `transcript_text()` contains the exact copy `No scored sessions yet — bench <client> to score` (`app.py:1067`)
- `HOME_ROW_RE` matches **zero** rows
- `"Product Consulting Harness"`, `"Product Judgment Layer"`, `"not scored"` absent
- `#role-prefix` still `@Principal`; idle footer exact `enter send · / commands · tab agents`
- chips row still mounted

Keep `CONSULT_NO_SPLASH=1` (`test_layout.py:36`). Do not `delenv` (that is splash).

**Native recency fixture** — name stable:

```text
test_home_recency_mtime_order
```

Do **not** `utime` live `state/engagements/`. Isolate with `tmp_path`:

- `monkeypatch.setattr` the module `ROOT` used by `_seed_home` / `_read_overall` / `_repo_path` (`app.py:60`, `app.py:994–1029`) to `tmp_path`.
- Monkeypatch `adapter.run_argv` for `["status", "--json"]` only; every other argv still hits the real CLI (palette/help).
- Write `tmp_path/state/engagements/{client}/runs/iter-N/scores.json` with valid `{"overall": …}` and `os.utime` distinct mtimes. Write `engagement.md` `Repo:` only for the mapped client, pointing at `Path.cwd().resolve()`.

**Required trap rows (membership and order must be asserted on `HOME_ROW_RE` names):**

| client | latest valid iter | mtime rank | notes |
|---|---|---|---|
| `new-client` | `iter-1` | newest | low numeric, newest mtime — **mtime beats numeric** |
| `mid-client` | `iter-9` | 2nd | |
| `lex-client` | `iter-10` | 3rd | `iter-10` vs `iter-9`: lex would mis-order; mtime is 3rd so it still appears |
| `old-client` | `iter-2` | oldest of four | 4th — **dropped by the cap of 3** |
| `here-client` | `iter-3` | older than `old-client` | mapped via `Repo:` == cwd; **outside top 3** so the pin puts it in slot 0; slots 1–2 are `new-client` then `mid-client` (mtime rest) |

Also include (may share the same tree, extra rows that must **not** appear): `smoke-client` newest-of-all mtime but name contains `smoke`; `idle-client` with `scored: false`. Both excluded by existing filters.

**Order asserted after pin:** `here-client`, `new-client`, `mid-client`. Not `lex-client`. Not `old-client`. Not banned/unscored. At most three `HOME_ROW_RE` rows. No status prose dump.

**Equal-mtime subcase** (same test or a tight sibling `test_home_recency_numeric_and_client_tiebreak`): two eligible clients, identical `st_mtime`, `iter-10` vs `iter-9` → `iter-10` first (numeric fallback). Two more with identical mtime **and** identical numeric iter → alphabetical client names. Do not rely on dict/JSON order.

**Reject:** adding `mtime` to status JSON; `sort(last_iter)` as a string; commenting `mapped-first` as recency; helper-only unit test that `_seed_home` never runs; writing into the live engagement tree; weakening `test_home_seed_filtered`.

### 5. Header pulse and four-role rail as widget spans (D05 / D04)

| Verdict | **SURVIVE. Bind `#header` span walks for the middle `▣`, and a four-role `_append_provider_chunk` matrix with rail/label hue + unstyled body. CUT source comments, helper-only tests, a second header widget, and live-provider mocks for these rows.** |
|---|---|
| Dimension lift | **D05** 8.5 → ~9.0 (pulse observed). **D04** 8.8 → ~9.0 (Principal/Analyst/Builder/Critic speaking rails). Residual to 10.0: pulse snapshot / live-PTY Critic speech (out). |

Pulse already exists (`app.py:1040–1041`): wide header paints the **middle** `▣` as `"bold " + OK` when `_provider_active or self._live_activity_rows()`, else `"bold"`. Compact header (`width <= 40`) has **no** heads — do not claim pulse there. Do **not** invent a second header. Do not retouch splash.

**Native pulse row** — name stable:

```text
test_header_pulse_middle_head_ok_when_busy
```

Observe spans on the **widget**, same pattern as `_splash_spans` (`test_layout.py:1070–1081`) / `_all_spans` (`test_layout.py:796–803`):

```python
def _header_spans(app):
    text = app.header.render()
    out = []
    for span in text.spans:
        color = ""
        if span.style is not None and span.style.foreground is not None:
            color = (span.style.foreground.hex6 or "").lower()
        out.append((text.plain[span.start:span.end], color, str(span.style) if span.style else ""))
    return out
```

`run_test(80, 24)`, `CONSULT_NO_SPLASH=1`, `_boot_home`:

1. **Idle:** `_provider_active` is false and no live activity rows. The middle `▣` span (the single `▣` between `▣─` and `─▣`, `app.py:1041`) is **not** `OK` / `#22c55e`. Style is `bold` only. `▣─▣─▣ ProductTeam` still present as plain text.
2. **Busy via activity:** `_write_activity_rows` one `running` row (`test_layout.py:336–342`); `pilot.pause` for the 5Hz poll. Middle `▣` span color is `OK` (`#22c55e`). Side heads stay un-pulsed (`bold` without OK on the `▣─` / `─▣` runs).
3. **Busy via `_provider_active`:** clear activity to `done` (strip hidden) then set `app._provider_active = True` and `_render_header()`. Middle `▣` is OK again. Idle restore: `_provider_active = False` and no live rows → middle `▣` not OK.

Do not use a screenshot as the only pulse proof. Do not grep `app.py` source for `OK`. Compact 40-col header is `ProductTeam {score}` without heads (`app.py:1033–1037`) — pulse N/A; existing activity compact test already covers that chrome.

**Native four-role matrix** — name stable:

```text
test_four_role_speaking_rails_neutral_body
```

One `run_test(80, 24)`. Do **not** stub `_start_provider_turn` unless the test would otherwise spawn (it must not submit composer). Do **not** mock the live provider. Drive `_append_provider_chunk` only, resetting `_provider_speech_opened` / `_md_buffer` / `_md_fence` between roles so each role opens its own rail (`app.py:1174–1205`).

For each role in `("Principal", "Analyst", "Builder", "Critic")`:

| role | glyph | hue constant | distinctive body |
|---|---|---|---|
| Principal | `◆` | `PRINCIPAL` `#c084fc` | `principal body` |
| Analyst | `◇` | `ANALYST` `#60a5fa` | `analyst body` |
| Builder | `▸` | `BUILDER` `#22c55e` | `builder body` |
| Critic | `◉` | `CRITIC` `#f59e0b` | `critic body` |

Per role, `app._active_turn_role = role`, then `_append_provider_chunk(f"{body}\n")`. Capture `transcript.write` like `test_provider_speech_markdown_and_attached_done_card` (`test_layout.py:830–837`).

**Pass (each role):**

- `_turn_has_hue(app, f"{glyph} {role}", hue)` (`test_layout.py:498–507`)
- delta contains `│ {glyph} {role}` once
- rail `│` on the opener is the role hue (`ROLE_STYLES[role][1]`, `theme.py:41–47`, `app.py:1182`)
- **Neutral body:** the distinctive body string is written with **no** style span covering it (same rule as `"plain body must carry no style span"`, `test_layout.py:870–876`). Body is not `PRINCIPAL` / `ANALYST` / `BUILDER` / `CRITIC` / `YOU` / `OK` / `ERR`.
- `Thinking…` absent. You chrome is **not** re-proven here (`test_you_turn_chrome` stays).

Builder may already pass via the markdown fixture; this row still **must** include Builder in the loop so the matrix is one citation. Do not skip Critic. Do not use `theme.turn()` as the only observation — the app path is `_append_provider_line`.

**Reject:** helper-only `turn()` unit test never mounted; source comment that pulse uses OK; restyling `#splash`; new hex; `ROLE_STYLES` edits.

### 6. Allowed files, Worker check, Principal acceptance, dimension lift

**Files the Worker may touch:**

| File | Why |
|---|---|
| `lib/tui/app.py` | `_seed_home` recency sort (replace mapped-first at `app.py:1063`); optional shared “latest valid scores path” helper with `_read_overall`. Pulse already exists at `_render_header` — **do not invent a second header**. Do not retouch splash/ask/confirm/evidence machines. |
| `lib/tui/tests/test_layout.py` | `test_home_empty_copy_when_no_scored`; `test_home_recency_mtime_order` (+ optional numeric/client tie-break sibling); `test_header_pulse_middle_head_ok_when_busy`; `test_four_role_speaking_rails_neutral_body`. Keep `setdefault CONSULT_NO_SPLASH=1`. Do not weaken splash rows or `test_home_seed_filtered`. |
| `lib/tui/tests/test_pty.py` | **Add** `test_pty_activity_empty_artifact_compact_and_prompt_export` after the existing five. **Do not weaken or replace** those five. Hold-provider fixture is tmp_path, not a committed product file. |

**Files the Worker may not touch:** `provider_turn.sh` (no signature change, no output/debug print), `adapter.py`, `session.py`, `__main__.py`, `theme.py` (token table / `ROLE_STYLES` / splash art), `bin/productteam` (no fake JSON mtime field), `test_all_verbs.py` NEEDLES, `test_slash.py`, `test_nontty.py`, `conftest.py`, Bash modules (`lib/splash.sh`, `lib/repl.sh`, `lib/activity.sh`, `lib/provider.sh`, `lib/agent-cards.sh`), freeze files, live `state/engagements/` mtimes, unrelated dirty worktree. Snapshots: Principal-only refresh after green pytest; idle snapshot stays the post-skip cockpit.

**Worker check (targeted files only; necessary, not sufficient):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_layout.py -q
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q
```

**Acceptance the Principal will run (Worker does not). Export `CONSULT_NO_SPLASH=1` for the full suite (freeze §7); do not add a live-splash PTY row:**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q          # 0 failed (do NOT freeze the count — new tests are added)
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 5 + the new row
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

**Non-regression needles (must remain exact — do not weaken, replace, or re-route):**

- All five PTY rows (`test_pty.py:171–369`): `/status`+`/gate`, provider interrupt (`interrupting provider` + `partial output left on disk` + `\tfailed\t` + second Ctrl+C → 130), typed `@Builder`, confirm Esc, ioctl 80→40→80.
- All fifteen splash rows in `test_layout.py` (`test_splash_*`).
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`; `test_confirm_run_exact_argv_for_all_three_intercepts`.
- Ask: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer ≥20.
- Evidence: `test_report_stream_evidence_panel`, `test_bench_stream_evidence_panel`, `test_report_missing_args_prints_usage` (no fake panel).
- Command/toast/card: `test_command_rail_mute_no_role_hues`, `test_export_writes_markdown`, `test_provider_sets_session_env`, `test_provider_speech_markdown_and_attached_done_card`.
- `test_nontty_refusal`, `test_nontty_no_color_no_escapes`.
- `test_all_verbs.py` `NEEDLES["splash"] == ("▣",)` in the **Command / `_turns` cli delta**; `NEEDLES["report"]` `iter-1`; `NEEDLES["bench"]` `Benchmark`.
- `test_four_sizes`, `test_home_seed_filtered`, `test_you_turn_chrome`, `test_role_chips_focusable_and_selectable`, `test_empty_artifact_stays_activity_and_speech_is_owned`, `test_activity_file_backed_caps_footer_and_resize`.

**Honest dimension lift after this slice (not a blanket 10.0):**

| ID | After this slice | Why not higher / still out |
|---|---|---|
| **D06** | 7.5 → ~9.0 | Live PTY activity strip (braille / mission / `hold-provider.sh` / `m:ss` / `+2`). Residual to 10: determinate-bar absence already held. |
| **D09** | 8.2 → ~9.0 | Freeze §7 empty-artifact **PTY** window (chip-safe rails absent, then `│ ▸` on first bytes). |
| **D07** | 8.5 → ~9.0 | Compact `ProductTeam (—|\d+\.\d)` + live 1+N cap on the TTY while work is live. |
| **D24** | 8.6 → ~9.0 | Exact Builder `prompt_export` + `verify the seam` in `prompt-capture.txt` before stdout; live strip shares D06. Residual: Critic/`agent_card_prompt_block` fallback unproven. |
| **D03** | 8.5 → ~9.0 | Empty-home fixture + mtime recency (+ numeric fallback, client tie-break, mapped pin with mtime rest). |
| **D05** | 8.5 → ~9.0 | Middle-head pulse observed on `#header` spans. Residual to 10: pulse snapshot optional. |
| **D04** | 8.8 → ~9.0 | Four-role speaking-rail + neutral-body matrix. Residual to 10: live-PTY Critic speech optional. |
| **D28** | 8.7 → ~9.0 | Empty-artifact PTY row lands; splash preamble already native. Live-PTY splash **not** required for this 9. |
| **D16 / D26 / D12 / D01 / D08 / D11 / D13 / D14 / D15 / D18 / D21 / D23 / D25 / D27 / D29** | hold ≥9 | Do not regress splash, ask, Command, evidence, confirm, toasts, chips, argv-only, PTY needles. |

**Explicitly out of iter-9 (feature-creep cut):** live-PTY `/report`, live-PTY splash / unsetting `CONSULT_NO_SPLASH` on `_open_session`, glob-latest `session.workers_rows` TSV, clobbering the live Builder row, stubbing `_start_provider_turn` on the PTY row, `provider_turn.sh` signature or stdout change, fake status-JSON `mtime` field, lexicographic `last_iter` sort, mapped-first labeled as recency, mutating live engagement mtimes, helper-only pulse/rail tests, a second header/`ModalScreen`, new hex / `ROLE_STYLES` edits, glob-latest ask, substring confirm, Enter-to-open files, two writers, formatters, demanding live-PTY splash as a D16/D26 9 reopen.

If the 9-band cluster lands, stop and write `final-report.md`. If anything in the sub-9 table remains, continue to iter-10 under `extension.md` with only the leftover blockers — do not invent new scope.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Whole-screen `◇ Analyst not in txt`** → chips always paint the glyph; PTY row false-fails; D09 stays 8.2 or the suite reds.
2. **Raw CSI grep for braille / `▣─▣─▣`** → UTF-8 spinner and split header glyphs missed; D06/D07 uncited.
3. **Glob-latest or truncate-write TSV** → live Builder row dropped or a different session polled; `+2` never appears on the TTY the app is painting.
4. **`time.sleep(8)` as the pass** → flake under load; freeze §7 wants a file/needle predicate.
5. **Mapped-first or string `last_iter`** → D03 stays 8.5; `iter-10` vs `iter-9` and newest-mtime/`iter-1` traps fail.
6. **Fake JSON `mtime` / `bin/productteam` edit** → out of files; D23/D27 risk; freeze does not ask the CLI for recency.
7. **Printing `prompt_export` onto the artifact** → T3 speech opens; D09 zeros; D24 still unproven as prepend.
8. **`provider_turn.sh` signature change** → existing five PTY rows and `ROOT PROMPT ROLE` (D18/D24 hold) regress.
9. **Helper-only pulse / `theme.turn()` unit test** → D05/D04 stay source-only (0 under freeze §8).
10. **Live `/report` or live splash in the same PTY file** → `CONSULT_NO_SPLASH=1` default broken, or the eight 9-blockers miss the 30-minute window.
11. **Stubbing `_start_provider_turn` on the PTY row** → D06/D09/D24 remain native-only.
12. **Weakening interrupt / Builder / confirm / idle-SIGWINCH / splash needles** → D13/D14/D16/D18/D28 hold breaks.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT this bound proof-cluster contract.** A Worker pointed at (1) one new PTY test `test_pty_activity_empty_artifact_compact_and_prompt_export` with hold-provider, T0–T8, same-session atomic TSV `+2`, `_strip_ansi` chip-safe absence and activity needles, compact `ProductTeam (—|\d+\.\d)` while live; (2) `prompt-capture.txt` written from `-p` **before** stdout, exact live `state/agents/builder.json` `prompt_export` + blank line + `verify the seam`, **no** `provider_turn.sh` edit; (3) `_seed_home` recency = `st_mtime` of latest valid `scores.json` (numeric iter fallback, client-name tie-break, mapped pin only with mtime-sorted rest), plus `test_home_empty_copy_when_no_scored` and `test_home_recency_mtime_order` on a tmp `ROOT`; (4) `#header` middle-`▣` OK vs idle spans; (5) four-role `_append_provider_chunk` rail/label hue + unstyled body; files = `app.py` + `test_layout.py` + `test_pty.py`; Worker check = those two pytest files; Principal acceptance = full native suite green under `CONSULT_NO_SPLASH=1` + 5+1 PTY + parity/visual gates, with live `/report` / live splash / signature changes / fake JSON mtime cut, is a bounded verifiable pass that can put **D03/D04/D05/D06/D07/D09/D24/D28 at ≥9 from behavior**, not comments.

### Iter-10 (named for leftover blockers only, not in this slice)

- only whatever the Reviewer still scores sub-9 after this contract lands
- optional 10-band: live-PTY splash, live-PTY `/report`, live-PTY Critic speech — **not** 9-blockers
- then `final-report.md` or `not-converged.md` under `extension.md`
