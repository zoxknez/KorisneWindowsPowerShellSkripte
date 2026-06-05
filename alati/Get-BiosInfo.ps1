[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-BiosInfo.ps1 - Prikaz informacija o BIOS-u i matičnoj ploči
Write-Host "Čitam podatke o matičnoj ploči i BIOS-u..." -ForegroundColor Cyan

try {
    $bios = Get-CimInstance Win32_BIOS
    $board = Get-CimInstance Win32_BaseBoard
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "             MATIČNA PLOČA (MOTHERBOARD)          " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Proizvođač : $($board.Manufacturer)" -ForegroundColor White
    Write-Host "Model      : $($board.Product)" -ForegroundColor White
    Write-Host "Verzija    : $($board.Version)" -ForegroundColor White
    Write-Host "Serijski br: $($board.SerialNumber)" -ForegroundColor White
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                    BIOS PODACI                   " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Proizvođač : $($bios.Manufacturer)" -ForegroundColor White
    Write-Host "Verzija    : $($bios.SMBIOSBIOSVersion)" -ForegroundColor White
    Write-Host "Datum      : $($bios.ReleaseDate.ToString('dd.MM.yyyy'))" -ForegroundColor White
    Write-Host "Serijski br: $($bios.SerialNumber)" -ForegroundColor White
    Write-Host "Status BIOS: $($bios.Status)" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška pri čitanju sistemskih specifikacija: $($_.Exception.Message)" -ForegroundColor Red
}