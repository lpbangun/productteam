# ProductTeam TUI fidelity — frozen benchmark

**Status:** FROZEN BEFORE APP EDITS  
**ACCEPT-FOR-FREEZE**  
**Run:** `tui-fidelity-20260818`  
**Date:** 2026-08-18

This file is the sole pre-implementation freeze. It is normative, not a proposal.
Do not edit it after `FREEZE-SHA.txt` is written. Rubric changes are an owner
escalation and a new run, not a mid-loop amendment.

Authority: `state/harness-evolution/runs/tui-fidelity-20260818/GOAL-LOOP.md`.
Visual sources of truth, Ask locks amending the mock where they conflict:

| source | sha256 |
|---|---|
| `state/harness-evolution/runs/tui-migration-20260812/visualizer/locked/index.html` | `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121` |
| `http://vmi3361268.tail16837d.ts.net:8788/locked/?v=1` | `2a9627cb17ec3bf41e0f205ebc8b7d6842741c5aa2670ee3f40fb70746db8121` |
| `state/harness-evolution/runs/tui-migration-20260812/visualizer/decide/index.html` | `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63` |
| `http://vmi3361268.tail16837d.ts.net:8788/decide/?v=1` | `db911fcbdb5075493f9b2fcc9e696f7c168fb32727b008a0d829458ef5fbfc63` |
| `state/harness-evolution/runs/tui-fidelity-20260818/inspection.md` | `1b0fa61c5830129ceb9b9c991232d2f6c28cc0ecdece53d5fd5be847d7d25105` |

`spikes/visualizer/classic.html` and `spikes/visualizer/app.js` are not in this
worktree. The locked and decide pages above are the visual contract.

## 0. Non-negotiables

- Do not rebuild `lib/tui/`. Do not start another frontend. Do not resurrect
  the box-drawing renderer. Do not copy any Ink-spike cyan/purple theme.
- Domain, MCP, ACP, onboarding, `bin/productteam`, and plain-file state stay.
  The TUI remains a presentation client. `productteam chat` stays the Bash REPL
  and must not launch the TUI.
- Permanent roles remain Principal / Analyst / Builder / Critic. One person,
  one profile. Keyboard is the product.
- Existing pass-bar checks **B1–B5 stay**. Never delete, rewrite, or weaken
  them. New work may **append** B6+ checks and tests. Never remove tests to
  look green. Allowed skip: `tests/tailored-resume.test.js` when
  Tectonic/Poppler are missing (that file is not part of this cockpit suite).
- `tests/visual-cli.sh` overall exit 1 is allowed **only** for the
  pre-existing missing live-provider proof. Do not mock the provider.
- Pins remain `textual==8.2.8`, `rich==15.0.0`, Python 3.12, `lib/tui/.venv`.
- If this run misses 9.0 after five implementation iterations, keep `lib/tui/`
  and write `not-converged.md`. Never delete the cockpit.

## 1. Ask locks that amend the mock

These amend conflicting mock / decide-recommendation details. They are
mandatory. Keep-locks in §2 are also mandatory.

