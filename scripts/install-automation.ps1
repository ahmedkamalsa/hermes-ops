param(
  [string]$TaskPrefix = "HermesOps"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Pwsh = (Get-Command powershell.exe).Source

$daily = New-ScheduledTaskAction -Execute $Pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$Root\scripts\hermes-maintain.ps1`" -Mode daily"
$weekly = New-ScheduledTaskAction -Execute $Pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$Root\scripts\hermes-maintain.ps1`" -Mode weekly"
$review = New-ScheduledTaskAction -Execute $Pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -Command `"python `"$Root\scripts\improvement-manager.py`" review`""

Register-ScheduledTask -TaskName "$TaskPrefix Daily Maintenance" -Action $daily -Trigger (New-ScheduledTaskTrigger -Daily -At 9:00am) -Description "Hermes Ops daily catalog and health refresh." -Force
Register-ScheduledTask -TaskName "$TaskPrefix Weekly Benchmark" -Action $weekly -Trigger (New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 9:30am) -Description "Hermes Ops weekly tiny free-model benchmark." -Force
Register-ScheduledTask -TaskName "$TaskPrefix Weekly Improvement Review" -Action $review -Trigger (New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 10:00am) -Description "Hermes Ops weekly controlled improvement review." -Force

Write-Output "Installed scheduled tasks with prefix '$TaskPrefix'."
