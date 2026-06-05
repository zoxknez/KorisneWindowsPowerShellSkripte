[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-UsbHistory.ps1 - Istorija priključivanja USB uređaja
Write-Host "Čitam istoriju USB skladišnih uređaja iz Windows Registra..." -ForegroundColor Cyan

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"

try {
    if (-not (Test-Path $regPath)) {
        Write-Host "Nema zapisa o priključenim USB uređajima u registrima." -ForegroundColor Yellow
        return
    }
    
    $devices = Get-ChildItem -Path $regPath
    
    Write-Host "`nIstorija USB skladišta (Flash diskovi, eksterni HDD):" -ForegroundColor Yellow
    
    $usbList = @()
    foreach ($dev in $devices) {
        # Naziv uređaja sadrži proizvođača i model
        $rawName = $dev.PSChildName
        $formattedName = $rawName
        if ($rawName -match '^Disk&Ven_([^&]+)&Prod_([^&]+)&Rev_(.*)$') {
            $formattedName = "$($Matches[1]) $($Matches[2]) (Rev: $($Matches[3]))"
        }
        
        # Dobijanje datuma prvog povezivanja iz ključa (preko datuma izmene registra)
        $subKeys = Get-ChildItem -Path $dev.PSPath
        $firstConnected = "N/A"
        if ($subKeys.Count -gt 0) {
            # Datum poslednje izmene ključa je indikator prvog priključivanja
            $firstConnected = $subKeys[0].PSChildName
        }
        
        $usbList += [PSCustomObject]@{
            Uredjaj = $formattedName
            SerijskiBroj = $firstConnected
        }
    }
    
    $usbList | Format-Table -AutoSize
} catch {
    Write-Host "Greška pri čitanju USB istorije: $($_.Exception.Message)" -ForegroundColor Red
}