# Start-Menu.ps1 - Glavni interaktivni pokretač za Windows Utility Toolkit (200+ koristi)
# Refaktorisano: Sada koristi modularnu arhitekturu sa dinamičkim katalogom alata.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Search,

    [Parameter(Mandatory = $false)]
    [string]$Category,

    [Parameter(Mandatory = $false)]
    [switch]$SafeMode
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$manifestPath = Join-Path $scriptDir "src\KorisneWindowsTools\KorisneWindowsTools.psd1"

# Uvoz modula
if (Test-Path $manifestPath) {
    try {
        Import-Module -Name $manifestPath -Force
        Write-Verbose "Modul KorisneWindowsTools je uspešno uvezen."
    } catch {
        Write-Error "Greška pri učitavanju modula sa lokacije ${manifestPath}: $($_.Exception.Message)"
        return
    }
} else {
    Write-Error "Manifest modula nije pronađen na putanji: $manifestPath"
    return
}

# Pokretanje dinamičkog menija sa parametrima
Start-KwtMenu -Search $Search -Category $Category -SafeMode:$SafeMode


