# --- OPTIMIZATION MODULE ---

function Optimize-System {
    Write-AeroLog "INFO" "Iniciando Limpieza y Optimizacion..."
    try {
        DISM /Online /Cleanup-Image /StartComponentCleanup /Quiet
        Write-AeroLog "SUCCESS" "Optimizacion completada."
    } catch {
        Write-AeroLog "WARNING" "Fallo en la optimizacion de sistema."
    }
}
