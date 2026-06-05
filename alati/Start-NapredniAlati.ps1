# Start-NapredniAlati.ps1 - 60 naprednih novih koristi za Windows Utility Toolkit
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 60)]
    [int]$ToolId,

    [Parameter(Mandatory = $false)]
    [switch]$List,

    [Parameter(Mandatory = $false)]
    [switch]$NoPause
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:Tools = @()

function Add-Tool {
    param(
        [int]$Id,
        [string]$Category,
        [string]$Name,
        [string]$Description,
        [scriptblock]$Action
    )

    $script:Tools += [PSCustomObject]@{
        Id = $Id
        Category = $Category
        Name = $Name
        Description = $Description
        Action = $Action
    }
}

function Show-Header {
    param([string]$Title)
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Read-ToolkitInput {
    param(
        [string]$Prompt,
        [string]$Default = ""
    )

    if ([string]::IsNullOrWhiteSpace($Default)) {
        return Read-Host $Prompt
    }

    $value = Read-Host "$Prompt (Enter za '$Default')"
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value
}

function Pause-Toolkit {
    if (-not $NoPause) {
        Read-Host "`nPritisnite Enter za nastavak..." | Out-Null
    }
}

function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-RegValueSafe {
    param([string]$Path, [string]$Name)
    try {
        return (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name
    } catch {
        return $null
    }
}

function Show-CommandMissing {
    param([string]$CommandName, [string]$InstallHint = "")
    Write-Host "Alat '$CommandName' nije pronađen." -ForegroundColor Yellow
    if ($InstallHint) { Write-Host $InstallHint -ForegroundColor DarkGray }
}

function Get-TargetPath {
    param([string]$Prompt = "Putanja", [string]$Default = (Get-Location))
    $path = Read-ToolkitInput -Prompt $Prompt -Default $Default
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "Putanja ne postoji: $path" -ForegroundColor Red
        return $null
    }
    return (Get-Item -LiteralPath $path).FullName
}

function Write-ObjectTable {
    param($InputObject)
    if ($InputObject) {
        $InputObject | Format-Table -AutoSize
    } else {
        Write-Host "Nema rezultata." -ForegroundColor Yellow
    }
}

Add-Tool 1 "Security" "Audit-PowerShellLogging" "Proverava Script Block, Module i Transcription logging." {
    $base = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell"
    [PSCustomObject]@{
        ScriptBlockLogging = Get-RegValueSafe "$base\ScriptBlockLogging" "EnableScriptBlockLogging"
        ModuleLogging = Get-RegValueSafe "$base\ModuleLogging" "EnableModuleLogging"
        Transcription = Get-RegValueSafe "$base\Transcription" "EnableTranscripting"
        TranscriptDirectory = Get-RegValueSafe "$base\Transcription" "OutputDirectory"
    } | Format-List
}

Add-Tool 2 "Security" "Enable-PowerShellLoggingSafe" "Uključuje PowerShell logging uz ShouldProcess podršku." {
    if (-not (Test-IsAdmin)) { Write-Host "Potrebne su administratorske privilegije." -ForegroundColor Red; return }
    $base = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell"
    if ($PSCmdlet.ShouldProcess("PowerShell policy registry", "Enable ScriptBlock, Module and Transcription logging")) {
        New-Item -Path "$base\ScriptBlockLogging" -Force | Out-Null
        Set-ItemProperty -Path "$base\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1 -Type DWord
        New-Item -Path "$base\ModuleLogging\ModuleNames" -Force | Out-Null
        Set-ItemProperty -Path "$base\ModuleLogging" -Name EnableModuleLogging -Value 1 -Type DWord
        Set-ItemProperty -Path "$base\ModuleLogging\ModuleNames" -Name "*" -Value "*"
        New-Item -Path "$base\Transcription" -Force | Out-Null
        Set-ItemProperty -Path "$base\Transcription" -Name EnableTranscripting -Value 1 -Type DWord
        Write-Host "PowerShell logging je uključen." -ForegroundColor Green
    }
}

Add-Tool 3 "Security" "Audit-DefenderExclusions" "Prikazuje Microsoft Defender exclusion-e." {
    if (-not (Get-Command Get-MpPreference -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-MpPreference"; return }
    $pref = Get-MpPreference
    [PSCustomObject]@{
        ExclusionPath = $pref.ExclusionPath -join "; "
        ExclusionProcess = $pref.ExclusionProcess -join "; "
        ExclusionExtension = $pref.ExclusionExtension -join "; "
        ExclusionIpAddress = $pref.ExclusionIpAddress -join "; "
    } | Format-List
}

Add-Tool 4 "Security" "Test-DefenderASRRules" "Prikazuje Attack Surface Reduction pravila i akcije." {
    if (-not (Get-Command Get-MpPreference -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-MpPreference"; return }
    $names = @{
        "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550" = "Block executable content from email and webmail"
        "D4F940AB-401B-4EFC-AADC-AD5F3C50688A" = "Block Office child processes"
        "3B576869-A4EC-4529-8536-B80A7769E899" = "Block Office executable content"
        "75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84" = "Block Office injection"
        "D3E037E1-3EB8-44C8-A917-57927947596D" = "Block JS/VBS downloaded executable content"
        "B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4" = "Block untrusted USB processes"
        "9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2" = "Block credential stealing from LSASS"
    }
    $pref = Get-MpPreference
    $ids = @($pref.AttackSurfaceReductionRules_Ids)
    $actions = @($pref.AttackSurfaceReductionRules_Actions)
    $rows = for ($i = 0; $i -lt $ids.Count; $i++) {
        [PSCustomObject]@{
            Id = $ids[$i]
            Action = $actions[$i]
            Name = if ($names.ContainsKey($ids[$i].ToUpper())) { $names[$ids[$i].ToUpper()] } else { "Unknown/custom" }
        }
    }
    $rows | Format-Table -AutoSize
}

Add-Tool 5 "Security" "Scan-AntivirusQuickSummary" "Sažima status Defender/AV zaštite." {
    if (Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue) {
        Get-MpComputerStatus | Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IoavProtectionEnabled,NISEnabled,AntispywareSignatureLastUpdated,AntivirusSignatureLastUpdated | Format-List
    } else {
        Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct -ErrorAction SilentlyContinue | Select-Object displayName,productState,pathToSignedProductExe | Format-Table -AutoSize
    }
}

Add-Tool 6 "Security" "Audit-LocalAdminsDrift" "Prikazuje članove lokalne Administrators grupe." {
    if (Get-Command Get-LocalGroupMember -ErrorAction SilentlyContinue) {
        Get-LocalGroupMember -Group "Administrators" | Select-Object Name,ObjectClass,PrincipalSource | Format-Table -AutoSize
    } else {
        net localgroup Administrators
    }
}

Add-Tool 7 "Security" "Audit-RDPExposure" "Proverava RDP, NLA i firewall pravila." {
    $rdpDenied = Get-RegValueSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections"
    $nla = Get-RegValueSafe "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" "UserAuthentication"
    Write-Host "RDP omogućen: $([bool]($rdpDenied -eq 0))" -ForegroundColor Cyan
    Write-Host "NLA uključen: $([bool]($nla -eq 1))" -ForegroundColor Cyan
    if (Get-Command Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue | Select-Object DisplayName,Enabled,Profile,Direction,Action | Format-Table -AutoSize
    }
}

Add-Tool 8 "Security" "Audit-SmbSigningGuest" "Proverava SMB signing, SMB1 i guest podešavanja." {
    if (-not (Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-SmbServerConfiguration"; return }
    Get-SmbServerConfiguration | Select-Object EnableSMB1Protocol,EnableSMB2Protocol,RequireSecuritySignature,EnableSecuritySignature,EnableAuthenticateUserSharing,RejectUnencryptedAccess | Format-List
}

Add-Tool 9 "Security" "Audit-WinRMExposure" "Prikazuje WinRM listenere i trusted hosts." {
    if (Test-Path WSMan:\localhost) {
        Get-ChildItem WSMan:\localhost\Listener -ErrorAction SilentlyContinue | Select-Object Name,Keys | Format-Table -AutoSize
        Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue | Format-List
    } else {
        Show-CommandMissing "WSMan provider"
    }
}

Add-Tool 10 "Security" "Check-FirewallProfileHardening" "Sažima Windows Firewall profile." {
    if (-not (Get-Command Get-NetFirewallProfile -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-NetFirewallProfile"; return }
    Get-NetFirewallProfile | Select-Object Name,Enabled,DefaultInboundAction,DefaultOutboundAction,NotifyOnListen,LogFileName,LogAllowed,LogBlocked | Format-Table -AutoSize
}

Add-Tool 11 "Security" "Audit-UACSettings" "Prikazuje ključna UAC registry podešavanja." {
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Get-ItemProperty -Path $path | Select-Object EnableLUA,ConsentPromptBehaviorAdmin,ConsentPromptBehaviorUser,PromptOnSecureDesktop,LocalAccountTokenFilterPolicy | Format-List
}

Add-Tool 12 "Security" "Audit-PowerShellProfiles" "Pronalazi PowerShell profile i hešira postojeće." {
    $profilePaths = @(
        $PROFILE.AllUsersAllHosts, $PROFILE.AllUsersCurrentHost, $PROFILE.CurrentUserAllHosts, $PROFILE.CurrentUserCurrentHost
    ) | Sort-Object -Unique
    $rows = foreach ($p in $profilePaths) {
        [PSCustomObject]@{
            Path = $p
            Exists = Test-Path -LiteralPath $p
            SHA256 = if (Test-Path -LiteralPath $p) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash } else { "" }
        }
    }
    $rows | Format-Table -AutoSize
}

Add-Tool 13 "Security" "Find-SuspiciousPowerShellHistory" "Traži rizične obrasce u PSReadLine istoriji." {
    $hist = Join-Path $env:APPDATA "Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (-not (Test-Path -LiteralPath $hist)) { Write-Host "PSReadLine istorija nije pronađena." -ForegroundColor Yellow; return }
    Select-String -LiteralPath $hist -Pattern "Invoke-Expression|iex|EncodedCommand|FromBase64String|DownloadString|Invoke-WebRequest|curl|wget|Add-MpPreference|Set-MpPreference" -CaseSensitive:$false | Select-Object LineNumber,Line | Format-Table -Wrap -AutoSize
}

Add-Tool 14 "Security" "Detect-PathHijacking" "Traži duple komande i sumnjive PATH foldere." {
    $dirs = $env:PATH -split ";" | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Sort-Object -Unique
    Write-Host "PATH folderi koji sadrže razmake ili korisničke putanje:" -ForegroundColor Yellow
    $dirs | Where-Object { $_ -match "\\Users\\" -or $_ -match "\s" } | ForEach-Object { Write-Host "  $_" }
    $names = @("git.exe","node.exe","npm.cmd","python.exe","powershell.exe","ssh.exe")
    $rows = foreach ($name in $names) {
        $matches = foreach ($dir in $dirs) { $candidate = Join-Path $dir $name; if (Test-Path -LiteralPath $candidate) { $candidate } }
        if ($matches.Count -gt 1) { [PSCustomObject]@{ Command=$name; Matches=($matches -join " | ") } }
    }
    $rows | Format-Table -Wrap -AutoSize
}

Add-Tool 15 "Security" "Find-AlternateDataStreams" "Traži NTFS Alternate Data Streams." {
    $path = Get-TargetPath -Prompt "Folder za ADS proveru"
    if (-not $path) { return }
    $rows = Get-ChildItem -LiteralPath $path -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
        Get-Item -LiteralPath $_.FullName -Stream * -ErrorAction SilentlyContinue | Where-Object Stream -ne ':$DATA' | Select-Object PSPath,Stream,Length
    }
    $rows | Format-Table -Wrap -AutoSize
}

Add-Tool 16 "Security" "Audit-CertificateStores" "Prikazuje certifikate koji ističu uskoro ili su self-signed." {
    $stores = @("Cert:\CurrentUser\My")
    if (Test-IsAdmin) { $stores += "Cert:\LocalMachine\My" }
    $rows = foreach ($store in $stores) {
        Get-ChildItem $store -ErrorAction SilentlyContinue | Where-Object {
            $_.NotAfter -lt (Get-Date).AddDays(45) -or $_.Subject -eq $_.Issuer
        } | Select-Object @{n="Store";e={$store}},Subject,Issuer,NotAfter,Thumbprint
    }
    $rows | Format-Table -Wrap -AutoSize
}

Add-Tool 17 "Security" "Monitor-NewServicesDrivers" "Prikazuje servise i drajvere sortirane po stanju i start modu." {
    Get-CimInstance Win32_Service | Select-Object Name,DisplayName,State,StartMode,StartName,PathName | Sort-Object StartMode,Name | Format-Table -Wrap -AutoSize
}

Add-Tool 18 "Security" "Audit-HiddenScheduledTasks" "Nalazi skrivene Scheduled Task stavke." {
    if (-not (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-ScheduledTask"; return }
    Get-ScheduledTask | Where-Object { $_.Settings.Hidden } | Select-Object TaskName,TaskPath,State | Format-Table -AutoSize
}

Add-Tool 19 "Security" "Export-SecurityTriageBundle" "Izvozi osnovni security triage bundle u ZIP." {
    $outDir = Read-ToolkitInput -Prompt "Output folder" -Default (Get-Location)
    if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $work = Join-Path $outDir "security_triage_$stamp"
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    Get-Process | Select-Object Name,Id,Path,Company,CPU,StartTime -ErrorAction SilentlyContinue | Export-Csv (Join-Path $work "processes.csv") -NoTypeInformation -Encoding UTF8
    Get-Service | Select-Object Name,DisplayName,Status,StartType | Export-Csv (Join-Path $work "services.csv") -NoTypeInformation -Encoding UTF8
    if (Get-Command Get-ScheduledTask -ErrorAction SilentlyContinue) { Get-ScheduledTask | Select-Object TaskName,TaskPath,State | Export-Csv (Join-Path $work "scheduled_tasks.csv") -NoTypeInformation -Encoding UTF8 }
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) { Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess | Export-Csv (Join-Path $work "tcp.csv") -NoTypeInformation -Encoding UTF8 }
    $zip = "$work.zip"
    Compress-Archive -Path (Join-Path $work "*") -DestinationPath $zip -Force
    Write-Host "Bundle: $zip" -ForegroundColor Green
}

Add-Tool 20 "Security" "Check-BitLockerRecoveryBackup" "Prikazuje BitLocker status i key protectore." {
    if (Get-Command Get-BitLockerVolume -ErrorAction SilentlyContinue) {
        Get-BitLockerVolume | Select-Object MountPoint,VolumeStatus,ProtectionStatus,EncryptionPercentage,KeyProtector | Format-List
    } else {
        manage-bde -status
    }
}

Add-Tool 21 "Windows Ops" "Check-WingetOutdated" "Prikazuje dostupne WinGet nadogradnje." {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Show-CommandMissing "winget" "Instalirajte App Installer / Windows Package Manager."; return }
    winget upgrade
}

Add-Tool 22 "Windows Ops" "Export-WingetPackageList" "Exportuje instalirane WinGet pakete u JSON." {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Show-CommandMissing "winget"; return }
    $out = Read-ToolkitInput -Prompt "Output JSON" -Default (Join-Path (Get-Location) "winget-packages.json")
    winget export --output $out --accept-source-agreements
    Write-Host "Export: $out" -ForegroundColor Green
}

Add-Tool 23 "Windows Ops" "Check-TimeSyncHealth" "Prikazuje Windows time sync status." {
    w32tm /query /status
    w32tm /query /source
    w32tm /query /peers
}

Add-Tool 24 "Windows Ops" "Analyze-BootPerformance" "Čita Diagnostics-Performance boot/shutdown događaje." {
    $log = "Microsoft-Windows-Diagnostics-Performance/Operational"
    Get-WinEvent -FilterHashtable @{ LogName=$log; Id=100,200 } -MaxEvents 20 -ErrorAction SilentlyContinue |
        Select-Object TimeCreated,Id,ProviderName,Message | Format-Table -Wrap -AutoSize
}

Add-Tool 25 "Windows Ops" "Repair-WindowsComponentStorePlan" "Daje bezbedan redosled DISM/SFC komandi." {
    Write-Host "Predloženi redosled pokrenuti kao Administrator:" -ForegroundColor Yellow
    Write-Host "  DISM /Online /Cleanup-Image /ScanHealth"
    Write-Host "  DISM /Online /Cleanup-Image /RestoreHealth"
    Write-Host "  sfc /scannow"
    Write-Host "Logovi: C:\Windows\Logs\DISM\dism.log i C:\Windows\Logs\CBS\CBS.log" -ForegroundColor DarkGray
}

Add-Tool 26 "Windows Ops" "Test-LongPathReadiness" "Proverava long path policy i nalazi duge putanje." {
    $enabled = Get-RegValueSafe "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" "LongPathsEnabled"
    Write-Host "LongPathsEnabled: $enabled" -ForegroundColor Cyan
    $path = Get-TargetPath -Prompt "Folder za proveru dugih putanja"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName.Length -gt 240 } | Select-Object FullName,@{n="Length";e={$_.FullName.Length}} | Format-Table -Wrap -AutoSize
}

Add-Tool 27 "Windows Ops" "Create-WindowsSandboxProfile" "Generiše .wsb profil za Windows Sandbox." {
    $folder = Read-ToolkitInput -Prompt "Folder koji mapirate" -Default (Get-Location)
    $out = Read-ToolkitInput -Prompt "Output .wsb fajl" -Default (Join-Path (Get-Location) "sandbox-profile.wsb")
    $xml = @"
<Configuration>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>$folder</HostFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
  <Networking>Enable</Networking>
</Configuration>
"@
    Set-Content -LiteralPath $out -Value $xml -Encoding UTF8
    Write-Host "Kreirano: $out" -ForegroundColor Green
}

Add-Tool 28 "Windows Ops" "Check-WprReadiness" "Proverava Windows Performance Recorder dostupnost." {
    if (Get-Command wpr -ErrorAction SilentlyContinue) {
        wpr -help | Select-Object -First 30
    } else {
        Show-CommandMissing "wpr" "Instalirajte Windows ADK / Windows Performance Toolkit."
    }
}

Add-Tool 29 "Windows Ops" "Manage-PowerToysBackup" "Pronalazi PowerToys settings folder za ručni backup." {
    $paths = @(
        Join-Path $env:LOCALAPPDATA "Microsoft\PowerToys"
        Join-Path $env:LOCALAPPDATA "PowerToys"
    )
    $rows = foreach ($p in $paths) {
        [PSCustomObject]@{ Path=$p; Exists=(Test-Path -LiteralPath $p); SizeMB=if(Test-Path -LiteralPath $p){[math]::Round(((Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum)/1MB,2)}else{0} }
    }
    $rows | Format-Table -AutoSize
}

Add-Tool 30 "Windows Ops" "Check-HotkeyConflicts" "Traži PowerToys Keyboard Manager konfiguracije." {
    $root = Join-Path $env:LOCALAPPDATA "Microsoft\PowerToys"
    Get-ChildItem -LiteralPath $root -Filter "*.json" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "Keyboard|Shortcut|key" } |
        Select-Object FullName,Length,LastWriteTime | Format-Table -AutoSize
}

Add-Tool 31 "Dev/Supply Chain" "Audit-RepoSecrets" "Lokalni scan tokena, ključeva i .env curenja." {
    $path = Get-TargetPath -Prompt "Repo/folder za secret scan"
    if (-not $path) { return }
    $patterns = "AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{20,}|-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----|password\s*=|api[_-]?key\s*=|secret\s*="
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -lt 5MB -and $_.FullName -notmatch "\\node_modules\\|\\.git\\" } |
        Select-String -Pattern $patterns -CaseSensitive:$false -ErrorAction SilentlyContinue |
        Select-Object Path,LineNumber,Line | Format-Table -Wrap -AutoSize
}

Add-Tool 32 "Dev/Supply Chain" "Audit-DependencyLockfiles" "Popisuje lockfile-ove u projektu." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -in @("package-lock.json","pnpm-lock.yaml","yarn.lock","poetry.lock","Pipfile.lock","Cargo.lock","composer.lock","go.sum") } |
        Select-Object Name,FullName,Length,LastWriteTime | Format-Table -AutoSize
}

Add-Tool 33 "Dev/Supply Chain" "Check-OpenSourceLicenses" "Traži licence u package.json fajlovima." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -Filter package.json -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\node_modules\\" } |
        ForEach-Object {
            try { $json = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json; [PSCustomObject]@{ Package=$json.name; License=$json.license; Path=$_.FullName } } catch {}
        } | Format-Table -AutoSize
}

Add-Tool 34 "Dev/Supply Chain" "Audit-DockerComposeSecurity" "Traži rizične docker-compose obrasce." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    $composeFiles = Get-ChildItem -LiteralPath $path -Recurse -File -Include "docker-compose*.yml","docker-compose*.yaml" -ErrorAction SilentlyContinue
    if (-not $composeFiles) { Write-Host "Nisu pronađeni docker-compose YAML fajlovi." -ForegroundColor Yellow; return }
    Select-String -Path $composeFiles.FullName -Pattern "privileged:\s*true|network_mode:\s*host|/var/run/docker.sock|:latest|cap_add:|security_opt:" -CaseSensitive:$false -ErrorAction SilentlyContinue |
        Select-Object Path,LineNumber,Line | Format-Table -Wrap -AutoSize
}

