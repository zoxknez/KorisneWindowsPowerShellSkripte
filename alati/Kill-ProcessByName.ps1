# Kill-ProcessByName.ps1 - Gašenje procesa po nazivu
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProcessName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pretraga procesa pod nazivom: '$ProcessName'..." -ForegroundColor Cyan

try {
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
} catch {
    Write-Host "Greška pri pretrazi procesa: $($_.Exception.Message)" -ForegroundColor Red
    return
}

if (-not $processes -or $processes.Count -eq 0) {
    Write-Host "Nije pronađen nijedan aktivan proces sa nazivom koji se poklapa sa '$ProcessName'." -ForegroundColor Green
    return
}

Write-Host "`nPronađeni procesi:" -ForegroundColor Yellow
$procList = @()

foreach ($proc in $processes) {
    $ramMB = [Math]::Round($proc.WorkingSet / 1MB, 2)
    $procList += [PSCustomObject]@{
        PID = $proc.Id
        Ime = $proc.ProcessName
        RAM_MB = $ramMB
        NaslovProzora = $proc.MainWindowTitle
    }
}

$procList | Format-Table -AutoSize

$totalRAM = ($procList | Measure-Object -Property RAM_MB -Sum).Sum
Write-Host "Ukupno procesa: $($procList.Count) | Ukupno zauzeće RAM-a: $([Math]::Round($totalRAM, 2)) MB" -ForegroundColor Yellow

$confirm = Read-Host "Da li ste sigurni da želite da ugasite sve navedene procese? (Y/N)"
if ($confirm.ToUpper() -eq "Y") {
    $killed = 0
    $errors = 0
    foreach ($proc in $processes) {
        try {
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
            $killed++
        } catch {
            Write-Host "Nije moguće ugasiti proces PID $($proc.Id) ($($proc.ProcessName)): $($_.Exception.Message)" -ForegroundColor Red
            $errors++
        }
    }
    Write-Host "`nOperacija završena!" -ForegroundColor Green
    Write-Host "Uspešno ugašeno: $killed procesa." -ForegroundColor Green
    if ($errors -gt 0) {
        Write-Host "Greške (nedostatak privilegija): $errors procesa." -ForegroundColor Red
        Write-Host "Pokušajte da pokrenete konzolu kao administrator ako neki procesi nisu ugašeni." -ForegroundColor Yellow
    }
} else {
    Write-Host "Operacija otkazana." -ForegroundColor Red
}