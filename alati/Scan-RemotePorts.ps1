# Scan-RemotePorts.ps1 - Port skener za testiranje mrežnih portova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [Parameter(Mandatory = $false)]
    [int[]]$Ports = @(21, 22, 23, 25, 80, 110, 143, 443, 445, 1433, 3306, 3389, 5432, 8080, 27017)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem skener portova na hostu: $HostName..." -ForegroundColor Cyan
Write-Host "Testiram portove: $($Ports -join ', ')`n" -ForegroundColor DarkGray

$results = @()

foreach ($port in $Ports) {
    Write-Host "Proveravam port $port..." -ForegroundColor DarkGray
    $client = New-Object System.Net.Sockets.TcpClient
    
    # Postavljanje asinhronog timeout-a od 1 sekunde za brži sken
    $connection = $client.BeginConnect($HostName, $port, $null, $null)
    $success = $connection.AsyncWaitHandle.WaitOne(1000, $false)
    
    if ($success) {
        $client.EndConnect($connection)
        Write-Host "  [+] Port $port je OTVOREN" -ForegroundColor Green
        $serviceName = switch ($port) {
            21 { "FTP" }
            22 { "SSH" }
            23 { "Telnet" }
            25 { "SMTP" }
            80 { "HTTP (Web)" }
            110 { "POP3" }
            143 { "IMAP" }
            443 { "HTTPS (Secure Web)" }
            445 { "SMB (File Share)" }
            1433 { "MSSQL Server" }
            3306 { "MySQL Server" }
            3389 { "RDP (Remote Desktop)" }
            5432 { "PostgreSQL" }
            8080 { "HTTP Web Cache / Dev" }
            27017 { "MongoDB" }
            default { "Nepoznata usluga" }
        }
        $results += [PSCustomObject]@{ Port = $port; Status = "OTVOREN"; Opis = $serviceName }
    } else {
        # Port je zatvoren ili nema odziva
        # Nema potrebe da spamujemo konzolu zatvorenim portovima, prikazaćemo ih u finalnom izveštaju
    }
    $client.Close()
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "             REZULTATI SKENIRANJA PORT-OVA        " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
if ($results.Count -gt 0) {
    $results | Format-Table -AutoSize
} else {
    Write-Host "Nijedan testirani port na hostu $HostName nije otvoren." -ForegroundColor Yellow
}