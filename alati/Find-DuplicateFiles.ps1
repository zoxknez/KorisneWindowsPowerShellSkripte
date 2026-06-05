# Find-DuplicateFiles.ps1 - Pronalaženje i brisanje duplih fajlova
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Skeniram folder za duple fajlove (ovo može potrajati)..." -ForegroundColor Cyan

try {
    # 1. Uzimamo sve fajlove rekurzivno
    $allFiles = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue
    
    # Efikasna optimizacija: Grupišemo po veličini jer samo fajlovi iste veličine mogu biti duplikati!
    # Hashing je skupa operacija pa heširamo samo fajlove koji imaju potencijalne duplikate.
    $sizeGroups = $allFiles | Group-Object -Property Length | Where-Object { $_.Count -gt 1 }
    
    if ($sizeGroups.Count -eq 0) {
        Write-Host "Nisu pronađeni potencijalni duplikati po veličini." -ForegroundColor Green
        return
    }
    
    Write-Host "Računam heševe za potencijalne duplikate..." -ForegroundColor DarkGray
    $hashTable = @{}
    $duplicates = @()
    
    foreach ($group in $sizeGroups) {
        foreach ($file in $group.Group) {
            try {
                $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
                if ($hash) {
                    if ($hashTable.ContainsKey($hash)) {
                        # Već imamo ovaj heš, to je duplikat
                        $duplicates += [PSCustomObject]@{
                            Naziv = $file.Name
                            Putanja = $file.FullName
                            Original = $hashTable[$hash]
                            VelicinaMB = [Math]::Round($file.Length / 1MB, 2)
                        }
                    } else {
                        $hashTable[$hash] = $file.FullName
                    }
                }
            } catch {}
        }
    }
    
    if ($duplicates.Count -eq 0) {
        Write-Host "Nisu pronađeni identični duplirani fajlovi." -ForegroundColor Green
        return
    }
    
    Write-Host "`nPronađeni duplirani fajlovi (ukupno: $($duplicates.Count)):" -ForegroundColor Yellow
    $duplicates | Format-Table -Property Naziv, VelicinaMB, Putanja -AutoSize
    
    $confirm = Read-Host "Da li želite da obrišete ove duplikate? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        $deleted = 0
        $errors = 0
        foreach ($dup in $duplicates) {
            try {
                Remove-Item -Path $dup.Putanja -Force -ErrorAction Stop
                Write-Host "Obrisano: $($dup.Putanja)" -ForegroundColor DarkGray
                $deleted++
            } catch {
                Write-Host "Greška pri brisanju: $($dup.Putanja) ($($_.Exception.Message))" -ForegroundColor Red
                $errors++
            }
        }
        Write-Host "`nBrisanje završeno! Uspešno obrisano: $deleted, Greške: $errors." -ForegroundColor Green
    } else {
        Write-Host "Operacija otkazana." -ForegroundColor Red
    }
} catch {
    Write-Host "Došlo je do greške: $($_.Exception.Message)" -ForegroundColor Red
}