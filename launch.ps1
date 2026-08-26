$installDir = "$env:USERPROFILE\.game-optimizer"

. "$installDir\modules\Localization.ps1"
. "$installDir\modules\Scanner.ps1"
. "$installDir\modules\Optimizer.ps1"
. "$installDir\modules\RegistryOptimizer.ps1"
Restore-StaleRegistryBackup

# Kurulumdan sonra güncel proje dosyalarının kullanılmasını sağla.
$projectDir = Split-Path -Parent $PSScriptRoot
if (Test-Path "$projectDir\modules\RegistryOptimizer.ps1") {
    . "$projectDir\modules\RegistryOptimizer.ps1"
}

Clear-Host
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "    $(Get-Text 'Title')" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "$(Get-Text 'Scanning')" -ForegroundColor Gray

$games = Get-InstalledGames

if (-not $games -or $games.Count -eq 0) {
    Write-Host "$(Get-Text 'NoGames')" -ForegroundColor Red
    pause
    exit
}

Write-Host "`n--- $(Get-Text 'FoundGames') ---" -ForegroundColor Green
for ($i = 0; $i -lt $games.Count; $i++) {
    Write-Host "[$($i + 1)] $($games[$i].Name) ($($games[$i].Platform))"
}

Write-Host "[Q] Exit / Çıkış" -ForegroundColor Red
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

$selection = Read-Host "$(Get-Text 'EnterChoice')"

# Q/exit sistemi korunur: registry yedeği varsa geri yüklenir ve program kapanır.
if ($selection -match '^(q|exit)$') {
    Stop-Cleanup
}

$index = 0
if (-not [int]::TryParse($selection, [ref]$index)) {
    Write-Host "$(Get-Text 'InvalidChoice')" -ForegroundColor Red
    pause
    exit
}

$index--
if ($index -ge 0 -and $index -lt $games.Count) {
    Start-Optimization -Game $games[$index]
} else {
    Write-Host "$(Get-Text 'InvalidChoice')" -ForegroundColor Red
    pause
}
