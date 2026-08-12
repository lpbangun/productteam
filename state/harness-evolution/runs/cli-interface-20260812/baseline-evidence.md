# Baseline evidence — ProductTeam CLI interface (iter-1, pre-implementation)

Run: `state/harness-evolution/runs/cli-interface-20260812/`
Date: 2026-08-12 · Evaluator: Analyst (independent; Principal/Advisor did not score)
HEAD: `1ebb52f fix(harness): pool cite leak, specialist sed corruption, iter validation`
Contract: `CLI-BENCHMARK-CONTRACT.md` (frozen **v3**, contract `cli-interface-20260812-v3`) ·
SHA-256 `92f06ecd08e4e804e8c703af4a3af38519a7702ba2a72494fcdf9d596a6dc7f6`
(recorded in `FREEZE-SHA.txt`; verified identical at scoring time).
Revision history: v1 (`7804c3dd…`, rejected pre-build by Critic, archived
`evidence/contract-v1-rejected.md` + `evidence/freeze-sha-v1.txt`); v2
(`036ae8e8…`, rejected by CriticV2, archived `evidence/contract-v2-rejected.md`
+ `evidence/freeze-sha-v2.txt`, reconstruction not byte-exact per header);
v3 (current) is the owner-approved re-freeze fixing the CriticV2 blockers
(set-for-set registry membership, PTY 24-verb palette + per-unsupported
behavior, probe numbering 1–16). No production edit has begun, so the iter-1
baseline is still taken from the unmodified repository.
Scope: `bin/productteam`, `bin/consult`, `lib/*.sh`, `tests/*.sh`, `README.md`, `tests/cli-interface-parity.sh`, `state/` surfaces. No production edits, no formatters/linters; targeted read-only probes only; no provider scoring executed.

Companion artifact: `baseline-scores.json` (11 dimensions, integer scores, rationale, evidence paths; aligned with the frozen v3 rubric — a failing parity probe caps its dimension at 5 per contract Scoring protocol rule 3).

---

## 0. Dirty-worktree preservation (verified before and after probes)

`git status --short` before any probe:

```
?? state/engagements/onboarding-flight-control/runs/check-20260810T061017889894029/
?? state/engagements/onboarding-flight-control/runs/check-20260810T061159572636558/
?? state/harness-evolution/inspect-pack.json
```

After all probes, `git status --short` shows exactly those three untracked paths plus the new run directory:

```
?? state/engagements/onboarding-flight-control/runs/check-20260810T061017889894029/
?? state/engagements/onboarding-flight-control/runs/check-20260810T061159572636558/
?? state/harness-evolution/inspect-pack.json
?? state/harness-evolution/runs/cli-interface-20260812/
```

- The untracked `state/harness-evolution/inspect-pack.json` was **never written**: the `inspect` probe redirected output to `evidence/inspect-probe.json` in this run dir.
- One probe side-effect occurred and was **restored byte-exact**: the reachability probe `productteam harness-checks` (no iter arg) rewrote tracked `state/harness-evolution/runs/checks.json`; restored with `git checkout -- state/harness-evolution/runs/checks.json`; verified `git diff --stat` empty. The probe's rc=0 remains recorded in `evidence/exit-table.txt`.
- `state/.cli/` is gitignored (`.gitignore:3`) and holds only the 5-byte `first-run` marker.

## 1. Probe environment

- Non-TTY shell (stdin `/dev/null`, stdout captured) — all exit-table rows are non-interactive behavior.
- `NO_COLOR=1 CONSULT_NO_SPLASH=1` for probe runs; `CONSULT_STATE_ROOT=$(mktemp -d)` for state-root probes so the repo `.cli` was never touched by cold-start probes.
- Provider: `agent` detected as default; provider **never invoked** during baseline (no `bench run`, no `skill` on real targets, no `role invoke` with real provider).

## 2. Observed suite entrypoints

