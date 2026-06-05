[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Get-SystemSerialNumbers.ps1 - Brzi prikaz serijskih brojeva računara
Write-Host "Čitam serijske brojeve uređaja sa matične ploče i BIOS-a..." -ForegroundColor Cyan

try {
    $bios = Get-CimInstance Win32_BIOS
    $system = Get-CimInstance Win32_ComputerSystemProduct
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "              SERIJSKI BROJEVI ZA GARANCIJU       " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Serijski broj računara (BIOS): $($bios.SerialNumber)" -ForegroundColor Green
    Write-Host "Serijski broj kućišta (UUID) : $($system.UUID)" -ForegroundColor White
    Write-Host "Model računara               : $($system.Name)" -ForegroundColor White
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška pri očitavanju serijskih brojeva: $($_.Exception.Message)" -ForegroundColor Red
}