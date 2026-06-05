[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Block-WindowsTelemetry.ps1 - Blokiranje Windows telemetrije i praćenja
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Ova skripta zahteva Administratorske privilegije za izmenu sistemskih registara i servisa!" -ForegroundColor Red
    return
}

Write-Host "Onemogućavam Windows telemetriju i praćenje aktivnosti..." -ForegroundColor Cyan

try {
    # 1. Isključivanje Diagnostic Tracking servisa (DiagTrack / dmwappushservice)
    Write-Host "Zaustavljam i onemogućavam DiagTrack servis..." -ForegroundColor DarkGray
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
    
    Write-Host "Zaustavljam i onemogućavam dmwappushservice..." -ForegroundColor DarkGray
    Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue

    # 2. Registry podešavanja za isključivanje telemetrije
    Write-Host "Podešavam Windows Registry ključeve..." -ForegroundColor DarkGray
    
    $policiesPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $policiesPath)) {
        New-Item -Path $policiesPath -Force | Out-Null
    }
    Set-ItemProperty -Path $policiesPath -Name "AllowTelemetry" -Value 0 -Type DWord -Force | Out-Null
    
    # 3. Onemogućavanje Cortana-e
    $cortanaPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $cortanaPath)) {
        New-Item -Path $cortanaPath -Force | Out-Null
    }
    Set-ItemProperty -Path $cortanaPath -Name "AllowCortana" -Value 0 -Type DWord -Force | Out-Null

    # 4. Isključivanje oglašavačkog ID-ja (Advertising ID)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -Force | Out-Null
    
    Write-Host "`n[+] Telemetrija i praćenje uspešno blokirani!" -ForegroundColor Green
    Write-Host "Preporučuje se restartovanje računara radi primene svih izmena." -ForegroundColor Yellow
} catch {
    Write-Host "Greška tokom blokiranja telemetrije: $($_.Exception.Message)" -ForegroundColor Red
}