param(
    [Parameter(Mandatory=$true)][string]$ReportDate,
    [string]$SiteUrl = 'https://kimks0510.github.io/Korea-Airline-Scrap/'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'KakaoCommon.ps1')

$url = "$($SiteUrl.TrimEnd('/'))/#$ReportDate"
# Windows PowerShell 5.1 can misread a BOM-less UTF-8 script. Keep the source
# text ASCII-only and decode the Korean message explicitly as UTF-8.
$koreanCodePoints = @(0xB300,0xD55C,0xD56D,0xACF5,0x20,0xC2A4,0xD06C,0xB7A9,0x5D,0xA,0xBAA8,0xBC14,0xC77C,0x20,0xB9AC,0xD3EC,0xD2B8,0xC5D0,0xC11C,0x20,0xC804,0xCCB4,0x20,0xB0B4,0xC6A9,0xC744,0x20,0xD655,0xC778,0xD558,0xC138,0xC694,0x2E)
$messageFormat = '[{0} ' + (-join ($koreanCodePoints | ForEach-Object { [char]$_ }))
$messageText = [string]::Format($messageFormat, $ReportDate)
$template = @{
    object_type = 'text'
    text = "$messageText`n$url"
    link = @{ web_url = $url; mobile_web_url = $url }
    button_title = '리포트 열기'
} | ConvertTo-Json -Depth 5 -Compress
$body = @{ template_object = $template }
$headers = @{ Authorization = "Bearer $(Get-KakaoAccessToken)" }
Invoke-RestMethod -Method Post -Uri 'https://kapi.kakao.com/v2/api/talk/memo/default/send' -Headers $headers -Body $body -ContentType 'application/x-www-form-urlencoded;charset=utf-8' | Out-Null
Write-Output "Kakao link sent: $url"
