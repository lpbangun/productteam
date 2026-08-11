# Mission 1 — OFC foundation proof (closed)

**Status:** DONE  
**Closed iter:** `roles/iter-2/close.json` (2026-08-11)  
**Critic:** ACCEPT-WITH-NITS  
**Score:** ofc-v1 overall 9.5 · evaluator analyst · isolated workspace SHA `6a8db8e`

## Seams proven end-to-end

1. **Workspace isolation** — `workspace ensure/status`; checks + score run on `tmp/workspaces/onboarding-flight-control` (not live `Repo:`); evidence in `runs/check-*/workspace.json` and `runs/iter-2/workspace.json`.
2. **Inspect → judgment gate** — `inspect-pack.json`; Guided `judgment/selection.json`; `gate implement` allowed.
3. **Sealed role work** — Builder seal + real `agent` invoke (`roles/iter-2/Builder/attempt-3`); Analyst + Critic real invokes; identities builder ≠ analyst.
4. **Analyst score → Critic close** — stamp-gated `score --iter 2`; `close.json` binds critic manifest + analyst stamp.
5. **Honest refuses** — archived under `runs/iter-2/refuse-evidence/` (missing stamp, dirty workspace, missing seal).

## Harness fix landed for proof

`cmd_checks` now ensures the isolated worktree, archives `runs/check-*/workspace.json`, restores check-induced dirt so roles aren't blocked, and `score --iter` publishes Analyst-stamped ofc scores into `runs/iter-N/`.