Add-Tool 35 "Dev/Supply Chain" "Validate-EnvFiles" "Poredi .env.example i .env ključeve bez prikaza vrednosti." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    $envFile = Join-Path $path ".env"
    $example = Join-Path $path ".env.example"
    if (-not (Test-Path $example)) { Write-Host ".env.example nije pronađen." -ForegroundColor Yellow; return }
    $keysA = Get-Content $example | Where-Object { $_ -match "^\s*[^#=]+\s*=" } | ForEach-Object { ($_ -split "=",2)[0].Trim() }
    $keysB = if (Test-Path $envFile) { Get-Content $envFile | Where-Object { $_ -match "^\s*[^#=]+\s*=" } | ForEach-Object { ($_ -split "=",2)[0].Trim() } } else { @() }
    Compare-Object $keysA $keysB | Format-Table -AutoSize
}

Add-Tool 36 "Dev/Supply Chain" "Validate-GitIgnoreCoverage" "Traži uobičajene build/cache/secret fajlove koji nisu ignorisani." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    $suspect = Get-ChildItem -LiteralPath $path -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\node_modules\\|\\dist\\|\\build\\|\\.next\\|\\.env$|\\.pem$|\\.key$" } |
        Select-Object -First 100 FullName
    $suspect | Format-Table -Wrap -AutoSize
}

