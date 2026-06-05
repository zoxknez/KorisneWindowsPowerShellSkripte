# Create-Symlink.ps1 - Jednostavno kreiranje simboličkih linkova i junction-a
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$LinkPath,
    [Parameter(Mandatory = $true)]
    [string]$TargetPath
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $TargetPath)) {
    Write-Host "Greška: Ciljna putanja (Target) ne postoji: $TargetPath" -ForegroundColor Red
    return
}

if (Test-Path $LinkPath) {
    Write-Host "Greška: Link putanja (Link) već postoji: $LinkPath. Uklonite je ili izaberite drugo ime." -ForegroundColor Red
    return
}

$targetItem = Get-Item $TargetPath
$isFolder = $targetItem.PSIsContainer

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Host "Detektovan tip cilja: " -NoNewline -ForegroundColor Cyan
if ($isFolder) {
    Write-Host "Direktorijum (Folder)" -ForegroundColor Green
    Write-Host "`nIzaberite tip linka za direktorijum:" -ForegroundColor Yellow
    Write-Host "1. Directory Junction (Preporučeno - NE zahteva administratorska prava)"
    Write-Host "2. Symbolic Link (Zahteva administratorska prava)"
    
    $choice = Read-Host "Izbor (1-2)"
    
    if ($choice -eq "2") {
        if (-not $isAdmin) {
            Write-Host "Greška: Symbolic Link zahteva administratorska prava. Relaunchujte konzolu kao Administrator." -ForegroundColor Red
            return
        }
        $itemType = "SymbolicLink"
    } else {
        $itemType = "Junction"
    }
} else {
    Write-Host "Fajl" -ForegroundColor Green
    Write-Host "`nIzaberite tip linka za fajl:" -ForegroundColor Yellow
    Write-Host "1. Symbolic Link (Zahteva administratorska prava)"
    Write-Host "2. Hard Link (NE zahteva administratorska prava, radi samo na istom disku)"
    
    $choice = Read-Host "Izbor (1-2)"
    
    if ($choice -eq "2") {
        $itemType = "HardLink"
    } else {
        if (-not $isAdmin) {
            Write-Host "Greška: Symbolic Link za fajlove zahteva administratorska prava." -ForegroundColor Red
            return
        }
        $itemType = "SymbolicLink"
    }
}

Write-Host "`nKreiram $itemType..." -ForegroundColor Cyan
Write-Host "Link:   $LinkPath" -ForegroundColor White
Write-Host "Target: $TargetPath" -ForegroundColor White

try {
    $parentDir = Split-Path -Parent $LinkPath
    if ($parentDir -and -not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    New-Item -ItemType $itemType -Path $LinkPath -Value $TargetPath -ErrorAction Stop | Out-Null
    Write-Host "`nUspešno kreiran link!" -ForegroundColor Green
} catch {
    Write-Host "`nGreška pri kreiranju linka: $($_.Exception.Message)" -ForegroundColor Red
}