# ProductTeam TUI polish — final report

Date: 2026-08-14  
Run: `tui-polish-20260814`  
Independent verdict: **PASS** (`iter-9/reviewer-gate.md`)  
Stop condition: **first all-pass at iter-9; iter-10 not started**

## Decision

Keep the already-shipped optional Textual cockpit, `lib/tui/`, and the `tui` registry row. The polish converged against the immutable locked visualizer contract: every mandatory D01–D29 score is at least 9.0.

`productteam chat` remains the Bash fallback and does not launch the TUI. No OpenTUI/Ink/second frontend, daemon, database, Python provider supervisor, alternate registry, or second state writer was introduced.

## Result

Independent final scores: **29/29 >=9.0**, minimum **9.0 (D14)**. Full table and citations: `iter-9/scores.json`, `iter-9/reviewer-gate.md`.

The final eight proof gaps closed in iter-9:

| Dimension | Final | Closing evidence |
|---|---:|---|
| D03 filtered home | 9.2 | Exact empty state; latest-valid-score mtime order; numeric/client tie-break; one-slot cwd pin. |
| D04 identity | 9.2 | All four role speaking rails carry exact hue; body remains neutral. |
| D05 header | 9.2 | Middle-head live pulse observed as widget spans; compact omits heads. |
| D06 activity | 9.2 | Real PTY braille, mission, provider, elapsed, busy footer. |
| D07 compact | 9.2 | Live PTY 80→40→80, score slot, `+2`, actual `@Builder` prefix, restored heads. |
| D09 thinking/speech | 9.2 | Real empty-artifact silence window, then one Builder rail on first bytes. |
| D24 provider seam | 9.2 | Real Builder `prompt_export` + user prompt captured from provider argv before stdout. |
| D28 coverage | 9.3 | 73 native tests, 6 PTY rows, parity PASS, canonical visual 14/14. |

## Shipped behavior

- Locked canvas/field/rule/text/mute/You/four-role/ok/err tokens and glyphs in the cockpit only; neutral message bodies; markdown-lite turns.
- Header `▣─▣─▣ ProductTeam · {cwd} · {score}`, live middle-head pulse, and explicit `ProductTeam {score}` compact header.
- At most three filtered, recency-ordered scored home rows; honest empty copy; no full status prose in the transcript.
- Focusable/clickable role chips, idle `@Principal`, session-local typed `@Role`, role argv, role activity, and selected agent-card prompt export.
- Exact-session `workers.tsv` activity strip with braille/elapsed facts and 3/2/1+N caps; no `Thinking…` message; speaking turn starts only on bytes.
- Live registry palette, argv-only supported commands, unsupported reason+usage/no-spawn, chat-only session verbs, mute Command rails, markdown-lite streamed output.
- Structured sibling `ask.json` dock and atomic answer; exact three write confirmations with empty Cancel spawn log; labelled bordered evidence panel.
- Attached done/error cards; interrupt/failure/session toasts; idle/busy/dock/splash footers.
- TUI-owned angular splash with neutral idle, Principal→Analyst→Builder→Principal live glow, any-key skip, and composer/footer preservation.
- Non-TTY exit 2 with stderr remedy, empty stdout, and no escape bytes under `NO_COLOR`.

## Verification

| Check | Result | Evidence |
|---|---|---|
| Native pytest + snapshots | **73 passed** | `iter-9/pytest.txt` |
| Real PTY | **6 passed** | `iter-9/pty-test.txt`, `iter-9/pty-note.md` |
| CLI interface parity | **PASS 33/18/15/6** | `iter-9/cli-interface-parity.txt` |
| Canonical visual CLI | **14/14** | `iter-9/visual-cli.txt`; exit 1 only for the allowed pre-existing live-provider proof hole |
| Frozen inputs | **7/7 hashes OK** | `FREEZE-SHA.txt`, closeout `sha256sum -c` |
| Independent benchmark | **PASS; 29/29 >=9.0** | `iter-9/reviewer-gate.md`, `iter-9/scores.json` |

The first iter-9 full run exposed a PTY chronology race: the force-exit Ctrl+C could precede failed-card paint. The row now observes the first interrupt's failed card before issuing the second Ctrl+C. Targeted PTY and repeated full suite are green; product interrupt behavior remains unchanged.

## Preservation and scope

- `bin/productteam` remains the sole domain/judgment/workspace/provider/durable-state authority.
- `lib/tui/requirements.txt` remains Textual 8.2.8 / Rich 15.0.0; Python 3.12 runtime verified.
- Canonical CLI two-accent checks remain unchanged and passing.
- `spikes/shared/`, deleted spike trees, 0444 proxy history, prior cockpit evidence, and unrelated dirty files were not replaced.
- Final TUI diff: **4,142 insertions / 300 deletions across 9 files**, including SVG source and the expanded behavioral suite (`diff-summary.md`).

## Run history and residuals

`not-converged.md` is retained as the honest iter-5 stop artifact. The owner later authorized `extension.md`; it is superseded as the run's final outcome by this report and the iter-9 independent PASS.

Reviewer-listed residuals are optional 10-band opportunities only: live-PTY splash, live-PTY `/report`, live-PTY Critic speech/fallback prompt export, pulse/recency snapshots, and compact-busy provider text. They do not authorize iter-10 or reopen the 9.0 gate.
