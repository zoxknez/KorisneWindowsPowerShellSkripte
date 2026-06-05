[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-PciDevices.ps1 - Prikaz svih PCI i PCIe uređaja
Write-Host "Skeniram PCI i PCIe magistrale (uređaje)..." -ForegroundColor Cyan

try {
    # Tražimo uređaje u WMI čiji DeviceID počinje sa PCI
    $pciDevices = Get-CimInstance Win32_PnPEntity | Where-Object { $_.DeviceID -like "PCI*" }
    
    Write-Host "`nPronađeno $($pciDevices.Count) PCI/PCIe uređaja na sistemu:`n" -ForegroundColor Yellow
    
    $deviceList = @()
    foreach ($dev in $pciDevices) {
        $deviceList += [PSCustomObject]@{
            NazivUredjaja = $dev.Name
            Proizvodjac   = $dev.Manufacturer
            StatusRada    = $dev.Status
        }
    }
    
    $deviceList | Format-Table -AutoSize
} catch {
    Write-Host "Greška pri čitanju magistrala: $($_.Exception.Message)" -ForegroundColor Red
}