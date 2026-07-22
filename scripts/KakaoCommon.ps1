Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-KakaoTokenPath {
    if ($env:KAKAO_TOKEN_PATH) { return $env:KAKAO_TOKEN_PATH }
    $local = Join-Path $PSScriptRoot '..\.secrets\kakao-token.json'
    if (Test-Path -LiteralPath $local) { return $local }
    $shared = Join-Path $PSScriptRoot '..\..\.secrets\kakao-token.json'
    return $shared
}

function Get-KakaoSetting([string]$Name) {
    $value = [Environment]::GetEnvironmentVariable($Name, 'User')
    if ([string]::IsNullOrWhiteSpace($value)) { $value = [Environment]::GetEnvironmentVariable($Name, 'Process') }
    if ([string]::IsNullOrWhiteSpace($value)) { throw "Required environment variable is missing: $Name" }
    return $value
}

function Save-KakaoToken($Token) {
    $Token | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Get-KakaoTokenPath) -Encoding UTF8
}

function Get-KakaoAccessToken {
    $path = Get-KakaoTokenPath
    if (-not (Test-Path -LiteralPath $path)) { throw "Kakao token not found: $path" }
    $token = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
    if (-not $token.access_token) { throw 'Kakao access_token is missing.' }
    $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    if ($token.expires_at -gt ($now + 300)) { return [string]$token.access_token }

    if (-not $token.refresh_token) { throw 'Kakao refresh_token is missing. Reauthorize Kakao.' }
    $body = @{
        grant_type = 'refresh_token'
        client_id = Get-KakaoSetting 'KAKAO_REST_API_KEY'
        refresh_token = $token.refresh_token
    }
    $secret = [Environment]::GetEnvironmentVariable('KAKAO_CLIENT_SECRET', 'User')
    if ([string]::IsNullOrWhiteSpace($secret)) { $secret = [Environment]::GetEnvironmentVariable('KAKAO_CLIENT_SECRET', 'Process') }
    if (-not [string]::IsNullOrWhiteSpace($secret)) { $body.client_secret = $secret }

    $fresh = Invoke-RestMethod -Method Post -Uri 'https://kauth.kakao.com/oauth/token' -ContentType 'application/x-www-form-urlencoded;charset=utf-8' -Body $body
    $token.access_token = $fresh.access_token
    $token.expires_at = $now + [int64]$fresh.expires_in
    if ($fresh.PSObject.Properties.Name -contains 'refresh_token') { $token.refresh_token = $fresh.refresh_token }
    Save-KakaoToken $token
    return [string]$token.access_token
}
