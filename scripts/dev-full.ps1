param(
  [string]$WorkingDirectory = (Get-Location).Path
)

$ErrorActionPreference = "Stop"

& hermes `
  --provider lmstudio `
  --model qwen3.5-4b `
  --reasoning low `
  --toolsets terminal,file,code_execution,clarify,skills,web,browser,vision,delegation `
  --in $WorkingDirectory
