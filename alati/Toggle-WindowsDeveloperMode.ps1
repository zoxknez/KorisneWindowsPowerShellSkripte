[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Toggle-WindowsDeveloperMode.ps1 - Prekidač za Developer Mode i bezbedne Symlinkove
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Upozorenje: Promena Developer Mode-a zahteva Administratorske privilegije." -ForegroundColor Yellow
    $confirm = Read-Host "Da li želite da pokrenete skriptu kao Administrator? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        try {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        } catch {
            Write-Host "Nije moguće pokrenuti kao Administrator: $($_.Exception.Message)" -ForegroundColor Red
        }
        return
    } else {
        Write-Host "Operacija otkazana." -ForegroundColor Red
        return
    }
}

Write-Host "Čitam trenutni status Developer Mode-a..." -ForegroundColor Cyan

try {
    # Provera i kreiranje ključa ako ne postoji
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    $devModeState = Get-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    
    # Ako je isključeno (ili ne postoji), uključujemo ga (Value = 1)
    if (-not $devModeState -or $devModeState.AllowDevelopmentWithoutDevLicense -eq 0) {
        Write-Host "Developer Mode je trenutno: ISKLJUČEN" -ForegroundColor Yellow
        Write-Host "Uključujem Developer Mode (omogućava instalaciju sideload aplikacija i symlinkove bez admina)..." -ForegroundColor White
        
        Set-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force
        $newState = "UKLJUČEN"
        $color = "Green"
    } else {
        # Ako je uključeno, isključujemo ga (Value = 0)
        Write-Host "Developer Mode je trenutno: UKLJUČEN" -ForegroundColor Yellow
        Write-Host "Isključujem Developer Mode..." -ForegroundColor White
        
        Set-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 0 -Force
        $newState = "ISKLJUČEN"
        $color = "Red"
    }
    
    Write-Host "`nOperacija završena!" -ForegroundColor Green
    Write-Host "Developer Mode je sada: " -NoNewline -ForegroundColor Green
    Write-Host $newState -ForegroundColor $color
    Write-Host "Promena je aktivna. Nije potreban restart sistema." -ForegroundColor DarkGray
} catch {
    Write-Host "Greška pri menjanju registra: $($_.Exception.Message)" -ForegroundColor Red
}