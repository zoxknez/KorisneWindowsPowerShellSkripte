[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Benchmark-DnsServers.ps1 - Testiranje brzine DNS servera
Write-Host "Pokrećem testiranje (benchmark) brzine DNS servera..." -ForegroundColor Cyan
Write-Host "Testiramo vreme odziva za razrešavanje adresa.`n" -ForegroundColor DarkGray

$dnsServers = @(
    @{ Ime = "Cloudflare Primary"; IP = "1.1.1.1" },
    @{ Ime = "Cloudflare Secondary"; IP = "1.0.0.1" },
    @{ Ime = "Google Primary"; IP = "8.8.8.8" },
    @{ Ime = "Google Secondary"; IP = "8.8.4.4" },
    @{ Ime = "Quad9"; IP = "9.9.9.9" },
    @{ Ime = "AdGuard DNS"; IP = "94.140.14.14" }
)

$testDomain = "www.google.com"
$results = @()

foreach ($dns in $dnsServers) {
    Write-Host "Testiram: $($dns.Ime) ($($dns.IP))..." -ForegroundColor DarkGray
    
    $totalTime = 0
    $successCount = 0
    
    # Radimo 3 upita i merimo prosek
    for ($i = 0; $i -lt 3; $i++) {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            # Resolve-DnsName sa definisanim serverom
            $res = Resolve-DnsName -Name $testDomain -Server $dns.IP -Type A -QuickQuery -Timeout 2 -ErrorAction Stop
            $stopwatch.Stop()
            $totalTime += $stopwatch.Elapsed.TotalMilliseconds
            $successCount++
        } catch {
            $stopwatch.Stop()
        }
    }
    
    if ($successCount -gt 0) {
        $avgTime = [Math]::Round($totalTime / $successCount, 1)
        $results += [PSCustomObject]@{
            DnsServer = $dns.Ime
            IPAdresa  = $dns.IP
            OdzivMs   = $avgTime
        }
    } else {
        $results += [PSCustomObject]@{
            DnsServer = $dns.Ime
            IPAdresa  = $dns.IP
            OdzivMs   = 9999 # Nedostupan
        }
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "             REZULTATI DNS BENCHMARK-A            " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
$results | Sort-Object -Property OdzivMs | Format-Table -AutoSize
Write-Host "Najbrži DNS je na vrhu tabele." -ForegroundColor Yellow