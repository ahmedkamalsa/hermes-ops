# Hermes Agent Infrastructure Sprint - Summary For Next Agent

Date: 2026-09-14

Workspace:

```text
D:\foraj_social\287
```

Important rule:

- Do not modify `D:\foraj_social\287\alforaij-research-assistant` without explicit user approval.
- Do not expose API keys, tokens, passwords, JWTs, or private credentials.
- No GitHub push was performed.
- Hermes configuration was not changed in this sprint.

## 1. What Was Done

Created an operational folder:

```text
D:\foraj_social\287\hermes-ops
```

Created these documentation files:

```text
hermes-ops\HERMES_AGENT_ARCHITECTURE.md
hermes-ops\HERMES_OPTIMIZATION_PLAN.md
hermes-ops\MODEL_ROUTING_POLICY.md
hermes-ops\FREE_MODEL_SCOUT.md
hermes-ops\SELF_IMPROVEMENT_DESIGN.md
hermes-ops\INTEGRATION_AUDIT.md
hermes-ops\HANDOFF.md
hermes-ops\HERMES_SPRINT_SUMMARY_FOR_AGENT.md
```

Created these scripts:

```text
hermes-ops\scripts\local-fast.ps1
hermes-ops\scripts\dev-full.ps1
hermes-ops\scripts\free-model-scout.py
hermes-ops\scripts\model-benchmark.py
hermes-ops\scripts\hermes-smart.py
hermes-ops\scripts\hermes-maintain.ps1
```

Created this draft skill template:

```text
hermes-ops\skills\real-estate-intelligence\SKILL.md
```

Generated these reports:

```text
hermes-ops\free-model-scout.json
hermes-ops\free-model-scout.md
hermes-ops\model-benchmark.json
hermes-ops\model-benchmark.md
hermes-ops\model-health-registry.json
hermes-ops\FINAL_OPERATIONS.md
```

Preserve-first automation was added after the initial sprint:

- Existing healthy config is preferred and preserved.
- `lmstudio/qwen3.5-4b` remains first route when healthy.
- Free cloud models are candidates only after official zero-price catalog data and tiny health checks.
- Failed models are marked inactive with history, not deleted.
- Paid/ambiguous models require approval.
- `python hermes-ops\scripts\hermes-smart.py select --task-class LOCAL_SIMPLE` verified first route as `lmstudio/qwen3.5-4b` / `HEALTHY`.

## 2. Hermes Current State Found

Hermes CLI:

```text
C:\Users\hello\AppData\Local\hermes\bin\hermes.exe
```

Hermes version:

```text
Hermes Agent v0.21.2 (2026.9.11)
upstream 6bc0e9e6
Python 3.11.9
```

Hermes install:

```text
C:\Users\hello\AppData\Local\hermes\hermes-agent
```

Hermes config:

```text
C:\Users\hello\AppData\Local\hermes\config.yaml
```

Hermes secrets file exists:

```text
C:\Users\hello\AppData\Local\hermes\.env
```

Credential values were not printed or copied.

Visible provider/key names in `.env` include:

- Supabase variables
- OpenRouter
- GitHub token
- Browser Use
- Langfuse
- local LM API variable

## 3. Current Model Routing

Primary model:

```text
provider: lmstudio
model: qwen3.5-4b
base_url: http://127.0.0.1:1234/v1
```

LM Studio status:

```text
reachable
3 local models detected
```

Reasoning:

```text
none
```

Context length:

```text
73728
```

Fallback chain currently mixes:

- OpenRouter free models
- paid-looking OpenRouter models
- Google model entries
- Nous model entries
- Groq entry

Risk:

The fallback chain is not cost-safe because some entries appear paid or unauthenticated. Do not silently rely on the global fallback list for cost-sensitive work.

## 4. Prompt / Tool Schema Overhead Evidence

Command used:

```text
hermes prompt-size
```

CLI overhead found:

```text
System prompt total: 40,098 B
Tool schemas:        56,982 B
Tool count:          33
Skills index:         9,013 B
Memory:               3,275 B
User profile:         1,796 B
```

Largest schema overhead:

```text
kanban:          24,107 B
file:             5,404 B
delegation:       4,423 B
skills:           3,619 B
terminal:         3,371 B
memory:           3,296 B
code_execution:   3,009 B
```

Conclusion:

The local Qwen model should not carry all tools all the time. The biggest immediate win is to avoid loading `kanban` and unnecessary MCP/tool schemas in fast local sessions.

## 5. Current Toolsets / MCP / Integration Findings

