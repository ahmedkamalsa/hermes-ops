# Start Hermes Pro

Double-click Hermes Pro on Desktop.

## Daily Routed Command

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\Start-HermesPro-OneClick.ps1 -Task "your request" -WorkingDirectory "D:\foraj_social\287" -TaskClass AUTO
```

Routing is session-level. The wrapper classifies the first task deterministically, selects provider/model before starting Hermes, and never uses Codex for routing.

## Interactive Professional Session

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\Start-HermesPro.cmd
```

## Fast Local Session

```powershell
cd D:\foraj_social\287\hermes-ops\pro
.\Start-HermesLocal.ps1 -WorkingDirectory "D:\foraj_social\287\alforaijboard"
```

## Explicit Codex Escalation

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\hermes-run.ps1 -Task "heavy coding task" -WorkingDirectory "D:\foraj_social\287" -TaskClass CODEX_HEAVY -EscalationReason "explicit user request"
```

## Status

```powershell
cd D:\foraj_social\287
.\hermes-ops\scripts\hermes-status.ps1
```

## Return To Default Profile

```powershell
hermes profile use default
```
