param(
  [Parameter(Mandatory = $true)]
  [string]$ChapterQmd
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$chapterPath = Join-Path $projectRoot $ChapterQmd

if (-not (Test-Path $chapterPath)) {
  Write-Error "File not found: $chapterPath"
  exit 1
}

quarto render $chapterPath --project $projectRoot
