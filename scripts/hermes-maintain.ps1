param(
  [ValidateSet("daily", "weekly", "failure")]
  [string]$Mode = "daily"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

Push-Location $Root
try {
  python .\scripts\free-model-scout.py

  if ($Mode -eq "weekly") {
    python .\scripts\model-benchmark.py
  } elseif ($Mode -eq "failure") {
    python .\scripts\model-benchmark.py
  }

  python .\scripts\hermes-smart.py refresh-registry
} finally {
  Pop-Location
}
