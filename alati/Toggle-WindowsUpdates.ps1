[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Toggle-WindowsUpdates.ps1 - Uključivanje/Isključivanje automatskog Windows Update servisa
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Kontrola Windows Update servisa zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

try {
    $service = Get-Service -Name "wuauserv"
    $status = $service.Status
    $startType = $service.StartType
    
    Write-Host "Trenutni status Windows Update servisa:" -ForegroundColor Cyan
    Write-Host "  Stanje (Status): $status" -ForegroundColor White
    Write-Host "  Start Tip      : $startType" -ForegroundColor White
    
    Write-Host "`nIzaberite akciju:" -ForegroundColor Yellow
    Write-Host "1. Onemogući i Stopiraj Windows Update (Blokiraj ažuriranja)" -ForegroundColor Red
    Write-Host "2. Omogući (Manual) i Pokreni Windows Update (Dozvoli ažuriranja)" -ForegroundColor Green
    Write-Host "0. Otkaži" -ForegroundColor Gray
    
    $choice = Read-Host "Opcija"
    
    if ($choice -eq "1") {
        Write-Host "`nStopiram Windows Update servis..." -ForegroundColor DarkGray
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "wuauserv" -StartupType Disabled
        Write-Host "[+] Windows Update je uspešno ONEMOGUĆEN i STOPIRAN!" -ForegroundColor Green
    }
    elseif ($choice -eq "2") {
        Write-Host "`nOmogućavam Windows Update servis..." -ForegroundColor DarkGray
        Set-Service -Name "wuauserv" -StartupType Manual
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Write-Host "[+] Windows Update je uspešno OMOGUĆEN i pokrenut!" -ForegroundColor Green
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}