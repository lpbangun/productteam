# Repository Analyst — harness-cli

**Specialist:** Repository Analyst (temporary, `JUDGMENT.md`) · **Engagement:** `harness-cli`
**Scope:** Product Consulting Harness **CLI** only — `bin/consult` + `lib/*.sh` + docs +
skills. **Not JobOS. Not a TUI redesign.** Terminology: CLI everywhere.

---

## 1. Current CLI architecture and command surface

Three-layer shape per `ARCHITECTURE.md` (CLI → org loop → state), unchanged by this
engagement. The CLI itself is one script, no framework:

- `bin/consult:1-529` — single Bash entry point, `set -euo pipefail`, sources
  `lib/provider.sh` and `lib/github.sh` at startup (`bin/consult:6-11`).
- Rendering primitives are inlined, not a module: `score_color`, `bar`, `trunc`,
  `spark` (`bin/consult:20-48`), color vars `B D R G Y RD C` gated on
  `[[ -t 1 && -z "${NO_COLOR:-}" ]]` (`bin/consult:14-18`).
- Dispatch is a single `case` in `main()` (`bin/consult:486-529`) driving 19
  subcommands: `help status org memory smoke runtime harness-checks gh skill
  judge score checks bench run report`.
- Supporting libs, each single-purpose (per `ARCHITECTURE.md:113-124`, "no plugin
  system"): `lib/provider.sh` (73 lines, runtime detect + `provider_ask`),
  `lib/github.sh` (135 lines, gated PR/merge), `lib/run-checks.sh` (332 lines,
  client `scorer=checks` engine — **not** CLI chrome, belongs to a different
  engagement's contract), `lib/harness-checks.sh` (189 lines, harness-apc
  objective checks), `lib/run-skill.sh` (191 lines, skill artifact generator).
- Total CLI-relevant shell: `bin/consult` (529) + `lib/provider.sh` (73) +
  `lib/github.sh` (135) = **737 lines** actually in the interactive command
  path; `run-checks.sh`/`harness-checks.sh` are batch scorers invoked by it,
  not interactive UI.
- Tests: `tests/consult-smoke.sh:1-69` — 25 assertions, all `grep`/exit-code
  based; no rendering/visual assertions, no onboarding-flow assertions.

No package.json/build step — it is a plain POSIX-ish Bash CLI with no external
JS/TS runtime dependency, which matters for "smallest diff" (§5): adding a
Node-based TUI framework would be a new runtime dependency, not a patch.

## 2. What exists for color/style, onboarding, runtime detection, skills

**Color/style** — present but minimal and inconsistent, not a designed theme:

- 7 ad hoc color vars, all basic ANSI SGR codes, no palette module
  (`bin/consult:14-18`).
- Colors used semantically in at least 4 different ways across the file: green
  for status dots/pass and score≥9 (`bin/consult:21,135,194`), yellow for
  score band 7-8 (`bin/consult:22`), red for errors/score<7
  (`bin/consult:23,50`), cyan for client names/active-provider markers
  (`bin/consult:135,194,245`). This is closer to a traditional CLI dashboard
  (htop-like) than the flat B&W-with-sparse-accent look of Grok
  Build/Droid/OpenCode.
- No box-drawing/rounded-panel chrome, no consistent prompt affordance
  (`❯`/`›`), no distinct "assistant vs system" turn styling — there is no chat
  loop at all (`bin/consult` is argv-dispatch, one-shot per invocation; see
  gap G1).
- `bar()`/`spark()` (`bin/consult:26-48`) are the only "visual" primitives and
  are score-dashboard widgets, reusable for a themed redraw but not chat UI.

**Onboarding** — does not exist as a concept in the CLI:

- `cmd_help` (`bin/consult:80-120`) is a static reference dump on request
  only; nothing runs automatically on first invocation.
- `cmd_status` (`bin/consult:164-204`) is the default (`main()` defaults
  `cmd="${1:-status}"`, `bin/consult:487`) but assumes engagements already
  exist; a truly new clone shows "No engagements yet" (`bin/consult:202`) with
  no guided next step, no runtime check, no explanation of what `consult` is.
- No first-run state file, no "have you set up a provider" nudge beyond
  `consult runtime` existing as a discoverable-if-you-already-know-to-look
  command.
- Grep across the repo for onboarding/splash/animation/banner terms
  (`splash|onboard|animation|first-run|ascii|banner|logo`) returns zero hits
  inside `bin/consult` or `lib/` — every hit is in `state/` docs/engagement
  briefs, none in product code.

**Runtime detection** — solid and the one area closest to "done":

- `runtime_detect` enumerates `agent claude codex opencode gemini cursor` via
  `command -v` (`lib/provider.sh:19-29`); `cmd_runtime`
  (`bin/consult:122-150`) renders found/missing with a `●`/`○` marker and
  flags the active one.
- Live check on this box: `agent claude codex opencode cursor` all present,
  `gemini` absent — detection correctly reports 5/6 with honest
  found/missing, matching the "detect all agents" owner goal *mechanically*.
  Gap is presentation, not detection (see G4).
- `runtime_default`/`provider_ask` (`lib/provider.sh:31-73`) give an honest
  refusal path (`consult runtime --check` exits non-zero, tested in
  `tests/consult-smoke.sh:38-42` and `lib/harness-checks.sh:61`).
- No auto-detection on startup/help; a user must know to type
  `consult runtime`.

**Skills** — exist and run, but are template generators, not LLM-driven:

- Three first-party skills: `skills/{critique,benchmark,design-sprint}/SKILL.md`,
  invoked via `bin/consult skill <name> <target> [out-dir]` →
  `lib/run-skill.sh:1-191`.
- Each skill's Bash implementation writes a **static Markdown template** with
  interpolated repo name/tree/README excerpt (`lib/run-skill.sh:56-188`) — it
  does **not** call `provider_ask`/any LLM. The "audit"/"benchmark"/"sprint"
  content is fill-in-the-blank prose ("Fill from evidence above"), not model
  output. This directly conflicts with the owner requirement "skills proven
  … with real LLM calls (no mocks)" (see G2, critical).
  Only `cmd_bench_run` (`bin/consult:415-483`) actually calls `provider_ask`.
- `docs/skills.md:1-9` documents the three skills and their default output
  dir (`state/harness-evolution/runs/skills/`), reinforcing skills are
  currently harness-evolution-flavored, not generic "run this skill against
  any two tmp projects" tooling.
- No skill discovery/list command beyond static help text and `docs/skills.md`.

## 3. Prioritized gap list vs owner brief

Owner checklist items 1–6 (`state/engagements/harness-cli/engagement.md:47-53`)
mapped to evidence, ranked by (a) how far current state is from the bar and
(b) benchmark leverage:

| # | Gap | Evidence | Owner item |
|---|-----|----------|------------|
| G1 | No chat-loop/REPL surface at all — CLI is one-shot argv dispatch, not a persistent Grok-Build/Droid/OpenCode-style session | `bin/consult:486-529` (`main` runs once, exits) | 1, 3 |
| G2 | **Skills don't make real LLM calls** — template-only generation, contradicts "no mocks" invariant | `lib/run-skill.sh:56-188` (no `provider_ask` call in any of 3 skills) vs `state/engagements/harness-cli/engagement.md:40-42` invariant | 6 (critical — also violates stated invariant) |
| G3 | No onboarding flow — first run gives no guided setup, just static status/help | `bin/consult:80-120`, `164-204`; no first-run marker file anywhere in `lib/`/`bin/` | 3 |
| G4 | No splash/login animation of any kind | zero matches for splash/animation/banner in `bin/consult`/`lib/` (grep, see §2) | 2 |
| G5 | Color scheme is a multi-hue dashboard palette, not B&W-with-sparse-accent chat chrome | `bin/consult:14-24` (7 colors, 4 semantic uses) | 1 |
| G6 | Runtime detection works but is opt-in/hidden — not surfaced during onboarding or default status | `bin/consult:164-204` (`cmd_status` doesn't call `runtime_detect`); `cmd_runtime` is a separate command a new user must discover | 4 |
| G7 | No proof harness: two dummy tmp projects for skills validation don't exist yet | `state/engagements/harness-cli/tmp-projects/` is empty (confirmed via `find`) | 6 |
| G8 | Not every "core feature" is a first-class discoverable verb — `gh`/`skill` are sub-dispatched (`bin/consult:309-337`, `301-307`) with their own usage strings not mirrored in `cmd_help`'s one-line-per-verb format, and skills are runnable only by exact SKILL.md name match (`lib/run-skill.sh:16-19`) | `bin/consult:80-120` vs `309-337` | 5 |
| G9 (minor) | No `consult` alias for "list skills" / "list runtimes as part of default view" — discoverability friction consistent with G3/G6 | `bin/consult:80-120` (help lists commands but not what skills exist) | 3, 5 |

G2 is the standout risk: it is not just a UX gap, it is a **contract
violation already on the books** ("No mocks for LLM/agent verification
paths" — `state/engagements/harness-cli/engagement.md:41-42`). Any benchmark
scoring skills-quality today would have to score current `lib/run-skill.sh`
output as templated/mocked, i.e. ≤5 on a skills dimension by the harness's
own banding convention (`state/harness-evolution/HARNESS-BENCHMARK-CONTRACT.md:79`,
"≤5 = missing, broken, mocked, or unsafe").

## 4. Risks

**Architecture escalation risk (high if not bounded):**
The owner brief (chat-loop UI, splash animation, onboarding wizard) is the
kind of ask that invites a full TUI framework (e.g. a Node/Ink or Go/Bubbletea
rewrite) "to do it properly." That would be an **architecture change** —
explicitly an escalation item per `CONSTITUTION.md:26-33` ("Escalate to owner:
Architecture changes") and would violate `ARCHITECTURE.md:113-124`'s
deliberate absences ("No second runtime module," "No plugin system"). A
Bash-only CLI *can* do B&W chrome, a text-mode splash animation, and a guided
onboarding wizard — Droid/OpenCode-style TUIs are commonly delivered over
plain ANSI + `read`, not a heavy dependency. Recommendation: treat "add a
JS/Go TUI runtime" as **escalate**, "extend `bin/consult` in Bash with new
sourced modules" as **auto-apply low-risk** per the Constitution's own table
(`CONSTITUTION.md:26-33`, "Small refactors under existing checks").

**Complexity vs. delete-before-add (Constitution principle 1):**
`bin/consult` is already 529 lines carrying rendering, dispatch, and command
bodies in one file. Bolting a splash animation + onboarding wizard + theme
module directly into it pushes it toward "God script" territory and fights
`ARCHITECTURE.md`'s own claim that the CLI is "a viewer and launcher"
(`ARCHITECTURE.md:17`). The safer path is new single-purpose `lib/*.sh` seams
(consistent with the existing `lib/provider.sh`/`lib/github.sh` pattern),
sourced from `bin/consult`, each independently testable and deletable if it
doesn't earn its keep — directly satisfying "delete before adding" as a
reversibility property, not just a literal deletion count.

**Mock risk on G2:** Making skills call `provider_ask` for real, against two
tmp projects, means real (slow, non-deterministic, cost-incurring) LLM calls
in what is currently a smoke-tested-in-CI-style flow
(`tests/consult-smoke.sh` intentionally avoids provider calls —
`tests/consult-smoke.sh:48`, "never invoke provider scoring here — it
hangs"). Proving G2 without breaking the "smoke must not hang" lesson
(`MEMORY.md:74-76`) requires a **separate, explicitly-invoked** live-proof
script/target, not folding real LLM calls into `consult smoke`.

**Scope-boundary risk:** `lib/run-checks.sh` (332 lines) is a different
engagement's scorer (client `ofc-v1` checks — Maya Chen/People Ops
strings, `lib/run-checks.sh:74-96`) that happens to live under `lib/`. It is
out of scope for harness-cli and must not be touched or refactored as
"cleanup," even though it's the largest file in `lib/`.

**Runtime-detection UX risk:** `gemini` is absent on this device
(`which` check, §2) — any onboarding/splash design that lists "all detected
agents" must render the empty/missing case cleanly (already partially done
via `○ …missing`, `bin/consult:140`) rather than erroring or hiding it,
otherwise the "detect all agents" bar looks worse after the redesign than
before.

## 5. Smallest-diff implementation sketch

Principle: **new sourced `lib/*.sh` modules, not bloating `bin/consult`**,
mirroring the existing `provider.sh`/`github.sh` seam pattern
(`ARCHITECTURE.md:54-65`).

1. `lib/theme.sh` (new, ~30-40 lines) — replace the inline color block
   (`bin/consult:14-24`) with a small B&W-first palette: `FG`/`DIM`/`BOLD`/
   `RESET` neutrals + exactly one `ACCENT` color, still gated on
   `[[ -t 1 && -z NO_COLOR ]]`. `bin/consult` sources it in place of its
   inline block; `score_color`/`bar` keep working, just re-themed. Smallest
   diff: delete 11 lines from `bin/consult`, add 1 `source` line, add 1 new
   file.
2. `lib/splash.sh` (new, ~40-60 lines) — one function `splash_show()`
   producing a short frame-by-frame ANSI redraw of a node/edge graph (simple
   `printf` frames with a `sleep 0.0x`, respecting `NO_COLOR`/non-tty via the
   same `[[ -t 1 ]]` guard so `consult smoke` and CI stay instant). Invoked
   once from `main()` guarded by a first-run marker (next item), never from
   `--help`/non-interactive paths. Skip entirely if `CONSULT_NO_SPLASH` env
   is set — keeps `tests/consult-smoke.sh` fast and honest.
3. `lib/onboarding.sh` (new, ~50-80 lines) — `onboarding_maybe_run()`: checks
   for `state/.onboarded` (new, gitignored marker, not a new state/
   subsystem); if absent, walks the user through: what `consult` is → run
   `runtime_detect` inline and print it (closes G6) → point at
   `consult help` and `consult skill …` → write the marker. Called once from
   `main()` before dispatch, before splash, opt-out via
   `CONSULT_SKIP_ONBOARDING=1` (consistent with existing `CONSULT_*` env
   convention, e.g. `CONSULT_PROVIDER`, `CONSULT_AUTHORIZE_MERGE`).
4. `bin/consult` changes: add 3 `source` lines near the existing sources
   (`bin/consult:8-9`), add one call site in `main()` before the `case`
   dispatch, gated so `help`/`smoke`/non-tty invocations never trigger splash
   or onboarding (prevents regressing `tests/consult-smoke.sh`'s 25
   assertions). Net new lines in `bin/consult` itself: ~10-15, not hundreds.
5. **Skills real-LLM fix (G2, highest priority)**: modify
   `lib/run-skill.sh` to call `provider_ask "$prompt" "$REPO"`
   (`lib/provider.sh:47`) for the analysis body of each skill instead of the
   static heredoc filler, keeping the same output file names/locations so
   `lib/harness-checks.sh:96-110`'s three `skill-*-runs` checks still pass
   unmodified. This is a targeted edit inside the existing `case "$SKILL" in`
   block (`lib/run-skill.sh:54-189`), not a new file.
6. **Live-proof harness (G7)**: new `tests/skills-live-proof.sh` (new file,
   not folded into `consult-smoke.sh` — respects the "smoke must not hang"
   lesson, `MEMORY.md:74-76`) that: creates two minimal tmp projects under
   `state/engagements/harness-cli/tmp-projects/{proj-a,proj-b}/` (e.g. one
   tiny Node script + README, one tiny Python script + README — deliberately
   different stacks so critique/benchmark/design-sprint produce visibly
   different real output), runs all three skills against each via
   `bin/consult skill … tmp-projects/proj-N/.out`, and asserts the output
   files contain non-templated, non-identical content (e.g. diff the two
   projects' `critique.md` and assert they differ, and assert the file does
   not contain the literal template markers like "Fill from evidence
   above"). Invoked explicitly (`bin/consult skill` real calls take
   seconds-to-minutes), never from CI-fast `consult smoke`.
7. `cmd_help` (`bin/consult:80-120`) gets a short "Skills" line already
   present implicitly via `consult skill …` — extend the one-line summary to
   name all three skills explicitly (closes part of G8) — a doc-string-only
   edit, zero new logic.

Estimated net new/changed lines: ~250-350 across 4 new small `lib/*.sh`
files + 1 new test script + ~20 line touch in `bin/consult` + a
`lib/run-skill.sh` edit — versus a framework rewrite that would be
1000+ lines and a new runtime dependency. This keeps `bin/consult` a thin
dispatcher and each new capability independently deletable, matching
`ARCHITECTURE.md`'s seam philosophy.

## 6. How to prove real LLM calls + two tmp projects

- **Location:** `state/engagements/harness-cli/tmp-projects/` (already
  created, empty — confirmed via `find`). Populate with two intentionally
  different dummy repos, e.g.:
  - `tmp-projects/proj-alpha/` — trivial Node CLI (package.json + one .js
    file + terse README, no tests).
  - `tmp-projects/proj-beta/` — trivial Python script (requirements.txt +
    one .py file + a different terse README, no tests).
  Difference matters: it lets a reviewer confirm skill output is
  repo-specific model reasoning, not a fixed template re-skinned with a
  different `$NAME` variable.
- **Prove "real, not mock":**
  1. Run all three skills against both projects using the fixed
     `bin/consult skill <skill> tmp-projects/<proj>` entrypoint (after the
     G2 fix in §5.5), capturing stdout/stderr and the generated
     `.md`/`.json` artifacts under
     `state/engagements/harness-cli/tmp-projects/<proj>/.out-<skill>/`.
  2. Evidence of "real": (a) artifacts reference specifics only present in
     that project's actual files (function/file names, README wording) —
     not generic boilerplate; (b) the two projects' outputs for the same
     skill are provably different (`diff` them, attach the diff — near-zero
     diff on substantive content = still templated, fail); (c) wall-clock
     time for the call is consistent with an LLM round-trip (seconds, not
     instant) — log start/end timestamps in the run script; (d) no
     `CONSULT_PROVIDER` override to a stub binary during the proof run —
     record `bin/consult runtime` output alongside as environment evidence
     of which real runtime served the call.
  3. Archive under
     `state/engagements/harness-cli/checks/live-llm-proof-<ts>/` (the
     existing empty `checks/` dir) with: the two tmp project trees, all six
     output artifacts (3 skills × 2 projects), the diff evidence, and a
     one-page `PROOF.md` stating provider used, timestamps, and the
     non-identical-output check result.
  4. Wire a `harness-cli`-local check (in a new `checks/live-llm-proof.sh`
     or documented manual command, **not** added to `lib/harness-checks.sh`
     which is scoped to `harness-apc-v1`) that fails loudly if either
     output file is byte-identical to the skill's old static template or to
     the other project's output for the same skill — this is the
     mechanical anti-mock guard the Independent Verifier can re-run.
  5. Never run this inside `tests/consult-smoke.sh` (must stay instant/CI-safe
     per `MEMORY.md:74-76`); it is a deliberately slower, explicitly-invoked
     proof step run once per convergence check.

---

## Assignments update

Marked `Repository Analyst` **done** in
`state/engagements/harness-cli/subagents/assignments.md`, output pointing at
this file.
