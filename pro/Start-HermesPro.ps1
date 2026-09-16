param(
    [string]$WorkingDirectory = "D:\foraj_social\287\alforaijboard",
    [string]$Profile = "alforaij-pro",
    [switch]$Desktop,
    [switch]$Worktree
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $WorkingDirectory)) {
    throw "Working directory does not exist: $WorkingDirectory"
}

Set-Location -LiteralPath $WorkingDirectory

$toolsets = @(
    "terminal",
    "file",
    "code_execution",
    "clarify",
    "skills",
    "web",
    "browser",
    "vision",
    "delegation",
    "session_search",
    "memory",
    "todo"
)

if ($Desktop) {
    $toolsets += "computer_use"
}

$args = @(
    "-p", $Profile,
    "chat",
    "--toolsets", ($toolsets -join ","),
    "--checkpoints"
)

if ($Worktree) {
    $args += "--worktree"
}

Write-Host "Profile: $Profile"
Write-Host "CWD: $WorkingDirectory"
Write-Host "Toolsets: $($toolsets -join ', ')"
Write-Host "Safety: checkpoints ON; yolo OFF"
Write-Host ""

& hermes @args
