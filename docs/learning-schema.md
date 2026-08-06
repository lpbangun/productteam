# Learning artifact schema (harness-evolution)

Durable lessons only. No secrets, tokens, `.env` contents, temporary noise,
or unsupported assumptions.

## Per-iteration files

```
state/harness-evolution/runs/iter-N/
  lessons.md          # required when iteration closes
  report.md           # debate, diff, critique, org review
  critic-verdict.md   # mandatory
  scores.json         # independent evaluator only
  checks.json|txt     # real command evidence
```

## `lessons.md` shape

```markdown
# Lessons — iter-N

## Expected
…

## Actual
…

## What worked
- …

## What failed
- …

## Change next time
- …
```

## Org memory

Append short, dated, evidence-linked entries to `MEMORY.md` under
**Lessons** or **Org self-improvements**. Reference the run path
(`state/harness-evolution/runs/iter-N/`).

## History

One JSON line per scored run in `state/harness-evolution/history.jsonl`:

```json
{"ts":"YYYY-MM-DD","iter":0,"kind":"baseline|iteration|void","overall":0.0,"run":"runs/iter-0"}
```
