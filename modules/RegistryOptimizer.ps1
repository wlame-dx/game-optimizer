$script:RegistryBackupPath = Join-Path $env:USERPROFILE '.game-optimizer\registry-backup.json'

function Get-RegistryValueState {
    param ([string]$Path, [string]$Name)

    $key = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $key) {
        return [PSCustomObject]@{ Path = $Path; Name = $Name; Exists = $false; Value = $null; Type = 'DWord' }
    }

    $property = Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $property) {
        return [PSCustomObject]@{ Path = $Path; Name = $Name; Exists = $false; Value = $null; Type = 'DWord' }
    }

    $value = $property.$Name
    $type = (Get-Item -LiteralPath $Path).GetValueKind($Name).ToString()
    return [PSCustomObject]@{ Path = $Path; Name = $Name; Exists = $true; Value = $value; Type = $type }
}

function Set-TemporaryRegistryValue {
    param ([string]$Path, [string]$Name, [int]$Value)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType DWord -Force | Out-Null
}

function Start-RegistryOptimization {
    $items = @(
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AppCaptureEnabled'; Value = 0 },
        @{ Path = 'HKCU:\System\GameConfigStore'; Name = 'GameDVR_Enabled'; Value = 0 },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'GameDVR_Enabled'; Value = 0 }
    )

    $backup = foreach ($item in $items) {
        $state = Get-RegistryValueState -Path $item.Path -Name $item.Name
        $state | Add-Member -NotePropertyName NewValue -NotePropertyValue $item.Value -PassThru
    }

    $backupDir = Split-Path -Parent $script:RegistryBackupPath
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    $backup | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $script:RegistryBackupPath -Encoding UTF8

    try {
        foreach ($item in $items) {
            Set-TemporaryRegistryValue -Path $item.Path -Name $item.Name -Value $item.Value
        }
        Write-Host '[✓] Game DVR ve arka plan kaydı geçici olarak kapatıldı.' -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[!] Registry ayarları uygulanamadı: $($_.Exception.Message)" -ForegroundColor Yellow
        Restore-RegistryOptimization
        return $false
    }
}

function Restore-RegistryOptimization {
    if (-not (Test-Path -LiteralPath $script:RegistryBackupPath)) {
        return
    }

    try {
        $rawBackup = Get-Content -LiteralPath $script:RegistryBackupPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $backup = @($rawBackup)
        foreach ($item in $backup) {
            $path = [string]$item.Path
            $name = [string]$item.Name
            $exists = [bool]$item.Exists

            if ([string]::IsNullOrWhiteSpace($path) -or [string]::IsNullOrWhiteSpace($name)) {
                continue
            }

            if ($exists) {
                $type = if ([string]$item.Type -eq 'DWord') { 'DWord' } else { 'String' }
                New-Item -Path $path -Force | Out-Null
                New-ItemProperty -LiteralPath $path -Name $name -Value $item.Value -PropertyType $type -Force | Out-Null
            }
            else {
                Remove-ItemProperty -LiteralPath $path -Name $name -ErrorAction SilentlyContinue
            }
        }
        Remove-Item -LiteralPath $script:RegistryBackupPath -Force -ErrorAction SilentlyContinue
        Write-Host '[✓] Registry ayarları oyun öncesindeki hâline döndürüldü.' -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Registry geri yüklenemedi: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Önceki oturum yarıda kaldıysa, yeni optimizasyon uygulamadan geri yükle.
function Restore-StaleRegistryBackup {
    if (Test-Path -LiteralPath $script:RegistryBackupPath) {
        Restore-RegistryOptimization
    }
}
