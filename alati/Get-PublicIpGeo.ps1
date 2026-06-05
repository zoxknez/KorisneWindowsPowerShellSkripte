[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-PublicIpGeo.ps1 - Detaljna geolokacija javne IP adrese
Write-Host "Geolokacija javne IP adrese..." -ForegroundColor Cyan

$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

try {
    # Koristimo ip-api.com koji ne zahteva ključ i daje sve detalje
    $url = "http://ip-api.com/json/"
    $geo = Invoke-RestMethod -Uri $url -TimeoutSec 3 -ErrorAction Stop
    
    $ProgressPreference = $oldProgress
    
    if ($geo -and $geo.status -eq "success") {
        Write-Host "`n==================================================" -ForegroundColor Cyan
        Write-Host "              JAVNA IP GEOLOKACIJA                " -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "IP Adresa  : $($geo.query)" -ForegroundColor Green
        Write-Host "ISP        : $($geo.isp)" -ForegroundColor White
        Write-Host "Provajder  : $($geo.org)" -ForegroundColor White
        Write-Host "Država     : $($geo.country) ($($geo.countryCode))" -ForegroundColor White
        Write-Host "Grad/Regija: $($geo.city), $($geo.regionName)" -ForegroundColor White
        Write-Host "Koordinate : Lat: $($geo.lat), Lon: $($geo.lon)" -ForegroundColor White
        Write-Host "Vrem. zona : $($geo.timezone)" -ForegroundColor White
        Write-Host "==================================================" -ForegroundColor Cyan
    } else {
        Write-Host "Nije moguće učitati podatke sa API servera." -ForegroundColor Red
    }
} catch {
    $ProgressPreference = $oldProgress
    Write-Host "Mrežna greška pri geolokaciji: $($_.Exception.Message)" -ForegroundColor Red
}