# Start-Menu.ps1 - Glavni interaktivni pokretač za Windows Utility Toolkit (140 alata)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Header {
    param([string]$Title)
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "             $Title             " -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Show-MainMenu {
    Show-Header -Title "WINDOWS UTILITY TOOLKIT (140 Alata)"
    Write-Host "Autor: o0o0o0o" -ForegroundColor DarkGray
    Write-Host "Izaberite kategoriju alata (unesite broj):`n" -ForegroundColor White
    Write-Host "1.  Sistemsko čišćenje i optimizacija (8 alata)" -ForegroundColor Green
    Write-Host "2.  Mrežni alati i SSL (8 alata)" -ForegroundColor Blue
    Write-Host "3.  Rad sa fajlovima i tekstom (10 alata)" -ForegroundColor Magenta
    Write-Host "4.  Programerske i ostale skripte (14 alata)" -ForegroundColor Yellow
    Write-Host "5.  Git i Developer alati (15 alata)" -ForegroundColor Green
    Write-Host "6.  Hardver i napredna dijagnostika (15 alata)" -ForegroundColor Blue
    Write-Host "7.  Sigurnost i mrežna odbrana (15 alata)" -ForegroundColor Red
    Write-Host "8.  Mreža, Web i DNS alati (15 alata)" -ForegroundColor Cyan
    Write-Host "9.  Rad sa medijima i fajl automatizacija (15 alata)" -ForegroundColor Magenta
    Write-Host "10. Registry, OS i Windows optimizacija (15 alata)" -ForegroundColor Yellow
    Write-Host "11. Baze podataka, Keš i Taskovi (10 alata)" -ForegroundColor Green
    Write-Host "0.  Izlaz" -ForegroundColor Red
    Write-Host "==================================================" -ForegroundColor Cyan
}

