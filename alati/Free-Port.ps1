# Free-Port.ps1 - Oslobađanje mrežnih portova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$Port
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pretraga procesa na portu ${Port}..." -ForegroundColor Cyan

# Pronalaženje PID-a na zadatom portu
$connections = @()
try {
    if (Get-Command Get-NetTCPConnection -ErrorAction SilentlyContinue) {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    } else {
        # Alternativa za starije verzije PowerShell-a
        $netstat = netstat -ano | Select-String "LISTENING" | Select-String ":$Port\s"
        foreach ($line in $netstat) {
            if ($line -match '\s+(\d+)$') {
                $connections += [PSCustomObject]@{ OwningProcess = [int]$Matches[1] }
            }
        }
    }
} catch {
    Write-Host "Greška pri pretrazi mrežnih konekcija: $($_.Exception.Message)" -ForegroundColor Red
    return
}

if ($connections.Count -eq 0) {
    Write-Host "Nijedan proces ne koristi port ${Port}." -ForegroundColor Green
    return
}

# Uzimanje jedinstvenih PID-ova
$pids = $connections | ForEach-Object { $_.OwningProcess } | Select-Object -Unique

Write-Host "`nPronađeni procesi na portu ${Port}:" -ForegroundColor Yellow
$processList = @()

foreach ($pid in $pids) {
    if ($pid -eq 0) { continue }
    try {
        $proc = Get-Process -Id $pid -ErrorAction Stop
        $processList += [PSCustomObject]@{
            PID = $pid
            ImeProcesa = $proc.ProcessName
            NaslovProzora = $proc.MainWindowTitle
            Putanja = $proc.Path
        }
    } catch {
        $processList += [PSCustomObject]@{
            PID = $pid
            ImeProcesa = "Nepoznat (Sistemski/Admin)"
            NaslovProzora = "N/A"
            Putanja = "N/A"
        }
    }
}

$processList | Format-Table -AutoSize

foreach ($p in $processList) {
    $confirm = Read-Host "Da li želite da ugasite proces $($p.ImeProcesa) (PID: $($p.PID))? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        try {
            Stop-Process -Id $p.PID -Force -ErrorAction Stop
            Write-Host "Proces $($p.ImeProcesa) (PID: $($p.PID)) je uspešno ugašen." -ForegroundColor Green
        } catch {
            Write-Host "Greška pri gašenju procesa: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "Pokušajte da pokrenete skriptu kao administrator." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Gašenje procesa $($p.ImeProcesa) je preskočeno." -ForegroundColor DarkGray
    }
}