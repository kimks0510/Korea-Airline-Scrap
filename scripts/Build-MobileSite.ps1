param([string]$OutputDir = (Join-Path $PSScriptRoot '..\output'), [string]$DocsDir = (Join-Path $PSScriptRoot '..\docs'))
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$resolvedOutput = (Resolve-Path -LiteralPath $OutputDir).Path
$resolvedDocs = (Resolve-Path -LiteralPath $DocsDir).Path
$reportsDir = Join-Path $resolvedDocs 'reports'
New-Item -ItemType Directory -Path $reportsDir -Force | Out-Null

$entries = @()
Get-ChildItem -LiteralPath $resolvedOutput -Filter '*.md' -File | Sort-Object Name -Descending | ForEach-Object {
    $target = Join-Path $reportsDir $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
    $title = (Get-Content -LiteralPath $_.FullName -Encoding UTF8 | Where-Object { $_ -match '^# ' } | Select-Object -First 1) -replace '^#\s*',''
    $entries += [ordered]@{ id = $_.BaseName; date = $_.BaseName.Substring(0,10); file = "reports/$($_.Name)"; title = $title }
}
$manifest = [ordered]@{ updatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:sszzz'); reports = $entries }
$json = $manifest | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText((Join-Path $resolvedDocs 'reports.json'), $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Built site manifest with $($entries.Count) report(s)."
