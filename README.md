# Korisne Windows PowerShell Skripte (Kolekcija od 140 alata)

**Autor: o0o0o0o**

Ovaj repozitorijum sadrži sveobuhvatnu kolekciju od **140 univerzalnih i robusnih PowerShell skripti** koje olakšavaju rad programerima, sistemskim administratorima i naprednim korisnicima na Windows platformi. Sve skripte su optimizovane za prikaz srpskih latiničnih diacritika (`č, ć, š, ž, đ`) i sadrže ugrađenu pomoć.

## Kako pokrenuti?

PowerShell po podrazumevanim podešavanjima blokira pokretanje skripti radi bezbednosti. Da biste koristili ovaj alat, potrebno je da omogućite pokretanje lokalnih skripti.

### Korak 1: Dozvolite pokretanje skripti (jednokratno)

1. Otvorite **PowerShell kao Administrator** (Desni klik na Start -> Terminal (Administrator) ili PowerShell (Administrator)).
2. Izvršite sledeću komandu:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
   ```

### Korak 2: Pokrenite glavni interaktivni meni

1. Otvorite običan PowerShell i pozicionirajte se u ovaj folder:
   ```powershell
   cd d:\ProjektiApp\skripte
   ```
2. Pokrenite interaktivni pokretač:
   ```powershell
   .\Start-Menu.ps1
   ```

---

## Pregled Skripti po Kategorijama (1-140)

### 1. Sistemsko čišćenje i optimizacija (1-8)
*   **`Clean-NodeProjects.ps1`** - Rekurzivno čišćenje `node_modules`, `dist`, `.next` i build keševa.
*   **`Clean-WindowsTemp.ps1`** - Čišćenje privremenih sistemskih fajlova, logova i kante za smeće.
*   **`Get-SystemSpecs.ps1`** - Hardverske specifikacije računara i verzije programerskih alata.
*   **`Get-BatteryStatus.ps1`** - Analiza zdravlja baterije laptopa (kapacitet i ciklusi).
*   **`Check-DiskHealthSMART.ps1`** - SMART dijagnostika diskova i predikcija kvarova.
*   **`Monitor-ResourcesDashboard.ps1`** - Real-time terminalski dashboard za CPU, RAM, Disk i Mrežu.
*   **`Get-SystemUptimeHistory.ps1`** - Istorija rada računara, restarta i rušenja u poslednjih 30 dana.
*   **`Clean-UnusedDocker.ps1`** - Čišćenje Docker kontejnera, starih slika i volumena.

### 2. Mrežni alati i SSL (9-16)
*   **`Free-Port.ps1`** - Pretraga i gašenje procesa na zauzetom portu.
*   **`Check-WebsiteStatus.ps1`** - Provera HTTP statusa i SSL sertifikata (preostali dani).
*   **`Check-InternetSpeed.ps1`** - Dijagnostika pinga, gubitka paketa i merenje brzine preuzimanja.
*   **`Get-NetworkDetails.ps1`** - Prikaz lokalnih adaptera i spoljne IP adrese sa ISP/lokacijom.
*   **`Scan-LocalNetwork.ps1`** - Skeniranje svih aktivnih uređaja u lokalnoj mreži (ARP sken).
*   **`Generate-LocalSslCert.ps1`** - Pravljenje samopotpisanog SSL-a za lokalni razvoj i uvoz u Trusted Root.
*   **`Scan-RemotePorts.ps1`** - Provera otvorenih mrežnih portova na bilo kom serveru.
*   **`Get-ActiveConnectionsExecutable.ps1`** - Prikaz aktivnih mrežnih veza grupisanih po procesima.

### 3. Rad sa fajlovima i tekstom (17-26)
*   **`Find-LargeFiles.ps1`** - Pronalaženje najvećih fajlova i foldera na disku.
*   **`Backup-Project.ps1`** - Pametno bekapovanje u ZIP arhivu uz preskakanje teških foldera.
*   **`Watch-Folder.ps1`** - Praćenje promena u folderu u realnom vremenu.
*   **`Search-TextInFiles.ps1`** - Brza pretraga teksta kroz fajlove (Grep) uz pametno filtriranje.
*   **`Rename-Files.ps1`** - Masovno i pametno preimenovanje fajlova.
*   **`Toggle-HiddenFiles.ps1`** - Prekidač za skrivene fajlove i ekstenzije u Exploreru.
*   **`Create-Symlink.ps1`** - Kreiranje simboličkih linkova, junction-a i hardlinkova.
*   **`Compare-Folders.ps1`** - Rekurzivno poređenje sadržaja dva foldera.
*   **`Find-DuplicateFiles.ps1`** - Pronalaženje i brisanje dupliranih fajlova preko SHA-256 heša.
*   **`Watch-FileIntegrity.ps1`** - Praćenje nedozvoljenih modifikacija fajlova na osnovu heš baze.

### 4. Programerske i ostale skripte (27-40)
*   **`Generate-Password.ps1`** - Kriptografski generator lozinki sa kopiranjem u clipboard.
*   **`Convert-ImageFormat.ps1`** - Masovna konverzija slika i promena rezolucije (resize).
*   **`Encrypt-DecryptFile.ps1`** - AES-256 šifrovanje i dešifrovanje fajlova.
*   **`Manage-HostsFile.ps1`** - Dodavanje i brisanje unosa iz Windows `hosts` fajla.
*   **`Kill-ProcessByName.ps1`** - Gašenje procesa po nazivu sa prikazom RAM-a i PID-ova.
*   **`Convert-DataFormat.ps1`** - Konverter podataka između CSV, JSON i XML formata.
*   **`Monitor-LogTail.ps1`** - Praćenje log fajlova u realnom vremenu sa bojenjem ključnih reči.
*   **`Manage-EnvironmentVariables.ps1`** - Uređivač korisničkih i sistemskih promenljivih i PATH-a.
*   **`Send-ToastNotification.ps1`** - Slanje nativnih Windows Toast obaveštenja.
*   **`Schedule-TaskHelper.ps1`** - Upravljanje Windows Task Scheduler-om.
*   **`Create-QrCodeText.ps1`** - Generisanje QR koda za uneti tekst ili URL.
*   **`Toggle-WindowsDeveloperMode.ps1`** - Prekidač za Windows Developer Mode.
*   **`Manage-WindowsServicesInteractive.ps1`** - Kontrola pokretanja i gašenja Windows servisa.

### 5. Git i Developer alati (41-55)
*   **`Git-CleanBranches.ps1`** - Briše lokalne Git grane koje su već spojene u master/main.
*   **`Git-VisualCommits.ps1`** - Vizuelni prikaz Git istorije sa granama i autorima.
*   **`Git-ProjectStatus.ps1`** - Skeniranje svih foldera i prikaz neprijavljenih Git izmena.
*   **`Start-LocalApiMock.ps1`** - Pokretanje privremenog HTTP servera koji vraća lažne JSON odgovore.
*   **`Test-JsonValidator.ps1`** - Validacija ispravnosti JSON strukture sa detaljima grešaka.
*   **`Test-RegexMatcher.ps1`** - Interaktivno testiranje regularnih izraza (Regex).
*   **`Convert-JsonToYaml.ps1`** - Dvosmerna konverzija između JSON i YAML fajlova.
*   **`Generate-MockData.ps1`** - Generisanje testnih korisničkih podataka (ime, email, telefon).
*   **`Get-CodeLineCount.ps1`** - Brojanje linija koda u projektu, podeljeno po jezicima.
*   **`Search-CodeTodo.ps1`** - Pronalaženje `TODO`, `FIXME` i `BUG` komentara u projektu.
*   **`Start-DevEnvironment.ps1`** - Pokretanje VS Code-a, Docker-a i lokalnog servera.
*   **`Get-WebColors.ps1`** - Ekstrakcija svih heksadecimalnih (#HEX) boja iz kodnih fajlova.
*   **`Convert-UrlEncodeDecode.ps1`** - Enkodiranje i dekodiranje URL stringova.
*   **`Get-MarkdownPreview.ps1`** - Konverzija Markdown (.md) fajlova u lepe HTML stranice.
*   **`Test-JwtDecoder.ps1`** - Dekodiranje i analiza JSON Web Tokena (JWT) lokalno.

### 6. Hardver i napredna dijagnostika (56-70)
*   **`Get-CpuTemperature.ps1`** - Čitanje temperatura CPU jezgara i brzine ventilatora.
*   **`Get-BiosInfo.ps1`** - Prikaz detalja o matičnoj ploči, BIOS-u i hardverskim serijskim brojevima.
*   **`Get-RamDetails.ps1`** - Informacije o RAM modulima (proizvođač, tip, brzina, slotovi).
*   **`Get-PciDevices.ps1`** - Prikaz svih povezanih PCI i PCIe uređaja.
*   **`Get-InstalledDrivers.ps1`** - Lista instaliranih drajvera na Windows-u sa datumima.
*   **`Check-DriverUpdates.ps1`** - Provera dostupnosti novijih verzija drajvera na internetu.
*   **`Get-UsbHistory.ps1`** - Istorija svih USB uređaja koji su ikada bili priključeni.
*   **`Get-AudioDevices.ps1`** - Prikaz mikrofona, zvučnika i zvučnih adaptera na sistemu.
*   **`Test-MonitorPixels.ps1`** - Test ekrana u punim bojama za pronalaženje mrtvih piksela.
*   **`Get-GpuTelemetry.ps1`** - Prikaz temperature, modela i zauzeća memorije grafičke kartice.
*   **`Get-SystemPowerReport.ps1`** - Generisanje sistemskog izveštaja o potrošnji energije.
*   **`Get-NetworkAdapterSpeed.ps1`** - Prikaz maksimalne brzine mrežnih adaptera.
*   **`Check-KeyboardKeys.ps1`** - Interaktivni test pritisnutih tastera i njihovih kodova.
*   **`Get-StorageControllerInfo.ps1`** - Prikaz SATA/NVMe kontrolera na matičnoj ploči.
*   **`Get-SystemSerialNumbers.ps1`** - Serijski brojevi kućišta i komponenti.

### 7. Sigurnost i mrežna odbrana (71-85)
*   **`Manage-FirewallRules.ps1`** - Interaktivno dodavanje, blokiranje i pretraga pravila Firewall-a.
*   **`Audit-LocalUsers.ps1`** - Revizija svih lokalnih naloga i administratorskih grupa.
*   **`Watch-RegistryChanges.ps1`** - Praćenje izmena u Windows Registru u realnom vremenu.
*   **`Lock-FolderLock.ps1`** - Sakrivanje i sistemsko zaključavanje izabranog foldera.
*   **`Audit-OpenShares.ps1`** - Lista svih deljenih foldera na mreži (Network Shares).
*   **`Test-PasswordStrength.ps1`** - Provera i ocena jačine lozinke sa predlozima.
*   **`Get-WindowsUpdatesStatus.ps1`** - Istorija instaliranih zakrpa i bezbednosni status ažuriranja.
*   **`Scan-AntivirusStatus.ps1`** - Provera statusa Windows Defender zaštite i definicija.
*   **`Get-DnsCache.ps1`** - Prikaz i čišćenje (flush) lokalnog DNS keša.
*   **`Block-IpAddress.ps1`** - Brza blokada dolaznog saobraćaja sa određene IP adrese.
*   **`Check-FileHashesBulk.ps1`** - Masovna provera MD5/SHA-256 heševa za listu fajlova.
*   **`Get-ActiveSessions.ps1`** - Prikaz aktivnih korisničkih sesija (lokalno i preko RDP-a).
*   **`Audit-StartupPaths.ps1`** - Revizija svih startup lokacija na sistemu (Registry i folderi).
*   **`Generate-SshKeys.ps1`** - Brzo generisanje SSH ključeva (ED25519) sa kopiranjem u clipboard.
*   **`Test-DnsLeak.ps1`** - Dijagnostika i detekcija curenja DNS-a (VPN bezbednosni test).

### 8. Mreža, Web i DNS alati (86-100)
*   **`Get-WhoisInfo.ps1`** - Preuzimanje WHOIS podataka o vlasniku i isteku domena.
*   **`Get-DnsRecords.ps1`** - Upit za sve DNS zapise (A, MX, TXT, NS, CNAME) nekog domena.
*   **`Calculate-Subnet.ps1`** - Mrežni kalkulator opsega, broadcast adrese i broja hostova.
*   **`Start-SshTunnel.ps1`** - Kreiranje SSH tunela i port-forwarding-a ka udaljenom serveru.
*   **`Send-HttpRequest.ps1`** - cURL/Postman zamena: slanje HTTP zahteva sa zaglavljima.
*   **`Benchmark-DnsServers.ps1`** - Testiranje brzine odziva najpoznatijih javnih DNS servera.
*   **`Get-PublicIpGeo.ps1`** - Geolokacijski podaci za vašu javnu IP adresu.
*   **`Check-PortListen.ps1`** - Prikaz svih portova na kojima računar čeka vezu (Listening).
*   **`Watch-PingStatus.ps1`** - Ping sa vizuelnim grafikonom i zvučnim alarmom na prekid.
*   **`Get-MacVendor.ps1`** - Pretraga proizvođača na osnovu MAC adrese.
*   **`Convert-WakeOnLan.ps1`** - Slanje "Magic Packet"-a za buđenje računara preko mreže.
*   **`Test-SubnetHosts.ps1`** Skeniranje portova kroz ceo mrežni subnet.
*   **`Get-SslCertChain.ps1`** - Prikaz kompletnog lanca SSL sertifikata za sajt.
*   **`Test-InternetConnectionStability.ps1`** - Merenje stabilnosti internet veze i džitera.
*   **`Get-RoutePrint.ps1`** - Prikaz tablice rutiranja i mrežnih putanja.

### 9. Rad sa medijima i fajl automatizacija (101-115)
*   **`Merge-PdfFiles.ps1`** - Spajanje više PDF fajlova u jedan zajednički dokument.
*   **`Convert-AudioFormat.ps1`** - Konverzija audio formata (npr. WAV u MP3) preko .NET-a.
*   **`Compress-VideoFfmpeg.ps1`** - Automatska video kompresija na željenu veličinu (MB).
*   **`Convert-TextEncoding.ps1`** - Masovna konverzija kodiranja fajlova u UTF-8 sa BOM.
*   **`Find-DuplicateFolders.ps1`** - Pronalaženje foldera sa identičnim fajlovima.
*   **`Clean-EmptyFolders.ps1`** - Rekurzivno brisanje praznih foldera sa diska.
*   **`Backup-FilesToCloud.ps1`** - Sinhronizacija lokalnog foldera sa cloud folderima (OneDrive, GDrive).
*   **`Get-FileExtensionStats.ps1`** - Analiza prostora i statistika po ekstenzijama fajlova.
*   **`Create-DirectoryTree.ps1`** - Prikaz rekurzivne mape foldera i fajlova (Tree view).
*   **`Split-LargeFile.ps1`** - Deljenje velikih log/tekstualnih fajlova na delove po broju linija.
*   **`Convert-CsvToHtmlTable.ps1`** - Pretvaranje CSV fajla u HTML tabelu sa CSS stilom.
*   **`Find-BrokenShortcuts.ps1`** - Pretraga i brisanje neispravnih prečica (.lnk).
*   **`Backup-ProfileFolders.ps1`** - Brzi bekap Desktop, Documents i Downloads foldera.
*   **`Convert-ImageToGrayScale.ps1`** - Konverzija slika u crno-belu (grayscale) varijantu.
*   **`Search-FilenameWildcard.ps1`** - Pretraga fajlova po naprednim džoker filterima.

### 10. Registry, OS i Windows optimizacija (116-130)
*   **`Manage-StartupApps.ps1`** - Dodavanje, brisanje i isključivanje startup programa.
*   **`Block-WindowsTelemetry.ps1`** - Isključivanje telemetrije i servisa praćenja aktivnosti.
*   **`Toggle-WindowsUpdates.ps1`** - Privremeno stopiranje ili ponovno pokretanje ažuriranja.
*   **`Clean-DiskCleanupAdvanced.ps1`** - Dubinsko sistemsko čišćenje nepotrebnih Windows instalacija.
*   **`Get-InstalledSoftware.ps1`** - Lista svih programa instaliranih na sistemu.
*   **`Uninstall-SoftwareHelper.ps1`** - Interaktivna pretraga i deinstalacija programa.
*   **`Toggle-SleepSettings.ps1`** - Keep-Alive mod za sprečavanje odlaska računara u sleep režim.
*   **`Manage-WindowsFeatures.ps1`** - Uključivanje i isključivanje opcionih komponenti (WSL, Hyper-V).
*   **`Optimize-WindowsExplorer.ps1`** - Podešavanja u registru koja ubrzavaju Explorer i menije.
*   **`Get-WindowsLicenseKey.ps1`** - Čitanje originalnog Windows licencnog ključa.
*   **`Backup-RegistryBranch.ps1`** - Izvoz određene grane registra u `.reg` fajl.
*   **`Clean-BrowserCache.ps1`** - Čišćenje keša i istorije pretraživača (Chrome, Edge, Firefox).
*   **`Toggle-VirtualMemory.ps1`** - Optimizacija pagefile.sys fajla na statičku veličinu.
*   **`Get-SystemErrorLogs.ps1`** - Prikaz BSOD i kritičnih sistemskih grešaka.
*   **`Manage-ScheduledRestarts.ps1`** - Zakazivanje automatskih i periodičnih restarta sistema.

### 11. Baze podataka, Keš i Taskovi (131-140)
*   **`Backup-DatabaseMySQL.ps1`** - Automatski bekap MySQL/MariaDB baze u `.sql` arhivu.
*   **`Backup-DatabasePostgreSQL.ps1`** - Automatski bekap PostgreSQL baza preko `pg_dump`.
*   **`Monitor-RedisInteractive.ps1`** - Praćenje statusa lokalnog Redis servera i interaktivni flush.
*   **`Query-SqliteDatabase.ps1`** - Izvršavanje SQL upita nad SQLite (.db) bazom.
*   **`Backup-MongoDatabase.ps1`** - Bekap MongoDB baza pomoću `mongodump`.
*   **`Test-DatabaseConnection.ps1`** - Testiranje konekcije ka SQL Server, MySQL i Postgres bazama.
*   **`Monitor-DatabaseSize.ps1`** - Prikaz veličina baza na lokalnom SQL Serveru.
*   **`Check-CronFormat.ps1`** - Kalkulacija sledećih vremena pokretanja Cron izraza.
*   **`Query-MssqlDatabase.ps1`** - Izvršavanje SQL upita nad lokalnim Microsoft SQL Serverom.
*   **`Sync-DirectoriesInterval.ps1`** - Periodična sinhronizacija dva foldera u realnom vremenu.
