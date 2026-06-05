[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-SystemPowerReport.ps1 - Izveštaj o potrošnji energije i bateriji
Write-Host "Generišem sistemski izveštaj o energetskoj efikasnosti..." -ForegroundColor Cyan
Write-Host "Ova komanda koristi ugrađeni Windows alat (powercfg.exe).`n" -ForegroundColor DarkGray

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Generisanje energetskog izveštaja zahteva pokretanje kao Administrator!" -ForegroundColor Red
    return
}

try {
    $reportPath = Join-Path (Get-Location) "power_report.html"
    Write-Host "Pokrećem skeniranje sistema od 60 sekundi... Molimo sačekajte..." -ForegroundColor Yellow
    
    # Pokretanje powercfg-a
    $result = powercfg /energy /output $reportPath /duration 60 2>&1
    
    if (Test-Path $reportPath) {
        Write-Host "`n[+] Energetski izveštaj uspešno kreiran!" -ForegroundColor Green
        Write-Host "Izveštaj je snimljen kao: $reportPath" -ForegroundColor Gold
        
        # Otvaranje fajla
        Start-Process $reportPath
    } else {
        Write-Host "Nije uspelo kreiranje izveštaja: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}