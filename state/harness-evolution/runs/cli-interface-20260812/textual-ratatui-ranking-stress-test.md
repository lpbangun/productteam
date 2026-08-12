# Textual + Ratatui ranking stress-test

**Role:** Critic (adversarial) / FinalistCritic
**Date:** 2026-08-12
**Against:** MigrationScout claim that **Textual + Ratatui** are the top two TUI stacks for *both* UX prototype value *and* eventual full rewrite with least headache; and that this pairing is ready to guide migration.
**Evidence base:** `framework-comparison.md`, `architecture-decision.md`, `dependency-packaging-report.md`, `charm-ranking-stress-test.md`, `MEMORY.md` 2026-08-12 framework gate, RepoScout + TextualResearch / RatatuiResearch / OpenTUIResearch / CharmResearch / MigrationScout (live).

---

## Verdicts

| Claim | Decision |
|-------|----------|
| Textual + Ratatui are the best two **for both** prototype value and least-headache rewrite | **REJECT** |
| Migration = optional frontend over Bash authority; do **not** rewrite domain gates/state | **ACCEPT** |
| Textual uniquely has multiline + scroll + overlays + palette + streaming + **a11y** + Pilot | **REJECT** (a11y clause is false; uniqueness overstated) |
| OpenTUI/Charm already “lost forever,” so they cannot displace either finalist | **REJECT** (they lost *retention* on measured spikes; ranking for a *future* spike is a different question) |

Primary product answer remains: **keep Bash** until a measured interactive defect exists. This document only ranks *candidates if* a spike is later authorized.

---

## Corrected ranking (forced single top-two across both axes)

| Rank | Candidate | Why it holds |
|------|-----------|--------------|
| **1** | **Textual** (pin exact, e.g. 8.2.8) | Only finalist on a **shipped** language (`python3` already used by `bin/productteam` bench path + check runners). Native TextArea / RichLog / MarkdownStream / ModalScreen / command palette / Workers + strongest Pilot/`run_test` story. Least new-toolchain headache for an optional frontend. |
| **2** | **OpenTUI** (pin exact; Bun path only) | **Displaces Ratatui.** Host already has Bun 1.3.14; chat-shaped primitives (ScrollBox sticky bottom, TextareaRenderable, zIndex overlays, `@opentui/keymap`); **in-repo spike already measured** (31/31, live JSON adapter). Prototype credibility is higher than Ratatui’s immediate-mode + missing `rustc` assembly tax. |

| Rank | Displaced / deferred | Why |
|------|----------------------|-----|
| 3 | Charm / Bubble Tea v2 | Best *compiled* chat example + Layer compositor, but **Go ≥1.25 absent** on this host → not “least headache.” Does **not** beat Textual. May beat Ratatui only on a *Go-accepted* rewrite track. |
| 4 | Ratatui 0.30.x | Best buffer/Unicode/TestBackend and static-binary story **after** rustup — but **no Rust toolchain here**, no core textarea (org fork `ratatui-textarea`), no overlays/focus/palette, no a11y. Worst prototype time-to-credible-chat of the finalists. |
| — | Ink 7.1.1 | Already measured; Node 22 present; still failed retention (packaging/RSS/net-deletion/streaming/a11y). Remains a measurement reference, not a top-two pick. |
| — | Bash CLI + REPL | **Still primary.** Ranking above is contingent candidates only. |

### Axis split (do not collapse these)

| Axis | #1 | #2 | Displacement note |
|------|----|----|-------------------|
| **UX prototype value** | Textual | **OpenTUI** | OpenTUI displaces Ratatui. Charm does not (no `go`). |
| **Full rewrite, least headache** | Textual **optional frontend only** | *No second stack* | Charm/Ratatui both introduce a missing language class → they increase headache. If owner later mandates a static binary, choose then: Ratatui (packaging) vs Charm (chat widgets) — **neither is #2 today**. |

---

## Why OpenTUI displaces Ratatui (and Charm does not displace Textual)

