# Watch-FileIntegrity.ps1 - Nadzor integriteta fajlova preko SHA-256 heša
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [switch]$UpdateBaseline
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

# Putanja do baze podataka integriteta (čuvanje u istom folderu)
$dbPath = Join-Path $Path ".file_integrity_db.json"

# Dobijanje samo fajlova (ignorišemo samu bazu i node_modules/.git foldere)
function Get-FilesToWatch {
    param([string]$dir)
    return Get-ChildItem -Path $dir -File -Recurse -Force -ErrorAction SilentlyContinue |
           Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.next)\\' -and $_.Name -ne ".file_integrity_db.json" }
}

# 1. Kreiranje/Ažuriranje baze heševa
if ($UpdateBaseline -or -not (Test-Path $dbPath)) {
    Write-Host "Kreiranje nove heš baze (Baseline) za: $Path..." -ForegroundColor Cyan
    $files = Get-FilesToWatch -dir $Path
    
    if ($files.Count -eq 0) {
        Write-Host "Nema fajlova za nadzor." -ForegroundColor Yellow
        return
    }
    
    $baseline = @{}
    foreach ($file in $files) {
        Write-Host "Heširam: $($file.Name)..." -ForegroundColor DarkGray
        try {
            $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
            $baseline[$file.FullName] = $hash
        } catch {}
    }
    
    $json = ConvertTo-Json -InputObject $baseline
    $json | Set-Content -Path $dbPath -Encoding utf8 -Force
    
    Write-Host "`n[+] Baseline uspešno kreiran i snimljen u: $dbPath" -ForegroundColor Green
    Write-Host "Ukupno fajlova u bazi: $($baseline.Count)" -ForegroundColor Gold
    return
}

# 2. Verifikacija integriteta
Write-Host "Verifikacija integriteta fajlova na osnovu baze..." -ForegroundColor Cyan
try {
    $rawJson = Get-Content -Path $dbPath -Raw
    $baseline = ConvertFrom-Json -InputObject $rawJson -AsHashtable
} catch {
    Write-Host "Greška pri čitanju baze podataka integriteta. Izbrišite .file_integrity_db.json i pokrenite skriptu ponovo." -ForegroundColor Red
    return
}

$currentFiles = Get-FilesToWatch -dir $Path
$currentHashes = @{}
$addedFiles = @()
$modifiedFiles = @()

# Skeniranje trenutnih fajlova i provera izmena
foreach ($file in $currentFiles) {
    try {
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        $currentHashes[$file.FullName] = $hash
        
        if (-not $baseline.ContainsKey($file.FullName)) {
            $addedFiles += $file.FullName
        } elseif ($baseline[$file.FullName] -ne $hash) {
            $modifiedFiles += $file.FullName
        }
    } catch {}
}

# Pronalaženje obrisanih fajlova
$deletedFiles = @()
foreach ($key in $baseline.Keys) {
    if (-not $currentHashes.ContainsKey($key)) {
        $deletedFiles += $key
    }
}

# Prikaz izveštaja
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "               IZVEŠTAJ O INTEGRITETU             " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$hasAlerts = $false

if ($addedFiles.Count -gt 0) {
    Write-Host "[!] DODATI FAJLOVI (Nisu u baseline-u) ($($addedFiles.Count)):" -ForegroundColor Yellow
    $addedFiles | ForEach-Object { Write-Host "  [+] $_" -ForegroundColor Green }
    $hasAlerts = $true
}

if ($modifiedFiles.Count -gt 0) {
    Write-Host "[!] MODIFIKOVANI FAJLOVI (Razlikuje se heš) ($($modifiedFiles.Count)):" -ForegroundColor Red -BackgroundColor Black
    $modifiedFiles | ForEach-Object { Write-Host "  [X] $_" -ForegroundColor Red }
    $hasAlerts = $true
}

if ($deletedFiles.Count -gt 0) {
    Write-Host "[!] OBRISANI FAJLOVI (Postoje samo u bazi) ($($deletedFiles.Count)):" -ForegroundColor DarkGray
    $deletedFiles | ForEach-Object { Write-Host "  [-] $_" -ForegroundColor DarkGray }
    $hasAlerts = $true
}

if (-not $hasAlerts) {
    Write-Host "[+] INTEGRITET JE U REDU: Svi fajlovi se poklapaju sa bazom!" -ForegroundColor Green
    Write-Host "Nije detektovana nijedna neautorizovana promena sadržaja." -ForegroundColor Green
} else {
    Write-Host "`nUpozorenje: Detektovane su promene u folderu!" -ForegroundColor Red
    Write-Host "Ako su ove promene namerne, pokrenite skriptu sa parametrom -UpdateBaseline da ažurirate bazu." -ForegroundColor Yellow
}
Write-Host "==================================================" -ForegroundColor Cyan