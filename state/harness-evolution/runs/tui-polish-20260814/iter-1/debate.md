# Critic debate — iteration 1 (pre-implementation)

**Role:** Critic (adversarial, read-only)
**Against:** Principal iter-1 proposal — "single coupled core-state/rendering slice": filtered scored-session home + cwd/latest-score header; exact role token/turn chrome; session-local focusable/clickable target chips with `@Principal` default; dedicated real `workers.tsv` activity strip and state-dependent footer; explicit compact resize behavior; provider role argv + selected card prompt. Expected lift D02–D07, D09, D15, D18, D23–D24 while "preserving current argv/interrupt behavior." Docks (ask/confirm/evidence), splash, and their tests deferred "unless the worker can include a dependency-free mechanical hook without broadening the diff."
**Authority:** `frozen-benchmark.md` (immutable), `inspect.md`, `GOAL-LOOP.md`.
**Stance:** An item survives only with a concrete mandatory-dimension lift. No implementation, no scoring, no validation commands run.

---

## Overall verdict

**REVISE-SLICE.**

The direction is correct — stop seeding full `productteam status` prose, stop rendering `harness-cli`/`Directive`, stop hardcoding `Analyst` — but the proposal is not "the single coupled slice." It is **five distinct widget regions** (home, header, turn rails, a *new* activity region, footer), a **Bash signature change**, a **theme/test-contract change**, and a **live-provider interrupt re-proof**, claiming **11 mandatory dimensions** in one 30-minute Worker pass. That is the precise failure mode this loop already recorded: the prior cockpit Worker "timed out at 30m after writing the tree" (`GOAL-LOOP.md:90`; `tui-cockpit-20260813/lessons.md`), and its own iter-1 gate scored only dims 3/7/8 below 9 and still needed three iterations to converge on a *smaller* surface (`tui-cockpit-20260813/iter-1/reviewer-gate.md`).

| Drift | Proposal | Reality on the ground |
|---|---|---|
| Slice size | "single coupled slice" | 11 dims, 5 regions, `app.py` (707 lines) touched in seed + header + chips + compose + resize + provider thread + composer simultaneously |
| Activity/footer | claimed D06/D09/D15 in this pass | non-vacuous evidence for these requires a **live role-argv provider turn**, which is D18/D24 — also in this pass (self-referential) |
| Compact resize | claimed D07 in this pass | "compact cap" needs a live activity row to prove `1+N`; with no workers row the cap is vacuously true → missing evidence = 0 (`frozen-benchmark.md` §8) |
| "preserving interrupt" | asserted | changing `provider_turn.sh`'s signature + sourcing `agent-cards.sh` is *exactly* where the INT trap regresses; no re-proof allocated |
| Escape clause | "dependency-free mechanical hook" | undefined; any ask/confirm/evidence/splash hook broadens the diff and drags D08/D12/D13/D16/D25/D26 into a slice that did not plan their evidence |

---

## Item-by-item rebuttal

### 1. Filtered scored-session home + cwd/latest-score header

| Verdict | **SURVIVE — anchor of the slice** |
|---|---|
| Dimension lift | **D03** (filtered home), **D05** (header), **D23** (home/header data seam) |

This is the single most visible lie and the right anchor (`inspect.md` §"Layout, home, header"). Today `_seed` runs prose `status` into the transcript and `_pick_engagement` explicitly prefers `harness-cli` (`app.py:245-282`); `_render_header` renders `ProductTeam · {engagement} · {mode} · {score}` (`app.py:319-334`).

**Hidden dependency (must be named, not implied):** "cwd project projection" has no code path today. `_pick_engagement`/`_read_overall` key off engagement *names* from `status --json`, not the process cwd (`app.py:274-304`). The freeze requires "cwd project" and "latest `runs/iter-*/scores.json` overall for the cwd project" (`frozen-benchmark.md` Q1/Q3, D23), but the cwd→engagement/score mapping is undefined. The Worker will have to invent it; if it guesses, D05/D23 evidence won't match the Reviewer's reading. Bind this slice to an explicit mapping rule (cwd basename → engagement, or first scored global project) before the Worker starts.

**Scope note:** exclusions `*smoke*` `*run-loop*` `*gate-smoke*` `*overnight-rehears*` and the honest empty state are mandatory; they are cheap but must be asserted, not assumed.

### 2. Exact role token + turn chrome

| Verdict | **SURVIVE — split "static identity chrome" from "speaking-turn gating"** |
|---|---|
| Dimension lift | **D02** (tokens/glyphs), **D04** (identity), and **D19** (dim timestamps) *only if* timestamps ship |