| ID | Lock | Exact observable |
|---|---|---|
| L1 | Splash persists until Enter / any key | Boot splash does **not** auto-finish on the fifth 0.4s tick or any timer. Glow may wrap Principal → Analyst → Builder → Principal. Only Enter (continue) or any other key (skip) hides it. |
| L2 | Splash-only plane | While the splash is active: hide `#header`, `#rule`, `#activity`, and `#chips` (`display: none` or height 0). `#splash` occupies the 1fr field. Composer and footer stay visible. Transcript stays hidden. |
| L3 | Identical ASCII splash bodies | Keep the three 11×7 pure-ASCII heads in `lib/tui/theme.py` (`#` / `o` / `>`). Do not ship distinct silhouettes, SVG, `· ─ ◇ ▸`, ROBOTS_MARK, or the six-node graph. |
| L4 | `#role-prefix` width 0 unpinned | Team mode: prefix content empty **and** CSS/region width is `0`. Caret is flush left. Pinned `@Role` expands the prefix. |
| L5 | Keep header `▣─▣─▣` | Wide: `▣─▣─▣ ProductTeam · {cwd} · {score}`. Compact `<=40`: `ProductTeam {score}`. Middle head turns ok while busy, no blink. Never `harness-cli` or `Directive` in the bar. Do not redraw as `#-o->`. |
| L6 | Second click same pinned chip unpins | First click/Enter/Space on a chip pins it (`@Role` in the role hue). A second click/Enter/Space on **that same** pinned chip returns to team (unpinned, prefix width 0, no `@Role`). Clicking a different chip pins that role. |
| L7 | Always role-hued chips | Idle chips stay in their identity hues. Do not mute them to gray. |
| L8 | Home `● name …… score` | Each scored home row is `● {client} …… {overall:.1f}` — bullet, name, two-or-more leader dots / `……`, score last. No score-first layout. No iter/trend metadata. At most three rows. Same exclusions (`*smoke*`, `*run-loop*`, `*gate-smoke*`, `*overnight-rehears*`). Display only. |
| L9 | Empty busy composer; facts in footer | While work is live the composer stays empty and typeable. Facts live in the footer (`ctrl+c interrupt · m:ss · {provider}`; compact `ctrl+c · m:ss`). Do not write `team is working` into the composer. |
| L10 | No-provider first-run | If `agents --json` reports no installed runtime/provider, first paint is the dedicated copy `no installed agent` / `run /agents  or  productteam onboarding` with footer `/agents · /onboarding · /help`. Not a status dump. Not the scored-home empty copy. Chips + empty composer remain. This path is taken even when scored sessions exist. |
| L11 | Evidence dock above composer | Keep the existing bordered labelled `#dock` above the composer. Display-only. Do not move evidence into the transcript stack. Do not add file-open. |
| L12 | 40-col chips `{glyph} {role} +N` | At `<=40` columns the chip row is exactly one live/pinned identity plus a hidden count: `{glyph} {role} +N` (team default `◆ Principal +3`). Restore four role-hued chips after SIGWINCH back to 80. |
| L13 | Live chrome pack | Keep Command · HH:MM, Textual corner toast, filled `#2a2a2a` rule row, no blink, `│` role rail. Do not restore a 1px CSS hairline, full-width toast bar, or 2px block rail. |
| L14 | Status ✓/✗ on chip row **and** card | After a role completes or fails, that role's chip shows `✓ {glyph} {role}` or `✗ {glyph} {role}` **and** the attached completion card keeps its ✓/✗. Identity-only chips fail this lock. |
| L15 | Team chat: no idle `@Role` | Unpinned default is team. Composer shows no `@Role`. Bare text briefs the whole ProductTeam (Principal coordinates under the hood). |
| L16 | OMP ask chrome | Ask dock (above composer) shows a title (`Ask`), in-dock `k of n`, the literal word `recommended` (not `★`), and each option's description. Question remains one real colored role turn. Keyboard: ↑↓ Space Enter Esc. |
| L17 | OMP confirm chrome | Confirm dock shows title `Confirm write`, in-dock `k of n`, option labels `Run` / `Cancel`, and descriptions (`argv to bin/productteam. Output streams as a Command turn.` / `Nothing is spawned.`). Composer stays below. Cancel spawns nothing. |

## 2. Keep locks already shipped (must not regress)

Exact cockpit tokens and glyphs stay (`#0a0a0a` `#141414` `#2a2a2a` `#e4e4e4`
`#737373` `#8a8a8a` `#c084fc` `#60a5fa` `#22c55e` `#f59e0b` `#ef4444`;
`◆ Principal` `◇ Analyst` `▸ Builder` `◉ Critic`). No Textual cyan `$primary`.
Bash two-accent budget stays. Layout remains header / transcript 1fr /
activity-while-live / chips / dock-above-composer / composer / footer.
Docks never cover the composer. Thinking stays in the activity strip.
Markdown-lite, slash palette, confirm intercepts, toasts, non-TTY exit 2,
argv-only `bin/productteam`, and `provider_turn.sh ROOT PROMPT ROLE` stay.

## 3. Established pass bar — B1–B5 (immutable)

These already exist. Never delete, rewrite, or weaken the named nodeids,
needles, or contracts. New B6+ tests may be **appended**. Home-row *regex
text* may be retargeted to L8 (`● name …… score`) only if every existing
home coverage (cap 3, exclusions, recency, empty copy, display-only) remains.

