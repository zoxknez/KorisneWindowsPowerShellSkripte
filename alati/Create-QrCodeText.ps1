# Create-QrCodeText.ps1 - Generisanje QR kodova iz konzole
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Text
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Enkodiranje teksta za URL
$encodedText = [System.Web.HttpUtility]::UrlEncode($Text)
# Ako System.Web.HttpUtility nije dostupan, radimo ručni fallback
if (-not $encodedText) {
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web")
    $encodedText = [System.Web.HttpUtility]::UrlEncode($Text)
}

# Koristimo besplatni javni API za QR kodove
$qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=$encodedText"

$tempFolder = [System.IO.Path]::GetTempPath()
$qrFilePath = Join-Path $tempFolder "qrcode.png"

Write-Host "Generišem QR kod za tekst/URL: '$Text'..." -ForegroundColor Cyan
Write-Host "Povezujem se sa API-jem..." -ForegroundColor DarkGray

# Isključujemo progres bar
$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

try {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($qrUrl, $qrFilePath)
    $ProgressPreference = $oldProgress
    
    Write-Host "`n[+] QR kod uspešno generisan i sačuvan!" -ForegroundColor Green
    Write-Host "Putanja slike: $qrFilePath" -ForegroundColor Yellow
    
    # Otvaramo sliku preko podrazumevanog preglednika
    Start-Process $qrFilePath
    Write-Host "Otvaram sliku QR koda..." -ForegroundColor DarkGray
} catch {
    $ProgressPreference = $oldProgress
    Write-Host "Greška pri preuzimanju QR koda: $($_.Exception.Message)" -ForegroundColor Red
}