param(
    [string]$Profile = "alforaij-pro",
    [string]$Workspace = "D:\foraj_social\287"
)

$ErrorActionPreference = "Continue"

Write-Host "=== HERMES PROFILE ==="
Write-Host "Profile: $Profile"
hermes -p $Profile config get model.provider
hermes -p $Profile config get model.default
hermes -p $Profile config get model.context_length

Write-Host "`n=== LM STUDIO ==="
try {
    $models = Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/models" -Method Get -TimeoutSec 8
    Write-Host "LM Studio API: reachable"
    if ($models.data) {
        $models.data | Select-Object id | Format-Table -AutoSize
    }
} catch {
    Write-Host "LM Studio API: unreachable"
}
lms ps

Write-Host "`n=== RECENT SESSION ==="
hermes sessions list --limit 1

Write-Host "`n=== CHECKPOINT SUPPORT ==="
hermes -p $Profile chat --help | Select-String -Pattern "checkpoint|resume|worktree"

Write-Host "`n=== FREE ROUTE HEALTH ==="
python "$Workspace\hermes-ops\scripts\hermes-smart.py" select --task-class LOCAL_SIMPLE
