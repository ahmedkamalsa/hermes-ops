param(
  [string]$TaskPrefix = "HermesOps"
)

$ErrorActionPreference = "Stop"
$names = @(
  "$TaskPrefix Daily Maintenance",
  "$TaskPrefix Weekly Benchmark",
  "$TaskPrefix Weekly Improvement Review"
)

foreach ($name in $names) {
  $task = Get-ScheduledTask -TaskName $name -ErrorAction SilentlyContinue
  if ($task) {
    Unregister-ScheduledTask -TaskName $name -Confirm:$false
    Write-Output "Removed $name"
  }
}
