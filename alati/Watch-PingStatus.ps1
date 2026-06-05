# Watch-PingStatus.ps1 - Neprekidni ping sa vizuelnom statistikom
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HostName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Neprekidni ping ka hostu: $HostName" -ForegroundColor Cyan
Write-Host "Pritisnite bilo koji taster za kraj testa...`n" -ForegroundColor Yellow

$pingCount = 0
$successCount = 0
$failCount = 0

try {
    while (-not [System.Console]::KeyAvailable) {
        $pingCount++
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        try {
            $ping = Test-Connection -ComputerName $HostName -Count 1 -Timeout 1 -ErrorAction Stop
            $stopwatch.Stop()
            $time = [Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 1)
            $successCount++
            
            Write-Host "[$pingCount] " -NoNewline -ForegroundColor DarkGray
            Write-Host "ODGOVOR " -NoNewline -ForegroundColor Green
            Write-Host "od $($HostName): vreme = " -NoNewline -ForegroundColor White
            Write-Host "$time ms" -ForegroundColor Green
        } catch {
            $stopwatch.Stop()
            $failCount++
            Write-Host "[$pingCount] " -NoNewline -ForegroundColor DarkGray
            Write-Host "PREKID KONEKCIJE / TIMEOUT" -ForegroundColor Red
            
            # Zvučni signal na prekid konekcije
            [System.Console]::Beep(1000, 300)
        }
        
        Start-Sleep -Seconds 1
    }
    # Čišćenje bafera tastature
    $null = [System.Console]::ReadKey($true)
    
    # Finalna statistika
    $percentLoss = [Math]::Round(($failCount / $pingCount) * 100, 1)
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                 STATISTIKA PING-A                " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Ukupno poslato    : $pingCount paketa" -ForegroundColor White
    Write-Host "Uspešnih odgovora : $successCount" -ForegroundColor Green
    Write-Host "Izgubljenih paketa: $failCount ($percentLoss% gubitka)" -ForegroundColor Red
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "`nPing prekinut." -ForegroundColor Red
}