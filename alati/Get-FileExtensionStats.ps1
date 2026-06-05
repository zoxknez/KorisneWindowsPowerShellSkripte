# Get-FileExtensionStats.ps1 - Statistika zauzeća diska po ekstenzijama
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Skeniram folder i računam zauzeće po tipovima fajlova (ekstenzijama) u: $Path..." -ForegroundColor Cyan
Write-Host "Skeniranje u toku...`n" -ForegroundColor DarkGray

try {
    # Dobijamo sve fajlove rekurzivno
    $files = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-Host "Nema fajlova za analizu." -ForegroundColor Yellow
        return
    }
    
    # Grupišemo po ekstenzijama
    $groups = $files | Group-Object -Property Extension
    
    $stats = @()
    foreach ($g in $groups) {
        $ext = if ($g.Name) { $g.Name.ToLower() } else { "Bez ekstenzije" }
        
        # Sabiramo veličine fajlova u grupi
        $size = 0
        foreach ($file in $g.Group) { $size += $file.Length }
        
        $stats += [PSCustomObject]@{
            Ekstenzija = $ext
            BrojFajlova = $g.Count
            VelicinaB   = $size
            VelicinaMB  = [Math]::Round($size / 1MB, 2)
        }
    }
    
    Write-Host "ZAUZEĆE DISKA PO EKSTENZIJAMA:" -ForegroundColor Yellow
    # Sortiramo po ukupnoj veličini
    $stats | Sort-Object -Property VelicinaB -Descending | Format-Table -Property Ekstenzija, BrojFajlova, VelicinaMB -AutoSize
} catch {
    Write-Host "Greška pri analizi: $($_.Exception.Message)" -ForegroundColor Red
}