| ID | Command | Pass rule | Freeze-day record |
|---|---|---|---|
| B1 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q` | Collects the current 73 nodeids. None of those nodeids may disappear. Count may grow only by appended B6+ tests. | exit **0** · `73 tests collected in 0.32s` |
| B2 | `lib/tui/.venv/bin/python -m pytest lib/tui/tests -q` | Every collected test passes. | exit **0** · `73 passed, 1 warning in 171.98s (0:02:51)` |
| B3 | `tests/cli-interface-parity.sh` | Prints `cli-interface parity v3: PASS`. Contract stays 33 / 18 / 15 / 6. | exit **0** · `cli-interface parity v3: PASS` |
| B4 | `tests/visual-cli.sh` | 14/14 visual IDs. Overall exit 1 allowed only for the pre-existing missing live-provider proof. | exit **1** · `14/14 pass · 0 fail · 0 skipped · live provider proof missing` |
| B5 | covered by B2 nodeids `test_four_sizes`, `test_pty_sigwinch_compact`, `test_activity_file_backed_caps_footer_and_resize` | 120×36, 80×24, 60×24, 40×20 chrome reachable; dock never covers composer; SIGWINCH 80→40→80 restores `▣─▣─▣` and keeps the composer. | included in B2 green |

B1–B5 are **not** a fidelity all-pass. They prove the shipped cockpit still
works. Fidelity all-pass also requires B6+ and every dimension in §5 ≥ 9.0.

## 4. New visual / TTY checks — B6+ (must fail today, then pass)

Parent runs the probe in §7 from the repo root. Freeze-day result: exit **1**,
**20 FAIL(S)** against today's compressed first paint. That failure is the
gate that implementation must turn green. Do not weaken needles to match
today's paint.

Today's compressed first paint (CONSULT_NO_SPLASH=1, recorded 2026-08-18):

```text
# 80x24 / 120x36 / 60x24
▣─▣─▣ ProductTeam · exp-tui-migration · —
  9.5  osint-loop-research · iter-2 · +0.0
  9.5  onboarding-flight-control · iter-2 · +0.0
  9.5  harness-cli · iter-1 · +6.1
◆ Principal ◇ Analyst ▸ Builder ◉ Critic
PREFIX=''
enter send · / commands · tab agents

# 40x20
ProductTeam —
  9.5  osint-loop-research · iter-2 · +0.0
  9.5  onboarding-flight-control · iter-2 · +0.0
  9.5  harness-cli · iter-1 · +6.1
◆ Principal ◇ Analyst ▸ Builder ◉ Critic
PREFIX=''
enter send · / commands · tab agents
```

| ID | Assertion against live `lib/tui/` | Freeze-day fail (verbatim) |
|---|---|---|
| B6 | After 2.4s with no key, splash still active; step must not finish at 5. | `FAIL B6: splash auto-finished without a key (step=5 active=False footer=Content('enter send · / commands · tab agents'))` · `FAIL B6: fifth tick finished the splash (step=5)` |
| B7 | Splash-only plane: header, rule, chips not displayed. | `FAIL B7: splash plane still shows chrome: header display=block h=1; rule display=block h=1; chips display=block h=1` |
| B8 | Unpinned `#role-prefix` style and region width 0 at 120×36, 80×24, 60×24, 40×20. | `FAIL B8: 120x36 unpinned #role-prefix width style=12 region=12 text=''` (same at 80×24, 60×24, 40×20) |
| B9 | Second click on the pinned Builder chip unpins. | `FAIL B9: second click same chip did not unpin (pinned=True target=Builder prefix='@Builder')` |
| B10 | Home rows match `● name …… score`. | `FAIL B10: compressed first paint has no \`● name …… score\` home row; rows=['  9.5  osint-loop-research · iter-2 · +0.0', '  9.5  onboarding-flight-control · iter-2 · +0.0', '  9.5  harness-cli · iter-1 · +6.1']` |
| B11 | Empty `agents --json` paints `no installed agent` first-run copy. | `FAIL B11: no dedicated no-provider first-run copy on first paint` — and a forced empty catalog still painted the scored-home rows above. |
| B12 | 40×20 chip row is `{glyph} {role} +N` (one widget). | `FAIL B12: 40x20 chips must be exactly \`{glyph} {role} +N\`; painted=[principal ◆ Principal, analyst ◇ Analyst, builder ▸ Builder, critic ◉ Critic]` |
| B13 | Done paints `✓` on the Builder chip **and** the card. | `FAIL B13: done status missing on chip row: ' ▸ Builder'; card_has_check=True` |
| B14 | Ask dock has title, in-dock `k of n`, literal `recommended`, descriptions. | `FAIL B14: OMP ask chrome missing ["literal 'recommended' in dock", 'k of n inside dock (not only footer)', 'dock title', '★ used instead of literal recommended']; rows=['● Label + rail  ★\n   Color the role label, chip, and 2px turn rail.', '○ Label only\n   Keep the rail neutral.']` |
| B15 | Confirm dock has `Confirm write`, in-dock `k of n`, descriptions. | `FAIL B15: OMP confirm chrome missing ["title 'Confirm write'", 'k of n in dock', 'option descriptions']; rows=['Run /gh merge', 'Cancel']` |
| B16 | L8 home needle at 120×36, 80×24, 60×24, 40×20; SIGWINCH 80→40 paints L12 chips; 40→80 restores `▣─▣─▣`. | `FAIL B16-120x36` / `80x24` / `60x24` / `40x20`: home lock absent · `FAIL B16-SIGWINCH-40: 80→40 chips not \`{glyph} {role} +N\`: ['◆ Principal', '◇ Analyst', '▸ Builder', '◉ Critic']` |

