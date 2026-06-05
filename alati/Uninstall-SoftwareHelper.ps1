[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Uninstall-SoftwareHelper.ps1 - Interaktivna pretraga i deinstalacija softvera
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Deinstalacija programa zahteva Administratorske privilegije!" -ForegroundColor Red
    return
}

$search = Read-Host "Unesite ime programa ili ključnu reč za pretragu"
if ([string]::IsNullOrWhitespace($search)) {
    Write-Host "Pretraga ne može biti prazna." -ForegroundColor Red
    return
}

Write-Host "`nPretražujem instalirani softver..." -ForegroundColor Cyan

$regPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    $matches = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue |
               Where-Object { $_.DisplayName -match $search -and $_.UninstallString } |
               Select-Object DisplayName, DisplayVersion, UninstallString, QuietUninstallString
               
    if (-not $matches -or $matches.Count -eq 0) {
        Write-Host "Nije pronađen nijedan program koji odgovara pretrazi '$search'." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`nPronađeni programi:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $matches.Count; $i++) {
        Write-Host "$($i + 1). $($matches[$i].DisplayName) (Verzija: $($matches[$i].DisplayVersion))" -ForegroundColor White
    }
    
    $choice = Read-Host "`nUnesite broj programa koji želite da deinstalirate"
    if ($choice -match '^\d+$') {
        $idx = [int]$choice - 1
        if ($idx -ge 0 -and $idx -lt $matches.Count) {
            $target = $matches[$idx]
            $confirm = Read-Host "Da li ste sigurni da želite da uklonite program '$($target.DisplayName)'? (Y/N)"
            if ($confirm.ToUpper() -eq "Y") {
                # Pokušavamo Quiet/Silent deinstalaciju ako postoji, inače klasičnu
                $uninstString = if ($target.QuietUninstallString) { $target.QuietUninstallString } else { $target.UninstallString }
                
                Write-Host "`nPokrećem deinstalaciju: $uninstString..." -ForegroundColor Yellow
                
                # Izvršavamo komandu deinstalacije
                if ($uninstString -match '^"([^"]+)"\s*(.*)$') {
                    $exe = $Matches[1]
                    $args = $Matches[2]
                    Start-Process -FilePath $exe -ArgumentList $args -Wait -NoNewWindow
                } else {
                    # Direktno pokretanje preko CMD-a za čudne stringove
                    Start-Process cmd.exe -ArgumentList "/c $uninstString" -Wait -NoNewWindow
                }
                
                Write-Host "`nProces deinstalacije završen." -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "Greška: $($_.Exception.Message)" -ForegroundColor Red
}