CLI built-in toolsets enabled included:

- web
- terminal
- file
- code_execution
- vision
- video
- image_gen
- video_gen
- x_search
- tts
- stt
- skills
- todo
- kanban
- memory
- context_engine
- session_search
- clarify
- delegation
- cronjob
- homeassistant
- computer_use

CLI disabled included:

- browser
- connections
- spotify
- yuanbao

MCP servers configured/enabled:

- context7
- notion
- filesystem
- github
- playwright
- atlassian
- netlify
- postman

Observed repeated startup/auth failures:

- Notion MCP: unauthorized / 401 / retry loop.
- Netlify MCP: OAuth token missing in non-interactive environment.
- Filesystem MCP: connection closed after retries.
- Nous Tool Gateway: no usable paid credits, managed tools unavailable.

Recommendation:

- Keep native `terminal,file,code_execution,clarify` always available.
- Load `kanban`, browser, Playwright, GitHub MCP, Context7, Netlify, Notion, Postman, Atlassian only on demand.
- Treat Notion and Netlify as `AUTH_REQUIRED`.
- Treat filesystem MCP as duplicate/broken while native file tools exist.

## 6. Memory Finding

Command used:

```text
hermes memory status
```

Finding:

- Built-in memory/profile injection is enabled.
- External provider is `supermemory`.
- Supermemory is unavailable because `SUPERMEMORY_API_KEY` is missing.
- Hermes warns that gateway/service environments may not inherit `~/.hermes/.env`.

Recommendation:

Do not depend on Supermemory until:

1. `SUPERMEMORY_API_KEY` exists.
2. Gateway environment inheritance is confirmed on Windows.
3. `hermes memory status` reports available.

Until then, use built-in `MEMORY.md` / `USER.md` as the safer fallback.

## 7. Gateway Warning

Hermes repeatedly printed:

```text
A previous `hermes update` pulled new code but did not restart running gateways.
Gateways may still be serving pre-update modules.
Run `hermes update` or `hermes gateway restart`.
```

No gateway restart was performed.

Recommendation before any config change:

```powershell
hermes backup
hermes gateway restart
hermes doctor
hermes prompt-size
```

Then verify LM Studio still works.

## 8. Operating Modes Proposed

### LOCAL_FAST

Purpose:

Fast local work with minimal tool/schema overhead.

Use:

```powershell
.\hermes-ops\scripts\local-fast.ps1 -Prompt "say ok" -WorkingDirectory D:\foraj_social\287
```

Wrapper behavior:

```text
provider: lmstudio
model: qwen3.5-4b
reasoning: none
toolsets: terminal,file,code_execution,clarify
ignore-rules: true
```

Why:

Avoids heavy `kanban`, browser, MCP, memory/profile/rules overhead for simple local tasks.

### DEV_FULL

Purpose:

Coding, debugging, repository work, UI checks.

Use:

```powershell
.\hermes-ops\scripts\dev-full.ps1 -WorkingDirectory D:\foraj_social\287
```

Wrapper behavior:

```text
provider: lmstudio
model: qwen3.5-4b
reasoning: low
toolsets: terminal,file,code_execution,clarify,skills,web,browser,vision,delegation
```

### RESEARCH

Purpose:

Web/research synthesis.

Recommendation:

- Use browser/web/research skills.
- Prefer zero-cost long-context cloud models when local model is too weak.
- Ask before paid models.

### REAL_ESTATE

Purpose:

Alforaij property intelligence workflow.

Recommendation:

- Use local/project data first.
- Use Supabase only when credentials and access are confirmed.
- Use external research only when explicitly needed.
- Avoid unsupported price claims.

Draft skill exists at:

```text
hermes-ops\skills\real-estate-intelligence\SKILL.md
```

It is not installed yet.

## 9. Free Model Scout

Script:

```text
hermes-ops\scripts\free-model-scout.py
```

Run:

```powershell
python hermes-ops\scripts\free-model-scout.py
```

Outputs:

```text
hermes-ops\free-model-scout.json
hermes-ops\free-model-scout.md
```

Behavior:

- Queries OpenRouter official catalog.
- Queries local LM Studio `/models`.
- Selects models where provider-reported prompt and completion prices are both zero.
- Records model ID, provider, context length, tool-calling support if known, reasoning if known, vision if known, price, availability, timestamp.
- Does not change Hermes routing.

Latest result:

```text
27 zero-price/local candidates found
providers: openrouter, lmstudio
```

## 10. Safe Model Benchmark

Script:

```text
hermes-ops\scripts\model-benchmark.py
```

