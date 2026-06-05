# Backup-DatabasePostgreSQL.ps1 - Automatizovani bekap PostgreSQL baze
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DbName,
    [Parameter(Mandatory = $false)]
    [string]$Username = "postgres",
    [Parameter(Mandatory = $false)]
    [string]$Host = "localhost",
    [Parameter(Mandatory = $false)]
    [int]$Port = 5432
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem bekap PostgreSQL baze podataka: $DbName..." -ForegroundColor Cyan

if (-not (Get-Command pg_dump -ErrorAction SilentlyContinue)) {
    Write-Host "Greška: Alat 'pg_dump' nije pronađen u PATH-u. Instalirajte PostgreSQL klijent." -ForegroundColor Red
    return
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = Join-Path (Get-Location) "postgres_${DbName}_backup_${timestamp}.sql"

try {
    Write-Host "Izvozim bazu..." -ForegroundColor DarkGray
    
    # Za pg_dump bez unosa lozinke na promptu, postavlja se PGUSER i PGPASSWORD promenljive ako su definisane
    $env:PGUSER = $Username
    
    & pg_dump -h $Host -p $Port -d $DbName -f $outFile
    
    if (Test-Path $outFile -and (Get-Item $outFile).Length -gt 0) {
        Write-Host "`n[+] Bekap PostgreSQL baze uspešno završen!" -ForegroundColor Green
        Write-Host "Arhiva: $outFile" -ForegroundColor Gold
    } else {
        Write-Host "Greška pri kreiranju arhive." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška pri izvozu baze: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Brisanje env promenljive iz bezbednosnih razloga
    Remove-Item env:PGUSER -ErrorAction SilentlyContinue
}