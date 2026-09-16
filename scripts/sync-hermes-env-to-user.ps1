param(
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$envFiles = @(
  (Join-Path $env:LOCALAPPDATA "Hermes\.env"),
  (Join-Path $env:LOCALAPPDATA "Hermes\supabase.env")
)

$allowList = @(
  "BROWSER_USE_API_KEY",
  "GITHUB_TOKEN",
  "HERMES_LANGFUSE_PUBLIC_KEY",
  "HERMES_LANGFUSE_SECRET_KEY",
  "LM_API_KEY",
  "OPENCODE_ZEN_API_KEY",
  "OPENROUTER_API_KEY",
  "SUPABASE_ANON_KEY",
  "SUPABASE_KEY",
  "SUPABASE_PROJECT_REF",
  "SUPABASE_PUBLISHABLE_KEY",
  "SUPABASE_SECRET_KEY",
  "SUPABASE_SERVICE_KEY",
  "SUPABASE_SERVICE_ROLE_KEY",
  "SUPABASE_URL",
  "TERMINAL_ENV",
  "UPSTASH_REDIS_REST_URL",
  "UPSTASH_REDIS_REST_TOKEN",
  "UPSTASH_REDIS_URL",
  "UPSTASH_BLOB_URL",
  "UPSTASH_BLOB_TOKEN",
  "CLOUDFLARE_ACCOUNT_ID",
  "CLOUDFLARE_API_TOKEN",
  "NETLIFY_AUTH_TOKEN",
  "GOOGLE_API_KEY",
  "GEMINI_API_KEY",
  "HF_TOKEN",
  "FIREBASE_API_KEY",
  "FIREBASE_AUTH_DOMAIN",
  "FIREBASE_PROJECT_ID",
  "FIREBASE_PROJECT_NUMBER",
  "FIREBASE_STORAGE_BUCKET",
  "FIREBASE_APP_ID",
  "FIREBASE_MEASUREMENT_ID",
  "FIREBASE_ANALYTICS_PROPERTY_ID",
  "FIREBASE_MESSAGING_SENDER_ID"
)

function Read-DotEnvFile {
  param([Parameter(Mandatory = $true)][string]$Path)

  $result = @{}
  if (-not (Test-Path -LiteralPath $Path)) {
    return $result
  }

  foreach ($line in Get-Content -LiteralPath $Path) {
    if ($line -match '^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$') {
      $name = $matches[1]
      $value = $matches[2].Trim()
      if (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'"))) {
        $value = $value.Substring(1, $value.Length - 2)
      }
      if ($allowList -contains $name -and -not [string]::IsNullOrWhiteSpace($value)) {
        $result[$name] = $value
      }
    }
  }

  return $result
}

$merged = @{}
foreach ($file in $envFiles) {
  $parsed = Read-DotEnvFile -Path $file
  foreach ($key in $parsed.Keys) {
    $merged[$key] = $parsed[$key]
  }
}

if ($merged.ContainsKey("SUPABASE_SERVICE_KEY") -and -not $merged.ContainsKey("SUPABASE_SERVICE_ROLE_KEY")) {
  $merged["SUPABASE_SERVICE_ROLE_KEY"] = $merged["SUPABASE_SERVICE_KEY"]
}

$changed = @()
$unchanged = @()

foreach ($name in ($merged.Keys | Sort-Object)) {
  $newValue = [string]$merged[$name]
  $currentValue = [Environment]::GetEnvironmentVariable($name, "User")
  if ($currentValue -ne $newValue) {
    if (-not $DryRun) {
      New-ItemProperty -Path "HKCU:\Environment" -Name $name -Value $newValue -PropertyType String -Force | Out-Null
      Set-Item -Path ("Env:{0}" -f $name) -Value $newValue
    }
    $changed += $name
  } else {
    $unchanged += $name
  }
}

[pscustomobject]@{
  dry_run = [bool]$DryRun
  source_files_present = @($envFiles | Where-Object { Test-Path -LiteralPath $_ }).Count
  changed = $changed
  unchanged = $unchanged
  changed_count = $changed.Count
  unchanged_count = $unchanged.Count
} | ConvertTo-Json -Depth 4
