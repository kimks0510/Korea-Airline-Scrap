param(
    [Parameter(Mandatory=$true)][string]$ReportDate,
    [string]$BriefingPath,
    [string]$SiteUrl = 'https://kimks0510.github.io/Korea-Airline-Scrap/'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'KakaoCommon.ps1')

$projectRoot = Split-Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($BriefingPath)) {
    $BriefingPath = Join-Path $projectRoot "output\$ReportDate-korean-air.md"
}
if (-not (Test-Path -LiteralPath $BriefingPath)) {
    throw "Report not found: $BriefingPath"
}

$lines = Get-Content -LiteralPath $BriefingPath -Encoding UTF8
$heading = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^## .*3.*$') { $heading = $i; break }
}
if ($heading -lt 0) { throw 'Three-line summary heading not found.' }

$summary = @()
for ($i = $heading + 1; $i -lt $lines.Count -and $summary.Count -lt 3; $i++) {
    if ($lines[$i] -match '^\d+\.\s+(.+)$') { $summary += $Matches[1] }
}
if ($summary.Count -ne 3) { throw 'Exactly three summary sentences are required.' }

$url = "$($SiteUrl.TrimEnd('/'))/?v=$($ReportDate.Replace('-',''))#$ReportDate"
$accessToken = Get-KakaoAccessToken
$headers = @{ Authorization = "Bearer $accessToken" }
$messages = @()
for ($part = 0; $part -lt 3; $part++) {
    $messages += "[$ReportDate Korean Air $($part + 1)/4]`n$($summary[$part])"
}
$messages += "[$ReportDate Full Report 4/4]`n$url"

for ($part = 0; $part -lt $messages.Count; $part++) {
    if ($messages[$part].Length -gt 200) {
        throw "Kakao message $($part + 1) exceeds 200 characters."
    }
    $template = @{
        object_type = 'text'
        text = $messages[$part]
        link = @{ web_url = $url; mobile_web_url = $url }
        button_title = 'Full Report'
    } | ConvertTo-Json -Depth 5 -Compress
    Invoke-RestMethod -Method Post -Uri 'https://kapi.kakao.com/v2/api/talk/memo/default/send' -Headers $headers -Body @{ template_object = $template } -ContentType 'application/x-www-form-urlencoded;charset=utf-8' | Out-Null
    Start-Sleep -Milliseconds 350
}
Write-Output "Three summaries and report link sent: $url"
