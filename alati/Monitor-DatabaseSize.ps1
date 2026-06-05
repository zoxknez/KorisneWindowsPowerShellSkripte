# Monitor-DatabaseSize.ps1 - Prikaz veličina baza podataka na lokalnom SQL Serveru
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ServerInstance = "localhost"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Skeniram veličine baza podataka na SQL Serveru: $ServerInstance..." -ForegroundColor Cyan

# Upit koji sabira veličinu fajlova podataka (.mdf) i logova (.ldf) za svaku bazu
$query = @"
SELECT 
    db.name AS [Database],
    CAST(SUM(size) * 8 / 1024.0 AS DECIMAL(18,2)) AS [SizeMB]
FROM 
    sys.master_files mf
INNER JOIN 
    sys.databases db ON db.database_id = mf.database_id
GROUP BY 
    db.name
ORDER BY 
    SizeMB DESC;
"@

try {
    # Konekcija i izvršavanje upita preko standardne .NET biblioteke
    $connString = "Server=$ServerInstance;Database=master;Trusted_Connection=True;Timeout=5;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $query
    
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$adapter.Fill($dt)
    
    $conn.Close()
    
    Write-Host "`nVeličine SQL Server baza podataka:`n" -ForegroundColor Yellow
    $dt | Format-Table -AutoSize
} catch {
    Write-Host "Greška: Nije moguće povezati se na SQL Server instancu $ServerInstance." -ForegroundColor Red
    Write-Host "Detalji: $($_.Exception.Message)" -ForegroundColor Yellow
}