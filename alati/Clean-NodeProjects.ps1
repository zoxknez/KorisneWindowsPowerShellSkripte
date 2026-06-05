# Clean-NodeProjects.ps1 - Čišćenje node_modules i build foldera
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Skeniranje putanje: $Path..." -ForegroundColor Cyan

if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

# Ciljni folderi za brisanje
$targets = @("node_modules", "dist", ".next", "build", ".nuxt", "out", "target", "cache", "pkg")

# Efikasno skeniranje bez ulaženja u foldere koje već planiramo da obrišemo
function Get-TargetFolders {
    param([string]$currentPath)
    $found = @()
    try {
        $items = Get-ChildItem -Path $currentPath -Directory -Force -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            if ($targets -contains $item.Name.ToLower()) {
                $found += $item
            } else {
                $found += Get-TargetFolders -currentPath $item.FullName
            }
        }
    } catch {}
    return $found
}

$foundFolders = Get-TargetFolders -currentPath $Path

if ($foundFolders.Count -eq 0) {
    Write-Host "Nisu pronađeni projektni folderi za čišćenje." -ForegroundColor Green
    return
}

Write-Host "`nPronađeni folderi za čišćenje:" -ForegroundColor Yellow
$totalSize = 0
$folderList = @()

foreach ($folder in $foundFolders) {
    Write-Host "Računanje veličine: $($folder.FullName)..." -ForegroundColor DarkGray
    $size = 0
    try {
        $files = Get-ChildItem -Path $folder.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
        foreach ($file in $files) { $size += $file.Length }
    } catch {}
    
    $totalSize += $size
    $sizeMB = [Math]::Round($size / 1MB, 2)
    
    $folderList += [PSCustomObject]@{
        Putanja = $folder.FullName
        VelicinaMB = $sizeMB
    }
}

$folderList | Format-Table -AutoSize

$totalSizeGB = [Math]::Round($totalSize / 1GB, 2)
Write-Host "Ukupna veličina za brisanje: $totalSizeGB GB ($([Math]::Round($totalSize / 1MB, 2)) MB)" -ForegroundColor Yellow

$confirm = Read-Host "Da li ste sigurni da želite da obrišete ove foldere? (Y/N)"
if ($confirm.ToUpper() -eq "Y") {
    $deletedCount = 0
    $errorCount = 0
    foreach ($folder in $foundFolders) {
        Write-Host "Brišem: $($folder.FullName)..." -ForegroundColor White
        try {
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction Stop
            $deletedCount++
        } catch {
            Write-Host "Greška pri brisanju $($folder.FullName): $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }
    Write-Host "`nČišćenje završeno!" -ForegroundColor Green
    Write-Host "Uspešno obrisano: $deletedCount foldera." -ForegroundColor Green
    if ($errorCount -gt 0) {
        Write-Host "Greške pri brisanju: $errorCount foldera (verovatno su zaključani procesima)." -ForegroundColor Red
    }
    Write-Host "Oslobođeno oko $totalSizeGB GB." -ForegroundColor Yellow
} else {
    Write-Host "Operacija otkazana." -ForegroundColor Red
}