# Hermes Pro Final Report

Date: 2026-09-14

## Changes Made

- Created Hermes backup before config mutation: `C:\Users\hello\hermes-backup-2026-09-14-192015.zip`.
- Restarted Hermes gateway; Hermes still prints the mixed-module warning after restart.
- Imported existing local Codex CLI OAuth credentials into profile `alforaij-pro` using Hermes v0.21.2's local `_login_openai_codex` import path. No token values or `auth.json` contents were printed.
- Updated profile `alforaij-pro`:
  - `model.context_length = 32768`
  - `display.show_cost = true`
- Restored profile primary model after Codex import:
  - `model.provider = lmstudio`
  - `model.default = qwen3.5-4b`
  - `model.base_url = http://127.0.0.1:1234/v1`
- Loaded LM Studio model `qwen3.5-4b` with context `32768`, GPU offload `0.4`, TTL `1800`.
- Added `scripts\hermes-status.ps1` for one-command operational status/recovery checks.
- Added `scripts\Start-HermesPro-OneClick.ps1` and `scripts\Start-HermesPro.cmd`.
- Created Desktop shortcut `Hermes Pro` targeting `D:\foraj_social\287\hermes-ops\scripts\Start-HermesPro.cmd`.
- Updated `scripts\hermes-smart.py` to classify task classes, exclude embedding models from chat routes, require tool-calling for cloud agentic coding routes, and expose explicit `CODEX_HEAVY`.
- Updated `scripts\hermes-run.ps1` to default to deterministic `AUTO` classification and require `-EscalationReason` for `CODEX_HEAVY`.
- Updated `FINAL_OPERATIONS.md`.

## Verification

- `hermes backup`: passed.
- `hermes gateway restart`: passed, but warning persists afterward.
- `hermes doctor`: passed core checks; remaining issues are optional/missing integrations and npm audit warnings.
- `hermes -p alforaij-pro config check`: passed; config version 44.
- `lms load qwen3.5-4b --context-length 32768 --gpu 0.4 --ttl 1800`: passed.
- Local one-shot prompt: returned `OK`; session `20260914_192250_277f3e`.
- File tool test with checkpoints: created/read/deleted test file and returned `TOOL_OK`; session `20260914_192517_52f207`.
- `python -m py_compile` for routing/improvement/scout/benchmark scripts: passed.
- `free-model-scout.py`: passed, 27 zero-price/local candidates.
- `hermes-maintain.ps1 -Mode daily`: passed.
- `hermes-run.ps1`: passed; logged `ok=true`, provider `lmstudio`, model `qwen3.5-4b`, task class `LOCAL_SIMPLE`.
- `Start-HermesPro-OneClick.ps1`: passed; detected gateway and LM Studio, auto-loaded Qwen when unloaded, then returned `OK`.
- `Start-HermesPro.cmd`: passed; invoked the one-click flow and returned `OK`.
- Desktop shortcut check: target and working directory are correct.
- `hermes -p alforaij-pro gateway status`: `Hermes_Gateway_alforaij-pro` registered, `Ready`, gateway process running.
- Scheduled tasks: old `Hermes_Gateway` remains `Disabled`; `Hermes_Gateway_alforaij-pro` remains `Ready`.
- Resume latest test: returned `RESUME_OK`.
- Router tests:
  - `LOCAL_SIMPLE` selects `lmstudio/qwen3.5-4b`.
  - `CODING`, `RESEARCH`, and `REASONING` select verified-free OpenRouter routes when available.
  - Embedding models are excluded from chat alternatives.
  - `CODEX_HEAVY` is refused by `hermes-run.ps1` unless `-EscalationReason` is supplied.
- `gh auth status`: authenticated; no push performed.
- `hermes computer-use status`: backend installed, update available.
- Codex import source check:
  - `hermes auth add openai-codex` in `hermes_cli\auth_commands.py:223-231` starts device-code flow directly.
  - Import/adoption path is in `hermes_cli\auth_codex.py:660-685`, where Hermes detects `~/.codex/auth.json`, prompts `Import these credentials?`, then saves to the Hermes auth store.
- `hermes -p alforaij-pro auth status openai-codex`: `logged in`.
- `hermes -p alforaij-pro auth list openai-codex`: one `device_code` OAuth credential present.
- Tiny Codex test:
  - `gpt-5.4-mini` returned HTTP 400 unsupported for this ChatGPT account.
  - `gpt-5.5` returned `CODEX_OK`.
- Primary model after Codex test remains `lmstudio/qwen3.5-4b`.

## Remaining Issues

- Hermes continues to warn that a previous update did not restart running gateways, even after `hermes gateway restart`.
- `browser` toolset is disabled in Hermes config; browser/backend testing was not activated.
- External memory provider `supermemory` is unavailable because `SUPERMEMORY_API_KEY` is missing.
- No global default profile switch was performed.
- No scheduled tasks were installed automatically.

## Safety Notes

- No secret values were printed or written to reports.
- No paid/unknown model was selected by automation.
- Codex/ChatGPT is available only as an explicit escalation route, not the simple-task default.
- Smart routing is implemented at session level, not per-message inside an already-open Hermes chat.
- `alforaij-research-assistant` was not modified.
- No GitHub push was performed.
