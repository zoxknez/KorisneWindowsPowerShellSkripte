# Convert-DataFormat.ps1 - Masovni konverter CSV / JSON / XML
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputFile,
    [Parameter(Mandatory = $true)]
    [ValidateSet("csv", "json", "xml")]
    [string]$TargetFormat,
    [Parameter(Mandatory = $false)]
    [string]$OutputFile
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $InputFile)) {
    Write-Host "Ulazni fajl ne postoji!" -ForegroundColor Red
    return
}

$inputExt = [System.IO.Path]::GetExtension($InputFile).ToLower().Replace(".", "")
$inputDir = [System.IO.Path]::GetDirectoryName($InputFile)
$inputBase = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)

if ($inputExt -eq $TargetFormat) {
    Write-Host "Izabrani ciljni format je isti kao i ulazni format!" -ForegroundColor Yellow
    return
}

# Ako izlazni fajl nije zadat, kreiramo ga u istom folderu sa novom ekstenzijom
if ([string]::IsNullOrWhitespace($OutputFile)) {
    $OutputFile = Join-Path $inputDir ($inputBase + "." + $TargetFormat)
}

Write-Host "Učitavam fajl: $InputFile (Format: $inputExt)..." -ForegroundColor Cyan

try {
    # 1. Učitavanje i parsiranje u PowerShell objekat
    $dataObject = $null
    switch ($inputExt) {
        "csv" {
            $dataObject = Import-Csv -Path $InputFile
        }
        "json" {
            $rawJson = Get-Content -Path $InputFile -Raw -ErrorAction Stop
            $dataObject = ConvertFrom-Json -InputObject $rawJson
        }
        "xml" {
            [xml]$rawXml = Get-Content -Path $InputFile -ErrorAction Stop
            # Pretvaranje XML-a u objekat
            $dataObject = $rawXml
        }
        default {
            Write-Host "Ekstenzija '$inputExt' nije podržana za konverziju! Podržani su samo csv, json, xml." -ForegroundColor Red
            return
        }
    }
    
    if (-not $dataObject) {
        Write-Host "Greška: Fajl je prazan ili nije ispravno parsiran." -ForegroundColor Red
        return
    }
    
    # 2. Eksportovanje u ciljni format
    Write-Host "Konvertujem u format: $TargetFormat..." -ForegroundColor DarkGray
    switch ($TargetFormat) {
        "csv" {
            # Ako je iz XML-a, može biti kompleksniji objekat, pa radimo dubinsko pojednostavljenje
            $dataObject | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding utf8 -Force
        }
        "json" {
            $jsonString = ConvertTo-Json -InputObject $dataObject -Depth 100
            $jsonString | Set-Content -Path $OutputFile -Encoding utf8 -Force
        }
        "xml" {
            # Kreiranje jednostavne XML strukture
            # Za XML, korenski tag je uvek <Root>
            $xmlWriter = New-Object System.IO.StringWriter
            $writer = New-Object System.Xml.XmlTextWriter($xmlWriter)
            $writer.Formatting = [System.Xml.Formatting]::Indented
            $writer.WriteStartDocument()
            $writer.WriteStartElement("Root")
            
            # Pretvaranje u XML
            foreach ($item in $dataObject) {
                $writer.WriteStartElement("Item")
                foreach ($prop in $item.PSObject.Properties) {
                    $writer.WriteElementString($prop.Name, $prop.Value.ToString())
                }
                $writer.WriteEndElement() # Item
            }
            $writer.WriteEndElement() # Root
            $writer.WriteEndDocument()
            $writer.Flush()
            $xmlString = $xmlWriter.ToString()
            $xmlString | Set-Content -Path $OutputFile -Encoding utf8 -Force
        }
    }
    
    Write-Host "Konverzija uspešno završena!" -ForegroundColor Green
    Write-Host "Izlazni fajl: $OutputFile" -ForegroundColor Gold
} catch {
    Write-Host "Došlo je do greške tokom konverzije: $($_.Exception.Message)" -ForegroundColor Red
}