# Advisor baseline

Date: 2026-08-13. Repository tip and `main`/`origin/main`: `7906348ca067120d368b2bb6a0424716bc77aae9` after `git fetch --all --prune`; both ancestry checks returned 0, so no rebase changed the worktree.

## Existing architecture

- `ARCHITECTURE.md`: CLI is a viewer/launcher; judgment lives in workers; durable state is plain text.
- `lib/commands.sh`: one 32-command registry drives `help --json`, dispatch, palette membership, chat classification, and refusal reasons.
- `lib/repl.sh`: canonical provider path already owns process-group termination/reap and partial artifacts.
- `state/engagements/*/inspect-pack.json`, `history.jsonl`, `runs/iter-*/scores.json`, and `state/.cli/runs/session-*/workers.tsv`: read-only frontend projections.

Observed machine seams before the build:

- `bin/productteam help --json`: contract `cli-interface-20260812-v3`, 32 commands, 6 chat-only verbs, 14 unsupported commands with reasons.
- `bin/productteam status --json`: six listed engagements; `harness-cli` iter 1 score 9.5.
- `bin/productteam agents --json`: real installed/missing runtime projection.
- `bin/productteam gate harness-cli status`: valid JSON refusal because no durable Directive decision is recorded.
- `bin/productteam workspace harness-cli status`: valid JSON with an absent disposable worktree.
- `bin/productteam role harness-cli status 1`: valid file-derived missing-envelope projection.

No read-only baseline command mutated ProductTeam state.

## Prior TUI evidence

`state/harness-evolution/runs/cli-interface-20260812/framework-comparison.md` previously rejected Ink 7.1.1 and OpenTUI 0.5.1 prototypes: neither implemented multiline editing, event streaming, or process ownership; OpenTUI measured about 79.6 MiB installed and required Bun here. That evidence informs risk but does not answer this new, stronger common contract.

`state/harness-evolution/runs/cli-interface-20260812/textual-opentui-autonomy-stress-test.md` correctly constrains any candidate to an optional projection. The present owner-directed spike does not authorize moving provider, judgment, workspace, role, escalation, evidence, or automation authority into a framework.

## Runtime and package availability

- Python: 3.12.3.
- Bun: 1.3.14.
- `@opentui/core`: 0.5.2 exists.
- `@opentui/solid`: 0.5.2 exists.
- `@opentui/keymap`: selected exact 0.5.2 exists.
- `solid-js`: 1.9.12 exists.
- `textual`: 8.2.8 exists.
- `rich`: 15.0.0 exists.

Dependencies will be installed only inside candidate directories and excluded from version control.

## Shared-fixture proof

Command:

```text
python3 -m py_compile spikes/shared/benchmark.py spikes/shared/process_fixture.py spikes/shared/test_shared.py
python3 -m unittest -v spikes/shared/test_shared.py
```

Initial outcome: 4 tests passed. After the Critic rejected self-attested probes, the amended suite passes 14 tests twice and rejects static, forged-lifecycle, scenario-drift, boundary-bypass, database/network, and survivor adversaries. The expanded evidence covers complete schemas, scenario/driver parity, correlated runs, worker projection, actual hanging-fixture group termination, scoring completeness, and static-stub rejection. Candidate behavior remains untested until both builds exist.

## Baseline conclusion

The canonical CLI already passes its own frozen contracts. The decision-relevant gap is whether either optional frontend can satisfy multiline/scroll/overlay/event/lifecycle behavior without duplicating authority and at acceptable runtime/maintenance cost. The new benchmark measures that gap; it does not weaken the Bash contracts or infer a migration.
