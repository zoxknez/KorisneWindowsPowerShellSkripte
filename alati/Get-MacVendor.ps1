# Get-MacVendor.ps1 - Detekcija proizvođača mrežne kartice na osnovu MAC adrese
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MacAddress
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Čišćenje MAC adrese od dvotački, crtica
$cleanMac = $MacAddress.Replace(":", "").Replace("-", "").Replace(".", "").Substring(0, 6).ToUpper()

Write-Host "Pretražujem proizvođača za MAC prefiks: $cleanMac..." -ForegroundColor Cyan

$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

try {
    # Koristimo besplatni javni API za MAC lookup
    $url = "https://api.macvendors.com/$cleanMac"
    $vendor = Invoke-RestMethod -Uri $url -TimeoutSec 3 -ErrorAction Stop
    $ProgressPreference = $oldProgress
    
    Write-Host "`nRezultat pretrage:" -ForegroundColor Yellow
    Write-Host "  MAC Adresa  : $MacAddress" -ForegroundColor White
    Write-Host "  Proizvođač  : " -NoNewline -ForegroundColor White
    Write-Host $vendor -ForegroundColor Green
} catch {
    $ProgressPreference = $oldProgress
    Write-Host "`n[-] Proizvođač nije pronađen ili je API privremeno nedostupan." -ForegroundColor Red
}