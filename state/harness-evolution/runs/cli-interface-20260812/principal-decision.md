# Principal decision after pre-build debate

## Accepted rebuttals

- Reject Advisor v1 as build-ready. It omitted required slash signature, quoted-argv, registry-derived metadata, and null-score behavior probes.
- Re-freeze as v2 before any production edit. This is not a mid-build benchmark rewrite: no production implementation has begun, and the user’s mission explicitly requires these dimensions in the pre-build freeze.
- Keep the registry descriptive and thin; no plugin host or `eval`.
- Do not edit durable style memory to satisfy D5. Remove that mis-aimed probe from the CLI contract.
- Workspace mismatch handling may only recreate metadata when the recorded workspace path is absent; it must never delete, relocate, reset, or overwrite an existing/dirty/foreign worktree.
- Existing JSON/file seams remain authoritative. New output is limited to `help --json` command metadata and `status --json` engagement summaries because the mission explicitly requires frontend access to available commands and engagement selection inputs.

## Overruled rebuttals

- **Ink/OpenTUI escalation:** overruled. The owner explicitly required bounded disposable prototypes for both candidates in this goal. Prototype work is authorized; retention still requires every evidence gate and Critic acceptance.
- **No new command metadata/status output:** narrowed rather than cut. The mission explicitly requires a stable frontend boundary for available commands and engagement list/current selection. `help --json` and `status --json` avoid a new command, daemon, or state authority.

## Accepted build list after v2 freeze

1. Thin shared registry driving `help`, `help --json`, dispatch validation/routing, slash palette, slash routing, and explicit unsupported reasons.
2. Safe slash argv parser without `eval`; exact forwarding for `/score … --iter` and `/bench … run --iter`; PTY proof with quoted spaces.
3. `status --json` plus documentation of existing `inspect`, activity TSV, gate/workspace/role/agents JSON and authoritative files.
4. Stale onboarding score syntax, README/help parity, and honest `bench`/`run` handling of summary-shaped scores.
5. Non-destructive stale-workspace metadata recovery only when the recorded path is absent.
6. Disposable Ink/OpenTUI evidence spikes after the repaired boundary passes.
