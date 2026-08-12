# Critic — Priority Debate (pre-implementation) — harness-cli

**Role:** Critic (adversarial) · **Engagement:** `harness-cli` · **Contract:** `harness-cli-v1` (FROZEN 2026-08-07)
**Scope:** Product Consulting Harness CLI only (`bin/consult`, `lib/`, `docs/`, `tests/`). Not JobOS. Not TUI framing.
**Stage:** Before implementation — debating the Principal's proposed work list P1–P8.

Verified against the repo directly (not just the Repository Analyst's brief): read `bin/consult` (529 lines), `lib/provider.sh` (73 lines), `contract.json`, `CHECK-CATALOG.md`, `assignments.md`, `README.md`/`ARCHITECTURE.md` grep, `MEMORY.md`. All line citations below are from this pass.

---

## 0. Blocking finding before any item-by-item debate

**None of P1–P8 can legally happen next.** The contract's own Baseline guard
(`BENCHMARK-CONTRACT.md:97-104`) and `assignments.md:24-39` are explicit:
iter-0 must be scored **before any CLI behavior change**, and only
measurement-only scaffolding may land first:

- `lib/harness-cli-checks.sh` does not exist yet (`ls lib/` = `github.sh
  harness-checks.sh provider.sh run-checks.sh run-skill.sh` — no
  `harness-cli-checks.sh`). Test Engineer is still **pending** in
  `assignments.md:13`.
- `state/engagements/harness-cli/tmp-projects/` is empty (confirmed via
  `find`), so `proj-a`/`proj-b` + `GUIDANCE.md` do not exist.
- `runs/` and `history.jsonl` do not exist — **no iter-0 has been scored.**

This means the debate below is correctly "before implementation," but the
Principal's work list skips a mandatory step: **P0 (unstated) — Test
Engineer builds the 49-id checks runner + two varying tmp-projects + claim
mapping skeleton, then iter-0 is scored on the CLI exactly as it stands
today.** Only after that is recorded does any of P1–P8 become legal to
implement (`BENCHMARK-CONTRACT.md:99-103`: "Any commit that changes CLI
behavior must land after iter-0 is recorded"; violating this is not
explicitly in the "critical failures" list by name, but it breaks
"Baseline guard" and would make iter-0 either impossible to score honestly
(scaffold measuring a moving target) or force a redo, burning one of the six
irreplaceable iterations. `CONSTITUTION.md:17-19` — "Never move the
goalposts" — cuts the same way: scoring baseline after quietly starting the
redesign is a goalpost move even if unintentional.

**Verdict on the missing P0: SURVIVE, and it is not negotiable — it goes
first, full stop.** I flag this as a debate-item because it is currently
implicit rather than written into the Principal's list, and Builders reading
only P1–P8 could reasonably start on P1 today and void the whole engagement.

Everything below assumes P0 lands first and iter-0 is recorded before any
of P1–P7 is coded.

---

## 1. Item-by-item rebuttal

### P1 — Wire skills to real `provider_ask` (fix G2) — SURVIVE (highest priority, scope corrected)

Confirmed independently: `lib/run-skill.sh` is out of scope for me to open
line-by-line here, but the Repository Analyst's citation
(`lib/run-skill.sh:56-188`, no `provider_ask` call) is consistent with
`lib/provider.sh:47` being the only defined seam and `bin/consult` showing
only `cmd_bench_run` (`bin/consult:432-454`) calling it. This is the
contract's own `no-mock-provider` **GATE**, `skill-uses-provider-seam`
**GATE**, and directly the invariant text in `engagement.md:40-42` ("No
mocks for LLM/agent verification paths"). This is not just a benchmark
point — it is a **standing invariant violation today**. Clear survive.

**Rebuttal on the claimed lift (2→9.5 in one pass):** Optimistic and
should not be the accepted success bar for iter-1. `skills-llm-reality` has
**8 checks**, 5 of them **LIVE** (`provider-live-answer`,
`skill-critique-live-project-a`, `skill-benchmark-live-project-b`,
`skill-design-sprint-live`, `skills-outputs-project-specific`) plus
`tmp-projects-two-varying` which is a **separate P0 deliverable**, not part
of P1's own diff. `skills-outputs-project-specific` requires Jaccard
similarity < 0.6 between two live LLM outputs for the *same* skill — that
is a property of prompt design against real model variance, not
guaranteed by "call `provider_ask` instead of a heredoc." Expect first pass
to land in the 6–8 band (`skill-uses-provider-seam` and `no-mock-provider`
gates pass, 1–3 non-gate checks fail) and budget a second look if
`skills-outputs-project-specific` or `provider-live-answer`'s sentinel-token
match is flaky.

**Scope note:** P1 also needs `docs/skills.md` truth-telling
(`docs-skills-live` check) — currently `docs/skills.md:1-9` says nothing
about live provider calls or tmp-projects, and would fail that check even
after the code fix. Fold that doc line into P1's own diff, don't defer it
to P7 — it is a one-line addition next to the code that makes it true.

### P2 — `lib/theme.sh` + refactor chrome — SURVIVE, but scope is underestimated

Verified directly: `bin/consult:14-18` defines 7 ad hoc colors
(`B D R G Y RD C`), and `score_color()` (`bin/consult:20-24`) maps score
bands to **three** different colors (green/yellow/red) beyond the cyan used
for identity/active markers. `cli-accent-budget` caps the **whole CLI
surface** at **≤2** distinct accent codes. Collapsing a 3-way
green/yellow/red score signal plus a 4th cyan-for-identity into ≤2 accents
is a **design decision** (which two hues survive, and what replaces the
third semantic band — bold/dim/marker-glyph substitution), not a
mechanical "move these lines to a new file" refactor as the framing implies.
Survives, but the Builder scope must explicitly include: (a) one theme
file, (b) a decision on which score bands keep color vs. move to glyph/dim
distinction, (c) re-verification that `bar()`/`spark()` still communicate
without color (`cli-monochrome-chrome` requires structure to hold with
color stripped). Independent of P1/P3/P4/P5's files — safe to run in
parallel/same iteration as P1 since it only touches `bin/consult:14-24`
and a new `lib/theme.sh`.

### P3 — `lib/splash.sh` knowledge-graph animation + first-run hook — SURVIVE, sequence after P4 or together

No disagreement with the Analyst's sketch (`repository-analyst.md §5.2`) on
approach. Two added constraints from the frozen catalog the Principal's
one-liner doesn't surface:

1. `splash-first-run-hook` and the catalog's "Testability requirements"
   section (`CHECK-CATALOG.md:24-37`) require a **documented state-root
   override** seam — the same seam `onboarding-cold-start` (P4) needs.
   Building this twice (once for splash, once for onboarding) risks two
   slightly different env-var names, which then trips
   `no-hidden-env-requirements`. **Build the state-root override once,
   shared by P3 and P4** — this is a sequencing dependency, not two
   independent items.
2. `splash-bounded-noninteractive` is a **GATE** at ≤2.0s wall time,
   `< /dev/null`, single static frame non-TTY, plus a documented opt-out.
   This is the same "smoke must not hang" lesson the Analyst already flagged
   (`MEMORY.md:74-76`) — the opt-out env var must be checked by
   `tests/consult-smoke.sh` indirectly (splash must never fire during smoke
   at all, opt-out or not, since smoke runs `bin/consult smoke`, not
   `bin/consult splash`) but the *first-run hook* firing splash from
   `main()` before dispatch (per Analyst §5, item 4) must not fire for the
   `smoke` command either, or `smoke-green` regresses. Flag explicitly for
   the Builder: gate the first-run hook on an allowlist of commands (or a
   denylist including `smoke`, `help`, `checks`), not a blanket "before the
   case statement."

### P4 — `lib/onboarding.sh` non-interactive cold-start — SURVIVE

Solid, matches G3/G6, shares the state-root seam with P3 (see above). No
independent objection. One addition: `onboarding-next-action` requires the
transcript's final line to name a `consult …` command that **itself exits
0 when run** — this means onboarding's suggested next command cannot be
`consult score <client>` or anything requiring a provider/repo that may not
exist in a cold clean-state-root test; pick something guaranteed cheap and
successful (e.g. `consult help` or `consult runtime`), or the check fails
on environments without a runtime installed.

### P5 — Expand agent detection ≥10, beyond PATH, `--json`, versions, alias `agents` — SURVIVE

Verified directly: `lib/provider.sh:22` catalogs exactly **6** names
(`agent claude codex opencode gemini cursor`), `runtime_detect` is
PATH-only (`command -v`, `lib/provider.sh:15-17`), there is no `--json`,
no version probing, no `bin/consult agents` command in the
`case` dispatch (`bin/consult:488-527`). Every claimed gap is real. This is
the Analyst's "closest to done" area and the highest-confidence item on the
list — but three implementation constraints the one-liner omits:

1. **Stay inside `lib/provider.sh`.** A second detection module is an
   explicit critical failure (`BENCHMARK-CONTRACT.md:358-369`, item 6:
   "second runtime-detection module added"; invariant 4). The ≥10-agent
   catalog, the install-dir scan, and the version probes all belong in the
   existing file, not a new `lib/agents.sh`.
2. **Per-agent version flags differ** (`--version` vs `-v` vs a subcommand)
   and must each be individually time-bounded (`detect-versions` requires
   ≤3s per probe, ≤10s total, never hangs) — this is more than a loop
   around one flag; budget for a small per-agent probe table.
3. **`detect-no-false-positive` is a GATE** using an injected
   non-executable file named after a catalog agent on a temp `PATH` — the
   detector must check executability, not just name-match, which the
   current `command -v`-based check likely already gets right, but the new
   install-dir scan (checking fixed directories directly, not via `PATH`)
   must apply the same executable-bit check or it regresses this gate while
   fixing `detect-beyond-path`.

### P6 — Wire `checks` dispatch + add splash/onboarding/agents to help+dispatch — SPLIT: survive (6a), cut-as-standalone (6b)

Verified the bug directly: `cmd_checks` (`bin/consult:276-288`) calls
`engagement_scorer()` which reads `contract.json`'s `scorer` field
(`"checks"` for harness-cli), then **unconditionally invokes
`lib/run-checks.sh`** — the client `ofc-v1` (Maya Chen/People Ops) suite,
never `lib/harness-cli-checks.sh` / the `checks_runner` field the Benchmark
Designer already wrote into `contract.json:5`. Today, `bin/consult checks
harness-cli` would run the **wrong suite** and self-evidently fail
`checks-dispatch-routes-engagement`. This is real and cheap to fix (read
`checks_runner` from `contract.json`, dispatch to it when present).

**6a (dispatch bugfix) — SURVIVE, and reclassify as early/cheap, not
mid-list.** It blocks the engagement's own ability to score itself via
`bin/consult checks harness-cli` / `bin/consult score harness-cli` (both
are "Required verification commands," `BENCHMARK-CONTRACT.md:121-126`).
Land it as the **first post-baseline commit**, bundled with P1 or alone —
either way, before relying on `consult checks harness-cli` for any later
iteration's self-check.

**6b ("add splash/onboarding/agents to help+dispatch") — CUT as a
standalone late item.** `help-lists-every-command` and
`every-command-exits-zero` are both **GATEs**
(`CHECK-CATALOG.md:95-96`) — a dimension with a failed gate caps at ≤5 by
the band table regardless of how many other checks pass
(`BENCHMARK-CONTRACT.md:88-89`). If P3/P4/P5 land their commands without
simultaneously updating `cmd_help` and adding the matching README line,
**every iteration in between** scores `feature-reachability` at ≤4.0/2.0
and risks `readme-matches-cli` (also a GATE) failing too. Treating "wire it
into help" as a separate follow-up item is how a benchmark run gets voided
by gate cascades for no reason. **Fold help/dispatch/README wiring into
each feature's own Definition of Done (P3, P4, P5 each ship with their
help line + README line in the same commit that adds the command.)**

### P7 — Docs: README first-run, CLI-not-TUI, env vars, skills-live — SURVIVE, but partly continuous not one-shot

Verified: `rg -in '\bTUI\b'` across `README.md ARCHITECTURE.md AGENTS.md
JUDGMENT.md CONSTITUTION.md docs/ skills/ bin/ lib/ tests/` returns **zero
hits** — `docs-cli-not-tui` is likely already clean today, good news, low
risk there. But `README.md`'s command table (`README.md:11-24`) is
**already missing `status` and `run`** relative to `cmd_help`'s list
(`bin/consult:87-113`: `help status org memory smoke runtime harness-checks
gh skill judge score checks bench run report`) — `readme-matches-cli`
(**GATE**) may already be failing at baseline, independent of any new
feature. This needs fixing regardless of P1–P6, and should not wait for a
single "documentation pass" at the end: every iteration that adds a
command (P3 splash, P4 onboarding, P5 agents) must add its README line in
the same commit (see P6 rebuttal). Reserve a **final consolidation pass**
in the last iteration for the things that can only be finished once
everything else exists: `readme-onboarding-section` (needs onboarding +
splash + agents commands to reference), `docs-skills-live`, and the
`no-overclaim` claim→check mapping file (`product-clarity`, **GATE** — must
map every README/help claim to a check id that **currently passes**, so it
can only be finalized last).

### P8 — Chatbot REPL loop (persistent chat session like OpenCode) — CUT

**Zero benchmark backing.** I checked all 49 check ids in
`CHECK-CATALOG.md` — none require a persistent session, a REPL loop, or
multi-turn chat state. The nine dimensions score chrome
(`visual-cli-clarity`), a bounded one-shot animation (`splash-animation`),
a one-shot cold-start wizard (`onboarding-ease`), detection, dispatch
coverage, skills, docs, dev experience, and identity clarity — every one of
these is satisfiable by the existing **one-shot argv-dispatch** model
(`bin/consult:486-529`) with new sourced commands. "Chatbot-style" in the
mission (`engagement.md:14-20`) is operationalized by the contract *only*
as visual chrome + calm identity, not as an interaction-model change — and
the frozen contract, not the mission prose, is what scores
(`CONSTITUTION.md:17-19`, "Never move the goalposts"; contract is the
operative artifact once frozen).

**Constitution risk — flagged, not overruled:**
- **Architecture escalation.** Converting `bin/consult` from stateless
  per-invocation dispatch to a persistent stateful session loop is exactly
  the kind of change the Repository Analyst already flagged as
  escalation-risk (`repository-analyst.md §4`, "Architecture escalation
  risk... would be an architecture change — explicitly an escalation item
  per `CONSTITUTION.md:26-33`"). The autonomy table
  (`CONSTITUTION.md:26-33`) lists "Architecture changes" under **Escalate
  to owner**, not auto-apply.
- **Complexity must justify itself** (`CONSTITUTION.md:12-14`, Principle
  2) — a REPL loop with zero checks behind it is complexity with no
  measurable benefit under this contract. Building it *cannot* move any
  frozen score, by construction.
- **Iteration budget is the scarce resource.** Only 5 improvement
  iterations exist for 9 dimensions / 49 checks, several already tight
  (P1's live-check variance, P3+P4's shared seam). Spending any of the 5 on
  an unscored feature directly reduces the odds of hitting ≥9.0 everywhere
  by iter-5, which is the actual definition of done
  (`CONSTITUTION.md:39-43`).

**Recommendation:** do not implement inside this engagement. If the owner
still wants it, it belongs in `proposed-benchmark-changes.md` as a proposal
for a successor contract (`harness-cli-v2`) with its own checks defined
first — consistent with "never move the goalposts"
(`BENCHMARK-CONTRACT.md:431-436`, amendments require a new contract id and
apply only to engagements opened after).

---

## 2. Constitution risk summary

| Risk | Item | Verdict |
|---|---|---|
| Architecture escalation | P8 (REPL loop) | **Blocked** — no checks back it; matches Analyst's own G1 escalation warning |
| Second runtime-detection module (critical failure #6) | P5 | Guardrail: must extend `lib/provider.sh` in place, not a new file |
| Gate-cascade from split delivery | P6b (help/dispatch as separate step) | Redistributed into P3/P4/P5's own Definition of Done |
| Baseline-guard violation | Implicit P0 skipped | **Blocking** — must land and be scored before P1–P7 |
| Smoke-must-not-hang regression (`MEMORY.md:74-76`) | P3 (splash first-run hook) | Guardrail: hook must denylist `smoke`/`help`/`checks`, not fire blanket-before-dispatch |
| Undersold design effort | P2 (theme ≤2 accents) | Not a blocker, but Builder scope must include the color-collapse decision, not just file extraction |
| Doc drift / GATE risk | P7 partially deferred to "last" | Redistributed: README/help updates per-feature, final pass only for cross-cutting items (`no-overclaim`, onboarding section) |

No item proposes a daemon, database, network service, second `clients/`
tree, or moving the provider seam out of `lib/provider.sh` — the other six
invariants (`BENCHMARK-CONTRACT.md:40-53`) are not at risk from P1–P7 as
scoped.

---

## 3. Recommended iteration sequencing (5 improvement iterations, post-baseline)

**Pre-req (not an improvement iteration — measurement scaffold only, before
iter-0):** Test Engineer ships `lib/harness-cli-checks.sh` (49 ids) +
`tmp-projects/proj-a`, `proj-b` + `GUIDANCE.md` + claim-mapping skeleton.
**Then iter-0 is scored on the CLI exactly as it is today** (expect very
low scores across most dimensions — that is the correct, honest baseline).

| Iter | Scope | Targets | Notes |
|---|---|---|---|
| **1** | P6a (checks-dispatch bugfix, do first/cheap) + P1 (skills → real `provider_ask`, incl. `docs/skills.md` truth line) + P2 (theme.sh, ≤2 accents) | `skills-llm-reality`, `developer-experience` (`checks-dispatch-routes-engagement`, `harness-cli-checks-runner`), `visual-cli-clarity` | P1 and P2 touch disjoint files (`lib/run-skill.sh` vs `bin/consult:14-24`+`lib/theme.sh`) — safe to bundle. Do not expect `skills-llm-reality` to hit 9.5 first pass; treat 6–8 as an acceptable iter-1 outcome given 5 LIVE checks. |
| **2** | P4 (onboarding) + shared state-root override seam (built once, reused by iter-3) | `onboarding-ease`, partial `feature-reachability`/`documentation` (help+README line for `onboarding` shipped same commit) | Pick a guaranteed-cheap `onboarding-next-action` suggestion (e.g. `consult help`), not one requiring a provider/repo. |
| **3** | P3 (splash, reusing iter-2's state-root seam) | `splash-animation`, same feature-reachability/documentation upkeep | Denylist `smoke`/`help`/`checks` from the first-run hook explicitly; verify `tests/consult-smoke.sh` still exits 0 and stays instant. |
| **4** | P5 (agent detection ≥10, install-dir scan, `--json`, versions, `agents` alias) | `agent-detection`, same feature-reachability/documentation upkeep | Extend `lib/provider.sh` only — no second detection module. |
| **5** | Hardening/consolidation: fix any residual gate failures carried from iters 1–4 first, then P7's cross-cutting-only remainder (`readme-onboarding-section`, `docs-skills-live` if not already true, final `no-overclaim` claim→check mapping) + full `feature-reachability`/`developer-experience` sweep (`scripts-parse-clean`, `errors-name-the-fix`, `no-hidden-env-requirements`) | Whatever is still <9.0 + `product-clarity`, `documentation` | Deliberately reserved as a buffer, not new scope — this is the iteration most likely to be needed for fix-ups given zero slack elsewhere. If iters 1–4 all land clean, use it for `skills-outputs-project-specific`/live-check hardening (the least deterministic checks in the whole suite). |

**Why this order, not the Principal's P1→P8 order:** the dispatch bugfix
(6a) must precede any reliance on `consult checks harness-cli` for
self-verification; P3/P4 share a seam so should be adjacent; P5 is the
most self-contained/lowest-risk item and can absorb schedule slip without
blocking anything else; documentation is deliberately *not* a single
late-item pass because `readme-matches-cli` and `help-lists-every-command`
are GATEs that must stay green every iteration, not just the last one.

**P8 does not get an iteration.** Cutting it is what buys iteration 5 as a
genuine buffer instead of a ninth feature crammed into a fixed 5-slot
budget.

---

## 4. Assignments update

Updated `subagents/assignments.md`: `Critic (priority debate)` → **done**,
pointing at this file.
