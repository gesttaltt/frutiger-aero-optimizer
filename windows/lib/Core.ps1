# --- CORE UTILITIES ---

function Write-AeroLog {
    param([string]$Level, [string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Color = switch($Level) {
        "INFO"    { "Cyan" }
        "SUCCESS" { "Green" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "DEBUG"   { "Gray" }
        default   { "Blue" }
    }
    if ($Level -eq "DEBUG" -and -not $Global:DEBUG) { return }
    Write-Host "[$Timestamp] [$Level] $Message" -ForegroundColor $Color
}

function Check-Assets {
    Write-AeroLog "DEBUG" "Verificando assets..."
    $required = @("assets\sounds", "assets\icons", "assets\vlc")
    foreach ($dir in $required) {
        $path = Join-Path $PSScriptRoot "..\$dir"
        if (-not (Test-Path $path)) {
            Write-AeroLog "WARNING" "Falta el directorio de assets: $path"
        }
    }
}

function Get-SystemInfo {
    Write-AeroLog "DEBUG" "Detecting system info..."
    try {
        $OS = if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            Get-CimInstance Win32_OperatingSystem
        } else {
            Get-WmiObject Win32_OperatingSystem
        }
        $Global:OS_NAME = $OS.Caption
        $Global:OS_VER = $OS.Version
    } catch {
        $Global:OS_NAME = "Microsoft Windows"
        $Global:OS_VER = "10.0"
    }
    $Global:IS_WIN11 = $Global:OS_NAME -like "*Windows 11*"
    Write-AeroLog "INFO" "Sistema detectado: $Global:OS_NAME ($Global:OS_VER)"
}

function Check-Admin {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-AeroLog "ERROR" "Se requieren privilegios de ADMINISTRADOR."
        exit 1
    }
}

function Create-RestorePoint {
    Write-AeroLog "INFO" "Creando Punto de Restauracion..."
    try {
        Checkpoint-Computer -Description "FrutigerAero_Master_Install" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-AeroLog "SUCCESS" "Punto de restauracion creado."
    } catch {
        Write-AeroLog "WARNING" "No se pudo crear el punto de restauracion. Asegurate de que la proteccion del sistema este activada."
    }
}

function Check-Connectivity {
    try {
        $request = [System.Net.WebRequest]::Create("http://www.google.com")
        $request.Method = "HEAD"
        $response = $request.GetResponse()
        return $true
    } catch {
        Write-AeroLog "WARNING" "Sin conexion a internet detectada."
        return $false
    }
}
