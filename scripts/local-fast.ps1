param(
  [string]$Prompt = "",
  [string]$WorkingDirectory = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

$argsList = @(
  "--provider", "lmstudio",
  "--model", "qwen3.5-4b",
  "--reasoning", "none",
  "--toolsets", "terminal,file,code_execution,clarify",
  "--ignore-rules",
  "--in", $WorkingDirectory
)

if ($Prompt.Trim()) {
  & hermes @argsList -z $Prompt
} else {
  & hermes @argsList
}
