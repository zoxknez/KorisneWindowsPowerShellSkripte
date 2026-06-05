[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-DnsCache.ps1 - Prikaz i brisanje lokalnog DNS keša
Write-Host "Čitam lokalni DNS keš računara..." -ForegroundColor Cyan

try {
    # Get-DnsClientCache je standard u Windows-u
    $cache = Get-DnsClientCache -ErrorAction SilentlyContinue
    
    if (-not $cache -or $cache.Count -eq 0) {
        Write-Host "Lokalni DNS keš je trenutno prazan." -ForegroundColor Green
    } else {
        Write-Host "`nPronađeni DNS zapisi u kešu (prvih 30):" -ForegroundColor Yellow
        $cache | Select-Object -Property Entry, Type, Status, Data | Select-Object -First 30 | Format-Table -AutoSize
    }
    
    $confirm = Read-Host "`nDa li želite da ispraznite (flush-ujete) DNS keš? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        Clear-DnsClientCache
        Write-Host "DNS keš je uspešno očišćen!" -ForegroundColor Green
    }
} catch {
    # Fallback na ipconfig /flushdns ako Get-DnsClientCache baci grešku
    Write-Host "Pokrećem klasično čišćenje preko ipconfig..." -ForegroundColor DarkGray
    ipconfig /flushdns
}