[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-StorageControllerInfo.ps1 - Informacije o diskovnim kontrolerima
Write-Host "Čitam specifikacije disk kontrolera (SATA/NVMe/SCSI)..." -ForegroundColor Cyan

try {
    $controllers = Get-CimInstance Win32_SCSIController
    
    Write-Host "`nPronađeni kontroleri skladišta podataka:`n" -ForegroundColor Yellow
    
    foreach ($c in $controllers) {
        Write-Host "Naziv kontrolera: $($c.Name)" -ForegroundColor Green
        Write-Host "  Proizvođač      : $($c.Manufacturer)" -ForegroundColor White
        Write-Host "  Protokol rada   : $($c.ProtocolWidth) bit" -ForegroundColor White
        Write-Host "  Status rada     : $($c.Status)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "Greška pri čitanju diskovnih kontrolera: $($_.Exception.Message)" -ForegroundColor Red
}