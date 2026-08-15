<#
.SYNOPSIS
    Frutiger Aero Optimizer - Windows Web Bootstrap Installer 🫧🐬✨
    Usage:
    irm https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/windows/install.ps1 | iex
#>

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "############################################################" -ForegroundColor Cyan
Write-Host "#   🫧  FRUTIGER AERO OPTIMIZER - WINDOWS INSTALLER  🐬   #" -ForegroundColor Cyan
Write-Host "############################################################`n" -ForegroundColor Cyan

# Check Admin Privileges
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] ERROR: Se requieren privilegios de ADMINISTRADOR." -ForegroundColor Red
    Write-Host "[*] Por favor ejecuta PowerShell como Administrador e intenta nuevamente." -ForegroundColor Yellow
    exit 1
}

$RepoUrl = "https://github.com/gesttaltt/frutiger-aero-optimizer"
$ReleaseApi = "https://api.github.com/repos/gesttaltt/frutiger-aero-optimizer/releases/latest"
$InstallDir = Join-Path $env:LOCALAPPDATA "FrutigerAeroOptimizer"

if (Test-Path $InstallDir) {
    Remove-Item -Path $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

$Downloaded = $false

try {
    Write-Host "[*] Consultando ultima version oficial en GitHub..." -ForegroundColor Cyan
    $ReleaseData = Invoke-RestMethod -Uri $ReleaseApi -UseBasicParsing
    $Asset = $ReleaseData.assets | Where-Object { $_.name -like "*Windows*.zip" } | Select-Object -First 1
    
    if ($Asset -and $Asset.browser_download_url) {
        $ZipPath = Join-Path $env:TEMP "FrutigerAero_Windows.zip"
        Write-Host "[*] Descargando $($Asset.name)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $Asset.browser_download_url -OutFile $ZipPath -UseBasicParsing
        
        Write-Host "[*] Extrayendo archivos en $InstallDir..." -ForegroundColor Cyan
        Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
        Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue
        $Downloaded = $true
        Write-Host "[V] Paquete oficial descargado y extraido con exito." -ForegroundColor Green
    }
} catch {
    Write-Host "[?] No se pudo obtener la release precompilada: $($_.Exception.Message)" -ForegroundColor Yellow
}

if (-not $Downloaded) {
    Write-Host "[*] Descargando codigo fuente via Git..." -ForegroundColor Cyan
    if (Get-Command git -ErrorAction SilentlyContinue) {
        git clone --depth 1 $RepoUrl $InstallDir
    } else {
        $ZipUrl = "$RepoUrl/archive/refs/heads/main.zip"
        $ZipPath = Join-Path $env:TEMP "frutiger_source.zip"
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
        Expand-Archive -Path $ZipPath -DestinationPath $env:TEMP -Force
        $ExtractedFolder = Join-Path $env:TEMP "frutiger-aero-optimizer-main"
        Copy-Item -Path "$ExtractedFolder\*" -Destination $InstallDir -Recurse -Force
        Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $ExtractedFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Localizar el script principal
$ScriptPath = Join-Path $InstallDir "optimize_and_aero.ps1"
if (-not (Test-Path $ScriptPath)) {
    $ScriptPath = Join-Path $InstallDir "windows\optimize_and_aero.ps1"
}

if (Test-Path $ScriptPath) {
    Write-Host "[V] Iniciando transformacion Frutiger Aero...`n" -ForegroundColor Green
    Set-Location -Path (Split-Path $ScriptPath -Parent)
    & $ScriptPath -Auto
} else {
    Write-Host "[!] No se encontro el script de optimizacion en $InstallDir" -ForegroundColor Red
}
