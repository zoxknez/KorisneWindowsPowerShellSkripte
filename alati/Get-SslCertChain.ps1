# Get-SslCertChain.ps1 - Preuzimanje kompletnog SSL lanca sa sajta
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DomainName
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


$domain = $DomainName.Replace("https://", "").Replace("http://", "").Split("/")[0]

Write-Host "Preuzimam lanac SSL sertifikata za: $domain..." -ForegroundColor Cyan

try {
    $client = New-Object System.Net.Sockets.TcpClient
    $client.Connect($domain, 443)
    
    $sslStream = New-Object System.Net.Security.SslStream(
        $client.GetStream(), 
        $false, 
        ({ $true } -as [System.Net.Security.RemoteCertificateValidationCallback])
    )
    $sslStream.AuthenticateAsClient($domain)
    
    # Dobijanje sertifikata
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    # Konfiguracija lanca da preuzme sve sertifikate
    $chain.ChainPolicy.RevocationMode = [System.Security.Cryptography.X509Certificates.X509RevocationMode]::NoCheck
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
    
    $null = $chain.Build($cert)
    
    Write-Host "`nLanac sertifikata (Certificate Chain):`n" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $chain.ChainElements.Count; $i++) {
        $element = $chain.ChainElements[$i]
        $c = $element.Certificate
        Write-Host "Nivo $($i): $($c.Subject)" -ForegroundColor Green
        Write-Host "  Izdavač (Issuer) : $($c.Issuer)" -ForegroundColor White
        Write-Host "  Serijski Broj    : $($c.SerialNumber)" -ForegroundColor White
        Write-Host "  Važi do          : $($c.NotAfter.ToString('dd.MM.yyyy'))" -ForegroundColor White
        Write-Host ""
    }
    
    $client.Close()
} catch {
    Write-Host "Greška pri preuzimanju lanca SSL sertifikata: $($_.Exception.Message)" -ForegroundColor Red
}