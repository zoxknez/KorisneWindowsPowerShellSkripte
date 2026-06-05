# Search-CodeTodo.ps1 - Pretraga TODO/FIXME oznaka u kodu projekta
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location)
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Pretraga TODO, FIXME i BUG beleški u: $Path...`n" -ForegroundColor Cyan

# Tražimo uobičajene kodne fajlove, preskačemo biblioteke
$extensions = @("*.js", "*.ts", "*.tsx", "*.jsx", "*.py", "*.cs", "*.go", "*.rs", "*.php", "*.cpp", "*.h", "*.html", "*.css")
$pattern = '\b(TODO|FIXME|BUG|HACK)\b'

try {
    $files = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
             Where-Object { 
                 $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.next|\.nuxt|target|obj|bin)\\' -and
                 ($extensions -contains "*" + $_.Extension)
             }
             
    $foundCount = 0
    
    foreach ($file in $files) {
        try {
            $lines = Get-Content -Path $file.FullName
            for ($i = 0; $i -lt $lines.Length; $i++) {
                $line = $lines[$i]
                if ($line -match $pattern) {
                    $matchWord = $Matches[1]
                    $lineNum = $i + 1
                    
                    # Određivanje boje za ispis
                    $color = switch ($matchWord) {
                        "TODO" { "Green" }
                        "FIXME" { "Yellow" }
                        "BUG" { "Red" }
                        "HACK" { "Magenta" }
                    }
                    
                    $relFile = $file.FullName.Replace($Path, ".").TrimStart("\")
                    
                    Write-Host "[$matchWord] " -NoNewline -ForegroundColor $color
                    Write-Host "$relFile : Linija $lineNum" -ForegroundColor Cyan
                    Write-Host "   $($line.Trim())`n" -ForegroundColor White
                    $foundCount++
                }
            }
        } catch {}
    }
    
    Write-Host "Pretraga završena. Ukupno pronađeno: $foundCount stavki." -ForegroundColor Yellow
} catch {
    Write-Host "Greška pri pretrazi: $($_.Exception.Message)" -ForegroundColor Red
}