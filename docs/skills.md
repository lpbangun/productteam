# First-party product skills

| Skill | Path | Command |
|-------|------|---------|
| /critique | `skills/critique/SKILL.md` | `bin/consult skill critique <target>` |
| /benchmark | `skills/benchmark/SKILL.md` | `bin/consult skill benchmark <target>` |
| /design-sprint | `skills/design-sprint/SKILL.md` | `bin/consult skill design-sprint <target>` |

Skills make real provider calls through `lib/provider.sh` (`provider_ask`).
There are no mocks: if the provider is missing or fails, the skill refuses
and writes no filled artifact. Each artifact records the runtime binary.

Default artifacts land under `state/harness-evolution/runs/skills/`
(directory created on first skill run).

## Verification (this engagement)

Two guided dummy projects under `tmp-projects` exercise project-specific output:

- `state/engagements/harness-cli/tmp-projects/proj-a` (Node · tide forecasting)
- `state/engagements/harness-cli/tmp-projects/proj-b` (Python · irrigation)

```sh
bin/consult skill critique   state/engagements/harness-cli/tmp-projects/proj-a
bin/consult skill benchmark  state/engagements/harness-cli/tmp-projects/proj-b
bin/consult skill design-sprint state/engagements/harness-cli/tmp-projects/proj-a
```
