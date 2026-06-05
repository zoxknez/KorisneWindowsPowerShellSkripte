# Convert-WakeOnLan.ps1 - Slanje Magic Packet-a (Wake on LAN)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MacAddress,
    [Parameter(Mandatory = $false)]
    [string]$BroadcastIP = "255.255.255.255"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Čišćenje MAC adrese
$cleanMac = $MacAddress.Replace(":", "").Replace("-", "").Replace(".", "")
if ($cleanMac.Length -ne 12) {
    Write-Host "Greška: MAC adresa mora imati tačno 12 heksadecimalnih karaktera!" -ForegroundColor Red
    return
}

Write-Host "Šaljem Wake-on-LAN Magic Packet..." -ForegroundColor Cyan
Write-Host "MAC Cilj   : $MacAddress" -ForegroundColor White
Write-Host "Broadcast  : $BroadcastIP" -ForegroundColor White

try {
    # Pretvaranje MAC adrese u niz bajtova
    $macBytes = New-Object byte[] 6
    for ($i = 0; $i -lt 6; $i++) {
        $macBytes[$i] = [System.Convert]::ToByte($cleanMac.Substring(($i * 2), 2), 16)
    }
    
    # Izrada Magic Packet-a: 6 bajtova 0xFF + 16 puta ponovljen MAC
    $packet = New-Object byte[] 102
    for ($i = 0; $i -lt 6; $i++) {
        $packet[$i] = [byte]0xFF
    }
    for ($i = 1; $i -le 16; $i++) {
        [System.Buffer]::BlockCopy($macBytes, 0, $packet, ($i * 6), 6)
    }
    
    # Slanje preko UDP socket-a na port 9
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.Connect($BroadcastIP, 9)
    $udpClient.Send($packet, $packet.Length) | Out-Null
    $udpClient.Close()
    
    Write-Host "`n[+] Magic Packet je uspešno poslat!" -ForegroundColor Green
} catch {
    Write-Host "Greška pri slanju paketa: $($_.Exception.Message)" -ForegroundColor Red
}