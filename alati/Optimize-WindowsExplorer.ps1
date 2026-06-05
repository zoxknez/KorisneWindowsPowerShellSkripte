[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Optimize-WindowsExplorer.ps1 - Registarske optimizacije za ubrzanje Windows Explorera
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Podešavanje sistemskih performansi zahteva Administratorske privilegije." -ForegroundColor Red
    return
}

Write-Host "Započinjem optimizaciju Windows Explorer-a i menija..." -ForegroundColor Cyan

try {
    # 1. Smanjenje kašnjenja prikaza menija (MenuShowDelay sa 400ms na 20ms)
    Write-Host "Smanjujem kašnjenje prikaza menija na 20ms..." -ForegroundColor DarkGray
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "20" -Force | Out-Null
    
    # 2. Ubrzanje odziva aplikacija koje ne reaguju (HungAppTimeout, WaitToKillAppTimeout)
    Write-Host "Podešavam brže gašenje zamrznutih procesa..." -ForegroundColor DarkGray
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "HungAppTimeout" -Value "2000" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WaitToKillAppTimeout" -Value "2000" -Force | Out-Null
    
    # 3. Otvaranje foldera u posebnom procesu (povećava stabilnost ako pukne jedan folder)
    Write-Host "Podešavam stabilnije pokretanje Explorer foldera..." -ForegroundColor DarkGray
    $exploreKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $exploreKey -Name "SeparateProcess" -Value 1 -Type DWord -Force | Out-Null
    
    # 4. Onemogućavanje pretrage na internetu u Start Meniju (ubrzava lokalni pretragu)
    Write-Host "Isključujem Bing pretragu u Start Meniju..." -ForegroundColor DarkGray
    $searchKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path $searchKey -Name "BingSearchEnabled" -Value 0 -Type DWord -Force | Out-Null
    Set-ItemProperty -Path $searchKey -Name "CortanaConsent" -Value 0 -Type DWord -Force | Out-Null

    Write-Host "`n[+] Optimizacije uspešno primenjene!" -ForegroundColor Green
    Write-Host "Restartujem Windows Explorer radi primene promena..." -ForegroundColor Yellow
    
    Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
    
    Write-Host "Optimizacija završena!" -ForegroundColor Yellow
} catch {
    Write-Host "Greška tokom primene optimizacija: $($_.Exception.Message)" -ForegroundColor Red
}