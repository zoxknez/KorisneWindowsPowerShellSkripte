# Check-WebsiteStatus.ps1 - Provera statusa veb sajtova i SSL sertifikata
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$Urls = @("https://www.google.com", "https://github.com", "https://news.ycombinator.com", "http://localhost:3000", "http://localhost:8080")
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Započinjem proveru statusa sajtova..." -ForegroundColor Cyan
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

foreach ($url in $Urls) {
    Write-Host "`nTestiranje: $url" -ForegroundColor White
    
    $uri = $null
    try {
        $uri = [System.Uri]$url
    } catch {
        try {
            $uri = [System.Uri]("https://" + $url)
        } catch {
            Write-Host "  [-] Neispravan URL format." -ForegroundColor Red
            continue
        }
    }

    $timeStart = Get-Date
    $statusCode = "NEDOSTUPAN"
    $statusColor = "Red"
    $responseTime = "-"
    
    try {
        $response = Invoke-WebRequest -Uri $uri.AbsoluteUri -Method Head -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $statusCode = [int]$response.StatusCode
        $responseTime = "$([Math]::Round(((Get-Date) - $timeStart).TotalMilliseconds)) ms"
        $statusColor = "Green"
    } catch {
        if ($_.Exception.Response) {
            $statusCode = [int]$_.Exception.Response.StatusCode
            $responseTime = "$([Math]::Round(((Get-Date) - $timeStart).TotalMilliseconds)) ms"
            $statusColor = "Yellow"
        } else {
            $statusCode = "NEDOSTUPAN ($($_.Exception.Message))"
            $statusColor = "Red"
        }
    }
    
    Write-Host "  Status: " -NoNewline -ForegroundColor White
    Write-Host "$statusCode" -ForegroundColor $statusColor -NoNewline
    Write-Host " | Odziv: $responseTime" -ForegroundColor White
    
    if ($uri.Scheme -eq "https" -and $statusCode -ne "NEDOSTUPAN") {
        $hostName = $uri.Host
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $tcpClient.Connect($hostName, 443)
            
            $sslStream = New-Object System.Net.Security.SslStream(
                $tcpClient.GetStream(), 
                $false, 
                ({ $true } -as [System.Net.Security.RemoteCertificateValidationCallback])
            )
            $sslStream.AuthenticateAsClient($hostName)
            
            $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
            $expirationDate = $cert.NotAfter
            $daysRemaining = ($expirationDate - (Get-Date)).Days
            
            $tcpClient.Close()
            
            Write-Host "  SSL Sertifikat: " -NoNewline -ForegroundColor White
            if ($daysRemaining -lt 7) {
                Write-Host "Ističe za $daysRemaining dana ($($expirationDate.ToString('dd.MM.yyyy')))" -ForegroundColor Red
            } elseif ($daysRemaining -lt 30) {
                Write-Host "Ističe za $daysRemaining dana ($($expirationDate.ToString('dd.MM.yyyy')))" -ForegroundColor Yellow
            } else {
                Write-Host "Važi još $daysRemaining dana ($($expirationDate.ToString('dd.MM.yyyy')))" -ForegroundColor Green
            }
        } catch {
            Write-Host "  SSL Sertifikat: Nije moguće preuzeti detalje sertifikata ($($_.Exception.Message))" -ForegroundColor Red
        }
    }
}
Write-Host "`nProvera završena." -ForegroundColor Cyan