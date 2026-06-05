# Get-SystemSpecs.ps1 - Specifikacije sistema i verzije programerskih alata
Write-Host "Prikupljanje informacija o sistemu..." -ForegroundColor Cyan

try {
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $cpuName = $cpu.Name.Trim()
} catch { $cpuName = "Nepoznato" }

try {
    $ramInfo = Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | Measure-Object -Property Capacity -Sum
    $ramGB = [Math]::Round($ramInfo.Sum / 1GB, 1)
} catch { $ramGB = "Nepoznato" }

try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue | Select-Object -First 1
    $osName = $os.Caption
    $osVersion = $os.Version
} catch { 
    $osName = "Windows"
    $osVersion = "Nepoznato"
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "               SPECIFIKACIJE SISTEMA              " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "OS:            $osName (Build $osVersion)" -ForegroundColor White
Write-Host "Procesor (CPU): $cpuName" -ForegroundColor White
Write-Host "Memorija (RAM): $ramGB GB" -ForegroundColor White

Write-Host "`nDiskovi:" -ForegroundColor Yellow
try {
    $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
    foreach ($disk in $disks) {
        $freeGB = [Math]::Round($disk.FreeSpace / 1GB, 2)
        $totalGB = [Math]::Round($disk.Size / 1GB, 2)
        Write-Host "  Disk $($disk.DeviceID) -> Slobodno: $freeGB GB / Ukupno: $totalGB GB" -ForegroundColor White
    }
} catch {
    Write-Host "  Nije moguće učitati podatke o diskovima." -ForegroundColor Red
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "            INSTALIRANI RAZVOJNI ALATI            " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

function Get-ToolVersion {
    param(
        [string]$ToolName,
        [string]$Command,
        [string]$Arguments = "--version"
    )
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    
    try {
        $cmdCheck = Get-Command $Command -ErrorAction SilentlyContinue
        if ($cmdCheck) {
            $versionOutput = & $Command $Arguments 2>&1
            if ($versionOutput -is [array]) {
                $version = $versionOutput[0].ToString().Trim()
            } else {
                $version = $versionOutput.ToString().Trim()
            }
            if ($version.Length -gt 60) { $version = $version.Substring(0, 57) + "..." }
            return [PSCustomObject]@{ Alat = $ToolName; Status = "Instaliran"; Verzija = $version }
        } else {
            return [PSCustomObject]@{ Alat = $ToolName; Status = "Nije instaliran"; Verzija = "-" }
        }
    } catch {
        return [PSCustomObject]@{ Alat = $ToolName; Status = "Nije instaliran"; Verzija = "-" }
    }
}

$tools = @()
$tools += Get-ToolVersion -ToolName "PowerShell" -Command "powershell" -Arguments "-Command `"`$PSVersionTable.PSVersion.ToString()`""
$tools += Get-ToolVersion -ToolName "Git" -Command "git"
$tools += Get-ToolVersion -ToolName "Node.js" -Command "node" -Arguments "-v"
$tools += Get-ToolVersion -ToolName "npm" -Command "npm" -Arguments "-v"
$tools += Get-ToolVersion -ToolName "Python" -Command "python" -Arguments "--version"
$tools += Get-ToolVersion -ToolName "Docker" -Command "docker" -Arguments "--version"
$tools += Get-ToolVersion -ToolName "Go" -Command "go" -Arguments "version"
$tools += Get-ToolVersion -ToolName "Rust (Cargo)" -Command "cargo" -Arguments "--version"
$tools += Get-ToolVersion -ToolName "Java (JVM)" -Command "java" -Arguments "-version"
$tools += Get-ToolVersion -ToolName ".NET CLI" -Command "dotnet" -Arguments "--version"

$javaTool = $tools | Where-Object { $_.Alat -eq "Java (JVM)" }
if ($javaTool -and $javaTool.Status -eq "Instaliran") {
    if ($javaTool.Verzija -match '"([^"]+)"') {
        $javaTool.Verzija = $Matches[1]
    }
}

foreach ($t in $tools) {
    if ($t.Status -eq "Instaliran") {
        Write-Host "  [+] " -NoNewline -ForegroundColor Green
        Write-Host "$($t.Alat.PadRight(15)) : $($t.Verzija)" -ForegroundColor White
    } else {
        Write-Host "  [-] " -NoNewline -ForegroundColor DarkGray
        Write-Host "$($t.Alat.PadRight(15)) : Nije instaliran" -ForegroundColor DarkGray
    }
}
Write-Host "==================================================" -ForegroundColor Cyan