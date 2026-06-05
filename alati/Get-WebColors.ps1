# Get-WebColors.ps1 - Ekstrakcija jedinstvenih boja (#HEX) iz koda
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

Write-Host "Pretraga CSS/HTML boja (#HEX format) u: $Path..." -ForegroundColor Cyan

$extensions = @("*.css", "*.html", "*.htm", "*.scss", "*.less", "*.js", "*.ts", "*.tsx", "*.jsx")
$colorPattern = '#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\b'

try {
    $files = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
             Where-Object { 
                 $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.next|\.nuxt|target)\\' -and
                 ($extensions -contains "*" + $_.Extension)
             }
             
    $uniqueColors = @{}
    
    foreach ($file in $files) {
        try {
            $content = Get-Content -Path $file.FullName -Raw
            $matches = [regex]::Matches($content, $colorPattern)
            foreach ($m in $matches) {
                $colorCode = $m.Value.ToUpper()
                # Ako heš ima samo 3 karaktera, proširujemo ga na 6 radi lepšeg sortiranja
                $cleanCode = $colorCode
                if ($colorCode.Length -eq 4) {
                    $c1 = $colorCode[1]; $c2 = $colorCode[2]; $c3 = $colorCode[3]
                    $cleanCode = "#$c1$c1$c2$c2$c3$c3"
                }
                
                if (-not $uniqueColors.ContainsKey($cleanCode)) {
                    $uniqueColors[$cleanCode] = @()
                }
                $relFile = $file.FullName.Replace($Path, ".").TrimStart("\")
                if ($uniqueColors[$cleanCode] -notcontains $relFile) {
                    $uniqueColors[$cleanCode] += $relFile
                }
            }
        } catch {}
    }
    
    Write-Host "`nPronađene jedinstvene boje:" -ForegroundColor Yellow
    $display = @()
    foreach ($key in $uniqueColors.Keys) {
        $display += [PSCustomObject]@{
            Boja = $key
            Fajlovi = $uniqueColors[$key] -join ", "
            BrojPojavljivanja = $uniqueColors[$key].Count
        }
    }
    
    if ($display.Count -gt 0) {
        $display | Sort-Object -Property BrojPojavljivanja -Descending | Format-Table -AutoSize
        Write-Host "Ukupno pronađeno jedinstvenih boja: $($display.Count)" -ForegroundColor Gold
    } else {
        Write-Host "Nisu pronađene boje u formatu #HEX." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri analizi boja: $($_.Exception.Message)" -ForegroundColor Red
}