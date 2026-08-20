# Iteration 1 PTY / resize note

Parent-run frozen evidence:

- B6+ exact probe: exit 0, `0 FAIL(S)`.
- Compressed 80×24 first paint rendered `▣─▣─▣ ProductTeam`, three `● name …… score` rows, four role chips, no idle prefix, and the idle footer.
- The probe exercised persistent splash at 80×24, splash-only chrome, 120×36 / 80×24 / 60×24 / 40×20 first paint, unpinned prefix widths, same-chip unpin, no-provider first-run, 40-col chips, completion status, OMP ask/confirm, and SIGWINCH 80→40→80.
- B2 PTY-containing suite did not fully pass: 73 tests passed and four failed. The failures were two boot helpers that did not accept the new no-provider first-run copy and two confirm-test expectations that omitted the locked radio marker. No PTY nodeid itself failed in this run.
- B4 visual CLI: 14/14 IDs passed; overall exit 1 only because the pre-existing live-provider proof is missing, as allowed by the freeze.
