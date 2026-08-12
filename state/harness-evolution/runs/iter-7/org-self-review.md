# Organization self-review — iter 7

## Roles

- Analyst mapping found the correct REPL, runner, contract, and PTY seams. Its artifact delivery failed despite a successful yield; the Principal recovered the transcript. This is harness friction, not a reason for another permanent worker.
- Builders split cleanly by file ownership: REPL behavior, progress runner, and executable benchmark. One builder ran unrequested validation; final validation remained centralized.
- Critic was load-bearing: it froze binary honesty criteria, found the PTY drain defect, rejected fake streaming, and audited four convergence iterations.
- Principal integration caught the function-via-`setsid` defect before the first benchmark and the full suite caught the remaining dependency-policy regression.

## Friction and prompt gaps

- Agent result transport should not report `completed` while `agent://` exposes only a missing-yield warning.
- Builder instructions should emphasize that shell functions are not standalone executables and that runtime dependency policy covers test scripts too.
- Benchmark reviewers should distinguish a product failure from a probe that cannot reach the intended timing window.

## Organization decision

Keep the four permanent roles. No role duplication, new permanent worker, autonomy change, or architecture escalation is justified. Temporary Analyst, Builder, and Critic instances disband with this iteration.
