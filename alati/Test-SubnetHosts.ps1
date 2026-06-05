# Test-SubnetHosts.ps1 - Skeniranje određenog porta kroz ceo subnet
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$Port,
    [Parameter(Mandatory = $false)]
    [string]$SubnetRange
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Ako subnet opseg nije zadat, pokušavamo detekciju
if ([string]::IsNullOrWhitespace($SubnetRange)) {
    try {
        $ip = (Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | Select-Object -First 1).IPv4Address.IPAddress
        if ($ip -match '^(\d+\.\d+\.\d+)\.\d+$') {
            $SubnetRange = $Matches[1]
        }
    } catch {}
}

if (-not $SubnetRange) {
    Write-Host "Greška: Neuspešna automatska detekcija subneta. Unesite parametar -SubnetRange (npr. 192.168.1)." -ForegroundColor Red
    return
}

Write-Host "Skeniram port $Port kroz opseg: ${SubnetRange}.1 do ${SubnetRange}.254..." -ForegroundColor Cyan
Write-Host "Čekam odgovore (timeout 500ms)...`n" -ForegroundColor DarkGray

$activeServers = @()

# Koristimo asinhrone poslove za izuzetnu brzinu
$jobs = @()
for ($i = 1; $i -le 254; $i++) {
    $ip = "${SubnetRange}.${i}"
    # Pokrećemo asinhroni socket test
    $script = {
        param($targetIp, $targetPort)
        $client = New-Object System.Net.Sockets.TcpClient
        $connection = $client.BeginConnect($targetIp, $targetPort, $null, $null)
        $success = $connection.AsyncWaitHandle.WaitOne(500, $false)
        if ($success) {
            $client.EndConnect($connection)
            $client.Close()
            return $targetIp
        }
        $client.Close()
        return $null
    }
    $jobs += Start-Job -ScriptBlock $script -ArgumentList $ip, $Port
}

# Čekamo poslove maksimalno 5 sekundi
$null = Wait-Job $jobs -Timeout 5

foreach ($job in $jobs) {
    $ipResult = Receive-Job -Job $job
    if ($ipResult) {
        $activeServers += $ipResult
        Write-Host "  [+] Server pronađen na IP: $ipResult (Port $Port otvoren)" -ForegroundColor Green
    }
}

$jobs | Remove-Job -Force

Write-Host "`nSkeniranje subneta završeno!" -ForegroundColor Gold
Write-Host "Ukupno pronađeno servera: $($activeServers.Count)" -ForegroundColor White