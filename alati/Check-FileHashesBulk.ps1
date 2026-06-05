# Check-FileHashesBulk.ps1 - Masovna provera heševa (MD5/SHA-256) za listu fajlova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [ValidateSet("SHA256", "MD5")]
    [string]$Algorithm = "SHA256"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Računam $Algorithm heš vrednosti za fajlove u: $Path..." -ForegroundColor Cyan

try {
    $files = Get-ChildItem -Path $Path -File -Force -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-Host "Nema fajlova u folderu." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nRezultati heširanja:" -ForegroundColor Yellow
    
    $results = @()
    foreach ($file in $files) {
        Write-Host "Heširam: $($file.Name)..." -ForegroundColor DarkGray
        try {
            $hash = (Get-FileHash -Path $file.FullName -Algorithm $Algorithm).Hash
            $results += [PSCustomObject]@{
                Fajl = $file.Name
                Hes  = $hash
            }
        } catch {}
    }
    
    $results | Format-Table -AutoSize
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}