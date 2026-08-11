# Agent cards

Named, inspectable overlays for the four permanent roles (Principal, Analyst,
Builder, Critic). Cards do not add workers — they bind display names,
traits, duties, and voice to machine roles.

Each permanent role has paired files:

- `<id>.json` — machine-readable card (schema below)
- `<id>.md` — human-readable export

Optional per-engagement specialists live under
`state/engagements/<client>/agents/` (seed with
`productteam card seed-specialist <client> [name]`).

## CLI

```bash
productteam card list [--json]
productteam card show <name|id|role> [--json]
productteam card seed-specialist <client> [display_name]
```

## JSON schema (required fields)

```json
{
  "id": "analyst",
  "display_name": "Meridian",
  "role": "Analyst",
  "kind": "permanent|specialist",
  "traits": ["evidence-first"],
  "duties": ["…"],
  "anti_duties": ["…"],
  "voice": "Terse, cites paths.",
  "prompt_export": "markdown body or excerpt"
}
```

Role envelopes under `roles/iter-N/` record `display_name`, `card_id`, `traits`,
and `voice` when a card resolves for the invoked role.

Override for a single invoke: `CONSULT_ROLE_CARD=<id|display_name>`.
