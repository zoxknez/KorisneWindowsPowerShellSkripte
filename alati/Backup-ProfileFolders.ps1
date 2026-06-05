# Backup-ProfileFolders.ps1 - Bekap korisničkih foldera (Desktop, Documents, Downloads)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$DestPath = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $DestPath)) {
    Write-Host "Odredišna putanja ne postoji!" -ForegroundColor Red
    return
}

$desktop = [Environment]::GetFolderPath("Desktop")
$documents = [Environment]::GetFolderPath("MyDocuments")
$downloads = Join-Path $env:USERPROFILE "Downloads"

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipPath = Join-Path $DestPath "KorisnickiProfil_Backup_$timestamp.zip"
$tempDir = Join-Path $DestPath "profile_backup_temp_$timestamp"

Write-Host "Započinjem bekap korisničkog profila..." -ForegroundColor Cyan
Write-Host "Desktop   : $desktop" -ForegroundColor DarkGray
Write-Host "Dokumenti : $documents" -ForegroundColor DarkGray
Write-Host "Preuzimanja: $downloads" -ForegroundColor DarkGray
Write-Host "Odredište : $zipPath" -ForegroundColor DarkGray

try {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Kopiramo foldere u privremeni prostor
    Write-Host "`nKopiram Desktop..." -ForegroundColor Yellow
    $dTemp = Join-Path $tempDir "Desktop"
    Robocopy.exe $desktop $dTemp /E /R:0 /W:0 /NFL /NDL /NJH /NJS /XD "node_modules" ".git" | Out-Null
    
    Write-Host "Kopiram Dokumente..." -ForegroundColor Yellow
    $docTemp = Join-Path $tempDir "Documents"
    Robocopy.exe $documents $docTemp /E /R:0 /W:0 /NFL /NDL /NJH /NJS /XD "node_modules" ".git" | Out-Null
    
    Write-Host "Kopiram Preuzimanja..." -ForegroundColor Yellow
    $downTemp = Join-Path $tempDir "Downloads"
    Robocopy.exe $downloads $downTemp /E /R:0 /W:0 /NFL /NDL /NJH /NJS /XD "node_modules" ".git" | Out-Null
    
    Write-Host "Kreiram ZIP arhivu (ovo može potrajati)..." -ForegroundColor Cyan
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force -ErrorAction Stop
    
    $sizeMB = [Math]::Round((Get-Item $zipPath).Length / 1MB, 2)
    Write-Host "`n[+] Bekap uspešno završen!" -ForegroundColor Green
    Write-Host "Sačuvano u: $zipPath (Veličina: $sizeMB MB)" -ForegroundColor Yellow
} catch {
    Write-Host "Greška tokom bekapa profila: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if (Test-Path $tempDir) {
        Write-Host "Čišćenje privremenih fajlova..." -ForegroundColor DarkGray
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}