| Entrypoint | Role | Baseline observation | Archived evidence (pre-implementation) |
|---|---|---|---|
| `tests/consult-smoke.sh` | CLI smoke (help/status/org/memory/judge/bench/gh/runtime/unknown/chat-refusal + 10 sub-smokes) | not re-executed (scope stop) | `state/harness-evolution/runs/iter-6/harness-cli-final/evidence/smoke.txt` (full pass) |
| `tests/visual-cli.sh` | 14-id visual contract suite | not re-executed (scope stop) | `state/harness-evolution/runs/iter-7/visual-checks-final.json` — `passed=14, failed=0, skipped=0`, live_provider_proof pass |
| `lib/harness-cli-checks.sh` | 49-check harness-cli-v1 runner | self-routes when dispatched via `productteam checks harness-cli` (recursion guard) | `state/harness-evolution/runs/iter-6/harness-cli-final/checks.json` — `49/49 passed, overall 9.5, kind full` (mirrored `state/engagements/harness-cli/runs/iter-1/checks.json`) |
| `lib/harness-checks.sh` (`productteam harness-checks`) | harness-apc objective suite + secrets scan | **observed rc=0** (evidence/exit-table.txt) | `state/harness-evolution/runs/checks.json` (tracked; restored after probe) |
| `lib/run-checks.sh` | ofc-v1 client deterministic suite | not run (builds/modifies sibling repos — smoke sets `CONSULT_SMOKE_SKIP_CLIENT=1` for the same reason) | prior ofc runs under `state/engagements/onboarding-flight-control/runs/` |
| `tests/cli-interface-parity.sh` | frozen-contract parity probe v3 (hash, help, checks, workspace guard, README, chat + slash forwarding, quoted argv, injection-inert, JSON, status/help --json, onboarding syntax, bench/run honesty, ANSI, argv) | **observed: 14 FAIL probes (= frozen defects D1–D7), all other probes PASS** (checks rc=2, /score+/bench --iter forwarding, 5 README omissions, stale onboarding syntax, quoted /provider, help/status --json absent, bench/run jq rc=5; PTY 24-verb palette) — `evidence/parity-test-baseline-v3.txt` | FAIL rows = frozen baseline defects D1–D7 |
| 10 sub-smokes | workspace, judgment-gate, escalation, role-envelope (real provider), agent-cards, style-memory, experience-pool, direction-path, open-baseline, run-loop | invoked by consult-smoke only | archived consult-smoke pass; all PASS in smoke-baseline.txt |

## 3. Parse / static integrity

```
bash -n bin/productteam  → OK
bash -n bin/consult      → OK
bash -n lib/*.sh (20 files) → all OK
bash -n tests/*.sh (12 files) → all OK
bash -n scripts/inspect-cli.sh → OK
```

## 4. Reachability + exit table (evidence/exit-table.txt, 66 rows)

All 30 help-listed commands reached their handlers. Representative rows:

```
default (no args)        rc=0   | Product Consulting Harness
help                     rc=0   | productteam — Product Consulting Harness
status                   rc=0   | Product Consulting Harness
org / memory / agents / runtime / splash / splash --frames   rc=0
onboarding (preview) rc=0   ·  onboarding --yes rc=0
judge harness-evolution rc=0   ·  gate harness-evolution status rc=0
direction list [--json] rc=0   ·  escalation status rc=0
inspect he (to run dir) rc=0   | Inspect pack regenerated: …/inspect-probe.json
role status rc=0  ·  card list [--json] rc=0  ·  card show Principal rc=0
style show rc=0  ·  project-memory show he rc=0  ·  pool list [--json] rc=0
report harness-evolution rc=0  ·  workspace status he rc=0  ·  gh preflight rc=0
harness-checks (no iter) rc=0
```

Invalid/missing-arg refusals (all rc=1, all with usage or cause+remedy):

```
judge (no client) / gate (no client) / role (no client) / workspace (no client)
gh (no sub) / skill (no args) / baseline (no client) / score (no client)
bench run (no --iter) / run-loop (no flags) / open (no args) / checks (no client)
agents --bogus / splash --bogus / onboarding --bogus / card list --bogus
pool list --bogus / style --bogus / direction --bogus / escalation bad action
run-loop bad --max-hours / open invalid slug / role invoke bad role / judge set bad mode
runtime --check bad prov (rc=1, honest) / gh merge no-auth (rc=1, honest)
unknown command (rc=1, 'cause: not in the command table. Remedy: productteam help')
chat (non-TTY refused rc=1, 'chat needs a TTY. Remedy: …')
```

