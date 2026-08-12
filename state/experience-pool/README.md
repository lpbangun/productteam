# Experience pool

Cross-engagement sealed excerpts: what worked / what failed. Not source patches.

- `INDEX.jsonl` — one line per entry `{id,ts,kind,domain,client,iter,title,path,tags[]}`
- `entries/<id>.md` — sealed excerpt with ## What worked | ## What failed | ## Context | ## Cite

Retrieve via `productteam pool list|show|search|retrieve`. Inspect and role invoke load top entries into context.

Write explicitly: `productteam pool add …` or `productteam pool add-from-iter …`
