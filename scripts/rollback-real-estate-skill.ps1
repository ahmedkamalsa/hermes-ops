param(
  [string]$TargetRoot = "$env:HERMES_HOME\skills"
)

$ErrorActionPreference = "Stop"
$Target = Join-Path $TargetRoot "real-estate-intelligence"
if (Test-Path $Target) {
  Remove-Item -Path $Target -Recurse -Force
  Write-Output "Removed $Target"
}
Write-Output "If a timestamped backup exists next to the target, restore it manually after review."
