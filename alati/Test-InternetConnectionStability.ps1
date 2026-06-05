[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Test-InternetConnectionStability.ps1 - Provera stabilnosti i džitera internet veze
Write-Host "Pokrećem dugotrajni test stabilnosti internet veze (merenje džitera)..." -ForegroundColor Cyan
Write-Host "Test meri varijaciju latencije (jitter) ka Cloudflare DNS (1.1.1.1)." -ForegroundColor DarkGray
Write-Host "Pritisnite bilo koji taster za završetak testa...`n" -ForegroundColor Yellow

$latencies = @()
$packetLoss = 0
$totalPings = 0

try {
    while (-not [System.Console]::KeyAvailable) {
        $totalPings++
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $ping = Test-Connection -ComputerName "1.1.1.1" -Count 1 -Timeout 1 -ErrorAction Stop
            $stopwatch.Stop()
            $ms = $stopwatch.Elapsed.TotalMilliseconds
            $latencies += $ms
            
            # Vizuelni prikaz
            Write-Host "Ping $($totalPings): " -NoNewline -ForegroundColor DarkGray
            Write-Host "$([Math]::Round($ms, 1)) ms" -ForegroundColor Green
        } catch {
            $stopwatch.Stop()
            $packetLoss++
            Write-Host "Ping $($totalPings): " -NoNewline -ForegroundColor DarkGray
            Write-Host "GUBITAK PAKETA (Timeout)" -ForegroundColor Red
        }
        Start-Sleep -Seconds 1
    }
    # Čišćenje bafera tastature
    $null = [System.Console]::ReadKey($true)
    
    if ($latencies.Count -gt 1) {
        # Računanje džitera (prosečna razlika između susednih pingova)
        $diffSum = 0
        for ($i = 0; $i -lt ($latencies.Count - 1); $i++) {
            $diffSum += [Math]::Abs($latencies[$i] - $latencies[$i+1])
        }
        $jitter = [Math]::Round($diffSum / ($latencies.Count - 1), 2)
        $avgPing = [Math]::Round(($latencies | Measure-Object -Average).Average, 1)
        $maxPing = [Math]::Round(($latencies | Measure-Object -Maximum).Maximum, 1)
        $minPing = [Math]::Round(($latencies | Measure-Object -Minimum).Minimum, 1)
        $lossPercent = [Math]::Round(($packetLoss / $totalPings) * 100, 1)
        
        Write-Host "`n==================================================" -ForegroundColor Cyan
        Write-Host "             STATISTIKA STABILNOSTI VEZE          " -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Prosečna latencija: $avgPing ms" -ForegroundColor White
        Write-Host "Minimalna / Maks. : $minPing ms / $maxPing ms" -ForegroundColor White
        Write-Host "Džiter (Jitter)   : " -NoNewline -ForegroundColor White
        
        if ($jitter -lt 5) {
            Write-Host "$jitter ms (Izuzetno stabilna veza/Gejming)" -ForegroundColor Green
        } elseif ($jitter -lt 15) {
            Write-Host "$jitter ms (Srednja stabilnost)" -ForegroundColor Yellow
        } else {
            Write-Host "$jitter ms (Visok džiter - Nestabilna veza/Paketi kasne)" -ForegroundColor Red
        }
        
        Write-Host "Gubitak paketa    : $packetLoss od $totalPings ($lossPercent%)" -ForegroundColor (if ($packetLoss -gt 0) {"Red"} else {"Green"})
        Write-Host "==================================================" -ForegroundColor Cyan
    }
} catch {
    Write-Host "`nTest prekinut." -ForegroundColor Red
}