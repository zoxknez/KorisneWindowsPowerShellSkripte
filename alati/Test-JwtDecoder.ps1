# Test-JwtDecoder.ps1 - Dekodiranje JWT tokena na lokalnoj mašini
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$JwtToken
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# JWT se sastoji od tri dela razdvojena tačkom: Header.Payload.Signature
$parts = $JwtToken.Split(".")

if ($parts.Length -ne 3) {
    Write-Host "Greška: Uneti tekst nije validan JWT token (nedostaju delovi razdvojeni tačkom)!" -ForegroundColor Red
    return
}

# Pomoćna funkcija za bezbedno Base64Url dekodiranje
function Decode-Base64Url {
    param([string]$base64UrlStr)
    
    # Zamena karaktera koji se koriste u Base64Url
    $base64Str = $base64UrlStr.Replace('-', '+').Replace('_', '/')
    
    # Dodavanje padding-a (=) ako je potrebno
    switch ($base64Str.Length % 4) {
        2 { $base64Str += "==" }
        3 { $base64Str += "=" }
    }
    
    try {
        $bytes = [System.Convert]::FromBase64String($base64Str)
        return [System.Text.Encoding]::UTF8.GetString($bytes)
    } catch {
        return "GREŠKA PRI DEKODIRANJU"
    }
}

Write-Host "Dekodiram JWT token..." -ForegroundColor Cyan

$headerJson = Decode-Base64Url -base64UrlStr $parts[0]
$payloadJson = Decode-Base64Url -base64UrlStr $parts[1]

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "                 JWT ZAGLAVLJE (HEADER)           " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
try {
    # Lep prikaz JSON-a
    $headerObj = ConvertFrom-Json $headerJson
    $headerObj | ConvertTo-Json | Write-Host -ForegroundColor Green
} catch {
    Write-Host $headerJson -ForegroundColor Green
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "                 JWT SADRŽAJ (PAYLOAD)            " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
try {
    $payloadObj = ConvertFrom-Json $payloadJson
    $payloadObj | ConvertTo-Json | Write-Host -ForegroundColor Green
} catch {
    Write-Host $payloadJson -ForegroundColor Green
}
Write-Host "==================================================" -ForegroundColor Cyan