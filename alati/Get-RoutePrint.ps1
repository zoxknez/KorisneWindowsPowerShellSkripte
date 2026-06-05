[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-RoutePrint.ps1 - Prikaz i analiza tabele rutiranja
Write-Host "Čitam aktivnu Windows tabelu rutiranja (Routing Table)..." -ForegroundColor Cyan

try {
    # Koristimo ugrađenu PowerShell komandu za rute
    $routes = Get-NetRoute -AddressFamily IPv4 -ErrorAction Stop
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                WINDOWS IPv4 TABLICA RUTIRANJA     " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    $routes | Select-Object DestinationPrefix, NextHop, RouteMetric, InterfaceAlias | Format-Table -AutoSize
    
    # Detekcija default rute (kuda ide sav internet saobraćaj)
    $defaultRoute = $routes | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" } | Select-Object -First 1
    if ($defaultRoute) {
        Write-Host "`nDefault Gateway (Glavni Izlaz):" -ForegroundColor Yellow
        Write-Host "  Sva mrežna komunikacija ide preko adaptera: $($defaultRoute.InterfaceAlias)" -ForegroundColor White
        Write-Host "  Gateway IP (Next Hop)                     : $($defaultRoute.NextHop)" -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri čitanju tabela rutiranja: $($_.Exception.Message)" -ForegroundColor Red
}