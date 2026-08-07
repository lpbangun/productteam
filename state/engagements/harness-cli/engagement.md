# Engagement: harness-cli

Opened: 2026-08-07 · Contract: harness-cli-v1 (to freeze) · Client owner: lpbangun
Mode: **Directive** (Product Judgment Layer)

Repo: /home/logani/.herdr/worktrees/Product Consulting Harness/fix-new-user-tui
Public: https://github.com/lpbangun/product-consulting-harness
Branch: Fix/New-User-TUI
Scorer: checks
Vision: Product Consulting Harness — CLI-first product judgment layer; evidence over opinion; delete before adding. Not a JobOS redesign.

## Mission

Turn `bin/productteam` into a **fully clean chatbot-style CLI** in the spirit of
Grok Build / Droid / OpenCode: black-and-white terminal chrome with sparse
accent colors, OpenCode/Droid-style first-run onboarding, a short login/splash
animation that draws a knowledge-graph of computer-headed human nodes and
edges, clean detection of all coding agents present on the device, and every
core harness feature/skill reachable from the CLI. Prove skills and real LLM
calls (no mocks) against two varying dummy tmp projects with guidance.
Converge every frozen dimension to **≥ 9.0** within **6 iterations**
(iter-0 baseline + up to 5 improvement iterations), or write a
non-convergence report.

## Scope (explicit)

- **In scope:** Product Consulting Harness CLI (`bin/productteam`, `lib/`, docs,
  smoke/checks, skills invocation, onboarding, splash, agent detection UX).
- **Out of scope:** JobOS / Job App / any sibling product TUI or redesign.
  Do not change JobOS repos.

## Terminology

Prefer **CLI** (not TUI) in all engagement artifacts, UX copy, and checks.

## Invariants (do not touch)

- Constitution: delete before adding; evidence over opinion; never move goalposts.
- Client product repos remain siblings; no nested `clients/` tree.
- Provider seam stays `lib/provider.sh`; no API-key mocks.
- No mocks for LLM/agent verification paths — use real `agent` (or declared
  `CONSULT_PROVIDER`) runtime.
- Max iterations: **6** (including baseline as iter-0).

## Success checklist (owner brief)

1. Clean B&W chatbot-style CLI with accent colors only.
2. Login/splash knowledge-graph animation (nodes=computer-headed humans, edges).
3. New-user onboarding comparable to OpenCode / Droid ease.
4. Detect all agents present on device cleanly.
5. All core features callable from the CLI.
6. Skills work — two dummy tmp projects + guidance; real agent LLM calls.
7. Frozen benchmark; all dims ≥ 9/10 or stop at 6 iters.
