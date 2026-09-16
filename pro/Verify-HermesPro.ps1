param(
    [string]$Profile = "alforaij-pro"
)

$ErrorActionPreference = "Continue"

Write-Host "=== VERSION ==="
hermes --version

Write-Host "`n=== PROFILE ==="
hermes profile show $Profile

Write-Host "`n=== CONFIG CHECK ==="
hermes -p $Profile config check

Write-Host "`n=== DOCTOR ==="
hermes -p $Profile doctor

Write-Host "`n=== PROMPT SIZE ==="
hermes -p $Profile prompt-size

Write-Host "`n=== COMPUTER USE ==="
hermes computer-use status

Write-Host "`n=== LM STUDIO ==="
try {
    $models = Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/models" -Method Get -TimeoutSec 8
    $models.data | Select-Object id | Format-Table -AutoSize
} catch {
    Write-Warning "LM Studio API unreachable: $($_.Exception.Message)"
}

Write-Host "`n=== FREE MODEL SCOUT (existing Hermes Ops) ==="
$scout = "D:\foraj_social\287\hermes-ops\scripts\free-model-scout.py"
$bench = "D:\foraj_social\287\hermes-ops\scripts\model-benchmark.py"
if (Test-Path $scout) { python $scout } else { Write-Warning "Scout script not found: $scout" }
if (Test-Path $bench) { python $bench } else { Write-Warning "Benchmark script not found: $bench" }
