[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-SystemUptimeHistory.ps1 - Uptime i istorija gašenja računara
Write-Host "Analiziram sistemske Event logove..." -ForegroundColor Cyan

# Trenutni uptime
$wmi = Get-CimInstance Win32_OperatingSystem
$lastBoot = $wmi.LastBootUpTime
$uptime = (Get-Date) - $lastBoot
$uptimeStr = "$($uptime.Days) dana, $($uptime.Hours) sati, $($uptime.Minutes) minuta"

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "            TRENUTNI RAD SISTEMA (UPTIME)         " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Zadnji boot (paljenje) : $($lastBoot.ToString('dd.MM.yyyy HH:mm:ss'))" -ForegroundColor White
Write-Host "Uptime (ukupno vreme)  : " -NoNewline -ForegroundColor White
Write-Host "$uptimeStr" -ForegroundColor Green

# Analiza istorije restarta i rušenja iz Event Loga (poslednjih 30 dana)
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "        ISTORIJA GAŠENJA I RESTARTOVANJA (30 DANA) " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

try {
    # Čitamo Event ID 6005 (pokretanje Event loga / boot), 6006 (čisto gašenje), 6008 (neočekivano gašenje / rušenje)
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        Id = 6005, 6006, 6008
        StartTime = (Get-Date).AddDays(-30)
    } -ErrorAction Stop
    
    $history = @()
    foreach ($e in $events) {
        $tip = switch ($e.Id) {
            6005 { "Uključivanje računara (Boot)" }
            6006 { "Normalno gašenje (Shutdown)" }
            6008 { "NEOČEKIVANO GAŠENJE / CRASH" }
        }
        $color = if ($e.Id -eq 6008) { "Red" } else { "White" }
        
        $history += [PSCustomObject]@{
            Vreme = $e.TimeCreated
            Dogadjaj = $tip
            ID = $e.Id
        }
    }
    
    # Sortiramo hronološki (najnoviji događaji na vrhu)
    $history | Sort-Object -Property Vreme -Descending | Format-Table -AutoSize
    
    # Sumarna statistika rušenja
    $crashes = $history | Where-Object { $_.ID -eq 6008 }
    Write-Host "`nStatistika u poslednjih 30 dana:" -ForegroundColor Yellow
    Write-Host "  - Ukupno startovanja sistema : $($history.Where({$_.ID -eq 6005}).Count)" -ForegroundColor White
    Write-Host "  - Ukupno neočekivanih rušenja: " -NoNewline -ForegroundColor White
    if ($crashes.Count -gt 0) {
        Write-Host "$($crashes.Count)" -ForegroundColor Red -BackgroundColor Black
    } else {
        Write-Host "0 (Sistem je stabilan!)" -ForegroundColor Green
    }
} catch {
    Write-Host "  Nije moguće učitati Event logove (nedovoljne privilegije ili su logovi očišćeni)." -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan