function Get-InstalledGames {
    $games = @()
    try {
        $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
        if ($steamPath -and (Test-Path "$steamPath\steamapps")) {
            $acfFiles = Get-ChildItem -Path "$steamPath\steamapps" -Filter "appmanifest_*.acf" -ErrorAction SilentlyContinue
            foreach ($file in $acfFiles) {
                $lines = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
                $gameName = ""; $appId = ""
                foreach ($line in $lines) {
                    if ($line -match '"name"\s+"([^"]+)"') { $gameName = $matches[1] }
                    if ($line -match '"appid"\s+"([^"]+)"') { $appId = $matches[1] }
                }
                if ($gameName -and $appId) {
                    $games += [PSCustomObject]@{ Name = $gameName; Platform = "Steam"; Path = "steam://rungameid/$appId" }
                }
            }
        }
    } catch {}

    try {
        $epicDataPath = "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests"
        if (Test-Path $epicDataPath) {
            $manifests = Get-ChildItem -Path $epicDataPath -Filter "*.item" -ErrorAction SilentlyContinue
            foreach ($file in $manifests) {
                $json = Get-Content -Path $file.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($json -and $json.DisplayName -and $json.InstallLocation) {
                    $exePath = Join-Path -Path $json.InstallLocation -ChildPath $json.LaunchExecutable
                    $games += [PSCustomObject]@{ Name = $json.DisplayName; Platform = "Epic Games"; Path = $exePath }
                }
            }
        }
    } catch {}

    return $games
}
