[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-StartupApps.ps1 - Upravljanje startup programima (Registry Run ključevi)
Write-Host "Učitavam listu startup aplikacija iz Windows Registra..." -ForegroundColor Cyan

$regPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

function Get-StartupList {
    $list = @()
    foreach ($rp in $regPaths) {
        if (Test-Path $rp) {
            $key = Get-Item -Path $rp
            $props = Get-ItemProperty -Path $rp
            foreach ($valName in $key.GetValueNames()) {
                $list += [PSCustomObject]@{
                    RegPath = $rp
                    KeyName = $valName
                    CmdLine = $props.$valName
                }
            }
        }
    }
    return $list
}

do {
    $apps = Get-StartupList
    
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "          UPRAVLJANJE STARTUP PROGRAMIMA          " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $a = $apps[$i]
        $loc = if ($a.RegPath -match "HKCU") { "Lokalni Korisnik" } else { "Ceo Sistem (Admin)" }
        Write-Host "$($i + 1). [$loc] $($a.KeyName)" -ForegroundColor White
        Write-Host "   Komanda: $($a.CmdLine)" -ForegroundColor DarkGray
    }
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "Opcije:" -ForegroundColor Yellow
    Write-Host "A. Dodaj novi startup program" -ForegroundColor Green
    Write-Host "D. Obriši startup program (unesite D prateći broj, npr. D2)" -ForegroundColor Red
    Write-Host "Q. Nazad/Izlaz" -ForegroundColor Red
    
    $choice = Read-Host "`nIzaberite opciju"
    
    if ($choice.ToUpper() -eq "A") {
        $name = Read-Host "Unesite naziv aplikacije"
        $path = Read-Host "Unesite apsolutnu putanju do izvršnog fajla (.exe)"
        if (-not [string]::IsNullOrWhitespace($name) -and (Test-Path $path)) {
            try {
                # Uvek upisujemo u HKCU (nije potreban Admin)
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $name -Value "`"$path`"" -ErrorAction Stop
                Write-Host "Startup program uspešno dodat!" -ForegroundColor Green
            } catch {
                Write-Host "Greška pri dodavanju: $($_.Exception.Message)" -ForegroundColor Red
            }
            Read-Host "Pritisnite Enter..."
        } else {
            Write-Host "Putanja do fajla ne postoji!" -ForegroundColor Red
            Read-Host "Pritisnite Enter..."
        }
    }
    elseif ($choice.ToUpper() -match '^D(\d+)$') {
        $index = [int]$Matches[1] - 1
        if ($index -ge 0 -and $index -lt $apps.Count) {
            $selected = $apps[$index]
            $confirm = Read-Host "Da li ste sigurni da želite da obrišete unos '$($selected.KeyName)'? (Y/N)"
            if ($confirm.ToUpper() -eq "Y") {
                try {
                    Remove-ItemProperty -Path $selected.RegPath -Name $selected.KeyName -ErrorAction Stop
                    Write-Host "Unos uspešno obrisan." -ForegroundColor Green
                } catch {
                    Write-Host "Greška: Brisanje iz HKLM registra zahteva Administratorska prava!" -ForegroundColor Red
                }
                Read-Host "Pritisnite Enter..."
            }
        }
    }
} while ($choice.ToUpper() -ne "Q")