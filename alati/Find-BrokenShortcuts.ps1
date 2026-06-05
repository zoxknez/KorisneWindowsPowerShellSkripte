# Find-BrokenShortcuts.ps1 - Skeniranje i uklanjanje neispravnih prečica (.lnk)
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

Write-Host "Skeniram neispravne prečice (.lnk) u folderu: $Path..." -ForegroundColor Cyan
Write-Host "Pretraga u toku..." -ForegroundColor DarkGray

try {
    $sh = New-Object -ComObject WScript.Shell
    $shortcuts = Get-ChildItem -Path $Path -Filter "*.lnk" -Recurse -Force -ErrorAction SilentlyContinue
    
    $brokenCount = 0
    $brokenList = @()
    
    foreach ($link in $shortcuts) {
        try {
            $sc = $sh.CreateShortcut($link.FullName)
            $target = $sc.TargetPath
            
            # Preskačemo prečice koje nemaju definisan target (npr. neke sistemske)
            if ([string]::IsNullOrEmpty($target)) { continue }
            
            # Provera da li cilj postoji
            if (-not (Test-Path $target)) {
                Write-Host "Pronađena neispravna prečica: $($link.Name) -> Pokazuje na: $target" -ForegroundColor Yellow
                $brokenList += $link
                $brokenCount++
            }
        } catch {}
    }
    
    Write-Host "`nUkupno skenirano prečica: $($shortcuts.Count)" -ForegroundColor White
    Write-Host "Pronađeno neispravnih prečica: $brokenCount" -ForegroundColor Yellow
    
    if ($brokenCount -gt 0) {
        $confirm = Read-Host "`nDa li želite da obrišete ove neispravne prečice? (Y/N)"
        if ($confirm.ToUpper() -eq "Y") {
            foreach ($bl in $brokenList) {
                Write-Host "Brišem: $($bl.FullName)..." -ForegroundColor DarkGray
                Remove-Item -Path $bl.FullName -Force -ErrorAction SilentlyContinue
            }
            Write-Host "Brisanje završeno." -ForegroundColor Green
        } else {
            Write-Host "Brisanje otkazano." -ForegroundColor Red
        }
    } else {
        Write-Host "Nema neispravnih prečica na sistemu." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška tokom skeniranja prečica: $($_.Exception.Message)" -ForegroundColor Red
}