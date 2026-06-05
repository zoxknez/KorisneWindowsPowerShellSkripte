# Find-DuplicateFolders.ps1 - Pronalaženje identičnih (duplih) foldera rekurzivno
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

Write-Host "Skeniram strukturu i tražim duple foldere u: $Path..." -ForegroundColor Cyan

# Izrada mape otisaka foldera (heš svih fajlova u folderu)
$folderSignatures = @{}

function Get-FolderSignature {
    param([string]$dirPath)
    
    try {
        $files = Get-ChildItem -Path $dirPath -File -Force -ErrorAction SilentlyContinue | Sort-Object Name
        if ($files.Count -eq 0) { return $null }
        
        # Pravimo string sastavljen od naziva fajlova i njihove veličine
        $sigString = ""
        foreach ($f in $files) {
            $sigString += "$($f.Name)_$($f.Length)|"
        }
        
        # Vraćamo MD5 heš tog opisa strukture
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($sigString)
        $hashBytes = $md5.ComputeHash($bytes)
        
        $hashStr = ""
        foreach ($byte in $hashBytes) {
            $hashStr += $byte.ToString("X2")
        }
        return $hashStr
    } catch {
        return $null
    }
}

try {
    # Nalazimo sve podfoldere
    $allDirs = Get-ChildItem -Path $Path -Directory -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "Skeniram podfoldere..." -ForegroundColor DarkGray
    foreach ($dir in $allDirs) {
        if ($dir.FullName -match '\\(\.git|node_modules)\\' ) { continue }
        
        $sig = Get-FolderSignature -dirPath $dir.FullName
        if ($sig) {
            if (-not $folderSignatures.ContainsKey($sig)) {
                $folderSignatures[$sig] = @()
            }
            $folderSignatures[$sig] += $dir.FullName
        }
    }
    
    Write-Host "`nRezultati pretrage duplih foldera:" -ForegroundColor Yellow
    $foundDuplicates = $false
    
    foreach ($key in $folderSignatures.Keys) {
        $paths = $folderSignatures[$key]
        if ($paths.Count -gt 1) {
            Write-Host "[!] Pronađeni identični folderi (isti fajlovi i veličine):" -ForegroundColor Red
            foreach ($p in $paths) {
                Write-Host "  - $p" -ForegroundColor White
            }
            Write-Host ""
            $foundDuplicates = $true
        }
    }
    
    if (-not $foundDuplicates) {
        Write-Host "Nema dupliranih foldera sa istom strukturom." -ForegroundColor Green
    }
} catch {
    Write-Host "Greška pri analizi: $($_.Exception.Message)" -ForegroundColor Red
}