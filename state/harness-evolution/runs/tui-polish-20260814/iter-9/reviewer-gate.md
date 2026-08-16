# Reviewer gate — iter-9

Reviewer: independent, read-only. No app, test, snapshot, registry, or freeze edits.
Run: `tui-polish-20260814` / `iter-9`
Freeze: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md` (`FREEZE-SHA.txt` first line `018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`; live `sha256sum` matches)
Authority: frozen D01–D29 (`frozen-benchmark.md:257–294`); owner schedule extension `extension.md` (iter-6…iter-10, freeze immutable); Worker contract `iter-9/debate.md`. Missing, stale, or uncited evidence scores 0.0. Average does not compensate. PASS only if every score ≥ 9.0.

**Verdict: PASS — KEEP polish. First all-pass. Every D01–D29 ≥ 9.0.**

The bound proof cluster landed. Native suite is 73/0 (five home/header/rail rows plus the prior 67). Real PTY is 6/0: the five unweakened rows plus freeze §7 empty-artifact / live activity / compact-score / `prompt_export`. Remaining zeros: none. Remaining sub-9: none.

| | |
|---|---|
| `all_ge_9` | `true` |
| Lowest | **9.0** (`D14`) |
| Zeros | **none** |
| ≥ 9.0 | D01–D29 (**29/29**) |
| Native pytest | **73 passed, 0 failed** (`iter-9/pytest.txt`) — 6 new rows over iter-8's 67 |
| Canonical gates | parity **PASS** 33/18/15/6; visual-cli **14/14** with allowed live-provider hole |

## Three required outputs

1. **Final verdict:** PASS. **STOP at first all-pass.** Do **not** start iter-10. Do **not** spawn another Worker. Authorize a Principal **`final-report.md` refresh** (plus `diff-summary.md` / `lessons.md` as the run evidence list requires). Do **not** delete `lib/tui/` or the `tui` registry row. This gate does not itself write `final-report.md`.
2. **Scores:** `iter-9/scores.json` (this gate). Every D01–D29 has a current path or command citation.
3. **Explicit 9.0 decisions (the eight iter-8 sub-9 dims, re-audited against product/test evidence):**
   - **D03 clears 9.0** (9.2). Honest empty-home copy is fixture-proven; recency is `st_mtime` of the latest valid `scores.json` (numeric-iter fallback, client-name tie-break, mapped pin of at most one slot with mtime-sorted rest). Residual to 10.0: live-tree recency snapshot.
   - **D04 clears 9.0** (9.2). Principal / Analyst / Builder / Critic speaking rails each carry that role's hue on rail+label with unstyled body. Residual to 10.0: live-PTY Critic speech.
   - **D05 clears 9.0** (9.2). Wide-header middle `▣` pulses `OK` on live activity and on `_provider_active`; idle restores un-pulsed bold; compact has no heads. Residual to 10.0: pulse snapshot.
   - **D06 clears 9.0** (9.2). Live PTY activity strip shows braille, mission, `hold-provider.sh`, `m:ss`, and busy interrupt footer on a real workers.tsv row. Residual to 10.0: 3/2 live-PTY caps (native already has 3/2/1+N).
   - **D07 clears 9.0** (9.2). Live ioctl 80→40→80 while work is live proves compact `ProductTeam {score}`, 1+N `+2`, composer retained, heads restored. Residual to 10.0: four sizes remain native (PTY is the 80/40 pair).
   - **D09 clears 9.0** (9.2). Freeze §7 empty-artifact **PTY** window: chip-safe absence of `Thinking…` and `│ {glyph}` rails, then exactly one `│ ▸` on first owned bytes. Residual to 10.0: live-PTY Analyst/Critic empty-artifact.
   - **D24 clears 9.0** (9.2). Exact live `state/agents/builder.json` `prompt_export` + blank line + `verify the seam` captured in `prompt-capture.txt` from `-p` **before** stdout; `provider_turn.sh` signature untouched. Residual to 10.0: Critic / `agent_card_prompt_block` fallback.
   - **D28 clears 9.0** (9.3). Every freeze §7 row now has a passing citation, including the empty-artifact PTY. Residual to 10.0: live-PTY splash and live-PTY `/report` remain optional 10-band, **not** 9-blockers.

---

## Adversarial inspections (required)

Scope bound by `iter-9/debate.md`: `_seed_home` recency sort; native empty/recency/pulse/four-role fixtures; one new PTY row `test_pty_activity_empty_artifact_compact_and_prompt_export`; interrupt chronology wait for the failed card before the second Ctrl+C. Product mtimes in the Worker window: `app.py` 01:35, `test_layout.py` 01:40, `test_pty.py` 02:08. Snapshots rewritten 02:11 by Principal `test_snapshots_export` during the freeze table. `provider_turn.sh` (11:46 2026-08-14), `adapter.py` (01:40), `session.py` (00:38), `theme.py` (00:11 — iter-8 splash), `__main__.py` (00:42), `test_slash.py` (22:52), `test_all_verbs.py` NEEDLES (11:47), and `test_nontty.py` (00:43) were not retouched this iter.

### 1. Home recency and honest empty (D03) — HONEST, clears 9.0

`_latest_valid_scores` walks `state/engagements/{c}/runs/iter-*`, accepts only numeric `N`, readable JSON, and numeric `overall`, and keeps the **largest numeric iter** (so `iter-10` beats `iter-9`). Recency key is that file's `st_mtime` (`app.py:1007-1036`). `_read_overall` is the overall half of the same helper (`app.py:1038-1040`). No `mtime` field was added to `status --json`; `bin/productteam` was not edited.

`_seed_home` filters scored / not-banned / numeric overall, then sorts `( -mtime, -iter, client )` (`app.py:1062-1088`). Mapped pin fires **only** when the cwd-mapped client is eligible and **outside** the top 3: it occupies slot 0; the rest stay mtime-sorted (`app.py:1089-1096`). This is not mapped-first over the whole list.

Native empty fixture (`test_layout.py:135-180`): `status --json` with `engagements: []` yields transcript **exactly** `No scored sessions yet — bench <client> to score`; `HOME_ROW_RE` is empty; prose dump needles absent; `@Principal`, idle footer, and chips remain. Re-seeding banned/unscored rows still yields zero home rows.

Native recency (`test_layout.py:210-254`): isolated `tmp_path` ROOT; order after pin is `here-client`, `new-client`, `mid-client`; `lex-client` / `old-client` / `smoke-client` / `idle-client` absent; cap 3; no status prose. Numeric/client tie-break (`test_layout.py:257-285`): equal mtimes → `tie-b` (`iter-10`) then `tie-a` (`iter-9`) then `name-a` (alphabetical over `name-z`); JSON array order was scrambled on purpose.

`test_home_seed_filtered` (`test_layout.py:112`) is unweakened. Snapshot home still shows three scored rows with `harness-cli` as a **row**, not the bar.

### 2. Four-role rails and header pulse (D04 / D05) — HONEST, clears 9.0

Four-role matrix (`test_layout.py:698-753`) drives `_append_provider_chunk` only. No live-provider mock. Per role Principal/Analyst/Builder/Critic: exactly one `│ {glyph} {role}`; `_turn_has_hue` on the label; opener rail span is the role hue; distinctive body has **no** style span; `Thinking…` absent. Builder is included in the loop (not skipped because the markdown fixture already covered it). You chrome remains `test_you_turn_chrome` (`test_layout.py:411`).

Pulse (`test_layout.py:351-408`) observes `#header` spans, not a source comment. Idle: middle `▣` is not `OK`; no OK-colored `▣` anywhere. Live activity row: middle `▣` is `OK` `#22c55e`; left `▣─` and right `─▣ ProductTeam` un-pulsed. `_provider_active` after activity clears to `done`: middle `▣` OK again. Compact 40 while busy: `ProductTeam {score}` and **no** `▣`. Idle restore drops the pulse. Product path is still `_render_header` (`app.py:1042-1057`); no second header widget.

