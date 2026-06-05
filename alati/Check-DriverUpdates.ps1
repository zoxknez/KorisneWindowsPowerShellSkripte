[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Check-DriverUpdates.ps1 - Provera verzija kritičnih drajvera
Write-Host "Skeniram datume kritičnih mrežnih i grafičkih drajvera..." -ForegroundColor Cyan

try {
    # Pronalaženje mrežnih i display adaptera
    $adapters = Get-CimInstance Win32_PnPSignedDriver | Where-Object { 
        $_.DeviceClass -eq "NET" -or $_.DeviceClass -eq "DISPLAY" 
    }
    
    Write-Host "`nDatumi i verzije instaliranih drajvera:" -ForegroundColor Yellow
    
    $list = @()
    foreach ($a in $adapters) {
        # Formatiranje datuma drajvera
        $dateStr = if ($a.DriverDate) { $a.DriverDate.ToString("dd.MM.yyyy") } else { "Nepoznato" }
        $list += [PSCustomObject]@{
            Uredjaj = $a.DeviceName
            Klasa = $a.DeviceClass
            Verzija = $a.DriverVersion
            Datum = $dateStr
            Proizvodjac = $a.Manufacturer
        }
    }
    
    $list | Format-Table -AutoSize
    Write-Host "`nSavet: Ukoliko su drajveri stariji od 2 godine (proveriti polje 'Datum'), posetite sajt proizvođača radi ažuriranja." -ForegroundColor Yellow
} catch {
    Write-Host "Greška pri proveri verzija drajvera: $($_.Exception.Message)" -ForegroundColor Red
}