Add-Tool 37 "Dev/Supply Chain" "Audit-GitLargeObjects" "Nalazi velike fajlove u radnom stablu." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    $mb = [int](Read-ToolkitInput -Prompt "Prag u MB" -Default "25")
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\.git\\" -and $_.Length -gt ($mb * 1MB) } |
        Sort-Object Length -Descending |
        Select-Object FullName,@{n="SizeMB";e={[math]::Round($_.Length/1MB,2)}} | Format-Table -Wrap -AutoSize
}

Add-Tool 38 "Dev/Supply Chain" "Check-GitHooksIntegrity" "Prikazuje lokalne Git hook-ove i heševe." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    $hooks = Join-Path $path ".git\hooks"
    if (-not (Test-Path $hooks)) { Write-Host "Nije pronađen .git/hooks folder." -ForegroundColor Yellow; return }
    Get-ChildItem -LiteralPath $hooks -File | Where-Object { $_.Name -notmatch "\.sample$" } | Select-Object Name,Length,LastWriteTime,@{n="SHA256";e={(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}} | Format-Table -AutoSize
}

Add-Tool 39 "Dev/Supply Chain" "Audit-NpmScripts" "Analizira package.json scripts za rizične obrasce." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -Filter package.json -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\node_modules\\" } |
        ForEach-Object {
            $packageJsonPath = $_.FullName
            try {
                $json = Get-Content -LiteralPath $_.FullName -Raw | ConvertFrom-Json
                $json.scripts.PSObject.Properties | Where-Object { $_.Value -match "curl|wget|Invoke-WebRequest|iex|postinstall|preinstall|rm -rf|del /" } |
                    ForEach-Object { [PSCustomObject]@{ PackageJson=$packageJsonPath; Script=$_.Name; Command=$_.Value } }
            } catch {}
        } | Format-Table -Wrap -AutoSize
}

