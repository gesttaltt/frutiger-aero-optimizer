<#
.SYNOPSIS
    Frutiger Aero Optimizer & Windows Master v1.0-stable 🫧🐬✨
    A PowerShell port of the original Linux customization suite.

.DESCRIPTION
    Automates the transformation of Windows 10/11 into a Frutiger Aero masterpiece.
    Uses open-source restorers (DWMBlurGlass, Open-Shell, Windhawk) and authentic assets.

.NOTES
    Author: Gemini CLI / Gestalt
    Version: 1.0-stable (Animation-Enhanced)
    Supported: Windows 10 (2004+), Windows 11
#>

# --- CONFIGURACIÓN Y COLORES ---
$ErrorActionPreference = "Continue"
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-AeroLog {
    param([string]$Level, [string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Color = switch($Level) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        default   { "Blue" }
    }
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Color
}

# --- DETECCIÓN DE SISTEMA ---
function Get-SystemInfo {
    $OS = Get-WmiObject Win32_OperatingSystem
    $Global:OS_NAME = $OS.Caption
    $Global:OS_VER = $OS.Version
    $Global:IS_WIN11 = $OS_NAME -like "*Windows 11*"
    
    Write-AeroLog "INFO" "Sistema detectado: $OS_NAME ($OS_VER)"
}

function Check-Admin {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-AeroLog "ERROR" "Se requieren privilegios de ADMINISTRADOR. Reinicia PowerShell como Admin."
        exit 1
    }
}

# --- FUNCIONES DE SEGURIDAD ---
function Create-RestorePoint {
    Write-AeroLog "INFO" "Creando Punto de Restauración del Sistema (Seguridad)..."
    try {
        Checkpoint-Computer -Description "FrutigerAero_Master_Install" -RestorePointType "MODIFY_SETTINGS"
        Write-AeroLog "SUCCESS" "Punto de restauración creado con éxito."
    } catch {
        Write-AeroLog "WARNING" "No se pudo crear el punto de restauración. Asegúrate de que la protección del sistema esté activada."
    }
}

# --- MÓDULOS DE TRANSFORMACIÓN ---

function Install-Dependencies {
    Write-AeroLog "INFO" "Verificando Winget y descargando componentes..."
    $tools = @("Open-Shell.Open-Shell", "Maplespe.DWMBlurGlass")
    if ($Global:IS_WIN11) { $tools += "valinet.ExplorerPatcher" }

    foreach ($tool in $tools) {
        Write-AeroLog "INFO" "Instalando $tool via Winget..."
        winget install $tool --accept-package-agreements --accept-source-agreements --silent || Write-AeroLog "WARNING" "No se pudo instalar $tool automáticamente."
    }
}

function Apply-AeroAssets {
    Write-AeroLog "INFO" "Aplicando Iconos y Sonidos de Windows 7..."
    
    # Rutas de assets locales
    $AssetPath = Join-Path $PSScriptRoot "assets"
    $SoundDir = Join-Path $AssetPath "sounds"
    $IconDir = Join-Path $AssetPath "icons"

    # 1. Sonidos (Registro)
    $RegistryBase = "HKCU:\AppEvents\Schemes\Apps"
    $SoundMap = @{
        ".Default\WindowsLogon" = "Logon.wav"
        ".Default\SystemHand"   = "Windows Error.wav"
        ".Default\SystemStart"  = "Windows Notify.wav"
    }

    foreach ($Event in $SoundMap.Keys) {
        $Key = "$RegistryBase\$Event\.Current"
        $File = Join-Path $SoundDir $SoundMap[$Event]
        if (Test-Path $File) {
            if (!(Test-Path $Key)) { New-Item -Path $Key -Force | Out-Null }
            Set-ItemProperty -Path $Key -Name "(Default)" -Value $File
        }
    }

    # 2. Iconos de Sistema (Registro)
    $GUIDs = @{
        "ThisPC"    = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        "RecycleBin"= "{645FF040-5081-101B-9F08-00AA002F954E}"
    }

    # Icono PC
    $pcReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$($GUIDs['ThisPC'])\DefaultIcon"
    $pcIco = Join-Path $IconDir "computer.ico"
    if (Test-Path $pcIco) {
        if (!(Test-Path $pcReg)) { New-Item -Path $pcReg -Force | Out-Null }
        Set-ItemProperty -Path $pcReg -Name "(Default)" -Value $pcIco
    }

    # Icono Papelera
    $binReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$($GUIDs['RecycleBin'])\DefaultIcon"
    if (!(Test-Path $binReg)) { New-Item -Path $binReg -Force | Out-Null }
    $emptyIco = Join-Path $IconDir "trash_empty.ico"
    $fullIco = Join-Path $IconDir "trash_full.ico"
    if (Test-Path $emptyIco) {
        Set-ItemProperty -Path $binReg -Name "(Default)" -Value $emptyIco
        Set-ItemProperty -Path $binReg -Name "empty" -Value $emptyIco
    }
    if (Test-Path $fullIco) { Set-ItemProperty -Path $binReg -Name "full" -Value $fullIco }

    Write-AeroLog "SUCCESS" "Assets inyectados correctamente."
}

