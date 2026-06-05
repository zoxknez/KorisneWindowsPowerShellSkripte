[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-WindowsUpdatesStatus.ps1 - Pregled statusa i istorije Windows Update-a
Write-Host "Čitam istoriju instaliranih Windows Update zakrpa..." -ForegroundColor Cyan

try {
    # Kreiranje COM objekta za rad sa Windows Update agentom
    $searcher = New-Object -ComObject "Microsoft.Update.Searcher"
    $historyCount = $searcher.GetTotalHistoryCount()
    
    Write-Host "`nUkupno instaliranih zakrpa u istoriji: $historyCount`n" -ForegroundColor Yellow
    
    if ($historyCount -gt 0) {
        $history = $searcher.QueryHistory(0, 15)
        
        $updateList = @()
        foreach ($h in $history) {
            $status = switch ($h.ResultCode) {
                2 { "USPEŠNO" }
                3 { "Greška" }
                4 { "Otkazano" }
                default { "Nepoznato" }
            }
            $color = if ($h.ResultCode -eq 2) { "Green" } else { "Red" }
            
            Write-Host "Datum: " -NoNewline -ForegroundColor White
            Write-Host "$($h.Date.ToString('dd.MM.yyyy HH:mm'))" -ForegroundColor Cyan -NoNewline
            Write-Host " | Status: " -NoNewline -ForegroundColor White
            Write-Host "$status" -ForegroundColor $color -NoNewline
            Write-Host " | Naslov: $($h.Title)" -ForegroundColor White
        }
    }
} catch {
    Write-Host "Nije moguće učitati istoriju Windows ažuriranja: $($_.Exception.Message)" -ForegroundColor Red
}