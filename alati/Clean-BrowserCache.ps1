# Clean-BrowserCache.ps1 - Čišćenje keša za Chrome, Edge i Firefox pretraživače
Write-Host "Započinjem čišćenje keša i privremenih fajlova pretraživača..." -ForegroundColor Cyan

$localApp = $env:LOCALAPPDATA
$roamingApp = $env:APPDATA
$freedBytes = 0

function Clean-FolderPattern {
    param(
        [string]$folderPath,
        [string]$browserName
    )
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $freed = 0
    if (Test-Path $folderPath) {
        Write-Host "  Čistim keš za: $browserName..." -ForegroundColor DarkGray
        try {
            $files = Get-ChildItem -Path $folderPath -Recurse -File -Force -ErrorAction SilentlyContinue
            foreach ($f in $files) {
                try {
                    $freed += $f.Length
                    Remove-Item -Path $f.FullName -Force -ErrorAction Stop | Out-Null
                } catch {}
            }
        } catch {}
    }
    return $freed
}

# 1. Google Chrome
$chromeCache = Join-Path $localApp "Google\Chrome\User Data\Default\Cache\Cache_Data"
$freedBytes += Clean-FolderPattern -folderPath $chromeCache -browserName "Google Chrome"

# 2. Microsoft Edge
$edgeCache = Join-Path $localApp "Microsoft\Edge\User Data\Default\Cache\Cache_Data"
$freedBytes += Clean-FolderPattern -folderPath $edgeCache -browserName "Microsoft Edge"

# 3. Mozilla Firefox
$firefoxProfiles = Join-Path $localApp "Mozilla\Firefox\Profiles"
if (Test-Path $firefoxProfiles) {
    $profiles = Get-ChildItem -Path $firefoxProfiles -Directory -ErrorAction SilentlyContinue
    foreach ($p in $profiles) {
        $pCache = Join-Path $p.FullName "cache2"
        $freedBytes += Clean-FolderPattern -folderPath $pCache -browserName "Mozilla Firefox ($($p.Name))"
    }
}

$freedMB = [Math]::Round($freedBytes / 1MB, 2)
Write-Host "`n[+] Čišćenje keša pretraživača završeno!" -ForegroundColor Green
Write-Host "Oslobođeno oko $freedMB MB memorije." -ForegroundColor Yellow