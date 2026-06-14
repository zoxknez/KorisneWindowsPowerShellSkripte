# Changelog

Sve značajne promene na ovom projektu biće dokumentovane u ovom fajlu.

Pratimo [Semantičko Verzionisanje](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-14

### Dodato
- Inicijalna struktura modula `KorisneWindowsTools`.
- Centralni katalog alata `tools.json` za dinamičko učitavanje i hibridni rad (legacy skripte + novi moduli).
- Refaktorisane verzije alata:
  - `Get-KwtLocalUserAudit` (pregled naloga i admin članova).
  - `Clear-KwtWindowsTemp` (bezbedno sistemsko čišćenje sa `-WhatIf`).
  - `Backup-KwtMySqlDatabase` (konekcija i izvoz baza).
- Smoke i unit testovi u Pester frameworku.
- Konfiguracija za linter `PSScriptAnalyzer`.
- GitHub Actions CI workflow za automatizovanu proveru.
- LICENSE (MIT), SECURITY.md, CONTRIBUTING.md.
