# Search-FilenameWildcard.ps1 - Napredna pretraga fajlova po nazivima i filterima
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $true)]
    [string]$Pattern,
    [Parameter(Mandatory = $false)]
    [long]$MinSizeKb = 0
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Pretraga fajlova u: $Path..." -ForegroundColor Cyan
Write-Host "Filter (Pattern)  : $Pattern" -ForegroundColor White
if ($MinSizeKb -gt 0) {
    Write-Host "Minimalna veličina: $MinSizeKb KB" -ForegroundColor White
}

try {
    # Pronalazimo sve fajlove koji odgovaraju šablonu
    $files = Get-ChildItem -Path $Path -Filter $Pattern -Recurse -File -Force -ErrorAction SilentlyContinue
    
    # Filtriranje po veličini
    if ($MinSizeKb -gt 0) {
        $files = $files | Where-Object { $_.Length -ge ($MinSizeKb * 1KB) }
    }
    
    Write-Host "`nRezultati pretrage (ukupno pronađeno $($files.Count) fajlova):`n" -ForegroundColor Yellow
    
    if ($files.Count -gt 0) {
        $display = $files | ForEach-Object {
            $sizeKB = [Math]::Round($_.Length / 1KB, 1)
            $sizeStr = if ($sizeKB -ge 1024) { "$([Math]::Round($sizeKB/1024, 2)) MB" } else { "$sizeKB KB" }
            [PSCustomObject]@{
                Naziv = $_.Name
                Velicina = $sizeStr
                Izmenjen = $_.LastWriteTime.ToString("dd.MM.yyyy HH:mm")
                Putanja = $_.DirectoryName
            }
        }
        $display | Format-Table -AutoSize
    } else {
        Write-Host "Nije pronađen nijedan fajl koji odgovara kriterijumima." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška tokom pretrage fajlova: $($_.Exception.Message)" -ForegroundColor Red
}