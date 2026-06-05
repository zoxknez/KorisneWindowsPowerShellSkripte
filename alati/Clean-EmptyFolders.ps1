# Clean-EmptyFolders.ps1 - Rekurzivno brisanje praznih foldera
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

Write-Host "Pretraga praznih foldera u: $Path..." -ForegroundColor Cyan

# Rekurzivna funkcija koja briše prazne foldere od najdubljih ka plićim
# (jer brisanjem praznog podfoldera roditeljski folder može takođe postati prazan!)
function Remove-EmptyDirectories {
    param([string]$targetDir)
    
    $deletedCount = 0
    try {
        # Prvo čistimo prazne foldere u poddirektorijumima
        $subDirs = Get-ChildItem -Path $targetDir -Directory -Force -ErrorAction SilentlyContinue
        foreach ($sd in $subDirs) {
            $deletedCount += Remove-EmptyDirectories -targetDir $sd.FullName
        }
        
        # Nakon čišćenja poddirektorijuma, proveravamo da li je trenutni folder sada prazan
        $items = Get-ChildItem -Path $targetDir -Force -ErrorAction SilentlyContinue
        if ($items.Count -eq 0 -and $targetDir -ne $Path) {
            Write-Host "Brišem prazan folder: $targetDir" -ForegroundColor DarkGray
            Remove-Item -Path $targetDir -Force -ErrorAction Stop
            $deletedCount++
        }
    } catch {}
    return $deletedCount
}

$confirm = Read-Host "Da li ste sigurni da želite da obrišete sve prazne foldere u $Path? (Y/N)"
if ($confirm.ToUpper() -eq "Y") {
    $totalDeleted = Remove-EmptyDirectories -targetDir $Path
    Write-Host "`nČišćenje praznih foldera završeno!" -ForegroundColor Green
    Write-Host "Ukupno obrisano praznih foldera: $totalDeleted" -ForegroundColor Gold
} else {
    Write-Host "Operacija otkazana." -ForegroundColor Red
}