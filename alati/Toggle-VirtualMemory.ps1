[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Toggle-VirtualMemory.ps1 - Podešavanje i optimizacija virtuelne memorije (Pagefile)
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Greška: Promena virtuelne memorije zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

try {
    # Dobijamo trenutno podešavanje pagefile-a
    $sys = Get-CimInstance Win32_ComputerSystem
    $autoPage = $sys.AutomaticManagedPagefile
    
    Write-Host "Trenutno stanje virtuelne memorije:" -ForegroundColor Cyan
    Write-Host "  Automatsko upravljanje (Auto-Managed): " -NoNewline
    if ($autoPage) { Write-Host "OMOGUĆENO" -ForegroundColor Green } else { Write-Host "Onemogućeno (Manual)" -ForegroundColor Yellow }
    
    Write-Host "`nIzaberite akciju:" -ForegroundColor Yellow
    Write-Host "1. Postavi automatsko upravljanje pagefile-om (Preporučeno za većinu)" -ForegroundColor Green
    Write-Host "2. Postavi statičku, optimizovanu veličinu pagefile-a (npr. 8GB za SSD)" -ForegroundColor Yellow
    Write-Host "0. Nazad / Odustani"
    
    $choice = Read-Host "Opcija"
    
    if ($choice -eq "1") {
        Write-Host "`nOmogućavam automatski pagefile..." -ForegroundColor DarkGray
        $sys.AutomaticManagedPagefile = $true
        Set-CimInstance -InputObject $sys -ErrorAction Stop
        Write-Host "[+] Virtuelna memorija uspešno vraćena na automatsko upravljanje!" -ForegroundColor Green
    }
    elseif ($choice -eq "2") {
        Write-Host "`nIsključujem automatsko upravljanje..." -ForegroundColor DarkGray
        $sys.AutomaticManagedPagefile = $false
        Set-CimInstance -InputObject $sys -ErrorAction Stop
        
        # Podešavanje statičke veličine pagefile-a (8192 MB = 8GB)
        Write-Host "Postavljam statički pagefile veličine 8GB (C:\pagefile.sys)..." -ForegroundColor Yellow
        
        # Proveravamo da li već postoji zapis
        $pageSetting = Get-CimInstance Win32_PageFileSetting
        if ($pageSetting) {
            $pageSetting.InitialSize = 8192
            $pageSetting.MaximumSize = 8192
            Set-CimInstance -InputObject $pageSetting -ErrorAction Stop
        } else {
            # Kreiramo novi pagefile ako ne postoji
            New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                Name = "C:\pagefile.sys"
                InitialSize = 8192
                MaximumSize = 8192
            } -ErrorAction Stop | Out-Null
        }
        Write-Host "[+] Statička veličina od 8GB uspešno podešena!" -ForegroundColor Green
        Write-Host "Za primenu izmena neophodno je restartovati sistem." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}