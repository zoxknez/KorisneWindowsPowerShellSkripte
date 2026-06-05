# Toggle-SleepSettings.ps1 - Prekidač za sprečavanje odlaska računara u sleep mod (Keep-Alive)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$KeepAlive
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if ($KeepAlive) {
    Write-Host "Pokrećem Keep-Alive mod. Sprečavam računar da zaspi..." -ForegroundColor Green
    Write-Host "Pritisnite Ctrl+C za zaustavljanje i vraćanje na normalna podešavanja.`n" -ForegroundColor Yellow
    
    # Wscript.Shell se koristi za slanje pritiska tastera (npr. F15) svakih 60 sekundi da bi Windows ostao budan
    $myshell = New-Object -com "Wscript.Shell"
    
    try {
        while ($true) {
            $myshell.sendkeys("{F15}")
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Poslata simulacija tastera (Keep Awake)." -ForegroundColor DarkGray
            Start-Sleep -Seconds 60
        }
    } catch {
        Write-Host "`nZaustavljen Keep-Alive mod." -ForegroundColor Yellow
    }
} else {
    Write-Host "Kontrola režima spavanja računara:" -ForegroundColor Cyan
    Write-Host "1. Postavi spavanje ekrana na NIKADA (dok ne vratite)" -ForegroundColor Yellow
    Write-Host "2. Vrati normalno spavanje na 15 minuta" -ForegroundColor Green
    
    $choice = Read-Host "Izaberite opciju (1 ili 2)"
    try {
        if ($choice -eq "1") {
            # powercfg -change -monitor-timeout-ac [minutes]
            powercfg /change monitor-timeout-ac 0
            powercfg /change disk-timeout-ac 0
            powercfg /change standby-timeout-ac 0
            Write-Host "[+] Podešeno: Monitor i Standby nikada neće zaspati kada je na punjaču." -ForegroundColor Green
        }
        elseif ($choice -eq "2") {
            powercfg /change monitor-timeout-ac 15
            powercfg /change disk-timeout-ac 20
            powercfg /change standby-timeout-ac 30
            Write-Host "[+] Podešeno: Monitor 15 min, Standby 30 min." -ForegroundColor Green
        }
    } catch {
        Write-Host "Greška: powercfg komande zahtevaju Administratorske privilegije." -ForegroundColor Red
    }
}