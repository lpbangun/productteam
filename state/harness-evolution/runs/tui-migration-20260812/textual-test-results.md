# Textual test results

Date: 2026-08-13

- `python -m compileall -q src`: PASS.
- `python -m pytest -q`: PASS, 52 tests; 8 deterministic pytest-textual-snapshot comparisons; two consecutive Principal runs passed after the final fix, with Builder reporting six consecutive passes.
- `python scripts/package.py`: PASS; `productteam-tui-textual-1.0.0.zip` produced.
- Redirect-safe frozen preflight: contract probe PASS; valid event fixture accepted; all generated malformed/envelope/payload/transition/timing variants rejected; non-TTY refusal PASS (exit 2, empty stdout, plain remedy, no ANSI).
- Direct real PTY `--terminal-case success`: exit 0, PRODUCTTEAM rendered, terminal attributes restored.
- Direct real PTY `--terminal-case failure`: exit 17, PRODUCTTEAM rendered, terminal attributes restored.
- Real tmux base captures recorded at 120x36, 80x24, 60x24, and 40x20 under `frame-captures/textual-rich/`; each contains PRODUCTTEAM, WORKERS, and Message ProductTeam.
- Lifecycle unit proof: 3/3 pass; real child group, exact argv with spaced artifact paths, parent/child death, unchanged partial artifact.

Frozen common benchmark: FAIL/VOID before the complete first frame. The shared runner changes its generated ProductTeam proxy from executable mode 0555 to 0444. Textual correctly surfaced `PermissionError`; the four-size interaction/boundary run therefore produced no comparable result. No mandatory retention claim is made.
