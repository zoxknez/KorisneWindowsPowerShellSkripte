# Backup-FilesToCloud.ps1 - Automatska sinhronizacija i bekap u Cloud foldere (OneDrive/Google Drive)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LocalPath,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("OneDrive", "GoogleDrive")]
    [string]$CloudType = "OneDrive"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $LocalPath)) {
    Write-Host "Lokalna putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Sinhronizujem folder sa Cloud servisom ($CloudType)..." -ForegroundColor Cyan

# Detekcija putanje Cloud foldera
$cloudPath = ""
if ($CloudType -eq "OneDrive") {
    # OneDrive putanja se nalazi u environmentu ili registrima
    $cloudPath = $env:OneDriveConsumer
    if (-not $cloudPath) { $cloudPath = $env:OneDrive }
} else {
    # Google Drive po defaultu pravi virtuelni disk G:\ ili folder pod UserProfile
    $gDriveDisk = "G:\My Drive"
    $gDriveFolder = Join-Path $env:USERPROFILE "Google Drive"
    
    if (Test-Path $gDriveDisk) { $cloudPath = $gDriveDisk }
    elseif (Test-Path $gDriveFolder) { $cloudPath = $gDriveFolder }
}

if (-not $cloudPath -or -not (Test-Path $cloudPath)) {
    Write-Host "Greška: Putanja za Cloud servis ($CloudType) nije automatski detektovana!" -ForegroundColor Red
    Write-Host "Proverite da li je aplikacija ($CloudType) instalirana i pokrenuta." -ForegroundColor Yellow
    return
}

# Pravimo folder za bekap unutar Cloud-a
$cloudBackupFolder = Join-Path $cloudPath "AutomatedBackups"
if (-not (Test-Path $cloudBackupFolder)) {
    New-Item -ItemType Directory -Path $cloudBackupFolder -Force | Out-Null
}

$localDirName = (Get-Item $LocalPath).Name
$destination = Join-Path $cloudBackupFolder $localDirName

Write-Host "Lokalna putanja : $LocalPath" -ForegroundColor White
Write-Host "Cloud odredište : $destination" -ForegroundColor White
Write-Host "`nPokrećem pametnu sinhronizaciju preko Robocopy..." -ForegroundColor DarkGray

try {
    # Robocopy /MIR ogledalo (Mirror) - briše iz Cloud-a ono što je obrisano lokalno
    # /R:0 /W:0 - bez ponavljanja za zaključane fajlove
    $process = Start-Process robocopy -ArgumentList @(
        $LocalPath,
        $destination,
        "/MIR",
        "/R:0",
        "/W:0",
        "/XD", "node_modules", ".git", "dist", "build",
        "/NFL", "/NDL"
    ) -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -lt 8) {
        Write-Host "`n[+] Sinhronizacija uspešno završena!" -ForegroundColor Green
        Write-Host "Vaši fajlovi su bezbedno prebačeni u Cloud i biće automatski sinhronizovani." -ForegroundColor Gold
    } else {
        Write-Host "Došlo je do delimičnih grešaka tokom Robocopy sinhronizacije (Exit Code: $($process.ExitCode))." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri sinhronizaciji: $($_.Exception.Message)" -ForegroundColor Red
}