Probe exit code today: **1**. Wide header restore after 40→80 already holds
(B5); B16 still fails on L8/L12.

## 5. Mandatory scoring rubric

A Reviewer scores every dimension independently from **0.0 through 10.0**,
one decimal. Every numeric score cites a path, snapshot, PTY note, or command
result. Missing, stale, or uncited evidence = **0.0**. No score may be
inferred from intent. No average, partial credit, or compensating high score
overrides a miss.

**Acceptance: every mandatory dimension ≥ 9.0.** Otherwise fail.

| ID | Dimension | 9.0–10.0 means |
|---|---|---|
| D01 | L1 splash persist | Timed 2.4s wait leaves splash active; only Enter/any key finishes; no You turn / spawn on the skip key. |
| D02 | L2 splash-only plane | Header, rule, activity, chips hidden while splash is live; composer + footer visible at 80×24 and 40×20. |
| D03 | L3 identical ASCII splash | Exact 11×7 `#` / `o` / `>` bodies; banned graph / ROBOTS / Critic needles absent. |
| D04 | L4 prefix width 0 | Unpinned prefix style+region width 0 at all four sizes; pinned `@Role` expands and is role-hued. |
| D05 | L5 header `▣─▣─▣` | Wide and compact shapes exact; busy middle head ok without blink; no `harness-cli` / `Directive`. |
| D06 | L6 second-click unpin | First click pins; second click on that chip unpins; other-chip click switches pin. |
| D07 | L7 role-hued chips | All four idle chips carry their identity hex; no mute-gray idle chips. |
| D08 | L8 home `● name …… score` | Every scored row matches the lock; cap 3; exclusions; no iter/trend; display-only. |
| D09 | L9 empty busy composer | Composer empty while busy; footer carries interrupt / elapsed / provider facts. |
| D10 | L10 no-provider first-run | Empty `agents --json` paints the locked copy + footer; not a status dump; chips remain. |
| D11 | L11 evidence dock | Bordered labelled dock above composer; Enter/Esc close; no file-open. |
| D12 | L12 40-col chips | `{glyph} {role} +N` at 40×20 and after SIGWINCH 80→40; four chips restore at 80. |
| D13 | L13 live chrome pack | Command · HH:MM, corner toast, filled rule, no blink, `│` rail proven. |
| D14 | L14 chip + card status | ✓/✗ on the completing role's chip and on its card; fail uses ✗ on both. |
| D15 | L15 team default | Idle unpinned, no `@Role`; bare text still routes through Principal under the hood. |
| D16 | L16 OMP ask | Title, in-dock `k of n`, literal `recommended`, descriptions, real colored question turn, composer below. |
| D17 | L17 OMP confirm | `Confirm write`, in-dock `k of n`, Run/Cancel descriptions; Cancel no-spawn; composer below. |
| D18 | Four sizes + SIGWINCH | 120×36, 80×24, 60×24, 40×20 and 80→40→80 each reach the locked chrome for that size. |
| D19 | B1–B5 preservation | 73 established nodeids still present and green; parity 33/18/15/6; visual-cli 14/14; no weakened needles. |
| D20 | Authority / non-rebuild | No second frontend, no box-drawing revival, no Ink cyan/purple, no domain/MCP/ACP/onboarding rewrite, argv-only CLI, chat is still Bash. |