### 3. Live PTY activity + empty-artifact + compact score/caps (D06 / D09 / D07) — HONEST, clears 9.0

One new test, appended after the existing five, name stable: `test_pty_activity_empty_artifact_compact_and_prompt_export` (`test_pty.py:438-591`). `_open_session` still sets `CONSULT_NO_SPLASH=1` (`test_pty.py:129`). No stub of `_start_provider_turn`. Hold-then-speak fixture parses `-p`, writes `prompt-capture.txt` **before** `sleep 8` and **before** stdout (`test_pty.py:384-398`).

Numbered timeline held:

| Step | Evidence |
|---|---|
| T0 | idle `ProductTeam` |
| T1 | `@Builder verify the seam` |
| T2 | exact-session `workers.tsv` Builder row in `{pending,running,progress}` with missing/empty artifact (15s file predicate, not a bare sleep) |
| T3 | stripped delta: `Thinking…` absent; `│ ◆` / `│ ◇` / `│ ▸` / `│ ◉` absent (chip glyphs without a rail are not a fake turn); braille from `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`; mission `verify the seam`; `hold-provider.sh`; `\d+:\d{2}`; `ctrl+c interrupt` |
| T4 | atomic `os.replace` of two extra live rows into **that same** TSV; header + Builder preserved |
| T5 | ioctl 80→40; compact `ProductTeam (—|\d+\.\d)`; heads and cwd absent; `+2`; composer prefix retained (see inspection 4) |
| T6 | ioctl 40→80; `▣─▣─▣ ProductTeam` restored **while still live** |
| T7 | `owned speech begins`; stripped delta from T1 contains `│ ▸` **once**; `Thinking…` still absent |
| T8 | `/exit` rc 0 — not Ctrl+C |

