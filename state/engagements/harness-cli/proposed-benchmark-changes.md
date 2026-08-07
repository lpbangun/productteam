# proposed-benchmark-changes.md — harness-cli

`harness-cli-v1` is **FROZEN** (2026-08-07). `BENCHMARK-CONTRACT.md`,
`contract.json`, and `checks/CHECK-CATALOG.md` must not be edited during
an active iteration (`CONSTITUTION.md` §4; critical failure #2).

This file is the **only** place to record rubric change proposals. Nothing
written here applies to the current engagement. Accepted proposals require
owner approval, a new contract id, and apply only to engagements opened
after the successor contract is frozen.

## Proposals

### 2026-08-07 · Test Engineer · `no-new-runtime-deps`
Observation:  The frozen allowlist is `bash awk sed grep find sort jq python3
              git gh`. Taken literally it excludes coreutils the CLI already
              uses everywhere — `cat head tail ls basename dirname date seq
              mktemp tr wc diff sha256sum timeout rm cp mkdir` — so the check
              could never pass, and it also excludes `npm`, which
              `lib/run-checks.sh:152` and `lib/github.sh:123` invoke only
              against a *client* repo's own toolchain.
Proposal:     State in the allowlist that `bash` means the shell environment
              (builtins + POSIX/coreutils utilities), and add a `client
              toolchain` category for commands invoked solely from client-facing
              check/validation paths.
Why not now:  It would move `developer-experience`. The runner implements this
              reading today and reports both sets explicitly in the check detail
              (`coreutils/POSIX baseline treated as bash …`, `client toolchain
              confined to run-checks/github …`) so the Critic can audit exactly
              what was excluded rather than trusting a silent allowance.

### 2026-08-07 · Test Engineer · `docs-cli-not-tui`
Observation:  `rg -in '\bTUI\b'` matches the worktree path itself
              (`fix-new-user-tui`) and the git branch (`Fix/New-User-TUI`).
              Those tokens appear in `BENCHMARK-CONTRACT.md:18`,
              `CHECK-CATALOG.md:13`, and `engagement.md:6,8` — all frozen or
              factual — on lines that carry no negation, so a literal reading
              makes the check unsatisfiable without renaming the worktree.
Proposal:     Scope the pattern to the standalone word, excluding path and
              branch tokens, or make the negation rule per-file rather than
              per-line for frozen files.
Why not now:  It would move `documentation`. The runner exempts only hits whose
              matched token is `fix-new-user-tui` / `Fix/New-User-TUI` and says
              so in the check detail; every other engagement-dir mention must
              still negate, and the product path set is still zero-tolerance.

### 2026-08-07 · Test Engineer · `CHECK-CATALOG.md` gate count
Observation:  The catalog's dimension→check index totals the gates as **16**.
              Summing the per-dimension gate lists in `contract.json` gives
              **18** (2+2+2+2+2+3+2+2+1).
Proposal:     Correct the index row to 18 in the successor catalog.
Why not now:  Both files are frozen and the discrepancy is cosmetic — the band
              table is evaluated per dimension, never against a global gate
              count. The runner reads gates from `contract.json`.

### 2026-08-07 · Test Engineer · runner skip encoding
Observation:  `CHECK-CATALOG.md` §Runner contract requires a skipped LIVE check
              to be recorded `fail` with detail `skipped`; the Principal's brief
              asked for `status: "skip"`.
Proposal:     Allow `status: "skip"` explicitly, since band scoring treats any
              non-`pass` as a failure either way.
Why not now:  The frozen catalog wins. The runner records `status: "fail"`,
              `detail: "skipped (CONSULT_SKIP_LIVE=1) …"`, plus `"skipped": true`
              on the entry and a top-level `skipped` count, so a skip is both
              contract-conformant and separately countable.

Format for each entry:

```
### <date> · <proposer role> · <check id or dimension>
Observation:  what the current rubric measures badly, with a path or check output.
Proposal:     the smallest rubric change that fixes it.
Why not now:  which frozen dimension it would move, i.e. why it is a goalpost move.
```
