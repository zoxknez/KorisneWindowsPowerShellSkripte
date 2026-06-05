[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-WindowsFeatures.ps1 - Upravljanje Windows opcionim komponentama (WSL, IIS...)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Izmena Windows komponenti zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

try {
    # Dobijamo listu uobičajenih Windows opcija preko DISM-a
    Write-Host "Učitavam Windows komponente (Features)..." -ForegroundColor Cyan
    $features = Get-WindowsOptionalFeature -Online |
                Where-Object { $_.FeatureName -match "Subsystem-Linux|Hyper-V|IIS-WebServerRole|Containers|VirtualMachinePlatform" }
                
    Write-Host "`nStatus važnih Windows komponenti:`n" -ForegroundColor Yellow
    
    $featList = @()
    for ($i = 0; $i -lt $features.Count; $i++) {
        $f = $features[$i]
        $color = if ($f.State -eq "Enabled") { "Green" } else { "Red" }
        Write-Host "$($i + 1). " -NoNewline -ForegroundColor White
        Write-Host "$($f.FeatureName.PadRight(35))" -ForegroundColor Cyan -NoNewline
        Write-Host " | Status: " -NoNewline -ForegroundColor White
        Write-Host "$($f.State)" -ForegroundColor $color
        $featList += $f
    }
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "Upišite broj komponente da biste promenili njen status (ili 'Q' za izlaz):" -ForegroundColor Yellow
    $choice = Read-Host "Izbor"
    
    if ($choice -match '^\d+$') {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $featList.Count) {
            $selected = $featList[$idx]
            
            if ($selected.State -eq "Enabled") {
                Write-Host "Onemogućavam $($selected.FeatureName)..." -ForegroundColor Yellow
                Disable-WindowsOptionalFeature -Online -FeatureName $selected.FeatureName -NoRestart
                Write-Host "Komponenta je uspešno onemogućena. Preporučuje se restart." -ForegroundColor Green
            } else {
                Write-Host "Omogućavam $($selected.FeatureName)..." -ForegroundColor Yellow
                Enable-WindowsOptionalFeature -Online -FeatureName $selected.FeatureName -NoRestart
                Write-Host "Komponenta je uspešno omogućena. Preporučuje se restart." -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "Greška pri radu sa DISM paketima: $($_.Exception.Message)" -ForegroundColor Red
}