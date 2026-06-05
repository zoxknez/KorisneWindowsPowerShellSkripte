[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-BatteryStatus.ps1 - Detaljno zdravlje baterije laptopa
Write-Host "Čitam podatke o bateriji..." -ForegroundColor Cyan

# Provera da li je u pitanju laptop / ima bateriju
$battery = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue

if (-not $battery) {
    Write-Host "Upozorenje: Baterija nije detektovana na ovom sistemu (verovatno je desktop računar)." -ForegroundColor Yellow
    return
}

# Dobijanje detaljnih informacija iz WMI root\WMI klase (standard u Windows-u)
try {
    $fullCapacity = Get-CimInstance -Namespace root\wmi -ClassName BatteryFullChargedCapacity -ErrorAction SilentlyContinue
    $staticData = Get-CimInstance -Namespace root\wmi -ClassName BatteryStaticData -ErrorAction SilentlyContinue
    $status = Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus -ErrorAction SilentlyContinue
} catch {
    # Nema prava za root\wmi, fallback na standard Win32_Battery
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "               TELEMETRIJA BATERIJE               " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# Prikaz osnovnih podataka
$chargeStatus = switch ($battery.BatteryStatus) {
    1 { "Pražnjenje (Discharging)" }
    2 { "Napaja se iz mreže (AC Power)" }
    3 { "Potpuno napunjena" }
    4 { "Nizak nivo (Low)" }
    5 { "Kritičan nivo (Critical)" }
    6 { "Puni se (Charging)" }
    default { "Nepoznato" }
}

Write-Host "Naziv uređaja   : $($battery.DeviceID)" -ForegroundColor White
Write-Host "Tip baterije    : $($battery.Chemistry)" -ForegroundColor White
Write-Host "Status rada     : $chargeStatus" -ForegroundColor White
Write-Host "Preostali procenat : $($battery.EstimatedChargeRemaining)%" -ForegroundColor Green

if ($battery.EstimatedRunTime -and $battery.EstimatedRunTime -ne 71582788) {
    $hours = [Math]::Floor($battery.EstimatedRunTime / 60)
    $mins = $battery.EstimatedRunTime % 60
    Write-Host "Vreme rada      : $hours sati i $mins minuta" -ForegroundColor White
}

# Zdravlje baterije (Stvarni pun kapacitet vs Dizajnirani kapacitet)
if ($fullCapacity -and $staticData) {
    $designCap = $staticData.DesignedCapacity
    $currCap = $fullCapacity.FullChargedCapacity
    
    if ($designCap -gt 0) {
        $health = [Math]::Round(($currCap / $designCap) * 100, 1)
        Write-Host "`nAnaliza zdravlja baterije (Health):" -ForegroundColor Yellow
        Write-Host "  Dizajnirani kapacitet : $designCap mWh" -ForegroundColor White
        Write-Host "  Trenutni pun kapacitet: $currCap mWh" -ForegroundColor White
        
        Write-Host "  Zdravlje baterije     : " -NoNewline -ForegroundColor White
        if ($health -ge 80) {
            Write-Host "$health% (Odlično/Dobro)" -ForegroundColor Green
        } elseif ($health -ge 50) {
            Write-Host "$health% (Oslabljeno)" -ForegroundColor Yellow
        } else {
            Write-Host "$health% (Potrebna zamena)" -ForegroundColor Red
        }
    }
}
Write-Host "==================================================" -ForegroundColor Cyan