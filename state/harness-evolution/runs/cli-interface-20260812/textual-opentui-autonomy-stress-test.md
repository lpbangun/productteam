# Textual + OpenTUI autonomy stress-test

**Role:** Critic (adversarial) / AutonomyCritic  
**Date:** 2026-08-12  
**Against:** “Textual + OpenTUI remain the right top two, with Textual leading, once the product centers **autonomous coding** rather than visual chat chrome.”  
**Evidence base:** `framework-comparison.md`, `architecture-decision.md`, `dependency-packaging-report.md`, `textual-ratatui-ranking-stress-test.md`, `charm-ranking-stress-test.md`, `ARCHITECTURE.md`, `CONSTITUTION.md`, `MEMORY.md` 2026-08-10 interactive honesty + 2026-08-12 framework gate.

---

## Verdict

| Claim | Decision |
|-------|----------|
| Textual + OpenTUI remain the right **two** when autonomy (not visuals) is central | **REJECT** |
| A TUI framework should **lead** autonomous coding | **REJECT** |
| Textual remains best **contingent** optional-frontend candidate *if* UI is later authorized | **ACCEPT** (narrow) |
| OpenTUI stays runner-up under an autonomy-first ranking | **REJECT** — demote; visual strength is the wrong axis |
| Architecture (protocol seams) must precede any UI framework choice | **ACCEPT** |

**Primary:** Bash CLI + org-loop protocol (`bin/productteam`, `lib/provider.sh`, `lib/repl.sh`, judgment/workspace/role/escalation seams).  
**Runner-up (framework, measurement-only):** Textual (pin exact) — optional viewer only, never autonomy engine.  
**Not runner-up:** OpenTUI. Under autonomy, its chat primitives and Bun/native floor buy the wrong thing.

---

## Challenge: framework → autonomy assumptions (false)

1. **“Best chat TUI ⇒ best autonomy surface.”**  
   Autonomy here is durable loop behavior: freeze → debate → workspace-isolated implement → score with evidence → critique → memory → escalate. That lives in plain files and Bash seams (`ARCHITECTURE.md`), not ScrollBox/TextArea. Visual suite already **14/14** with live provider proof; no recurring interactive defect (`framework-comparison.md` gate 1).

2. **“Widgets deliver agent honesty.”**  
   Honesty is process-group kill, partial artifact retention, worker=`failed`, return-to-prompt (`MEMORY.md` 2026-08-10). Ink/OpenTUI spikes owned **no** provider child. Framework Workers/keymap cannot substitute for `provider_ask` + `repl_interrupt_cleanup`.

3. **“OpenTUI belongs in the top two because it was measured.”**  
   Measured ≠ ranked for autonomy. The spike proved JSON/TSV adapters and UI tests; it did not advance judgment, role stamps, escalation, scoring recursion guards, or net deletion. Measurement without autonomy lift is a visual prototype credit only (`textual-ratatui-ranking-stress-test.md`).

4. **“Pick a framework now so autonomy can grow into it.”**  
   Constitution: architecture + new dependency class escalate. Absences (no daemon, DB, plugin host, second runtime module) are deliberate. Choosing Textual/OpenTUI *before* protocol gaps exist invents a dual-runtime forever and fails the 25–30% net-deletion gate (prior spikes deleted **0** Bash UI lines).

5. **“Frontend maturity tables are product need.”**  
   Same category error rejected for Charm: librarian rankings disagree with each other and with frozen retention (`charm-ranking-stress-test.md`). Need = archived Bash defect or missing **protocol** capability — not prettier panes.

---

## Architecture that must precede UI

Ship / harden these **before** any Textual or OpenTUI retention debate. UI may read them; UI must not redefine them.

| # | Protocol boundary | Authority today | UI may… | UI must not… |
|---|-------------------|-----------------|---------|--------------|
| A | Provider lifecycle | `lib/provider.sh` `provider_ask`; REPL interrupt group-kill | Shell out to `productteam` / watch artifacts | Own agent child, invent SIGINT policy, dual-write activity |
| B | Activity + partials | `state/.cli/runs/session-*/workers.tsv` + artifact paths | Tail / display | Author TSV rows or “fix” interrupt state |
| C | Judgment gate | `lib/judgment-gate.sh` + `judgment/*.json` | Show `gate … status` | Bypass Guided selection / Challenge refuse / Override non-waivers |
| D | Workspace isolation | `lib/workspace.sh`; never live `Repo:` fallback | Display `workspace … status` | Score/implement against owner tree; destructive recover |
| E | Role envelopes | `lib/role-envelope.sh`; Analyst stamp; Builder seal; Critic close | Render envelopes / hashes | Invoke provider as anonymous self-scorer; reseal Builder |
| F | Escalation / pause | `engagement-state.sh`; authorize-resume consume | Surface blocked + options | Treat missing files as resume; auto-authorize |
| G | Inspect projection | `inspect-pack.json` regenerated | Read pack | Treat pack as second store; patch it as authority |
| H | One-shot automation | Non-TTY / pipe / `NO_COLOR` Bash paths | Refuse interactive when not a TTY | Capture stdout via App on `--json` paths |
| I | Evidence / memory | `scores.json`, `history.jsonl`, `MEMORY.md`, run reports | Link paths | Score without path evidence; rewrite frozen history for cosmetics |
| J | Extension points | `scorer` + `CONSULT_PROVIDER` only | N/A | Plugin host, daemon, DB, event bus |

