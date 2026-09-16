# Hermes Agent Architecture

Date: 2026-09-14

## Installation

- Version: Hermes Agent v0.21.2 (2026.9.11), upstream `6bc0e9e6`.
- CLI: `C:\Users\hello\AppData\Local\hermes\bin\hermes.exe`.
- Install: `C:\Users\hello\AppData\Local\hermes\hermes-agent`.
- Config: `C:\Users\hello\AppData\Local\hermes\config.yaml`.
- Secrets file exists: `C:\Users\hello\AppData\Local\hermes\.env`.
- Warning on every command: a previous `hermes update` pulled new code but running gateways were not restarted.

## Current Routing

- Primary provider/model: `lmstudio` / `qwen3.5-4b`.
- LM Studio base URL: `http://127.0.0.1:1234/v1`.
- LM Studio status: reachable with 3 local models.
- Fallback chain mixes free, paid, and possibly unavailable providers:
  - OpenRouter free models first.
  - Then paid-looking OpenRouter models including DeepSeek Pro and Claude Opus.
  - Google fallback is configured, but no Google/Gemini key is visible in Hermes status.
  - Nous `upstage/solar-pro4:free` is configured for compression.
  - Groq fallback is configured, but no Groq key was visible in the shell/config summary.
- Reasoning: `none`.
- Context length: `73728`.
- Auxiliary model: Vision uses Google `gemini-2.5-flash`.
- Context compression: enabled at 50%, target 20%, model `nous/upstage/solar-pro4:free`.

## Memory

- Built-in memory/profile injection enabled.
- External provider: `supermemory`.
- Supermemory status: unavailable because `SUPERMEMORY_API_KEY` is not set.
- Hermes note: gateway/system services may not inherit `~/.hermes/.env`; service environment must be verified before moving secrets.

## Prompt / Tool Overhead

CLI prompt-size:

- System prompt: 40,098 B.
- Tool schemas: 56,982 B across 33 tools.
- Skills index: 9,013 B.
- Memory: 3,275 B.
- User profile: 1,796 B.

Largest CLI tool schema overhead:

- `kanban`: 24,107 B.
- `file`: 5,404 B.
- `delegation`: 4,423 B.
- `skills`: 3,619 B.
- `terminal`: 3,371 B.
- `memory`: 3,296 B.
- `code_execution`: 3,009 B.

Desktop prompt-size simulation showed no tool schemas, but `hermes tools list --platform desktop` reports `desktop` is not a valid tools platform. Treat desktop/toolset state as unresolved.

## Toolsets / MCP

CLI built-ins enabled include web, terminal, file, code_execution, vision, video, image_gen, video_gen, x_search, tts, stt, skills, todo, kanban, memory, context_engine, session_search, clarify, delegation, cronjob, homeassistant, computer_use.

CLI disabled include browser, connections, spotify, yuanbao.

MCP servers configured/enabled: context7, notion, filesystem, github, playwright, atlassian, netlify, postman.

Startup warnings/failures observed:

- Notion MCP: 401 unauthorized; repeated Streamable HTTP to SSE retries.
- Netlify MCP: missing cached OAuth token in non-interactive environment.
- Filesystem MCP: connection closed after retries.
- Nous Tool Gateway: no usable paid credits, managed tools unavailable.

## Skills / Plugins

- Skills directory contains broad categories: software-development, web-development, research, supabase, mcp, devops, finance, productivity, security, free-model-orchestrator, hermes-ops-learnings, and others.
- Plugin toolset enabled in CLI: `a2a`.
- `hermes plugins list --plain --no-bundled` did not produce useful plain rows because Hermes returned the update/restart warning as an error stream.
