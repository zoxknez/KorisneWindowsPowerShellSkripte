# Find-LargeFiles.ps1 - Pronalaženje najvećih fajlova i foldera
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [int]$TopCount = 20
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Skeniranje putanje: $Path..." -ForegroundColor Cyan

# 1. Pronalaženje najvećih fajlova rekurzivno
Write-Host "`nSkeniranje fajlova (ovo može potrajati za velike diskove)..." -ForegroundColor DarkGray
$largeFiles = @()
try {
    $largeFiles = Get-ChildItem -Path $Path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Sort-Object -Property Length -Descending |
        Select-Object -First $TopCount
} catch {
    Write-Host "Greška pri skeniranju fajlova: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Pronalaženje najvećih direktnih podfoldera
Write-Host "Skeniranje direktnih podfoldera..." -ForegroundColor DarkGray
$subFolders = @()
try {
    $directSubfolders = Get-ChildItem -Path $Path -Directory -Force -ErrorAction SilentlyContinue
    foreach ($dir in $directSubfolders) {
        $size = 0
        $files = Get-ChildItem -Path $dir.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
        foreach ($f in $files) { $size += $f.Length }
        
        $subFolders += [PSCustomObject]@{
            Naziv = $dir.Name
            Putanja = $dir.FullName
            VelicinaB = $size
        }
    }
    $largeFolders = $subFolders | Sort-Object -Property VelicinaB -Descending | Select-Object -First 10
} catch {
    Write-Host "Greška pri skeniranju foldera: $($_.Exception.Message)" -ForegroundColor Red
}

# Prikaz najvećih foldera
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "        TOP 10 NAJVEĆIH DIREKTNIH PODFOLDERA      " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
if ($largeFolders.Count -gt 0) {
    $folderDisplay = $largeFolders | ForEach-Object {
        $sizeMB = [Math]::Round($_.VelicinaB / 1MB, 2)
        $sizeGB = [Math]::Round($_.VelicinaB / 1GB, 2)
        $sizeStr = if ($sizeGB -ge 1) { "$sizeGB GB" } else { "$sizeMB MB" }
        [PSCustomObject]@{
            Folder = $_.Naziv
            Velicina = $sizeStr
            Putanja = $_.Putanja
        }
    }
    $folderDisplay | Format-Table -AutoSize
} else {
    Write-Host "Nisu pronađeni podfolderi." -ForegroundColor White
}

# Prikaz najvećih fajlova
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "         TOP ${TopCount} NAJVEĆIH FAJLOVA REKURZIVNO        " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
if ($largeFiles.Count -gt 0) {
    $fileDisplay = $largeFiles | ForEach-Object {
        $sizeMB = [Math]::Round($_.Length / 1MB, 2)
        $sizeGB = [Math]::Round($_.Length / 1GB, 2)
        $sizeStr = if ($sizeGB -ge 1) { "$sizeGB GB" } else { "$sizeMB MB" }
        [PSCustomObject]@{
            Fajl = $_.Name
            Velicina = $sizeStr
            Folder = $_.DirectoryName
        }
    }
    $fileDisplay | Format-Table -AutoSize
} else {
    Write-Host "Nisu pronađeni fajlovi." -ForegroundColor White
}