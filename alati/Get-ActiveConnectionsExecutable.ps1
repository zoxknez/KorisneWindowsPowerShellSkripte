[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-ActiveConnectionsExecutable.ps1 - Aktivne mrežne veze i nazivi programa
Write-Host "Prikupljanje podataka o aktivnim mrežnim vezama..." -ForegroundColor Cyan

$connections = @()
try {
    # Dobijamo mrežne konekcije sa PID-ovima
    $conns = Get-NetTCPConnection -State Established -ErrorAction Stop
    Write-Host "`nPronađeno $($conns.Count) aktivnih konekcija. Razrešavam nazive programa..." -ForegroundColor DarkGray
    
    foreach ($c in $conns) {
        $pid = $c.OwningProcess
        if ($pid -eq 0) { continue }
        
        # Razrešavanje PID-a u proces name
        $procName = "Nepoznato"
        try {
            $procName = (Get-Process -Id $pid).ProcessName
        } catch {}
        
        $connections += [PSCustomObject]@{
            Program = $procName
            PID = $pid
            LokalnaAdresa = "$($c.LocalAddress):$($c.LocalPort)"
            UdaljenaAdresa = "$($c.RemoteAddress):$($c.RemotePort)"
        }
    }
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "             AKTIVNE MREŽNE KONEKCIJE             " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    if ($connections.Count -gt 0) {
        $connections | Sort-Object -Property Program | Format-Table -AutoSize
    } else {
        Write-Host "Nema aktivnih uspostavljenih mrežnih konekcija." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri čitanju mrežnih konekcija: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan