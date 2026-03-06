param(
  [string]$ReadmePath = "README.md"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $ReadmePath)) {
  Write-Error "README file not found: $ReadmePath"
}

$content = Get-Content -Raw -Encoding UTF8 $ReadmePath
$pattern = '(?<!\!)\[[^\]]+\]\((https?://[^)\s]+)\)'
$matches = [regex]::Matches($content, $pattern)

$results = @()

foreach ($m in $matches) {
  $url = $m.Groups[1].Value
  $cleanUrl = $url.Split('#')[0].Split('?')[0]
  $localPath = $null
  $status = "SKIP"

  if ($cleanUrl -match '^https://chung-jiwoong\.github\.io/FMB819/(.+)$') {
    $repoRelative = [uri]::UnescapeDataString($Matches[1]).Replace('/', '\')
    $localPath = $repoRelative
  } elseif ($cleanUrl -match '^https://github\.com/chung-jiwoong/FMB819/blob/main/(.+)$') {
    $repoRelative = [uri]::UnescapeDataString($Matches[1]).Replace('/', '\')
    $localPath = $repoRelative
  }

  if ($null -ne $localPath) {
    if (Test-Path $localPath) {
      $status = "OK"
    } else {
      $status = "MISSING"
    }
  }

  $results += [pscustomobject]@{
    status = $status
    url = $url
    path = $localPath
  }
}

$checked = @($results | Where-Object { $_.status -ne "SKIP" })
$missing = @($checked | Where-Object { $_.status -eq "MISSING" })

if ($checked.Count -eq 0) {
  Write-Output "No repository-local links found."
  exit 0
}

Write-Output ("Checked links: {0}" -f $checked.Count)
foreach ($row in $checked) {
  Write-Output ("{0}`t{1}`t->`t{2}" -f $row.status, $row.url, $row.path)
}

if ($missing.Count -gt 0) {
  Write-Output ""
  Write-Output ("Missing links: {0}" -f $missing.Count)
  exit 1
}

Write-Output ""
Write-Output "All repository-local links are valid."
exit 0
