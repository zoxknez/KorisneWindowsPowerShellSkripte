[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Manage-FirewallRules.ps1 - Upravljanje Windows Firewall-om
function Show-SubMenu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "                WINDOWS FIREWALL ASISTENT         " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "1. Prikaži aktivna pravila za dolazni saobraćaj (Inbound)"
    Write-Host "2. Dodaj pravilo za blokiranje dolaznog porta"
    Write-Host "3. Obriši pravilo iz Firewall-a"
    Write-Host "0. Nazad u glavni meni"
    Write-Host "==================================================" -ForegroundColor Cyan
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Rad sa Windows Firewall-om zahteva pokretanje sa Administratorskim privilegijama!" -ForegroundColor Red
    return
}

do {
    Show-SubMenu
    $choice = Read-Host "Izbor"
    
    switch ($choice) {
        "1" {
            Clear-Host
            Write-Host "Aktivna Inbound pravila (prvih 30):`n" -ForegroundColor Yellow
            Get-NetFirewallRule -Direction Inbound -Enabled True | Select-Object DisplayName, Action, Direction | Select-Object -First 30 | Format-Table -AutoSize
            Read-Host "`nPritisnite Enter za nastavak..."
        }
        "2" {
            Clear-Host
            Write-Host "Blokiranje dolaznog porta:`n" -ForegroundColor Yellow
            $ruleName = Read-Host "Unesite IME pravila (npr. Blokiraj_DevPort)"
            $port = Read-Host "Unesite broj porta (npr. 8080)"
            
            if (-not [string]::IsNullOrEmpty($ruleName) -and $port -match "^\d+$") {
                try {
                    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -LocalPort $port -Protocol TCP -Action Block -ErrorAction Stop | Out-Null
                    Write-Host "[+] Port $port uspešno BLOKIRAN u Firewall-u!" -ForegroundColor Green
                } catch {
                    Write-Host "Greška pri kreiranju pravila: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
            Read-Host "`nPritisnite Enter za nastavak..."
        }
        "3" {
            Clear-Host
            $ruleName = Read-Host "Unesite IME pravila koje želite da obrišete"
            if (-not [string]::IsNullOrEmpty($ruleName)) {
                try {
                    Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction Stop
                    Write-Host "[+] Pravilo '$ruleName' uspešno uklonjeno." -ForegroundColor Green
                } catch {
                    Write-Host "Greška: Pravilo nije pronađeno." -ForegroundColor Red
                }
            }
            Read-Host "`nPritisnite Enter za nastavak..."
        }
    }
} while ($choice -ne "0")