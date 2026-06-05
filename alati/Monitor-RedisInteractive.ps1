# Monitor-RedisInteractive.ps1 - Interaktivna provera i brisanje Redis keša
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$RedisHost = "127.0.0.1",
    [Parameter(Mandatory = $false)]
    [int]$Port = 6379
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Povezujem se na Redis server: $($RedisHost):$Port..." -ForegroundColor Cyan

if (-not (Get-Command redis-cli -ErrorAction SilentlyContinue)) {
    Write-Host "Greška: Alat 'redis-cli' nije pronađen u PATH-u. Instalirajte Redis klijentske alate." -ForegroundColor Red
    return
}

try {
    # 1. Provera pinga
    $ping = & redis-cli -h $RedisHost -p $Port PING 2>$null
    if ($ping.Trim() -ne "PONG") {
        Write-Host "Redis server na adresi $($RedisHost):$Port ne odgovara (Ping neuspešan)." -ForegroundColor Red
        return
    }
    Write-Host "[+] Redis je online (PONG)." -ForegroundColor Green
    
    do {
        # 2. Čitanje info parametara
        $info = & redis-cli -h $RedisHost -p $Port INFO memory 2>$null
        $usedMem = $info | Select-String "used_memory_human:"
        
        $dbSize = & redis-cli -h $RedisHost -p $Port DBSIZE 2>$null
        
        Clear-Host
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "                REDIS MONITOR DASHBOARD           " -ForegroundColor Yellow
        Write-Host "==================================================" -ForegroundColor Cyan
        Write-Host "Server     : $($RedisHost):$Port" -ForegroundColor White
        Write-Host "Korišćeno  : $($usedMem.ToString().Trim())" -ForegroundColor White
        Write-Host "Broj ključeva (Keys): $($dbSize.Trim())" -ForegroundColor White
        Write-Host "==================================================" -ForegroundColor Cyan
        
        Write-Host "Opcije:" -ForegroundColor Yellow
        Write-Host "1. Prikaži prvih 30 ključeva (KEYS *)" -ForegroundColor White
        Write-Host "2. Očisti ceo Redis keš (FLUSHALL)" -ForegroundColor Red
        Write-Host "0. Izlaz" -ForegroundColor Gray
        
        $choice = Read-Host "Opcija"
        
        if ($choice -eq "1") {
            Write-Host "`nKljučevi u bazi (KEYS *):" -ForegroundColor Yellow
            & redis-cli -h $RedisHost -p $Port KEYS "*" | Select-Object -First 30
            Read-Host "`nPritisnite Enter..."
        }
        elseif ($choice -eq "2") {
            $confirm = Read-Host "Da li ste sigurni da želite da obrišete SVE ključeve u Redisu? (Y/N)"
            if ($confirm.ToUpper() -eq "Y") {
                $res = & redis-cli -h $RedisHost -p $Port FLUSHALL
                Write-Host "Redis odgovor: $res" -ForegroundColor Green
                Read-Host "`nPritisnite Enter..."
            }
        }
    } while ($choice -ne "0")
} catch {
    Write-Host "Greška tokom rada sa Redisom: $($_.Exception.Message)" -ForegroundColor Red
}