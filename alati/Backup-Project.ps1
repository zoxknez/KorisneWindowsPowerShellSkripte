# Backup-Project.ps1 - Pametan bekap projekata
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    [Parameter(Mandatory = $false)]
    [string]$DestinationPath = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Provera putanja
if (-not (Test-Path $SourcePath)) {
    Write-Host "Izvorna putanja ne postoji!" -ForegroundColor Red
    return
}

$sourceDirName = (Get-Item $SourcePath).Name
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipName = "${sourceDirName}_backup_${timestamp}.zip"
$zipFilePath = Join-Path $DestinationPath $zipName

Write-Host "Započinjem pametan bekap..." -ForegroundColor Cyan
Write-Host "Izvor: $SourcePath" -ForegroundColor White
Write-Host "Cilj: $zipFilePath" -ForegroundColor White

# Kreiranje privremenog foldera za robocopy
$tempDir = Join-Path $DestinationPath "backup_temp_$timestamp"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "Filtriranje i kopiranje fajlova (preskakanje node_modules, .git, dist, build, .next)..." -ForegroundColor DarkGray

# Folderi koje preskačemo
$excludeDirs = "node_modules" , ".git" , "dist" , "build" , ".next" , ".nuxt" , "out" , "target" , "obj" , "bin"
# Fajlovi koje preskačemo (npr. već postojeći zip fajlovi)
$excludeFiles = "*.zip" , "*.7z" , "*.rar"

# Robocopy komanda
$rcParams = @(
    $SourcePath,
    $tempDir,
    "/E",
    "/XD"
) + $excludeDirs + @(
    "/XF"
) + $excludeFiles + @(
    "/R:0",
    "/W:0",
    "/NFL",
    "/NDL"
)

# Pokretanje robocopy-ja
$process = Start-Process robocopy -ArgumentList $rcParams -Wait -NoNewWindow -PassThru
if ($process.ExitCode -ge 8) {
    Write-Host "Greška prilikom kopiranja fajlova preko Robocopy (Exit Code: $($process.ExitCode))." -ForegroundColor Red
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    return
}

Write-Host "Kreiranje ZIP arhive..." -ForegroundColor DarkGray
try {
    $items = Get-ChildItem -Path $tempDir
    if ($items.Count -eq 0) {
        Write-Host "Nema fajlova za bekap nakon filtriranja!" -ForegroundColor Yellow
    } else {
        Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFilePath -Force -ErrorAction Stop
        $zipSize = (Get-Item $zipFilePath).Length
        $zipSizeMB = [Math]::Round($zipSize / 1MB, 2)
        Write-Host "Bekap uspešno završen!" -ForegroundColor Green
        Write-Host "Veličina arhive: $zipSizeMB MB" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška prilikom kompresije arhive: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Write-Host "Čišćenje privremenih fajlova..." -ForegroundColor DarkGray
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}