param(
  [string]$TargetRoot = "$env:HERMES_HOME\skills"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Source = Join-Path $Root "skills\real-estate-intelligence"
$Target = Join-Path $TargetRoot "real-estate-intelligence"
$Backup = "$Target.backup-$(Get-Date -Format yyyyMMdd-HHmmss)"

if (-not (Test-Path $Source)) { throw "Missing source skill: $Source" }
if (Test-Path $Target) {
  Copy-Item -Path $Target -Destination $Backup -Recurse -Force
  Write-Output "Backup created: $Backup"
}
New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
Copy-Item -Path $Source -Destination $Target -Recurse -Force
Write-Output "Installed skill draft to $Target. Not activated in Hermes config."
