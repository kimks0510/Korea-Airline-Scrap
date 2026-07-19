Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-KakaoTokenPath {
    if ($env:KAKAO_TOKEN_PATH) { return $env:KAKAO_TOKEN_PATH }
    $local = Join-Path $PSScriptRoot '..\.secrets\kakao-token.json'
    if (Test-Path -LiteralPath $local) { return $local }
    $shared = Join-Path $PSScriptRoot '..\..\.secrets\kakao-token.json'
    return $shared
}

function Get-KakaoAccessToken {
    $path = Get-KakaoTokenPath
    if (-not (Test-Path -LiteralPath $path)) { throw "Kakao token not found: $path" }
    $token = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $token.access_token) { throw 'Kakao access_token is missing.' }
    return [string]$token.access_token
}
