# Compare-Folders.ps1 - Poređenje dva direktorijuma rekurzivno
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PathA,
    [Parameter(Mandatory = $true)]
    [string]$PathB
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $PathA) -or -not (Test-Path $PathB)) {
    Write-Host "Obe putanje moraju postojati!" -ForegroundColor Red
    return
}

Write-Host "Skeniram i poredim foldere..." -ForegroundColor Cyan
Write-Host "Folder A: $PathA" -ForegroundColor White
Write-Host "Folder B: $PathB`n" -ForegroundColor White

try {
    # Dobijanje relativnih putanja za sve fajlove u oba foldera
    $filesA = Get-ChildItem -Path $PathA -File -Recurse -Force -ErrorAction SilentlyContinue
    $filesB = Get-ChildItem -Path $PathB -File -Recurse -Force -ErrorAction SilentlyContinue
    
    $dictA = @{}
    foreach ($f in $filesA) {
        $relPath = $f.FullName.Replace($PathA, "").TrimStart("\")
        $dictA[$relPath] = $f
    }
    
    $dictB = @{}
    foreach ($f in $filesB) {
        $relPath = $f.FullName.Replace($PathB, "").TrimStart("\")
        $dictB[$relPath] = $f
    }
    
    $onlyInA = @()
    $onlyInB = @()
    $differing = @()
    
    # Provera šta je samo u A i šta se razlikuje
    foreach ($key in $dictA.Keys) {
        if (-not $dictB.ContainsKey($key)) {
            $onlyInA += $key
        } else {
            $fileA = $dictA[$key]
            $fileB = $dictB[$key]
            
            # Prvo poredimo po veličini i datumu izmene (brza provera)
            if ($fileA.Length -ne $fileB.Length -or $fileA.LastWriteTime -ne $fileB.LastWriteTime) {
                # Ako se razlikuju, radimo SHA-256 heš za konačnu potvrdu
                $hashA = (Get-FileHash -Path $fileA.FullName -Algorithm SHA256).Hash
                $hashB = (Get-FileHash -Path $fileB.FullName -Algorithm SHA256).Hash
                
                if ($hashA -ne $hashB) {
                    $differing += [PSCustomObject]@{
                        Fajl = $key
                        VelicinaA = "$([Math]::Round($fileA.Length / 1KB, 2)) KB"
                        VelicinaB = "$([Math]::Round($fileB.Length / 1KB, 2)) KB"
                    }
                }
            }
        }
    }
    
    # Provera šta je samo u B
    foreach ($key in $dictB.Keys) {
        if (-not $dictA.ContainsKey($key)) {
            $onlyInB += $key
        }
    }
    
    # Prikaz rezultata
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "               REZULTATI POREĐENJA                " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    
    Write-Host "`n[+] Samo u folderu A ($($onlyInA.Count) fajlova):" -ForegroundColor Green
    $onlyInA | ForEach-Object { Write-Host "  - $_" }
    
    Write-Host "`n[+] Samo u folderu B ($($onlyInB.Count) fajlova):" -ForegroundColor Green
    $onlyInB | ForEach-Object { Write-Host "  - $_" }
    
    Write-Host "`n[!] Fajlovi koji se razlikuju po sadržaju ($($differing.Count) fajlova):" -ForegroundColor Yellow
    if ($differing.Count -gt 0) {
        $differing | Format-Table -AutoSize
    }
} catch {
    Write-Host "Greška pri poređenju foldera: $($_.Exception.Message)" -ForegroundColor Red
}