**Churn (hidden acceptance prerequisite):** `tests/test_layout.py::test_two_accents_only_in_css_and_theme` currently forbids the owner-locked role hues (`test_layout.py:59-62`; `inspect.md` §"Tests and snapshots"). The freeze *requires* amending it cockpit-only while **adding** a separate Bash two-accent assertion (`frozen-benchmark.md` §3; `GOAL-LOOP.md` "Code placement"). The proposal claims D02 but never names this test edit. If the Worker adds hues to `theme.py`/CSS without the amendment, `test_layout.py` — the exact file a Worker is allowed to run — fails immediately. The slice must name: (a) the amendment, (b) the new `chk_cli_accent_budget`/`lib/theme.sh`-side assertion, as first-class items.

**Hidden dimension:** "turn chrome" implies dim timestamps (D19) and the You-rail on bare Enter. D19 is not in the claimed lift; either pull it in (it rides on the same rails) or state it is out and keep timestamps absent — but do not ship half a rail with unstyled timestamps and leave D19 ambiguous.

**Split line:** the *static* You rail + role label/rail/token infrastructure belongs here (pure presentation, no provider). The *role-colored speaking turn that begins only when a role emits text* is **D09** and belongs with activity — it is not testable without a live workers row.

### 3. Session-local focusable/clickable target chips with `@Principal` default

| Verdict | **DEFER to the follow-on slice** |
|---|---|
| Dimension lift | **D18** (targeting) |

This is control work (focus traversal, click handling, `@Role` composer prefix, session-local selection state), not a static render. It is only *honestly* testable end-to-end once the role argv provider path exists — otherwise "selecting @Builder" has no observable consequence and D18's "role argv / no Analyst hardcode" evidence is missing. Rendering role-hued chips is D02/D04 (item 2); making them **focusable/clickable targets** is D18 and must not ride here. Bundling it inflates the diff against a 707-line `app.py` and a 30-minute cap.

### 4. Dedicated real `workers.tsv` activity strip + state-dependent footer

| Verdict | **DEFER — self-referential; cannot be scored ≥9 in this pass** |
|---|---|
| Dimension lift | **D06** (activity), **D09** (thinking vs speech), **D15** (footer), **D24** (activity/provider seam) |

Three problems:

1. **Self-reference.** D06/D09 require a real `workers.tsv` row with `role/mission/provider/elapsed` and a running worker with an empty artifact. Those rows only appear when `provider_turn.sh` runs `activity_start "$ROLE"` — which is item 6 (D24/D18), *also in this slice*. D15's busy facts (`ctrl+c interrupt · m:ss · {provider}`, `frozen-benchmark.md` R6) likewise require a live provider turn. If the role-argv path is incomplete or flaky, **D06, D09, D15, D24 fall together to 0** — the §7 "Activity vs speech" and "Provider interrupt" rows both fail.
2. **Unclaimed D01.** The activity strip is a **new region**. `compose()` today yields header/rule/transcript/chips/dock/composer/footer with no `#activity` widget (`app.py:200-209`). Inserting it changes the global layout order that D01 ("all seven regions in locked order, activity conditional") scores — and D01 is not in the claimed lift. Adding an unclaimed-dimension change while not re-verifying D01 is an acceptance hole.
3. **30m budget.** A braille spinner, elapsed `m:ss`, mission/provider fact, and 3/2/1+N caps (`frozen-benchmark.md` Q4, activity seam) is a real widget with a poll loop; combined with items 1–3 and 5–6 it is not one Worker's pass.

### 5. Explicit compact resize behavior

| Verdict | **DEFER (or at minimum re-sequence after activity exists)** |
|---|---|
| Dimension lift | **D07** (compact and resize) |

The four-size reachability and the `80→40→80` SIGWINCH sequence are Principal-run PTY evidence, not Worker scope (`GOAL-LOOP.md` "Principal runs the long tests"). The compact header `ProductTeam {score}` and composer retention are self-contained, but D07's "compact cap" (one line + `+N`) is **vacuous with zero activity rows** — the §7 "PTY sizes + SIGWINCH" row requires proving the cap, and the freeze scores missing evidence 0. Shipping compact resize before the activity strip exists guarantees D07 can't reach 9 this iteration.

### 6. Provider role argv + selected card prompt

| Verdict | **DEFER with the follow-on slice, but bind it to an interrupt re-proof** |
|---|---|
| Dimension lift | **D18** (role argv, no hardcode), **D24** (provider seam) |

