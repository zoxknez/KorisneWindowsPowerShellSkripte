# Check-CronFormat.ps1 - Prikaz sledećih vremena izvršavanja na osnovu Cron izraza
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CronExpression
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Analiziram Cron izraz: $CronExpression..." -ForegroundColor Cyan

# Osnovna polja cron izraza: minuta, sat, dan u mesecu, mesec, dan u nedelji
$parts = $CronExpression.Split(" ")
if ($parts.Length -ne 5) {
    Write-Host "Greška: Cron izraz mora imati tačno 5 polja razdvojenih razmakom!" -ForegroundColor Red
    Write-Host "Format: 'minut sat dan_u_mesecu mesec dan_u_nedelji'" -ForegroundColor Yellow
    return
}

# Za pravu verifikaciju cron izraza u PowerShell-u bez eksternih paketa,
# možemo uraditi laganu proveru formata i generisati prognozu za najjednostavnije slučajeve
try {
    Write-Host "`nSledeća potencijalna vremena izvršavanja (simulirano):" -ForegroundColor Yellow
    
    $now = Get-Date
    $count = 0
    
    # Vrlo jednostavna simulacija za standardne šablone poput '*/5 * * * *', '0 0 * * *' i sl.
    # Prolazimo kroz narednih 5 sati minutu po minutu i proveravamo da li odgovara
    for ($i = 0; $i -lt 300; $i++) {
        $t = $now.AddMinutes($i)
        
        $matchMin  = ($parts[0] -eq "*") -or ($parts[0] -match '^\*/(\d+)$' -and $t.Minute % [int]$Matches[1] -eq 0) -or ($parts[0] -eq $t.Minute.ToString())
        $matchHour = ($parts[1] -eq "*") -or ($parts[1] -match '^\*/(\d+)$' -and $t.Hour % [int]$Matches[1] -eq 0) -or ($parts[1] -eq $t.Hour.ToString())
        
        # Dan u mesecu i mesec se pretpostavlja da se poklapaju za osnovne testove
        if ($matchMin -and $matchHour) {
            Write-Host "  - $($t.ToString('dd.MM.yyyy HH:mm:00'))" -ForegroundColor Green
            $count++
            if ($count -ge 5) { break }
        }
    }
    
    if ($count -eq 0) {
        Write-Host "Za složenije cron izraze koristite eksterne online alate poput crontab.guru." -ForegroundColor DarkGray
    }
} catch {
    Write-Host "Greška pri analizi cron izraza: $($_.Exception.Message)" -ForegroundColor Red
}