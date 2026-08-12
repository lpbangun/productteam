# Build 4 Critic Verdict — Product direction (Guided path)
Status: **ACCEPT-WITH-NITS**
Date: 2026-08-11

## Done-when audit
- [x] **Guided: named Principal/Analyst propose ≤N directions with tradeoffs + expected lift; no Implement until selection exists** — `lib/direction-gate.sh`: `direction_propose` / `direction_propose_refusal` enforce Guided mode + `CONSULT_DIRECTION_MAX` (default 3, clamp 1–5); each direction records `title`, `tradeoffs`, `expected_lift`, optional `evidence_paths`, and `proposed_by` display name; `judgment_implement_refusal` (Guided) refuses until `selection.json` is complete (`direction-path-smoke`: `direction-guided-implement-refuse`; `judgment-gate-smoke`: `gate-guided-refuse`).
- [x] **Critic rebuttal before Builder seal** — `judgment_critic_rebuttal_refusal` blocks `role_seal`, `role_seal_refusal`, and Builder `role_invoke` when Guided and rebuttal missing/REJECT/wrong-iter (`role-envelope.sh` lines 82–85, 104–106, 204–206); smoke: `direction-seal-no-rebuttal`, `direction-seal-reject`, `direction-seal-accept`.
- [x] **Seal = smallest slice of selected direction only** — `role_seal_direction_refusal` requires sealed Builder input to contain bound direction substring; smoke: `direction-seal-no-direction-cite` refuses uncited input, `direction-seal-accept` passes cited input. Semantic “smallest diff” is process/human (rebuttal text), not machine-scored — acceptable for this build.
- [x] **Challenge/Override gates still enforced** — `judgment-gate.sh` unchanged for Challenge/Override; `direction-path-smoke`: `direction-challenge-still-enforced`, `direction-override-still-enforced`; `judgment-gate-smoke`: all 8 legacy gate paths PASS.
- [x] **idea → select → seal → score/close works with named cards visible in artifacts** — smoke covers propose → select → rebut → seal → Builder invoke (provider refuse after seal); named cards in artifacts verified: `proposals.json` `proposed_by` team `[Kai (Principal), Meridian (Analyst)]`, per-direction `proposed_by`, `selection.json` `display_name: Kai`, `critic-rebuttal.json` `display_name: Vesper`, `role: Critic` (manual probe + smoke list assertions). Full Analyst stamp → score → `role close` not exercised in direction-path smoke (see nit #1).

## Verification run
| Check | Result |
|-------|--------|
| `bash tests/direction-path-smoke.sh` | **PASS** (13/13) |
| `bash tests/judgment-gate-smoke.sh` | **PASS** (8/8) |
| `tests/consult-smoke.sh` wiring | **PASS** — both smokes invoked from aggregate suite |
| Named cards in proposal artifact | **PASS** — Kai/Meridian in `proposals.json`; Kai in `selection.json` |
| Named card in rebuttal artifact | **PASS** — Vesper in `critic-rebuttal.json` (probe; not asserted in smoke) |
| Challenge/Override regression | **PASS** — minimal cross-mode probes in direction-path smoke |
| Wiring: `bin/productteam` sources `direction-gate.sh` | **PASS** |
| Wiring: `role-envelope.sh` rebuttal + direction cite gates | **PASS** |
| Docs: `JUDGMENT.md` Guided section | **PASS** — propose/select/rebut/seal documented |

## Findings (ordered by severity)
None blocking.

### Nits (non-blocking)
1. **Smoke gap: end-to-end score/close** — `direction-path-smoke.sh` stops at Builder invoke (provider refuse); does not run Analyst stamp → `bench score --iter` → Critic envelope → `role close`. Done-when “score/close works” is satisfied by existing Build 1 role-envelope smokes + direction gates composing, but not proven in one Guided-direction transcript.
2. **Smoke gap: Vesper assertion** — rebuttal artifact writes `display_name: Vesper` via `agent_card_for_role Critic` (fallback literal); smoke never `jq`-checks `critic-rebuttal.json` display name.
3. **`gate implement` vs rebuttal ordering** — after selection, `productteam gate … implement` is **allowed** without Critic rebuttal; rebuttal is enforced only at Builder seal/invoke. Matches done-when wording (“before Builder seal”) but operators may read “implement” as the full build step — consider doc note or optional implement-time rebuttal check if confusion appears.
4. **Per-direction `proposed_by` is display string only** — team roster carries `{role, display_name}` objects; individual directions store `"proposed_by": "Kai"` not full card overlay. Sufficient for list/audit; machine consumers cannot recover role from direction row alone.
5. **Inspect pack omits proposals/rebuttal** — `inspect_derive_pack` does not surface `judgment/proposals.json` or `critic-rebuttal.json`; visibility is CLI `direction list` + artifact paths. Acceptable unless Build 5 wants inspect-driven direction status.
6. **Rebuttal iter mismatch untested** — code refuses wrong `iter` in `critic-rebuttal.json`; no smoke line.
7. **`direction clear --i-am-owner` untested** — owner-gated scratch reset implemented; no smoke.
8. **Default proposer `--by Meridian`** — sensible Analyst default; Principal proposals require explicit `--by Kai`.

## Org note
Clean extension of `judgment-gate.sh`: Guided gains a pre-selection proposal plane (`proposals.json`) and a pre-seal Critic plane (`critic-rebuttal.json`) without touching Directive/Challenge/Override semantics. Named cards reuse Build 1 `agent-cards.sh` with sane fallbacks (Kai/Meridian/Vesper). Critic rebuttal is Guided-only — no fifth worker, no second orchestrator. `bin/consult` shim keeps smoke compatibility.

## Gate for Build 5
**OPEN** — no must-fix items. Optional before Build 5: (a) one smoke line asserting `critic-rebuttal.json` carries `display_name: Vesper`, (b) Guided-direction happy-path through stamp/score/close using existing role-envelope markers, (c) expose proposal/rebuttal summary on inspect pack if Build 5 needs machine-readable direction state, (d) document that `gate implement` is selection-only while Builder seal requires rebuttal.
