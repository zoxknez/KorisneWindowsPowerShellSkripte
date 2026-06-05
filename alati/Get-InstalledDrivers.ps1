[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-InstalledDrivers.ps1 - Prikaz instaliranih drajvera na sistemu
Write-Host "Učitavam listu aktivnih drajvera na Windowsu..." -ForegroundColor Cyan

try {
    # Koristimo driverquery.exe koji je standard na svakom Windowsu i daje lep izlaz
    $driversRaw = driverquery /fo csv | ConvertFrom-Csv
    
    Write-Host "`nPronađeno ukupno $($driversRaw.Count) drajvera.`n" -ForegroundColor Yellow
    
    $driverList = @()
    foreach ($d in $driversRaw) {
        $driverList += [PSCustomObject]@{
            Naziv = $d."Display Name"
            NazivModula = $d."Module Name"
            TipDrajvera = $d."Driver Type"
        }
    }
    
    # Prikazujemo prvih 30 radi preglednosti
    $driverList | Select-Object -First 30 | Format-Table -AutoSize
    Write-Host "Prikazan je samo prvi deo liste (30 drajvera). Pokrenite 'driverquery' u konzoli za potpun izveštaj." -ForegroundColor DarkGray
} catch {
    Write-Host "Greška pri analizi drajvera: $($_.Exception.Message)" -ForegroundColor Red
}