<#
.SYNOPSIS
    Frutiger Aero Optimizer & Windows Master v1.1-modular 🫧🐬✨
    A modular PowerShell port of the original customization suite.
#>

# --- CONFIGURACION ---
$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

# Load Modules
$LibDir = Join-Path $PSScriptRoot "lib"
. (Join-Path $LibDir "Core.ps1")
. (Join-Path $LibDir "Assets.ps1")
. (Join-Path $LibDir "Apps.ps1")
. (Join-Path $LibDir "Optimization.ps1")

# --- LOGICA PRINCIPAL ---
function Show-Header {
    Clear-Host
    Write-Host "############################################################" -ForegroundColor Cyan
    Write-Host "#                                                          #" -ForegroundColor Cyan
    Write-Host "#   🫧  FRUTIGER AERO OPTIMIZER v1.1 (Windows)  🐬         #" -ForegroundColor White
    Write-Host "#   Multi-Module Restoration Suite                         #" -ForegroundColor Cyan
    Write-Host "#                                                          #" -ForegroundColor Cyan
    Write-Host "############################################################" -ForegroundColor Cyan
    Write-Host "OS: $Global:OS_NAME | Admin: True" -ForegroundColor Blue
    Write-Host ""
}

# Argumentos
$Global:DEBUG = $args -contains "--debug" -or $args -contains "-d"
$AutoMode = $args -contains "--auto" -or $args -contains "-a"
$RestoreMode = $args -contains "--restore" -or $args -contains "-r"
$WallpaperMode = $args -contains "--wallpaper" -or $args -contains "-w"

# START
if ($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&' -and (-not $env:PESTER_TESTING)) {
    Get-SystemInfo
    Check-Admin
    Check-Assets

    if ($RestoreMode) {
        Write-AeroLog "WARNING" "Modo Restauracion..."
        Write-AeroLog "INFO" "Usa 'rstrui.exe' para volver al punto de restauracion."
        exit 0
    }

    if ($WallpaperMode) {
        Apply-AeroWallpaper
        exit 0
    }

    Show-Header

    if ($AutoMode) {
        Write-AeroLog "INFO" "Ejecutando en MODO AUTOMATICO..."
        Create-RestorePoint
        Install-Dependencies
        Apply-AeroAssets
        Apply-AeroWallpaper
        Apply-AeroAnimations
        Install-SpotifyGlass
        Apply-VlcSkin
        Refresh-Shell
        Optimize-System
        Write-AeroLog "SUCCESS" "TRANSFORMACION COMPLETADA! Disfruta del brillo."
    } else {
        Write-AeroLog "INFO" "Inicia el script con --auto para una instalacion rapida."
    }
}
