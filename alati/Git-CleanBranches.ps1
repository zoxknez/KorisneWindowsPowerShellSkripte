[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
# Git-CleanBranches.ps1 - Čišćenje lokalnih Git grana
Write-Host "Čišćenje lokalnih Git grana koje su spojene u master/main..." -ForegroundColor Cyan

# Provera da li smo u git repozitorijumu
if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
    Write-Host "Trenutni folder nije Git repozitorijum!" -ForegroundColor Red
    return
}

try {
    # Osvežavanje udaljenih grana
    Write-Host "Osvežavam stanje sa remote-a (git fetch)..." -ForegroundColor DarkGray
    git fetch --prune | Out-Null
    
    # Pronalaženje spojenih grana, preskačemo aktivnu granu i glavne grane
    $currentBranch = (git branch --show-current).Trim()
    $mergedBranches = git branch --merged | ForEach-Object { $_.Trim() } | Where-Object { 
        $_ -ne "*" -and 
        $_ -ne $currentBranch -and 
        $_ -notmatch '^\*' -and 
        $_ -notmatch '^(master|main|develop|development)$' 
    }
    
    if (-not $mergedBranches -or $mergedBranches.Count -eq 0) {
        Write-Host "Nema spojenih lokalnih grana za brisanje." -ForegroundColor Green
        return
    }
    
    Write-Host "`nPronađene spojene grane za brisanje:" -ForegroundColor Yellow
    $mergedBranches | ForEach-Object { Write-Host "  - $_" }
    
    $confirm = Read-Host "`nDa li želite da obrišete ove grane? (Y/N)"
    if ($confirm.ToUpper() -eq "Y") {
        foreach ($branch in $mergedBranches) {
            Write-Host "Brišem granu: $branch..." -ForegroundColor DarkGray
            $result = git branch -d $branch 2>&1
            Write-Host "  $result" -ForegroundColor Green
        }
        Write-Host "Čišćenje grana završeno." -ForegroundColor Gold
    } else {
        Write-Host "Operacija otkazana." -ForegroundColor Red
    }
} catch {
    Write-Host "Greška pri čišćenju Git grana: $($_.Exception.Message)" -ForegroundColor Red
}