Add-Tool 40 "Dev/Supply Chain" "Test-LocalPortsExpected" "Prikazuje listening portove i procese." {
    if (-not (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue)) { Show-CommandMissing "Get-NetTCPConnection"; return }
    Get-NetTCPConnection -State Listen | ForEach-Object {
        $p = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{ LocalAddress=$_.LocalAddress; Port=$_.LocalPort; Process=$p.ProcessName; PID=$_.OwningProcess }
    } | Sort-Object Port | Format-Table -AutoSize
}

Add-Tool 41 "Dev/Supply Chain" "Validate-OpenApiSpec" "Osnovna validacija OpenAPI JSON/YAML fajla." {
    $file = Read-ToolkitInput -Prompt "Putanja do OpenAPI fajla"
    if (-not (Test-Path -LiteralPath $file)) { Write-Host "Fajl ne postoji." -ForegroundColor Red; return }
    $raw = Get-Content -LiteralPath $file -Raw
    [PSCustomObject]@{
        HasOpenApi = $raw -match "openapi\s*[:=]"
        HasInfo = $raw -match "\binfo\s*:"
        HasPaths = $raw -match "\bpaths\s*:"
        HasSecurity = $raw -match "\bsecuritySchemes\b|\bsecurity\s*:"
        DeprecatedCount = ([regex]::Matches($raw, "deprecated\s*:\s*true")).Count
    } | Format-List
}

