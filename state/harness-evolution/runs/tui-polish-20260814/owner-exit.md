# Owner exit — Principal close

Date: 2026-08-14  
Session: Kai (Principal) received `z/exit` and stopped.

## Decision

Stop the polish loop. Do not spawn a Worker or Reviewer. Do not write
`final-report.md`. Do not self-score. Do not start iter-7.

Last **independently scored** close remains iter-5:

- Verdict: FAIL — 8/29 dimensions ≥ 9.0
- Evidence: `iter-5/reviewer-gate.md`, `iter-5/scores.json`, `not-converged.md`

Keep the shipped 2026-08-13 cockpit, `lib/tui/`, and the `tui` registry
row. Uncommitted polish work stays in the worktree; nothing is reverted
and nothing is committed.

## Iter-6 status (incomplete — void as a scored iteration)

Owner had authorized iter-6…iter-10 in `extension.md`. Iter-6 was in
flight when exit arrived.

Present:

- Bound Critic contract: `iter-6/debate.md` (ask + confirm dock machine)
- Native pytest recording: `iter-6/pytest.txt` (45 passed)
- PTY recording: `iter-6/pty-test.txt` (4 passed)
- App/tests on disk include the ask.json consumer, confirm intercepts,
  native ask/confirm tests, and `test_pty_confirm_cancel_keeps_composer`

Absent (so the iteration cannot close):

- `iter-6/{notes.md,pty-note.md,cli-interface-parity.txt,visual-cli.txt}`
- Independent Reviewer `iter-6/scores.json` and `iter-6/reviewer-gate.md`

Constitution: no evidence / no Critic verdict → the iteration is void.
A future Principal must re-run the freeze table and spawn Reviewer
before claiming D08/D13 lift. Do not treat the on-disk tests as scores.

## Frozen contract

Unchanged. `FREEZE-SHA.txt` first line:

`018c2d0c406e80ffa5127749b5bf3e122b679f993e88020d24901afd939b7bca`

## Routing note

`z/exit` is not the cockpit `/exit` verb. Input that does not start with
`/` is a Principal provider turn. `/exit` / `/quit` remain chat-only and
leave the TUI with rc 0.

## Resume (owner must re-authorize)

1. Copy the bound slice in `iter-6/debate.md` (not a new proposal).
2. Principal runs the freeze test table; spawn one Reviewer.
3. Continue the `extension-blockers.md` map (evidence/Command rails →
   splash → PTY proof) only if the owner still wants iter-7…iter-10.
