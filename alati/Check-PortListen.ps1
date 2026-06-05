[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Check-PortListen.ps1 - Prikaz portova koji čekaju vezu (Listening Ports)
Write-Host "Učitavam sve lokalne portove koji čekaju vezu (Listening)..." -ForegroundColor Cyan

try {
    # Get-NetTCPConnection sa stanjem Listen
    $conns = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
    
    $portList = @()
    foreach ($c in $conns) {
        $pid = $c.OwningProcess
        if ($pid -eq 0) { continue }
        
        $procName = "Nepoznato"
        try {
            $procName = (Get-Process -Id $pid).ProcessName
        } catch {}
        
        $portList += [PSCustomObject]@{
            Port = $c.LocalPort
            Program = $procName
            PID = $pid
            Adresa = $c.LocalAddress
        }
    }
    
    Write-Host "`nAktivni slušajući portovi (Listening Ports):`n" -ForegroundColor Yellow
    if ($portList.Count -gt 0) {
        $portList | Sort-Object -Property Port | Format-Table -AutoSize
    } else {
        Write-Host "Nema aktivnih portova u stanju Listen." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri čitanju portova: $($_.Exception.Message)" -ForegroundColor Red
}