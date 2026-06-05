# Manage-HostsFile.ps1 - Upravljanje Windows Hosts fajlom
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [switch]$ShowOnly,
    [Parameter(Mandatory = $false)]
    [switch]$Add,
    [Parameter(Mandatory = $false)]
    [switch]$Remove,
    [Parameter(Mandatory = $false)]
    [string]$IPAddress = "127.0.0.1",
    [Parameter(Mandatory = $false)]
    [string]$HostName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$hostsPath = "C:\Windows\System32\drivers\etc\hosts"

if ($ShowOnly -or (-not $Add -and -not $Remove)) {
    Write-Host "Prikaz sadržaja Hosts fajla ($hostsPath):`n" -ForegroundColor Cyan
    try {
        $content = Get-Content $hostsPath
        foreach ($line in $content) {
            if ($line.Trim().StartsWith("#")) {
                Write-Host $line -ForegroundColor DarkGray
            } elseif ([string]::IsNullOrWhitespace($line)) {
                Write-Host ""
            } else {
                Write-Host $line -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "Greška pri čitanju Hosts fajla: $($_.Exception.Message)" -ForegroundColor Red
    }
    return
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Za izmenu Hosts fajla su potrebne administratorske privilegije." -ForegroundColor Yellow
    $confirm = Read-Host "Da li želite da pokrenete skriptu kao Administrator? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        try {
            $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            if ($Add) { $argList += " -Add -IPAddress `"$IPAddress`" -HostName `"$HostName`"" }
            if ($Remove) { $argList += " -Remove -HostName `"$HostName`"" }
            Start-Process powershell -ArgumentList $argList -Verb RunAs
        } catch {
            Write-Host "Nije moguće pokrenuti kao Administrator: $($_.Exception.Message)" -ForegroundColor Red
        }
        return
    } else {
        Write-Host "Operacija je otkazana jer nemate Admin privilegije." -ForegroundColor Red
        return
    }
}

if ($Add) {
    if ([string]::IsNullOrWhitespace($HostName)) {
        Write-Host "Greška: Morate uneti HostName (domen) za dodavanje!" -ForegroundColor Red
        return
    }
    
    $cleanHost = $HostName.Trim().ToLower()
    $content = Get-Content $hostsPath
    
    $exists = $false
    foreach ($line in $content) {
        if ($line -notmatch "^\s*#" -and $line -match "\s+$cleanHost(\s+|`$|#)") {
            $exists = $true
            break
        }
    }
    
    if ($exists) {
        Write-Host "Unos za domen '$cleanHost' već postoji u Hosts fajlu!" -ForegroundColor Yellow
        return
    }
    
    $newLine = "$IPAddress`t$cleanHost`t# Dodao Windows Utility Toolkit"
    try {
        Add-Content -Path $hostsPath -Value $newLine -ErrorAction Stop
        Write-Host "Uspešno dodat unos: $IPAddress -> $cleanHost" -ForegroundColor Green
    } catch {
        Write-Host "Greška pri pisanju u Hosts fajl: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($Remove) {
    if ([string]::IsNullOrWhitespace($HostName)) {
        Write-Host "Greška: Morate uneti HostName (domen) za brisanje!" -ForegroundColor Red
        return
    }
    
    $cleanHost = $HostName.Trim().ToLower()
    try {
        $content = Get-Content $hostsPath
        $newContent = @()
        $removed = $false
        
        foreach ($line in $content) {
            if ($line -notmatch "^\s*#" -and $line -match "\s+$cleanHost(\s+|`$|#)") {
                $removed = $true
                Write-Host "Uklanjam unos: $line" -ForegroundColor Yellow
                continue
            }
            $newContent += $line
        }
        
        if ($removed) {
            $newContent | Set-Content -Path $hostsPath -ErrorAction Stop
            Write-Host "Unos za domen '$cleanHost' je uspešno uklonjen." -ForegroundColor Green
        } else {
            Write-Host "Domen '$cleanHost' nije pronađen u Hosts fajlu." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Greška pri menjanju Hosts fajla: $($_.Exception.Message)" -ForegroundColor Red
    }
}