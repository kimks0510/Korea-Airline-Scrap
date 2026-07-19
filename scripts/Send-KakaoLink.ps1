param(
    [Parameter(Mandatory=$true)][string]$ReportDate,
    [string]$SiteUrl = 'https://kimks0510.github.io/Korea-Airline-Scrap/'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'KakaoCommon.ps1')

$url = "$($SiteUrl.TrimEnd('/'))/#$ReportDate"
$template = @{
    object_type = 'text'
    text = "[$ReportDate 대한항공 스크랩]`n모바일 리포트에서 전체 내용을 확인하세요.`n$url"
    link = @{ web_url = $url; mobile_web_url = $url }
    button_title = '리포트 열기'
} | ConvertTo-Json -Depth 5 -Compress
$body = @{ template_object = $template }
$headers = @{ Authorization = "Bearer $(Get-KakaoAccessToken)" }
Invoke-RestMethod -Method Post -Uri 'https://kapi.kakao.com/v2/api/talk/memo/default/send' -Headers $headers -Body $body -ContentType 'application/x-www-form-urlencoded;charset=utf-8' | Out-Null
Write-Output "Kakao link sent: $url"
