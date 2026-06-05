# Backup-DatabaseMySQL.ps1 - Automatizovani bekap MySQL/MariaDB baza
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DbName,
    [Parameter(Mandatory = $false)]
    [string]$Username = "root",
    [Parameter(Mandatory = $false)]
    [string]$Password = "",
    [Parameter(Mandatory = $false)]
    [string]$Host = "localhost"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem bekap MySQL baze podataka: $DbName..." -ForegroundColor Cyan

# Provera da li je mysqldump dostupan
if (-not (Get-Command mysqldump -ErrorAction SilentlyContinue)) {
    Write-Host "Greška: Alat 'mysqldump' nije pronađen u sistemskom PATH-u. Instalirajte MySQL/MariaDB klijent." -ForegroundColor Red
    return
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path (Get-Location) "mysql_${DbName}_backup_${timestamp}.sql"

try {
    Write-Host "Izvozim SQL arhivu..." -ForegroundColor DarkGray
    
    $passArg = if ($Password) { "-p$Password" } else { "" }
    
    # Pokretanje mysqldump
    & mysqldump -h $Host -u $Username $passArg --databases $DbName > $outFile
    
    if (Test-Path $outFile -and (Get-Item $outFile).Length -gt 0) {
        Write-Host "`n[+] Bekap MySQL baze uspešno završen!" -ForegroundColor Green
        Write-Host "Arhiva: $outFile" -ForegroundColor Gold
    } else {
        Write-Host "Greška pri kreiranju arhive. Proverite pristupne podatke i privilegije." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}