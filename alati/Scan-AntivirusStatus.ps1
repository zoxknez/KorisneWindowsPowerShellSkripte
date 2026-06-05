[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Scan-AntivirusStatus.ps1 - Provera stanja Windows Defender-a
Write-Host "Proveravam status antivirusne zaštite (Windows Defender)..." -ForegroundColor Cyan

try {
    if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
        $status = Get-MpComputerStatus
        
        Write-Host "`n==================================================" -ForegroundColor Cyan
        Write-Host "               STATUS WINDOWS DEFENDER-A          " -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $rtColor = if ($status.RealTimeProtectionEnabled) { "Green" } else { "Red" }
        $rtStatus = if ($status.RealTimeProtectionEnabled) { "AKTIVNA" } else { "NEAKTIVNA!" }
        
        Write-Host "Zaštita u realnom vremenu: " -NoNewline -ForegroundColor White
        Write-Host $rtStatus -ForegroundColor $rtColor
        
        Write-Host "Verzija antivirusa        : $($status.AMProductVersion)" -ForegroundColor White
        Write-Host "Verzija baze definicija   : $($status.AntivirusSignatureVersion)" -ForegroundColor White
        Write-Host "Datum ažuriranja definic. : $($status.AntivirusSignatureLastUpdated.ToString('dd.MM.yyyy HH:mm'))" -ForegroundColor White
        
        # Provera starosti definicija
        $age = (Get-Date) - $status.AntivirusSignatureLastUpdated
        if ($age.TotalDays -gt 3) {
            Write-Host "  [ALARM] Antivirusne definicije su zastarele (starije od 3 dana)!" -ForegroundColor Red
        } else {
            Write-Host "  [+] Antivirusne definicije su ažurne." -ForegroundColor Green
        }
        Write-Host "==================================================" -ForegroundColor Cyan
    } else {
        Write-Host "Komande za Windows Defender nisu dostupne na ovom sistemu." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri čitanju statusa antivirusa: $($_.Exception.Message)" -ForegroundColor Red
}