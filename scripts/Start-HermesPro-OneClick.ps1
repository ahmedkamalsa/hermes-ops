param(
    [string]$WorkingDirectory = "D:\foraj_social\287",
    [string]$Profile = "alforaij-pro",
    [string]$Task = "",
    [ValidateSet("AUTO", "LOCAL_SIMPLE", "CODING", "RESEARCH", "REASONING", "AUXILIARY", "REAL_ESTATE", "CODEX_HEAVY")]
    [string]$TaskClass = "AUTO"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Info($Message) {
    Write-Host "[Hermes Pro] $Message"
}

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

if (-not (Test-Path -LiteralPath $WorkingDirectory)) {
    throw "Working directory does not exist: $WorkingDirectory"
}

Info "Checking gateway for profile $Profile"
$gatewayStatus = (& hermes -p $Profile gateway status 2>&1 | Out-String)
if ($LASTEXITCODE -ne 0 -or $gatewayStatus -match "not running|stopped|inactive") {
    Info "Starting gateway"
    hermes -p $Profile gateway start
}

Info "Checking LM Studio server"
$lmReachable = $false
try {
    Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/models" -Method Get -TimeoutSec 5 | Out-Null
    $lmReachable = $true
} catch {
    $lmReachable = $false
}

if (-not $lmReachable) {
    Info "Starting LM Studio server"
    lms server start
    Start-Sleep -Seconds 3
}

try {
    Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/models" -Method Get -TimeoutSec 10 | Out-Null
} catch {
    throw "LM Studio API is not reachable at http://127.0.0.1:1234/v1"
}

Info "Checking qwen3.5-4b"
$previousPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$loaded = (& lms ps 2>&1 | Out-String)
$ErrorActionPreference = $previousPreference
if ($loaded -notmatch "qwen3\.5-4b") {
    Info "Loading qwen3.5-4b with context 32768"
    lms load qwen3.5-4b --context-length 32768 --gpu 0.4 --ttl 1800 --identifier qwen3.5-4b -y
} else {
    Info "qwen3.5-4b already loaded"
}

Set-Location -LiteralPath $WorkingDirectory

Write-Host ""
if ([string]::IsNullOrWhiteSpace($Task)) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $Task = [Microsoft.VisualBasic.Interaction]::InputBox(
        "What should Hermes Pro do first?",
        "Hermes Pro",
        ""
    )
}

if ([string]::IsNullOrWhiteSpace($Task)) {
    throw "No task was provided."
}

if ($TaskClass -eq "AUTO") {
    $classJson = python (Join-Path $Root "scripts\hermes-smart.py") classify --task $Task
    $TaskClass = [string](($classJson | ConvertFrom-Json).task_class)
}

$routeJson = python (Join-Path $Root "scripts\hermes-smart.py") select --task-class $TaskClass
$route = $routeJson | ConvertFrom-Json
if (-not $route.selected) {
    throw "No HEALTHY verified-free route is available. Refusing paid/unknown model without approval."
}

if ($TaskClass -eq "CODEX_HEAVY" -and $Task -notmatch "(?i)\b(codex|chatgpt)\b") {
    throw "Codex escalation requires explicit request or prior free/local failure evidence."
}

$provider = [string]$route.selected.provider
$model = [string]$route.selected.model_id
$tools = "terminal,file,code_execution,clarify"
if ($TaskClass -eq "CODING") { $tools = "terminal,file,code_execution,clarify,skills" }
if ($TaskClass -eq "RESEARCH") { $tools = "web,terminal,file,clarify" }
if ($TaskClass -eq "REAL_ESTATE") { $tools = "terminal,file,code_execution,clarify,skills" }
if ($TaskClass -eq "CODEX_HEAVY") { $tools = "terminal,file,code_execution,clarify,skills" }

$env:HERMES_TUI_PROVIDER = $provider
$env:HERMES_INFERENCE_PROVIDER = $provider
$env:HERMES_MODEL = $model
$env:HERMES_INFERENCE_MODEL = $model
$env:HERMES_TUI_TOOLSETS = $tools
$env:HERMES_TUI_CHECKPOINTS = "1"
$env:HERMES_TUI_QUERY = ""

Info "Creating routed Hermes session"
$chatOutput = ""
$chatErrorText = ""
$chatExitCode = 1
$terminalCwdState = $null
try {
    $terminalCwdState = Push-TerminalCwd $Profile $WorkingDirectory
    $env:TERMINAL_CWD = $WorkingDirectory
    $env:HERMES_CWD = $WorkingDirectory
    $run = Invoke-NativeCapture @("-p", $Profile, "chat", "--provider", $provider, "--model", $model, "--toolsets", $tools, "--checkpoints", "--pass-session-id", "--in", $WorkingDirectory, "-Q", "-q", $Task)
    $chatOutput = $run.output
    $chatExitCode = $run.exit_code
} catch {
    $chatErrorText = $_.Exception.Message
}
if ($chatExitCode -ne 0) {
    Pop-TerminalCwd $Profile $terminalCwdState
    throw ($chatOutput + $chatErrorText)
}
Pop-TerminalCwd $Profile $terminalCwdState
$terminalCwdState = $null

$sessionId = ""
foreach ($line in ($chatOutput -split "`r?`n")) {
    if ($line -match "^session_id:\s*(\S+)") {
        $sessionId = $Matches[1]
        break
    }
}

if (-not [string]::IsNullOrWhiteSpace($sessionId)) {
    $env:HERMES_TUI_RESUME = $sessionId
    Info "Session: $sessionId"
}

Info "Opening Hermes Desktop with checkpoints"
Info "Route: $TaskClass -> $provider/$model"
& hermes -p $Profile desktop --cwd $WorkingDirectory --skip-build --local
