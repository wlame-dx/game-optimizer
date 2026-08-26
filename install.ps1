$ErrorActionPreference = 'Stop'
$sourceDir = $PSScriptRoot
$targetDir = Join-Path $env:USERPROFILE '.game-optimizer'
$sourceModules = Join-Path $sourceDir 'modules'
$targetModules = Join-Path $targetDir 'modules'

New-Item -ItemType Directory -Force -Path $targetModules | Out-Null

# Eski sürümden kalmış modülleri kaldır; kaynakta olmayan özellikler kurulu sürümde kalmasın.
Get-ChildItem -LiteralPath $targetModules -File -ErrorAction SilentlyContinue | Remove-Item -Force

Write-Host 'Dil Seçin / Select Language:' -ForegroundColor Yellow
Write-Host '[1] Türkçe (TR)'
Write-Host '[2] English (EN)'
$langChoice = Read-Host 'Seçim / Choice (1/2)'
$lang = if ($langChoice -eq '2') { 'EN' } else { 'TR' }

@{ Language = $lang } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $targetDir 'config.json') -Encoding UTF8

Copy-Item -LiteralPath (Join-Path $sourceDir 'launch.ps1') -Destination (Join-Path $targetDir 'launch.ps1') -Force
Copy-Item -Path (Join-Path $sourceModules '*') -Destination $targetModules -Force -Recurse

$cmdContent = "@echo off`r`nchcp 65001 >nul`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"$targetDir\launch.ps1`""
Set-Content -LiteralPath (Join-Path $targetDir 'game-optimizer.cmd') -Value $cmdContent -Encoding ASCII -Force

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$targetDir*") {
    [Environment]::SetEnvironmentVariable('Path', "$userPath;$targetDir", 'User')
}

Write-Host "`n[✓] Kurulum Tamamlandı! / Installation Completed!" -ForegroundColor Green
Write-Host "[!] 'game-optimizer' yazarak çalıştırabilirsiniz." -ForegroundColor Cyan
