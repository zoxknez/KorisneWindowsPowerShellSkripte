[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Toggle-HiddenFiles.ps1 - Prikaz/sakrivanje skrivenih fajlova i ekstenzija
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Write-Host "Čitam trenutna podešavanja Windows Explorer-a..." -ForegroundColor Cyan

try {
    $hiddenState = Get-ItemProperty -Path $regPath -Name "Hidden" -ErrorAction Stop
    $hideExtState = Get-ItemProperty -Path $regPath -Name "HideFileExt" -ErrorAction Stop
    
    if ($hiddenState.Hidden -eq 2) {
        Write-Host "Trenutni status: Sakriveni fajlovi i ekstenzije su SAKRIVENI." -ForegroundColor Yellow
        Write-Host "Menjam na: VIDLJIVO (prikazuj skrivene fajlove, sistemske fajlove i ekstenzije)..." -ForegroundColor White
        
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value 1 -Force
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 0 -Force
        Set-ItemProperty -Path $regPath -Name "ShowSuperHidden" -Value 1 -Force
        
        $newState = "VIDLJIVI"
        $color = "Green"
    } else {
        Write-Host "Trenutni status: Sakriveni fajlovi i ekstenzije su VIDLJIVI." -ForegroundColor Yellow
        Write-Host "Menjam na: SAKRIVENO (sakrij sakrivene fajlove, sistemske fajlove i ekstenzije)..." -ForegroundColor White
        
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value 2 -Force
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value 1 -Force
        Set-ItemProperty -Path $regPath -Name "ShowSuperHidden" -Value 0 -Force
        
        $newState = "SAKRIVENI"
        $color = "Red"
    }
    
    Write-Host "Podešavanja u registru su uspešno promenjena." -ForegroundColor Green
    Write-Host "Osvežavam Windows Explorer..." -ForegroundColor DarkGray
    
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 1
    if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
        Start-Process explorer.exe
    }
    
    Write-Host "`nGotovo! Sakriveni fajlovi i ekstenzije su sada: " -NoNewline -ForegroundColor Green
    Write-Host $newState -ForegroundColor $color
} catch {
    Write-Host "Greška pri pristupu registrima: $($_.Exception.Message)" -ForegroundColor Red
}