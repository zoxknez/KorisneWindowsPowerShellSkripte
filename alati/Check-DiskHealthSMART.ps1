[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Check-DiskHealthSMART.ps1 - SMART zdravlje i status diskova
Write-Host "Provera zdravlja SSD, NVMe i HDD diskova..." -ForegroundColor Cyan

# Zahteva administratorske privilegije za čitanje detaljnih SMART parametara preko WMI
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Upozorenje: Pokrenite skriptu kao Administrator za potpuniji SMART izveštaj.`n" -ForegroundColor Yellow
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "                IZVEŠTAJ O ZDRAVLJU DISKOVA       " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Osnovni status diskova preko Get-PhysicalDisk (Windows 8/10+)
try {
    $physDisks = Get-PhysicalDisk -ErrorAction Stop
    foreach ($disk in $physDisks) {
        $healthColor = switch ($disk.HealthStatus) {
            "Healthy" { "Green" }
            "Warning" { "Yellow" }
            "Unhealthy" { "Red" }
            default { "White" }
        }
        Write-Host "Disk #$($disk.DeviceId): $($disk.FriendlyName)" -ForegroundColor White
        Write-Host "  Tip medija     : $($disk.MediaType)" -ForegroundColor White
        Write-Host "  Zdravstveni status: " -NoNewline -ForegroundColor White
        Write-Host "$($disk.HealthStatus)" -ForegroundColor $healthColor
        Write-Host "  Operativni status : $($disk.OperationalStatus)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "Greška pri čitanju fizičkih diskova: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. SMART Failure Prediction status (WMI)
if ($isAdmin) {
    Write-Host "Provera SMART predikcije otkaza (Failure Prediction)..." -ForegroundColor Yellow
    try {
        $failureStatus = Get-CimInstance -Namespace root\wmi -ClassName MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue
        if ($failureStatus) {
            foreach ($drive in $failureStatus) {
                Write-Host "  Putanja pogona : $($drive.InstanceName)" -ForegroundColor DarkGray
                if ($drive.PredictFailure) {
                    Write-Host "  [ALARM] Disk predviđa OTKAZ! Bezbjednosno kopirajte podatke ODMAH!" -ForegroundColor Red -BackgroundColor Black
                    Write-Host "  SMART kod greške: $($drive.Reason)" -ForegroundColor Red
                } else {
                    Write-Host "  [+] Disk radi ispravno (SMART ne predviđa greške)." -ForegroundColor Green
                }
                Write-Host ""
            }
        } else {
            Write-Host "  SMART podaci o predikciji grešaka nisu dostupni." -ForegroundColor DarkGray
        }
    } catch {
        Write-Host "  Nije moguće učitati SMART Failure Predict parametre." -ForegroundColor Red
    }
}
Write-Host "==================================================" -ForegroundColor Cyan