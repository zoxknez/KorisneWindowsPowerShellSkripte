# Kako Doprineti (Contributing Guidelines)

Hvala Vam što želite da doprinesete projektu! Kako bismo održali visok nivo kvaliteta koda i sigurnosti, molimo Vas da pratite ove smernice:

## Struktura Projekta

- Sve javne funkcije modula nalaze se u `src/KorisneWindowsTools/Public/`.
- Sve privatne helper funkcije nalaze se u `src/KorisneWindowsTools/Private/`.
- Katalog svih alata je u `src/KorisneWindowsTools/Data/tools.json`.

## Standardi Koda

1. **CmdletBinding:** Svaka nova funkcija mora imati `[CmdletBinding()]`.
2. **ShouldProcess:** Svaka funkcija koja menja stanje sistema (brisanje, registry, firewall, itd.) mora podržavati `SupportsShouldProcess` i koristiti `$PSCmdlet.ShouldProcess` za podršku `-WhatIf` i `-Confirm`.
3. **Objektni Izlaz:** Funkcije treba da vraćaju strukturisane objekte (npr. `[PSCustomObject]`) umesto isključivog korišćenja `Write-Host` (osim za Start-KwtMenu UI).
4. **Pravila Linter-a:** Kod mora proći proveru sa `PSScriptAnalyzer` bez kritičnih grešaka i upozorenja.

## Testiranje

Pre slanja Pull Request-a, proverite ispravnost koda pokretanjem testova:
```powershell
Invoke-Pester ./tests
```
