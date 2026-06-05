# Test-DatabaseConnection.ps1 - Testiranje konekcije za razne tipove baza podataka
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("MSSQL", "MySQL", "Postgres")]
    [string]$DbType,
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Testiram konekciju ka bazi tipa $DbType..." -ForegroundColor Cyan

try {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    if ($DbType -eq "MSSQL") {
        # Konekcija ka SQL Server-u
        $conn = New-Object System.Data.SqlClient.SqlConnection
        $conn.ConnectionString = $ConnectionString
        $conn.Open()
        $conn.Close()
    }
    elseif ($DbType -eq "MySQL") {
        # Konekcija ka MySQL (zahteva MySql.Data.dll)
        [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
        $conn = New-Object MySql.Data.MySqlClient.MySqlConnection
        $conn.ConnectionString = $ConnectionString
        $conn.Open()
        $conn.Close()
    }
    elseif ($DbType -eq "Postgres") {
        # Konekcija ka PostgreSQL (zahteva Npgsql.dll)
        [void][System.Reflection.Assembly]::LoadWithPartialName("Npgsql")
        $conn = New-Object Npgsql.NpgsqlConnection
        $conn.ConnectionString = $ConnectionString
        $conn.Open()
        $conn.Close()
    }
    
    $stopwatch.Stop()
    Write-Host "`n[+] KONEKCIJA USPEŠNA!" -ForegroundColor Green
    Write-Host "Vreme uspostavljanja veze: $($stopwatch.ElapsedMilliseconds) ms" -ForegroundColor Gold
} catch {
    Write-Host "`n[-] KONEKCIJA NIJE USPELA!" -ForegroundColor Red
    Write-Host "Detalji greške: $($_.Exception.Message)" -ForegroundColor Yellow
}