**Precedence rule:** if a proposed UI feature requires changing A–J, that is an architecture/autonomy escalation — not a framework spike.

---

## Corrected ranking (autonomy-central)

| Rank | Candidate | Role under autonomy |
|------|-----------|---------------------|
| **Primary** | **Bash + file protocol** | Only system that already runs autonomous loop mechanics end-to-end. |
| **Runner-up** | **Textual** (contingent, optional frontend) | Best *viewer* candidate if need appears: `python3` already on bench/check path; Pilot/`run_test`; must stay adapter-only. |
| 3 | Ink 7.1.1 | Prior in-repo measurement reference (Node 22, smaller tree than OpenTUI). Not autonomy-relevant beyond adapter precedent. |
| 4 | OpenTUI 0.5.x | **Demoted.** Strengths are visual (ScrollBox, Textarea, keymap). Autonomy gains nothing from Bun/Node≥26.4 FFI + ~80 MiB natives that Ink/Bash already answered for need. |
| — | Charm / Ratatui | Still toolchain-absent; irrelevant until owner accepts Go/Rust **and** a protocol gap UI cannot fix. |

### Primary vs runner-up (explicit)

- **Primary leads all autonomy work.** Loop verbs, provider, gates, envelopes, checks, smoke, CI.
- **Textual leads only the optional interactive *projection*** after need + gates — never domain rewrite.
- **OpenTUI does not remain one of the two** for this axis. Keep it as a historical spike archive, not a shortlist seat.

---

## Explicit switch criteria

### Switch **away from Bash-primary UI** (authorize Textual spike) only when **all** hold

1. Archived recurring **task** failure on Bash path that is interactive *and* blocks autonomy (e.g. operators cannot supervise long multi-agent turns because scrollback/focus genuinely loses evidence paths) — not taste.
2. Protocol A–J are green on Bash without the new UI (no “UI will fix judgment/provider”).
3. Owner escalates architecture/dependency class (`CONSTITUTION.md`).
4. Spike plan commits: shell-out-only mutations; App never on one-shot/`--json`; Critic retention bar below.

### Switch **Textual → other framework** (demote Textual runner-up) when any hold

| Trigger | Switch to |
|---------|-----------|
| Textual spike fails packaging/cold-start/RSS vs Bash after honest measure | Re-open measurement shortlist (Ink first — already measured) |
| Owner mandates static single binary + accepts new language | Charm (Go≥1.25) *or* Ratatui (rustup) — choose then; neither is default runner-up now |
| Bun/Node≥26.4 FFI accepted as product runtime **and** Textual cannot meet signal/a11y/net-deletion | OpenTUI may re-enter shortlist — still after need, not instead of protocol |
| Net-deletion unreachable without retiring Bash chrome probes | Owner-amended TUI contract first; framework switch alone is insufficient |

### Switch **OpenTUI back into top two** only when

- Autonomy-central brief is withdrawn (visuals become primary again), **or**
- Host runtime policy explicitly accepts Bun (or Node≥26.4 FFI) **and** Textual is disqualified on measured gates **and** need gate still passes.

Otherwise OpenTUI stays demoted.

---

## Non-negotiable protocol boundaries

1. **Bash owns the agent.** TUI never becomes `provider_ask`.
2. **Files own truth.** JSON/TSV/markdown under `state/`; atomic tmp+rename; inspect is projection.
3. **Mutations are CLI argv.** Frontend shells out to `productteam …`; exit codes preserved.
4. **Automation stays headless.** Non-TTY/CI/NO_COLOR paths do not start a framework App.
5. **No dual activity authority.** Only canonical REPL/CLI writes `workers.tsv` / artifacts.
6. **No autonomy via chrome.** Judgment, workspace, role stamp/seal/close, escalation resume remain Bash modules.
7. **Retention ≠ green unit tests.** Need + signal + a11y + packaging + ≥25–30% net deletion + Critic ACCEPT (`MEMORY.md` framework evidence gate).
8. **Absences stay absences** until evidenced: no daemon, DB, plugin host, second state store.

---

## Stop conditions

Stop / delete spike / refuse further framework ranking when any of:

- No measured Bash defect that blocks **autonomous** operation (current default — **stop UI framework work**).
- Proposal treats Textual/OpenTUI selection as the autonomy roadmap.
- Work invents daemon/bus/DB or moves provider ownership into a TUI to “make agents feel live.”
- OpenTUI is re-elevated solely for widget polish while protocol A–J are unfinished or already sufficient.
- Textual App wraps one-shot `--json` (breaks automation contracts).
- Spike passes Pilot/unit tests but fails signal, non-TTY, a11y, packaging, or net-deletion.
- Ranking docs use research maturity tables as substitutes for in-repo autonomy evidence.
- Iteration budget spends on a third unspiked stack before a real protocol gap or Bash defect is closed.

---

## Bottom line

Autonomy is a **protocol**, not a **framework**. Textual + OpenTUI are **not** the right two on this axis: **Bash leads**; **Textual** is the only justified framework runner-up as an optional viewer; **OpenTUI is demoted** because its advantages are visual and its runtime tax does not buy loop integrity. Harden provider/judgment/workspace/role/escalation/evidence seams first; switch frameworks only under the criteria above.
