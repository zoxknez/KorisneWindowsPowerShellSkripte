[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-WindowsLicenseKey.ps1 - Pronalaženje Windows licencnog ključa
Write-Host "Pokušavam da očitam originalni Windows licencni ključ..." -ForegroundColor Cyan

try {
    # 1. Čitanje OEM ključa upisanog u BIOS/matičnu ploču (najčešće za fabričke laptopove)
    Write-Host "`nPretraga OEM ključa u BIOS-u..." -ForegroundColor DarkGray
    $oemKey = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
    
    if (-not [string]::IsNullOrEmpty($oemKey)) {
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "  OEM LICENCNI KLJUČ U BIOS-U (Fabrički):" -ForegroundColor Yellow
        Write-Host "  $oemKey" -ForegroundColor Green
        Write-Host "==================================================" -ForegroundColor Cyan
        $oemKey | clip.exe
        Write-Host "(Kopirano u Clipboard)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [-] Nije pronađen OEM licencni ključ u matičnoj ploči." -ForegroundColor Yellow
    }
    
    # 2. Čitanje aktivnog ključa iz Registra
    Write-Host "`nPretraga aktivnog ključa u Windows Registru..." -ForegroundColor DarkGray
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
    if (Test-Path $regPath) {
        $backupKey = (Get-ItemProperty -Path $regPath).BackupProductKeyDefault
        if (-not [string]::IsNullOrEmpty($backupKey) -and $backupKey -ne "bbbbb-bbbbb-bbbbb-bbbbb-bbbbb") {
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host "  AKTIVNI LICENCNI KLJUČ (Registry Backup):" -ForegroundColor Yellow
            Write-Host "  $backupKey" -ForegroundColor Green
            Write-Host "==================================================" -ForegroundColor Cyan
            $backupKey | clip.exe
            Write-Host "(Kopirano u Clipboard)" -ForegroundColor DarkGray
        } else {
            Write-Host "  [-] Nije pronađen licencni ključ u registru." -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Greška pri preuzimanju licencnog ključa: $($_.Exception.Message)" -ForegroundColor Red
}