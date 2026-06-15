$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$manifestPath = Join-Path $projectRoot "src\KorisneWindowsTools\KorisneWindowsTools.psd1"

Describe 'Unit Tests - Get-KwtLocalUserAudit' {
    BeforeAll {
        Import-Module -Name $manifestPath -Force
    }

    Context 'Normalno pokretanje' {
        It 'Vraća listu korisnika koji imaju očekivane atribute' {
            $users = Get-KwtLocalUserAudit
            $users | Should Not Be $null

            if ($users.Count -gt 0) {
                $firstUser = $users[0]
                ($firstUser.PSObject.Properties.Name -contains 'UserName') | Should Be $true
                ($firstUser.PSObject.Properties.Name -contains 'Enabled') | Should Be $true
                ($firstUser.PSObject.Properties.Name -contains 'IsLocalAdmin') | Should Be $true
            }
        }
    }

    Context 'Pokretanje sa filtriranjem' {
        It 'Sa parametrom -OnlyAdmins vraća isključivo administratore' {
            $admins = Get-KwtLocalUserAudit -OnlyAdmins
            if ($admins.Count -gt 0) {
                foreach ($admin in $admins) {
                    $admin.IsAdmin | Should Be $true
                    $admin.IsLocalAdmin | Should Be $true
                    ($admin.PSObject.Properties.Name -contains 'UserName') | Should Be $true
                }
            }
        }
    }
}
