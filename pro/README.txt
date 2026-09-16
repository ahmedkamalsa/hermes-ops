HERMES PRO PACK
===============

Goal
----
Keep the existing Hermes setup as rollback, create an isolated professional profile,
use the local Qwen model as the reliable base, and use free cloud models only through
the existing verified-free scout/router rather than a paid/unknown fallback chain.

IMPORTANT SECURITY
------------------
If you pasted or uploaded API keys/tokens anywhere during troubleshooting, rotate/revoke
them at the provider before continuing. Do not paste the replacement values into chat.

ONE-TIME SETUP
--------------
1) Put these files in:
   D:\foraj_social\287\hermes-ops\pro\

2) Open PowerShell in that folder.

3) Run:
   Set-ExecutionPolicy -Scope Process Bypass
   .\Setup-HermesPro.ps1

Optional, after you verify the profile:
   .\Setup-HermesPro.ps1 -Activate

Optional Computer Use:
   .\Setup-HermesPro.ps1 -EnableComputerUse

Do NOT use -EnableLmStudioJit unless LM Studio JIT/Auto-Evict is enabled in LM Studio.

DAILY USE
---------
Professional development / research agent:
   .\Start-HermesPro.ps1

Professional agent with desktop control:
   .\Start-HermesPro.ps1 -Desktop

Use an isolated git worktree:
   .\Start-HermesPro.ps1 -Worktree

Very light local-only session:
   .\Start-HermesLocal.ps1

Point it at the parent workspace instead:
   .\Start-HermesPro.ps1 -WorkingDirectory "D:\foraj_social\287"

VERIFY / REFRESH FREE MODELS
----------------------------
   .\Verify-HermesPro.ps1

The verifier also reruns the existing free-model scout and tiny benchmark if those
scripts are still present in D:\foraj_social\287\hermes-ops\scripts.

AUTOMATIC FREE ROUTED ONE-SHOT TASKS
------------------------------------
Keep using the existing preserve-first runner for tasks where you want automatic
model selection:

   .\hermes-ops\scripts\hermes-run.ps1 `
      -Task "your request" `
      -WorkingDirectory "D:\foraj_social\287" `
      -TaskClass LOCAL_SIMPLE

Why no paid fallback is installed in alforaij-pro:
- the cloned global config previously mixed free, paid-looking, and unavailable routes;
- free catalogs and rate limits change;
- the existing scout/router verifies zero price and health before selection.

ROLLBACK
--------
Return to the original profile:
   hermes profile use default

Delete the new profile only after you no longer need it:
   hermes profile delete alforaij-pro

The setup script creates a Hermes backup before any mutation.
