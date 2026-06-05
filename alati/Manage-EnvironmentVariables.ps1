[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-EnvironmentVariables.ps1 - Uređivanje Environment promenljivih i PATH-a
function Show-SubMenu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "          UREĐIVANJE ENVIRONMENT PROMENLJIVIH     " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Prikaži sve User promenljive"
    Write-Host "2. Prikaži sve System promenljive"
    Write-Host "3. Dodaj / Izmeni promenljivu"
    Write-Host "4. Obriši promenljivu"
    Write-Host "5. Uredi PATH promenljivu (User)"
    Write-Host "6. Uredi PATH promenljivu (System - Zahteva Admin)"
    Write-Host "0. Nazad u glavni meni"
    Write-Host "==================================================" -ForegroundColor Cyan
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

do {
    Show-SubMenu
    $choice = Read-Host "Izbor"
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "KORISNIČKE PROMENLJIVE (User):`n" -ForegroundColor Yellow
            [Environment]::GetEnvironmentVariables("User") | Format-List
        }
        "2" {
            Clear-Host
            Write-Host "SISTEMSKE PROMENLJIVE (System):`n" -ForegroundColor Yellow
            [Environment]::GetEnvironmentVariables("Machine") | Format-List
        }
        "3" {
            $scopeChoice = Read-Host "Izaberite opseg: 1 za User, 2 za System (Machine)"
            $scope = if ($scopeChoice -eq "2") { "Machine" } else { "User" }
            
            if ($scope -eq "Machine" -and -not $isAdmin) {
                Write-Host "Greška: Izmena sistemskih promenljivih zahteva administratorske privilegije!" -ForegroundColor Red
                break
            }
            
            $name = Read-Host "Unesite IME promenljive (npr. JAVA_HOME)"
            $val = Read-Host "Unesite VREDNOST promenljive"
            
            if (-not [string]::IsNullOrEmpty($name)) {
                [Environment]::SetEnvironmentVariable($name, $val, $scope)
                Write-Host "Uspešno sačuvano!" -ForegroundColor Green
            }
        }
        "4" {
            $scopeChoice = Read-Host "Izaberite opseg iz kojeg brišete: 1 za User, 2 za System"
            $scope = if ($scopeChoice -eq "2") { "Machine" } else { "User" }
            
            if ($scope -eq "Machine" -and -not $isAdmin) {
                Write-Host "Greška: Zahteva se administratorski pristup!" -ForegroundColor Red
                break
            }
            
            $name = Read-Host "Unesite IME promenljive koju brišete"
            if (-not [string]::IsNullOrEmpty($name)) {
                [Environment]::SetEnvironmentVariable($name, $null, $scope)
                Write-Host "Promenljiva '$name' obrisana." -ForegroundColor Green
            }
        }
        "5" {
            # Uređivanje User PATH
            $pathVal = [Environment]::GetEnvironmentVariable("Path", "User")
            $paths = $pathVal.Split(";") | Where-Object { $_ }
            
            Clear-Host
            Write-Host "TRENUTNI KORISNIČKI PATH (User PATH):`n" -ForegroundColor Yellow
            for ($i=0; $i -lt $paths.Count; $i++) {
                Write-Host "$i. $($paths[$i])"
            }
            Write-Host "`nIzaberite akciju:"
            Write-Host "1. Dodaj novu putanju u PATH"
            Write-Host "2. Obriši putanju iz PATH-a"
            $act = Read-Host "Akcija"
            
            if ($act -eq "1") {
                $newPath = Read-Host "Unesite novu putanju"
                if (-not [string]::IsNullOrEmpty($newPath) -and (Test-Path $newPath)) {
                    $newPathVal = $pathVal + ";" + $newPath
                    [Environment]::SetEnvironmentVariable("Path", $newPathVal, "User")
                    Write-Host "Putanja uspešno dodata u PATH!" -ForegroundColor Green
                } else {
                    Write-Host "Putanja ne postoji ili je prazna!" -ForegroundColor Red
                }
            } elseif ($act -eq "2") {
                $idx = Read-Host "Unesite broj stavke koju brišete (0-$($paths.Count - 1))"
                if ($idx -match "^\d+$" -and [int]$idx -lt $paths.Count) {
                    $filteredPaths = $paths | Where-Object { $_ -ne $paths[[int]$idx] }
                    $newPathVal = $filteredPaths -join ";"
                    [Environment]::SetEnvironmentVariable("Path", $newPathVal, "User")
                    Write-Host "Putanja uspešno uklonjena iz PATH-a!" -ForegroundColor Green
                }
            }
        }
        "6" {
            # Uređivanje System PATH (zahteva Admin)
            if (-not $isAdmin) {
                Write-Host "Greška: Uređivanje sistemskog PATH-a zahteva pokretanje kao Administrator!" -ForegroundColor Red
                break
            }
            $pathVal = [Environment]::GetEnvironmentVariable("Path", "Machine")
            $paths = $pathVal.Split(";") | Where-Object { $_ }
            
            Clear-Host
            Write-Host "TRENUTNI SISTEMSKI PATH (Machine PATH):`n" -ForegroundColor Yellow
            for ($i=0; $i -lt $paths.Count; $i++) {
                Write-Host "$i. $($paths[$i])"
            }
            Write-Host "`nIzaberite akciju:"
            Write-Host "1. Dodaj novu putanju u PATH"
            Write-Host "2. Obriši putanju iz PATH-a"
            $act = Read-Host "Akcija"
            
            if ($act -eq "1") {
                $newPath = Read-Host "Unesite novu putanju"
                if (-not [string]::IsNullOrEmpty($newPath) -and (Test-Path $newPath)) {
                    $newPathVal = $pathVal + ";" + $newPath
                    [Environment]::SetEnvironmentVariable("Path", $newPathVal, "Machine")
                    Write-Host "Putanja uspešno dodata u sistemski PATH!" -ForegroundColor Green
                } else {
                    Write-Host "Putanja ne postoji!" -ForegroundColor Red
                }
            } elseif ($act -eq "2") {
                $idx = Read-Host "Unesite broj stavke koju brišete (0-$($paths.Count - 1))"
                if ($idx -match "^\d+$" -and [int]$idx -lt $paths.Count) {
                    $filteredPaths = $paths | Where-Object { $_ -ne $paths[[int]$idx] }
                    $newPathVal = $filteredPaths -join ";"
                    [Environment]::SetEnvironmentVariable("Path", $newPathVal, "Machine")
                    Write-Host "Putanja uspešno uklonjena!" -ForegroundColor Green
                }
            }
        }
    }
    
    if ($choice -ne "0") {
        Write-Host ""
        Read-Host "Pritisnite Enter za nastavak..."
    }
} while ($choice -ne "0")