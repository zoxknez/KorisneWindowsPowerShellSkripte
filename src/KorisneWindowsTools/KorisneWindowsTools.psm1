# KorisneWindowsTools.psm1 - Učitavač modula
# Rekurzivno učitava sve funkcije iz Public/ i Private/ direktorijuma.

$publicPath = Join-Path $PSScriptRoot "Public"
$privatePath = Join-Path $PSScriptRoot "Private"

# Učitavanje privatnih pomoćnih funkcija (interni helperi)
if (Test-Path $privatePath) {
    Get-ChildItem -Path $privatePath -Filter *.ps1 -File | ForEach-Object {
        try {
            . $_.FullName
            Write-Verbose "Učitan privatni helper: $($_.Name)"
        } catch {
            Write-Error "Greška pri učitavanju privatne funkcije $($_.Name): $($_.Exception.Message)"
        }
    }
}

# Učitavanje javno dostupnih funkcija (cmdleti)
if (Test-Path $publicPath) {
    Get-ChildItem -Path $publicPath -Filter *.ps1 -File | ForEach-Object {
        try {
            . $_.FullName
            Write-Verbose "Učitan javni cmdlet: $($_.Name)"
        } catch {
            Write-Error "Greška pri učitavanju javne funkcije $($_.Name): $($_.Exception.Message)"
        }
    }
}


