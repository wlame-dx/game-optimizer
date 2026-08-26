# Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$installDir = "$env:USERPROFILE\.game-optimizer"

# Remove from PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*$installDir*") {
    $newPath = ($userPath -split ';' | Where-Object { $_ -ne $installDir }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "[✓] PATH güncellendi." -ForegroundColor Green
}

# Delete Files
if (Test-Path $installDir) {
    Remove-Item -Recurse -Force $installDir
    Write-Host "[✓] game-optimizer sistemden kaldırıldı." -ForegroundColor Green
} else {
    Write-Host "[!] Kurulum bulunamadı." -ForegroundColor Red
}
pause
