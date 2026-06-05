# Convert-UrlEncodeDecode.ps1 - Enkodiranje i dekodiranje URL stringova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Text,
    [Parameter(Mandatory = $false)]
    [switch]$Decode
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


try {
    # Učitavanje sklopova za rad sa webom
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web")
    
    if ($Decode) {
        Write-Host "DEKODIRANJE URL-a:" -ForegroundColor Cyan
        $result = [System.Web.HttpUtility]::UrlDecode($Text)
    } else {
        Write-Host "ENKODIRANJE URL-a:" -ForegroundColor Cyan
        $result = [System.Web.HttpUtility]::UrlEncode($Text)
    }
    
    Write-Host "Original : $Text" -ForegroundColor White
    Write-Host "Rezultat : " -NoNewline -ForegroundColor White
    Write-Host $result -ForegroundColor Green
    
    # Kopiranje u clipboard
    $result | clip.exe
    Write-Host "`nRezultat je uspešno kopiran u Clipboard!" -ForegroundColor DarkGray
} catch {
    Write-Host "Greška pri konverziji: $($_.Exception.Message)" -ForegroundColor Red
}