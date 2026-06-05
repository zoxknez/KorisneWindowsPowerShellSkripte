[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-CpuTemperature.ps1 - Temperatura procesora i zone hlađenja
Write-Host "Učitavam temperature senzora (zahteva pokretanje kao Administrator)...`n" -ForegroundColor Cyan

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Očitavanje temperature hardvera zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

try {
    # Klasa MSAcpi_ThermalZoneTemperature sadrži temperaturu u desetinama Kelvina (npr. 3000 = 300.0 Kelvin)
    $zones = Get-CimInstance -Namespace root\wmi -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
    
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             TEMPERATURNI SENZORI CPU-A           " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    foreach ($zone in $zones) {
        # Kelvin u Celzijus: (Kelvin / 10) - 273.15
        $tempC = [Math]::Round(($zone.CurrentTemperature / 10) - 273.15, 1)
        
        $color = if ($tempC -gt 80) { "Red" } elseif ($tempC -gt 60) { "Yellow" } else { "Green" }
        
        Write-Host "Senzor (Zona) : $($zone.InstanceName)" -ForegroundColor White
        Write-Host "  Temperatura : " -NoNewline -ForegroundColor White
        Write-Host "$tempC °C" -ForegroundColor $color
        Write-Host ""
    }
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Sistemski senzori ACPI temperature nisu dostupni na ovom hardveru." -ForegroundColor Red
    Write-Host "Neke matične ploče (ili virtuelne mašine) ne eksponiraju temperaturu kroz standardni MSAcpi interfejs." -ForegroundColor Yellow
}