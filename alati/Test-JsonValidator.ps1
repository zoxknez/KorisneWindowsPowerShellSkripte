# Test-JsonValidator.ps1 - Validacija JSON strukture i pretraga grešaka
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$JsonPath
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $JsonPath)) {
    Write-Host "Fajl ne postoji: $JsonPath" -ForegroundColor Red
    return
}

Write-Host "Validacija JSON fajla: $JsonPath..." -ForegroundColor Cyan

try {
    $rawContent = Get-Content -Path $JsonPath -Raw -ErrorAction Stop
    $null = ConvertFrom-Json -InputObject $rawContent -ErrorAction Stop
    Write-Host "`n[+] JSON JE VALIDAN! Struktura je ispravna." -ForegroundColor Green
} catch {
    Write-Host "`n[-] JSON NIJE VALIDAN! Pronađene su greške u sintaksi." -ForegroundColor Red
    Write-Host "Detalji greške: " -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor White
}