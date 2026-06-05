# Convert-CsvToHtmlTable.ps1 - Konverzija CSV fajla u lepu HTML tabelu
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CsvPath,
    [Parameter(Mandatory = $false)]
    [string]$Delimiter = ","
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $CsvPath)) {
    Write-Host "CSV fajl ne postoji na putanji: $CsvPath" -ForegroundColor Red
    return
}

$htmlPath = [System.IO.Path]::ChangeExtension($CsvPath, ".html")
Write-Host "Pretvaram CSV u HTML tabelu..." -ForegroundColor Cyan

try {
    # Uvozimo CSV sa ispravnim kodiranjem i delimiterom
    $csvData = Import-Csv -Path $CsvPath -Delimiter $Delimiter -Encoding utf8
    
    if (-not $csvData -or $csvData.Count -eq 0) {
        Write-Host "CSV fajl je prazan ili nema validnih podataka." -ForegroundColor Yellow
        return
    }
    
    # Izvlačenje kolona
    $properties = $csvData[0].PSObject.Properties | ForEach-Object { $_.Name }
    
    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("<!DOCTYPE html><html><head><meta charset='utf-8'><title>CSV u HTML</title>") | Out-Null
    $sb.AppendLine("<style>body{font-family:'Segoe UI',Arial,sans-serif;margin:40px;background-color:#f8f9fa;}table{border-collapse:collapse;width:100%;margin-top:20px;box-shadow:0 2px 5px rgba(0,0,0,0.1);background:#fff;}th,td{border:1px solid #dee2e6;padding:12px;text-align:left;}th{background-color:#007bff;color:#fff;font-weight:bold;}tr:nth-child(even){background-color:#f2f2f2;}tr:hover{background-color:#e9ecef;}</style></head><body>") | Out-Null
    $sb.AppendLine("<h2>Tabelarni prikaz fajla: " + [System.IO.Path]::GetFileName($CsvPath) + "</h2>") | Out-Null
    $sb.AppendLine("<table><thead><tr>") | Out-Null
    
    # Zaglavlje tabele
    foreach ($prop in $properties) {
        $sb.AppendLine("<th>" + [System.Web.HttpUtility]::HtmlEncode($prop) + "</th>") | Out-Null
    }
    $sb.AppendLine("</tr></thead><tbody>") | Out-Null
    
    # Redovi podataka
    foreach ($row in $csvData) {
        $sb.AppendLine("<tr>") | Out-Null
        foreach ($prop in $properties) {
            $val = $row.$prop
            $sb.AppendLine("<td>" + [System.Web.HttpUtility]::HtmlEncode($val) + "</td>") | Out-Null
        }
        $sb.AppendLine("</tr>") | Out-Null
    }
    
    $sb.AppendLine("</tbody></table></body></html>") | Out-Null
    
    [System.IO.File]::WriteAllText($htmlPath, $sb.ToString(), [System.Text.Encoding]::UTF8)
    Write-Host "`n[+] HTML tabela uspešno kreirana!" -ForegroundColor Green
    Write-Host "Fajl je sačuvan na: $htmlPath" -ForegroundColor Gold
} catch {
    Write-Host "Greška pri konverziji CSV u HTML: $($_.Exception.Message)" -ForegroundColor Red
}