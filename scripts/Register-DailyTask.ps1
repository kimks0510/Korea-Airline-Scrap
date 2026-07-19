Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script = (Resolve-Path (Join-Path $PSScriptRoot 'Run-DailyScrap.ps1')).Path
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
$trigger = New-ScheduledTaskTrigger -Daily -At '08:20'
$settings = New-ScheduledTaskSettingsSet -WakeToRun -StartWhenAvailable -RunOnlyIfNetworkAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 10) -ExecutionTimeLimit (New-TimeSpan -Hours 2)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'Korean Air Daily Scrap' -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Description 'Build and publish Korean Air cabin crew preparation report' -Force | Out-Null
Write-Output 'Scheduled task registered: Korean Air Daily Scrap (daily 08:20)'
