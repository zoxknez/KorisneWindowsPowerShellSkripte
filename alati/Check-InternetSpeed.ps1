[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Check-InternetSpeed.ps1 - Mrežna dijagnostika i merenje brzine
Write-Host "Pokretanje mrežne dijagnostike..." -ForegroundColor Cyan

$hosts = @(
    @{ Ime = "Cloudflare DNS"; IP = "1.1.1.1" },
    @{ Ime = "Google DNS"; IP = "8.8.8.8" },
    @{ Ime = "Local Gateway"; IP = "default" }
)

try {
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
    if ($gateway) {
        $hosts[2].IP = $gateway
    } else {
        $hosts = $hosts[0..1]
    }
} catch {
    $hosts = $hosts[0..1]
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "             PING I LATENCIJA (ODZIV)             " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

foreach ($h in $hosts) {
    Write-Host "Pingujem $($h.Ime) ($($h.IP))..." -ForegroundColor DarkGray
    try {
        $ping = Test-Connection -ComputerName $h.IP -Count 4 -ErrorAction SilentlyContinue
        if ($ping) {
            $avgResponse = ($ping | Measure-Object -Property ResponseTime -Average).Average
            $loss = 4 - $ping.Count
            $lossPercent = ($loss / 4) * 100
            
            Write-Host "  [+] " -NoNewline -ForegroundColor Green
            Write-Host "$($h.Ime.PadRight(15)) : Prosek: $([Math]::Round($avgResponse, 1)) ms | Gubitak paketa: $lossPercent%" -ForegroundColor White
        } else {
            Write-Host "  [-] $($h.Ime.PadRight(15)) : Nije dostupno (100% gubitak paketa)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  [-] $($h.Ime.PadRight(15)) : Greška pri testiranju" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "            TEST BRZINE PREUZIMANJA               " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$testUrl = "https://speed.cloudflare.com/__down?bytes=5000000"
Write-Host "Preuzimanje testnog fajla od 5MB sa Cloudflare CDN-a..." -ForegroundColor DarkGray

try {
    $wc = New-Object System.Net.WebClient
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $data = $wc.DownloadData($testUrl)
    $stopwatch.Stop()
    
    $ProgressPreference = $oldProgress
    
    $seconds = $stopwatch.Elapsed.TotalSeconds
    $sizeBits = $data.Length * 8
    $speedMbps = [Math]::Round(($sizeBits / $seconds) / 1MB, 2)
    $speedMBps = [Math]::Round(($data.Length / $seconds) / 1MB, 2)
    
    Write-Host "`nRezultati testa brzine:" -ForegroundColor Yellow
    Write-Host "  Vreme preuzimanja: $([Math]::Round($seconds, 2)) sekundi" -ForegroundColor White
    Write-Host "  Brzina preuzimanja (Mbps): " -NoNewline -ForegroundColor White
    Write-Host "$speedMbps Mbps" -ForegroundColor Green
    Write-Host "  Brzina preuzimanja (MB/s): " -NoNewline -ForegroundColor White
    Write-Host "$speedMBps MB/s" -ForegroundColor Green
} catch {
    Write-Host "Nije moguće izmeriti brzinu preuzimanja. Proverite internet vezu." -ForegroundColor Red
    Write-Host "Detalji greške: $($_.Exception.Message)" -ForegroundColor DarkGray
}
Write-Host "==================================================" -ForegroundColor Cyan