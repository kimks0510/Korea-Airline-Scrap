Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$date = Get-Date -Format 'yyyy-MM-dd'
$report = Join-Path $repo "output\$date-korean-air.md"
$log = Join-Path $repo 'output\errors.log'
try {
    $prompt = @"
AGENTS.md 지침에 따라 오늘자 대한항공 객실승무원 준비용 스크랩을 작성하세요. 현재 날짜는 $date (Asia/Seoul)입니다. 최근 24~48시간 자료 중 대한항공·아시아나 공식 자료, 정부·규제·공항·ICAO·IATA 자료를 최우선으로 하고 Reuters, Bloomberg, FT, WSJ, Nikkei Asia, 연합뉴스급 직접 취재 보도로 교차검증하세요. 블로그·커뮤니티·출처 불명 재인용은 제외하고 기사마다 출처 등급과 면접 활용 신뢰도를 표시하세요. 기존 output의 모든 보고서를 참고해 최근 7일·30일 누적 인사이트를 갱신하세요. 약어와 업계 용어는 초보자 설명을 붙이고 숫자 범위에는 물결표(~)를 쓰지 마세요. 결과는 반드시 $report 에 저장하세요. 저장 후 파일이 존재하는지 검증하세요.
"@
    Push-Location $repo
    try {
        & codex --search --sandbox workspace-write --ask-for-approval never exec $prompt
        if ($LASTEXITCODE -ne 0) { throw "codex exec exit code: $LASTEXITCODE" }
    } finally { Pop-Location }
    if (-not (Test-Path -LiteralPath $report)) { throw "Report was not created: $report" }
    & (Join-Path $PSScriptRoot 'Publish-GitHub.ps1') -BriefingPath $report
    & (Join-Path $PSScriptRoot 'Send-KakaoLink.ps1') -ReportDate $date -BriefingPath $report
} catch {
    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $($_.Exception.Message)"
    Add-Content -LiteralPath $log -Value $line -Encoding UTF8
    throw
}
