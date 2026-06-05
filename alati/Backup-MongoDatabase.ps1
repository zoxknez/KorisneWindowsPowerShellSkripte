# Backup-MongoDatabase.ps1 - Bekap MongoDB baza pomoću mongodump
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DbName,
    [Parameter(Mandatory = $false)]
    [string]$Host = "127.0.0.1",
    [Parameter(Mandatory = $false)]
    [int]$Port = 27017
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem bekap MongoDB baze podataka: $DbName..." -ForegroundColor Cyan

if (-not (Get-Command mongodump -ErrorAction SilentlyContinue)) {
    Write-Host "Greška: Alat 'mongodump' nije pronađen u PATH-u. Instalirajte MongoDB Database Tools." -ForegroundColor Red
    return
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outDir = Join-Path (Get-Location) "mongodb_${DbName}_backup_${timestamp}"

try {
    Write-Host "Izvozim kolekcije..." -ForegroundColor DarkGray
    
    # Izvršavamo mongodump
    & mongodump --host $Host --port $Port --db $DbName --out $outDir
    
    if (Test-Path $outDir) {
        Write-Host "`n[+] Bekap MongoDB baze uspešno završen!" -ForegroundColor Green
        Write-Host "Podaci sačuvani u folderu: $outDir" -ForegroundColor Gold
    } else {
        Write-Host "Greška pri eksportu baze." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška pri bekapanju MongoDB: $($_.Exception.Message)" -ForegroundColor Red
}