Keep dimensions D03, D05, D07, D09, D11, D13, D15, D19, D20 may already
cite today's B2/B5 evidence at ≥9.0. D01, D02, D04, D06, D08, D10, D12,
D14, D16, D17, D18 are **0.0 today** (B6–B16 fail). Reviewer output must
include a score and citation for **all D01–D20**.

## 6. Artifact expectations per iteration

Under `state/harness-evolution/runs/tui-fidelity-20260818/`:

```text
inspection.md                         # exists; no-app-edit
frozen-benchmark.md                   # this file
FREEZE-SHA.txt                        # sha256 of this file
iter-N/pytest.txt                     # B1 collect + B2 full suite
iter-N/cli-interface-parity.txt       # B3
iter-N/visual-cli.txt                 # B4
iter-N/b6plus.txt                     # B6–B16 probe, full stdout + exit
iter-N/pty-note.md                    # SIGWINCH 80→40→80 + splash/key notes
iter-N/notes.md                       # isolated transcript deltas
iter-N/scores.json                    # D01–D20, one decimal, each cited
iter-N/reviewer-gate.md               # pass or fail only
final-report.md                       # only on first all-pass
not-converged.md                      # only if still failing after iter-5
```

No evidence → the iteration is void and must be re-run.

## 7. Exact commands the parent orchestrator runs

From the worktree root, every implementation iteration, in this order.
Record exit code and full output. Do not invent output. Set
`CONSULT_NO_SPLASH=1` except while probing splash.