`bin/consult help` rc=0, `bin/consult status` rc=0 (compat shim verified).

### CONFIRMED DEFECT — bench/run exit 5 on the reference client

```
$ bin/productteam bench harness-evolution        → rc=5
  LATEST — iter-7
jq: error (at …/state/harness-evolution/runs/iter-7/scores.json:26): null (null) has no keys
$ bin/productteam run harness-evolution 7        → rc=5
  harness-evolution — iter-7
jq: error (at …/iter-7/scores.json:26): null (null) has no keys
```

Root cause: `latest_run` (bin/productteam:84-86) selects `runs/iter-7`; that directory's `scores.json` is a **convergence summary shape** (`ts/iter/kind/visual/harness/converged`, `"scores": null`, `"overall": null`) rather than the contract scores shape. `cmd_bench`/`cmd_run_detail` (bin/productteam:1214-1290) then run `.scores | to_entries[] | … .score` unguarded → jq error → process exits with jq's exit code 5 (invalid-input class). No fallback to the last contract-shaped scores file (iter-6) and no die() with a remedy. This breaks the primary score-reading commands on the flagship client. (Exit 5 is jq's own code, leaking raw jq internals to the user.)

## 5. Chat reachability / classification

- `productteam chat` in help, README, dispatch; `cmd_chat` (lib/repl.sh:428-441) guards `[[ ! -t 0 || ! -t 1 ]]` → die with remedy.
- **Rejected assumption**: non-TTY refusal is a *defect*. It is intended TTY-gated design, asserted by `tests/consult-smoke.sh:48-49` (`if chat </dev/null … ok 'chat refuses non-TTY'`).
- Slash classification: canonical `repl_slash_verbs` palette (lib/repl.sh:26-29) drives `/help` AND live readline hints (`_repl_hint_wire`), `repl_run_slash` (lib/repl.sh:331-426) routes verbs (help/status/agents/runtime/onboarding/splash/judge/score/checks/bench/report/run/memory/org/gh/skill/smoke/harness-checks/workers/provider/clear/export/exit/quit); unknown slash → `unknown /x — /help`.
- Turn separators + plain-markdown transcript; `/export` writes `$STATE_ROOT/sessions/chat-<ts>.md` and prints the path.
- Prior archived visual suite (14/14) covers chat role chrome, live card, spinner, SIGINT, slash hints via PTY.

## 6. Argument / usage parity

- 20+ probes confirm usage strings match parser behavior (section 4 rows). Validators: `--iter` non-negative integer (bin/productteam:121-135), `--allow-dirty` non-empty reason, `run-loop --max-hours` numeric + required pair, `open` slug `^[a-z0-9][a-z0-9_-]*$` + absolute git repo, `role` name whitelist, `judge set` mode whitelist, `gh` subcommand table, `skill` name whitelist.
- Confirmed gaps:
  1. bench/run raw jq error instead of a usage/honest failure (see §4).
  2. `pool list --bogus` → `unknown pool list option: --bogus` — missing the standard `error:` prefix used by `die()` everywhere else (bin/productteam:690-700).
  3. README body uses `bin/consult gate/…`, `bin/consult role/…`, `bin/consult escalation/…`, `bin/consult score/…` (18 `bin/consult` mentions) while help and quickstart use `bin/productteam`; the shim (`bin/consult` → `exec productteam "$@"`) is documented, so behavior is intact, but the documented surface is inconsistent.

## 7. Help / README / onboarding parity

- help names all **32 frozen top-level commands** (parity-verified PASS): `agents baseline bench card chat checks direction escalation gate gh harness-checks help inspect judge memory onboarding open org pool project-memory report role run run-loop runtime score skill smoke splash status style workspace` (plus `worktree` alias → workspace, `-h|--help` → help). No dispatch command is missing from help (rejected assumption).
- README quickstart covers 24/30; **help-only commands absent from README**: `direction`, `pool`, `project-memory`, `run-loop`, `style`. (Prior archived check `core-features-reachable` verified only the 15 core features in both; these 5 are beyond that set.)
- Onboarding (lib/onboarding.sh:14-79): 5 explicit steps + "Next: productteam bench <client>"; preview vs `--yes` (`--yes` writes `$STATE_ROOT/config` line `provider=<bin>` and `first-run` marker, idempotent); matches README "First run" section. `onboarding --yes` rc=0 with fresh state root (cold start).

## 8. argv safety

- Every malformed argv probe (section 4) produced rc=1, a one-line actionable message on stderr, no stack trace, no partial file writes. `set -euo pipefail` in `bin/productteam`; unknown commands name cause + remedy.
- `-h`/`--help` handled at dispatch (bin/productteam:1337-1344).
- Single confirmed exception: bench/run exit-5 raw jq leak (§4).
- No `--` end-of-options convention implemented — minor, not scored down beyond §4/§6.

## 9. Frontend machine-readable boundary

Machine-surface validation (all non-TTY, `jq -e .` parse + ANSI byte scan):

| Command | rc | valid JSON | ANSI bytes |
|---|---|---|---|
| `agents --json` | 0 | yes | none |
| `card list --json` | 0 | yes | none |
| `direction harness-evolution list --json` | 0 | yes | none |
| `escalation harness-evolution status` | 0 | yes | none |
| `role harness-evolution status` | 0 | yes | none |
| `gate harness-evolution status` | 0 | yes | none |
| `workspace harness-evolution status` | 0 | yes | none |
| `pool list --json` | 0 | yes | none |
| `project-memory show harness-evolution --json` | 0 | yes | none |
| `inspect harness-evolution evidence/inspect-probe.json` | 0 | yes | none |

Human-default commands print prose unless `--json` (by design). Confirmed defect: bench/run violate the boundary on non-contract scores shape — raw `jq: error` text and exit 5 (§4).

## 10. Non-TTY / redirected / NO_COLOR / exit behavior

- Theme guard `[[ -t 1 && -z "${NO_COLOR:-}" ]]` (bin/productteam:22-28) — ANSI literals only ever emitted on a real TTY without NO_COLOR.
- Byte-level check, piped (no NO_COLOR): `help`, `status`, `org`, `splash`, `agents` all **clean** (zero `\e[` sequences). With NO_COLOR on a pipe: clean. No `CLR`/spinner in redirected output; splash is bounded non-interactive (rc=0, prints frames; `CONSULT_NO_SPLASH=1` skips).
- Exit codes stable across the 66-row table; `die()` writes to stderr; machine payloads exit 0.

## 11. Ctrl+C child cleanup / partial artifacts

- `repl_interrupt_cleanup` (lib/repl.sh:207-226): `kill -TERM -- "-$pid"` on the provider's process group (grandchildren cannot outlive the turn), reaps with `wait`, marks the worker `failed` via `activity_update`, then preserves the partial artifact: prints `Ctrl+C — partial output left on disk (N bytes): <path>` (or honest empty-artifact wording).
- Runtime assertion exists: `tests/visual-cli.sh` `honest-partial-output` probe (lines 245-362) drives real SIGINT to the foreground pty group and asserts: artifact bytes preserved at printed path, worker row `failed`, provider pid + child pid both dead (`! ps -p`), REPL still alive, clean `/exit`. Archived pass: `iter-7/visual-checks-final.json` 14/14. Not re-executed in this baseline (scope stop).
- `run-loop` kill/TERM: `progress.json` → `status=paused, stop_reason=killed-resume-pending`; `--resume` continues from the recorded iter (`tests/run-loop-smoke.sh`, archived pass via consult-smoke).
- `chat` itself is TTY-only, so SIGINT handling is exercised only via pty in visual-cli.

## 12. Visual / smoke contracts

- Contract sources: `state/harness-evolution/visual-contract.json` (14 ids: role-chrome, worker-strip, live-loading-card, two-accent-language, judgment-badges, splash-animation, slash-palette-hints, honest-partial-output, transcript-export, …) and `state/engagements/harness-cli/checks/CHECK-CATALOG.md` (49 ids, 9 dimensions).
- ANSI single-source: accent literals only under the `bin/productteam` guard (`G`/`RD` = `\e[32m`/`\e[31m`); badge glyphs/role chrome in `lib/theme.sh`; no escape literals in other lib files (matches archived check `cli-theme-single-source`).
- Archived full passes (pre-implementation, both mirrored in two locations):
  - `state/harness-evolution/runs/iter-7/visual-checks-final.json`: `passed=14, failed=0, skipped=0`, `live_provider_proof=pass`, `converged=true`.
  - `state/harness-evolution/runs/iter-6/harness-cli-final/checks.json` and `state/engagements/harness-cli/runs/iter-1/checks.json`: `49/49 passed, overall 9.5, kind full`.
  - `state/harness-evolution/runs/iter-6/harness-cli-final/evidence/smoke.txt` (smoke PASS rows), `command-exit-table.txt`, `onboarding-cold.txt` (cold transcript + next action).
- Baseline re-execution was stopped by scope; scores for this dimension rest on archived suite passes + static verification, and are marked accordingly.

## 13. Dependencies / cold start

- Cold start (fresh `CONSULT_STATE_ROOT=$(mktemp -d)`): `onboarding --yes` rc=0 (wrote `config` + `first-run`, idempotent on re-run), `status` rc=0 (writes first-run marker only), `splash` rc=0, `agents` rc=0 (detection, ~3s).
- No hidden env requirements: README "Environment variables" table documents every variable; `CONSULT_PROVIDER` optional (default = first installed catalog agent); `runtime --check` with `CONSULT_PROVIDER=/nonexistent/…` → rc=1, clear message (honest failure, not opaque).
- Dependency scan of `bin/productteam` + `lib/*.sh`: `printf, jq, echo, grep, read, test, date, head, basename, cat, timeout, sed, tr, sort, awk, python3, git, dirname, gh, find, cut, tail, wc, seq, mktemp, kill, sha256sum, wait, sleep, realpath, ps, uniq, stat, readlink, md5sum` — all within the documented allowlist (`bash, awk, sed, grep, find, sort, jq, python3, git, gh` + coreutils + timeout). `node`/`bun` references exist only in client-facing check runners (`lib/run-checks.sh` probes the *client's* `package.json`) and comments (splash node-glyph docs), not in CLI runtime paths.

## 14. Metadata simplicity / deletion

- No daemon/server/database (help Non-goals; README); state is plain files under `state/engagements/<client>/`, `state/harness-evolution/`, `state/agents/`, `state/style/`, `state/experience-pool/`.
- CLI's own state: `state/.cli/` gitignored, single 5-byte `first-run` marker; onboarding writes one `config` line; chat transcripts under `$STATE_ROOT/sessions/`.
- Atomic tmp+rename writes observed in code: workspace snapshots, judgment files, role envelopes, escalation/pause files.
- Deletion paths: `workspace <client> remove` (clean worktree only), `direction <client> clear --i-am-owner`, `style rewrite` (owner-gated).
- `inspect` regenerates the pack purely from files with explicit `missing: true` objects + `missing` array — never invents state (evidence/inspect-probe.json).

## 15. Confirmed defects vs rejected assumptions (summary, v3)

Frozen v3 defects D1–D7 (all reproduced by the parity test; evidence/parity-test-baseline-v3.txt, 14 FAIL rows; identical defect set to v2 — v3 fixes only probe mechanics: set-for-set registry membership, PTY 24-verb palette, probe numbering 1–16):

1. **D1 (reachability/deps)** — `checks onboarding-flight-control` exits 2 (`workspace-metadata-mismatch`): tracked `workspace.json` pins a stale worktree path; `workspace_ensure` hard-fails, no remedy, no non-destructive recovery (evidence/checks-baseline.txt, lib/workspace.sh:66-68). Non-destructive workspace guard PASSes.
2. **D2 (chat/arg-usage)** — slash forwarding drops required flags: `/score <client> --iter <n>` and `/bench <client> run --iter <n>` die with `scoring requires --iter …` instead of reaching the Analyst-stamp refusal; CLI controls prove the honest downstream is `scores invalid: missing Analyst stamp …`.
3. **D3 (help-readme)** — README omits 5 help-listed commands: direction, pool, project-memory, run-loop, style (help 32 vs README 27) (evidence/readme-parity-diff.txt).
4. **D4 (help-readme)** — `onboarding --yes` step 4 prints stale `productteam score <client>`; current syntax requires `--iter <n>` (lib/onboarding.sh:51, evidence/onboarding-stale-syntax.txt).
5. **D5 (argv-safety)** — quoted slash argv mangled: `/provider "codex"` treats quotes literally; must parse as one value without `eval` (embedded `$(…)`/`;` is already inert).
6. **D6 (frontend boundary)** — `help --json` and `status --json` do not exist (emit prose, exit 0); no command-registry metadata, no engagement-list JSON.
7. **D7 (non-tty/exit)** — `bench harness-evolution` and `run harness-evolution 7` exit 5 with a raw `jq: error` traceback on summary-shaped `runs/iter-7/scores.json` (`"scores": null`); no honest message, no fallback (evidence/bench-harness-evolution.txt, evidence/run-harness-evolution-7.txt).

Out of scope (v3): the committed `state/style/` duplicate entry (v1 D5) is durable org memory — evidence retained at evidence/style-dup-baseline.txt; `state/style/*` must not be edited to satisfy any probe (critical failure #6).

Analyst additional findings (cosmetic, not frozen): `pool list --bogus` message lacks the `error:` prefix convention; README names the CLI inconsistently (18× `bin/consult` in body vs `productteam`; documented shim).

Rejected assumptions (parity PASS rows + Analyst probes):
- chat non-TTY refusal = defect → intended, parity-asserted with remedy.
- Unsupported slash commands misroute → all 14 classify as `unknown /X — /help`.
- Slash lines execute embedded text → `$(…)`/`;` inert.
- Existing JSON surfaces leak ANSI / emit non-JSON → all parse, byte-clean.
- NO_COLOR/redirect broken → parity PASS on all four ANSI criteria.
- CLI multi-word argv truncated / empty argv accepted → round-trip byte-identical; empty rejected.
- Hidden runtime deps (node/bun) → only in client-check runners/comments.
- help missing dispatch commands → all 32 frozen top-level commands listed.
- Probes dirtied protected untracked paths → byte-identical before/after; only side-effect (runs/checks.json) restored exactly.

## 16. Score reconciliation with the frozen v3 contract (parity-probe outcomes)

Frozen-contract scoring protocol rule 3: a failing parity probe caps its dimension at 5 unless an environment-only cause is proven. v3 parity run: **14 FAIL probes (= D1–D7), all other probes PASS** (evidence/parity-test-baseline-v3.txt). Scores are unchanged from the v2 reconciliation (same defect set, same rubrics; v3 changed only probe mechanics). Final iter-1 scores (integers):

| Dimension | Score | Basis |
|---|---|---|
| reachability | 5 | parity FAIL (checks rc=2, D1) |
| chat-reachability-classification | 5 | parity FAIL (slash --iter forwarding, D2) |
| argument-usage-parity | 5 | parity FAIL via shared D2 slash-forwarding probes (dimension 3 verification cites parity 6–8) |
| help-readme-onboarding-parity | 5 | parity FAIL (README omits 5, D3; stale onboarding syntax, D4) |
| argv-safety | 5 | parity FAIL (quoted slash argv mangled, D5) |
| frontend-machine-boundary | 5 | parity FAIL (help --json + status --json absent, D6) |
| non-tty-redirect-nocolor-exit | 5 | parity FAIL (raw jq traceback exit 5, D7); all ANSI criteria PASS |
| ctrl-c-child-cleanup-partial-artifacts | 7 | code-verified + archived visual 14/14; not re-executed |
| visual-smoke-contracts | 6 | smoke exit 1, single FAIL from state drift (D1 root cause); rest green |
| dependencies-cold-start | 5 | tracked state pins machine paths; cold-checkout command fails, no recovery (D1 root cause) |
| metadata-simplicity-deletion | 8 | no v3 probe failure; style dup out of scope; CLI metadata minimal |

**Overall: 5.5** (mean of 11 integers, one decimal; 61/11). Convergence for repair iterations: every dimension ≥ 8.0 with the parity test green. Repair backlog = frozen defects D1–D7; the v3 baseline mean is below the v1 figure (6.6) because v2 added four previously-missed frozen defects and moved D7 into dimension 7's ≤5 band — v3 retains that defect set.
