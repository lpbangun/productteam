# Build 5 — Overnight loop resume proof
Date: 2026-08-11
Status: **verified**

## Smoke
```
PASS run-loop-refuse-missing-flags
PASS run-loop-dry-run-progress
PASS run-loop-no-auto-builder-seal
PASS run-loop-kill-resume
PASS run-loop-gate-block
PASS run-loop-escalation-stop
PASS run-loop-max-iters
PASS run-loop-max-hours-test-seconds
PASS run-loop-no-lift
PASS run-loop-smoke-all
```

## Sustained cycle + resume (archived run: `build5-proof-614455`)

1. Started `productteam run-loop build5-proof-614455 --max-hours 6 --max-iters 4 --dry-run --no-provider`
2. Sent SIGTERM mid-run → `status=paused`, `stop_reason=killed-resume-pending`
3. Resumed with `--resume` → completed with `stop_reason=max-iters`, `iter=4`

### Final progress.json
```json
{"client":"build5-proof-614455","started_at":"2026-08-11T07:36:01Z","updated_at":"2026-08-11T07:36:07Z","heartbeat_at":"2026-08-11T07:36:07Z","status":"completed","stop_reason":"max-iters","iter":4,"max_iters":4,"max_hours":6,"phase":"inspect","no_lift_streak":0,"last_overall":null,"pid":614636,"log":"state/engagements/build5-proof-614455/loop/run.log","stop_detail":"completed 4 iterations"}
```

### Log tail
```
2026-08-11T07:36:07Z iter 4: inspect complete
2026-08-11T07:36:07Z iter 4: gate clear
2026-08-11T07:36:07Z iter 4: role phase simulated (dry-run/no-provider)
2026-08-11T07:36:07Z iter 4: score skipped (dry-run/no-provider)
2026-08-11T07:36:07Z iter 4: close skipped — Critic envelope incomplete
2026-08-11T07:36:07Z iter 4: To seal experience: productteam pool add-from-iter build5-proof-614455 4 --kind worked|failed --domain ideation|implement|scoring|client --title "…"
2026-08-11T07:36:07Z iter 4: complete
2026-08-11T07:36:07Z stop: max-iters — completed 4 iterations
```

Sample snapshot: `state/missions/overnight-named-org/build-5-progress-sample.json`
