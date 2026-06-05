[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-GpuTelemetry.ps1 - Telemetrija i model grafičke karte
Write-Host "Prikupljam podatke o grafičkoj kartici..." -ForegroundColor Cyan

try {
    $gpu = Get-CimInstance Win32_VideoController
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "               SPECIFIKACIJE GRAFIČKE KARTE       " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    foreach ($card in $gpu) {
        $ramMB = [Math]::Round($card.AdapterRAM / 1MB, 0)
        
        Write-Host "Model          : $($card.Name)" -ForegroundColor Green
        Write-Host "  Proizvođač   : $($card.AdapterCompatibility)" -ForegroundColor White
        Write-Host "  VRAM (Video) : $ramMB MB" -ForegroundColor White
        Write-Host "  Driver Verz. : $($card.DriverVersion)" -ForegroundColor White
        Write-Host "  Rezolucija   : $($card.VideoModeDescription)" -ForegroundColor White
        Write-Host ""
    }
    
    # Pokušaj očitavanja Nvidia-smi ako je u pitanju Nvidia kartica
    $nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
    if ($nvidiaSmi) {
        Write-Host "Nvidia GPU detektovan! Očitavam temperaturu i opterećenje preko nvidia-smi:`n" -ForegroundColor Yellow
        & nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,utilization.memory --format=csv,noheader
    }
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška pri čitanju GPU specifikacija: $($_.Exception.Message)" -ForegroundColor Red
}