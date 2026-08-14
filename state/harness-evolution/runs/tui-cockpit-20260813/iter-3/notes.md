# Iteration 3 — isolate per-verb CLI output (dim 3)

Reviewer 12ebe1ce failed dim 3 because needles were matched against the accumulated transcript.

## Fix

- `_cli_busy` + `finally` so the test waits for each argv turn to finish.
- Slash echo is a `user` turn, not `cli`.
- `test_all_verbs.py` asserts needles only in `_turns` entries of kind `cli` added **after** that invocation.
- Valid semantic args: `/skill critique /nonexistent-skill-target` → real `cannot resolve target`; `/score … --iter 0` → real stamp refusal; `/gh preflight` → real auth text; `/checks nosuchclient` → real missing engagement.
- `run_argv_stream` now has a real wall-clock deadline so `/smoke` and `/harness-checks` still deliver their real banners then end.

## Commands

| command | result |
|---|---|
| pytest `lib/tui/tests` | **28 passed** |
| `cli-interface-parity.sh` | **PASS** |
| `visual-cli.sh` | **14/14**; live-provider proof missing (allowed) |