No `ProgressBar`. Native 3/2/1+N (`test_layout.py:597-663`) still in the 73. Live PTY proves the 40-col 1+N cap; 3-at-80 / 2-at-60 remain native (10-band residual, not a 9 fail).

### 4. `@Builder` compact contract correction (D07 / D18) — HONEST, freeze-aligned

Debate T5 named `@Principal` as the compact composer needle. Freeze Q15 is stricter and wins: composer shows `@Role`, session-local; idle home defaults to `@Principal`.

This row **typed** `@Builder verify the seam`, which is the Q15 target change. The compact frame therefore shows `@Builder` (`test_pty.py:567-571`). Demanding `@Principal` on that frame would contradict the product lock and false-fail a correct session-local prefix.

Composer retention is still proven twice:

| Frame | Prefix | Why |
|---|---|---|
| Idle SIGWINCH (`test_pty.py:306-373`) | `@Principal` | default target, no role typed |
| Live activity compact (`test_pty.py:558-572`) | `@Builder` | typed `@Builder` changed the session-local target |

This is a freeze-over-debate correction, not a needle weaken. The idle row's `@Principal` needle is unchanged. D07 and D18 both still clear 9.0.

### 5. `prompt_export` capture (D24) — HONEST, clears 9.0

`provider_turn.sh` mtime 11:46 2026-08-14 — **not this iter**. Signature stays `ROOT PROMPT ROLE` (`provider_turn.sh:22-24`); default ROLE Principal (`:24`); `activity_start "$ROLE"` (`:36`); prepend `printf '%s\n\n%s' "$exported" "$PROMPT"` (`:52`). App still launches `["bash", PROVIDER_TURN_SH, ROOT, prompt, role]` (`app.py:1581`).

Capture is argv-adjacent: the hold fixture writes `$prompt` from `-p` to `CONSULT_STATE_ROOT/prompt-capture.txt` before any stdout. The test loads `prompt_export` from live `state/agents/builder.json` at runtime (`test_pty.py:466-470`) and requires whole-file equality `{prompt_export}\n\nverify the seam\n` (`:523-526`). `Thinking…`, `│ ▸`, and `owned speech begins` are forbidden in the capture file. Read happens after T2 and **before** T7.

That is observed prepend, not a source comment. Residual: Critic / empty-card `agent_card_prompt_block` fallback unproven (10-band).

### 6. Interrupt chronology (D14 / D24 / D28) — STRENGTHENED, not weakened

Freeze §7: first Ctrl+C reaps the process group, retains partial artifact, marks worker `failed`; second Ctrl+C exits 130.

`test_pty_provider_interrupt` (`test_pty.py:184-219`) still uses the live slow-provider fixture and the same needles: `partial analysis begins`; `"interrupting provider"`; artifact bytes; `\tfailed\t`; status 130. The **only** change is that after the first Ctrl+C the test now waits for the failed-card copy `partial output left on disk` **before** sending the second Ctrl+C (`test_pty.py:202-207`).

