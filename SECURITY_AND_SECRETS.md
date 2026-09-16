# Security And Secrets

Date: 2026-09-14

No secret values are stored in this report.

## Present Variable Names

Found by name only in Hermes `.env` and `alforaij-pro\.env`:

- `BROWSER_USE_API_KEY`
- `GITHUB_TOKEN`
- `HERMES_LANGFUSE_PUBLIC_KEY`
- `HERMES_LANGFUSE_SECRET_KEY`
- `LM_API_KEY`
- `OPENCODE_ZEN_API_KEY`
- `OPENROUTER_API_KEY`
- `SUPABASE_ANON_KEY`
- `SUPABASE_KEY`
- `SUPABASE_SERVICE_KEY`
- `SUPABASE_URL`
- `TERMINAL_ENV`

## Useful Missing Variable Names

- `SUPERMEMORY_API_KEY`: needed only for external Supermemory provider.
- `GOOGLE_API_KEY` or `GEMINI_API_KEY`: useful for Gemini routes if approved.
- `GROQ_API_KEY`: useful for Groq routes if approved.
- `EXA_API_KEY`, `PARALLEL_API_KEY`, `FIRECRAWL_API_KEY`, `TAVILY_API_KEY`, or `BRAVE_SEARCH_API_KEY`: useful for richer web search/extract providers.
- `NOTION_API_KEY`: needed only if Notion MCP should be active.
- `NETLIFY` OAuth/cache action: needed only if Netlify MCP should be active interactively.

## Rules

- Static API keys must not be regenerated, scraped, printed, or pasted into chat.
- OAuth refresh is allowed only through the provider's supported mechanism.
- Invalid credentials should be marked `AUTH_REQUIRED` and bypassed in routing.
- Paid or unknown-price models require explicit approval before use.
