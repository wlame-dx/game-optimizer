$global:LangData = @{
    TR = @{
        Title        = "🚀 GAME OPTIMIZER & OVERLAY CLI"
        Scanning     = "[*] Oyunlar taranıyor..."
        NoGames      = "[!] Oyun bulunamadı!"
        FoundGames   = "BULUNAN OYUNLAR"
        EnterChoice  = "Oyun numarası girin (Çıkış için Q veya exit)"
        InvalidChoice= "[!] Geçersiz seçim!"
        OptStart     = "[+] Optimizasyon Başlatılıyor..."
        PowerMode    = "[✓] Güç Planı: Yüksek Performans moduna geçildi."
        RamClean     = "[✓] Sistem Belleği (RAM) temizlendi."
        RtssStart    = "[✓] RTSS (FPS Göstergesi) başlatıldı."
        GameLaunch   = "[➜] Oyun Başlatılıyor: "
        PrioritySet  = "[✓] Oyun işlem önceliği 'Yüksek' olarak ayarlandı."
        RunningState = "[*] Oyun çalışıyor... Oyun kapanana kadar bu pencereyi kapatmayın."
        ExitCleanup  = "[✓] Oyun kapandı. Güç planı varsayılana döndürüldü ve temizlik tamamlandı."
    }
    EN = @{
        Title        = "🚀 GAME OPTIMIZER & OVERLAY CLI"
        Scanning     = "[*] Scanning games..."
        NoGames      = "[!] No games found!"
        FoundGames   = "FOUND GAMES"
        EnterChoice  = "Enter game number (Q or exit to Exit)"
        InvalidChoice= "[!] Invalid choice!"
        OptStart     = "[+] Starting Optimization..."
        PowerMode    = "[✓] Power Plan: Switched to High Performance."
        RamClean     = "[✓] System RAM cleaned."
        RtssStart    = "[✓] RTSS (FPS Overlay) launched."
        GameLaunch   = "[➜] Launching Game: "
        PrioritySet  = "[✓] Game process priority set to High."
        RunningState = "[*] Game is running... Keep this window open until you finish."
        ExitCleanup  = "[✓] Game closed. Power plan restored and cleanup completed."
    }
}

function Get-Text {
    param ([string]$Key)
    $configPath = "$env:USERPROFILE\.game-optimizer\config.json"
    $lang = "TR"
    if (Test-Path $configPath) {
        try {
            $cfg = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.Language) { $lang = $cfg.Language }
        } catch {}
    }
    return $global:LangData[$lang][$Key]
}
