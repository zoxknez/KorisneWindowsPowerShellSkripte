[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-ScheduledRestarts.ps1 - Zakazivanje automatskog restartovanja računara
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Kreiranje zakazanih taskova zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

Write-Host "Upravljanje zakazanim restartovanjima računara:" -ForegroundColor Cyan
Write-Host "1. Zakaži jednokratan restart za određeno vreme (preko shutdown komande)" -ForegroundColor Yellow
Write-Host "2. Kreiraj dnevni zakazani zadatak (Task) za restart (npr. svake noći u 03:00)" -ForegroundColor Green
Write-Host "3. Obriši dnevni zadatak za restart" -ForegroundColor Red
Write-Host "0. Izlaz"

$choice = Read-Host "Opcija"

try {
    if ($choice -eq "1") {
        $minutes = Read-Host "Za koliko minuta želite da se računar restartuje?"
        if ($minutes -match '^\d+$') {
            $seconds = [int]$minutes * 60
            # shutdown -r -t [seconds]
            shutdown.exe /r /t $seconds /c "Windows Toolkit: Zakazan restart za $minutes minuta."
            Write-Host "Računar će se restartovati za $minutes minuta. Da otkažete pokrenite: shutdown /a" -ForegroundColor Green
        }
    }
    elseif ($choice -eq "2") {
        $time = Read-Host "Unesite vreme za dnevni restart u formatu HH:MM (npr. 03:00)"
        if ($time -match '^\d{2}:\d{2}$') {
            $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0 /f"
            $trigger = New-ScheduledTaskTrigger -Daily -At $time
            
            # Registrujemo task pod SYSTEM nalogom kako bi se izvršio i bez ulogovanog korisnika
            Register-ScheduledTask -TaskName "WindowsToolkit_Restarti" -Action $action -Trigger $trigger -User "SYSTEM" -RunLevel Highest | Out-Null
            Write-Host "Dnevni restart uspešno zakazan u $time svake noći!" -ForegroundColor Green
        } else {
            Write-Host "Neispravan format vremena!" -ForegroundColor Red
        }
    }
    elseif ($choice -eq "3") {
        if (Get-ScheduledTask -TaskName "WindowsToolkit_Restarti" -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName "WindowsToolkit_Restarti" -Confirm:$false
            Write-Host "Zadatak za automatski restart je uspešno obrisan." -ForegroundColor Green
        } else {
            Write-Host "Zadatak nije pronađen na sistemu." -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}