Add-Tool 42 "Dev/Supply Chain" "Generate-RepoHealthReport" "Pravi sažet repo health izveštaj." {
    $path = Get-TargetPath -Prompt "Repo/folder"
    if (-not $path) { return }
    Push-Location $path
    try {
        Write-Host "Git status:" -ForegroundColor Yellow
        if (Test-Path ".git") { git status --short; git branch --show-current } else { Write-Host "Nije Git repo." }
        Write-Host "`nTODO/FIXME:" -ForegroundColor Yellow
        Get-ChildItem -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch "\\.git\\|\\node_modules\\" -and $_.Length -lt 2MB } | Select-String -Pattern "TODO|FIXME|BUG" -ErrorAction SilentlyContinue | Select-Object -First 30 Path,LineNumber,Line | Format-Table -Wrap -AutoSize
    } finally {
        Pop-Location
    }
}

Add-Tool 43 "Network/Web" "Check-DomainEmailSecurity" "Proverava SPF, DMARC i MTA-STS DNS zapise." {
    $domain = Read-ToolkitInput -Prompt "Domen"
    if (-not $domain) { return }
    foreach ($name in @($domain, "_dmarc.$domain", "_mta-sts.$domain")) {
        Write-Host "`n$name" -ForegroundColor Yellow
        Resolve-DnsName -Name $name -Type TXT -ErrorAction SilentlyContinue | Select-Object Name,Type,Strings | Format-Table -Wrap -AutoSize
    }
}

