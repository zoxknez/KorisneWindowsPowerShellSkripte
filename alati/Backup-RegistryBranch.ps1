# Backup-RegistryBranch.ps1 - Izvoz (bekap) određene grane registra u .reg fajl
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegPath,
    [Parameter(Mandatory = $false)]
    [string]$OutFile = ""
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Bekapujem Windows Registry granu..." -ForegroundColor Cyan

# Validacija da li je ispravna sintaksa
if ($RegPath -match '^(HKLM|HKCU|HKU|HKCR):\\?(.*)$') {
    $hive = switch ($Matches[1]) {
        "HKLM" { "HKEY_LOCAL_MACHINE" }
        "HKCU" { "HKEY_CURRENT_USER" }
        "HKU"  { "HKEY_USERS" }
        "HKCR" { "HKEY_CLASSES_ROOT" }
    }
    $subKey = $Matches[2]
    $fullRegPath = if ($subKey) { "$hive\$subKey" } else { $hive }
} else {
    Write-Host "Greška: Registry putanja mora početi sa HKLM, HKCU, HKCR ili HKU (npr. HKCU:\Software\Microsoft)!" -ForegroundColor Red
    return
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$finalOutFile = $OutFile
if ([string]::IsNullOrEmpty($finalOutFile)) {
    # Kreiranje naziva fajla na osnovu grane
    $safeName = $RegPath.Replace(":\", "_").Replace("\", "_")
    $finalOutFile = Join-Path (Get-Location) "${safeName}_backup_${timestamp}.reg"
}

Write-Host "Grana  : $fullRegPath" -ForegroundColor White
Write-Host "Izlazni: $finalOutFile" -ForegroundColor White

try {
    # Pokretanje sistemskog reg.exe alata za export
    Write-Host "`nIzvozim podatke..." -ForegroundColor DarkGray
    & reg.exe export "$fullRegPath" "$finalOutFile" /y
    
    if (Test-Path $finalOutFile) {
        Write-Host "`n[+] Registry bekap uspešno završen!" -ForegroundColor Green
        Write-Host "Fajl je sačuvan na: $finalOutFile" -ForegroundColor Gold
    } else {
        Write-Host "Greška: Bekap fajl nije kreiran. Proverite putanju." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška pri izvozu registra: $($_.Exception.Message)" -ForegroundColor Red
}