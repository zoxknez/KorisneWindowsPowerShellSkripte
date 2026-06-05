# Check-WebsiteStatus.ps1 - Provera statusa veb sajtova i SSL sertifikata
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$Urls = @("https://www.google.com", "https://github.com", "https://news.ycombinator.com", "http://localhost:3000", "http://localhost:8080"),

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 120)]
    [int]$TimeoutSec = 8,

    [Parameter(Mandatory = $false)]
    [switch]$AllowInvalidCertificate
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Resolve-InputUri {
    param([string]$Value)

    try {
        $uri = [System.Uri]$Value
        if (-not $uri.Scheme) { throw "Missing scheme" }
        return $uri
    } catch {
        try {
            return [System.Uri]("https://" + $Value)
        } catch {
            return $null
        }
    }
}

function Test-HttpEndpoint {
    param(
        [System.Uri]$Uri,
        [int]$Timeout
    )

    $start = Get-Date
    try {
        try {
            $response = Invoke-WebRequest -Uri $Uri.AbsoluteUri -Method Head -TimeoutSec $Timeout -UseBasicParsing -ErrorAction Stop
        } catch {
            $status = $_.Exception.Response.StatusCode
            if ($status -and [int]$status -eq 405) {
                $response = Invoke-WebRequest -Uri $Uri.AbsoluteUri -Method Get -TimeoutSec $Timeout -UseBasicParsing -ErrorAction Stop
            } else {
                throw
            }
        }

        return [PSCustomObject]@{
            StatusCode = [int]$response.StatusCode
            StatusText = $response.StatusDescription
            DurationMs = [Math]::Round(((Get-Date) - $start).TotalMilliseconds)
            Error = $null
        }
    } catch {
        $statusCode = $null
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode) {
            $statusCode = [int]$_.Exception.Response.StatusCode
        }

        return [PSCustomObject]@{
            StatusCode = $statusCode
            StatusText = if ($statusCode) { $_.Exception.Response.StatusDescription } else { "NEDOSTUPAN" }
            DurationMs = [Math]::Round(((Get-Date) - $start).TotalMilliseconds)
            Error = $_.Exception.Message
        }
    }
}

function Get-SslCertificateInfo {
    param(
        [string]$HostName,
        [int]$Timeout,
        [switch]$AllowInvalid
    )

    $tcpClient = $null
    $sslStream = $null
    $validationErrors = [System.Net.Security.SslPolicyErrors]::None
    $chainSummary = @()

    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($HostName, 443, $null, $null)
        if (-not $connect.AsyncWaitHandle.WaitOne($Timeout * 1000, $false)) {
            throw "Timeout pri povezivanju na TCP 443."
        }
        $tcpClient.EndConnect($connect)

        $callback = {
            param($sender, $certificate, $chain, $sslPolicyErrors)
            $script:__sslErrors = $sslPolicyErrors
            $script:__sslChain = @()
            if ($chain) {
                foreach ($status in $chain.ChainStatus) {
                    $script:__sslChain += ($status.Status.ToString() + ": " + $status.StatusInformation.Trim())
                }
            }
            return $true
        }

        $script:__sslErrors = [System.Net.Security.SslPolicyErrors]::None
        $script:__sslChain = @()
        $sslStream = New-Object System.Net.Security.SslStream($tcpClient.GetStream(), $false, $callback)
        $sslStream.AuthenticateAsClient($HostName)

        $validationErrors = $script:__sslErrors
        $chainSummary = $script:__sslChain

        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($sslStream.RemoteCertificate)
        $daysRemaining = ($cert.NotAfter - (Get-Date)).Days

        return [PSCustomObject]@{
            Subject = $cert.Subject
            Issuer = $cert.Issuer
            NotAfter = $cert.NotAfter
            DaysRemaining = $daysRemaining
            Thumbprint = $cert.Thumbprint
            IsValid = ($validationErrors -eq [System.Net.Security.SslPolicyErrors]::None)
            ValidationErrors = $validationErrors.ToString()
            ChainStatus = $chainSummary
        }
    } catch {
        if (-not $AllowInvalid) {
            return [PSCustomObject]@{
                Error = $_.Exception.Message
            }
        }

        return [PSCustomObject]@{
            Error = $_.Exception.Message
            ValidationErrors = $validationErrors.ToString()
            ChainStatus = $chainSummary
        }
    } finally {
        Remove-Variable -Name __sslErrors -Scope Script -ErrorAction SilentlyContinue
        Remove-Variable -Name __sslChain -Scope Script -ErrorAction SilentlyContinue
        if ($sslStream) { $sslStream.Dispose() }
        if ($tcpClient) { $tcpClient.Close(); $tcpClient.Dispose() }
    }
}

Write-Host "Započinjem proveru statusa sajtova..." -ForegroundColor Cyan

foreach ($url in $Urls) {
    Write-Host "`nTestiranje: $url" -ForegroundColor White

    $uri = Resolve-InputUri -Value $url
    if (-not $uri) {
        Write-Host "  [-] Neispravan URL format." -ForegroundColor Red
        continue
    }

    $http = Test-HttpEndpoint -Uri $uri -Timeout $TimeoutSec
    $statusColor = if ($http.StatusCode -and $http.StatusCode -lt 400) { "Green" } elseif ($http.StatusCode) { "Yellow" } else { "Red" }
    $statusText = if ($http.StatusCode) { "$($http.StatusCode) $($http.StatusText)" } else { "NEDOSTUPAN ($($http.Error))" }

    Write-Host "  Status: " -NoNewline -ForegroundColor White
    Write-Host $statusText -NoNewline -ForegroundColor $statusColor
    Write-Host " | Odziv: $($http.DurationMs) ms" -ForegroundColor White

    if ($uri.Scheme -eq "https") {
        $ssl = Get-SslCertificateInfo -HostName $uri.Host -Timeout $TimeoutSec -AllowInvalid:$AllowInvalidCertificate
        if ($ssl.Error) {
            Write-Host "  SSL Sertifikat: Nije moguće preuzeti detalje ($($ssl.Error))" -ForegroundColor Red
            continue
        }

        Write-Host "  SSL Sertifikat: " -NoNewline -ForegroundColor White
        if (-not $ssl.IsValid) {
            Write-Host "Lanac nije validan ($($ssl.ValidationErrors)); ističe za $($ssl.DaysRemaining) dana ($($ssl.NotAfter.ToString('dd.MM.yyyy')))" -ForegroundColor Red
        } elseif ($ssl.DaysRemaining -lt 7) {
            Write-Host "Ističe za $($ssl.DaysRemaining) dana ($($ssl.NotAfter.ToString('dd.MM.yyyy')))" -ForegroundColor Red
        } elseif ($ssl.DaysRemaining -lt 30) {
            Write-Host "Ističe za $($ssl.DaysRemaining) dana ($($ssl.NotAfter.ToString('dd.MM.yyyy')))" -ForegroundColor Yellow
        } else {
            Write-Host "Važi još $($ssl.DaysRemaining) dana ($($ssl.NotAfter.ToString('dd.MM.yyyy')))" -ForegroundColor Green
        }
    }
}

Write-Host "`nProvera završena." -ForegroundColor Cyan
