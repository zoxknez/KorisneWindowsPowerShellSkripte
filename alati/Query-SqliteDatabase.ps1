# Query-SqliteDatabase.ps1 - Izvršavanje SQL upita nad SQLite bazom
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DbPath,
    [Parameter(Mandatory = $true)]
    [string]$Query
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $DbPath)) {
    Write-Host "SQLite baza ne postoji na putanji: $DbPath" -ForegroundColor Red
    return
}

Write-Host "Povezujem se na SQLite bazu: $DbPath..." -ForegroundColor Cyan
Write-Host "Upit: $Query`n" -ForegroundColor DarkGray

try {
    # Koristimo standardni .NET adapter za SQLite koji je uglavnom dostupan ili preuzimamo preko klasičnog tipa
    # Pokušavamo da učitamo System.Data.SQLite, ako ne uspe radimo fallback na sqlite3.exe
    $sqliteAssembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Data.SQLite")
    
    if ($sqliteAssembly) {
        $conn = New-Object System.Data.SQLite.SQLiteConnection("Data Source=$DbPath;Version=3;")
        $conn.Open()
        
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
        
        $adapter = New-Object System.Data.SQLite.SQLiteDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        [void]$adapter.Fill($dt)
        
        $conn.Close()
        
        if ($dt.Rows.Count -gt 0) {
            $dt | Format-Table -AutoSize
        } else {
            Write-Host "Upit je uspešno izvršen. Nema vraćenih redova." -ForegroundColor Green
        }
    } else {
        # Fallback na sqlite3.exe CLI alat ako postoji
        if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
            Write-Host "System.Data.SQLite sklop nije učitan. Koristim sqlite3 CLI..." -ForegroundColor DarkGray
            & sqlite3.exe $DbPath $Query
        } else {
            Write-Host "Greška: SQLite driver (System.Data.SQLite) ili sqlite3.exe CLI nisu pronađeni na sistemu!" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Greška pri izvršavanju SQLite upita: $($_.Exception.Message)" -ForegroundColor Red
}