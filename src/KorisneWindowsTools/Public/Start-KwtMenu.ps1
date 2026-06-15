function Start-KwtMenu {
    <#
    .SYNOPSIS
    Glavni interaktivni pokretač za Windows Utility Toolkit.

    .DESCRIPTION
    Učitava katalog alata iz JSON baze podataka i dinamički renderuje terminalski meni.
    Podržava kategorije, pretragu alata, proveru administratorskih prava i bezbedno pokretanje.

    .PARAMETER Search
    Pretražuje alate po nazivu ili opisu i pokreće brzi prikaz rezultata.

    .PARAMETER Category
    Prikazuje alate samo iz odabrane kategorije.

    .PARAMETER SafeMode
    Pokreće meni u sigurnom režimu gde su prikazani samo alati sa niskim nivoom rizika (Low).

    .PARAMETER List
    Prikazuje katalog alata bez ulaska u interaktivni prompt.

    .PARAMETER Json
    Prikazuje katalog alata kao JSON bez ulaska u interaktivni prompt.

    .EXAMPLE
    Start-KwtMenu

    .EXAMPLE
    Start-KwtMenu -Search "dns"
    #>
    [CmdletBinding()]
    param(
        [string]$Search,
        [string]$Category,
        [switch]$SafeMode,
        [switch]$List,
        [switch]$Json
    )

    begin {
        $moduleRoot = Split-Path -Parent $PSScriptRoot
        $projectRoot = Split-Path -Parent $moduleRoot
        $catalogPath = Join-Path $moduleRoot "Data\tools.json"

        if (-not (Test-Path $catalogPath)) {
            Write-Error "Katalog alata nije pronađen na putanji: $catalogPath"
            return
        }

        # Učitavanje kataloga
        $tools = Get-Content -Path $catalogPath -Encoding UTF8 -Raw | ConvertFrom-Json
        Write-Verbose "Učitano $($tools.Count) alata iz kataloga."

        # Provera admin statusa
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        function Get-KwtPowerShellHost {
            $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
            if ($pwsh) {
                return $pwsh.Source
            }

            return (Get-Command powershell.exe -ErrorAction Stop).Source
        }

        function Get-KwtToolArguments {
            param($tool)

            if ($tool.PSObject.Properties.Name -contains "arguments" -and $null -ne $tool.arguments) {
                return @($tool.arguments)
            }

            return @()
        }

        function Resolve-KwtLegacyTool {
            param($tool)

            $legacyPath = [string]$tool.legacyPath
            $arguments = Get-KwtToolArguments -tool $tool

            # Backward compatibility for older catalog entries that stored
            # simple script arguments inside legacyPath.
            if ($arguments.Count -eq 0 -and $legacyPath -match '^(.+?\.ps1)\s+(.+)$') {
                $legacyPath = $matches[1]
                $arguments = $matches[2] -split '\s+'
            }

            [PSCustomObject]@{
                ScriptPath = Join-Path $projectRoot $legacyPath
                Arguments  = @($arguments)
            }
        }

        function Get-KwtToolList {
            $filtered = $tools

            if ($Search) {
                $filtered = $filtered | Where-Object { $_.name -like "*$Search*" -or $_.descriptionSr -like "*$Search*" }
            }

            if ($Category) {
                $filtered = $filtered | Where-Object { $_.category -eq $Category }
            }

            if ($SafeMode) {
                $filtered = $filtered | Where-Object { $_.riskLevel -eq "Low" }
            }

            $filtered | Select-Object id, category, name, riskLevel, requiresAdmin, @{
                Name = "target"
                Expression = {
                    if ($_.cmdlet) {
                        $_.cmdlet
                    } else {
                        $resolved = Resolve-KwtLegacyTool -tool $_
                        if ($resolved.Arguments.Count -gt 0) {
                            "{0} {1}" -f $_.legacyPath, ($resolved.Arguments -join " ")
                        } else {
                            $_.legacyPath
                        }
                    }
                }
            }
        }

        function Get-KwtOrderedCategories {
            $seen = @{}
            foreach ($tool in $tools) {
                if (-not $seen.ContainsKey($tool.category)) {
                    $seen[$tool.category] = $true
                    $tool.category
                }
            }
        }

        # Helper za prikaz zaglavlja
        function Show-KwtHeader {
            param([string]$Title)
            Clear-Host
            Write-Host "==================================================" -ForegroundColor Cyan
            Write-Host "             $Title             " -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "==================================================" -ForegroundColor Cyan
        }

        # Helper za proveru admin prava i ponovno pokretanje
        function Test-KwtAdminRequirement {
            param($tool)
            if ($tool.requiresAdmin -and -not $isAdmin) {
                Write-Host "`n[!] Upozorenje: Alat '$($tool.name)' zahteva administratorske privilegije." -ForegroundColor Yellow
                $confirm = Read-Host "Da li želite da pokrenete ovaj alat kao Administrator? (Y/N)"
                if ($confirm.ToUpper() -eq "Y") {
                    try {
                        # Ponovo pokrećemo skriptu/cmdlet u novom admin procesu
                        $psHost = Get-KwtPowerShellHost
                        if ($tool.cmdlet) {
                            $modulePath = $manifestPath.Replace("'", "''")
                            $command = "Import-Module -Name '$modulePath' -Force; & '$($tool.cmdlet)' -Verbose"
                            Start-Process -FilePath $psHost -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $command) -Verb RunAs
                        } else {
                            $resolved = Resolve-KwtLegacyTool -tool $tool
                            $argList = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $resolved.ScriptPath) + @($resolved.Arguments)
                            Start-Process -FilePath $psHost -ArgumentList $argList -Verb RunAs
                        }
                        Write-Host "Pokrenut administrator proces." -ForegroundColor Green
                    } catch {
                        Write-Host "Nije uspelo pokretanje kao administrator: $($_.Exception.Message)" -ForegroundColor Red
                    }
                    return $false
                }
                return $false
            }
            return $true
        }

        # Pokretanje alata
        function Invoke-KwtTool {
            param($tool)
            Show-KwtHeader -Title $tool.name.ToUpper()
            $riskColor = "Green"
            if ($tool.riskLevel -eq "High") { $riskColor = "Red" }
            elseif ($tool.riskLevel -eq "Medium") { $riskColor = "Yellow" }

            $adminColor = "Green"
            if ($tool.requiresAdmin) { $adminColor = "Red" }

            Write-Host "Opis: $($tool.descriptionSr)" -ForegroundColor Gray
            Write-Host "Nivo rizika: $($tool.riskLevel)" -ForegroundColor $riskColor
            Write-Host "Zahteva Admin: $($tool.requiresAdmin)" -ForegroundColor $adminColor
            Write-Host "==================================================" -ForegroundColor Cyan

            if (-not (Test-KwtAdminRequirement -tool $tool)) {
                Read-Host "`nPritisnite Enter za nastavak..." | Out-Null
                return
            }

            try {
                if ($tool.cmdlet) {
                    Write-Host "Pokrećem cmdlet: $($tool.cmdlet)...`n" -ForegroundColor Cyan
                    # Pozivamo cmdlet iz učitanog modula
                    & $tool.cmdlet
                } else {
                    Write-Host "Pokrećem legacy skriptu: $($tool.legacyPath)...`n" -ForegroundColor Cyan
                    $resolved = Resolve-KwtLegacyTool -tool $tool
                    if (Test-Path -LiteralPath $resolved.ScriptPath) {
                        & $resolved.ScriptPath @($resolved.Arguments)
                    } else {
                        Write-Host "Greška: Fajl skripte ne postoji na putanji $($resolved.ScriptPath)" -ForegroundColor Red
                    }
                }
            } catch {
                Write-Host "Greška pri izvršavanju alata: $($_.Exception.Message)" -ForegroundColor Red
            }

            Read-Host "`nPritisnite Enter za nastavak..." | Out-Null
        }
    }

    process {
        if ($List -or $Json) {
            $listOutput = @(Get-KwtToolList)
            if ($Json) {
                $listOutput | ConvertTo-Json -Depth 4
            } else {
                $listOutput | Format-Table -AutoSize
            }
            return
        }

        # Ako je prosleđen parametar za pretragu
        if ($Search) {
            $filtered = $tools | Where-Object { $_.name -like "*$Search*" -or $_.descriptionSr -like "*$Search*" }
            if ($filtered.Count -eq 0) {
                Write-Host "Nema pronađenih alata za pojam: '$Search'" -ForegroundColor Yellow
                return
            }
            Show-KwtHeader -Title "REZULTATI PRETRAGE: $Search"
            for ($i = 0; $i -lt $filtered.Count; $i++) {
                Write-Host "$($i + 1). $($filtered[$i].name) ($($filtered[$i].category))" -ForegroundColor White
            }
            Write-Host "0. Nazad" -ForegroundColor Red
            Write-Host "==================================================" -ForegroundColor Cyan
            $choice = Read-Host "Izaberite alat za pokretanje"
            if ($null -eq $choice) { return }
            if ($choice -match "^\d+$" -and [int]$choice -gt 0 -and [int]$choice -le $filtered.Count) {
                Invoke-KwtTool -tool $filtered[[int]$choice - 1]
            }
            return
        }

        # Ako je prosleđen filter kategorije
        if ($Category) {
            $filtered = $tools | Where-Object { $_.category -eq $Category }
            if ($filtered.Count -eq 0) {
                Write-Host "Nepoznata kategorija: '$Category'" -ForegroundColor Yellow
                return
            }
            Show-KwtHeader -Title $Category.ToUpper()
            for ($i = 0; $i -lt $filtered.Count; $i++) {
                Write-Host "$($i + 1). $($filtered[$i].name)" -ForegroundColor White
            }
            Write-Host "0. Nazad" -ForegroundColor Red
            Write-Host "==================================================" -ForegroundColor Cyan
            $choice = Read-Host "Izaberite alat za pokretanje"
            if ($null -eq $choice) { return }
            if ($choice -match "^\d+$" -and [int]$choice -gt 0 -and [int]$choice -le $filtered.Count) {
                Invoke-KwtTool -tool $filtered[[int]$choice - 1]
            }
            return
        }

        # Glavna interaktivna petlja za ceo meni
        $categories = @(Get-KwtOrderedCategories)

        do {
            Show-KwtHeader -Title "WINDOWS UTILITY TOOLKIT (DINAMIČKI)"
            Write-Host "Autor: o0o0o0o | Modul: KorisneWindowsTools v0.1.0" -ForegroundColor DarkGray
            if ($isAdmin) {
                Write-Host "Privilegije: Administrator" -ForegroundColor Red
            } else {
                Write-Host "Privilegije: Standardni Korisnik" -ForegroundColor Green
            }
            Write-Host "`nIzaberite kategoriju alata (broj):`n" -ForegroundColor White

            for ($i = 0; $i -lt $categories.Count; $i++) {
                $catToolsCount = ($tools | Where-Object { $_.category -eq $categories[$i] }).Count
                $color = "Green"
                if ($categories[$i] -match "Sigurnost|odbrana") { $color = "Red" }
                elseif ($categories[$i] -match "Mreža|SSL") { $color = "Blue" }
                elseif ($categories[$i] -match "Fajlovi") { $color = "Magenta" }
                
                Write-Host ("{0,2}. {1} ({2} alata)" -f ($i + 1), $categories[$i], $catToolsCount) -ForegroundColor $color
            }

            Write-Host " 0. Izlaz" -ForegroundColor Red
            Write-Host "==================================================" -ForegroundColor Cyan
            
            $catChoice = Read-Host "Unesite Vaš izbor"
            if ($null -eq $catChoice) {
                break
            }

            if ($catChoice -match "^\d+$" -and [int]$catChoice -gt 0 -and [int]$catChoice -le $categories.Count) {
                $selectedCat = $categories[[int]$catChoice - 1]
                
                # Petlja za podmeni
                do {
                    $catTools = $tools | Where-Object { $_.category -eq $selectedCat }
                    if ($SafeMode) {
                        $catTools = $catTools | Where-Object { $_.riskLevel -eq "Low" }
                    }

                    Show-KwtHeader -Title $selectedCat.ToUpper()
                    for ($j = 0; $j -lt $catTools.Count; $j++) {
                        $t = $catTools[$j]
                        $markers = @()
                        if ($t.cmdlet) { $markers += "[Cmdlet]" } else { $markers += "[Script]" }
                        if ($t.requiresAdmin) { $markers += "[Admin]" }
                        if ($t.riskLevel -ne "Low") { $markers += "[$($t.riskLevel)]" }
                        $marker = $markers -join " "
                        $color = if ($t.riskLevel -eq "High") { "Red" } elseif ($t.riskLevel -eq "Medium") { "Yellow" } else { "White" }
                        Write-Host ("{0,2}. {1,-45} {2}" -f ($j + 1), $t.name, $marker) -ForegroundColor $color
                    }
                    Write-Host " 0. Nazad u glavni meni" -ForegroundColor Red
                    Write-Host "==================================================" -ForegroundColor Cyan

                    $toolChoice = Read-Host "Izaberite alat"
                    if ($null -eq $toolChoice) {
                        break
                    }
                    if ($toolChoice -match "^\d+$" -and [int]$toolChoice -gt 0 -and [int]$toolChoice -le $catTools.Count) {
                        Invoke-KwtTool -tool $catTools[[int]$toolChoice - 1]
                    }
                } while ($toolChoice -ne "0")
            }
        } while ($catChoice -ne "0")

        Write-Host "`nDoviđenja! Hvala što ste koristili Windows Utility Toolkit." -ForegroundColor Yellow
    }
}


