$projectRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $projectRoot "src\KorisneWindowsTools\KorisneWindowsTools.psd1"
$catalogPath = Join-Path $projectRoot "src\KorisneWindowsTools\Data\tools.json"

Describe 'Smoke Tests - Modul KorisneWindowsTools' {
    BeforeAll {
        if (Get-Module -Name KorisneWindowsTools) {
            Remove-Module -Name KorisneWindowsTools -ErrorAction SilentlyContinue
        }
    }

    It 'Manifest datoteka modula postoji' {
        Test-Path $manifestPath | Should Be $true
    }

    It 'Katalog alata tools.json postoji' {
        Test-Path $catalogPath | Should Be $true
    }

    It 'Start-Menu.ps1 launcher postoji' {
        $launcher = Join-Path $projectRoot "Start-Menu.ps1"
        Test-Path $launcher | Should Be $true
    }

    It 'Modul se uspešno uvozi u sesiju' {
        $module = Import-Module -Name $manifestPath -PassThru -Force
        $module | Should Not Be $null
    }

    It 'Modul izvozi očekivane cmdlete' {
        $exportedCommands = Get-Command -Module KorisneWindowsTools | Select-Object -ExpandProperty Name
        
        ($exportedCommands -contains 'Get-KwtLocalUserAudit') | Should Be $true
        ($exportedCommands -contains 'Clear-KwtWindowsTemp') | Should Be $true
        ($exportedCommands -contains 'Backup-KwtMySqlDatabase') | Should Be $true
        ($exportedCommands -contains 'Start-KwtMenu') | Should Be $true
    }
}
