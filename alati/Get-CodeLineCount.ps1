# Get-CodeLineCount.ps1 - Brojanje linija koda po jezicima u projektu
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

Write-Host "Brojanje linija koda u folderu: $Path..." -ForegroundColor Cyan
Write-Host "Preskačem biblioteke i build foldere...`n" -ForegroundColor DarkGray

# Mape ekstenzija i jezika
$langMap = @{
    ".js"   = "JavaScript"
    ".ts"   = "TypeScript"
    ".tsx"  = "React TypeScript"
    ".jsx"  = "React JavaScript"
    ".html" = "HTML"
    ".css"  = "CSS"
    ".py"   = "Python"
    ".cs"   = "C# / .NET"
    ".go"   = "Go"
    ".rs"   = "Rust"
    ".cpp"  = "C++"
    ".h"    = "C/C++ Header"
    ".php"  = "PHP"
    ".sh"   = "Shell Script"
    ".ps1"  = "PowerShell"
    ".json" = "JSON Config"
}

$stats = @{}
foreach ($lang in $langMap.Values) {
    $stats[$lang] = [PSCustomObject]@{ BrojFajlova = 0; LinijaKoda = 0 }
}

try {
    # Rekurzivno nalazimo sve fajlove
    $files = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -notmatch '\\(\.git|node_modules|dist|build|\.next|\.nuxt|target|obj|bin)\\' }
             
    foreach ($file in $files) {
        $ext = $file.Extension.ToLower()
        if ($langMap.ContainsKey($ext)) {
            $lang = $langMap[$ext]
            $lineCount = 0
            
            # Brojimo linije u fajlu
            try {
                $lines = [System.IO.File]::ReadLines($file.FullName)
                foreach ($l in $lines) { $lineCount++ }
            } catch {
                # Preskačemo binarne ili zaključane fajlove
                continue
            }
            
            $stats[$lang].BrojFajlova++
            $stats[$lang].LinijaKoda += $lineCount
        }
    }
    
    # Pretvaranje statistike u tabelu
    $display = @()
    foreach ($key in $stats.Keys) {
        if ($stats[$key].BrojFajlova -gt 0) {
            $display += [PSCustomObject]@{
                Jezik = $key
                Fajlova = $stats[$key].BrojFajlova
                LinijaKoda = $stats[$key].LinijaKoda
            }
        }
    }
    
    if ($display.Count -gt 0) {
        $display | Sort-Object -Property LinijaKoda -Descending | Format-Table -AutoSize
        $totalLines = ($display | Measure-Object -Property LinijaKoda -Sum).Sum
        $totalFiles = ($display | Measure-Object -Property Fajlova -Sum).Sum
        Write-Host "UKUPNO: $totalFiles kodnih fajlova sa $totalLines linija koda." -ForegroundColor Yellow
    } else {
        Write-Host "Nisu pronađeni kodni fajlovi podržanih jezika." -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri analizi projekta: $($_.Exception.Message)" -ForegroundColor Red
}