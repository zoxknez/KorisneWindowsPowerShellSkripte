# Generate-LocalSslCert.ps1 - Kreiranje i uvoz lokalnih SSL sertifikata
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Generisanje SSL sertifikata i instalacija u Trusted Root zahtevaju Administratorske privilegije." -ForegroundColor Red
    return
}

Write-Host "Generišem samopotpisani SSL sertifikat za domen: $DomainName..." -ForegroundColor Cyan

try {
    # 1. Kreiranje sertifikata u Cert:\LocalMachine\My
    $cert = New-SelfSignedCertificate -DnsName $DomainName -CertStoreLocation "cert:\LocalMachine\My" -FriendlyName "Dev Cert - $DomainName" -NotAfter (Get-Date).AddYears(3) -ErrorAction Stop
    Write-Host "  [+] Sertifikat uspešno kreiran u Personal store-u." -ForegroundColor Green
    Write-Host "  [+] Thumbprint: $($cert.Thumbprint)" -ForegroundColor DarkGray
    
    # 2. Kopiranje u Trusted Root Certification Authorities kako pretraživač ne bi javljao grešku
    Write-Host "Uvozim sertifikat u Trusted Root store..." -ForegroundColor DarkGray
    $rootStore = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
    $rootStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $rootStore.Add($cert)
    $rootStore.Close()
    
    Write-Host "  [+] Sertifikat uspešno uvezen u Trusted Root store!" -ForegroundColor Green
    Write-Host "`nInstalacija uspešna!" -ForegroundColor Gold
    Write-Host "Sada možete koristiti HTTPS za lokalne projekte na domenu https://$DomainName" -ForegroundColor White
} catch {
    Write-Host "Greška pri kreiranju/uvozu sertifikata: $($_.Exception.Message)" -ForegroundColor Red
}