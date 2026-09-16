# Integration Audit

## Classification

| Integration | Status | Recommendation |
|---|---|---|
| Native terminal/file/code_execution/clarify | working | KEEP_ALWAYS for LOCAL_FAST |
| LM Studio | reachable | KEEP_ALWAYS |
| Kanban toolset | high schema cost | LOAD_ON_DEMAND |
| Skills toolset | useful but adds index | LOAD_ON_DEMAND in LOCAL_FAST |
| Delegation | moderate schema cost | LOAD_ON_DEMAND |
| Web/browser/Playwright | useful for research/UI | LOAD_ON_DEMAND |
| Context7 MCP | enabled | LOAD_ON_DEMAND |
| Notion MCP | 401/retry warnings | BROKEN/AUTH_REQUIRED |
| Netlify MCP | OAuth missing in non-interactive startup | AUTH_REQUIRED/LOAD_ON_DEMAND |
| Filesystem MCP | connection closed | BROKEN/DUPLICATE native file tools |
| GitHub MCP | enabled | LOAD_ON_DEMAND |
| Atlassian MCP | enabled | LOAD_ON_DEMAND |
| Postman MCP | enabled | LOAD_ON_DEMAND |
| Supermemory | missing API key | BROKEN/AUTH_REQUIRED |
| A2A plugin | enabled | LOAD_ON_DEMAND |
| Nous Tool Gateway | no usable paid credits | DISABLE unless credits added |

## Security Inventory

Secrets are in `C:\Users\hello\AppData\Local\hermes\.env`; values were not copied.

Provider/key names present: Supabase URL/anon/service/key, OpenRouter, Opencode Zen, GitHub token, Langfuse public/secret, Browser Use, LM API key, terminal env.

Risk:

- `.env` secret storage is expected local storage.
- Confirm gateway service environment inheritance before moving or relying on env vars.
- Avoid inline secrets in `config.yaml`.
