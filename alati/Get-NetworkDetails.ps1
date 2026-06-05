[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-NetworkDetails.ps1 - Detaljne informacije o mreži i IP adresama
Write-Host "Prikupljanje mrežnih informacija..." -ForegroundColor Cyan

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "           LOKALNA MREŽNA KONFIGURACIJA           " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

try {
    if (Get-Command Get-NetIPConfiguration -ErrorAction SilentlyContinue) {
        $netConfigs = Get-NetIPConfiguration
        foreach ($config in $netConfigs) {
            if ($config.IPv4Address) {
                Write-Host "Adapter:    $($config.InterfaceAlias) ($($config.InterfaceDescription))" -ForegroundColor Green
                Write-Host "  IPv4 Adresa:   $($config.IPv4Address.IPAddress)" -ForegroundColor White
                if ($config.IPv6Address) {
                    Write-Host "  IPv6 Adresa:   $($config.IPv6Address.IPAddress)" -ForegroundColor White
                }
                Write-Host "  MAC Adresa:    $($config.NetAdapter.MacAddress)" -ForegroundColor White
                
                if ($config.IPv4DefaultGateway) {
                    Write-Host "  Gateway IP:    $($config.IPv4DefaultGateway.NextHop)" -ForegroundColor White
                }
                
                if ($config.DNSServer) {
                    $dnsServers = $config.DNSServer.DNSServerAddress -join ", "
                    Write-Host "  DNS Serveri:   $dnsServers" -ForegroundColor White
                }
                Write-Host ""
            }
        }
    } else {
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = True"
        foreach ($adapter in $adapters) {
            Write-Host "Adapter:    $($adapter.Description)" -ForegroundColor Green
            Write-Host "  IPv4 Adresa:   $($adapter.IPAddress[0])" -ForegroundColor White
            Write-Host "  MAC Adresa:    $($adapter.MACAddress)" -ForegroundColor White
            Write-Host "  Gateway IP:    $($adapter.DefaultIPGateway -join ', ')" -ForegroundColor White
            Write-Host "  DNS Serveri:   $($adapter.DNSServerSearchOrder -join ', ')" -ForegroundColor White
            Write-Host ""
        }
    }
} catch {
    Write-Host "Greška pri prikupljanju lokalnih mrežnih parametara: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "            SPOLJNI (JAVNI) DETALJI               " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Pozivanje javnog API-ja za IP adresu..." -ForegroundColor DarkGray

$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

$publicIPData = $null
$apis = @("https://ipinfo.io/json", "https://ipapi.co/json/", "https://ip-api.com/json/")

foreach ($api in $apis) {
    try {
        $response = Invoke-RestMethod -Uri $api -TimeoutSec 3
        if ($response) {
            $publicIPData = $response
            break
        }
    } catch {}
}

$ProgressPreference = $oldProgress

if ($publicIPData) {
    $ip = $publicIPData.ip
    if (-not $ip) { $ip = $publicIPData.query }
    
    $isp = if ($publicIPData.org) { $publicIPData.org } else { $publicIPData.isp }
    $country = if ($publicIPData.country_name) { $publicIPData.country_name } else { $publicIPData.country }
    $city = $publicIPData.city
    $region = if ($publicIPData.region) { $publicIPData.region } else { $publicIPData.regionName }
    
    Write-Host "  Javna IP adresa : " -NoNewline -ForegroundColor White
    Write-Host "$ip" -ForegroundColor Green
    Write-Host "  Provajder (ISP) : $isp" -ForegroundColor White
    Write-Host "  Lokacija        : $city, $region, $country" -ForegroundColor White
} else {
    Write-Host "  [-] Nije moguće utvrditi javnu IP adresu (Offline ili su API servisi nedostupni)." -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan