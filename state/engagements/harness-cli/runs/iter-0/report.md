# harness-cli iter-0 — baseline (pre-change)

**Contract:** harness-cli-v1 · **Kind:** baseline · **Overall:** 3.4
**Mode:** Directive · **Scorer:** checks via `lib/harness-cli-checks.sh`
**Live:** yes (`provider-live-answer` returned CONSULT-LIVE-OK via real `agent`)

## Debate (pre-implementation)

See `subagents/critic-priority-debate.md`. P8 (REPL) CUT. Surviving: skills LLM,
theme, splash, onboarding, agent detection, checks dispatch, docs.
Measurement scaffold only landed before this score (runner, tmp-projects, claim-map).

## Diff summary

No CLI behavior change. Added measurement: `lib/harness-cli-checks.sh`,
`tmp-projects/{proj-a,proj-b}`, `checks/claim-map.json`.

## Baseline scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| visual-cli-clarity | 4.0 | multi-hue palette; pipe-safe gate fails |
| splash-animation | 2.0 | absent |
| onboarding-ease | 2.0 | absent |
| agent-detection | 2.0 | runtime exists; catalog <10; false-positive on non-exec |
| feature-reachability | 4.0 | help/dispatch drift |
| skills-llm-reality | 4.0 | live provider OK; skills still templates |
| documentation | 2.0 | README incomplete vs help |
| developer-experience | 7.0 | smoke+runner OK; wrong checks suite for engagement |
| product-clarity | 4.0 | overclaim gate fails |

## Critic notes

Baseline recorded before product changes per freeze. Independent of Builder.
