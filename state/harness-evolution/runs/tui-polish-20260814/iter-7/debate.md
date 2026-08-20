# Critic debate — iteration 7 (pre-implementation, owner-extended)

**Role:** Critic (adversarial, read-only)
**Against:** Principal / Reviewer iter-7 proposal — `iter-6/reviewer-gate.md` “Iter-7 bind (evidence panel + only coherent Command/toast/card semantics)” and `iter-6/notes.md:25` (“Iter-7 should implement evidence + Command/toast/card semantics”). Expected: bordered evidence panel, mute Command rails, session toasts, attached done/error card, speaking-turn markdown-lite snapshot. Implied lift: D01/D10/D11/D12/D14/D19/D21/D25 → ≥9; D16 stays 0.
**Authority:** `frozen-benchmark.md` (immutable; `FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`) R1–R5, §2.1 layout, §5 Evidence/Supported-slash/Chat-only seams, §7 Evidence row, D01/D10/D11/D12/D14/D19/D21/D25/D28 rubric; `extension.md` (owner-authorized iter-6…iter-10); `iter-6/reviewer-gate.md` + `iter-6/scores.json` (D12=0.0, D16=0.0, D10=6.0, D11=7.5, D14=5.8, D19=8.0, D21=8.2, D01=8.7, D25=6.7; native 47/0; PTY 5/0); current `lib/tui/app.py`, `lib/tui/theme.py`, `lib/tui/tests/{test_slash.py,test_layout.py,test_all_verbs.py,test_pty.py}`; live CLI shapes `bin/productteam` `cmd_report` / `cmd_bench` / `lib/render.sh`. Inspect.md is pre-iter-1, not current source.
**Stance:** An item survives only with a concrete mandatory-dimension lift and a bound mechanic the Worker cannot invent. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE → ACCEPT the bound contract below only.**

The direction is exactly right and is the highest-leverage remaining work: D12 is still a zero-score function; D11/D21/D10/D14/D19 fail because slash echo, `/report`/`/bench` lists, completion, and `/export` still share one unowned `transcript.write`. Freeze R2/R3/R5/R1 are one output vocabulary and must ship together. The Reviewer paragraph is not yet a Worker contract. It leaves eight load-bearing specifics unbounded — the classifier versus real `cmd_report`/`cmd_bench` stdout, which widget occupies the dock slot, evidence keyboard/focus/compact, Command-rail ownership, how tests observe a mute toast, how append-only `RichLog` attaches a card without rewriting speech, fail/interrupt toast-vs-card split, and markdown style proof — and “Static/RichLog (or OptionList)” / “reuse `_EVIDENCE_RE` or equivalent” is exactly where a Worker can ship a placeholder panel, a test-only parser, or a classifier that swallows `iter-1` / `Benchmark`.

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Classifier | “reuse `theme._EVIDENCE_RE` or an equivalent `path: rest` / path-only rule named in the test” | `_EVIDENCE_RE` (`theme.py:123`) is a **full-line** `path: rest` matcher for markdown-lite styling. Real `/report` is `render_markdown_lite` of `report.md` (`bin/productteam:1290–1296`) — headings keep `# … iter-1` under non-TTY (TUI Popen is not a TTY). Real `/bench` is a banner + HISTORY table + `LATEST` area rows + trailing `…/scores.json` (`bin/productteam:1169–1246`). Area rows carry the path **after** the score (`render_evidence`, `lib/render.sh:7–25`). A full-line `_EVIDENCE_RE` match on those rows is false; sending the whole row to the panel swallows the summary; sending nothing leaves the file list in chat. Unbound. |
| Panel widget | “labelled bordered `Static`/`RichLog` (or OptionList with no Enter-to-run)” | Compose is one `#dock` `OptionList` (`app.py:313`) in the dock-above-composer slot. A second widget, `ModalScreen`, or a `RichLog` dropped into `#transcript` is a new region or a drowned chat. Unbound. |
| Controls / order / focus / compact | “Esc / close → `_close_dock(); composer.focus()`. Composer ≥20” | Slash/ask/confirm already steal Enter/Esc/Space/↑↓ (`app.py:157–200, 1106–1115`). Evidence kind is unnamed. Visualizer footer `enter open` would spawn a file-open path the freeze does not name. 40-col `max-height: 10` can cover the composer. Unbound. |
| Command rail | “one helper, mute rail + mute `Command` label” | Slash echo is unstyled `Text` (`app.py:1153`). Stream is `_append_cli_line` → `md_line` with **no** rail (`app.py:939–942`). Refuse is two `_echo_muted` lines (`app.py:1201–1205`). Nothing stops a Worker from using a role hue, a toast, or a second helper per verb. Unbound. |
| Session toasts | “mute `notify` and no extra transcript line; update `test_export_writes_markdown`” | `/export` `_echo_muted(f"wrote {path}")` (`app.py:1171–1177`); `/provider` `_echo(msg)` (`app.py:1178–1181`). `test_export_writes_markdown` **requires** `"wrote "` in `transcript_text()` (`test_slash.py:215–216`); `test_provider_*` require `provider →` in the transcript (`test_slash.py:165, 178`). `notify` is not recorded. Unbound observation. |
| Attached card | “`status_tag` on the open speaking rail, not a detached row” | `#transcript` is `RichLog` (`app.py:308`) — append-only. `_provider_done` writes an unowned `status_tag` row (`app.py:1354–1362`) and, on interrupt, a second `_echo_muted("Ctrl+C — partial output left on disk …")` (`app.py:1349–1353`). Rewriting the spoken body duplicates speech (`test_layout.py:411–414` forbids duplicate owned bytes). Unbound. |
| Fail / interrupt | “keep toast + error card; partial path may live on the card, not as a second mute echo” | “May” is not a contract. First Ctrl+C already `notify("Ctrl+C — interrupting provider, partial output kept")` (`app.py:1373`); `_provider_done` rc==130 notifies **again** (`app.py:1350`). PTY needle is `"interrupting provider"` **and** `"partial output left on disk"` (`test_pty.py:201–209`). Dropping the phrase, or leaving it only in a toast that tests do not scrape, zeros D14 and reds the PTY row. Unbound. |
| Markdown proof | “one native speaking-turn fixture asserting `md_line` styles” | `md_line` exists (`theme.py:144–174`) and `_append_provider_line` calls it, but no test inspects heading/fence/+/-/path **styles on the owned rail**. A screenshot or a `md_line()` unit test that never hits the transcript is not D10. Unbound. |
| Parser ownership | unnamed | A classify function that lives only in `test_layout.py` / `test_slash.py` is a test-only parser. Freeze D25: evidence path parsing must be real and file-backed where required — here, product-side, against real CLI shapes. |

