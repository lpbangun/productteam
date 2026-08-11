# Build 1 Critic Verdict
Status: ACCEPT-WITH-NITS → **nit fixed 2026-08-11** (client-scoped `card show`)
Date: 2026-08-11

## Done-when audit
- [x] Durable cards (name, role, traits, duties, anti-duties, voice) — `state/agents/*.json` + `*.md`
- [x] Role invoke/status show display name + characteristics — `lib/role-envelope.sh`; smoke PASS
- [x] CLI list/show cards — `productteam card list|show`
- [x] Four permanent + optional engagement specialist — seeds + `seed-specialist`
- [x] Name, inspect, see who ran under roles/iter-N/ — envelope `display_name`; specialist show via `card show <name> <client>`

## Findings (ordered by severity)
1. ~~Engagement specialist not showable via CLI~~ **FIXED**: `productteam card show Scout <client>` wires `client_dir` into `agent_card_show`.
2. Card slice untracked in git (commit when owner asks).
3. Card smoke refuse coverage thin for bad list options / unknown client seed (can wait).

## Nits (non-blocking)
- Automate refuse smokes for bad `card list` options and unknown client on `seed-specialist`.
- Clarify in docs that `card list` is permanent-only.

## Org note
Vanilla, file-backed, inspectable overlays — no fifth invokable worker; Principal card names the orchestrating session without expanding the role envelope surface.

## Gate for Build 2
**OPEN** — must-fix for specialist show is landed; Build 2 may proceed.
