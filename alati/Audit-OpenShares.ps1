[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Audit-OpenShares.ps1 - Pregled otvorenih mrežnih deljenja (Network Shares)
Write-Host "Proveravam aktivne mrežne deljene foldere na računaru..." -ForegroundColor Cyan

try {
    # Get-SmbShare je standard na modernom Windowsu
    $shares = Get-SmbShare -ErrorAction Stop
    
    Write-Host "`nTRENUTNO AKTIVNI NETWORK SHARES (Folderi deljeni na lokalnoj mreži):`n" -ForegroundColor Yellow
    
    $shareList = @()
    foreach ($s in $shares) {
        # Preskačemo administrativna deljenja koja Windows drži po defaultu (npr. C$, ADMIN$)
        if ($s.Name -match '\$$') {
            continue
        }
        
        $shareList += [PSCustomObject]@{
            NazivDeljenja = $s.Name
            LokalnaPutanja = $s.Path
            Opis = $s.Description
        }
    }
    
    if ($shareList.Count -gt 0) {
        $shareList | Format-Table -AutoSize
        Write-Host "Sigurnosno upozorenje: Bilo koji korisnik u lokalnoj mreži može pristupiti ovim folderima!" -ForegroundColor Red
    } else {
        Write-Host "[+] Nema deljenih foldera na mreži (sistem je siguran)." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri čitanju mrežnih deljenja: $($_.Exception.Message)" -ForegroundColor Red
}