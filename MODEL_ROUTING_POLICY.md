# Model Routing Policy

## Principle

Route by task class. Do not silently use paid models.

## Task Classes

| Class | First Choice | Allowed Tools | Fallback |
|---|---|---|---|
| LOCAL_SIMPLE | `lmstudio/qwen3.5-4b` | terminal,file,code_execution,clarify | zero-cost cloud only |
| CODING | local first | dev tools + selected skills | zero-cost cloud, then explicit approval for paid |
| RESEARCH | free/long-context cloud if needed | web/browser/research | ask before paid |
| REASONING | local if adequate | minimal tools | free strong model, ask before paid |
| AUXILIARY | cheapest/free small model | none/minimal | local |
| REAL_ESTATE | local + project data | file,data,Supabase if configured | research mode with approval |

## Current Concern

The global fallback chain includes models that appear paid or unauthenticated. That is unsafe for cost-aware routing.

## Policy

- Catalog price `> 0`: requires explicit user permission unless pre-approved in config.
- Catalog price missing/ambiguous: treat as paid/unknown.
- `:free` suffix is helpful but not sufficient; verify via provider catalog each run.
- Free discovery must not auto-edit routing.

## Current Verified State

- `LOCAL_SIMPLE` selects `lmstudio/qwen3.5-4b` first when healthy.
- `qwen3.5-4b` is loaded in LM Studio with context `32768` and TTL `1800`.
- `free-model-scout.py` found 27 zero-price/local candidates on 2026-09-14.
- `hermes-run.ps1` refuses to run if no `HEALTHY` verified-free route is available.
- Paid and unknown-price models remain approval-gated.
- `openai-codex` OAuth is logged in for `alforaij-pro` via imported local Codex CLI credentials.
- `openai-codex/gpt-5.5` passed a tiny test returning `CODEX_OK`.
- `openai-codex/gpt-5.4-mini` is not supported for this ChatGPT account and must not be selected automatically.
- Embedding models are excluded from chat routes.
- `CODING`, `RESEARCH`, and `REASONING` prefer verified-free cloud routes before local fallback when suitable routes are healthy.

## Codex Escalation Policy

- Keep `lmstudio/qwen3.5-4b` as the primary route for simple and normal local work.
- Use verified-free cloud routes before Codex when the task does not require Codex-specific capability.
- Use `openai-codex/gpt-5.5` only for explicit heavy coding or reasoning escalation, or when the user asks for Codex/ChatGPT escalation.
- Do not route simple tasks to Codex automatically.
- Do not change the profile primary provider/model when testing or using Codex as an escalation route.
- `CODEX_HEAVY` requires an explicit escalation reason in `hermes-run.ps1`.
