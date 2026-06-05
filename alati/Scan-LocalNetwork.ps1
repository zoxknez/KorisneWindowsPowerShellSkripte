[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Scan-LocalNetwork.ps1 - Skener lokalne mreže (ARP)
Write-Host "Započinjem skeniranje lokalne mreže..." -ForegroundColor Cyan

# Pronalaženje lokalne IP adrese i subneta
$localIp = ""
$subnet = ""
try {
    $ipConfig = Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | Select-Object -First 1
    $localIp = $ipConfig.IPv4Address.IPAddress
    # Izračunavanje subneta (pretpostavljamo /24 što je 99% kućnih/kancelarijskih mreža)
    if ($localIp -match '^(\d+\.\d+\.\d+)\.\d+$') {
        $subnet = $Matches[1]
    }
} catch {
    Write-Host "Nije moguće pronaći lokalne mrežne adaptere!" -ForegroundColor Red
    return
}

if (-not $subnet) {
    Write-Host "Neuspešna detekcija mrežnog opsega." -ForegroundColor Red
    return
}

Write-Host "Detektovana lokalna IP: $localIp" -ForegroundColor White
Write-Host "Skeniram opseg: ${subnet}.1 do ${subnet}.254..." -ForegroundColor White
Write-Host "Brzi ping sken (ovo može potrajati oko 15-30 sekundi)...`n" -ForegroundColor DarkGray

$activeHosts = @()

# Brza pretraga mrežnih IP adresa (paralelne Socket konekcije na port 135/445/80/ping)
# Koristimo Test-Connection sa minimalnim timeoutom
$jobs = @()
for ($i = 1; $i -le 254; $i++) {
    $ip = "${subnet}.${i}"
    # Pokrećemo Test-Connection kao asinhroni posao radi brzine
    $jobs += Test-Connection -ComputerName $ip -Count 1 -Delay 0 -BufferSize 8 -AsJob -ErrorAction SilentlyContinue
}

Write-Host "Čekam odgovor od uređaja..." -ForegroundColor DarkGray
# Čekamo poslove i prikupljamo rezultate (maksimalno 10 sekundi)
$null = Wait-Job $jobs -Timeout 10

foreach ($job in $jobs) {
    $result = Receive-Job -Job $job
    if ($result -and $result.ResponseTime -ne $null) {
        $ip = $result.Address
        
        # Dobijanje MAC adrese iz ARP tabele
        $mac = "Nepoznato"
        $arp = arp -a $ip | Select-String "$ip\s+"
        if ($arp -and $arp.Line -match '([0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2})') {
            $mac = $Matches[1].ToUpper()
        }
        
        # Pokušaj razrešenja imena (DNS HostName)
        $hostName = "N/A"
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($ip)
            $hostName = $hostEntry.HostName
        } catch {}
        
        $activeHosts += [PSCustomObject]@{
            IPAdresa = $ip
            HostName = $hostName
            MACAdresa = $mac
        }
    }
}

# Čišćenje poslova iz memorije
$jobs | Remove-Job -Force

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "             AKTIVNI UREĐAJI NA MREŽI             " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
if ($activeHosts.Count -gt 0) {
    $activeHosts | Sort-Object -Property IPAdresa | Format-Table -AutoSize
    Write-Host "Ukupno aktivnih uređaja: $($activeHosts.Count)" -ForegroundColor Yellow
} else {
    Write-Host "Nije pronađen nijedan aktivan uređaj u mreži." -ForegroundColor Yellow
}