Hand the Worker the bound slice below. Do not spawn until the Principal copies this boundary — not the Reviewer paragraph, not `iter-6/notes.md`.

---

## Item-by-item rebuttal

### 1. Evidence path classifier against real report/bench shapes (D12 / D25)

| Verdict | **SURVIVE — this is the D12 zero. Bind classify-at-stream, split mixed lines, withhold paths from chat, open no fake panel. CUT full-line `_EVIDENCE_RE` dumps, glob-latest file discovery, transcript scraping, and any parser that exists only in tests.** |
|---|---|
| Dimension lift | **D12** 0.0 → ~9.0 (bordered labelled panel + Command summary + files withheld). **D25** 6.7 → ~9.0 (ask + confirm + evidence parse all real). Residual to 10.0: live PTY `/report`. |

**When to classify (not after the fact):**

`RichLog` cannot unwrite. Classify **inside** `_append_cli_line` while streaming. `_exec_cli` stores `self._cli_argv = argv` before `run_argv_stream` and clears it in `finally`. Classify **only** when `self._cli_argv[:1] == ["report"]` or `["bench"]`. Every other supported verb streams every line to the Command rail (D11/D21). `/run` prints a trailing `report.md` path (`bin/productteam:1286`) — **do not** classify it.

**Strip then split — product helper, not a test double:**

Add `theme.split_evidence_line(line: str) -> tuple[str | None, str | None]` returning `(command_fragment, evidence_fragment)`. Either side may be `None`. Implementation **must** be called from `_append_cli_line` (and nowhere else as a second parser). Tests may import the helper to document cases, but a green helper with no app call is not D12.

Preprocess: drop CSI/OSC (`\x1b[…` / `\x1b]…`), then `rstrip("\n")`, then inspect a copy with leading whitespace stripped for matching. Keep original indent out of the panel payload.

Match rules, in order, against the stripped copy:

