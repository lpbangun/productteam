# Charm ranking stress-test — provider-boundary proposal

**Role:** Critic (adversarial)
**Date:** 2026-08-12
**Against:** "Charm (Bubble Tea v2 / Lip Gloss v2) wins the interactive frontend ranking for this repository" + any ranking that treats framework research maturity as adoption evidence.
**Evidence base:** frozen `cli-interface-20260812` run (`framework-comparison.md`, `architecture-decision.md`, `dependency-packaging-report.md`, `MEMORY.md` 2026-08-12 framework gate) + live librarian findings (CharmResearch / InkResearch / OpenTUIResearch / RepoScout).

---

## Verdict

**Charm does not win for this repository.** Ranking Charm primary because it is a strong Go TUI stack is a category error: this product is a Bash CLI with proven provider/signal contracts, and the frozen framework gate already rejected better-measured candidates for failing need, packaging, streaming completeness, accessibility, and net deletion.

**Corrected ranking**

| Rank | Candidate | Role |
|------|-----------|------|
| **Primary** | **Bash CLI + REPL** (`bin/productteam`, `lib/repl.sh`) | Retain. Only candidate that satisfies current gates and owns provider lifecycle. |
| **Runner-up** | **Ink 7.1.1** (disposable spike only) | Next *measurement* candidate if defects appear — already spiked here, Node 22 present, smaller tree than OpenTUI, some screen-reader hooks. Still **not** retention-ready. |
| 3 | Charm / Bubble Tea v2 stack | Speculative pure-Go rewrite. Unmeasured here; introduces Go ≥1.25 (missing on this host). |
| 4 | OpenTUI 0.5.x | Fails this repo's runtime floor (Bun or Node ≥26.4 experimental FFI); native binary weight; pre-1.0 churn. |

Do **not** adopt Charm to "avoid JS." That trades a measured Node spike for an unmeasured second language, a new toolchain floor, and the same retention gates Ink/OpenTUI already failed.

---

## Evidence-based objections (hidden costs & wrong assumptions)

### 1. Wrong assumption: "Charm wins on packaging"
- Repo has **zero Go**; `go` is **missing** on this host. Node 22.22.3 and Bun 1.3.14 exist.
- CharmResearch: Bubble Tea / Lip Gloss / Bubbles require **Go 1.25.0+** (huh/glamour 1.25.8). That is a new distribution + contributor floor, not a free win over Ink's Node ≥22.
- Static binary fantasy still costs: CI matrix, `go.mod`/`go.sum`, release artifacts, and a second implementation language beside ~8.8k lines of Bash under `lib/` + `bin/productteam`.
- Constitution: architecture change + new dependency class → owner escalation (`CONSTITUTION.md` autonomy table). Analyst already flagged Go/Bubbletea rewrite as escalation (`harness-cli` repository-analyst §4).

### 2. Wrong assumption: "Better widgets ⇒ replace Bash"
- Frozen decision: visual suite **14/14** + live provider cycle already pass on Bash (`evidence/visual-final.json`, `evidence/live-chat-cycle.typescript`). No recurring multiline / scroll / focus / streaming / Unicode / repaint defect was demonstrated (`framework-comparison.md` gate 1; `MEMORY.md` 2026-08-12).
- Ink and OpenTUI spikes both passed their own tests (35/35, 31/31) and still failed retention — working spike ≠ adoption (`MEMORY.md` framework evidence gate).
- Net deletion: both prior spikes deleted **0** replaceable Bash UI lines while adding >1,100 source lines. Charm has no path to 25–30% net deletion without a planned Bash UI retirement plan that does not yet exist.

### 3. Wrong assumption: "Charm can own the provider"
- Canonical authority is `provider_ask` (`lib/provider.sh:128-152`) and `repl_interrupt_cleanup` process-group kill (`lib/repl.sh:225-242`), proven by visual probe 11.
- CharmResearch: raw Ctrl+C is app-handled; real SIGINT → `ErrInterrupted`; `tea.ExecProcess` shares the terminal/process group with the child. If Charm wraps the provider itself, it must **re-prove** group kill, partial artifact retention, worker=failed, and return-to-prompt — or it regresses MEMORY 2026-08-10 interactive honesty.
- Safer (and required) model: Charm/Ink/OpenTUI **never** call the agent binary; they shell out to `productteam` / reuse Bash interrupt ownership.

### 4. Wrong assumption: "Charm accessibility is fine"
- CharmResearch: Bubble Tea core has **no** screen-reader contract; only Huh `WithAccessible(true)` for forms. Chat composer path has no a11y proof.
- Prior gate already failed Ink/OpenTUI on missing interactive a11y evidence despite Ink having `INK_SCREEN_READER` hooks. Charm is weaker on chat a11y, not stronger.

### 5. Wrong assumption: "Provider-boundary JSON is enough to greenlight a frontend"
- Boundary viability was proven by Ink/OpenTUI adapters and still did **not** justify retention (`architecture-decision.md`).
- Research peers disagree (InkResearch → Ink primary; OpenTUIResearch → OpenTUI if Bun OK; CharmResearch → Charm stack; RepoScout → Bash). Maturity tables are not product need.

