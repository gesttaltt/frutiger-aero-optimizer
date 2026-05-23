# --- ASSETS MODULE ---

function Apply-AeroAssets {
    Write-AeroLog "INFO" "Aplicando Iconos y Sonidos de Windows 7..."
    
    $AssetPath = Join-Path $PSScriptRoot "assets"
    $SoundDir = Join-Path $AssetPath "sounds"
    $IconDir = Join-Path $AssetPath "icons"

    # Sonidos
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

    # Iconos
    $GUIDs = @{
        "ThisPC"    = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
        "RecycleBin"= "{645FF040-5081-101B-9F08-00AA002F954E}"
    }

    $pcReg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\$($GUIDs['ThisPC'])\DefaultIcon"
    $pcIco = Join-Path $IconDir "computer.ico"
    if (Test-Path $pcIco) {
        if (!(Test-Path $pcReg)) { New-Item -Path $pcReg -Force | Out-Null }
        Set-ItemProperty -Path $pcReg -Name "(Default)" -Value $pcIco
    }

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
    Write-AeroLog "INFO" "Configurando Animaciones Aero..."
    $path = "HKCU:\Control Panel\Desktop"
    $mask = (Get-ItemProperty -Path $path).UserPreferencesMask
    $mask[0] = $mask[0] -bor 0x08
    Set-ItemProperty -Path $path -Name UserPreferencesMask -Value $mask

    $metricsPath = "HKCU:\Control Panel\Desktop\WindowMetrics"
    Set-ItemProperty -Path $metricsPath -Name MinAnimate -Value 1
    Write-AeroLog "SUCCESS" "Animaciones configuradas."
}

function Refresh-Shell {
    Write-AeroLog "INFO" "Reiniciando explorer..."
    ie4uinit.exe -show
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
}
