# Changelog

Sve značajne promene na ovom projektu biće dokumentovane u ovom fajlu.

Pratimo [Semantičko Verzionisanje](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-17

### Dodato
- Proširena baza alata sa 140 na 200+ Windows PowerShell skripti.
- Novi alati grupisani u 10 novih kategorija:
  - `Napredni alati - Security` (20 alata): revizija bezbednosti, Defender, BitLocker, UAC, zakazani zadaci.
  - `Napredni alati - Windows Ops` (10 alata): winget, boot analiza, sandbox, Hotkey konflikti.
  - `Napredni alati - Dev/Supply Chain` (12 alata): tajne u kodu, lockfiles, npm skripte, OpenAPI validacija.
  - `Napredni alati - Network/Web` (8 alata): SPF/DKIM, sertifikati, IPv6, VPN, mDNS/SSDP.
  - `Napredni alati - Files/Backup` (10 alata): NTFS permisije, EXIF, ransomware kanari, OneDrive konflikti.
  - `Mreža, Web i DNS`, `Mediji i automatizacija`, `Registry i OS`, `Baze, Keš i Taskovi`.
- Dodat `Pokreni.bat` — jednostavna prečica za pokretanje menija bez direktnog pozivanja PowerShell-a.
- Dinamički meni (`Start-KwtMenu`) — modularno učitavanje kategorija iz `tools.json`.

### Promenjeno
- Refaktorisana arhitektura: sve skripte sada imaju unose u centralnom `tools.json` katalogu.
- Poboljšano prikazivanje kategorija u meniju (bojom, brojem alata).

---

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