```sh
# B1
lib/tui/.venv/bin/python -m pytest lib/tui/tests --collect-only -q
# B2
lib/tui/.venv/bin/python -m pytest lib/tui/tests -q
# B3
tests/cli-interface-parity.sh
# B4
tests/visual-cli.sh
# B6–B16 (must be exit 0 after implementation; exit 1 today)
lib/tui/.venv/bin/python - <<'PY'
from __future__ import annotations
import asyncio, json, os, re, subprocess, sys, time
from pathlib import Path
sys.path.insert(0, str(Path("lib/tui").resolve()))
from textual.widgets import Static
from app import ProductTeamApp
import adapter

ASK = {
    "event": "ask", "id": "ask-b6", "role": "Builder",
    "question": "Where should each role's color appear?", "mode": "single",
    "options": [
        {"id": "label-rail", "label": "Label + rail",
         "description": "Color the role label, chip, and 2px turn rail.",
         "recommended": True},
        {"id": "label-only", "label": "Label only",
         "description": "Keep the rail neutral.", "recommended": False},
    ],
    "default": ["label-rail"],
}
HOME_LOCK = re.compile(r"^● \S+ …+ \d+\.\d$")
CHIP40 = re.compile(r"^[◆◇▸◉] \S+ \+\d+$")
fails = []

def fail(check, detail):
    fails.append(f"{check}: {detail}")

def compressed(app):
    header = str(app.query_one("#header").render())
    body = app.transcript_text()
    chips = " ".join(str(app.query_one(f"#role-{r}", Static).render()).strip()
                     for r in ("principal", "analyst", "builder", "critic"))
    footer = str(app.query_one("#footer", Static).render())
    prefix = str(app.query_one("#role-prefix", Static).render())
    return "\n".join([header, body, chips, f"PREFIX={prefix!r}", footer])

async def wait_home(pilot, app):
    for _ in range(300):
        if "ProductTeam" in str(app.query_one("#header").render()):
            break
        await pilot.pause()
    for _ in range(300):
        if app.transcript_text():
            return
        await pilot.pause()

async def main():
    os.environ["CONSULT_NO_SPLASH"] = "1"
    app = ProductTeamApp()
    async with app.run_test(size=(80, 24)) as pilot:
        await wait_home(pilot, app)
        print("--- compressed first paint 80x24 ---")
        print(compressed(app))

    os.environ.pop("CONSULT_NO_SPLASH", None)
    app = ProductTeamApp()
    async with app.run_test(size=(80, 24)) as pilot:
        await pilot.pause()
        header = app.query_one("#header"); rule = app.query_one("#rule")
        chips = app.query_one("#chips")
        visible = []
        if header.styles.display != "none" and header.region.height > 0:
            visible.append(f"header display={header.styles.display} h={header.region.height}")
        if rule.styles.display != "none" and rule.region.height > 0:
            visible.append(f"rule display={rule.styles.display} h={rule.region.height}")
        if chips.styles.display != "none" and chips.region.height > 0:
            visible.append(f"chips display={chips.styles.display} h={chips.region.height}")
        if visible:
            fail("B7", "splash plane still shows chrome: " + "; ".join(visible))
        await asyncio.sleep(2.4); await pilot.pause()
        if not app._splash_active:
            fail("B6", f"splash auto-finished without a key (step={app._splash_step} active={app._splash_active})")
        if app._splash_step >= 5:
            fail("B6", f"fifth tick finished the splash (step={app._splash_step})")

    os.environ["CONSULT_NO_SPLASH"] = "1"
    for size in ((120, 36), (80, 24), (60, 24), (40, 20)):
        app = ProductTeamApp()
        async with app.run_test(size=size) as pilot:
            await wait_home(pilot, app)
            prefix = app.query_one("#role-prefix", Static)
            style_w = str(prefix.styles.width)
            if not app._pinned and (prefix.region.width != 0 or style_w not in ("0", "0w", "0h")):
                fail("B8", f"{size[0]}x{size[1]} unpinned #role-prefix width style={style_w} region={prefix.region.width}")
            if "● " not in app.transcript_text():
                fail(f"B16-{size[0]}x{size[1]}", "home lock absent in compressed first paint: " + compressed(app)[:240])

    app = ProductTeamApp()
    async with app.run_test(size=(80, 24)) as pilot:
        await wait_home(pilot, app)
        await pilot.click("#role-builder"); await pilot.pause()
        await pilot.click("#role-builder"); await pilot.pause()
        prefix = str(app.query_one("#role-prefix", Static).render())
        if app._pinned or prefix:
            fail("B9", f"second click same chip did not unpin (pinned={app._pinned} target={app._target_role} prefix={prefix!r})")
        rows = [ln for ln in app.transcript_text().splitlines() if ln.strip()]
        if not any(HOME_LOCK.match(ln.strip()) for ln in rows):
            fail("B10", f"compressed first paint has no ● name …… score home row; rows={rows!r}")
        app._active_turn_role = "Builder"
        app._append_provider_chunk("done body\n")
        app._provider_done(0, "/tmp/w12.txt"); await pilot.pause()
        chip = str(app.query_one("#role-builder", Static).render())
        if "✓" not in chip:
            fail("B13", f"done status missing on chip row: {chip!r}; card_has_check={'✓' in app.transcript_text()}")

    real = adapter.run_argv
    def fake(args, **kw):
        if list(args)[:2] == ["agents", "--json"] or list(args) == ["agents", "--json"]:
            return subprocess.CompletedProcess(args, 0, json.dumps({"agents": [], "installed": []}), "")
        return real(args, **kw)
    adapter.run_argv = fake
    try:
        app = ProductTeamApp()
        async with app.run_test(size=(80, 24)) as pilot:
            await wait_home(pilot, app)
            text = app.transcript_text(); footer = str(app.query_one("#footer", Static).render())
            if "no installed agent" not in text.lower():
                fail("B11", f"no dedicated no-provider first-run copy; transcript={text!r} footer={footer!r}")
    finally:
        adapter.run_argv = real

    app = ProductTeamApp()
    async with app.run_test(size=(40, 20)) as pilot:
        await wait_home(pilot, app)
        painted = []
        for role in ("principal", "analyst", "builder", "critic"):
            w = app.query_one(f"#role-{role}", Static)
            if w.region.width > 0 and str(w.styles.display) != "none":
                painted.append({"role": role, "text": str(w.render()), "w": w.region.width})
        joined = " ".join(c["text"].strip() for c in painted)
        if len(painted) != 1 or not CHIP40.match(joined.replace("  ", " ").strip()):
            fail("B12", f"40x20 chips must be exactly {{glyph}} {{role}} +N; painted={painted}")

    app = ProductTeamApp()
    async with app.run_test(size=(80, 24)) as pilot:
        await wait_home(pilot, app)
        app._provider_active = True
        art = Path("/tmp/tui-fidelity-ask/artifacts"); art.mkdir(parents=True, exist_ok=True)
        app._active_artifact = str(art / "a.txt")
        (art / "ask.json").write_text(json.dumps(ASK), encoding="utf-8")
        for _ in range(80):
            if app._dock_kind == "ask":
                break
            await pilot.pause()
        rows = [app.dock.get_option_at_index(i).prompt.plain for i in range(app.dock.option_count)] if app.dock_visible() else []
        blob = "\n".join(rows); missing = []
        if "recommended" not in blob.lower(): missing.append("literal 'recommended' in dock")
        if not re.search(r"\d+ of \d+", blob): missing.append("k of n inside dock (not only footer)")
        if "Ask" not in blob and "Agent identity" not in blob: missing.append("dock title")
        if "Color the role label, chip, and 2px turn rail." not in blob: missing.append("option descriptions")
        if "★" in blob and "recommended" not in blob.lower(): missing.append("★ used instead of literal recommended")
        if missing:
            fail("B14", f"OMP ask chrome missing {missing}; rows={rows!r}")
        if app.dock_visible():
            await pilot.press("escape"); await pilot.pause()
        await pilot.press(*list("/gh merge")); await pilot.press("enter"); await pilot.pause()
        rows = [app.dock.get_option_at_index(i).prompt.plain for i in range(app.dock.option_count)] if app.dock_visible() else []
        blob = "\n".join(rows); missing = []
        if "Confirm write" not in blob: missing.append("title 'Confirm write'")
        if not re.search(r"\d+ of \d+", blob): missing.append("k of n in dock")
        if "argv to bin/productteam" not in blob and "Nothing is spawned" not in blob:
            missing.append("option descriptions")
        if missing:
            fail("B15", f"OMP confirm chrome missing {missing}; rows={rows!r}")
        await pilot.resize_terminal(40, 20); await pilot.pause(0.25)
        painted = []
        for role in ("principal", "analyst", "builder", "critic"):
            w = app.query_one(f"#role-{role}", Static)
            if w.region.width > 0 and str(w.styles.display) != "none":
                painted.append(str(w.render()).strip())
        if len(painted) != 1 or not CHIP40.match(" ".join(painted).replace("  ", " ")):
            fail("B16-SIGWINCH-40", f"80→40 chips not {{glyph}} {{role}} +N: {painted!r}")
        await pilot.resize_terminal(80, 24); await pilot.pause(0.25)
        if "▣─▣─▣ ProductTeam" not in str(app.query_one("#header").render()):
            fail("B16-SIGWINCH-80", "wide header not restored after 40→80")

    print("=== FAIL LIST ===")
    for item in fails:
        print("FAIL", item)
    print(f"=== {len(fails)} FAIL(S) ===")
    return 1 if fails else 0

if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
PY
```

