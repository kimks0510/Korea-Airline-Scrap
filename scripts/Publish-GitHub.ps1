param([Parameter(Mandatory=$true)][string]$BriefingPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
& (Join-Path $PSScriptRoot 'Build-MobileSite.ps1')
$resolved = (Resolve-Path -LiteralPath $BriefingPath).Path
if (-not $resolved.StartsWith($repo, [StringComparison]::OrdinalIgnoreCase)) { throw 'Briefing must be inside repository.' }
$relative = $resolved.Substring($repo.Length).TrimStart('\')
git -C $repo add -- $relative docs AGENTS.md scripts .gitignore
if (git -C $repo diff --cached --quiet) { Write-Output 'Nothing to publish.'; exit 0 }
$date = [regex]::Match([IO.Path]::GetFileName($resolved), '^\d{4}-\d{2}-\d{2}').Value
git -C $repo commit -m "Publish Korean Air report $date"
git -C $repo push origin HEAD:main
Write-Output "Published $date."
