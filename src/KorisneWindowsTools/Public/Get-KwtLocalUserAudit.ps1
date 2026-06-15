function Get-KwtLocalUserAudit {
    <#
    .SYNOPSIS
    Sigurnosni pregled lokalnih korisničkih naloga i članova administratorske grupe.

    .DESCRIPTION
    Prikazuje spisak lokalnih korisničkih naloga, njihov status (aktivan/onemogućen) i opis. 
    Takođe pronalazi sve članove lokalne grupe Administratori prevodeći SID (S-1-5-32-544) 
    kako bi ispravno funkcionisalo na svim jezičkim verzijama Windows operativnog sistema.

    .PARAMETER OnlyAdmins
    Ako je prosleđen ovaj prekidač, funkcija vraća samo članove grupe Administratori.

    .PARAMETER IncludeDisabled
    Ako je prosleđen ovaj prekidač, u izveštaj se uključuju i korisnički nalozi koji su onemogućeni.

    .OUTPUTS
    [PSCustomObject] sa detaljima o korisnicima ili članovima grupe Administratori.

    .EXAMPLE
    Get-KwtLocalUserAudit

    .EXAMPLE
    Get-KwtLocalUserAudit -OnlyAdmins
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [switch]$OnlyAdmins,
        [switch]$IncludeDisabled
    )

    begin {
        $result = [System.Collections.Generic.List[PSCustomObject]]::new()

        # Pronalaženje naziva lokalne grupe Administratori preko standardnog SID-a (S-1-5-32-544)
        try {
            $adminSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
            $adminGroup = $adminSid.Translate([System.Security.Principal.NTAccount]).Value
            $adminGroupName = ($adminGroup -split '\\')[-1]
            Write-Verbose "Identifikovana administratorska grupa: $adminGroupName"
        } catch {
            $adminGroupName = "Administrators"
            Write-Warning "Nije moguće prevesti SID za grupu Administrators, koristim podrazumevanu vrednost."
        }
    }

    process {
        if ($OnlyAdmins) {
            # Vrati samo članove administratorske grupe
            try {
                $members = Get-LocalGroupMember -Group $adminGroupName -ErrorAction Stop
                foreach ($m in $members) {
                    $result.Add([PSCustomObject]@{
                        UserName    = $m.Name
                        Type        = $m.ObjectClass
                        Principal   = $m.PrincipalSource
                        IsAdmin     = $true
                        IsLocalAdmin = $true
                        AuditTime   = (Get-Date)
                    })
                }
            } catch {
                Write-Error "Greška pri čitanju članova grupe ${adminGroupName}: $($_.Exception.Message)"
            }
        } else {
            # Vrati sve lokalne korisnike
            try {
                $users = Get-LocalUser -ErrorAction Stop
                $adminMembers = Get-LocalGroupMember -Group $adminGroupName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
                $normalizedAdminMembers = foreach ($memberName in $adminMembers) {
                    $memberName
                    ($memberName -split '\\')[-1]
                }

                foreach ($u in $users) {
                    # Filtriranje onemogućenih ako prekidač nije uključen
                    if (-not $u.Enabled -and -not $IncludeDisabled) {
                        continue
                    }

                    $isAdmin = $normalizedAdminMembers -contains $u.Name

                    $result.Add([PSCustomObject]@{
                        UserName      = $u.Name
                        Enabled       = $u.Enabled
                        Description   = $u.Description
                        LastLogon     = $u.LastLogon
                        IsLocalAdmin  = $isAdmin
                        AuditTime     = (Get-Date)
                    })
                }
            } catch {
                Write-Error "Greška pri listanju lokalnih korisnika: $($_.Exception.Message)"
            }
        }
    }

    end {
        return ,$result.ToArray()
    }
}


