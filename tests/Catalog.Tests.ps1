$projectRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $projectRoot "src\KorisneWindowsTools\KorisneWindowsTools.psd1"
$catalogPath = Join-Path $projectRoot "src\KorisneWindowsTools\Data\tools.json"

Describe 'Catalog Tests - tools.json' {
    BeforeAll {
        $script:tools = Get-Content -Path $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if (Get-Module -Name KorisneWindowsTools) {
            Remove-Module -Name KorisneWindowsTools -ErrorAction SilentlyContinue
        }
        Import-Module -Name $manifestPath -Force
    }

    It 'Sadrzi tacno 200 alata sa jedinstvenim ID vrednostima od 1 do 200' {
        @($script:tools).Count | Should Be 200

        $duplicateIds = $script:tools | Group-Object id | Where-Object { $_.Count -gt 1 }
        @($duplicateIds).Count | Should Be 0

        $missingIds = Compare-Object -ReferenceObject (1..200) -DifferenceObject ($script:tools | Select-Object -ExpandProperty id) |
            Where-Object { $_.SideIndicator -eq '<=' }
        @($missingIds).Count | Should Be 0
    }

    It 'Svaki legacyPath pokazuje na postojecu skriptu bez nalepljenih argumenata' {
        $badEntries = foreach ($tool in $script:tools) {
            if ($tool.cmdlet) {
                continue
            }

            if ([string]::IsNullOrWhiteSpace($tool.legacyPath)) {
                $tool
                continue
            }

            if ($tool.legacyPath -match '\s+-') {
                $tool
                continue
            }

            $scriptPath = Join-Path $projectRoot $tool.legacyPath
            if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
                $tool
            }
        }

        @($badEntries).Count | Should Be 0
    }

    It 'Svi cmdleti iz kataloga postoje u modulu' {
        $exportedCommands = Get-Command -Module KorisneWindowsTools | Select-Object -ExpandProperty Name
        $missingCmdlets = $script:tools |
            Where-Object { $_.cmdlet } |
            Where-Object { $exportedCommands -notcontains $_.cmdlet }

        @($missingCmdlets).Count | Should Be 0
    }

    It 'Napredni alati koriste arguments polje za ToolId pozive' {
        $advancedTools = $script:tools | Where-Object { $_.category -like 'Napredni alati -*' }

        @($advancedTools).Count | Should Be 60
        foreach ($tool in $advancedTools) {
            $tool.legacyPath | Should Be 'alati/Start-NapredniAlati.ps1'
            @($tool.arguments).Count | Should Be 3
            $tool.arguments[0] | Should Be '-ToolId'
            $tool.arguments[2] | Should Be '-NoPause'
        }
    }
}