1. **Empty / usage / error / die** → `(line, None)`. `usage:`, `error:`, `die`, `no report yet`, `no scored runs yet` never open a panel.
2. **Full-line evidence** → `(None, payload)` when the stripped line matches existing `_EVIDENCE_RE` (`^([^\s:]*[./_\-][^\s:]*):\s(.*)$`, `theme.py:123` / `lib/render.sh:74`) **or** is a path-only token: contains `/`, has no `://`, and (has a `.` extension **or** starts with `state/` `runs/` `lib/` `bin/` `tests/` `docs/`). Optional leading signed delta `+[0-9.]+` / `-[0-9.]+` stays on the payload (locked visualizer `+0.0  runs/iter-3/scores.json`).
3. **Mixed bench/report row** → search from the right for an `_EVIDENCE_RE` substring **or** a trailing path token as in (2). `(prefix, payload)`: prefix is the line with that payload removed, collapsed inner whitespace, still containing the area name / `overall` / score; payload is the path (plus the signed delta if it sat immediately before the path). This is how `cmd_bench` actually prints (`bin/productteam:1225–1245`: area + score + bar + `render_evidence` + overall line ending in `$d/runs/$last/scores.json`).
4. **Summary** → `(line, None)` for everything else, including:
   - report headings (`# … iter-1 …`) — **NEEDLES["report"] is `iter-1`** (`test_all_verbs.py:31`)
   - bench banner `Benchmark — {client}` — **NEEDLES["bench"] is `Benchmark`** (`test_all_verbs.py:32`)
   - `Contract `, `HISTORY`, history table header/rows, `trend:`, `LATEST —`
   - markdown prose, `**` verdicts, `- ` bullets that are not `path: rest`
   - fenced body (`md_line` fence state already tracked as `self._md_fence`; while in fence, never classify as evidence)

**Do not swallow summaries:** after a `/report` or `/bench` turn, the Command-summary **transcript delta** (and `_turns` cli text) **must** still contain `iter-1` for report and `Benchmark` for bench. Extracted paths **must not** reappear in `transcript_text()` for that turn. `_add_turn("cli", out)` keeps the **full** stdout for `/export` — do not strip `_turns`.

**Buffer and open:**

- Evidence fragments accumulate on `self._evidence_paths: list[str]` for the active CLI argv (reset at `_exec_cli` start).
- Command fragments go to the Command rail immediately (live).
- When the stream finishes (`_exec_cli` `finally`, UI thread): if the buffer is **empty**, do **not** open a dock, do **not** paint a labelled empty chrome. If non-empty, open `_dock_kind == "evidence"` on the existing `#dock` (see §2).
- A malformed / usage-only `/report` (no client) stays Command; `test_report_missing_args_prints_usage` still finds `usage: productteam report <client>` in `transcript_text()`.

**Reject:** globbing `runs/iter-*`; scraping the transcript after the fact; classifying `/status` `/help` `/score`; a second Python supervisor; placeholder rows (`file1.md`, `lorem`, `TODO`).

### 2. Panel widget, dock controls, y-order, focus, compact (D12 / D01 / D15)

