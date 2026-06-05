# Block-IpAddress.ps1 - Brza blokada IP adresa u Firewall-u
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IPAddress
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Blokiranje IP adresa u Firewall-u zahteva Administratorske privilegije." -ForegroundColor Red
    return
}

Write-Host "Blokiram dolazni i odlazni saobraćaj za IP adresu: $IPAddress..." -ForegroundColor Cyan

try {
    $ruleNameIn = "BLOKADA_IP_INBOUND_$IPAddress"
    $ruleNameOut = "BLOKADA_IP_OUTBOUND_$IPAddress"
    
    # Kreiranje pravila za blokiranje ulaznog i izlaznog saobraćaja
    New-NetFirewallRule -DisplayName $ruleNameIn -Direction Inbound -RemoteAddress $IPAddress -Action Block -ErrorAction Stop | Out-Null
    New-NetFirewallRule -DisplayName $ruleNameOut -Direction Outbound -RemoteAddress $IPAddress -Action Block -ErrorAction Stop | Out-Null
    
    Write-Host "`n[+] IP Adresa $IPAddress je uspešno BLOKIRANA!" -ForegroundColor Green
    Write-Host "Pravila kreirana u Windows Firewall-u." -ForegroundColor DarkGray
} catch {
    Write-Host "Greška pri kreiranju pravila: $($_.Exception.Message)" -ForegroundColor Red
}