Add-Tool 44 "Network/Web" "Check-SecurityHeaders" "Proverava ključne web security header-e." {
    $url = Read-ToolkitInput -Prompt "URL" -Default "https://example.com"
    $rows = try {
        $r = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10 -UseBasicParsing
        $headers = "Strict-Transport-Security","Content-Security-Policy","X-Frame-Options","X-Content-Type-Options","Referrer-Policy","Permissions-Policy","Cross-Origin-Opener-Policy"
        foreach ($h in $headers) {
            $value = $r.Headers[$h]
            [PSCustomObject]@{ Header=$h; Present=(-not [string]::IsNullOrWhiteSpace($value)); Value=$value }
        }
    } catch {
        Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
    }
    $rows | Format-Table -Wrap -AutoSize
}

Add-Tool 45 "Network/Web" "Check-CertificateTransparency" "Pretražuje crt.sh za certifikate domena." {
    $domain = Read-ToolkitInput -Prompt "Domen"
    if (-not $domain) { return }
    try {
        $url = "https://crt.sh/?q=%25.$domain&output=json"
        Invoke-RestMethod -Uri $url -TimeoutSec 15 | Select-Object -First 50 name_value,issuer_name,not_before,not_after | Format-Table -Wrap -AutoSize
    } catch {
        Write-Host "Greška pri CT pretrazi: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Add-Tool 46 "Network/Web" "Monitor-DomainDnsBaseline" "Prikazuje A/AAAA/MX/NS/TXT DNS baseline." {
    $domain = Read-ToolkitInput -Prompt "Domen"
    if (-not $domain) { return }
    foreach ($type in "A","AAAA","MX","NS","TXT") {
        Write-Host "`n$type" -ForegroundColor Yellow
        Resolve-DnsName -Name $domain -Type $type -ErrorAction SilentlyContinue | Format-Table -Wrap -AutoSize
    }
}

Add-Tool 47 "Network/Web" "Test-IPv6Readiness" "Proverava lokalni IPv6, rutu i DNS." {
    Get-NetIPAddress -AddressFamily IPv6 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notmatch "^fe80" } | Select-Object InterfaceAlias,IPAddress,PrefixLength | Format-Table -AutoSize
    Get-NetRoute -AddressFamily IPv6 -DestinationPrefix "::/0" -ErrorAction SilentlyContinue | Format-Table -AutoSize
    Test-NetConnection -ComputerName "ipv6.google.com" -Port 443 -InformationLevel Detailed
}

