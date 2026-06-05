[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-WindowsServicesInteractive.ps1 - Upravljanje Windows servisima
function Show-SubMenu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             UPRAVLJANJE WINDOWS SERVISIMA        " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Pretraži servise po nazivu"
    Write-Host "2. Pokreni servis"
    Write-Host "3. Zaustavi servis"
    Write-Host "4. Restartuj servis"
    Write-Host "5. Promeni režim pokretanja servisa"
    Write-Host "0. Nazad u glavni meni"
    Write-Host "==================================================" -ForegroundColor Cyan
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Upozorenje: Pokretanje/zaustavljanje servisa zahteva Administratorska prava." -ForegroundColor Yellow
    Read-Host "Pritisnite Enter da nastavite..."
}

do {
    Show-SubMenu
    $choice = Read-Host "Izbor"
    
    switch ($choice) {
        "1" {
            $search = Read-Host "Unesite deo naziva servisa za pretragu (npr. wuauserv)"
            if (-not [string]::IsNullOrEmpty($search)) {
                Clear-Host
                Write-Host "Rezultati pretrage servisa za '$search':`n" -ForegroundColor Yellow
                Get-Service -Name "*$search*" -ErrorAction SilentlyContinue | Select-Object Name, DisplayName, Status, StartType | Format-Table -AutoSize
            }
        }
        "2" {
            $name = Read-Host "Unesite tačan naziv servisa koji želite da pokrenete"
            if (-not [string]::IsNullOrEmpty($name)) {
                try {
                    Start-Service -Name $name -ErrorAction Stop
                    Write-Host "Servis '$name' je uspešno pokrenut." -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri pokretanju servisa: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        "3" {
            $name = Read-Host "Unesite tačan naziv servisa koji želite da zaustavite"
            if (-not [string]::IsNullOrEmpty($name)) {
                try {
                    Stop-Service -Name $name -Force -ErrorAction Stop
                    Write-Host "Servis '$name' je uspešno zaustavljen." -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri zaustavljanju servisa: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        "4" {
            $name = Read-Host "Unesite tačan naziv servisa koji želite da restartujete"
            if (-not [string]::IsNullOrEmpty($name)) {
                try {
                    Restart-Service -Name $name -Force -ErrorAction Stop
                    Write-Host "Servis '$name' je uspešno restartovan." -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri restartu servisa: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
        "5" {
            $name = Read-Host "Unesite tačan naziv servisa za promenu start režima"
            $mode = Read-Host "Izaberite režim: 1 za Automatic, 2 za Manual, 3 za Disabled"
            $startType = switch ($mode) {
                "1" { "Automatic" }
                "2" { "Manual" }
                "3" { "Disabled" }
            }
            if (-not [string]::IsNullOrEmpty($name) -and -not [string]::IsNullOrEmpty($startType)) {
                try {
                    Set-Service -Name $name -StartupType $startType -ErrorAction Stop
                    Write-Host "Start tip servisa '$name' uspešno promenjen na: $startType" -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri promeni parametara servisa: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "Pritisnite Enter za nastavak..."
    }
} while ($choice -ne "0")