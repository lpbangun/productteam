# Product critique — skills-vector

**Skill:** /critique · **Repo:** /home/logani/projects/skills-vector · **When:** 20260806T064527Z

## Method
Structured audit from README + shallow tree. Findings cite paths.

## Product clarity
README present — skim first 80 lines for identity/audience.

## Target user
Infer from README "Who" / audience sections; flag if absent.

## UX / navigation / onboarding
Inspect entry docs and primary UI/docs paths in the tree below.

## Accessibility
Note whether a11y tests or guidance exist in tree.

## Product direction / friction / priorities / risks
Prioritize by impact-per-change. Prefer deletion. Do not rewrite vision.

## Tree (depth 2, truncated)
```
/home/logani/projects/skills-vector/.gitignore
/home/logani/projects/skills-vector/README.md
/home/logani/projects/skills-vector/docs/goal-loop.md
/home/logani/projects/skills-vector/pyproject.toml
/home/logani/projects/skills-vector/tests/test_domain.py
/home/logani/projects/skills-vector/tests/test_workflow_contract.py
```

## README excerpt
```
# Skills Vector

Skills Vector is a private-first occupational intelligence MVP for the U.S. People Operations & Talent domain. The first monitored roles are deliberately fixed to:

- HR Coordinator
- Recruiter
- Learning & Development Specialist

The initial foundation encodes the evidence, scope, uncertainty, and human-review rules for one updatable role brief. It also defines the controlled LangGraph workflow boundary without configuring model providers, credentials, schedulers, storage, deployment, or a public UI.

## Local verification

Python 3.11 or newer is required.

```bash
uv venv .venv
uv pip install --python .venv/bin/python -e .
.venv/bin/python -m unittest discover -s tests -v
.venv/bin/python -m compileall -q src tests
```

LangGraph is a runtime dependency, but the contract tests are offline and do not make model or network calls. The graph factory accepts narrow, injected handlers so later tool access stays controlled by the workflow.

## Current boundary

This repository does not predict an individual's career, publish briefs, operate a job board, call paid APIs, or autonomously change prompts, policy, memory, routing, or code. Those remain outside the current milestone. See [the project goal loop](docs/goal-loop.md) for the adaptive work/stop policy.
```

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
