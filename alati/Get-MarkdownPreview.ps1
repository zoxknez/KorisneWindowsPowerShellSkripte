# Get-MarkdownPreview.ps1 - Pretvaranje Markdown fajlova u HTML stranice
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MarkdownFile
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $MarkdownFile)) {
    Write-Host "Fajl ne postoji: $MarkdownFile" -ForegroundColor Red
    return
}

$htmlFile = [System.IO.Path]::ChangeExtension($MarkdownFile, ".html")
Write-Host "Generišem HTML pregled za: $MarkdownFile..." -ForegroundColor Cyan

# Izuzetno jednostavan i lagan parser za Markdown linije u HTML
# (Naslovi, liste, pasusi, kodni blokovi)
try {
    $lines = Get-Content -Path $MarkdownFile
    $htmlContent = New-Object System.Text.StringBuilder
    
    # HTML Zaglavlje sa stilovima za lepšu čitljivost (GitHub Markdown stil)
    $htmlContent.AppendLine("<!DOCTYPE html><html><head><meta charset='utf-8'><title>Markdown Preview</title>") | Out-Null
    $htmlContent.AppendLine("<style>body{font-family:'Segoe UI',Helvetica,Arial,sans-serif;margin:40px auto;max-width:800px;line-height:1.6;color:#333;padding:0 10px;}h1,h2,h3{color:#111;border-bottom:1px solid #eaecef;padding-bottom:10px;}code{background:#f6f8fa;padding:2px 5px;border-radius:3px;font-family:Consolas,monospace;font-size:0.9em;}pre{background:#f6f8fa;padding:15px;border-radius:5px;overflow-x:auto;font-family:Consolas,monospace;}blockquote{border-left:4px solid #dfe2e5;color:#6a737d;padding:0 15px;margin:0;}table{border-collapse:collapse;width:100%;margin:20px 0;}table,th,td{border:1px solid #dfe2e5;padding:8px 13px;}th{background:#f6f8fa;}</style></head><body>") | Out-Null
    
    $inCodeBlock = $false
    $inList = $false
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        
        # 1. Kodni blokovi ```
        if ($trimmed.StartsWith('```')) {
            if ($inCodeBlock) {
                $htmlContent.AppendLine("</pre>") | Out-Null
                $inCodeBlock = $false
            } else {
                $htmlContent.AppendLine("<pre>") | Out-Null
                $inCodeBlock = $true
            }
            continue
        }
        
        if ($inCodeBlock) {
            $htmlContent.AppendLine([System.Web.HttpUtility]::HtmlEncode($line)) | Out-Null
            continue
        }
        
        # 2. Liste -
        if ($trimmed.StartsWith("- ") -or $trimmed.StartsWith("* ")) {
            if (-not $inList) {
                $htmlContent.AppendLine("<ul>") | Out-Null
                $inList = $true
            }
            $item = $trimmed.Substring(2)
            $htmlContent.AppendLine("<li>$item</li>") | Out-Null
            continue
        } else {
            if ($inList) {
                $htmlContent.AppendLine("</ul>") | Out-Null
                $inList = $false
            }
        }
        
        # 3. Naslovi #
        if ($trimmed.StartsWith("# ")) {
            $h = $trimmed.Substring(2); $htmlContent.AppendLine("<h1>$h</h1>") | Out-Null
        } elseif ($trimmed.StartsWith("## ")) {
            $h = $trimmed.Substring(3); $htmlContent.AppendLine("<h2>$h</h2>") | Out-Null
        } elseif ($trimmed.StartsWith("### ")) {
            $h = $trimmed.Substring(4); $htmlContent.AppendLine("<h3>$h</h3>") | Out-Null
        } # 4. Prazan red
        elseif ([string]::IsNullOrWhitespace($trimmed)) {
            $htmlContent.AppendLine("<br/>") | Out-Null
        } # 5. Standardni pasus
        else {
            # Obrada inline stilova (npr `code` ili **bold**)
            $processed = $line
            # Zamena **bold** sa <strong>bold</strong>
            $processed = [regex]::Replace($processed, '\*\*(.*?)\*\*', '<strong>$1</strong>')
            # Zamena `code` sa <code>code</code>
            $processed = [regex]::Replace($processed, '`(.*?)`', '<code>$1</code>')
            
            $htmlContent.AppendLine("<p>$processed</p>") | Out-Null
        }
    }
    
    if ($inList) { $htmlContent.AppendLine("</ul>") | Out-Null }
    
    $htmlContent.AppendLine("</body></html>") | Out-Null
    
    $htmlContent.ToString() | Set-Content -Path $htmlFile -Encoding utf8 -Force
    Write-Host "`n[+] HTML fajl uspešno generisan!" -ForegroundColor Green
    Write-Host "Izlazni fajl: $htmlFile" -ForegroundColor Gold
    
    # Otvaranje u podrazumevanom pretraživaču
    Start-Process $htmlFile
} catch {
    Write-Host "Greška pri kreiranju HTML-a: $($_.Exception.Message)" -ForegroundColor Red
}