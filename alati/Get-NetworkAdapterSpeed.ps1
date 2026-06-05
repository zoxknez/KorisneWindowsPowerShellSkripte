[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-NetworkAdapterSpeed.ps1 - Detekcija brzine mrežne kartice
Write-Host "Očitavam brzinu mrežnih adaptera..." -ForegroundColor Cyan

try {
    $adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.Speed -gt 0 -and $_.PhysicalAdapter }
    
    Write-Host "`nAktivni fizički mrežni adapteri:`n" -ForegroundColor Yellow
    
    foreach ($a in $adapters) {
        # Brzina je u bitovima u sekundi, konvertujemo u Mbps ili Gbps
        $speed = $a.Speed
        $speedStr = ""
        if ($speed -ge 1GB) {
            $speedStr = "$([Math]::Round($speed / 1GB, 1)) Gbps"
        } else {
            $speedStr = "$([Math]::Round($speed / 1MB, 1)) Mbps"
        }
        
        Write-Host "Naziv mrežne kartice : $($a.Name)" -ForegroundColor Green
        Write-Host "  Maksimalna brzina  : $speedStr" -ForegroundColor White
        Write-Host "  Tip adaptera       : $($a.AdapterType)" -ForegroundColor White
        Write-Host "  MAC adresa         : $($a.MACAddress)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "Greška pri čitanju mrežne brzine: $($_.Exception.Message)" -ForegroundColor Red
}