param(
    [string]$Profile = "alforaij-pro",
    [switch]$Activate,
    [switch]$EnableComputerUse,
    [switch]$EnableLmStudioJit
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Warn($msg) {
    Write-Host "WARNING: $msg" -ForegroundColor Yellow
}

Step "Checking Hermes"
$hermes = Get-Command hermes -ErrorAction Stop
Write-Host "Hermes: $($hermes.Source)"
hermes --version

Step "Creating Hermes backup BEFORE any config mutation"
hermes backup

Step "Restarting the default gateway to clear mixed pre/post-update modules"
try {
    hermes gateway restart
} catch {
    Warn "Gateway restart returned an error. Continuing to doctor; if doctor reports gateway trouble, stop and review it."
}

Step "Running baseline diagnostics"
hermes doctor
hermes prompt-size

Step "Creating isolated professional profile if it does not already exist"
$profileExists = $false
try {
    hermes profile show $Profile *> $null
    if ($LASTEXITCODE -eq 0) { $profileExists = $true }
} catch {
    $profileExists = $false
}

if (-not $profileExists) {
    hermes profile create $Profile --clone
    Write-Host "Created profile: $Profile"
} else {
    Write-Host "Profile already exists: $Profile"
}

Step "Removing inherited fallback chains from the new profile"
# This prevents a cloned paid/unknown fallback from being used silently.
try { hermes -p $Profile config unset fallback_providers } catch {}
try { hermes -p $Profile config unset fallback_model } catch {}

Step "Pinning reliable local primary model"
hermes -p $Profile config set model.provider lmstudio
hermes -p $Profile config set model.default qwen3.5-4b
hermes -p $Profile config set model.base_url http://127.0.0.1:1234/v1

if ($EnableLmStudioJit) {
    Step "Enabling LM Studio JIT loading (use only when Auto-Evict/JIT is enabled in LM Studio)"
    hermes -p $Profile config set model.lmstudio_load_mode jit
}

Step "Making the model more agentic and verification-oriented"
hermes -p $Profile config set agent.reasoning_effort low
hermes -p $Profile config set agent.tool_use_enforcement true
hermes -p $Profile config set agent.execution_guidance true
hermes -p $Profile config set display.tool_progress all
hermes -p $Profile config set display.show_cost true

Step "Validating profile configuration"
hermes -p $Profile config check
hermes -p $Profile doctor

Step "Checking LM Studio API"
$lmOk = $false
try {
    $models = Invoke-RestMethod -Uri "http://127.0.0.1:1234/v1/models" -Method Get -TimeoutSec 8
    $lmOk = $true
    Write-Host "LM Studio API is reachable."
    if ($models.data) {
        Write-Host ("Models: " + (($models.data | ForEach-Object { $_.id }) -join ", "))
    }
} catch {
    Warn "LM Studio is not reachable on 127.0.0.1:1234. Start LM Studio Server before the local smoke test."
}

if ($EnableComputerUse) {
    Step "Checking / installing Hermes Computer Use backend"
    try {
        hermes computer-use status
    } catch {
        hermes computer-use install
        hermes computer-use status
    }
}

if ($lmOk) {
    Step "Local agent smoke test"
    hermes -p $Profile chat --oneshot `
        --provider lmstudio `
        --model qwen3.5-4b `
        --toolsets "terminal,file,code_execution,clarify" `
        -q "Reply with exactly OK"
}

if ($Activate) {
    Step "Making $Profile the sticky default"
    hermes profile use $Profile
} else {
    Write-Host ""
    Write-Host "Profile was NOT made the global default. This is intentional preserve-first behavior."
    Write-Host "After you verify it, activate with:"
    Write-Host "  hermes profile use $Profile"
}

Write-Host ""
Write-Host "SETUP COMPLETE" -ForegroundColor Green
Write-Host "Professional launch:"
Write-Host "  .\Start-HermesPro.ps1"
Write-Host "Safe local launch:"
Write-Host "  .\Start-HermesLocal.ps1"
