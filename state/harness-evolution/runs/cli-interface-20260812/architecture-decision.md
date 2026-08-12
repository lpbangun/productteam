# Final architecture decision

**Decision: retain the repaired Bash CLI and REPL; retain neither Ink nor OpenTUI. No `productteam tui` command is added.**

The framework gate fails on demonstrated need, packaging/cold-start cost, streaming completeness, accessibility evidence, and net deletion. Both spikes proved the new CLI boundary is usable without scraping prose, but boundary viability does not justify a frontend.

The stable frontend boundary is:

- `productteam help --json`: canonical command/usage/chat metadata.
- `productteam status --json`: engagement list and transient selection inputs.
- `productteam agents --json`: provider availability; `runtime --check` for honest selection failure.
- `productteam gate <client> status`, `workspace <client> status`, and `role <client> status`: machine-readable judgment/workspace/worker state.
- `productteam inspect <client> [out]`: regenerates the authoritative inspect pack; frontends read that file.
- `state/.cli/runs/session-*/workers.tsv` and session artifacts/transcripts: activity and partial-output authority.
- Engagement `runs/iter-*/scores.json` and `history.jsonl`: iteration/score history.

No daemon, server, database, duplicate state, or orchestration API is introduced. Future framework evaluation triggers: repeated user evidence for multiline editing, scrollback/focus defects, rich streaming needs, or recurring Unicode/repaint failures; then require real provider signal proof and 25–30% net deletion after adapters and tests.
