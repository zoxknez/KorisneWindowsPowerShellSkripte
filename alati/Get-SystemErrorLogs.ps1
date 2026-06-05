[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-SystemErrorLogs.ps1 - Prikaz BSOD i kritičnih grešaka iz Event Viewer-a
Write-Host "Pretražujem Event Viewer za plave ekrane (BSOD) i kritične sistemske greške (poslednjih 30 dana)..." -ForegroundColor Cyan

try {
    # Filtriramo Event logove sa nivoom Error (2) i Critical (1) iz System loga
    $timeLimit = (Get-Date).AddDays(-30)
    
    Write-Host "Čitam sistemske greške..." -ForegroundColor DarkGray
    $logs = Get-WinEvent -FilterHashtable @{
        LogName   = 'System'
        Level     = 1, 2 # 1=Critical, 2=Error
        StartTime = $timeLimit
    } -ErrorAction SilentlyContinue
    
    if (-not $logs -or $logs.Count -eq 0) {
        Write-Host "Nema zabeleženih kritičnih grešaka u poslednjih 30 dana." -ForegroundColor Green
        return
    }
    
    Write-Host "`nUkupno pronađeno grešaka: $($logs.Count)" -ForegroundColor Yellow
    Write-Host "Prikazujem poslednjih 20 grešaka:`n" -ForegroundColor Yellow
    
    $display = @()
    foreach ($log in $logs | Select-Object -First 20) {
        # Provera da li je BSOD (Kernel-Power ili BugCheck)
        $isBsod = "Ne"
        if ($log.ProviderName -match "BugCheck|Kernel-Power" -and $log.Id -eq 41) {
            $isBsod = "DA (Neočekivan restart / BSOD)"
        }
        
        $display += [PSCustomObject]@{
            Vreme    = $log.TimeCreated.ToString("dd.MM.yyyy HH:mm")
            Izvor    = $log.ProviderName
            EventID  = $log.Id
            BSOD     = $isBsod
            Poruka   = $log.Message.Split("`n")[0].Trim()
        }
    }
    
    $display | Format-Table -AutoSize
} catch {
    Write-Host "Nije moguće pristupiti Event logovima (Event Log service možda nije pokrenut ili niste administrator)." -ForegroundColor Red
}