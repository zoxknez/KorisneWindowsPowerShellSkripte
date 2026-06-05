[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Audit-StartupPaths.ps1 - Bezbednosna revizija svih Startup lokacija
Write-Host "Skeniram Startup lokacije (programe koji se pokreću pri startu)..." -ForegroundColor Cyan

$startupItems = @()

# 1. Provera Startup foldera u profilu
$userStartup = [Environment]::GetFolderPath("Startup")
if (Test-Path $userStartup) {
    Get-ChildItem -Path $userStartup -File | ForEach-Object {
        $startupItems += [PSCustomObject]@{
            Lokacija = "Startup Folder (User)"
            Naziv = $_.Name
            Putanja = $_.FullName
        }
    }
}

# 2. Provera sistemskog Startup foldera
$commonStartup = [Environment]::GetFolderPath("CommonStartup")
if (Test-Path $commonStartup) {
    Get-ChildItem -Path $commonStartup -File | ForEach-Object {
        $startupItems += [PSCustomObject]@{
            Lokacija = "Startup Folder (System)"
            Naziv = $_.Name
            Putanja = $_.FullName
        }
    }
}

# 3. Provera registra (Run ključevi)
$regPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($rp in $regPaths) {
    if (Test-Path $rp) {
        $key = Get-Item -Path $rp
        $props = Get-ItemProperty -Path $rp
        foreach ($valName in $key.GetValueNames()) {
            $startupItems += [PSCustomObject]@{
                Lokacija = "Registry ($($rp.Split(':')[0]))"
                Naziv = $valName
                Putanja = $props.$valName
            }
        }
    }
}

Write-Host "`nPronađeni programi koji se pokreću pri startu sistema:" -ForegroundColor Yellow
if ($startupItems.Count -gt 0) {
    $startupItems | Format-Table -AutoSize
    Write-Host "`nSavet: Ukoliko primetite sumnjive programe koje ne prepoznajete, obrišite ih kako biste ubrzali paljenje računara." -ForegroundColor Yellow
} else {
    Write-Host "Nema registrovanih programa u startup-u." -ForegroundColor Green
}