### OpenTUI → outranks Ratatui on the dual brief
1. **Prototype shape:** OpenTUI already has transcript/composer/overlay/keymap primitives; Ratatui requires composing Paragraph/List/Clear + `ratatui-textarea` fork + custom focus/palette — more custom code before a chat looks real.
2. **Host reality:** `bun` is present; `rustc`/`cargo` are not. Ratatui’s “best packaging” is theoretical until rustup (≥1.88, large first build) becomes a product dependency.
3. **Measured precedent:** OpenTUI spike consumed the real JSON/TSV boundary here (`framework-comparison.md`). Ratatui has **zero** in-repo measurement. Treating an unspiked stack as #2 over a measured one is the same category error Charm ranking already rejected.
4. **Retention still fails today:** OpenTUI remains **not retention-ready** (Bun/Node≥26.4 floor vs repo Node-22 conservatism, ~80 MiB tree, pre-1.0 churn, 0% Bash deletion, no provider streaming in spike, no SR proof). Displacement is for *next spike ranking*, not adoption.

### Charm → does **not** displace Textual
1. Go ≥1.25 (huh/glamour) is a **new** distribution floor; Textual rides existing `python3`.
2. Chat a11y is not a Charm win (Huh forms only). Textual is also **not** an a11y win (see below) — so Charm cannot claim a11y superiority over Textual.
3. Same frozen retention gates Ink/OpenTUI already failed (need, signal, a11y, packaging, ≥25–30% net deletion).
4. Charm **can** displace Ratatui on a future *compiled-language* shortlist (first-party chat example + lipgloss Layer/Compositor), but only after owner accepts Go — not under “least headache.”

---

## Material falsehood in the proposed top-two rationale

MigrationScout’s uniqueness sentence credits Textual with **a11y**. TextualResearch (source-verified against Textual 8.2.8 / roadmap): screen-reader integration is **unchecked**; **zero** announcement/SR code in `src/`; **zero** accessibility CHANGELOG entries. Keyboard focus styling ≠ screen-reader contract.

Corrected: **no assessed stack** (Textual, Ratatui, OpenTUI, Charm main chat, Ink hooks aside) has proven interactive chat screen-reader compliance for this product. Ink’s `INK_SCREEN_READER` hooks remain the only partial prior art — and still failed the frozen a11y gate. Textual’s real differentiators are **Python-present + widget depth + Pilot**, not a11y.

---

## Migration conclusion — what survives challenge

**ACCEPT:** migrate only an **optional interactive frontend**; do **not** rewrite domain modules (`judgment-gate`, `direction-gate`, `engagement-state`, `role-envelope`, agent cards, style memory, experience pool, etc.). Those stay Bash + plain files behind the frozen JSON/file seams (`architecture-decision.md`).

**REJECT as understated:** “frontend ≈ 1,300 lines ⇒ easy.” Replaceable chrome is roughly `lib/repl.sh` (504) + theme/render/activity/splash (~440) + in-binary render paths (~330) ≈ **1.3–1.5k lines**, but frozen **parity/visual/smoke/harness** surfaces (~2.3k+ test lines + `harness-cli-checks.sh`) stay Bash and will keep asserting Bash glyphs, ANSI rules, and source shape. Prior Ink/OpenTUI spikes added **>1,100 lines and deleted 0** replaceable Bash — the 25–30% net-deletion gate is unreachable without an owner-approved **new** TUI contract that retires Bash chrome probes.

**REJECT:** any implication that picking Textual/Ratatui now authorizes retention. Unspiked ≠ adopted (`MEMORY.md` framework evidence gate).

---

## Precise caveats — preserving every function

A candidate may wrap UX only. **Every** of the following must remain byte/behavior-stable unless the owner amends the frozen contract (`CLI-BENCHMARK-CONTRACT.md` + `FREEZE-SHA.txt`):

