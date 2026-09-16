# Hermes Optimization Plan

## Immediate Safe Changes

No Hermes config was changed in this sprint.

Use wrapper scripts instead of editing config until the gateway is restarted and config validation is confirmed:

- `scripts/local-fast.ps1`: local LM Studio, minimal tools, no rules/memory/skills injection.
- `scripts/dev-full.ps1`: local primary with fuller dev tools.

## Recommended Modes

### LOCAL_FAST

- Provider/model: `lmstudio/qwen3.5-4b`.
- Reasoning: `none`.
- Tools: `terminal,file,code_execution,clarify`.
- Avoid: kanban, MCP, browser, web, memory, skills, delegation unless requested.
- Launch: `.\hermes-ops\scripts\local-fast.ps1 -Prompt "..."`.

### DEV_FULL

- Provider/model: local first.
- Reasoning: `low`.
- Tools: terminal, file, code_execution, clarify, skills, web, browser, vision, delegation.
- Use for repo debugging and UI checks.

### RESEARCH

- Prefer cloud/free model with long context if local model is too slow.
- Tools: web/research/browser only.
- Avoid dev-heavy MCP unless explicitly needed.

### REAL_ESTATE

- Project filesystem and local datasets first.
- Supabase/data tooling only when credentials/environment are confirmed.
- External research only when explicitly needed.

## Overhead Reduction Priority

1. Do not load `kanban` in LOCAL_FAST; it is the largest schema block.
2. Disable or load-on-demand MCP servers that are parked or unauthenticated: Notion, Netlify, filesystem.
3. Keep browser and Playwright out of LOCAL_FAST.
4. Keep memory external provider disabled or fallback-local until Supermemory credentials work.
5. Split routing by task class instead of one global fallback list.

## Gateway Safety

Hermes reports mixed modules after update. Before config mutation:

1. `hermes backup`
2. `hermes gateway restart`
3. `hermes doctor`
4. `hermes prompt-size`
5. Confirm LM Studio still responds.
