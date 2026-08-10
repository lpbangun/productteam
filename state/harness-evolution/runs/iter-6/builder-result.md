# Builder result — iter-6 Build 1 closeout

## Edit made

Added one concise paragraph to the workspace seam in `ARCHITECTURE.md`
(under "Scoring seam", immediately after the existing `ensure |
status|remove` paragraph):

> `ensure` reuses the existing pinned detached checkout and does not
> reset to newer source HEAD; a caller that needs a fresh tree runs
> `remove` then `ensure`. If the checkout directory is removed
> out-of-band while source still registers the worktree, recovery is
> `git worktree prune` in the source repo, then `ensure`.

This closes the Critic nit that the workspace seam did not document
reuse-without-refresh or orphan registration repair. README already
covers the same ground; ARCHITECTURE now matches.

## Ownership of the core implementation

The Build 1 core — `lib/workspace.sh`, `bin/consult` routing, the
`tests/workspace-smoke.sh` harness checks, and the wider README
content — was implemented by Principal, not by a Builder. Two
delegated Builder attempts stalled during research and were cancelled
before producing any edits. Principal implemented the accepted core
directly rather than hide the failure. The role-loop review in
`report.md` and `lessons.md` records this honestly, and the
`principal-decision.md` file carries the binding scope decision.

This Builder closeout is intentionally narrowly bounded: it makes
only the one ARCHITECTURE paragraph above and writes this result file.
No other files were edited, no commands were run, no tests were
executed.

## Verification

Verification is owned by Advisor artifacts and is not rerun here:

- `evidence/advisor-verdict.json` — five-pointer PASS pack.
- `evidence/acceptance-smoke.txt` — `bin/consult smoke` full run.
- `evidence/acceptance-harness-checks.txt` — `bin/consult harness-checks`
  27/27 transcript.
- `critic-verdict.md` — `ACCEPT-WITH-NITS`, no blockers; this paragraph
  addresses item 2 of the follow-up list.
- `report.md` — convergence statement, org self-review, and stop
  signal for Build 1.

The architecture change is doc-only and does not require fresh
verification; the existing Advisor pack already covers the workspace
seam behavior the paragraph describes.
