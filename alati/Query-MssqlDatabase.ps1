# Query-MssqlDatabase.ps1 - Izvršavanje upita na SQL Serveru
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerInstance,
    [Parameter(Mandatory = $true)]
    [string]$DbName,
    [Parameter(Mandatory = $true)]
    [string]$Query
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Izvršavam upit na SQL Serveru [$ServerInstance], baza [$DbName]..." -ForegroundColor Cyan
Write-Host "Upit: $Query`n" -ForegroundColor DarkGray

try {
    $connString = "Server=$ServerInstance;Database=$DbName;Trusted_Connection=True;Timeout=10;"
    $conn = New-Object System.Data.SqlClient.SqlConnection($connString)
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = $Query
    
    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$adapter.Fill($dt)
    
    $conn.Close()
    
    if ($dt.Rows.Count -gt 0) {
        $dt | Format-Table -AutoSize
    } else {
        Write-Host "Upit uspešno izvršen. Nema vraćenih redova." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri izvršavanju SQL upita: $($_.Exception.Message)" -ForegroundColor Red
}