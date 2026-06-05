# Convert-TextEncoding.ps1 - Masovna konverzija kodiranja tekstualnih fajlova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $true)]
    [ValidateSet("utf8", "ascii", "unicode", "utf32")]
    [string]$TargetEncoding,
    [Parameter(Mandatory = $false)]
    [string]$Filter = "*.txt"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

$files = Get-ChildItem -Path $Path -Filter $Filter -File -Force -ErrorAction SilentlyContinue

if ($files.Count -eq 0) {
    Write-Host "Nema fajlova koji odgovaraju filteru '$Filter' u folderu: $Path" -ForegroundColor Yellow
    return
}

Write-Host "Konvertujem enkodiranje za $($files.Count) fajlova u: $TargetEncoding..." -ForegroundColor Cyan

$success = 0
$errors = 0

foreach ($file in $files) {
    try {
        # Čitamo sadržaj
        $content = Get-Content -Path $file.FullName -Raw
        
        # Pišemo nazad u novom formatu
        $content | Set-Content -Path $file.FullName -Encoding $TargetEncoding -Force
        $success++
    } catch {
        Write-Host "Greška na fajlu $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host "`nKonverzija enkodiranja završena!" -ForegroundColor Green
Write-Host "Uspešno konvertovano: $success | Greške: $errors" -ForegroundColor Yellow