# Overnight loop — VPS wake recipe

Thin file-orchestrated driver. **Not** an always-on daemon — cron or systemd wakes the CLI, runs bounded iterations, exits.

## Command

```bash
productteam run-loop <client> \
  --max-hours 6 \
  --max-iters 5 \
  [--dry-run] [--no-provider] [--resume]
```

Both `--max-hours` and `--max-iters` are **required** (explicit overnight bounds).

## Artifacts

| Path | Purpose |
|------|---------|
| `state/engagements/<client>/loop/progress.json` | Durable progress, pid, stop reason, phase |
| `state/engagements/<client>/loop/heartbeat` | Plain timestamp touch for external watchdogs |
| `state/engagements/<client>/loop/run.log` | Append-only file log |

## Hard stops

The loop exits (status `stopped` or `completed`) on:

- `max-hours` — elapsed wall time (see test override below)
- `max-iters` — iteration budget consumed
- `escalation` — open escalation or active pause (`progress_blocked_reason`)
- `gate-block` — judgment gate refuses implement (Guided with no selection, etc.)
- `no-lift` — overall score flat/down for `CONSULT_NO_LIFT_STREAK` consecutive iters (default 2)
- `critic-reject` — Guided Critic rebuttal verdict `REJECT` for the current iter

SIGTERM/INT writes `killed-resume-pending`, status `paused`, exit 0 — safe for cron resume.

## Cron example (5–6 h wake, resume)

```cron
# Every night 22:00 UTC — start or resume up to 6 h / 5 iters
0 22 * * * cd /path/to/harness && \
  productteam run-loop my-client --max-hours 6 --max-iters 5 --no-provider --resume \
  >> state/engagements/my-client/loop/cron.log 2>&1
```

Use `--no-provider` on a headless VPS without a coding agent, or omit it when `CONSULT_PROVIDER` is configured. Never auto-implements past judgment gates.

## systemd oneshot (alternative)

```ini
[Unit]
Description=Product team overnight loop

[Service]
Type=oneshot
WorkingDirectory=/path/to/harness
Environment=CONSULT_PROVIDER=cursor-agent
ExecStart=/path/to/harness/bin/productteam run-loop my-client --max-hours 6 --max-iters 5 --resume
StandardOutput=append:/path/to/harness/state/engagements/my-client/loop/systemd.log
StandardError=append:/path/to/harness/state/engagements/my-client/loop/systemd.log

[Install]
WantedBy=multi-user.target
```

Pair with a timer (`OnCalendar=*-*-* 22:00:00`) for scheduled wake.

## Smoke / test override

```bash
CONSULT_LOOP_TEST_SECONDS=1 bash tests/run-loop-smoke.sh
```

Treats the hours budget as seconds for fast CI without waiting overnight.
