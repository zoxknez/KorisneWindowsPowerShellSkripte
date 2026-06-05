# Search-TextInFiles.ps1 - Brza pretraga teksta kroz fajlove (Grep)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $true)]
    [string]$Query,
    [Parameter(Mandatory = $false)]
    [string]$Filter = "*",
    [Parameter(Mandatory = $false)]
    [switch]$CaseSensitive,
    [Parameter(Mandatory = $false)]
    [switch]$IsRegex
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

$pattern = $Query
if (-not $IsRegex) {
    $pattern = [Regex]::Escape($Query)
}

Write-Host "Pretražujem tekst: '$Query' u putanji: $Path (Filter: $Filter)...`n" -ForegroundColor Cyan

try {
    $files = Get-ChildItem -Path $Path -Filter $Filter -Recurse -File -Force -ErrorAction SilentlyContinue | 
             Where-Object { $_.FullName -notmatch '\\(node_modules|\.git|dist|build|\.next)\\' }
             
    if ($files.Count -eq 0) {
        Write-Host "Nisu pronađeni fajlovi koji odgovaraju filteru." -ForegroundColor Yellow
        return
    }
    
    $matchesFound = $files | Select-String -Pattern $pattern -CaseSensitive:$CaseSensitive -ErrorAction SilentlyContinue
    
    if (-not $matchesFound -or $matchesFound.Count -eq 0) {
        Write-Host "Nema pronađenih poklapanja." -ForegroundColor Green
        return
    }
    
    Write-Host "Pronađeni rezultati:" -ForegroundColor Yellow
    
    $grouped = $matchesFound | Group-Object -Property Path
    
    foreach ($group in $grouped) {
        $relativeFile = $group.Name.Replace($Path, ".").TrimStart("\")
        Write-Host "`n[Fajl] $relativeFile" -ForegroundColor Cyan -BackgroundColor Black
        
        foreach ($match in $group.Group) {
            $lineNum = $match.LineNumber.ToString().PadRight(4)
            $lineContent = $match.Line.Trim()
            
            if ($lineContent.Length -gt 100) { $lineContent = $lineContent.Substring(0, 97) + "..." }
            
            Write-Host "  Linija ${lineNum}: " -NoNewline -ForegroundColor DarkGray
            Write-Host $lineContent -ForegroundColor White
        }
    }
    
    Write-Host "`nUkupno pronađeno poklapanja: $($matchesFound.Count) u $($grouped.Count) fajlova." -ForegroundColor Yellow
} catch {
    Write-Host "Došlo je do greške pri pretrazi: $($_.Exception.Message)" -ForegroundColor Red
}