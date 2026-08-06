# Product critique — onboarding-flight-control

**Skill:** /critique · **Repo:** /home/logani/projects/onboarding-flight-control · **When:** 20260806T064647Z

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
/home/logani/projects/onboarding-flight-control/tsconfig.json
/home/logani/projects/onboarding-flight-control/src/styles.css
/home/logani/projects/onboarding-flight-control/src/vite-env.d.ts
/home/logani/projects/onboarding-flight-control/src/main.tsx
/home/logani/projects/onboarding-flight-control/src/domain.ts
/home/logani/projects/onboarding-flight-control/src/App.tsx
/home/logani/projects/onboarding-flight-control/src/domain.test.ts
/home/logani/projects/onboarding-flight-control/src/contract.test.ts
/home/logani/projects/onboarding-flight-control/.gitignore
/home/logani/projects/onboarding-flight-control/IMPLEMENTATION_PROMPT.md
/home/logani/projects/onboarding-flight-control/README.md
/home/logani/projects/onboarding-flight-control/tsconfig.tsbuildinfo
/home/logani/projects/onboarding-flight-control/vite.config.ts
/home/logani/projects/onboarding-flight-control/vitest.config.ts
/home/logani/projects/onboarding-flight-control/package-lock.json
/home/logani/projects/onboarding-flight-control/index.html
/home/logani/projects/onboarding-flight-control/package.json
```

## README excerpt
```
# Onboarding Flight Control

A fictional People Ops workspace for keeping new hires, managers, and cross-functional
handoffs aligned through the first 30 days of onboarding.

> No new hire starts disconnected, and no cross-functional handoff goes unseen.

## What this is

Onboarding Flight Control is a small, interactive **portfolio demo** built with React,
TypeScript, and Vite. It shows a cohort onboarding board (Healthy / Needs Attention /
Blocked), role-specific views for People Ops, a Manager, and a New Hire, and a
lightweight "onboarding copilot" that surfaces evidence-based suggestions — never a
performance score.

Everything runs entirely in the browser. All state lives in `localStorage`; there is no
server, no database, and no real integrations.

## Who it is for

- People considering this project as a **product/UX case study** of a supportive
  (not surveillance-style) onboarding coordination tool.
- Reviewers who want to click through a realistic, end-to-end onboarding scenario
  (see the [Demo walkthrough](#demo-walkthrough) below).
- Engineers evaluating the codebase itself: a small, dependency-light React app with a
  pure, unit-tested domain model (`src/domain.ts`).

## What it is not

- **Not a production HR or onboarding system.** It does not connect to any real HRIS,
  calendar, chat, or identity provider.
- **Not backed by a server or database.** There is no backend of any kind — every
  "save" is a `localStorage` write in the current browser.
- **Not real AI.** The "onboarding copilot" is deterministic, prebuilt demo logic that
  reads local state and renders grounded, evidence-based messages. It never calls an
  external model and never sends a message or books a meeting silently.
- **Not authenticated.** There are no user accounts, logins, or permissions — the role
  switcher (People Ops / Manager / New Hire) is a demo convenience, not access control.
- **Not tracking real people.** All hires, managers, teams, and events are fictional.

## Clone and run

Requires **Node.js 22+** (see `engines.node` in `package.json`).

```bash
git clone <this-repo-url>
cd onboarding-flight-control
npm ci
npm run dev
```

Then open the printed local URL (typically `http://localhost:5173`).

### Other scripts

```bash
npm run build   # type-check (tsc -b) and produce a production build in dist/
npm test        # run the Vitest suite (domain logic + contract checks)
npm run preview # preview the production build locally
```

## Demo walkthrough

The primary demo story follows **Maya Chen**, a new Software Engineer II who starts
`Blocked` because her manager introduction hasn't been scheduled yet:

1. **People Ops** — Open the workspace (default role). Maya appears in the `Blocked`
   column. Open her card to see her timeline, plan, and the pending
   "Manager introduction" handoff with People Ops' evidence-based recommendation.
2. **Manager** — Switch to the Manager role (Elena Vasquez's view). Her card shows the
   introduction is still unscheduled. Click **Request availability** to generate three
   local meeting-time options — nothing is sent anywhere; it's local demo state.
3. **New Hire** — Switch to the New Hire role (Maya's view). The generated slots now
   appear. Selecting a slot schedules the meeting: it's recorded on the shared timeline
   and Maya moves from `Blocked` to `Needs Attention` with the reason
   "Meeting scheduled—awaiting completion."
4. **Copilot** — Open **Ask the onboarding copilot** from any role. Once a slot is
   selected, the copilot offers to **confirm the handoff**. Confirming moves Maya to
   `Healthy` and marks the "Manager introduction" handoff `complete`.
```

## Prioritized recommendations
1. (Fill from evidence above — highest leverage first)
2. …
3. …

## Evidence rule
Every recommendation must cite a path from this repo.