### 6. Hidden cost: dual-runtime forever
- Even a "perfect" Charm TUI must keep Bash as automation, scoring, smoke, and non-TTY authority (`ARCHITECTURE.md` absences: no daemon, no second runtime module; non-TTY `Run()` fails without a TTY guard per CharmResearch).
- Result: Bash + Go binary permanently, unless Bash UI is actually deleted — which re-triggers the net-deletion gate and a large rewrite risk.

---

## Corrected architecture (provider / frontend boundary)

```
┌─────────────────────────────────────────────────────────┐
│ Optional TUI (Ink/Charm/OpenTUI) — disposable frontend  │
│  read-only: help/status/agents/gate/workspace/role JSON │
│             inspect-pack.json, workers.tsv, artifacts   │
│  mutate only by shelling out to bin/productteam …       │
└───────────────────────────┬─────────────────────────────┘
                            │ argv / exit / files
┌───────────────────────────▼─────────────────────────────┐
│ Bash authority (PRIMARY)                                │
│  bin/productteam · lib/repl.sh · lib/provider.sh        │
│  owns: provider_ask, process-group Ctrl+C, activity TSV │
│  durable state: plain files under state/ only           │
└─────────────────────────────────────────────────────────┘
```

**Safer backend seam (non-negotiable):** keep the frozen machine boundary; do not invent a daemon, event bus, or duplicate state.

| Seam | Authority |
|------|-----------|
| `productteam help --json` | Command registry / chat classification |
| `productteam status --json` | Engagement list / selection inputs |
| `productteam agents --json` + `runtime --check` | Provider availability |
| `gate` / `workspace` / `role` / escalation `status` | Judgment / workspace / worker envelopes |
| `productteam inspect <client>` → `inspect-pack.json` | Regenerable projection (not a second store) |
| `state/.cli/runs/session-*/workers.tsv` + artifacts | Activity + partial output |
| `runs/iter-*/scores.json`, `history.jsonl` | Scores |
| `provider_ask` + REPL interrupt cleanup | **Only** Bash path executes/kills the agent |

Rejected seams: provider process API inside the TUI, writing `workers.tsv` from Go/JS, scraping human help text, plugin host, or "Charm owns SIGINT globally."

---

## Non-negotiable prototype gates

A Charm (or any) spike may be **authorized** only after owner escalation **and** a measured Bash defect. Retention requires **every** gate:

1. **Need gate** — archived recurring user/task evidence for multiline editing, scrollback/focus, rich streaming, or Unicode/repaint failure on the Bash path. No defect → **no spike**.
2. **Boundary gate** — adapter consumes only the seams above; zero durable-state writes; automation CLI unchanged.
3. **Signal gate** — real authenticated provider turn; Ctrl+C kills the full process group; partial bytes + path preserved; worker marked failed; prompt returns. Prefer Bash-owned interrupt via shell-out over in-process `ExecProcess`.
4. **Non-TTY / CI gate** — interactive TUI refuses cleanly when stdin/stdout are not terminals; `NO_COLOR` and redirected one-shots stay Bash-native.
5. **Accessibility gate** — interactive screen-reader or equivalent proof for the chat surface (Huh forms alone do not pass).
6. **Packaging gate** — measured binary/dep size, cold start, RSS vs Bash baselines in `framework-comparison.md`; Charm must document Go ≥1.25 install matrix; no silent cgo/native surprises.
7. **Net-deletion gate** — after adapters + tests, **≥25–30%** net deletion of replaceable Bash UI lines (`lib/repl.sh` chrome and kin). Additive dual-UI = fail (Ink/OpenTUI precedent).
8. **Critic gate** — retention only with recorded Critic ACCEPT of gates 1–7; otherwise delete the spike tree and deps.

---

## Stop conditions

Stop and delete / refuse further framework work when any of:

- No measured Bash interactive defect (default stop — current state).
- Spike green on unit tests but fails signal, a11y, non-TTY, packaging, or net-deletion.
- Proposal requires daemon, DB, duplicate state, plugin host, or moving `provider_ask` out of Bash without equivalent proof.
- Charm spike requested while `go` < 1.25 or unavailable without making Go a documented product dependency (owner decision first).
- Ranking documents treat librarian API maturity as substitute for in-repo measurements.
- Iteration budget would burn on a third framework before Ink's measured failure modes are addressed or a real defect appears.

---

## Bottom line

Primary = **Bash**. Runner-up = **Ink** (measurement only). **Charm is not the winner** despite a coherent Go stack: it adds an absent toolchain, weakens chat a11y relative to Ink's hooks, cannot claim packaging victory on this host, and inherits the same retention failures that already killed Ink and OpenTUI. Keep the JSON/file provider-boundary; do not grow a Go frontend until Bash defects and the eight gates say otherwise.
