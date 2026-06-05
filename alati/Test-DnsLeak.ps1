[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Test-DnsLeak.ps1 - Test curenja DNS-a (VPN test)
Write-Host "Pokrećem dijagnostiku DNS curenja (DNS Leak)..." -ForegroundColor Cyan
Write-Host "Ova skripta proverava preko kojih DNS servera Vaš računar šalje zahteve." -ForegroundColor DarkGray

try {
    # Koristimo javni API koji vraća podatke o IP adresi sa koje je upućen DNS upit
    Write-Host "Povezujem se sa mrežnim API-jem..." -ForegroundColor DarkGray
    
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    
    # ipinfo.io nam daje javnu IP adresu, a radimo Resolve-DnsName da vidimo koji nas DNS razrešava
    $dnsResolve = Resolve-DnsName -Name "whoami.akamai.net" -Type A -ErrorAction Stop
    $dnsServerIp = $dnsResolve[0].IPAddress
    
    $ProgressPreference = $oldProgress
    
    Write-Host "`nRezultati testa:" -ForegroundColor Yellow
    Write-Host "  Vaš primarni DNS koji vrši razrešavanje: " -NoNewline -ForegroundColor White
    Write-Host "$dnsServerIp" -ForegroundColor Green
    
    # Detekcija vlasnika tog DNS servera
    try {
        $geo = Invoke-RestMethod -Uri "https://ipinfo.io/$dnsServerIp/json" -TimeoutSec 3
        if ($geo) {
            Write-Host "  Provajder (DNS ISP)                     : $($geo.org)" -ForegroundColor White
            Write-Host "  Lokacija DNS servera                   : $($geo.city), $($geo.country)" -ForegroundColor White
        }
    } catch {}
    
    Write-Host "`nSavet: Ako koristite VPN, lokacija i provajder DNS servera MORAJU odgovarati VPN provajderu. Ako vidite Vašeg lokalnog provajdera (Telekom, SBB i sl.), Vaš DNS curi (DNS Leak)!" -ForegroundColor Yellow
} catch {
    Write-Host "Greška pri mrežnom testiranju: $($_.Exception.Message)" -ForegroundColor Red
}