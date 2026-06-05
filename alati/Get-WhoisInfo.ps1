# Get-WhoisInfo.ps1 - Vraćanje WHOIS informacija o domenu
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Čišćenje naziva domena od HTTP/HTTPS
$domain = $DomainName.Replace("https://", "").Replace("http://", "").Split("/")[0]

Write-Host "Preuzimam WHOIS informacije za domen: $domain..." -ForegroundColor Cyan

try {
    # Koristimo besplatni javni WHOIS API
    $url = "https://rdap.org/domain/$domain"
    Write-Host "Šaljem RDAP upit..." -ForegroundColor DarkGray
    
    $oldProgress = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    $info = Invoke-RestMethod -Uri $url -TimeoutSec 5
    $ProgressPreference = $oldProgress
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "                 WHOIS PODACI (RDAP)              " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "Domen:       $($info.ldhName)" -ForegroundColor Green
    Write-Host "Status:      $($info.status -join ', ')" -ForegroundColor White
    
    # Pronalaženje datuma registracije/isteka
    foreach ($event in $info.events) {
        if ($event.eventAction -eq "registration") {
            Write-Host "Registrovan: $($event.eventDate)" -ForegroundColor White
        }
        if ($event.eventAction -eq "expiration") {
            Write-Host "Ističe:      $($event.eventDate)" -ForegroundColor Yellow
        }
    }
    
    # Registar (Registrar)
    $registrar = $info.entities | Where-Object { $_.roles -contains "registrar" }
    if ($registrar) {
        Write-Host "Registar:    $($registrar.vcardArray[1][1][3])" -ForegroundColor White
    }
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    $ProgressPreference = $oldProgress
    Write-Host "Greška: Nije moguće preuzeti WHOIS podatke. Proverite naziv domena." -ForegroundColor Red
}