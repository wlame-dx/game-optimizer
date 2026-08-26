function Get-GameProcess {
    param (
        [Parameter(Mandatory = $true)] [string]$GameName,
        [int[]]$ExistingProcessIds = @(),
        [int]$TimeoutSeconds = 90
    )

    $ignoredNames = @(
        'powershell', 'pwsh', 'cmd', 'conhost', 'explorer', 'rtss',
        'rtsshooksrsr64', 'steam', 'steamwebhelper', 'epicgameslauncher',
        'epicwebhelper', 'crashreportclient', 'dwm'
    )
    $nameParts = @($GameName -split '[^a-zA-Z0-9]+') | Where-Object { $_.Length -ge 4 }
    $endTime = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $endTime) {
        $candidates = @(Get-Process -ErrorAction SilentlyContinue | Where-Object {
            $_.Id -notin $ExistingProcessIds -and
            $_.MainWindowHandle -ne 0 -and
            $_.ProcessName.ToLower() -notin $ignoredNames
        })

        if ($candidates.Count -gt 0) {
            $named = $candidates | Where-Object {
                $title = $_.MainWindowTitle
                $processName = $_.ProcessName
                ($title -and $title -like "*$GameName*") -or
                ($nameParts | Where-Object { $processName -like "*$_*" })
            } | Select-Object -First 1

            if ($named) { return $named }
        }

        Start-Sleep -Seconds 2
    }

    return $null
}

$script:RTSSStartedByUs = $false

function Start-Optimization {
    param ($Game)

    Write-Host "`n$(Get-Text 'OptStart')" -ForegroundColor Yellow

    # Registry ayarlarını oyun başlamadan önce yedekle ve geçici olarak uygula.
    $null = Start-RegistryOptimization

    # Optimizatörü çalıştırmadan önce açık işlemlerin listesini al.
    $existingProcessIds = @(Get-Process -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id)

    # 1. Güç Planı
    $activeScheme = (powercfg /getactivescheme) -replace '.*:\s+([a-f0-9\-]+)\s+.*', '$1'
    powercfg /setactive SCHEME_MIN 2>$null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null
    powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100 2>$null
    powercfg /setactive SCHEME_CURRENT 2>$null
    Write-Host "$(Get-Text 'PowerMode')" -ForegroundColor Green

    # 2. RTSS başlat; zaten açıksa kullanıcı oturumuna dokunma.
    $rtssExe = "C:\Program Files (x86)\RivaTuner Statistics Server\RTSS.exe"
    $rtssWasRunning = @(Get-Process -Name 'RTSS' -ErrorAction SilentlyContinue).Count -gt 0
    $script:RTSSStartedByUs = $false
    if ((Test-Path -LiteralPath $rtssExe) -and (-not $rtssWasRunning)) {
        Start-Process -FilePath $rtssExe -ArgumentList "-mi" -ErrorAction SilentlyContinue
        $script:RTSSStartedByUs = $true
        Write-Host "$(Get-Text 'RtssStart')" -ForegroundColor Green
    }

    # 3. Oyunu başlat
    Write-Host "$(Get-Text 'GameLaunch') $($Game.Name)" -ForegroundColor Cyan
    Start-Process -FilePath $Game.Path -ErrorAction SilentlyContinue

    # 4. Gerçek oyun sürecini bul ve yalnızca ona öncelik uygula.
    Write-Host "`n$(Get-Text 'RunningState')" -ForegroundColor Magenta
    $proc = Get-GameProcess -GameName $Game.Name -ExistingProcessIds $existingProcessIds -TimeoutSeconds 60

    if ($proc) {
        try {
            # Öncelik ayarı FPS garantisi vermez; erişim reddedilirse devam edilir.
            $proc.PriorityClass = 'AboveNormal'
            Write-Host "$(Get-Text 'PrioritySet') ($($proc.ProcessName))" -ForegroundColor Green
        }
        catch {
            Write-Host "İşlem önceliği ayarlanamadı; program izlemeye devam ediyor: erişim engellendi." -ForegroundColor Yellow
        }

        # Süreç nesnesi eski kalabileceği için PID üzerinden yenile.
        $gamePid = $proc.Id

        do {
            Start-Sleep -Seconds 2
            $stillRunning = Get-Process -Id $gamePid -ErrorAction SilentlyContinue
        } while ($stillRunning)
    }
    else {
        Write-Host "Oyun süreci bulunamadı; oyun izlenemedi." -ForegroundColor Yellow
        Write-Host "Oyun kapandığında geri yükleme için Enter'a basın." -ForegroundColor Yellow
        Read-Host
    }

    # 5. Ayarları geri yükle
    Stop-Cleanup -ActiveScheme $activeScheme
}

function Stop-Cleanup {
    param ($ActiveScheme)

    Write-Host "`n[*] Temizlik yapılıyor..." -ForegroundColor Yellow
    Restore-RegistryOptimization
    if ($script:RTSSStartedByUs) {
        Stop-Process -Name 'RTSS' -Force -ErrorAction SilentlyContinue
        Stop-Process -Name 'RTSSHooksRSR64' -Force -ErrorAction SilentlyContinue
        $script:RTSSStartedByUs = $false
    }

    if ($ActiveScheme) { powercfg /setactive $ActiveScheme 2>$null }
    else { powercfg /setactive SCHEME_BALANCED 2>$null }

    Write-Host "$(Get-Text 'ExitCleanup')" -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    [System.Environment]::Exit(0)
}
