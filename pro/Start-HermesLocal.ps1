param(
    [string]$WorkingDirectory = "D:\foraj_social\287\alforaijboard",
    [string]$Profile = "alforaij-pro"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $WorkingDirectory)) {
    throw "Working directory does not exist: $WorkingDirectory"
}

Set-Location -LiteralPath $WorkingDirectory

& hermes -p $Profile chat `
    --provider lmstudio `
    --model qwen3.5-4b `
    --toolsets "terminal,file,code_execution,clarify" `
    --checkpoints