# Sub-Menu 1: Čišćenje i optimizacija
function Show-SubMenu1 {
    do {
        Show-Header -Title "ČIŠĆENJE I OPTIMIZACIJA SISTEMA"
        Write-Host "1. Očisti Node.js projekte (node_modules, dist...)" -ForegroundColor Green
        Write-Host "2. Očisti Windows privremene fajlove (Temp)" -ForegroundColor Green
        Write-Host "3. Prikaži specifikacije sistema i dev alate" -ForegroundColor Green
        Write-Host "4. Prikaži telemetriju i zdravlje baterije (laptop)" -ForegroundColor Green
        Write-Host "5. Proveri SMART zdravstveni status diskova" -ForegroundColor Green
        Write-Host "6. Prikaži real-time resurs dashboard (slično top-u)" -ForegroundColor Green
        Write-Host "7. Prikaži istoriju gašenja, restarta i rušenja (30 dana)" -ForegroundColor Green
        Write-Host "8. Očisti Docker sistem (kontejneri, slike, volumeni)" -ForegroundColor Green
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $path = Read-Host "Unesite putanju za čišćenje (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Clean-NodeProjects.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                & "$scriptDir\alati\Clean-WindowsTemp.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                & "$scriptDir\alati\Get-SystemSpecs.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                & "$scriptDir\alati\Get-BatteryStatus.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                & "$scriptDir\alati\Check-DiskHealthSMART.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                & "$scriptDir\alati\Monitor-ResourcesDashboard.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                & "$scriptDir\alati\Get-SystemUptimeHistory.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                & "$scriptDir\alati\Clean-UnusedDocker.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 2: Mreža i SSL
function Show-SubMenu2 {
    do {
        Show-Header -Title "MREŽNI ALATI I SSL"
        Write-Host "1. Oslobodi mrežni port" -ForegroundColor Blue
        Write-Host "2. Proveri status veb sajtova i SSL sertifikata" -ForegroundColor Blue
        Write-Host "3. Testiraj internet brzinu i ping" -ForegroundColor Blue
        Write-Host "4. Prikaži detaljne mrežne adaptere i javni IP" -ForegroundColor Blue
        Write-Host "5. Skeniraj lokalni mrežni opseg (ARP sken)" -ForegroundColor Blue
        Write-Host "6. Kreiraj i uvezi lokalni SSL sertifikat" -ForegroundColor Blue
        Write-Host "7. Testiraj otvorene portove na udaljenom hostu" -ForegroundColor Blue
        Write-Host "8. Prikaži mrežne veze po procesima/programima" -ForegroundColor Blue
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $port = Read-Host "Unesite port koji želite da oslobodite (npr. 3000)"
                if ($port -match "^\d+$") {
                    & "$scriptDir\alati\Free-Port.ps1" -Port [int]$port
                } else {
                    Write-Host "Neispravan port!" -ForegroundColor Red
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $urls = Read-Host "Unesite URL-ove odvojene zarezom (ili Enter za default)"
                if ([string]::IsNullOrWhitespace($urls)) {
                    & "$scriptDir\alati\Check-WebsiteStatus.ps1"
                } else {
                    $urlArray = $urls.Split(",") | ForEach-Object { $_.Trim() }
                    & "$scriptDir\alati\Check-WebsiteStatus.ps1" -Urls $urlArray
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                & "$scriptDir\alati\Check-InternetSpeed.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                & "$scriptDir\alati\Get-NetworkDetails.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                & "$scriptDir\alati\Scan-LocalNetwork.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                $domain = Read-Host "Unesite lokalni domen za SSL (npr. mojprojekat.local)"
                if (-not [string]::IsNullOrWhitespace($domain)) {
                    & "$scriptDir\alati\Generate-LocalSslCert.ps1" -DomainName $domain
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $hostName = Read-Host "Unesite host/IP za skeniranje (npr. 127.0.0.1)"
                if (-not [string]::IsNullOrWhitespace($hostName)) {
                    $portsStr = Read-Host "Unesite portove odvojene zarezom (ili Enter za common)"
                    if ([string]::IsNullOrWhitespace($portsStr)) {
                        & "$scriptDir\alati\Scan-RemotePorts.ps1" -HostName $hostName
                    } else {
                        $portsArray = $portsStr.Split(",") | ForEach-Object { [int]$_.Trim() }
                        & "$scriptDir\alati\Scan-RemotePorts.ps1" -HostName $hostName -Ports $portsArray
                    }
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                & "$scriptDir\alati\Get-ActiveConnectionsExecutable.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 3: Fajlovi i tekst
function Show-SubMenu3 {
    do {
        Show-Header -Title "RAD SA FAJLOVIMA I TEKSTOM"
        Write-Host "1. Pronađi najveće fajlove i foldere na disku" -ForegroundColor Magenta
        Write-Host "2. Napravi pametni bekap projekta (ZIP)" -ForegroundColor Magenta
        Write-Host "3. Prati izmene u folderu u realnom vremenu" -ForegroundColor Magenta
        Write-Host "4. Pretraži tekst u fajlovima (Grep)" -ForegroundColor Magenta
        Write-Host "5. Masovno preimenovanje fajlova" -ForegroundColor Magenta
        Write-Host "6. Prikaži/Sakrij sakrivene fajlove u Exploreru" -ForegroundColor Magenta
        Write-Host "7. Kreiraj simbolički link (Symlink/Junction)" -ForegroundColor Magenta
        Write-Host "8. Uporedi sadržaj dva direktorijuma rekurzivno" -ForegroundColor Magenta
        Write-Host "9. Pronađi i obriši duple fajlove (SHA-256)" -ForegroundColor Magenta
        Write-Host "10. Prati i nadgledaj integritet fajlova" -ForegroundColor Magenta
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $path = Read-Host "Unesite putanju za skeniranje (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $count = Read-Host "Broj stavki za prikaz (Enter za 20)"
                if ([string]::IsNullOrWhitespace($count)) { $count = 20 }
                & "$scriptDir\alati\Find-LargeFiles.ps1" -Path $path -TopCount [int]$count
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $src = Read-Host "Unesite putanju foldera koji bekapujete"
                $dest = Read-Host "Unesite odredišnu putanju (Enter za trenutni)"
                if (-not [string]::IsNullOrWhitespace($src)) {
                    if ([string]::IsNullOrWhitespace($dest)) { $dest = Get-Location }
                    & "$scriptDir\alati\Backup-Project.ps1" -SourcePath $src -DestinationPath $dest
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                $path = Read-Host "Unesite putanju foldera za praćenje (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Watch-Folder.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                $path = Read-Host "Unesite putanju za pretragu (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $query = Read-Host "Unesite tekst koji tražite"
                $filter = Read-Host "Putanja filtera (npr. *.js - Enter za *)"
                if ([string]::IsNullOrWhitespace($filter)) { $filter = "*" }
                if (-not [string]::IsNullOrWhitespace($query)) {
                    & "$scriptDir\alati\Search-TextInFiles.ps1" -Path $path -Query $query -Filter $filter
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $path = Read-Host "Putanja (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                Write-Host "`nIzaberite tip preimenovanja:"
                Write-Host "1. Dodaj prefiks"
                Write-Host "2. Dodaj sufiks"
                Write-Host "3. Zameni tekst"
                $ren = Read-Host "Izbor"
                if ($ren -eq "1") {
                    $prefix = Read-Host "Prefiks"
                    & "$scriptDir\alati\Rename-Files.ps1" -Path $path -Prefix $prefix
                } elseif ($ren -eq "2") {
                    $suffix = Read-Host "Sufiks"
                    & "$scriptDir\alati\Rename-Files.ps1" -Path $path -Suffix $suffix
                } elseif ($ren -eq "3") {
                    $oldTxt = Read-Host "Tekst za zamenu"
                    $newTxt = Read-Host "Novi tekst"
                    & "$scriptDir\alati\Rename-Files.ps1" -Path $path -ReplaceText $oldTxt -WithText $newTxt
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                & "$scriptDir\alati\Toggle-HiddenFiles.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $link = Read-Host "Unesite putanju novog linka"
                $target = Read-Host "Unesite putanju cilja"
                if (-not [string]::IsNullOrWhitespace($link) -and -not [string]::IsNullOrWhitespace($target)) {
                    & "$scriptDir\alati\Create-Symlink.ps1" -LinkPath $link -TargetPath $target
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                $pathA = Read-Host "Unesite putanju foldera A"
                $pathB = Read-Host "Unesite putanju foldera B"
                if (-not [string]::IsNullOrWhitespace($pathA) -and -not [string]::IsNullOrWhitespace($pathB)) {
                    & "$scriptDir\alati\Compare-Folders.ps1" -PathA $pathA -PathB $pathB
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "9" {
                $path = Read-Host "Putanja za skeniranje duplikata (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Find-DuplicateFiles.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                $path = Read-Host "Putanja za nadzor integriteta (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                Write-Host "`nIzaberite akciju:"
                Write-Host "1. Verifikacija integriteta (Proveri izmene)"
                Write-Host "2. Ažuriraj Baseline bazu heševa"
                $intChoice = Read-Host "Izbor"
                if ($intChoice -eq "2") {
                    & "$scriptDir\alati\Watch-FileIntegrity.ps1" -Path $path -UpdateBaseline
                } else {
                    & "$scriptDir\alati\Watch-FileIntegrity.ps1" -Path $path
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 4: Programiranje i ostalo
function Show-SubMenu4 {
    do {
        Show-Header -Title "PROGRAMIRANJE I OSTALE SKRIPTE"
        Write-Host "1. Generiši sigurnu lozinku (kriptografski)" -ForegroundColor Yellow
        Write-Host "2. Masovna konverzija i resize slika" -ForegroundColor Yellow
        Write-Host "3. Šifruj / Dešifruj fajl (AES-256)" -ForegroundColor Yellow
        Write-Host "4. Upravljaj Windows Hosts fajlom" -ForegroundColor Yellow
        Write-Host "5. Ugasi procese po nazivu" -ForegroundColor Yellow
        Write-Host "6. Konvertuj formate podataka (CSV/JSON/XML)" -ForegroundColor Yellow
        Write-Host "7. Prati log fajlove u realnom vremenu sa bojama (Tail)" -ForegroundColor Yellow
        Write-Host "8. Upravljaj Environment promenljivim i PATH-om" -ForegroundColor Yellow
        Write-Host "9. Pošalji Windows Toast obaveštenje" -ForegroundColor Yellow
        Write-Host "10. Upravljaj zakazanim zadacima (Task Scheduler)" -ForegroundColor Yellow
        Write-Host "11. Generiši QR kod za tekst ili URL" -ForegroundColor Yellow
        Write-Host "12. Uključi / Isključi Windows Developer Mode" -ForegroundColor Yellow
        Write-Host "13. Upravljaj Windows servisima interaktivno" -ForegroundColor Yellow
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $len = Read-Host "Dužina lozinke (Enter za 16)"
                if ([string]::IsNullOrWhitespace($len)) { $len = 16 }
                & "$scriptDir\alati\Generate-Password.ps1" -Length [int]$len
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $path = Read-Host "Putanja sa slikama (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $fmt = Read-Host "Ciljni format (png, jpg, gif - Enter za png)"
                if ([string]::IsNullOrWhitespace($fmt)) { $fmt = "png" }
                $width = Read-Host "Širina u px za resize (Enter za zadržavanje)"
                if ([string]::IsNullOrWhitespace($width)) {
                    & "$scriptDir\alati\Convert-ImageFormat.ps1" -Path $path -TargetFormat $fmt
                } else {
                    & "$scriptDir\alati\Convert-ImageFormat.ps1" -Path $path -TargetFormat $fmt -Width [int]$width
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                $file = Read-Host "Unesite putanju do fajla"
                $mode = Read-Host "1 za Šifrovanje, 2 za Dešifrovanje"
                if ($mode -eq "1") {
                    & "$scriptDir\alati\Encrypt-DecryptFile.ps1" -FilePath $file -Encrypt
                } elseif ($mode -eq "2") {
                    & "$scriptDir\alati\Encrypt-DecryptFile.ps1" -FilePath $file -Decrypt
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                Write-Host "`n1. Prikaži Hosts, 2. Dodaj unos, 3. Ukloni unos"
                $opt = Read-Host "Izbor"
                if ($opt -eq "1") {
                    & "$scriptDir\alati\Manage-HostsFile.ps1" -ShowOnly
                } elseif ($opt -eq "2") {
                    $ip = Read-Host "IP"
                    $domain = Read-Host "Domen"
                    & "$scriptDir\alati\Manage-HostsFile.ps1" -Add -IPAddress $ip -HostName $domain
                } elseif ($opt -eq "3") {
                    $domain = Read-Host "Domen"
                    & "$scriptDir\alati\Manage-HostsFile.ps1" -Remove -HostName $domain
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $name = Read-Host "Naziv procesa za gašenje (npr. chrome)"
                if (-not [string]::IsNullOrEmpty($name)) {
                    & "$scriptDir\alati\Kill-ProcessByName.ps1" -ProcessName $name
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                $file = Read-Host "Unesite putanju do ulaznog fajla"
                $fmt = Read-Host "Ciljni format (csv, json, xml)"
                if (-not [string]::IsNullOrEmpty($file) -and -not [string]::IsNullOrEmpty($fmt)) {
                    & "$scriptDir\alati\Convert-DataFormat.ps1" -InputFile $file -TargetFormat $fmt
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $file = Read-Host "Unesite putanju do log fajla"
                if (-not [string]::IsNullOrEmpty($file)) {
                    & "$scriptDir\alati\Monitor-LogTail.ps1" -LogFile $file
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                & "$scriptDir\alati\Manage-EnvironmentVariables.ps1"
            }
            "9" {
                $title = Read-Host "Naslov obaveštenja"
                $msg = Read-Host "Tekst poruke"
                if (-not [string]::IsNullOrEmpty($title) -and -not [string]::IsNullOrEmpty($msg)) {
                    & "$scriptDir\alati\Send-ToastNotification.ps1" -Title $title -Message $msg
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                & "$scriptDir\alati\Schedule-TaskHelper.ps1"
            }
            "11" {
                $text = Read-Host "Unesite tekst ili URL za QR kod"
                if (-not [string]::IsNullOrEmpty($text)) {
                    & "$scriptDir\alati\Create-QrCodeText.ps1" -Text $text
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" {
                & "$scriptDir\alati\Toggle-WindowsDeveloperMode.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "13" {
                & "$scriptDir\alati\Manage-WindowsServicesInteractive.ps1"
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 5: Git i Developer alati (41-55)
function Show-SubMenu5 {
    do {
        Show-Header -Title "GIT I DEVELOPER ALATI"
        Write-Host "1. Obriši lokalne Git grane spojene u master/main" -ForegroundColor Green
        Write-Host "2. Prikaz Git grafikona commit-a sa autorima" -ForegroundColor Green
        Write-Host "3. Status Git izmena na svim projektima u folderu" -ForegroundColor Green
        Write-Host "4. Pokretanje lokalnog mock HTTP servera za test" -ForegroundColor Green
        Write-Host "5. Validacija JSON strukture i grešaka" -ForegroundColor Green
        Write-Host "6. Interaktivno testiranje regularnih izraza (Regex)" -ForegroundColor Green
        Write-Host "7. Konverzija JSON u YAML (i obrnuto)" -ForegroundColor Green
        Write-Host "8. Generisanje testnih lažnih podataka (mock data)" -ForegroundColor Green
        Write-Host "9. Brojanje linija koda po jezicima u projektu" -ForegroundColor Green
        Write-Host "10. Pretraga TODO/FIXME/BUG oznaka u kodu" -ForegroundColor Green
        Write-Host "11. Pokretanje VS Code, Docker-a i dev servera" -ForegroundColor Green
        Write-Host "12. Ekstrakcija jedinstvenih boja (#HEX) iz CSS/HTML" -ForegroundColor Green
        Write-Host "13. Enkodiranje / Dekodiranje URL stringova" -ForegroundColor Green
        Write-Host "14. Markdown (.md) preview u HTML" -ForegroundColor Green
        Write-Host "15. JWT Token Decoder (Offline)" -ForegroundColor Green
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                & "$scriptDir\alati\Git-CleanBranches.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $count = Read-Host "Broj commit-a za prikaz (Enter za 15)"
                if ([string]::IsNullOrWhitespace($count)) { $count = 15 }
                & "$scriptDir\alati\Git-VisualCommits.ps1" -Count [int]$count
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                $path = Read-Host "Putanja sa projektima (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Git-ProjectStatus.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                $port = Read-Host "Unesite port za server (Enter za 8085)"
                if ([string]::IsNullOrWhitespace($port)) { $port = 8085 }
                & "$scriptDir\alati\Start-LocalApiMock.ps1" -Port [int]$port
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $file = Read-Host "Putanja do JSON fajla"
                if (Test-Path $file) {
                    & "$scriptDir\alati\Test-JsonValidator.ps1" -JsonPath $file
                } else { Write-Host "Fajl ne postoji!" -ForegroundColor Red }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                & "$scriptDir\alati\Test-RegexMatcher.ps1"
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $file = Read-Host "Putanja do fajla (.json ili .yaml)"
                if (Test-Path $file) {
                    & "$scriptDir\alati\Convert-JsonToYaml.ps1" -FilePath $file
                } else { Write-Host "Fajl ne postoji!" -ForegroundColor Red }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                $count = Read-Host "Broj zapisa za generisanje (Enter za 50)"
                if ([string]::IsNullOrWhitespace($count)) { $count = 50 }
                $fmt = Read-Host "Format: json ili csv (Enter za json)"
                if ([string]::IsNullOrWhitespace($fmt)) { $fmt = "json" }
                & "$scriptDir\alati\Generate-MockData.ps1" -Count [int]$count -Format $fmt
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "9" {
                $path = Read-Host "Putanja koda (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Get-CodeLineCount.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                $path = Read-Host "Putanja projekta (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Search-CodeTodo.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "11" {
                $path = Read-Host "Putanja projekta (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $url = Read-Host "Lokalni URL za pretraživač (Enter za http://localhost:3000)"
                if ([string]::IsNullOrWhitespace($url)) { $url = "http://localhost:3000" }
                & "$scriptDir\alati\Start-DevEnvironment.ps1" -Path $path -LocalUrl $url
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" {
                $path = Read-Host "Putanja sa CSS/HTML fajlovima (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Get-WebColors.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "13" {
                $text = Read-Host "Unesite tekst za URL konverziju"
                $decode = Read-Host "Da li želite dekodiranje? (Y za Da, Enter za enkodiranje)"
                if ($decode.ToUpper() -eq "Y") {
                    & "$scriptDir\alati\Convert-UrlEncodeDecode.ps1" -Text $text -Decode
                } else {
                    & "$scriptDir\alati\Convert-UrlEncodeDecode.ps1" -Text $text
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "14" {
                $file = Read-Host "Putanja do .md fajla"
                if (Test-Path $file) {
                    & "$scriptDir\alati\Get-MarkdownPreview.ps1" -MarkdownFile $file
                } else { Write-Host "Fajl ne postoji!" -ForegroundColor Red }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "15" {
                $jwt = Read-Host "Unesite JWT token za dekodiranje"
                if (-not [string]::IsNullOrEmpty($jwt)) {
                    & "$scriptDir\alati\Test-JwtDecoder.ps1" -Token $jwt
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 6: Hardver i napredna dijagnostika (56-70)
function Show-SubMenu6 {
    do {
        Show-Header -Title "HARDVER I NAPREDNA DIJAGNOSTIKA"
        Write-Host "1. Očitavanje temperatura procesora (CPU)" -ForegroundColor Blue
        Write-Host "2. Prikaz verzije BIOS-a i serijskih brojeva ploče" -ForegroundColor Blue
        Write-Host "3. Detaljan izveštaj o RAM memoriji (brzina, slotovi)" -ForegroundColor Blue
        Write-Host "4. Prikaz PCI i PCIe uređaja" -ForegroundColor Blue
        Write-Host "5. Lista instaliranih drajvera na sistemu" -ForegroundColor Blue
        Write-Host "6. Provera dostupnih ažuriranja za drajvere" -ForegroundColor Blue
        Write-Host "7. Prikaz istorije priključivanih USB uređaja" -ForegroundColor Blue
        Write-Host "8. Detaljne specifikacije audio uređaja" -ForegroundColor Blue
        Write-Host "9. Test ekrana za pronalazak mrtvih piksela" -ForegroundColor Blue
        Write-Host "10. Telemetrija grafičke kartice (GPU)" -ForegroundColor Blue
        Write-Host "11. Generisanje izveštaja o potrošnji energije (Power Report)" -ForegroundColor Blue
        Write-Host "12. Prikaz brzine i statusa mrežnih kartica" -ForegroundColor Blue
        Write-Host "13. Interaktivni test tastera na tastaturi" -ForegroundColor Blue
        Write-Host "14. Informacije o SATA/NVMe kontrolerima" -ForegroundColor Blue
        Write-Host "15. Brz prikaz sistemskih serijskih brojeva" -ForegroundColor Blue
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" { & "$scriptDir\alati\Get-CpuTemperature.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "2" { & "$scriptDir\alati\Get-BiosInfo.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "3" { & "$scriptDir\alati\Get-RamDetails.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "4" { & "$scriptDir\alati\Get-PciDevices.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "5" { & "$scriptDir\alati\Get-InstalledDrivers.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "6" { & "$scriptDir\alati\Check-DriverUpdates.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "7" { & "$scriptDir\alati\Get-UsbHistory.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "8" { & "$scriptDir\alati\Get-AudioDevices.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "9" { & "$scriptDir\alati\Test-MonitorPixels.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "10" { & "$scriptDir\alati\Get-GpuTelemetry.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "11" { & "$scriptDir\alati\Get-SystemPowerReport.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "12" { & "$scriptDir\alati\Get-NetworkAdapterSpeed.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "13" { & "$scriptDir\alati\Check-KeyboardKeys.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "14" { & "$scriptDir\alati\Get-StorageControllerInfo.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "15" { & "$scriptDir\alati\Get-SystemSerialNumbers.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 7: Sigurnost i mrežna odbrana (71-85)
function Show-SubMenu7 {
    do {
        Show-Header -Title "SIGURNOST I MREŽNA ODBRANA"
        Write-Host "1. Upravljanje pravilima u Windows Firewall-u" -ForegroundColor Red
        Write-Host "2. Revizija lokalnih korisničkih naloga i grupa" -ForegroundColor Red
        Write-Host "3. Praćenje izmena u Windows Registru u realnom vremenu" -ForegroundColor Red
        Write-Host "4. Zaštita (sakrivanje) izabranog foldera" -ForegroundColor Red
        Write-Host "5. Pregled deljenih foldera u mreži (Open Shares)" -ForegroundColor Red
        Write-Host "6. Analiza i provera jačine lozinke" -ForegroundColor Red
        Write-Host "7. Pregled istorije i zakrpa Windows Update-a" -ForegroundColor Red
        Write-Host "8. Provera statusa Windows Defender zaštite" -ForegroundColor Red
        Write-Host "9. Prikaz i brisanje (flush) DNS keša" -ForegroundColor Red
        Write-Host "10. Brza blokada određene IP adrese u Firewall-u" -ForegroundColor Red
        Write-Host "11. Masovna kalkulacija i provera heševa fajlova" -ForegroundColor Red
        Write-Host "12. Prikaz aktivnih korisničkih sesija (lokalno/RDP)" -ForegroundColor Red
        Write-Host "13. Bezbednosna provera Startup pokretačkih lokacija" -ForegroundColor Red
        Write-Host "14. Generisanje SSH ključeva (ED25519)" -ForegroundColor Red
        Write-Host "15. Test VPN/DNS curenja podataka (DNS Leak)" -ForegroundColor Red
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" { & "$scriptDir\alati\Manage-FirewallRules.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "2" { & "$scriptDir\alati\Audit-LocalUsers.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "3" {
                $key = Read-Host "Unesite Registry putanju za praćenje (npr. HKCU:\Software)"
                if (-not [string]::IsNullOrEmpty($key)) {
                    & "$scriptDir\alati\Watch-RegistryChanges.ps1" -RegistryPath $key
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                $path = Read-Host "Unesite putanju foldera za zaključavanje"
                if (Test-Path $path) {
                    & "$scriptDir\alati\Lock-FolderLock.ps1" -FolderPath $path
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" { & "$scriptDir\alati\Audit-OpenShares.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "6" {
                $pass = Read-Host "Unesite lozinku za proveru jačine"
                if ($pass) {
                    & "$scriptDir\alati\Test-PasswordStrength.ps1" -Password $pass
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" { & "$scriptDir\alati\Get-WindowsUpdatesStatus.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "8" { & "$scriptDir\alati\Scan-AntivirusStatus.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "9" { & "$scriptDir\alati\Get-DnsCache.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "10" {
                $ip = Read-Host "Unesite IP adresu za blokiranje"
                if ($ip) {
                    & "$scriptDir\alati\Block-IpAddress.ps1" -IPAddress $ip
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "11" {
                $path = Read-Host "Putanja sa fajlovima (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $alg = Read-Host "Algoritam: SHA256 ili MD5 (Enter za SHA256)"
                if ([string]::IsNullOrWhitespace($alg)) { $alg = "SHA256" }
                & "$scriptDir\alati\Check-FileHashesBulk.ps1" -Path $path -Algorithm $alg
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" { & "$scriptDir\alati\Get-ActiveSessions.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "13" { & "$scriptDir\alati\Audit-StartupPaths.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "14" {
                $email = Read-Host "Unesite Vaš email za komentar ključa"
                if ($email) {
                    & "$scriptDir\alati\Generate-SshKeys.ps1" -CommentEmail $email
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "15" { & "$scriptDir\alati\Test-DnsLeak.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 8: Mreža, Web i DNS alati (86-100)
function Show-SubMenu8 {
    do {
        Show-Header -Title "MREŽA, WEB I DNS ALATI"
        Write-Host "1. Preuzimanje WHOIS podataka o domenu" -ForegroundColor Cyan
        Write-Host "2. Čitanje svih DNS zapisa za domen (A, MX, TXT...)" -ForegroundColor Cyan
        Write-Host "3. IP mrežni kalkulator (Subnet Calculator)" -ForegroundColor Cyan
        Write-Host "4. Kreiranje SSH tunela (Port Forwarding)" -ForegroundColor Cyan
        Write-Host "5. cURL zamena: slanje HTTP zahteva (GET/POST/PUT...)" -ForegroundColor Cyan
        Write-Host "6. Testiranje i benchmark brzine DNS servera" -ForegroundColor Cyan
        Write-Host "7. Detaljna geolokacija javne IP adrese" -ForegroundColor Cyan
        Write-Host "8. Prikaz portova koji čekaju vezu (Listening Ports)" -ForegroundColor Cyan
        Write-Host "9. Kontinuirani vizuelni ping sa alarmom na prekid" -ForegroundColor Cyan
        Write-Host "10. Pronalaženje proizvođača na osnovu MAC adrese" -ForegroundColor Cyan
        Write-Host "11. Magic Packet slanje za paljenje računara (Wake On LAN)" -ForegroundColor Cyan
        Write-Host "12. Mrežni skener celog subneta na aktivnim IP adresama" -ForegroundColor Cyan
        Write-Host "13. Prikaz kompletnog lanca SSL sertifikata za sajt" -ForegroundColor Cyan
        Write-Host "14. Test stabilnosti internet veze i merenje džiter-a" -ForegroundColor Cyan
        Write-Host "15. Prikaz tablice rutiranja (Route Print)" -ForegroundColor Cyan
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $domain = Read-Host "Unesite naziv domena (npr. google.com)"
                if ($domain) { & "$scriptDir\alati\Get-WhoisInfo.ps1" -DomainName $domain }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $domain = Read-Host "Unesite naziv domena (npr. google.com)"
                if ($domain) { & "$scriptDir\alati\Get-DnsRecords.ps1" -DomainName $domain }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                $ip = Read-Host "IP adresa (npr. 192.168.1.50)"
                $mask = Read-Host "Maska podmreže (npr. 255.255.255.0)"
                if ($ip -and $mask) {
                    & "$scriptDir\alati\Calculate-Subnet.ps1" -IPAddress $ip -SubnetMask $mask
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                $srv = Read-Host "SSH server"
                $user = Read-Host "SSH korisnik"
                $lPort = Read-Host "Lokalni port"
                $rHost = Read-Host "Udaljeni host"
                $rPort = Read-Host "Udaljeni port"
                if ($srv -and $user -and $lPort -and $rHost -and $rPort) {
                    & "$scriptDir\alati\Start-SshTunnel.ps1" -SshServer $srv -SshUser $user -LocalPort [int]$lPort -RemoteHost $rHost -RemotePort [int]$rPort
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $url = Read-Host "URL adresa"
                $method = Read-Host "Metoda: GET, POST, PUT, DELETE (Enter za GET)"
                if ([string]::IsNullOrWhitespace($method)) { $method = "GET" }
                $body = if ($method -match "POST|PUT") { Read-Host "JSON Body podaci" } else { "" }
                if ($url) {
                    & "$scriptDir\alati\Send-HttpRequest.ps1" -Url $url -Method $method -Body $body
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" { & "$scriptDir\alati\Benchmark-DnsServers.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "7" { & "$scriptDir\alati\Get-PublicIpGeo.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "8" { & "$scriptDir\alati\Check-PortListen.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "9" {
                $hostName = Read-Host "Unesite host za ping (npr. 8.8.8.8)"
                if ($hostName) { & "$scriptDir\alati\Watch-PingStatus.ps1" -HostName $hostName }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                $mac = Read-Host "Unesite MAC adresu (npr. 00:1A:2B)"
                if ($mac) { & "$scriptDir\alati\Get-MacVendor.ps1" -MacAddress $mac }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "11" {
                $mac = Read-Host "Ciljna MAC adresa (npr. 00-11-22-33-44-55)"
                if ($mac) { & "$scriptDir\alati\Convert-WakeOnLan.ps1" -MacAddress $mac }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" {
                $sub = Read-Host "Subnet opseg za skeniranje (npr. 192.168.1)"
                $port = Read-Host "Port za proveru (npr. 80)"
                if ($sub -and $port) {
                    & "$scriptDir\alati\Test-SubnetHosts.ps1" -SubnetPrefix $sub -Port [int]$port
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "13" {
                $hostName = Read-Host "Unesite domen (npr. github.com)"
                if ($hostName) { & "$scriptDir\alati\Get-SslCertChain.ps1" -HostName $hostName }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "14" { & "$scriptDir\alati\Test-InternetConnectionStability.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "15" { & "$scriptDir\alati\Get-RoutePrint.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 9: Rad sa medijima i fajl automatizacija (101-115)
function Show-SubMenu9 {
    do {
        Show-Header -Title "MEDIJI I FAJL AUTOMATIZACIJA"
        Write-Host "1. Spajanje više PDF dokumenata u jedan zajednički" -ForegroundColor Magenta
        Write-Host "2. Konverzija audio fajlova (WAV u MP3 i sl.)" -ForegroundColor Magenta
        Write-Host "3. FFmpeg video kompresija na zadatu veličinu" -ForegroundColor Magenta
        Write-Host "4. Masovna promena kodiranja fajlova (u UTF-8)" -ForegroundColor Magenta
        Write-Host "5. Pronalaženje dupliranih foldera sa identičnim fajlovima" -ForegroundColor Magenta
        Write-Host "6. Rekurzivno brisanje praznih foldera sa diska" -ForegroundColor Magenta
        Write-Host "7. Sinhronizacija fajlova sa Cloud folderima" -ForegroundColor Magenta
        Write-Host "8. Analiza zauzeća prostora po ekstenzijama fajlova" -ForegroundColor Magenta
        Write-Host "9. Generisanje vizuelnog stabla direktorijuma (Tree View)" -ForegroundColor Magenta
        Write-Host "10. Deljenje ogromnog log/tekstualnog fajla na manje delove" -ForegroundColor Magenta
        Write-Host "11. Pretvaranje CSV fajla u HTML tabelu sa CSS stilom" -ForegroundColor Magenta
        Write-Host "12. Uklanjanje neispravnih prečica (.lnk) sa diska" -ForegroundColor Magenta
        Write-Host "13. Brzi bekap Desktop, Documents i Downloads foldera" -ForegroundColor Magenta
        Write-Host "14. Pretvaranje slika u crno-belu (Grayscale) varijantu" -ForegroundColor Magenta
        Write-Host "15. Napredna pretraga fajlova po naprednim džoker filterima" -ForegroundColor Magenta
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $files = Read-Host "Putanje PDF fajlova odvojene zarezom"
                $out = Read-Host "Izlazni PDF fajl"
                if ($files -and $out) {
                    $arr = $files.Split(",") | ForEach-Object { $_.Trim() }
                    & "$scriptDir\alati\Merge-PdfFiles.ps1" -Files $arr -OutputFile $out
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $file = Read-Host "Putanja do audio fajla"
                $out = Read-Host "Izlazni fajl"
                if ($file -and $out) {
                    & "$scriptDir\alati\Convert-AudioFormat.ps1" -InputFile $file -OutputFile $out
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" {
                $file = Read-Host "Putanja do video fajla"
                $size = Read-Host "Ciljna veličina u MB (Enter za 25MB)"
                if ([string]::IsNullOrWhitespace($size)) { $size = 25 }
                if ($file) {
                    & "$scriptDir\alati\Compress-VideoFfmpeg.ps1" -InputFile $file -TargetSizeMB [int]$size
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "4" {
                $path = Read-Host "Putanja foldera (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $filter = Read-Host "Filter ekstenzije (npr. *.txt - Enter za *)"
                if ([string]::IsNullOrWhitespace($filter)) { $filter = "*" }
                & "$scriptDir\alati\Convert-TextEncoding.ps1" -Path $path -Filter $filter
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $path = Read-Host "Putanja za pretragu (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Find-DuplicateFolders.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                $path = Read-Host "Putanja za brisanje (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Clean-EmptyFolders.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $src = Read-Host "Lokalni folder"
                $cloud = Read-Host "Putanja OneDrive/GoogleDrive/Dropbox foldera"
                if ($src -and $cloud) {
                    & "$scriptDir\alati\Backup-FilesToCloud.ps1" -LocalFolder $src -CloudFolder $cloud
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                $path = Read-Host "Putanja (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Get-FileExtensionStats.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "9" {
                $path = Read-Host "Putanja (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $depth = Read-Host "Maksimalna dubina stabla (Enter za 3)"
                if ([string]::IsNullOrWhitespace($depth)) { $depth = 3 }
                & "$scriptDir\alati\Create-DirectoryTree.ps1" -Path $path -MaxDepth [int]$depth
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                $file = Read-Host "Putanja do ogromnog fajla"
                $lines = Read-Host "Broj linija po fajlu (Enter za 50000)"
                if ([string]::IsNullOrWhitespace($lines)) { $lines = 50000 }
                if (Test-Path $file) {
                    & "$scriptDir\alati\Split-LargeFile.ps1" -FilePath $file -LinesPerFile [int]$lines
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "11" {
                $file = Read-Host "Putanja do CSV fajla"
                if (Test-Path $file) {
                    & "$scriptDir\alati\Convert-CsvToHtmlTable.ps1" -CsvPath $file
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" {
                $path = Read-Host "Putanja za skeniranje (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                & "$scriptDir\alati\Find-BrokenShortcuts.ps1" -Path $path
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "13" {
                $dest = Read-Host "Odredišna putanja bekapa (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($dest)) { $dest = Get-Location }
                & "$scriptDir\alati\Backup-ProfileFolders.ps1" -DestPath $dest
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "14" {
                $file = Read-Host "Putanja do slike"
                if (Test-Path $file) {
                    & "$scriptDir\alati\Convert-ImageToGrayScale.ps1" -ImagePath $file
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "15" {
                $path = Read-Host "Putanja pretrage (Enter za trenutni)"
                if ([string]::IsNullOrWhitespace($path)) { $path = Get-Location }
                $pat = Read-Host "Naziv/Filter pretrage (npr. *izvestaj*)"
                $minKb = Read-Host "Min veličina u KB (Enter za 0)"
                if ([string]::IsNullOrWhitespace($minKb)) { $minKb = 0 }
                if ($pat) {
                    & "$scriptDir\alati\Search-FilenameWildcard.ps1" -Path $path -Pattern $pat -MinSizeKb [long]$minKb
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 10: Registry, OS i Windows optimizacija (116-130)
function Show-SubMenu10 {
    do {
        Show-Header -Title "REGISTRY, OS I WINDOWS OPTIMIZACIJA"
        Write-Host "1. Upravljanje programima u Startup-u" -ForegroundColor Yellow
        Write-Host "2. Blokiranje Windows telemetrije i praćenja aktivnosti" -ForegroundColor Yellow
        Write-Host "3. Privremeno zaustavljanje / pokretanje Windows Update servisa" -ForegroundColor Yellow
        Write-Host "4. Pokretanje naprednog čišćenja diska (Cleanmgr)" -ForegroundColor Yellow
        Write-Host "5. Lista svih instaliranih programa na računaru" -ForegroundColor Yellow
        Write-Host "6. Interaktivni pomoćnik za deinstalaciju softvera" -ForegroundColor Yellow
        Write-Host "7. Prekidač za sprečavanje odlaska računara u sleep mod (Keep-Alive)" -ForegroundColor Yellow
        Write-Host "8. Uključivanje/Isključivanje opcionih Windows komponenti (WSL, IIS)" -ForegroundColor Yellow
        Write-Host "9. Registarske optimizacije za ubrzanje Windows Explorera" -ForegroundColor Yellow
        Write-Host "10. Izvlačenje originalnog licencnog Windows ključa (BIOS/Registry)" -ForegroundColor Yellow
        Write-Host "11. Izvoz (bekap) određene grane registra u .reg fajl" -ForegroundColor Yellow
        Write-Host "12. Čišćenje keša i istorije pretraživača (Chrome, Edge, Firefox)" -ForegroundColor Yellow
        Write-Host "13. Podešavanje i optimizacija virtuelne memorije (Pagefile)" -ForegroundColor Yellow
        Write-Host "14. Prikaz BSOD i kritičnih sistemskih grešaka (poslednjih 30 dana)" -ForegroundColor Yellow
        Write-Host "15. Zakazivanje automatskog restartovanja računara" -ForegroundColor Yellow
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" { & "$scriptDir\alati\Manage-StartupApps.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "2" { & "$scriptDir\alati\Block-WindowsTelemetry.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "3" { & "$scriptDir\alati\Toggle-WindowsUpdates.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "4" { & "$scriptDir\alati\Clean-DiskCleanupAdvanced.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "5" { & "$scriptDir\alati\Get-InstalledSoftware.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "6" { & "$scriptDir\alati\Uninstall-SoftwareHelper.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "7" {
                $ka = Read-Host "Da li želite da aktivirate Keep Awake simulaciju tastera? (Y/N)"
                if ($ka.ToUpper() -eq "Y") {
                    & "$scriptDir\alati\Toggle-SleepSettings.ps1" -KeepAlive
                } else {
                    & "$scriptDir\alati\Toggle-SleepSettings.ps1"
                }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" { & "$scriptDir\alati\Manage-WindowsFeatures.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "9" { & "$scriptDir\alati\Optimize-WindowsExplorer.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "10" { & "$scriptDir\alati\Get-WindowsLicenseKey.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "11" {
                $reg = Read-Host "Registry putanja (npr. HKCU:\Software\MyKey)"
                if ($reg) { & "$scriptDir\alati\Backup-RegistryBranch.ps1" -RegPath $reg }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "12" { & "$scriptDir\alati\Clean-BrowserCache.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "13" { & "$scriptDir\alati\Toggle-VirtualMemory.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "14" { & "$scriptDir\alati\Get-SystemErrorLogs.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "15" { & "$scriptDir\alati\Manage-ScheduledRestarts.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
        }
    } while ($subChoice -ne "0")
}

# Sub-Menu 11: Baze podataka, Keš i Taskovi (131-140)
function Show-SubMenu11 {
    do {
        Show-Header -Title "BAZE PODATAKA, KEŠ I TASKOVI"
        Write-Host "1. Bekap MySQL/MariaDB baze podataka" -ForegroundColor Green
        Write-Host "2. Bekap PostgreSQL baze podataka" -ForegroundColor Green
        Write-Host "3. Monitor Redis keš servera i interaktivni brisač" -ForegroundColor Green
        Write-Host "4. Izvršavanje SQL upita nad SQLite bazom" -ForegroundColor Green
        Write-Host "5. Bekap MongoDB kolekcija pomoću mongodump" -ForegroundColor Green
        Write-Host "6. Testiranje konekcionih stringova za SQL/MySQL/Postgres" -ForegroundColor Green
        Write-Host "7. Skeniranje veličina svih baza na lokalnom SQL Serveru" -ForegroundColor Green
        Write-Host "8. Kalkulator sledećih izvršavanja Linux Cron izraza" -ForegroundColor Green
        Write-Host "9. Izvršavanje upita nad lokalnim Microsoft SQL Serverom" -ForegroundColor Green
        Write-Host "10. Periodična sinhronizacija dva foldera u realnom vremenu" -ForegroundColor Green
        Write-Host "0. Nazad u glavni meni" -ForegroundColor Red
        Write-Host "==================================================" -ForegroundColor Cyan
        
        $subChoice = Read-Host "Izaberite alat"
        switch ($subChoice) {
            "1" {
                $db = Read-Host "Naziv MySQL baze"
                $user = Read-Host "Korisnik (Enter za root)"
                if ([string]::IsNullOrWhitespace($user)) { $user = "root" }
                $pass = Read-Host "Lozinka"
                if ($db) { & "$scriptDir\alati\Backup-DatabaseMySQL.ps1" -DbName $db -Username $user -Password $pass }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "2" {
                $db = Read-Host "Naziv PostgreSQL baze"
                $user = Read-Host "Korisnik (Enter za postgres)"
                if ([string]::IsNullOrWhitespace($user)) { $user = "postgres" }
                if ($db) { & "$scriptDir\alati\Backup-DatabasePostgreSQL.ps1" -DbName $db -Username $user }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "3" { & "$scriptDir\alati\Monitor-RedisInteractive.ps1"; Read-Host "`nPritisnite Enter za nastavak..." }
            "4" {
                $db = Read-Host "Putanja do SQLite baze"
                $sql = Read-Host "SQL upit"
                if ($db -and $sql) { & "$scriptDir\alati\Query-SqliteDatabase.ps1" -DbPath $db -Query $sql }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "5" {
                $db = Read-Host "Naziv MongoDB baze"
                if ($db) { & "$scriptDir\alati\Backup-MongoDatabase.ps1" -DbName $db }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "6" {
                $type = Read-Host "Tip baze (MSSQL, MySQL, Postgres)"
                $connStr = Read-Host "ConnectionString"
                if ($type -and $connStr) { & "$scriptDir\alati\Test-DatabaseConnection.ps1" -DbType $type -ConnectionString $connStr }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "7" {
                $srv = Read-Host "SQL Server Instanca (Enter za localhost)"
                if ([string]::IsNullOrWhitespace($srv)) { $srv = "localhost" }
                & "$scriptDir\alati\Monitor-DatabaseSize.ps1" -ServerInstance $srv
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "8" {
                $cron = Read-Host "Cron izraz (npr. */5 * * * *)"
                if ($cron) { & "$scriptDir\alati\Check-CronFormat.ps1" -CronExpression $cron }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "9" {
                $srv = Read-Host "SQL Server Instanca"
                $db = Read-Host "Baza podataka"
                $sql = Read-Host "SQL upit"
                if ($srv -and $db -and $sql) { & "$scriptDir\alati\Query-MssqlDatabase.ps1" -ServerInstance $srv -DbName $db -Query $sql }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
            "10" {
                $src = Read-Host "Izvorni folder"
                $dest = Read-Host "Odredišni folder"
                $sec = Read-Host "Interval u sekundama (Enter za 60)"
                if ([string]::IsNullOrWhitespace($sec)) { $sec = 60 }
                if ($src -and $dest) { & "$scriptDir\alati\Sync-DirectoriesInterval.ps1" -SourcePath $src -DestinationPath $dest -IntervalSeconds [int]$sec }
                Read-Host "`nPritisnite Enter za nastavak..."
            }
        }
    } while ($subChoice -ne "0")
}

# Glavna petlja aplikacije
do {
    Show-MainMenu
    $choice = Read-Host "Unesite Vaš izbor"
    
    switch ($choice) {
        "1" { Show-SubMenu1 }
        "2" { Show-SubMenu2 }
        "3" { Show-SubMenu3 }
        "4" { Show-SubMenu4 }
        "5" { Show-SubMenu5 }
        "6" { Show-SubMenu6 }
        "7" { Show-SubMenu7 }
        "8" { Show-SubMenu8 }
        "9" { Show-SubMenu9 }
        "10" { Show-SubMenu10 }
        "11" { Show-SubMenu11 }
        "0" {
            Write-Host "`nDoviđenja! Hvala što ste koristili Windows Utility Toolkit." -ForegroundColor Yellow
            break
        }
    }
} while ($choice -ne "0")