function Clear-KwtWindowsTemp {
    <#
    .SYNOPSIS
    Generalno čišćenje privremenih sistemskih i korisničkih fajlova.

    .DESCRIPTION
    Prazni Temp foldere i opciono briše prefetch, log fajlove i prazni kantu za otpatke.
    Podržava -WhatIf i -Confirm parametre za bezbedno simuliranje i izvršavanje akcija.

    .PARAMETER IncludeRecycleBin
    Ako je prosleđen, prazni kantu za otpatke (Recycle Bin).

    .PARAMETER IncludePrefetch
    Ako je prosleđen, briše sadržaj Windows Prefetch foldera (zahteva admin privilegije).

    .PARAMETER IncludeLogFiles
    Ako je prosleđen, briše sistemske log fajlove pod System32\LogFiles (zahteva admin privilegije).

    .OUTPUTS
    [PSCustomObject] sa informacijama o ukupno oslobođenom prostoru i uspehu operacije.

    .EXAMPLE
    Clear-KwtWindowsTemp -WhatIf

    .EXAMPLE
    Clear-KwtWindowsTemp -IncludeRecycleBin -Verbose
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [switch]$IncludeRecycleBin,
        [switch]$IncludePrefetch,
        [switch]$IncludeLogFiles
    )

    begin {
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        $freedBytes = 0
        $errors = @()

        $paths = @($env:TEMP, 'C:\Windows\Temp')
        
        if ($IncludePrefetch) {
            if ($isAdmin) {
                $paths += 'C:\Windows\Prefetch'
            } else {
                Write-Warning "Prefetch folder zahteva administratorske privilegije. Preskačem."
            }
        }

        if ($IncludeLogFiles) {
            if ($isAdmin) {
                $paths += 'C:\Windows\System32\LogFiles'
            } else {
                Write-Warning "LogFiles folder zahteva administratorske privilegije. Preskačem."
            }
        }

        # Pomoćna funkcija za čišćenje sadržaja
        function Local-CleanFolder {
            param([string]$Folder)
            if (-not (Test-Path $Folder -PathType Container)) {
                return 0
            }
            
            $freed = 0
            $items = Get-ChildItem -Path $Folder -Force -ErrorAction SilentlyContinue

            foreach ($item in $items) {
                $itemSize = 0
                try {
                    if (-not $item.PSIsContainer) {
                        $itemSize = $item.Length
                    } else {
                        $subFiles = Get-ChildItem -Path $item.FullName -Recurse -File -Force -ErrorAction SilentlyContinue
                        foreach ($sf in $subFiles) { $itemSize += $sf.Length }
                    }
                } catch {
                    # Ignorišemo greške pri računanju veličine
                }

                if ($PSCmdlet.ShouldProcess($item.FullName, "Obriši stavku iz privremenog foldera")) {
                    try {
                        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                        $freed += $itemSize
                    } catch {
                        $errors += "Nije moguće obrisati '$($item.FullName)': $($_.Exception.Message)"
                    }
                }
            }
            return $freed
        }
    }

    process {
        foreach ($p in $paths) {
            Write-Verbose "Čišćenje foldera: $p"
            $freedBytes += Local-CleanFolder -Folder $p
        }

        if ($IncludeRecycleBin) {
            if ($PSCmdlet.ShouldProcess("Recycle Bin", "Isprazni kantu za otpatke")) {
                try {
                    Clear-RecycleBin -Force -ErrorAction Stop | Out-Null
                    Write-Verbose "Kanta za otpatke uspešno ispražnjena."
                } catch {
                    try {
                        # Fallback na COM objekat ako cmdlet ne uspe
                        $sh = New-Object -ComObject Shell.Application
                        $bin = $sh.Namespace(0xa)
                        $bin.Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }
                    } catch {
                        $errors += "Nije moguće isprazniti kantu za otpatke: $($_.Exception.Message)"
                    }
                }
            }
        }
    }

    end {
        $result = [PSCustomObject]@{
            TotalFreedBytes = $freedBytes
            TotalFreedMB    = [Math]::Round($freedBytes / 1MB, 2)
            Errors          = $errors
            Success         = ($errors.Count -eq 0)
            ComputerName    = $env:COMPUTERNAME
            CleanedTime     = (Get-Date)
        }
        return $result
    }
}


