# Mission 3 — Harness bootstrap (closed)

**Status:** DONE  
**Commands:** `productteam open` · `productteam baseline`  
**Smoke:** `tests/open-baseline-smoke.sh` (wired into `consult-smoke` + `harness-checks`)

## Done-when

1. Cold `open <client> --repo <abs>` writes engagement.md, frozen contract.json, BENCHMARK-CONTRACT.md, open-stamp.json, and ensures isolated workspace — no hand-written tree.
2. `baseline <client>` writes `runs/iter-0/` with workspace evidence:
   - checks + runner / ofc-v1 → measured scores
   - checks without runner → honest deferred unscored baseline
   - provider → named refuse `baseline-provider-requires-analyst`
3. Named refuses: `open-repo-missing`, `open-repo-not-absolute`, `open-exists`, `baseline-exists`, invalid mode/scorer/client.
4. Smoke + harness-checks cover open→baseline.

## Evidence

- `tests/open-baseline-smoke.sh` PASS markers
- `lib/harness-checks.sh` open-* / baseline-* probes
