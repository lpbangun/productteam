# OpenTUI test results

Date: 2026-08-13

- `bun run typecheck`: PASS.
- Raw `bun test`: PASS, 61 tests, 916 assertions.
- `bun run package`: PASS; audit-clean externalized `dist/main.js` plus source manifest archive.
- Redirect-safe frozen preflight: contract probe PASS; valid event fixture accepted; all generated malformed/envelope/payload/transition/timing variants rejected; non-TTY refusal PASS (exit 2, empty stdout, plain remedy, no ANSI).
- Direct real PTY `--terminal-case success`: exit 0, PRODUCTTEAM rendered, terminal attributes restored.
- Direct real PTY `--terminal-case failure`: exit 17, PRODUCTTEAM rendered, terminal attributes restored.
- Real tmux base captures recorded at 120x36, 80x24, 60x24, and 40x20 under `frame-captures/opentui-solid/`; each contains PRODUCTTEAM, WORKERS, and Message ProductTeam.
- Lifecycle unit proof: 3/3 pass; real child group, exact argv with spaced artifact paths, parent/child death, exit 130, unchanged partial artifact.

Frozen common benchmark: FAIL/VOID. The shared runner changes its generated ProductTeam proxy from executable mode 0555 to 0444 before launch. A partial 120x36 candidate frame was captured before the failed read-only seams, then cleanup reported a transient survivor. The complete four-size interaction/boundary run never completed, so no mandatory retention claim is made.
