# Frozen benchmark — osint-loop-v1

Frozen: 2026-08-11. Do not move goalposts mid-engagement.

## Dimensions (target ≥ 9.0 each)

1. **cli-runnable** — `python3 -m loops.main_loop --help` exits 0 from repo root.
2. **cold-run** — Fresh `--max-iterations 1` exits 0; writes dossier + evidence_summary for the given `--target` without foreign hardcoded subject identity.
3. **resume-semantics** — After a stopped run, `--resume` either continues when max_iterations is raised or exits non-zero with an explicit message; never a silent success no-op that only prints “use --resume”.
4. **termination-fidelity** — A machine-readable termination artifact lists criteria; orchestrator stop decision matches that artifact; README stop bullets match the engine.
5. **evidence-integrity** — New evidence rows have provenance fields; verification upgrades persist on disk across reload.
6. **output-inspectability** — Dossier/summary derive from store for the active target; termination artifact present under `output/`.
7. **boundedness** — `max_iterations` is honored; no path that ignores the bound for “find contact / don’t stop” missions.

## Scorer

Deterministic checks via engagement `checks_runner`. Overall = mean of seven dimensions. Convergence: every dimension ≥ 9.0.
