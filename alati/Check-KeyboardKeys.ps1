[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Check-KeyboardKeys.ps1 - Test ispravnosti tastera na tastaturi
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "                TESTER TASTERA (KEYBOARD)         " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Pritiskajte tastere na tastaturi. Na ekranu će se ispisivati kodovi." -ForegroundColor White
Write-Host "Pritisnite 'Esc' za izlaz iz testa.`n" -ForegroundColor Yellow

try {
    do {
        # Provera da li je pritisnut taster
        $keyInfo = [System.Console]::ReadKey($true)
        
        Write-Host "Pritisnut taster: " -NoNewline -ForegroundColor White
        Write-Host "$($keyInfo.Key.ToString().PadRight(15))" -ForegroundColor Green -NoNewline
        Write-Host " | Kod tastera (Char): " -NoNewline -ForegroundColor White
        Write-Host "$($keyInfo.KeyChar)" -ForegroundColor Yellow -NoNewline
        Write-Host " | Modifikatori: $($keyInfo.Modifiers)" -ForegroundColor Gray
        
    } while ($keyInfo.Key -ne [System.ConsoleKey]::Escape)
    
    Write-Host "`nTest tastature završen." -ForegroundColor Green
} catch {
    Write-Host "Ova konzola ne podržava direktan unos tastera." -ForegroundColor Red
}