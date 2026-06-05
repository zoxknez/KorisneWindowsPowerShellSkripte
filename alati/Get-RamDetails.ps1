[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-RamDetails.ps1 - Detaljan prikaz instaliranih RAM modula
Write-Host "Prikupljam informacije o RAM memoriji..." -ForegroundColor Cyan

try {
    $memDevices = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                IZVEŠTAJ O RAM MODULIMA           " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    $totalCapacity = 0
    
    foreach ($dev in $memDevices) {
        $sizeGB = [Math]::Round($dev.Capacity / 1GB, 1)
        $totalCapacity += $dev.Capacity
        
        # Tipovi memorije
        $memType = switch ($dev.MemoryType) {
            20 { "DDR" }
            21 { "DDR2" }
            22 { "DDR2 FB-DIMM" }
            24 { "DDR3" }
            26 { "DDR4" }
            default { "DDR4/DDR5 (Savremeni)" }
        }
        
        Write-Host "Slot lokacija : $($dev.DeviceLocator)" -ForegroundColor Green
        Write-Host "  Kapacitet   : $sizeGB GB" -ForegroundColor White
        Write-Host "  Brzina      : $($dev.Speed) MHz" -ForegroundColor White
        Write-Host "  Proizvođač  : $($dev.Manufacturer)" -ForegroundColor White
        Write-Host "  Napon rada  : $($dev.ConfiguredVoltage / 1000) V" -ForegroundColor White
        Write-Host "  Part Number : $($dev.PartNumber.Trim())" -ForegroundColor White
        Write-Host ""
    }
    
    $totalGB = [Math]::Round($totalCapacity / 1GB, 1)
    Write-Host "Ukupno instalirana RAM memorija: $totalGB GB" -ForegroundColor Gold
    Write-Host "Ukupan broj zauzetih slotova: $($memDevices.Count)" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška pri čitanju RAM memorije: $($_.Exception.Message)" -ForegroundColor Red
}