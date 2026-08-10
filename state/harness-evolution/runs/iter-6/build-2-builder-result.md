# Builder result — iter-6 Build 2 (judgment gates)

## Scope shipped (exactly the debate-amended list)

Build 2 implements the durable judgment-gate seam per `mission-benchmark.md` §6
and `build-2-debate.md`. Builds 3–4 untouched; no frozen `harness-apc-v1` file
edited; no provider invocation; no daemon/DB/router/orchestrator; no mocks.

### Files created

- `lib/judgment-gate.sh` — single sourced seam (mirrors `lib/workspace.sh`
  conventions): `judgment_mode` (current `Mode:` from `engagement.md` is the
  sole authority; missing/unknown → refuse), per-mode payload predicates,
  read-only `judgment_implement_refusal` + `judgment_status` JSON, atomic
  writers (tmp + rename) for `selection/directive/challenge/override.json`.
- `tests/judgment-gate-smoke.sh` — real CLI temporary-engagement probe
  (temp `gate-smoke-$$` client + cleanup trap; no fixtures/mocks) exercising
  every mode's refuse and pass path, including Challenge harmful refusal /
  safer-alternative pass, Override empty-risk refusal with no durable write,
  and Override non-waiver tamper refusal.
- `state/harness-evolution/runs/iter-6/build-2-builder-result.md` — this file.

### Files edited (permission list)

- `bin/consult` — `source lib/judgment-gate.sh`; `cmd_gate`
  (`status|implement [direction]|select <direction>|direct <direction> [risk...]|
  challenge <harmful> <safer> <evidence>|override <direction> <risk> <critic-record> <evidence-record>`);
  help entry + dispatch branch. `cmd_judge_set` unchanged; no checks/score/bench
  wiring (Build 4 consumer).
- `tests/consult-smoke.sh` — added help-discoverability checks for the gate.
- `lib/harness-checks.sh` — exactly the eight §6.4 G5.1 ids
  (`gate-guided-refuse`, `gate-guided-pass`, `gate-directive-refuse`,
  `gate-directive-pass`, `gate-challenge-refuse`, `gate-challenge-alternative`,
  `gate-override-refuse`, `gate-override-pass`) recorded from the real
  `tests/judgment-gate-smoke.sh` run.
- `README.md` — Judgment gates section (verbs, per-mode require/refuse table,
  non-waivers, Build 4 consumer note) + Layout rows for the seam and the probe.
- `ARCHITECTURE.md` — `judgment/` row in the state layout + Judgment gate seam
  section.

## Semantics as shipped (debate-amended)

- **Guided** — implement refuses until `judgment/selection.json` has non-empty
  `direction` + `selected_by`; `select` writes it; pass thereafter.
- **Directive** — implement refuses until `direct` archives a durable
  direction; `implement` remains read-only and `risks` may be empty.
- **Challenge** — implement of the challenged `harmful` path always refuses;
  only `safer_alternative` is implementable, and only when
  `judgment/selection.json` matches it.
- **Override** — requires exact `direction`, non-empty `risks`,
  `critic_record`, `evidence_record`, and required-true
  `non_waivers.{critic,evidence,frozen_contract}`. Empty risk refuses and
  writes nothing; any false/missing non-waiver (e.g. tampered file) refuses.
  There is no waiver channel; the frozen contract is never waived.
- **Status** — valid JSON: `client`, `mode`, `allowed`, `decision`, `reason`,
  `bound_direction`, `artifact`, `artifact_ts`, `required`/`present`. Always
  exits 0 (refused or legacy engagement with no `judgment/`); a later session
  re-derives the same decision from files alone. Writers persist `mode`, `ts`,
  and `decision` atomically.
- Stale cross-mode files are ignored (current-mode-only reads), never deleted.
- `implement [<direction>]` — omitted arg uses the mode's bound direction;
  a provided direction must equal it or refuse naming the client and file.

## Verification

Delegated run per instructions: no commands or tests were executed by this
builder. Verification is owned by the Advisor acceptance pack
(`state/harness-evolution/runs/iter-6/evidence/acceptance-build-2-*.txt`) and
the harness-checks suite; the eight gate ids above are the G5.1 surface that
suite records.

## Out of scope (refused, not implemented)

Builds 3–4 surfaces; Builder invocation wiring; workspace-dirty coupling inside
`gate implement`; MEMORY/run-report enforcement; any `waivers` channel; editing
`JUDGMENT.md` or frozen harness-apc-v1 files; re-scoring Build 1 or contract
bands; daemon/DB/plugin/RAG/second CLI; product/client application code.
