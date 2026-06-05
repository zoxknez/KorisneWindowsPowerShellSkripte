[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-AudioDevices.ps1 - Detaljan prikaz audio uređaja
Write-Host "Učitavam konfiguraciju audio zvučnika i mikrofona..." -ForegroundColor Cyan

try {
    # 1. Čitanje WMI audio kontrolera
    $soundControllers = Get-CimInstance Win32_SoundDevice
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "               AUDIO KONTROLERI (HARDVER)         " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    foreach ($sc in $soundControllers) {
        Write-Host "Model      : $($sc.Name)" -ForegroundColor Green
        Write-Host "  Status   : $($sc.Status)" -ForegroundColor White
        Write-Host "  Proizvođač: $($sc.Manufacturer)" -ForegroundColor White
        Write-Host ""
    }
    
    # 2. Čitanje aktivnih audio kanala (preko registry-ja)
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             AKTIVNI AUDIO UREĐAJI (IN/OUT)       " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    # Dobijanje imena audio interfejsa
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio"
    if (Test-Path $regPath) {
        $endpoints = Get-ChildItem -Path "$regPath\*" | Get-ChildItem | Get-ChildItem | Where-Object { $_.Name -match "Properties" }
        foreach ($ep in $endpoints) {
            $friendlyName = Get-ItemProperty -Path $ep.PSPath -Name "{a45c254e-df1c-4efd-8020-67d146a850e0},2" -ErrorAction SilentlyContinue
            if ($friendlyName) {
                Write-Host "  - $($friendlyName.'{a45c254e-df1c-4efd-8020-67d146a850e0},2')" -ForegroundColor White
            }
        }
    }
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška pri učitavanju audio uređaja: $($_.Exception.Message)" -ForegroundColor Red
}