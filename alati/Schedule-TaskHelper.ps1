[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Schedule-TaskHelper.ps1 - Pomoćnik za Windows Task Scheduler
function Show-SubMenu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "          WINDOWS TASK SCHEDULER ASISTENT         " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Prikaži sve aktivne zakazane zadatke (Custom)"
    Write-Host "2. Kreiraj novi zakazani zadatak (Dnevno pokretanje)"
    Write-Host "3. Obriši zakazani zadatak"
    Write-Host "0. Nazad u glavni meni"
    Write-Host "==================================================" -ForegroundColor Cyan
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Upozorenje: Upravljanje zakazanim zadacima uglavnom zahteva Administratorske privilegije." -ForegroundColor Yellow
    Read-Host "Pritisnite Enter da nastavite bez obzira na to..."
}

do {
    Show-SubMenu
    $choice = Read-Host "Izbor"
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "ZAKAZANI ZADACI:`n" -ForegroundColor Yellow
            try {
                # Prikazujemo samo zadatke iz Root foldera koji nisu Microsoft sistemski
                Get-ScheduledTask | Where-Object { $_.TaskPath -eq "\" -and $_.TaskName -notmatch "^\b(Microsoft|Windows)\b" } | 
                    Select-Object TaskName, State, @{Name="Putanja";Expression={$_.Actions[0].Execute}} | Format-Table -AutoSize
            } catch {
                Write-Host "Nije moguće pročitati zadatke: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        "2" {
            # Kreiranje novog zadatka
            Clear-Host
            Write-Host "Kreiranje novog dnevnog zadatka:`n" -ForegroundColor Yellow
            $taskName = Read-Host "Unesite IME zadatka (npr. MojDnevniBekap)"
            $exePath = Read-Host "Unesite putanju do programa/skripte za pokretanje (npr. powershell.exe)"
            $args = Read-Host "Unesite argumente (npr. -File D:\ProjektiApp\skripte\Clean-WindowsTemp.ps1)"
            $timeStr = Read-Host "Unesite vreme pokretanja u formatu HH:mm (npr. 08:30)"
            
            if (-not [string]::IsNullOrEmpty($taskName) -and -not [string]::IsNullOrEmpty($exePath) -and $timeStr -match "^\d{2}:\d{2}$") {
                try {
                    $action = New-ScheduledTaskAction -Execute $exePath -Argument $args
                    $trigger = New-ScheduledTaskTrigger -Daily -At $timeStr
                    
                    # Registrujemo zadatak
                    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description "Zadatak kreiran preko Windows Utility Toolkit-a" -Force | Out-Null
                    Write-Host "`n[+] Zadatak '$taskName' je uspešno kreiran i zakazan!" -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri kreiranju zadatka: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "Neispravan unos podataka ili format vremena!" -ForegroundColor Red
            }
        }
        "3" {
            Clear-Host
            $taskName = Read-Host "Unesite IME zadatka koji želite da obrišete"
            if (-not [string]::IsNullOrEmpty($taskName)) {
                try {
                    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
                    Write-Host "Zadatak '$taskName' je uspešno obrisan." -ForegroundColor Green
                } catch {
                    Write-Host "Greška: Zadatak sa tim nazivom nije pronađen ili ne može biti obrisan." -ForegroundColor Red
                }
            }
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "Pritisnite Enter za nastavak..."
    }
} while ($choice -ne "0")