| Verdict | **SURVIVE. Bind the existing `#dock` OptionList as the only evidence surface. CUT a second OptionList, Static/RichLog region, ModalScreen, Screen, Button, ProgressBar, and Enter-to-open.** |
|---|---|
| Dimension lift | **D01** 8.7 → ~9.0 (every dock — slash/ask/confirm/**evidence** — above composer; close restores focus). D15 holds ≥9 (evidence footer is extra; freeze 10.0 already names idle/busy/ask/slash). |

**One slot, one widget:**

`compose` stays `header / rule / transcript / activity / chips / #dock OptionList / composer-region / footer` (`app.py:305–317`). `_dock_kind` gains `"evidence"` (default remains `"slash"`). No new widget id. Opening evidence closes slash; `_refresh_dock` still early-returns when `_dock_kind != "slash"`. **While `_cli_busy`**, `_refresh_dock` also early-returns so a typed `/` during a `/report` stream cannot steal the slot before the panel opens.

CSS: keep `#dock { border: none !important; border-top: solid {RULE}; }`. Add `#dock.evidence { border: solid {RULE} !important; }` — `RULE` is existing `#2a2a2a`, not a new hex. `_close_dock` removes class `evidence` and resets kind to `"slash"`.

**Labelled rows (display-only):**

- Row 0 prompt (mute, not a path id): `evidence · {n} files` (`n` = buffered path count). Option id `_label`.
- Rows 1…: each evidence payload, path bold (`TEXT`/`bold`), optional signed delta `ok`/`err` (`+` → `OK`, `-` → `ERR`). Option id `ev-{i}`. These ids are **never** passed to `_exec_cli`.
- Compact cap: at `size.width <= 40`, show at most **3** path rows; otherwise **6**. Remainder is one mute last row `+{hidden}`. Composer stays `>= 20` columns (extend `test_composer_width_visible_in_dock_states` with an evidence state at 80 and 40).

**Controls (composer retained):**

| Key | Evidence behavior |
|---|---|
| ↑ / ↓ | `dock_move` highlights only (scroll). Does not run. |
| Space / Tab | no-op (`prevent_default` while dock visible, same as confirm Space). |
| Enter | `_close_dock(); composer.focus()`. Does **not** submit composer text, does **not** open a file, does **not** spawn. |
| Esc | `_close_dock(); composer.focus()`. |

`submit_composer` early-route joins ask/confirm: `_dock_kind == "evidence"` → close; return. `on_composer_escape` same. `dock_move` when `_dock_kind == "evidence"` highlights among OptionList rows (not `_dock_verbs`; today the non-ask/confirm branch uses `_dock_verbs` and would no-op). `_close_dock` already early-returns slash refresh for non-slash kinds, so a typed `/` during evidence cannot steal the slot. Y-order proof: `dock.region.y + dock.region.height <= composer.region.y` (reuse `test_layout.py:60, 514–518`). Close restores `composer.focus()` and removes class `evidence`. `_exec_cli` `finally` currently runs on the streamer thread (`app.py:1242–1243`) and only clears `_cli_busy`; opening the panel **must** `_call` onto the UI thread. Store `self._cli_argv = argv` on the UI thread before starting that thread (today `_exec_cli` does not).

**Footer** while evidence is open (dock > busy > idle already holds):

```text
↑↓ · esc close
```

Not the visualizer's `enter open`. Freeze D15 10.0 does not name an evidence footer; this string is honest and does not claim a file-open path.

### 3. Command rail ownership (D11 / D21)

| Verdict | **SURVIVE. Bind one mute Command helper as the only writer for slash echo, supported summary, and refuse+usage. CUT role hues, toasts-as-Command, and per-verb extra helpers.** |
|---|---|
| Dimension lift | **D11** 7.5 → ~9.0, **D21** 8.2 → ~9.0. PTY `/status` / `/gate` needles stay exact. |

**One helper in `theme.py` (no new hex):**

```text
command_open(first_body_line) → Text
  MUTE rail `│` + MUTE `Command` + dim ` · HH:MM` + newline + MUTE rail + md_line(body)

command_continue(line) → Text
  MUTE rail `│` + md_line(line)
```

Never `ROLE_STYLES`. Never `YOU`. Body uses existing `md_line` (headings/fences/diff still style; that is markdown-lite on a Command turn, freeze R2 “stream real stdout with markdown-lite as a mute Command turn”).

**Ownership — these three calls, and only these, write Command chrome:**

1. **Slash request echo** replaces `self.transcript.write(Text(f"/{verb}…"))` (`app.py:1153`). First line of the turn is `/{verb}` plus args. Sets `self._command_open = True`.
2. **Supported stream** — `_append_cli_line` for non-evidence fragments (all verbs, including report/bench summaries). If `_command_open` is False, `command_open`; else `command_continue`. Reset `_command_open` / `_md_fence` at the start of each `_run_slash` / `_exec_cli`.
3. **Unsupported refuse** replaces the two `_echo_muted` lines (`app.py:1201–1205`) with one Command turn whose body is `/{verb} — {chat_reason}` then `use the CLI: {usage}`. `test_gate_refused_without_spawn` still requires those two needles in `transcript_text()` and `spawns == []`.

`/splash` after skip remains a Command turn (out of this slice to *build* TUI splash; the CLI verb still streams as Command).

**Not Command:** session verbs (`/export` `/provider` `/clear` `/workers` `/exit` `/quit`), You turns, role speech, evidence panel rows, toasts, completion cards.

Native proof: after `/status` (fake or real), transcript delta contains `│ Command` and does **not** carry Principal/Analyst/Builder/Critic hex on those strips (reuse `_turn_has_hue` inverted). `/gate` refuse is MUTE, not a role.

### 4. Session-toast observable tests (D14 / D19)

| Verdict | **SURVIVE. Bind an append-only `self._toasts` log on `notify`, move `/export` and `/provider` off the transcript, and rewrite the two tests that currently require those strings in chat. CUT leaving toasts unobservable or deleting the export file assertion.** |
|---|---|
| Dimension lift | **D19** 8.0 → ~9.0 (copy is a session verb). **D14** 5.8 → ~9.0 together with §5–§6. |

Override `notify` on `ProductTeamApp`:

```text
self._toasts: list[tuple[str, str]]  # (message, severity), append-only
notify(...) → append (message, severity) then super().notify(...)
```

Severity: session verbs `"information"` (mute toast); interrupt `"warning"`; provider fail `"error"`. No new hex — Textual toast chrome stays; freeze fail toast color is already `err` on severity error.

| Verb | Transcript | Toast | Other |
|---|---|---|---|
| `/export` success | **no** `"wrote "` line; no `_echo_muted` | one information toast whose message contains `wrote ` and the path | file still exists; export markdown still has `# TUI session`, `/export`, and the prior CLI turn (`test_slash.py:218–223`) |
| `/export` OSError | no extra system line | information or error toast with `export failed:` | |
| `/provider` | **no** `provider →` line; no `_echo` | information toast equal to today's `msg` (`provider → agent` / `provider → claude` / failure text) | `CONSULT_PROVIDER` still set (`test_provider_sets_session_env`) |
| `/clear` `/workers` `/exit` | unchanged | no new toast required | |

**Exact test rewrites (Worker owns `test_slash.py`):**

- `test_export_writes_markdown`: wait until `any("wrote " in m for m, _ in app._toasts)`; assert `"wrote "` **not** in `transcript_text()`; keep the file glob + markdown needles.
- `test_provider_sets_session_env` / `test_provider_named`: wait on `_toasts` for `provider → agent` / `provider → claude`; assert those strings **not** required in `transcript_text()`; keep the env assertion.

Do not scrape Toast widget internals. Do not monkeypatch `notify` only in tests without the product `_toasts` log — Reviewer cannot cite a test double as D19.

### 5. Append-only RichLog card without rewriting/duplicating speech (D10 / D14)

| Verdict | **SURVIVE. Bind a rail-continuation append. CUT `transcript.clear`, `_write_turn` of the full body at done, and the current unowned `status_tag` row.** |
|---|---|
| Dimension lift | **D10** 6.0 → ~9.0 with §7. **D14** with §4 and §6. |

`#transcript` is `RichLog(wrap=True, highlight=False, markup=False)` (`app.py:308`). Lines are append-only. Owned speech already opens once then continues the role rail (`_append_provider_line`, `app.py:944–964`). `test_empty_artifact_stays_activity_and_speech_is_owned` requires `delta.count("answer one") == 1` (`test_layout.py:411–414`).

**Required attach helper** (theme.py may hold `completion_card(role, state, elapsed_s, artifact_name, *, detail: str | None)`; app must call it):

On `_provider_done` for `rc is not None and rc != 130` (done/failed) and for `rc == 130` (interrupt), **append one new RichLog line**:

```text
│{role hue}  {status_tag(state)}  {role_tag(role)} · {elapsed}s · {artifact name}
```

- `state` is `done` if `rc == 0`, else `failed` (interrupt uses `failed`).
- Same `_active_turn_role` hue rail as the speaking turn (`ROLE_STYLES`).
- `status_tag` already exists (`theme.py:93–95`).
- **Do not** replay any spoken body. **Do not** `transcript.clear()`. **Do not** `_write_turn(role, body)`. **Do not** write `status_tag` without the rail (today `app.py:1354–1362`).

If speech never opened (`_provider_speech_opened is False`): still append **only** that card line (completion without fake speech). During empty-artifact work the transcript stays silent (D09); the card appears at done, not while running.

**Forbidden duplicate:** `_add_turn("provider", body)` remains metadata-only (already true, `app.py:1322–1323`). Do not also `_append_provider_chunk` the full file at exit.

Native proof: after a fixture that opened speech with `answer one`, calling the done path yields `delta.count("answer one") == 1` and the card line contains `✓ done` (or `✗ failed`) plus the role glyph on a rail segment whose style is that role's hue.

### 6. Fail / interrupt behavior (D14 / D24 / D29)

| Verdict | **SURVIVE as a split of toast vs card vs PTY needles. CUT a second interrupt toast, dropping `partial output left on disk` from the RichLog, and any change to `action_interrupt_provider` / `_ensure_stopped` / exit 130.** |
|---|---|
| Dimension lift | **D14** completes ≥9 with §4–§5. D24/D29 hold. |

Do **not** rewrite the reaper. Exact existing sequence stays (`app.py:1368–1401`): first Ctrl+C sets `_provider_interrupted`, notifies, `killpg` SIGINT, starts `_ensure_stopped`; drain loop does not break on the flag; second Ctrl+C `exit(130)`.

| Event | Toast (`notify` + `_toasts`) | Transcript / card | Must remain in PTY bytes |
|---|---|---|---|
| First Ctrl+C while provider alive | **Keep exact** `Ctrl+C — interrupting provider, partial output kept`, severity `warning`. **One toast.** | none yet | `"interrupting provider"` (`test_pty.py:201–202`) |
| `_provider_done` `rc == 130` | **No second notify** (today `app.py:1350` is the double). | error **card** (§5) whose detail/plain text contains `partial output left on disk` and the artifact basename. **No** `_echo_muted` extra line (`app.py:1351–1352` goes away). | `"partial output left on disk"` (`test_pty.py:209`); `"partial analysis begins"` already streamed; `workers.tsv` `\tfailed\t` |
| `_provider_done` `rc != 0` (not 130) | `provider failed`, severity `error` (keep). | error card on the rail. **Remove** `_echo_muted("provider refused — /agents · raw artifact kept on disk")` (`app.py:1365`) — that is an extra transcript line. | n/a for current PTY |
| `_provider_done` `rc == 0` | **no** toast | done card only | `"builder analysis complete"` unchanged |
| Second Ctrl+C | n/a | `exit(130)` | status == 130 |

Partial artifact bytes already on the rail stay; do not replay them on the card. The card names the file; the PTY needle is satisfied because the card is written to the same `#transcript` RichLog the PTY paints.

### 7. Markdown style proof (D10 / D04)

| Verdict | **SURVIVE as one native owned-rail fixture in `test_layout.py`. CUT live-provider mocks, `md_line()`-only unit tests that never hit `#transcript`, and snapshot-only claims.** |
|---|---|
| Dimension lift | **D10** 6.0 → ~9.0 with §5. D04 residual (identity already 8.6) moves only if the same fixture shows the role rail. |

One test, empty-artifact then bytes, **no** `_start_provider_turn` stub of the live PTY path (this is native `run_test`, same pattern as `test_empty_artifact_stays_activity_and_speech_is_owned`):

1. Seed a running Analyst row with empty artifact; assert no `Thinking…`, no `◇ Analyst` in transcript.
2. `_active_turn_role = "Builder"`; `_append_provider_chunk` of **exactly** this body (heading, plus, minus, evidence path, plain, fence):

```
# Done when
+ keep composer
- dump status
lib/tui/app.py: rail stays 2px
plain body
```

then a fenced block ` ```fence ` / `inside` / ` ``` `.

3. Assert on `app.transcript.lines` segments (same inspection style as `_turn_has_hue`):
   - `▸ Builder` present once, style `BUILDER` (`#22c55e`)
   - heading payload `Done when` style includes `bold` and `OK` (`#22c55e`)
   - `+` style `OK`; `-` style `ERR` (`#ef4444`)
   - `lib/tui/app.py` bold; `: rail stays 2px` mute
   - `plain body` is not `OK`/`ERR`/role hue (neutral body)
   - fence marker / `inside` mute or unstyled, not `OK`
   - `delta.count("plain body") == 1`
4. Then `_provider_done(0, "/tmp/w12.txt")` (or the attach helper): card line `✓ done`, Builder rail, **still** `plain body` count == 1.

Not a live-provider mock. Not `CONSULT_PROVIDER` stubbing on `test_pty.py`.

---

## Smallest coherent Worker boundary

This is the **sole Worker contract**. One Worker. Skip formatters, linters, and project-wide suites. Do not run `tests/cli-interface-parity.sh` or `tests/visual-cli.sh`.

| Change | File | Why |
|---|---|---|
| `_dock_kind == "evidence"` on existing `#dock`; labelled bordered CSS class; display-only keys; y-order/focus/compact cap; evidence footer | `lib/tui/app.py` | D01 / D12 |
| `split_evidence_line` used from `_append_cli_line` for `report`/`bench` only; buffer; no fake empty panel | `lib/tui/theme.py` + `lib/tui/app.py` | D12 / D25 |
| `command_open` / `command_continue`; slash echo + stream + refuse | `lib/tui/theme.py` + `lib/tui/app.py` | D11 / D21 |
| `_toasts` + `notify` wrap; `/export` `/provider` toasts; no extra transcript lines | `lib/tui/app.py` | D14 / D19 |
| rail-continuation completion/error card; interrupt toast/card split | `lib/tui/theme.py` + `lib/tui/app.py` | D10 / D14 |
| Evidence panel + Command rail + attached card + markdown-lite snapshot + composer≥20 in evidence | `lib/tui/tests/test_layout.py` | D01 / D10 / D12 |
| `/report`/`/bench` summary-vs-files fixtures; `/export`/`/provider` toast observation; `/gate` no-spawn **unchanged** | `lib/tui/tests/test_slash.py` | D11 / D12 / D14 / D19 / D13 hold |

**Exact `/report` / `/bench` stream fixtures** (drive `adapter.run_argv_stream`, not a second parser). Bodies match `cmd_report` / `cmd_bench` under non-TTY (2-space indent, markers kept):

Report (`argv[0]=="report"`) — Command must keep `iter-1`; panel gets the two paths; transcript delta after the Command summary must not contain `runs/iter-1/pytest.txt` or `lib/tui/app.py`:

```text
  # harness-cli iter-1 — report
  KEEP lib/tui/. Reviewer scored every mandatory dim ≥ 9.0.
  lib/tui/app.py: rail stays 2px
  runs/iter-1/pytest.txt
```

Bench (`argv[0]=="bench"`) — Command must keep `Benchmark` and `visual-cli-clarity` / `9.5`; panel gets `+5.5  lib/theme.py` (or `lib/theme.py: headings stay ok`) and `state/engagements/harness-cli/runs/iter-1/scores.json`; those paths must not remain in `transcript_text()`:

```text
  Benchmark — harness-cli
  Contract harness-cli-v1 · frozen 2026-08-07 · target ≥ 9.0 in every dimension
  HISTORY
   iter  date        kind        overall
  LATEST — iter-1
   visual-cli-clarity   9.5  +5.5  lib/theme.py: headings stay ok
   overall  9.5   state/engagements/harness-cli/runs/iter-1/scores.json
```

Usage-only `/report` with no client still prints `usage: productteam report <client>` as Command and opens **no** panel. Empty buffer → no labelled chrome. Tests assert `_dock_kind == "evidence"`, label `evidence · {n} files`, y-order above composer, Esc restores focus, composer width ≥20.

**Worker check (one targeted file only):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_slash.py -q
```

That file holds `/gate` no-spawn, confirm needles, export/provider toast contracts, and report/bench summary-vs-files. Passing it is necessary and not sufficient; the Principal owns the full `lib/tui/tests` run, including new `test_layout.py` rows and the existing five PTY rows.

**Acceptance the Principal will run (Worker does not):**

```
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q          # 0 failed (do NOT freeze the count — new tests are added)
lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_pty.py -q   # existing 5 pass
tests/cli-interface-parity.sh    # PASS 33/18/15/6
tests/visual-cli.sh              # 14/14; exit 1 allowed only for the pre-existing live-provider hole
```

**Non-regression needles (must remain exact — do not weaken, replace, or re-route):**

- `test_pty_status_and_gate_refuse` — `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:171–179`).
- `test_pty_provider_interrupt` — live `partial analysis begins`; first Ctrl+C keeps `"interrupting provider"` + `"partial output left on disk"` + artifact bytes + `\tfailed\t`; second Ctrl+C exits 130 (`test_pty.py:182–215`).
- `test_pty_typed_role_records_builder` — live `builder analysis complete`; Builder/`done`/`verify the seam`.
- `test_pty_confirm_cancel_keeps_composer` — `Run /gh merge`, `Cancel`, confirm footer, `@Principal`, Esc → idle footer, `/exit` rc 0.
- `test_pty_sigwinch_compact` — ioctl 80→40→80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads.
- `test_gate_refused_without_spawn`; `test_confirm_cancel_no_spawn`; `test_confirm_non_matching_gh_unchanged`; `test_confirm_run_exact_argv_for_all_three_intercepts`.
- Ask tests: exact `ask-answer` shape, `ask.json.done` / `ask.json.invalid`, composer ≥20.
- `test_all_verbs.py` `NEEDLES["status"]`, `NEEDLES["report"]` (`iter-1`), `NEEDLES["bench"]` (`Benchmark`), `gh preflight` — needles stay in the **Command-summary / `_turns` cli delta**, not only in the panel.
- `test_role_chips_focusable_and_selectable`, `test_typed_role_prefix_strips`, `test_four_sizes`, `test_you_turn_chrome`, `test_activity_file_backed_caps_footer_and_resize`, `test_empty_artifact_stays_activity_and_speech_is_owned`.

**Exact surviving dimension lift (honest, not a blanket 9.0 promise):**

| ID | After this slice | Why not higher |
|---|---|---|
| **D12** | 0.0 → ~9.0 | Bordered labelled `#dock` + Command summary + files withheld against real report/bench shapes. Residual to 10.0: live PTY `/report`. |
| **D25** | 6.7 → ~9.0 | Ask + confirm + evidence path parsing all real. Residual: live PTY evidence. |
| **D01** | 8.7 → ~9.0 | Evidence dock completes “every dock above composer”. Splash is boot, not a seventh-region miss. |
| **D11 / D21** | → ~9.0 | Mute Command rail for echo/run/refuse/usage; PTY slash needles still exact. |
| **D10 / D14 / D19** | → ~9.0 | Markdown snapshot + rail-continuation card + session toasts with `_toasts` proof and no extra lines. |
| **D15** | hold ≥9 | Evidence footer optional vs freeze 10.0; ask/slash/idle/busy unchanged. Do not leave evidence falling through to the slash footer `enter run · tab complete` (`app.py:494`) — that claims a run path. |
| **D08 / D13 / D22 / D27 / D29** | hold ≥9 | Do not regress answer shape, retire, exact confirm, no-spawn, argv-only. |
| **D16 / D26** | stay 0 / 5 | Splash is iter-8. |
| **D28** | 7.9 → ~8.5 | Evidence §7 row lands; splash + empty-artifact PTY still fail. |

**Explicitly out of iter-7 (feature-creep cut):** TUI splash / skip / glow (D16), middle-head pulse, empty-home fixture, `prompt_export` capture, live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot, glob-latest ask, substring confirm, re-tokenizing Run argv, Enter-to-open files, a second `#evidence` widget / `ModalScreen` / `Button` / `ProgressBar`, placeholder panel chrome (`file1.md`, `lorem`, `TODO`), a classify function that is not called from `_append_cli_line`, provider mocks on the live path, weakened/replaced PTY or `/gate` needles, two writers, formatters.

**Files the Worker may touch:**

- `lib/tui/app.py` (required — evidence dock-kind, classify-at-stream, Command rail writer, `_toasts`, card attach, interrupt split)
- `lib/tui/theme.py` — **only** `command_open`/`command_continue`, `completion_card`, `split_evidence_line` reusing `_EVIDENCE_RE` / `MUTE` / `RAIL` / `status_tag` / `md_line`. **No new hex. No token table edits. No ROLE_STYLES changes.**
- `lib/tui/tests/test_layout.py` (evidence panel + Command rail + attached card + markdown-lite snapshot + composer width in evidence)
- `lib/tui/tests/test_slash.py` (report/bench fixtures, export/provider toasts, `/gate` needle unchanged)

**Files the Worker may not touch:** `provider_turn.sh`, `adapter.py`, `session.py`, `test_pty.py` assertions (existing five must stay exact), `test_all_verbs.py` `NEEDLES` (report still contains `iter-1`; bench still contains `Benchmark` **in the Command-summary / `_turns` delta**), Bash modules, freeze files, snapshots, unrelated dirty worktree. Snapshots: Principal-only refresh after green pytest.

---

## Missing proof / untested behavior if the unbound proposal shipped

1. **Full-line `_EVIDENCE_RE` on `cmd_bench` area rows** → score/area summaries vanish into the panel; `Benchmark`/`iter-1` may survive by accident or not; D12 “summary stays a Command turn” fails.
2. **Classifying report markdown headings as paths** → `NEEDLES["report"]` (`iter-1`) leaves the Command delta; `test_all_verbs` or freeze §7 Evidence row fails.
3. **Post-stream classify** → `RichLog` already contains the file list; D12 “do not drown the transcript” is unrecoverable.
4. **Test-only parser** in `test_slash.py` with a stub `_append_cli_line` → D25 evidence seam is not real; Reviewer scores 0.
5. **Placeholder `#evidence` Static / hardcoded three paths** → D12 0.0; freeze forbids fake chrome.
6. **Second widget / `ModalScreen` / Enter-to-open** → D01 y-order or a new spawn path; replay of iter-2/3 dock-steal.
7. **Command rail as a role turn or a toast** → D11/D14 circle; `/gate` needles may move off-transcript and red PTY.
8. **`notify` without `_toasts`** → `test_export_writes_markdown` is rewritten to a sleep or a Toast query that flakes; D19 uncited.
9. **`transcript.clear` + rewrite speech + card** → duplicates `answer one`; D09/D10 native row fails.
10. **Dropping `partial output left on disk` from the RichLog** → `test_pty_provider_interrupt` red; D14/D29.
11. **Second interrupt toast in `_provider_done`** (today `app.py:1350` `notify("Ctrl+C — interrupt")`) → double toast, not the locked frame. Cut it.
12. **Evidence/Command riding splash or pulse** → 30-minute timeout replay; D16 claimed without evidence.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT this bound evidence+Command+toast+card contract only.** A Worker pointed at (1) `theme.split_evidence_line` called from `_append_cli_line` for `report`/`bench` only, splitting mixed `cmd_bench` rows so `iter-1`/`Benchmark` stay Command and paths never re-enter `transcript_text()`; empty buffer opens no panel; (2) existing `#dock` OptionList `_dock_kind=="evidence"`, bordered `RULE` class, display-only keys, y-order above composer, close restores focus, compact 3/6+`+N`, composer ≥20; (3) one mute `Command` rail helper owning slash echo, supported summary, refuse+usage; (4) `self._toasts` wrapping `notify`; `/export`/`/provider` information toasts with **no** extra transcript line and rewritten slash tests; (5) append-only role-rail completion/error card, no body rewrite; (6) one interrupt toast + error card carrying `partial output left on disk`; (7) native owned-rail markdown-lite style fixture; files = `app.py` + `theme.py` (helpers only) + `test_layout.py` + `test_slash.py`; Worker check = `lib/tui/.venv/bin/python -m pytest lib/tui/tests/test_slash.py -q`; Principal acceptance = full native suite green + existing 5 PTY rows + parity/visual gates, with splash/pulse/empty-home/PTY-strip cut to iter-8, is a bounded verifiable pass.

### Iter-8 (named for convergence, not in this slice)

- TUI splash + non-TTY seam (D16/D26 → 9.0)
- middle-head pulse + honest empty-home fixture + `prompt_export` capture + live-PTY activity-strip / empty-artifact / compact-cap-and-score-slot (D03/D05/D06/D07/D09/D24 → 9.0)
- then D28 → 9.0 and `final-report.md`
