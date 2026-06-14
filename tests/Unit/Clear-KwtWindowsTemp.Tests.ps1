$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$manifestPath = Join-Path $projectRoot "src\KorisneWindowsTools\KorisneWindowsTools.psd1"

Describe 'Unit Tests - Clear-KwtWindowsTemp' {
    BeforeAll {
        Import-Module -Name $manifestPath -Force
    }

    Context 'Simulacija čišćenja sa -WhatIf' {
        It 'Izvršava se bez greške i vraća statistiku' {
            $result = Clear-KwtWindowsTemp -WhatIf
            $result | Should Not Be $null
            
            ($result.PSObject.Properties.Name -contains 'TotalFreedBytes') | Should Be $true
            ($result.PSObject.Properties.Name -contains 'TotalFreedMB') | Should Be $true
            ($result.PSObject.Properties.Name -contains 'Errors') | Should Be $true
            ($result.PSObject.Properties.Name -contains 'Success') | Should Be $true
        }
    }
}
