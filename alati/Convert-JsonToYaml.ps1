# Convert-JsonToYaml.ps1 - Konverzija JSON u YAML (i obrnuto)
[CmdletBinding(DefaultParameterSetName = "ToJson")]
param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    
    [Parameter(Mandatory = $false, ParameterSetName = "ToYaml")]
    [switch]$ToYaml,
    
    [Parameter(Mandatory = $false, ParameterSetName = "ToJson")]
    [switch]$ToJson
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $FilePath)) {
    Write-Host "Fajl ne postoji: $FilePath" -ForegroundColor Red
    return
}

# Pomoćna funkcija za pretvaranje objekta u jednostavan YAML
function Convert-ObjectToYaml {
    param($InputObject, $Indent = 0)
    $yaml = ""
    $spaces = " " * $Indent
    
    if ($InputObject -is [System.Collections.IDictionary] -or $InputObject -is [PSCustomObject]) {
        $props = if ($InputObject -is [PSCustomObject]) { $InputObject.PSObject.Properties } else { $InputObject.Keys }
        foreach ($prop in $props) {
            $name = if ($InputObject -is [PSCustomObject]) { $prop.Name } else { $prop }
            $val = if ($InputObject -is [PSCustomObject]) { $prop.Value } else { $InputObject[$prop] }
            
            if ($val -is [System.Collections.IDictionary] -or $val -is [PSCustomObject] -or $val -is [array]) {
                $yaml += "${spaces}${name}:`r`n"
                $yaml += Convert-ObjectToYaml -InputObject $val -Indent ($Indent + 2)
            } else {
                $yaml += "${spaces}${name}: $val`r`n"
            }
        }
    } elseif ($InputObject -is [array]) {
        foreach ($item in $InputObject) {
            if ($item -is [System.Collections.IDictionary] -or $item -is [PSCustomObject]) {
                # Prikaz prvog elementa liste sa crticom
                $subYaml = Convert-ObjectToYaml -InputObject $item -Indent ($Indent + 2)
                # Zamena prvog indenta sa crticom
                $subLines = $subYaml.Split("`r`n")
                if ($subLines.Length -gt 0) {
                    $subLines[0] = $spaces + "- " + $subLines[0].Substring($Indent + 2)
                    for ($i = 1; $i -lt $subLines.Length; $i++) {
                        if ($subLines[$i].Trim()) {
                            $subLines[$i] = $subLines[$i]
                        }
                    }
                    $yaml += ($subLines -join "`r`n")
                }
            } else {
                $yaml += "${spaces}- $item`r`n"
            }
        }
    } else {
        $yaml += "${spaces}$InputObject`r`n"
    }
    return $yaml
}

try {
    $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
    
    if ($ext -eq ".json" -or $ToYaml) {
        # Konverzija JSON u YAML
        Write-Host "Konvertujem JSON u YAML..." -ForegroundColor Cyan
        $json = Get-Content -Path $FilePath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        $yaml = Convert-ObjectToYaml -InputObject $json
        
        $outFile = [System.IO.Path]::ChangeExtension($FilePath, ".yaml")
        $yaml | Set-Content -Path $outFile -Encoding utf8 -Force
        Write-Host "Uspešno kreiran YAML fajl: $outFile" -ForegroundColor Green
    } else {
        Write-Host "Ova skripta za prevođenje YAML-a u JSON podržava osnovne YAML fajlove." -ForegroundColor Yellow
        # Za pravu YAML konverziju u PowerShellu je potreban modul YamlDotNet.
        # Ovde radimo lagani linijski parser za osnovne strukture
        $lines = Get-Content -Path $FilePath
        $obj = @{}
        foreach ($line in $lines) {
            if ($line.Trim() -and $line -match '^\s*([^:]+)\s*:\s*(.*)$') {
                $key = $Matches[1].Trim()
                $val = $Matches[2].Trim()
                $obj[$key] = $val
            }
        }
        $json = ConvertTo-Json -InputObject $obj
        $outFile = [System.IO.Path]::ChangeExtension($FilePath, ".json")
        $json | Set-Content -Path $outFile -Encoding utf8 -Force
        Write-Host "Uspešno konvertovano u JSON: $outFile" -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri konverziji: $($_.Exception.Message)" -ForegroundColor Red
}