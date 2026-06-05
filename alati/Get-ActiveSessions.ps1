[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-ActiveSessions.ps1 - Prikaz aktivnih korisničkih sesija
Write-Host "Očitavam aktivne korisničke sesije na računaru..." -ForegroundColor Cyan

try {
    # Koristimo qwinsta.exe koji prikazuje sve sesije (lokalne i RDP)
    $sessions = qwinsta.exe 2>&1
    
    Write-Host "`nAktivne sesije (lokalne i RDP):`n" -ForegroundColor Yellow
    foreach ($line in $sessions) {
        if ($line.Trim()) {
            # Isticanje aktivne sesije (zelena boja)
            if ($line -match '(?i)active') {
                Write-Host $line -ForegroundColor Green
            } else {
                Write-Host $line -ForegroundColor White
            }
        }
    }
} catch {
    Write-Host "Greška pri čitanju aktivnih sesija: $($_.Exception.Message)" -ForegroundColor Red
}