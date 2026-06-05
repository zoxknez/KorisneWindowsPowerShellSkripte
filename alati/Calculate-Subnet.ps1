# Calculate-Subnet.ps1 - IP mrežni kalkulator (Subnet Calculator)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IPAddress,
    [Parameter(Mandatory = $true)]
    [string]$SubnetMask
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Računam mrežne parametre za: $IPAddress / $SubnetMask..." -ForegroundColor Cyan

try {
    # Parsiranje IP adresa u bajtove
    $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
    $maskBytes = [System.Net.IPAddress]::Parse($SubnetMask).GetAddressBytes()
    
    # Računanje Network ID-a (Bitwise AND)
    $netBytes = New-Object byte[] 4
    for ($i = 0; $i -lt 4; $i++) {
        $netBytes[$i] = [byte]($ipBytes[$i] -band $maskBytes[$i])
    }
    $networkAddress = [System.Net.IPAddress]$netBytes
    
    # Računanje Broadcast adrese (Network ID + Bitwise NOT maske)
    $broadBytes = New-Object byte[] 4
    for ($i = 0; $i -lt 4; $i++) {
        $broadBytes[$i] = [byte]($netBytes[$i] -bor ([byte](-bnot $maskBytes[$i])))
    }
    $broadcastAddress = [System.Net.IPAddress]$broadBytes
    
    # Računanje CIDR notacije (/24, /16...)
    $cidr = 0
    foreach ($byte in $maskBytes) {
        $binary = [System.Convert]::ToString($byte, 2)
        $cidr += ($binary.Replace('0', '').Length)
    }
    
    # Računanje broja hostova
    $hostBits = 32 - $cidr
    $totalHosts = [Math]::Pow(2, $hostBits) - 2
    if ($cidr -eq 32) { $totalHosts = 1 }
    
    # Prvi i zadnji host
    $firstHostBytes = [byte[]]$netBytes.Clone()
    $firstHostBytes[3] += 1
    $firstHost = [System.Net.IPAddress]$firstHostBytes
    
    $lastHostBytes = [byte[]]$broadBytes.Clone()
    $lastHostBytes[3] -= 1
    $lastHost = [System.Net.IPAddress]$lastHostBytes
    
    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host "               MREŽNI PARAMETRI SUB-NETA          " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "CIDR notacija      : $IPAddress/$cidr" -ForegroundColor Green
    Write-Host "Mrežna adresa (Net): $($networkAddress.IPAddressToString)" -ForegroundColor White
    Write-Host "Broadcast adresa   : $($broadcastAddress.IPAddressToString)" -ForegroundColor White
    Write-Host "Prva IP adresa     : $($firstHost.IPAddressToString)" -ForegroundColor White
    Write-Host "Poslednja IP adresa: $($lastHost.IPAddressToString)" -ForegroundColor White
    Write-Host "Ukupno upotrebljivo: $totalHosts hostova" -ForegroundColor Gold
    Write-Host "==================================================" -ForegroundColor Cyan
} catch {
    Write-Host "Greška: Neispravna IP adresa ili Subnet maska!" -ForegroundColor Red
}