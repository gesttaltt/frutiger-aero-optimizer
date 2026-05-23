# --- APPLICATIONS MODULE ---

function Install-Dependencies {
    Write-AeroLog "INFO" "Instalando herramientas via Winget..."
    $tools = @("Open-Shell.Open-Shell", "Maplespe.DWMBlurGlass")
    if ($Global:IS_WIN11) { $tools += "valinet.ExplorerPatcher" }

    foreach ($tool in $tools) {
        Write-AeroLog "INFO" "Instalando $tool..."
        try {
            winget install $tool --accept-package-agreements --accept-source-agreements --silent --upgrade-fixed
        } catch {
            Write-AeroLog "WARNING" "Fallo al instalar $tool."
        }
    }
}

function Install-SpotifyGlass {
    Write-AeroLog "INFO" "Configurando Spotify Aero (Spicetify)..."
    if (-not (Check-Connectivity)) { return }
    try {
        powershell -Command "iwr -useb https://raw.githubusercontent.com/spicetify/cli/main/install.ps1 | iex"
        $spDir = "$env:APPDATA\spicetify\Themes\WMPotify"
        if (!(Test-Path $spDir)) {
            New-Item -ItemType Directory -Force -Path $spDir | Out-Null
            $tempSp = Join-Path $env:TEMP "aero_spotify"
            if (Test-Path $tempSp) { Remove-Item -Recurse -Force $tempSp }
            git clone --depth 1 https://github.com/p-p-h/WMPotify.git $tempSp
            Copy-Item -Path "$tempSp\*" -Destination $spDir -Recurse -Force
        }
        & spicetify config current_theme WMPotify
        & spicetify backup apply
        Write-AeroLog "SUCCESS" "Spotify Aero configurado."
    } catch {
        Write-AeroLog "WARNING" "No se pudo configurar Spotify."
    }
}

function Apply-VlcSkin {
    Write-AeroLog "INFO" "Aplicando skin WMP11 a VLC..."
    $vlcAppPath = "$env:APPDATA\vlc"
    $vlcSkins = Join-Path $vlcAppPath "skins2"
    if (!(Test-Path $vlcSkins)) { New-Item -ItemType Directory -Force -Path $vlcSkins | Out-Null }
    
    $skinSource = Join-Path $PSScriptRoot "assets\vlc\WMP11.vlt"
    if (Test-Path $skinSource) {
        Copy-Item -Path $skinSource -Destination $vlcSkins -Force
        $vlcrc = Join-Path $vlcAppPath "vlcrc"
        if (Test-Path $vlcrc) {
            (Get-Content $vlcrc) -replace "^#intf=", "intf=skins2" | Set-Content $vlcrc
        }
        Write-AeroLog "SUCCESS" "VLC Skin aplicado."
    }
}
