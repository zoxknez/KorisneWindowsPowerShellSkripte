[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Monitor-ResourcesDashboard.ps1 - Real-time terminalski resurs menadžer
Write-Host "Pokretanje Resource Dashboard-a..." -ForegroundColor Cyan
Write-Host "Pritisnite bilo koji taster u konzoli da zaustavite praćenje..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

$cpuCounter = $null
try {
    # Inicijalizacija brojača
    $cpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
    $null = $cpuCounter.NextValue() # Prvo očitavanje je uvek 0
} catch {}

try {
    while (-not [System.Console]::KeyAvailable) {
        Clear-Host
        
        # Očitavanje CPU %
        $cpuVal = 0
        if ($cpuCounter) {
            $cpuVal = [Math]::Round($cpuCounter.NextValue(), 1)
        } else {
            # Sporiji fallback ako performance counteri ne rade
            $cpuVal = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
        }
        
        # Očitavanje RAM %
        $os = Get-CimInstance Win32_OperatingSystem
        $freeRam = $os.FreePhysicalMemory
        $totalRam = $os.TotalVisibleMemorySize
        $usedRam = $totalRam - $freeRam
        $ramPercent = [Math]::Round(($usedRam / $totalRam) * 100, 1)
        
        # Prikaz zaglavlja
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "           SYSTEM MONITOR REAL-TIME DASHBOARD     " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Vreme osvežavanja: $(Get-Date -Format 'HH:mm:ss') | Pritisnite taster za izlaz`n" -ForegroundColor DarkGray
        
        # CPU ProgressBar
        Write-Host "CPU opterećenje: $cpuVal %" -ForegroundColor White
        $cpuBlocks = [Math]::Min(50, [Math]::Max(0, [int]($cpuVal / 2)))
        $cpuColor = if ($cpuVal -gt 85) { "Red" } elseif ($cpuVal -gt 50) { "Yellow" } else { "Green" }
        Write-Host "[" -NoNewline -ForegroundColor White
        Write-Host ("#" * $cpuBlocks) -NoNewline -ForegroundColor $cpuColor
        Write-Host ("." * (50 - $cpuBlocks)) -NoNewline -ForegroundColor DarkGray
        Write-Host "]"
        
        # RAM ProgressBar
        $usedRamGB = [Math]::Round($usedRam / 1MB, 2)
        $totalRamGB = [Math]::Round($totalRam / 1MB, 2)
        Write-Host "`nRAM memorija: $ramPercent % ($usedRamGB GB / $totalRamGB GB)" -ForegroundColor White
        $ramBlocks = [Math]::Min(50, [Math]::Max(0, [int]($ramPercent / 2)))
        $ramColor = if ($ramPercent -gt 85) { "Red" } elseif ($ramPercent -gt 60) { "Yellow" } else { "Green" }
        Write-Host "[" -NoNewline -ForegroundColor White
        Write-Host ("#" * $ramBlocks) -NoNewline -ForegroundColor $ramColor
        Write-Host ("." * (50 - $ramBlocks)) -NoNewline -ForegroundColor DarkGray
        Write-Host "]"
        
        # Aktivni procesi i mrežne veze
        $processesCount = (Get-Process).Count
        $tcpConnections = 0
        try {
            $tcpConnections = (Get-NetTCPConnection -ErrorAction SilentlyContinue).Count
        } catch {}
        
        Write-Host "`nOstali detalji:" -ForegroundColor Yellow
        Write-Host "  - Pokrenutih procesa : $processesCount" -ForegroundColor White
        Write-Host "  - Aktivnih TCP veza  : $tcpConnections" -ForegroundColor White
        Write-Host "==================================================" -ForegroundColor Cyan
        
        Start-Sleep -Seconds 1
    }
    # Čišćenje tastera iz bafera
    $null = [System.Console]::ReadKey($true)
} finally {
    Write-Host "`nPraćenje resursa zaustavljeno." -ForegroundColor Red
}