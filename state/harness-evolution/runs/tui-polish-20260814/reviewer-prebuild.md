# ACCEPT-FOR-FREEZE

Reviewer: fresh-context Freeze Critic (read-only prebuild)
Date: 2026-08-14
Subject: `state/harness-evolution/runs/tui-polish-20260814/frozen-benchmark.md`
Authority: `state/harness-evolution/runs/tui-polish-20260814/GOAL-LOOP.md`
Visual source: `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html`
This is contract acceptance only. Implementation is not scored.

## Review

- Correct: The freeze transcribes the GOAL locked contract without weakening, omitting, or contradicting a mandatory requirement or cut. D01–D29 are independently scorable from named tests, snapshots, PTY notes, argv traces, and file seams. Fresh dry-run evidence targets the real executable, records mode `0o775`, uses argv arrays with `shell=false`, applies a whole-token deny list, and allows `agents --json` at rc 0. Live registry remains 33/18/15/6; `tui` is unsupported with a non-empty reason.
- Blocker: none
- Note: Freeze §5:185–195 also asks the prebuild dry-run folder to include a TUI-level unsupported no-spawn and a role-targeted `provider_turn.sh` path. Those are not GOAL freeze-critic gates (`GOAL-LOOP.md:231`) and cannot be shown by spawning `bin/productteam`. They remain mandatory implementation scores (D11, D18, D22, D24). Not a GOAL weakening.

## 1. GOAL contract vs freeze (no weakening / omission / untestable score)

| GOAL lock | Freeze | Result |
|---|---|---|
| Layout: header / transcript `1fr` / activity-while-live / chips / dock-above-composer / composer / footer; overlays never cover composer; close restores focus (`GOAL-LOOP.md:99–103`) | `frozen-benchmark.md:21–30` | kept |
| Cockpit tokens + glyphs + no cyan/extra hue + Bash two-accent + `NO_COLOR` (`GOAL-LOOP.md:105–126`) | `frozen-benchmark.md:72–91` | exact hex/glyphs kept |
| Q1–Q6, thinking vs speech, R1–R8, Target, Defaults (`GOAL-LOOP.md:128–165`; HTML contract rows `locked/index.html:150–167`) | `frozen-benchmark.md:35–163, 93–163` | kept; Q6 schema added at §6:197–236 (testable, not weaker) |
| Backend seams, argv-only, real `bin/productteam`, whole-token deny, `agents --json` allowed, no 0444 proxy (`GOAL-LOOP.md:147–167`) | `frozen-benchmark.md:165–195` | kept |
| Test table including 33/18/15/6, visual-cli 14/14 + live-provider exception, SIGWINCH 80→40→80, isolate per-invocation deltas (`GOAL-LOOP.md:169–191`) | `frozen-benchmark.md:238–256` | kept; confirm/evidence rows extended, not reduced |
| Cuts (`GOAL-LOOP.md:218–229`) and forbidden (`GOAL-LOOP.md:264–278`) | `frozen-benchmark.md:354–385` | kept |
| Polish failure retains 2026-08-13 cockpit; no delete of `lib/tui/` or `tui` row; stop at iter-5 (`GOAL-LOOP.md:33, 253–254, 300`) | `frozen-benchmark.md:14, 296–305, 388–397` | kept |
| Mandatory dims ≥9.0, no compensating average (`GOAL-LOOP.md:216, 251, 300`) | D01–D29 at `frozen-benchmark.md:259–294` | every GOAL lock maps to a cited dim; none are intent-only |

Locked HTML picture matches the freeze on idle home, You/role rails, activity-strip thinking (not a fake transcript turn), docks above composer, compact `ProductTeam {score}`, and splash cycle Principal → Analyst → Builder → Principal (`locked/index.html:277–314, 387–409, 542–557, 164`; freeze `§2–§4`). HTML contract Q4 wording “live chip” (`locked/index.html:154`) is superseded by GOAL Q4 and the HTML thinking frame, both of which place the braille spinner on the activity line; the freeze follows GOAL (`frozen-benchmark.md:107–109`).

## 2. Fresh argv dry-run

Evidence:

- `state/harness-evolution/runs/tui-polish-20260814/argv-dry-run/argv-dry-run.json`
- `state/harness-evolution/runs/tui-polish-20260814/argv-dry-run/trace.jsonl`

| Check | Record |
|---|---|
| Real CLI, not a proxy | `argv-dry-run.json:2` `cli` = `/home/logani/.herdr/worktrees/Product Consulting Harness/exp-tui-migration/bin/productteam`; every `trace.jsonl` `exec` matches that path |
| Executable mode, not 0444 | `argv-dry-run.json:3–4` `mode_oct` `0o775`, `executable` true; live `stat` of the same path is `0o775` |
| Argv arrays, no shell | `argv-dry-run.json:5` `shell` false; 24 results are argv arrays only; no `/bin/sh`, `/bin/bash`, `-c`, or `eval` in any argv |
| Whole-token deny | `argv-dry-run.json:6–14` policy + `forbidden_tokens` = `/bin/bash`, `/bin/sh`, `eval`, `sqlite`, `sqlite3`; all 24 `token_ok` true; zero forbidden-token hits |
| `agents --json` allowed, rc 0 | `argv-dry-run.json:49–55`; `trace.jsonl:3` argv `["agents","--json"]`, `token_note` “allowed required seam agents --json”, `rc` 0 |
| Palette/help | `argv-dry-run.json:16–23` / `trace.jsonl:1` `["help","--json"]` rc 0; stdout sha256 `d9d43afb202e326ce438ccc7253bc34b4ba5e5f6a9790c332c0ecd22a7e0fb98` matches a live re-run of the same argv |

## 3. Live registry 33/18/15/6 and unsupported `tui`

`inspect.md:22–23` already recorded contract `cli-interface-20260812-v3`, 33/18/15/6, and a non-empty TTY/nesting reason for `tui`.

Live `productteam help --json` (same stdout hash as the dry-run) confirms:

- 33 commands
- 18 `chat_supported=true`
- 15 `chat_supported=false` (each with `chat_reason`)
- 6 chat-only REPL verbs frozen in `tests/cli-interface-parity.sh:64` as `provider workers clear export exit quit` (not CLI names; freeze `§5` Chat-only and `§7` parity row keep this split)

`tui` registry row:

```json
{"name":"tui","usage":"productteam tui","chat_supported":false,
 "chat_reason":"safety/usefulness: optional presentation client; TTY required; must not nest inside chat"}
```

Non-TTY invocation in the dry-run is consistent: `argv-dry-run.json:375–387` / `trace.jsonl:24` argv `["tui"]`, rc 2, empty stdout, stderr `productteam tui requires an interactive TTY` (freeze Non-TTY seam `frozen-benchmark.md:183`).

## Freeze verdict

**ACCEPT-FOR-FREEZE**

Hashing and implementation may begin. Principal should write `FREEZE-SHA.txt` from `frozen-benchmark.md:338–350` and must not edit the rubric after hash. Iteration scoring of D01–D29 remains pending.