Iter-9 notes record a paint race: waiting only for the toast could issue the force-exit Ctrl+C before Textual painted the card. Waiting for the card makes the asserted sequence match the freeze: first interrupt reaps/preserves/marks failed **and paints the card**; second exits 130. Needles were not replaced, shortened, or routed around. Isolated PTY 6/0 includes this row (`iter-9/pty-test.txt`; `iter-9/pty-note.md`).

D14 holds 9.0 (non-130 fail toast+card remains source-only). Chronology is a proof-quality fix, not a product feature, so it does not inflate D14 to 10.

### 7. D01 / D08 / D13 / D15 / D16 / D26 re-audit — HOLD, still clear 9.0

Proof-cluster work did not retouch splash/ask/confirm/evidence machines.

**D01 holds 9.2.** Compose is still `header / rule / #splash / #transcript / #activity / #chips / #dock / #composer-region / footer` (`app.py:361-374`). Activity CSS `display:none` until `.visible`. Every dock above composer. Composer ≥20 at four sizes. Splash occupies transcript `1fr` while visible.

**D08 holds 9.1.** `_poll_ask` still reads only `Path(self._active_artifact).parent / "ask.json"` while `_provider_active` and `_dock_kind == "slash"` (`app.py:687-693`). Evidence kind cannot steal the poll.

**D13 holds 9.2.** Exact tuple intercept of `("gh","merge")`, `("checks","--allow-dirty")`, `("onboarding","--yes")` (`app.py:884-888`). Cancel/Esc `spawns == []`. Live PTY `/gh merge` Esc still in the 6.

**D15 holds 9.2.** Idle / busy / slash / ask / confirm / evidence / splash footers unchanged. Compact busy still omits provider (9-band residual).

**D16 holds 9.2.** Fifteen `test_splash_*` rows still in the 73. Live-PTY splash remains optional 10-band, **not** a 9 reopen.

**D26 holds 9.2.** `CONSULT_NO_SPLASH` short-circuit + `/splash` Command `▣` + non-TTY exit 2 / empty stdout / TTY remedy / no ESC under `NO_COLOR` (`test_nontty.py:25-37`). New PTY row keeps `_open_session`'s `CONSULT_NO_SPLASH=1`.

### 8. PTY regressions — NONE; sixth row added without replacing the five

`test_pty.py` added one test after line 373. Existing five names, needles, and `_open_session` default env are intact. Isolated PTY **6 passed** (`iter-9/pty-test.txt`).

| Row | Held |
|---|---|
| `test_pty_status_and_gate_refuse` | `Product Consulting Harness`, `harness-cli`, `use the CLI: productteam gate`, `owner-gated`, `no directive` absent, no `AttributeError` (`test_pty.py:173-181`) |
| `test_pty_provider_interrupt` | live `partial analysis begins`; `"interrupting provider"`; `"partial output left on disk"` **before** second Ctrl+C; artifact bytes; `\tfailed\t`; second Ctrl+C exits 130 (`test_pty.py:184-219`) |
| `test_pty_typed_role_records_builder` | live `builder analysis complete`; Builder/`done`/`verify the seam` (`test_pty.py:222-262`) |
| `test_pty_confirm_cancel_keeps_composer` | `Run /gh merge`, `Cancel`, confirm footer, `@Principal`; Esc -> idle footer; `/exit` rc 0 (`test_pty.py:266-303`) |
| `test_pty_sigwinch_compact` | ioctl 80->40->80; compact `ProductTeam` without heads/cwd; `@Principal` retained; restored heads (`test_pty.py:306-373`) |
| `test_pty_activity_empty_artifact_compact_and_prompt_export` | **new** — freeze §7 empty-artifact + live strip + compact score/`+2`/`@Builder` + `prompt_export` (`test_pty.py:438-591`) |

### 9. Snapshot scope — HONEST, not a needle weaken

Snapshots are still idle cockpit + slash palette only. Principal rewrote them at 02:11 during `test_snapshots_export` (allowed as chrome evidence). They do **not** contain splash art. Recency/empty/pulse/activity are fixture-proven, not idle-snapshot claims.

Held needles:

| Frame | Held |
|---|---|
| `cockpit-80x24.svg` | `▣─▣─▣ ProductTeam`; no `Directive`; `harness-cli` is a **home row**, not the bar; `@Principal` |
| `palette-80x24.svg` | `/st` filters; `@Principal` |
| Both | role hues `#c084fc` `#60a5fa` `#22c55e` `#f59e0b`; canvas `#0a0a0a`; field `#141414`; no `#0178D4`; no `Directive` |

You `#8a8a8a` and err `#ef4444` remain absent from idle frames (D02 9-band residual, unchanged).

### 10. Org One Writer — HELD

Debate named one Worker and `app.py` + `test_layout.py` + `test_pty.py`. Those three files moved in one window. Principal ran the freeze table and refreshed snapshots. No second Worker on `lib/tui/`. `provider_turn.sh` / `adapter.py` / `session.py` / `theme.py` / `__main__.py` / `test_slash.py` / `test_all_verbs.py` NEEDLES / `test_nontty.py` mtimes predate this iter. No new hex. No `bin/productteam` fake mtime field. No live `state/engagements/` utime. Optional 10-band live `/report` and live splash PTY were **cut**, as bound.

---

## Diff / scope critique

Worker diff is the bound proof cluster only:

| File | What landed | Out of slice? |
|---|---|---|
| `lib/tui/app.py` | `_latest_valid_scores` + `_seed_home` recency/pin. Pulse already existed. | No second header; splash/ask/confirm/evidence untouched |
| `lib/tui/tests/test_layout.py` | empty-home, recency, numeric/client tie-break, pulse spans, four-role rails | Splash rows unweakened; `CONSULT_NO_SPLASH=1` default kept |
| `lib/tui/tests/test_pty.py` | one new live-provider row; interrupt wait-for-card | Existing five not renamed/replaced; no live splash; no live `/report` |
| Snapshots | Principal freeze-table refresh | Idle chrome only |

`provider_turn.sh` was in the iter-8 reviewer file list as "only if capture needs a needle." Debate cut that. Capture used the hold-provider `-p` file instead. Correct: a signature or stdout print would have opened speech during T3 and zeroed D09.

Feature-creep that did **not** land: glob-latest TSV, clobbering the live Builder row, stubbing `_start_provider_turn` on the PTY row, fake JSON mtime, lexicographic `last_iter`, mapped-first labeled as recency, helper-only pulse tests, `ModalScreen`, new hex, live-PTY splash as a D16 reopen.

---

## Self-grading bias re-audit / benchmark bias audit

Prior gates were re-read against current evidence. Conservative resolution: disputed subjective items keep the lower score until new evidence. **A 9 threshold is not a 10-band demand:** live-PTY splash and live-PTY `/report` stay unrequested for D16/D26/D12 ≥9.

| Pattern | Finding |
|---|---|
| Iter-8 correctly left D03/D04/D05/D06/D07/D09/D24/D28 sub-9 | Closed. All eight now ≥9 from fixtures + one live PTY row, not source comments. |
| Debate predicted ~9.0 for those eight | Landed 9.2 / 9.2 / 9.2 / 9.2 / 9.2 / 9.2 / 9.2 / 9.3. None are 10 because the named 10-band residuals remain. |
| Green 73 != automatic 10.0 | **Not inflated.** D14 stays 9.0. D02 still lacks You/err on idle SVGs. D16/D26 do not claim live-PTY splash. |
| Debate `@Principal` vs freeze `@Role` | Scored as freeze-aligned correction (inspection 4), not as a D07 miss and not as a needle weaken. Idle `@Principal` still held. |
| Interrupt wait-for-card | Scored as chronology honesty (inspection 6), not as a D14 10. Product interrupt path unchanged. |
| D01/D08/D13/D15/D16/D26 without being the slice | Re-audited live (inspection 7). All still clear 9.0. No silent regression. |
| No implementer-authored `scores.json` | This Reviewer did not edit app code. |
| Missing evidence = 0 | No dimension is uncited. No zeros. |

---

## Organization critique

**One Writer:** held. See inspection 10.

**Debate / reviewer friction:** the iter-9 Critic bound chip-safe PTY absence needles, same-session atomic TSV inject, `st_mtime` recency (not a fake JSON field), `-p` capture **before** stdout with no `provider_turn.sh` edit, header-span pulse, and four-role `_append_provider_chunk`. The Worker copied that contract and made two honest corrections the freeze already implied: (1) compact composer needle is `@Builder` on a typed Builder turn; (2) interrupt PTY waits for the failed card before the 130 exit. Both prevent false-fails (idle-prefix on a retargeted turn; racy card paint). Neither reopens scope.