Run:

```powershell
python hermes-ops\scripts\model-benchmark.py
```

Outputs:

```text
hermes-ops\model-benchmark.json
hermes-ops\model-benchmark.md
```

Rules implemented:

- Max 5 OpenRouter `:free` models.
- Sequential requests.
- Max 16 response tokens.
- No paid model test by design.
- Does not change routing.

Latest benchmark:

| Model | Result | Latency |
|---|---|---:|
| `cohere/north-mini-code:free` | ok | 21741 ms |
| `dots-studio/dots-3-note-preview:free` | ok | 22448 ms |
| `google/gemma-4-26b-a4b-it:free` | 429 rate limited | |
| `google/gemma-4-31b-it:free` | 429 rate limited | |
| `inclusionai/ling-3.0-flash-fin:free` | ok | 905 ms |

Best observed free candidate:

```text
inclusionai/ling-3.0-flash-fin:free
```

Important:

Free status can change. Always rerun scout before updating routing.

## 11. Smart Routing Policy

Policy file:

```text
hermes-ops\MODEL_ROUTING_POLICY.md
```

Core policy:

- Route by task class, not one giant fallback chain.
- Prefer local model when capable.
- Prefer zero-cost cloud models next.
- Require explicit permission before using paid models.
- Treat missing/ambiguous pricing as paid/unknown.

Suggested classes:

| Class | First choice | Notes |
|---|---|---|
| LOCAL_SIMPLE | `lmstudio/qwen3.5-4b` | minimal tools |
| CODING | local first | stronger fallback only when needed |
| RESEARCH | free long-context cloud if needed | web tools only |
| REASONING | capable local or free strong model | ask before paid |
| AUXILIARY | cheapest/free small model | compression/review/title |
| REAL_ESTATE | local/project data first | Supabase when configured |

## 12. Self-Improvement Design

Design file:

```text
hermes-ops\SELF_IMPROVEMENT_DESIGN.md
```

Skill Lifecycle Manager statuses:

- candidate
- testing
- approved
- active
- rejected
- deprecated

Promotion criteria:

- solves repeated problem
- tests pass
- measurable improvement
- does not duplicate existing skill
- rollback available
- human approval before activation

No self-modifying or auto-promotion behavior was implemented.

## 13. Real Estate Skill Draft

Draft path:

```text
hermes-ops\skills\real-estate-intelligence\SKILL.md
```

Purpose:

- property opportunity analysis
- price comparison
- comparable properties
- market trends
- scoring/ranking
- source/evidence tracking
- Supabase/local dataset use
- structured reports
- source confidence
- avoiding unsupported price claims

Status:

- Draft only.
- Not installed.
- Not benchmarked.
- Needs human review before activation.

## 14. What Was Not Done

- Hermes config was not edited.
- No Hermes profile was created or activated.
- No MCP/toolset was disabled globally.
- Gateway was not restarted.
- No paid model was intentionally tested.
- No credentials were printed.
- No GitHub push was performed.
- `alforaij-research-assistant` was not modified.
- `alforaijboard` was not modified during this Hermes sprint.

## 15. Known Small Cleanup

Running `py_compile` created:

```text
hermes-ops\scripts\__pycache__
```

An attempted cleanup command was blocked by command policy. It is safe generated Python cache and can be deleted manually later.

## 16. Recommended Next Actions For Another Agent

Start here:

```powershell
cd D:\foraj_social\287
Get-Content hermes-ops\HANDOFF.md
Get-Content hermes-ops\HERMES_AGENT_ARCHITECTURE.md
```

Then:

```powershell
hermes backup
hermes gateway restart
hermes doctor
hermes prompt-size
```

Test LOCAL_FAST:

```powershell
.\hermes-ops\scripts\local-fast.ps1 -Prompt "Reply with exactly OK" -WorkingDirectory D:\foraj_social\287
```

Refresh free model data:

```powershell
python hermes-ops\scripts\free-model-scout.py
python hermes-ops\scripts\model-benchmark.py
```

Only after backup/restart/doctor:

- consider converting wrapper modes into real Hermes profiles if native profile layering is confirmed safe;
- consider disabling or load-on-demanding `kanban` and broken/auth-required MCPs for LOCAL_FAST;
- review and optionally install `real-estate-intelligence` skill.

## 17. Rollback

Because no Hermes config was changed, rollback is simple:

```powershell
Remove-Item -Recurse -Force D:\foraj_social\287\hermes-ops
```

Use normal caution before deleting if you want to keep generated reports.
