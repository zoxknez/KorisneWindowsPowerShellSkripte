[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Test-RegexMatcher.ps1 - Interaktivno testiranje regularnih izraza
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "          INTERAKTIVNI TEST REGEX MATCHER-A       " -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Unesite tekst koji želite da analizirate i regularni izraz." -ForegroundColor DarkGray
Write-Host "Unesite 'exit' za izlaz.`n" -ForegroundColor Yellow

do {
    $text = Read-Host "Unesite testni tekst"
    if ($text -eq "exit") { break }
    
    $pattern = Read-Host "Unesite regularni izraz (Regex)"
    if ($pattern -eq "exit") { break }
    
    if (-not [string]::IsNullOrEmpty($text) -and -not [string]::IsNullOrEmpty($pattern)) {
        try {
            $matches = [regex]::Matches($text, $pattern)
            if ($matches.Count -gt 0) {
                Write-Host "`nPronađeno $($matches.Count) poklapanja:" -ForegroundColor Green
                foreach ($m in $matches) {
                    Write-Host "  - Poklapanje: " -NoNewline -ForegroundColor White
                    Write-Host "'$($m.Value)'" -ForegroundColor Green -NoNewline
                    Write-Host " na indeksu: $($m.Index)" -ForegroundColor White
                }
                Write-Host ""
            } else {
                Write-Host "`n[-] Nije pronađeno nijedno poklapanje za taj regex.`n" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "`n[-] Greška u sintaksi regularnog izraza: $($_.Exception.Message)`n" -ForegroundColor Red
        }
    }
} while ($true)