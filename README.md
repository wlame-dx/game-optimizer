# Game Optimizer for Windows

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight, reversible PowerShell game launcher and optimizer for Windows.

> **Safety first:** The optimizer changes only temporary, user-level settings and restores them after the game exits. FPS gains are hardware- and game-dependent; no FPS increase is guaranteed.

## Features

* Detects installed Steam and Epic Games titles.
* Temporarily switches to the High Performance power plan.
* Temporarily disables selected Game DVR/background capture settings.
* Applies `AboveNormal` priority when Windows allows it.
* Restores the previous Registry and power-plan state after the game exits.
* Starts RTSS only when it was not already running, then closes only the RTSS instance started by this tool.
* Supports Turkish and English CLI output.
* Includes a clean uninstall script.

## Removed features

The experimental performance-test mode, GUI overlay, PresentMon integration, and performance-monitoring module were removed to keep the tool focused, predictable, and lightweight.

## Requirements

* Windows 10 or Windows 11
* PowerShell 5.1 or newer
* Steam and/or Epic Games Launcher for automatic game discovery
* Administrator privileges are recommended for power-plan and process-priority changes
* RTSS is optional and is not bundled with this project

## Installation

```powershell
cd "$env:USERPROFILE\Desktop\game-optimizer\game-optimizer"
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

Choose `1` for Turkish or `2` for English. Open a new PowerShell window after installation and run:

```powershell
game-optimizer
```

You can also launch it directly:

```powershell
& "$env:USERPROFILE\.game-optimizer\launch.ps1"
```

## Usage

1. Start `game-optimizer`.
2. Select a game by number.
3. Play normally.
4. Exit the game normally.
5. The saved Registry values and power plan are restored automatically.
6. Select `Q` or type `exit` to quit from the game list.

If the process cannot be changed because of Windows permissions, the game still launches and the tool continues without applying that one change.

## Safety and limitations

* Registry values are backed up before temporary changes are made.
* An interrupted session leaves a backup that is restored on the next launch.
* The tool does not overclock hardware, modify GPU firmware, disable security software, or delete files.
* Registry and power-plan tweaks may provide no measurable benefit on some systems.
* Test the same game scene with the same graphics settings when comparing results.

## VirusTotal

A VirusTotal result must be generated from the exact release files or archive. No scan result is claimed until those files are uploaded and the report URL is available.

* **Status:** Scan pending — not a security verdict
* **English report:** Add the public VirusTotal report URL here after uploading the release archive.
* **Türkçe açıklama:** Yayın arşivini yükledikten sonra herkese açık VirusTotal rapor bağlantısını buraya ekleyin.

Never upload files containing passwords, API keys, tokens, or private personal data to a public malware scanner.

## Uninstall

```powershell
.\uninstall.ps1
```

The uninstall script removes the installed launcher and its user PATH entry. It does not remove the project source folder.

## License

MIT License. See [LICENSE](LICENSE).

---

# Türkçe

Windows için hafif, geri alınabilir PowerShell oyun başlatıcısı ve optimizasyon aracı.

## Özellikler

* Steam ve Epic Games oyunlarını otomatik tarar.
* Oyun başlarken geçici olarak Yüksek Performans güç planını kullanır.
* Seçili Game DVR/arka plan kayıt ayarlarını geçici olarak kapatır.
* Windows izin verirse oyun önceliğini `AboveNormal` yapar.
* Oyun kapandıktan sonra Registry ve güç planını eski hâline getirir.
* RTSS önceden açık değilse başlatır ve yalnızca kendi başlattığı RTSS örneğini kapatır.
* Türkçe ve İngilizce CLI desteği sunar.

## Kaldırılan özellikler

Deneysel performans testi modu, GUI overlay, PresentMon entegrasyonu ve performans izleme modülü kaldırıldı. Araç artık daha sade, tahmin edilebilir ve hafif.

## Gereksinimler

* Windows 10 veya Windows 11
* PowerShell 5.1 veya daha yeni sürüm
* Otomatik oyun taraması için Steam ve/veya Epic Games Launcher
* Güç planı ve işlem önceliği için yönetici yetkisi önerilir
* RTSS isteğe bağlıdır ve projeyle birlikte gelmez

## Kurulum

```powershell
cd "$env:USERPROFILE\Desktop\game-optimizer\game-optimizer"
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

Dil seçiminde Türkçe için `1`, İngilizce için `2` yazın. Kurulumdan sonra yeni bir PowerShell penceresi açıp çalıştırın:

```powershell
game-optimizer
```

## VirusTotal

VirusTotal sonucu yalnızca tam sürüm dosyaları veya arşivi gerçekten tarandıktan sonra yazılabilir.

* **Durum:** Tarama bekliyor — bu bir güvenlik sonucu değildir.
* **English report:** Yayın arşivini yükledikten sonra herkese açık VirusTotal rapor bağlantısını ekleyin.
* **Türkçe açıklama:** Gerçek rapor bağlantısı olmadan “temiz” sonucu iddia edilmez.

## Lisans

MIT License. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