**Freeze coverage / blind spots remaining (10-band only — not iter-10 blockers):**

- Live-PTY splash frame (D16/D26 residual). Explicitly **not** a 9 reopen.
- Live-PTY `/report` evidence (D12/D25 residual). Explicitly **not** a 9 reopen.
- Live-PTY Critic speech / `agent_card_prompt_block` fallback (D04/D24 residual).
- Pulse / recency idle-snapshot (D03/D05 residual).
- Compact busy footer omits provider (D15 residual, already ≥9).
- `/workers` glob-latest (`session.py`) remains a second reader beside the honest live strip. Harmless for D24 as scored.

**Evidence completeness:** iter-9 has debate, pytest, isolated PTY, parity, visual-cli, notes, pty-note, this gate, and scores. Argv dry-run and freeze hashes unchanged.

---

## Scores

| ID | dimension | score | citation |
|---|---|---:|---|
| D01 | Exact global layout | 9.2 | Compose header/rule/`#splash`/transcript/`#activity`/`#chips`/`#dock`/`#composer-region`/footer (`app.py:361-374`). Activity CSS `display:none` until `.visible`. One `OptionList`; `_dock_kind` in slash/ask/confirm/evidence. Every dock above composer; Esc/Enter close restores focus. Composer >=20 at four sizes (`test_layout.py:93`). Splash does not cover composer. Residual: splash is boot, not a missing idle seventh region. |
| D02 | Exact cockpit tokens and glyphs | 9.3 | Exact hex + glyphs `theme.py:17-60`; token/bash/snapshot tests in the 73. Both SVGs carry role hues and no `#0178D4`. No new hex this iter. Non-10: idle SVGs omit You `#8a8a8a` and err `#ef4444`. |
| D03 | Q1 filtered home | **9.2** | **Clears 9.0.** `test_home_seed_filtered` (`test_layout.py:112`) <=3, exclusions, no prose dump. `test_home_empty_copy_when_no_scored` (`:135`) exact empty copy + idle chrome. `test_home_recency_mtime_order` (`:210`) pin+mtime cap. `test_home_recency_numeric_and_client_tiebreak` (`:257`) `iter-10` beats `iter-9`. Product: `_latest_valid_scores` + recency sort (`app.py:1007-1096`). Residual: live-tree recency snapshot. |
| D04 | Q2 identity | **9.2** | **Clears 9.0.** You rail (`test_layout.py:411`). Four-role speaking matrix (`test_layout.py:698-753`): rail+label hue, unstyled body, no `Thinking…`. Live Builder speech held (`test_pty.py:222`). Markdown fixture still asserts Builder `#22c55e` (`test_layout.py:1116`). Residual: live-PTY Critic speech. |
| D05 | Q3 header | **9.2** | **Clears 9.0.** Wide `▣─▣─▣ ProductTeam · {cwd} · {score}`; compact `ProductTeam {score}`; no `harness-cli`/`Directive` in the bar (`test_layout.py:288`; snapshots). Middle-head pulse observed on `#header` spans (`test_layout.py:351-408`; `app.py:1052`). Live PTY compact score slot (`test_pty.py:563-564`). Residual: pulse snapshot. |
| D06 | Q4 honest activity | **9.2** | **Clears 9.0.** Native braille/mission/`m:ss`/caps 3/2/1+N (`test_layout.py:597`). Live PTY strip: braille + `verify the seam` + `hold-provider.sh` + `m:ss` + `ctrl+c interrupt` (`test_pty.py:530-540`). No `ProgressBar`. Residual: 3/2 caps native-only. |
| D07 | Q5 compact and resize | **9.2** | **Clears 9.0.** Four sizes + native 80->40->80 (`test_layout.py:93,597`). Idle PTY ioctl (`test_pty.py:306`). **Live** ioctl while busy: compact `ProductTeam (—|\d+\.\d)`, no heads/cwd, `+2`, `@Builder` composer, restored heads (`test_pty.py:558-577`). Residual: four sizes native; PTY is the 80/40 pair. |
| D08 | Q6 structured ask | 9.1 | **Re-audit HOLD, still clears 9.0.** Sibling `ask.json` (`app.py:687`). Native single/multi/invalid tests still in the 73. Evidence kind cannot steal the poll. Residual: no live-PTY ask. |
| D09 | Thinking versus speech | **9.2** | **Clears 9.0.** Native empty-artifact silent + owned first-bytes (`test_layout.py:666`). Freeze §7 **PTY** window: chip-safe rail absence then one `│ ▸` (`test_pty.py:527-534, 578-583`). Residual: live-PTY Analyst/Critic empty-artifact. |
| D10 | R1 markdown-lite | 9.1 | Heading/fence/+/-/evidence-path/neutral body on the owned Builder rail (`test_layout.py:1116`). Attached done card does not replay speech. Residual: not a live-PTY markdown row. |
| D11 | R2 slash | 9.1 | Live `help --json` palette. Native `/sta` + `/gate` no-spawn. PTY `/status`/`/gate` held. Mute Command rail. Residual: live PTY does not assert the `│ Command` string. |
| D12 | R3 evidence | 9.1 | Bordered labelled `#dock`. Report/bench Command summaries + withheld paths (`test_slash.py:205,253`). Empty buffer paints no chrome. Residual: live PTY `/report` is 10-band, not a 9 fail. |
| D13 | R4 confirm | 9.2 | **Re-audit HOLD, still clears 9.0.** All three exact argvs intercepted (`app.py:884-888`); Run original argv; Cancel/Esc no-spawn. Residual: PTY proves cancel UI, not live Run. |
| D14 | R5 toasts and cards | 9.0 | Done card attached. Interrupt: one warning toast + error card with `partial output left on disk`; PTY now waits for that card before the 130 exit (`test_pty.py:202-211`). `/export`/`/provider` information toasts. Residual: non-130 fail toast+card is source-only. |
| D15 | R6 footer | 9.2 | Idle / busy / slash / ask / confirm / evidence / splash footers exact (`app.py:554-589`). Freeze D15 10.0 names idle/busy/ask/slash — all exact. Residual: compact busy omits provider. |
| D16 | R7 splash | 9.2 | **Re-audit HOLD, still clears 9.0.** Fifteen `test_splash_*` rows (`test_layout.py:1403-1841`). Residual to 10.0: live-PTY splash — **not required for 9.** |
| D17 | R8 display-only home | 9.2 | Home is `transcript.write` of <=3 rows; compose has no picker; header follows cwd. Snapshots have no switcher. Recency fixtures do not add a picker. |
| D18 | Targeting | 9.3 | Focusable chips, `@Role` chrome, Principal default, typed `@Role`, `ROOT PROMPT ROLE`, `prompt_export` else card block, live `@Builder` -> Builder `workers.tsv`. Compact `@Builder` prefix retained on the live SIGWINCH frame (`test_pty.py:567-571`). |
| D19 | Defaults | 9.1 | Dim timestamps held; copy/export is a session toast, not chrome. Token table unchanged this iter. |
| D20 | Palette backend seam | 9.7 | Live `help --json` (`adapter.py`); dry-run `["help","--json"]` rc 0. No second verb list. |
| D21 | Supported slash backend | 9.1 | Real executable argv + stream. Native 18-verb per-turn proof (`test_all_verbs.py:70`). Live `/status` complete. Mute Command + `md_line` on the stream. |
| D22 | Unsupported / chat-only | 9.4 | 15-verb refuse no-spawn. Native + PTY `/gate`. Chat-only `/provider` `/clear` `/export` `/exit` `/workers` `/quit`. |
| D23 | Home/header data seam | 9.3 | Home seeds only `status --json`; header score from latest `runs/iter-*/scores.json` when `Repo:` matches cwd (`app.py:1007-1057`). Snapshot header has no Mode/Directive. Recency reads those same files; it does not invent a JSON mtime field. |
| D24 | Activity/provider seam | **9.2** | **Clears 9.0.** Exact-session poll + caps. `ROOT PROMPT ROLE`; `activity_start "$ROLE"`; agent-cards prepend **observed** in `prompt-capture.txt` (`test_pty.py:512-526`; `provider_turn.sh:22-52` unedited). Process-group interrupt held and chronology-hardened. Residual: Critic/`agent_card_prompt_block` fallback. |
| D25 | Ask/confirm/evidence seams | 9.1 | Ask file-backed + id-keyed retire + atomic answer (D08). Pre-run write intercept + empty Cancel argv log (D13). Evidence path parsing is product-side `split_evidence_line` at stream time (D12). Residual: live PTY evidence is 10-band. |
| D26 | Splash / non-TTY seams | 9.2 | **Re-audit HOLD, still clears 9.0.** TUI-owned splash + `/splash` Command `▣` (`test_all_verbs.py:41`) + non-TTY exit 2 / empty stdout / TTY remedy / no ESC under `NO_COLOR` (`test_nontty.py:25-37`). New PTY row keeps env short-circuit. Residual to 10.0: live-PTY splash — **not required for 9.** |
| D27 | Argv safety and dry-run | 9.6 | Fresh executable dry-run unchanged: real `bin/productteam` 0o775, `shell` false, whole-token deny, `agents --json` allowed. No new parser of argv. Recency does not edit `bin/productteam`. |
| D28 | Required test coverage | **9.3** | **Clears 9.0.** Native **73/0** (`iter-9/pytest.txt`). Isolated PTY **6/0** (`pty-test.txt`): five prior rows plus freeze §7 empty-artifact PTY. Parity PASS 33/18/15/6. Visual-cli 14/14 with allowed live-provider hole. Interrupt chronology wait-for-card is a strengthen. Residual: live-PTY splash / live `/report` are not §7 9-blockers. |
| D29 | Preservation and failure behavior | 9.2 | No forbidden cuts; chat remains Bash TTY; `lib/tui/` not deleted; freeze hash unchanged; `tui` registry row kept; PTY needles not replaced; One Writer held; `provider_turn.sh` unedited this iter; unrelated dirty worktree not overwritten. Owner extension did not amend D01-D29. This slice **does** claim KEEP. |