Add-Tool 48 "Network/Web" "Trace-PathQuality" "Pokreće tracert i ping za cilj." {
    $target = Read-ToolkitInput -Prompt "Host/IP" -Default "8.8.8.8"
    Test-Connection -ComputerName $target -Count 10 -ErrorAction SilentlyContinue | Select-Object Address,ResponseTime,StatusCode | Format-Table -AutoSize
    tracert $target
}

Add-Tool 49 "Network/Web" "Benchmark-VpnSplitTunnel" "Upoređuje javnu IP i default rutu." {
    Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object ifIndex,NextHop,RouteMetric,InterfaceAlias | Format-Table -AutoSize
    try { Invoke-RestMethod -Uri "https://api.ipify.org?format=json" -TimeoutSec 5 | Format-List } catch { Write-Host "Javna IP provera nije uspela." -ForegroundColor Yellow }
}

Add-Tool 50 "Network/Web" "Scan-MdnsSsdpDevices" "Lagano proverava mDNS/SSDP indikatore." {
    Write-Host "mDNS servis upit:" -ForegroundColor Yellow
    Resolve-DnsName -Name "_services._dns-sd._udp.local" -Type PTR -ErrorAction SilentlyContinue | Format-Table -AutoSize
    Write-Host "SSDP UDP port 1900 nije aktivno skeniran radi bezbednosti; koristite Wireshark/ssdp tools za dublje." -ForegroundColor DarkGray
}

Add-Tool 51 "Files/Backup" "Analyze-NtfsPermissionsDrift" "Sažima ACL za folder." {
    $path = Get-TargetPath -Prompt "Folder za ACL proveru"
    if (-not $path) { return }
    Get-Acl -LiteralPath $path | Select-Object -ExpandProperty Access | Select-Object IdentityReference,FileSystemRights,AccessControlType,IsInherited | Format-Table -AutoSize
}

Add-Tool 52 "Files/Backup" "Export-ExifAndZoneMetadata" "Izvozi osnovne metadata indikatore i Zone.Identifier." {
    $path = Get-TargetPath -Prompt "Folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object -First 200 | ForEach-Object {
        $zone = Get-Item -LiteralPath $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue
        [PSCustomObject]@{ File=$_.FullName; Extension=$_.Extension; SizeKB=[math]::Round($_.Length/1KB,1); HasZoneIdentifier=[bool]$zone; LastWriteTime=$_.LastWriteTime }
    } | Format-Table -Wrap -AutoSize
}

Add-Tool 53 "Files/Backup" "Detect-ArchiveBombRisk" "Procena ZIP compression ratio rizika." {
    $file = Read-ToolkitInput -Prompt "ZIP fajl"
    if (-not (Test-Path -LiteralPath $file)) { Write-Host "Fajl ne postoji." -ForegroundColor Red; return }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path $file))
    try {
        $totalCompressed = ($zip.Entries | Measure-Object CompressedLength -Sum).Sum
        $totalRaw = ($zip.Entries | Measure-Object Length -Sum).Sum
        [PSCustomObject]@{ Entries=$zip.Entries.Count; CompressedMB=[math]::Round($totalCompressed/1MB,2); ExpandedMB=[math]::Round($totalRaw/1MB,2); Ratio=if($totalCompressed){[math]::Round($totalRaw/$totalCompressed,2)}else{0} } | Format-List
    } finally { $zip.Dispose() }
}

