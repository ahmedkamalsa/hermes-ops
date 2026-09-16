# Final Operations - Hermes Pro

## DAILY COMMAND

```powershell
.\hermes-ops\scripts\Start-HermesPro-OneClick.ps1 -Task "your request" -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

Or double-click `Hermes Pro` on Desktop for an interactive session. The launcher starts/checks the `alforaij-pro` gateway, starts/checks LM Studio, loads `qwen3.5-4b` when needed, and opens Hermes with checkpoints.

Uses preserve-first session-level routing, local `lmstudio/qwen3.5-4b` for simple work, verified-free cloud routes for suitable non-simple work, and refuses paid/unknown models without approval. Runs are logged to `hermes-ops\hermes-run-log.jsonl`.

## REAL ESTATE COMMAND

```powershell
.\hermes-ops\scripts\hermes-run.ps1 -Task "analyze this property/opportunity" -WorkingDirectory "D:\foraj_social\287" -TaskClass REAL_ESTATE
```

Optional draft skill install:

```powershell
.\hermes-ops\scripts\install-real-estate-skill.ps1
```

Rollback:

```powershell
.\hermes-ops\scripts\rollback-real-estate-skill.ps1
```

## MAINTENANCE COMMAND

```powershell
.\hermes-ops\scripts\hermes-maintain.ps1 -Mode daily
.\hermes-ops\scripts\hermes-maintain.ps1 -Mode weekly
.\hermes-ops\scripts\hermes-maintain.ps1 -Mode failure
.\hermes-ops\scripts\hermes-status.ps1
```

No large benchmark is run by daily maintenance.

## INSTALL AUTOMATION

Review first, then run manually:

```powershell
.\hermes-ops\scripts\install-automation.ps1
```

Remove scheduled tasks:

```powershell
.\hermes-ops\scripts\uninstall-automation.ps1
```

## IMPROVEMENT REVIEW

```powershell
python hermes-ops\scripts\improvement-manager.py status
python hermes-ops\scripts\improvement-manager.py review
python hermes-ops\scripts\improvement-manager.py approve <id>
python hermes-ops\scripts\improvement-manager.py reject <id>
```

Repeated failures may create candidates, but activation requires human approval.

## ROLLBACK

Hermes backup created:

```text
C:\Users\hello\hermes-backup-2026-09-14-192015.zip
```

Return to default profile:

```powershell
hermes profile use default
```

Restore backup if needed:

```powershell
hermes import C:\Users\hello\hermes-backup-2026-09-14-192015.zip
```