---

## Remaining zeros and every sub-9 blocker

Zeros: **none.**

Every sub-9: **none.**

| ID | iter-8 | iter-9 | Exact close |
|---|---:|---:|---|
| D03 | 8.5 | 9.2 | Empty-home fixture + mtime recency + numeric/client tie-break + mapped pin. |
| D04 | 8.8 | 9.2 | Four-role speaking-rail + neutral-body matrix. |
| D05 | 8.5 | 9.2 | Middle-head pulse observed on `#header` spans; compact no-heads while busy. |
| D06 | 7.5 | 9.2 | Live PTY activity strip (braille / mission / provider / `m:ss` / busy footer). |
| D07 | 8.5 | 9.2 | Live compact `ProductTeam {score}` + `+2` + composer retained (`@Builder` freeze-aligned) + heads restored while live. |
| D09 | 8.2 | 9.2 | Freeze §7 empty-artifact PTY window, chip-safe. |
| D24 | 8.6 | 9.2 | Exact Builder `prompt_export` captured from `-p` before stdout; interrupt chronology held. |
| D28 | 8.7 | 9.3 | Empty-artifact PTY lands; 73/0 and 6/0; parity/visual green. |

Cleared this iter (no longer blockers): **D03, D04, D05, D06, D07, D09, D24, D28**. Re-audit holds: **D01, D08, D13, D15, D16, D26**. Already-cleared ≥9 unchanged: **D02, D10, D11, D12, D14, D17, D18, D19, D20, D21, D22, D23, D25, D27, D29**.

Do **not** treat live-PTY splash or live-PTY `/report` as leftover 9-blockers. Those are 10-band residuals on dimensions that already clear 9.0.

---

## Iter-10 bind

**None.** First all-pass. Do not start iter-10. Do not hand a Worker another slice. 10-band residuals above are optional polish, not acceptance blockers.

---

## Verdict

**PASS — KEEP `lib/tui/` polish.** Every mandatory dimension ≥ 9.0. Exact failing commands: none. Remaining zeros: none.

**STOP at first all-pass.** Do not start iter-10. Do not spawn another Worker. Principal is authorized to refresh `final-report.md` (and the run's `diff-summary.md` / `lessons.md`) from this gate and `iter-9/scores.json`. Keep the registry row. Freeze stays immutable.
