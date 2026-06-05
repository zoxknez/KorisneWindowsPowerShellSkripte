# Watch-RegistryChanges.ps1 - Nadgledanje promena u Windows Registrima
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


# Konvertovanje standardne registry putanje (npr HKLM:\...)
Write-Host "Pokrećem nadzor registra: $RegistryPath" -ForegroundColor Cyan
Write-Host "Pratim sve izmene u ovom ključu... Pritisnite bilo koji taster za kraj.`n" -ForegroundColor Yellow

try {
    $regItem = Get-Item -Path $RegistryPath -ErrorAction Stop
    
    # Uzimamo trenutne vrednosti za baseline
    $baseline = @{}
    $props = Get-ItemProperty -Path $RegistryPath
    foreach ($p in $regItem.GetValueNames()) {
        $baseline[$p] = $props.$p
    }
    
    while (-not [System.Console]::KeyAvailable) {
        Start-Sleep -Seconds 1
        
        # Očitavanje trenutnih vrednosti
        $currentProps = Get-ItemProperty -Path $RegistryPath
        $currentKeys = $regItem.GetValueNames()
        
        # Provera izmenjenih i novih vrednosti
        foreach ($k in $currentKeys) {
            $currVal = $currentProps.$k
            if (-not $baseline.ContainsKey($k)) {
                Write-Host "[NOVI UNOS] Dodat ključ: " -NoNewline -ForegroundColor Green
                Write-Host "$k = $currVal" -ForegroundColor White
                $baseline[$k] = $currVal
            } elseif ($baseline[$k].ToString() -ne $currVal.ToString()) {
                Write-Host "[IZMENJENO] Promena vrednosti ključa: " -NoNewline -ForegroundColor Yellow
                Write-Host "$k : $($baseline[$k]) -> $currVal" -ForegroundColor White
                $baseline[$k] = $currVal
            }
        }
        
        # Provera obrisanih vrednosti
        $baselineKeys = @() + $baseline.Keys
        foreach ($bk in $baselineKeys) {
            if ($currentKeys -notcontains $bk) {
                Write-Host "[OBRISANO] Uklonjen ključ: $bk" -ForegroundColor Red
                $baseline.Remove($bk)
            }
        }
    }
    # Čišćenje bafera tastature
    $null = [System.Console]::ReadKey($true)
} catch {
    Write-Host "Greška pri nadgledanju registra: $($_.Exception.Message)" -ForegroundColor Red
}