[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Clean-DiskCleanupAdvanced.ps1 - Pokretanje naprednog čišćenja diska (Cleanmgr)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Za napredno sistemsko čišćenje potrebne su Vam Administratorske privilegije." -ForegroundColor Yellow
    $confirm = Read-Host "Da li želite da pokrenete skriptu kao Administrator? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    }
    return
}

Write-Host "Pokrećem napredno čišćenje diska (Windows Update cleanups, logovi, senke)..." -ForegroundColor Cyan
Write-Host "Konfigurišem parametre za automatsko duboko čišćenje..." -ForegroundColor DarkGray

try {
    # Postavljanje svih zastavica za čišćenje u registru (Sagerun 1)
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    $caches = Get-ChildItem -Path $regPath
    
    foreach ($cache in $caches) {
        # Zapisujemo StateFlags0001 = 2 (čišćenje aktivno)
        Set-ItemProperty -Path $cache.PsPath -Name "StateFlags0001" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    
    Write-Host "[+] Parametri uspešno zapisani." -ForegroundColor Green
    Write-Host "Sada se otvara sistemski proces cleanmgr.exe za potpuno čišćenje..." -ForegroundColor Yellow
    
    # Pokretanje cleanmgr sa sagerun zastavicom
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
    
    Write-Host "`n[+] Čišćenje diska preko cleanmgr.exe je uspešno pokrenuto i završeno." -ForegroundColor Green
} catch {
    Write-Host "Greška pri pokretanju čišćenja: $($_.Exception.Message)" -ForegroundColor Red
}