1. **Registry & help** — full command table; `help --json` shape (counts/fields) unchanged.
2. **Status & inspect** — `status --json`; `inspect` regenerates `inspect-pack.json` (projection, never a second store).
3. **One-shot automation** — non-TTY / piped / `NO_COLOR` paths stay Bash-native; TUI must refuse cleanly when not a TTY (not replace one-shots).
4. **Exit codes & usage strings** — parity probes (incl. usage byte identity) remain green.
5. **ANSI contract** — exactly the allowed accents; zero ESC under redirect/`NO_COLOR`.
6. **Prompt / status glyphs** — `◆◇▸◉ ✓✗…▲○` (and related visual-contract symbols) preserved where the contract asserts them.
7. **Provider honesty** — only Bash `provider_ask` + REPL interrupt path executes/kills the agent; Ctrl+C = process-group kill (`kill -TERM -- -pid`), rc 130, partial artifact bytes+path retained, worker=failed, prompt returns. TUI must shell out; must not own the provider child.
8. **Activity authority** — `state/.cli/runs/session-*/workers.tsv` + artifacts written only by canonical CLI/REPL.
9. **Durable state** — plain files under `state/` only; atomic tmp+rename; no daemon/DB/duplicate state.
10. **Env seams** — all `CONSULT_*` behaviors preserved.
11. **Workspace D1** — non-destructive recovery only when recorded path is absent; never delete/relocate dirty/foreign worktrees.
12. **Scoring recursion guard** — `checks_self_route` / harness self-check invariants unchanged.
13. **Derived JSON** — role/gate/workspace status envelopes remain cmp-stable where tests assert.
14. **App-mode stdout** — Textual (and peers) capture stdout in app mode; one-shot commands must **not** start the App, or automation JSON breaks.

“Preserve every function” ≠ “reimplement every function inside the TUI.” It means **no behavioral hole** in the Bash authority surface while the optional UI exists.

---

## Non-negotiable gates (unchanged bar)

1. Need — archived recurring Bash defect (multiline / scroll-focus / streaming / Unicode-repaint). No defect → no spike.
2. Boundary — read JSON/files; mutate only via `productteam …`.
3. Signal — real provider turn + group kill + partial retention + failed worker + prompt return.
4. Non-TTY / CI — interactive refuse; automation stays Bash.
5. Accessibility — interactive SR (or accepted equivalent) for **chat**, not form demos.
6. Packaging — measured size/cold-start/RSS vs Bash; document runtime matrix (Textual: pin + `textual-dev` separate; OpenTUI: Bun or Node≥26.4 FFI; never silent native surprises).
7. Net deletion — ≥25–30% replaceable Bash UI lines **after** adapters/tests, or an owner-amended TUI contract that retires those lines honestly.
8. Critic ACCEPT on 1–7 or delete the spike tree.

---

## Migration stop conditions

Stop / delete / refuse further framework work when any of:

- No measured Bash interactive defect (current default — **stop now**).
- Spike greens unit/Pilot tests but fails signal, a11y, non-TTY, packaging, or net-deletion.
- Proposal rewrites domain gates/state “for convenience,” or moves `provider_ask` into the TUI without equivalent proof.
- Textual spike starts the App on one-shot paths (breaks `--json` / redirect contracts).
- OpenTUI spike requires Node 22 live renderer (it will refuse — Bun-only path must be an **explicit** owner-accepted runtime, not smuggled).
- Ratatui/Charm spike requested while `rustc`/`go` absent without documenting that toolchain as a product dependency first.
- Ranking docs treat librarian maturity tables as substitutes for in-repo measurements (Textual/Ratatui today are desktop assessments only).
- Iteration budget would burn a third unspiked stack before OpenTUI’s measured failure modes or a real Bash defect is addressed.
- “Preserve every function” is interpreted as dual-writing `workers.tsv` / scores from the TUI.

---

## Bottom line

- **REJECT** Textual+Ratatui as the dual-axis top two.
- **Ranked top two (contingent):** **1 Textual · 2 OpenTUI**.
- **OpenTUI displaces Ratatui** on prototype value and on a forced joint ranking; **Charm does not displace Textual**; Charm may later displace Ratatui only on an owner-accepted Go binary track.
- **ACCEPT** optional-frontend / no-domain-rewrite migration shape — with the net-deletion and frozen-test caveats above.
- **Do not migrate** until need + gates say so; Bash remains primary.
