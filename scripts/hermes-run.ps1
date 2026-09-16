param(
  [Parameter(Mandatory = $true)]
  [string]$Task,
  [string]$WorkingDirectory = (Get-Location).Path,
  [string]$Profile = "alforaij-pro",
  [ValidateSet("AUTO", "LOCAL_SIMPLE", "CODING", "RESEARCH", "REASONING", "AUXILIARY", "REAL_ESTATE", "CODEX_HEAVY")]
  [string]$TaskClass = "AUTO",
  [string]$EscalationReason = ""
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$LogPath = Join-Path $Root "hermes-run-log.jsonl"
$Started = Get-Date

function Invoke-NativeCapture($CommandArgs) {
  function ConvertTo-ProcessArgument([string]$Arg) {
    if ($Arg.Length -eq 0) { return '""' }
    if ($Arg -notmatch '[\s"]') { return $Arg }
    $result = '"'
    $slashes = 0
    foreach ($char in $Arg.ToCharArray()) {
      if ($char -eq '\') {
        $slashes += 1
      } elseif ($char -eq '"') {
        $result += ('\' * (($slashes * 2) + 1))
        $result += '"'
        $slashes = 0
      } else {
        if ($slashes -gt 0) {
          $result += ('\' * $slashes)
          $slashes = 0
        }
        $result += $char
      }
    }
    if ($slashes -gt 0) { $result += ('\' * ($slashes * 2)) }
    $result += '"'
    return $result
  }

  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "hermes"
  $psi.Arguments = (($CommandArgs | ForEach-Object { ConvertTo-ProcessArgument ([string]$_) }) -join " ")
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $psi
  [void]$process.Start()
  $stdout = $process.StandardOutput.ReadToEnd()
  $stderr = $process.StandardError.ReadToEnd()
  $process.WaitForExit()
  return @{ output = ($stdout + $stderr); exit_code = $process.ExitCode }
}

function Push-TerminalCwd($ProfileName, $Directory) {
  $current = Invoke-NativeCapture @("-p", $ProfileName, "config", "get", "terminal.cwd")
  $hadValue = ($current.exit_code -eq 0 -and -not [string]::IsNullOrWhiteSpace($current.output))
  $previous = ($current.output | Out-String).Trim()
  $set = Invoke-NativeCapture @("-p", $ProfileName, "config", "set", "terminal.cwd", $Directory)
  if ($set.exit_code -ne 0) { throw $set.output }
  return @{ had_value = $hadValue; previous = $previous }
}

function Pop-TerminalCwd($ProfileName, $State) {
  if ($null -eq $State) { return }
  if ($State.had_value) {
    Invoke-NativeCapture @("-p", $ProfileName, "config", "set", "terminal.cwd", $State.previous) | Out-Null
  } else {
    Invoke-NativeCapture @("-p", $ProfileName, "config", "unset", "terminal.cwd") | Out-Null
  }
}

if ($TaskClass -eq "AUTO") {
  $classJson = python (Join-Path $Root "scripts\hermes-smart.py") classify --task $Task
  $TaskClass = [string](($classJson | ConvertFrom-Json).task_class)
}

if ($TaskClass -eq "CODEX_HEAVY" -and [string]::IsNullOrWhiteSpace($EscalationReason) -and $Task -match "(?i)\b(codex|chatgpt)\b") {
  $EscalationReason = "explicit user request"
}

if ($TaskClass -eq "CODEX_HEAVY" -and [string]::IsNullOrWhiteSpace($EscalationReason)) {
  throw "CODEX_HEAVY requires -EscalationReason. Codex is explicit escalation only."
}

$routeJson = python (Join-Path $Root "scripts\hermes-smart.py") select --task-class $TaskClass
$route = $routeJson | ConvertFrom-Json
if (-not $route.selected) {
  throw "No HEALTHY verified-free route is available. Refusing paid/unknown model without approval."
}

$provider = [string]$route.selected.provider
$model = [string]$route.selected.model_id
$tools = "terminal,file,code_execution,clarify"
if ($TaskClass -eq "CODING") { $tools = "terminal,file,code_execution,clarify,skills" }
if ($TaskClass -eq "RESEARCH") { $tools = "web,terminal,file,clarify" }
if ($TaskClass -eq "REAL_ESTATE") { $tools = "terminal,file,code_execution,clarify,skills" }
if ($TaskClass -eq "CODEX_HEAVY") { $tools = "terminal,file,code_execution,clarify,skills" }

$argsList = @(
  "-p", $Profile,
  "chat",
  "--provider", $provider,
  "--model", $model,
  "--reasoning", "none",
  "--toolsets", $tools,
  "--in", $WorkingDirectory,
  "--pass-session-id",
  "-Q",
  "-q", $Task
)

$ok = $false
$output = ""
$errorText = ""
$runExitCode = 1
$terminalCwdState = $null
try {
  $terminalCwdState = Push-TerminalCwd $Profile $WorkingDirectory
  $env:TERMINAL_CWD = $WorkingDirectory
  $env:HERMES_CWD = $WorkingDirectory
  $run = Invoke-NativeCapture $argsList
  $output = $run.output
  $runExitCode = $run.exit_code
  if ($runExitCode -eq 0) { $ok = $true }
} catch {
  $errorText = $_.Exception.Message
} finally {
  Pop-TerminalCwd $Profile $terminalCwdState
}

$sessionId = ""
foreach ($line in ($output -split "`r?`n")) {
  if ($line -match "^session_id:\s*(\S+)") {
    $sessionId = $Matches[1]
    break
  }
}

$Ended = Get-Date
$entry = [ordered]@{
  timestamp = $Started.ToUniversalTime().ToString("o")
  task_class = $TaskClass
  provider = $provider
  model = $model
  session_id = $sessionId
  tools = $tools
  paid_allowed = $false
  escalation_reason = $EscalationReason
  ok = $ok
  latency_ms = [int](($Ended - $Started).TotalMilliseconds)
  exit_code = $runExitCode
  error = $errorText
}
($entry | ConvertTo-Json -Compress) | Add-Content -Path $LogPath -Encoding UTF8

if (-not $ok) {
  python (Join-Path $Root "scripts\improvement-manager.py") review | Out-Null
  throw "Hermes run failed. Logged to $LogPath"
}

$output