function Apply-AeroAnimations {
    Write-AeroLog "INFO" "Configurando Animaciones Fluidas y Smooth Scrolling..."
    
    # 1. Habilitar Smooth Scrolling en el Registro (UserPreferencesMask bit 0x08)
    $path = "HKCU:\Control Panel\Desktop"
    $mask = (Get-ItemProperty -Path $path).UserPreferencesMask
    $mask[0] = $mask[0] -bor 0x08
    Set-ItemProperty -Path $path -Name UserPreferencesMask -Value $mask

    # 2. Habilitar Animaciones de Ventanas (MinAnimate)
    $metricsPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    Set-ItemProperty -Path $metricsPath -Name MinAnimate -Value 1

    # 3. Optimizar Firefox para Scrollbars Windows 7 (si existe)
    $ffDir = "$env:APPDATA\Mozilla\Firefox\Profiles"
    if (Test-Path $ffDir) {
        $profiles = Get-ChildItem $ffDir | Where-Object { $_.PSIsContainer }
        foreach ($profile in $profiles) {
            $userJs = Join-Path $profile.FullName "user.js"
            Add-Content -Path $userJs -Value 'user_pref("widget.non-native-theme.scrollbar.style", 4);' -ErrorAction SilentlyContinue
        }
    }

    Write-AeroLog "SUCCESS" "Animaciones Aero configuradas."
}

function Refresh-Shell {
    Write-AeroLog "INFO" "Reiniciando el shell para aplicar cambios visuales..."
    # Refrescar iconos
    ie4uinit.exe -show
    # Reiniciar Explorer
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Write-AeroLog "SUCCESS" "Shell refrescado."
}

function Optimize-System {
    Write-AeroLog "INFO" "Iniciando Limpieza y Optimización de Windows..."
    # 1. Limpieza de archivos temporales (System)
    DISM /Online /Cleanup-Image /StartComponentCleanup /Quiet
    Write-AeroLog "SUCCESS" "Optimización de sistema completada."
}

# --- LÓGICA PRINCIPAL ---
function Show-Header {
    Clear-Host
    Write-Host "############################################################" -ForegroundColor Cyan
    Write-Host "#                                                          #" -ForegroundColor Cyan
    Write-Host "#   🫧  FRUTIGER AERO OPTIMIZER v1.0 (Windows)  🐬         #" -ForegroundColor White
    Write-Host "#   The Ultimate 2007 Restoration Suite                    #" -ForegroundColor Cyan
    Write-Host "#                                                          #" -ForegroundColor Cyan
    Write-Host "############################################################" -ForegroundColor Cyan
    Write-Host "OS: $Global:OS_NAME | Admin: True" -ForegroundColor Blue
    Write-Host ""
}

# Argumentos
$AutoMode = $args -contains "--auto" -or $args -contains "-a"
$RestoreMode = $args -contains "--restore" -or $args -contains "-r"

Get-SystemInfo
Check-Admin

if ($RestoreMode) {
    Write-AeroLog "WARNING" "Modo Restauración activado..."
    Write-AeroLog "INFO" "Usa 'rstrui.exe' para volver al punto de restauración creado por este script."
    exit 0
}

Show-Header

if ($AutoMode) {
    Write-AeroLog "INFO" "Ejecutando en MODO AUTOMÁTICO..."
    Create-RestorePoint
    Install-Dependencies
    Apply-AeroAssets
    Apply-AeroAnimations
    Refresh-Shell
    Optimize-System
    Write-AeroLog "SUCCESS" "¡TRANSFORMACIÓN COMPLETADA! Disfruta del brillo."
} else {
    Write-AeroLog "INFO" "Inicia el script con --auto para una instalación rápida."
}