**Acceptance hole:** the proposal asserts "preserving current argv/interrupt behavior" while simultaneously changing the exact surface that owns interrupt behavior. `provider_turn.sh` is currently `ROOT PROMPT` and hardcodes `activity_start Analyst` (`provider_turn.sh:26`); `_provider_thread` launches `["bash", PROVIDER_TURN_SH, ROOT, prompt]` with no role (`app.py:594-601`). The freeze requires `ROOT PROMPT ROLE`, `activity_start "$ROLE"`, and prepending `agent_card_prompt_block` (`lib/agent-cards.sh:199`) with a Principal default (`frozen-benchmark.md` provider-turn seam; D24). Changing the signature and sourcing a new module is *precisely* where the `set -m`/process-group/INT trap can regress. "Preserving" is not a testable claim — the §7 "Provider interrupt" row must be re-proven after the change, and the proposal does not allocate that evidence. Any slice touching this signature must carry the interrupt re-proof as a named acceptance unit.

### 7. Escape clause — "dependency-free mechanical hook" for docks/splash

| Verdict | **CUT** |
|---|---|
| Dimension lift | none |

Undefined optional scope inside a frozen 5-iteration loop under a 30-minute Worker cap is exactly how a Worker burns budget on a partial ask/confirm/evidence/splash "hook" that then needs its own evidence for D08/D12/D13/D16/D25/D26 — none of which the slice planned. Delete the clause. Docks and splash are categorically out of iter-1.

---

## Smallest coherent implementation boundary

Ship **one** slice now; hand the rest to a second Worker.

### Iter-1 (revised): identity + honest-state presentation

| Scope | Files | Dimension lift |
|---|---|---|
| Filtered home (≤3 scored rows, exclusion globs, honest empty, display-only) | `lib/tui/app.py` (`_seed`, `_seed_header`, `_pick_engagement`, `_read_overall`) | D03, D23 |
| Wide header `▣─▣─▣ ProductTeam · {cwd} · {score}`, no `harness-cli`/`Directive`; define the cwd→score mapping | `lib/tui/app.py` (`_render_header`) | D05, D23 |
| Exact role hues + glyphs in `theme.py`/CSS; no cyan; Bash two-accent preserved | `lib/tui/theme.py`, `app.py` CSS | D02 |
| Static identity chrome: You gray rail + mute label on bare Enter; role-colored label/rail/chip render; dim timestamps | `lib/tui/app.py` (`_echo`, `submit_composer`, CSS), `theme.py` | D04 (+D19) |
| Test-contract amendment: cockpit-only hue allowance + new Bash two-accent assertion | `lib/tui/tests/test_layout.py` | D02 gate |

**Explicitly out of iter-1:** focusable/clickable target chips + `@Role` (D18), provider role argv + card prompt (D18/D24), activity strip (D06), thinking-vs-speech gating (D09), state-dependent footer (D15), compact resize + SIGWINCH (D07), ask/confirm/evidence docks, splash, and any "mechanical hook" toward them.

### Iter-2 (follow-on, already coherent): live work + control

Targeting (D18) → provider role argv + card prompt + interrupt re-proof (D18/D24) → activity strip + thinking-vs-speech (D06/D09) → state-dependent footer (D15) → compact + resize (D07). This sequence is genuinely coupled: activity is only honest once role argv exists, and the compact cap is only non-vacuous once activity exists. It is still two tight passes, not one.

---

## Missing proof / untested behavior (why the 11-dim claim fails today)

1. **No non-vacuous activity evidence exists.** There is no live `workers.tsv` row produced by a role-argv turn in the repo today; D06/D09/D15/D24's 10.0 standard ("real workers.tsv activity … elapsed m:ss … no fake agent message") has no current artifact to cite, so any claim now is unbacked.
2. **Interrupt re-proof absent.** The §7 "Provider interrupt" row is currently green against the *old* `ROOT PROMPT` signature; nothing re-proves it after the signature/card-prompt change the proposal asserts is "preserved."
3. **Test amendment unnamed.** D02 depends on editing `test_two_accents_only_in_css_and_theme`, which the proposal neither names nor sequences.
4. **cwd→score mapping undefined.** D05/D23 require a "cwd project" projection that no code path produces today; the Worker would be inventing acceptance semantics mid-slice.
5. **D01/D29 collateral unclaimed.** The new activity region re-opens D01 (global layout) and the signature change touches D29 (preservation); neither is in the claimed lift, so the Reviewer would score them with no planned evidence.

**Verdict for the Principal to hand the Worker:** **REVISE-SLICE → ACCEPT the iter-1 boundary above only.** A Worker pointed at `lib/tui/app.py` + `lib/tui/theme.py` + `lib/tui/tests/test_layout.py` for the identity/honest-state slice (D02/D03/D04/D05/D23 ± D19) is a bounded, verifiable pass. Anything larger re-enters the recorded 30-minute timeout and multi-iteration churn the loop exists to avoid.