Add-Tool 54 "Files/Backup" "Verify-BackupRestore" "Poredi dva foldera preko SHA256 manifest-a." {
    $a = Get-TargetPath -Prompt "Original folder"
    $b = Get-TargetPath -Prompt "Restore/backup folder"
    if (-not $a -or -not $b) { return }
    $mapA = @{}
    Get-ChildItem -LiteralPath $a -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object { $rel=$_.FullName.Substring($a.Length).TrimStart("\"); $mapA[$rel]=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    Get-ChildItem -LiteralPath $b -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object { $rel=$_.FullName.Substring($b.Length).TrimStart("\"); $hash=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash; if(-not $mapA.ContainsKey($rel) -or $mapA[$rel] -ne $hash){ [PSCustomObject]@{ File=$rel; Status="Different or extra" } } } | Format-Table -AutoSize
}

Add-Tool 55 "Files/Backup" "Snapshot-FolderManifest" "Kreira SHA256 manifest foldera." {
    $path = Get-TargetPath -Prompt "Folder"
    if (-not $path) { return }
    $out = Read-ToolkitInput -Prompt "Output CSV" -Default (Join-Path (Get-Location) "folder-manifest.csv")
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{ RelativePath=$_.FullName.Substring($path.Length).TrimStart("\"); Length=$_.Length; LastWriteTime=$_.LastWriteTime; SHA256=(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    } | Export-Csv -Path $out -NoTypeInformation -Encoding UTF8
    Write-Host "Manifest: $out" -ForegroundColor Green
}

Add-Tool 56 "Files/Backup" "Detect-CaseOnlyFilenameConflicts" "Nalazi case-only konflikte korisne za Git/WSL." {
    $path = Get-TargetPath -Prompt "Folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Group-Object { $_.FullName.ToLowerInvariant() } |
        Where-Object Count -gt 1 |
        ForEach-Object { [PSCustomObject]@{ ConflictKey=$_.Name; Files=($_.Group.FullName -join " | ") } } | Format-Table -Wrap -AutoSize
}

Add-Tool 57 "Files/Backup" "Normalize-FilenamesUnicodePreview" "Prikazuje fajlove čija Unicode normalizacija menja naziv." {
    $path = Get-TargetPath -Prompt "Folder"
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $normalized = $_.Name.Normalize([Text.NormalizationForm]::FormC)
        if ($normalized -ne $_.Name) { [PSCustomObject]@{ Current=$_.FullName; Normalized=$normalized } }
    } | Format-Table -Wrap -AutoSize
}

Add-Tool 58 "Files/Backup" "Detect-OneDriveSyncConflicts" "Traži OneDrive conflicted copies i sync indikatore." {
    $path = Get-TargetPath -Prompt "Folder" -Default (Join-Path $env:USERPROFILE "OneDrive")
    if (-not $path) { return }
    Get-ChildItem -LiteralPath $path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "conflicted copy|sync conflict|računar|computer" } |
        Select-Object FullName,Length,LastWriteTime | Format-Table -Wrap -AutoSize
}

Add-Tool 59 "Files/Backup" "Monitor-RansomwareCanary" "Kreira ili proverava canary fajlove." {
    $path = Get-TargetPath -Prompt "Folder"
    if (-not $path) { return }
    $canary = Join-Path $path "_WUT_CANARY_DO_NOT_EDIT.txt"
    if (-not (Test-Path -LiteralPath $canary)) {
        Set-Content -LiteralPath $canary -Value "Windows Utility Toolkit canary $(Get-Date -Format o)" -Encoding UTF8
        Write-Host "Canary kreiran: $canary" -ForegroundColor Green
    } else {
        Get-Item -LiteralPath $canary | Select-Object FullName,Length,LastWriteTime,@{n="SHA256";e={(Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash}} | Format-List
    }
}

Add-Tool 60 "Files/Backup" "Analyze-LargeLogAnomalies" "Top greške i frekvencije u velikom log fajlu." {
    $file = Read-ToolkitInput -Prompt "Log fajl"
    if (-not (Test-Path -LiteralPath $file)) { Write-Host "Fajl ne postoji." -ForegroundColor Red; return }
    $lines = Get-Content -LiteralPath $file -Tail 5000 -ErrorAction Stop
    Write-Host "Top ključne reči:" -ForegroundColor Yellow
    $rows = foreach ($p in "error","exception","failed","timeout","denied","warning") {
        [PSCustomObject]@{ Pattern=$p; Count=($lines | Select-String -Pattern $p -CaseSensitive:$false).Count }
    }
    $rows | Format-Table -AutoSize
    Write-Host "`nNajčešće linije sa greškama:" -ForegroundColor Yellow
    $lines | Select-String -Pattern "error|exception|failed|timeout|denied" -CaseSensitive:$false | ForEach-Object Line | Group-Object | Sort-Object Count -Descending | Select-Object -First 15 Count,Name | Format-Table -Wrap -AutoSize
}

function Show-ToolList {
    foreach ($group in ($script:Tools | Group-Object Category)) {
        Write-Host "`n$($group.Name)" -ForegroundColor Yellow
        $group.Group | Sort-Object Id | ForEach-Object {
            Write-Host ("{0,2}. {1} - {2}" -f $_.Id, $_.Name, $_.Description) -ForegroundColor White
        }
    }
}

function Invoke-AdvancedTool {
    param([int]$Id)

    $tool = $script:Tools | Where-Object Id -eq $Id | Select-Object -First 1
    if (-not $tool) {
        Write-Host "Nepoznat alat: $Id" -ForegroundColor Red
        return
    }

    Show-Header -Title ("{0}. {1}" -f $tool.Id, $tool.Name)
    Write-Host $tool.Description -ForegroundColor DarkGray
    Write-Host ""
    & $tool.Action
}

if ($List) {
    Show-ToolList
    return
}

if ($ToolId) {
    Invoke-AdvancedTool -Id $ToolId
    return
}

do {
    Show-Header -Title "NAPREDNI NOVI ALATI (60 KORISTI)"
    Show-ToolList
    Write-Host "`n0. Nazad" -ForegroundColor Red
    $choice = Read-Host "`nIzaberite alat"
    if ($choice -match "^\d+$" -and [int]$choice -gt 0) {
        Invoke-AdvancedTool -Id ([int]$choice)
        Pause-Toolkit
    }
} while ($choice -ne "0")