Workers may append pytest that encode the same needles. They may not replace
this probe with a weaker one. Parent still runs this probe every iteration.

## 8. Immutable stop rules

1. This benchmark is frozen. After `FREEZE-SHA.txt` exists, do not edit it.
2. At most five implementation iterations: `iter-1` … `iter-5`. One worker
   at a time. Smallest diff that lifts a failing dimension.
3. **Stop immediately on first all-pass:** every D01–D20 ≥ 9.0, B1–B5 hold,
   and the §7 B6+ probe exits 0. Write `final-report.md` and stop.
4. **Stop after iter-5** if any dimension is below 9.0. Write
   `not-converged.md` naming each failing dimension, command, exit code, and
   fail output. Keep `lib/tui/`. Do not start iter-6. Do not call it done.
5. Reviewer verdict is **pass** or **fail** only. No 9/10 as a loop verdict.
   Dimension scores still use the 0.0–10.0 scale above.
6. Forbidden: OpenTUI/Ink/second framework; box-drawing revival; Ink
   cyan/purple; deleting `lib/tui/`; making `chat` launch the TUI; daemon /
   database / second state writer; mocking the live provider; secrets in
   artifacts; weakening B1–B5; amending this freeze after hash.

## 9. ACCEPT-FOR-FREEZE

**ACCEPT-FOR-FREEZE**

The freeze transcribes the locked page as amended by the 2026-08-18 Ask
locks. B1–B5 were executed and stay. B6–B16 were executed against today's
compressed first paint and failed (exit 1, 20 FAIL(S)). Implementation may
begin. Do not amend this rubric after hash.
