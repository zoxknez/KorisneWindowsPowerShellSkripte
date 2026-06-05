# Lock-FolderLock.ps1 - Emulator zaključavanja direktorijuma
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$FolderDirectory,
    [Parameter(Mandatory = $false)]
    [switch]$Unlock
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $FolderDirectory)) {
    Write-Host "Folder ne postoji!" -ForegroundColor Red
    return
}

# Klasa CLSID za Control Panel - koristi se da zbuni Explorer pri ulasku u folder
$clsid = ".{21EC2020-3AEA-1069-A2DD-08002B30309D}"

try {
    $parent = Split-Path -Parent $FolderDirectory
    $folderName = (Get-Item $FolderDirectory).Name
    
    if ($Unlock) {
        # Provera da li je folder zaključan
        if ($folderName -match "\.\{[a-fA-F0-9-]+\}$") {
            $cleanName = $folderName.Replace($clsid, "")
            $newPath = Join-Path $parent $cleanName
            
            # Otključavanje: vraćanje naziva i uklanjanje sistemskih atributa
            Rename-Item -Path $FolderDirectory -NewName $cleanName -Force
            attrib -h -s $newPath
            
            Write-Host "[+] Folder je uspešno OTKLJUČAN!" -ForegroundColor Green
        } else {
            Write-Host "Folder izgleda nije zaključan." -ForegroundColor Yellow
        }
    } else {
        # Zaključavanje: dodavanje CLSID i postavljanje sistemskih atributa (skrivanje)
        if ($folderName -match "\.\{[a-fA-F0-9-]+\}$") {
            Write-Host "Folder je već zaključan!" -ForegroundColor Yellow
            return
        }
        
        $newPath = $FolderDirectory + $clsid
        Rename-Item -Path $FolderDirectory -NewName ($folderName + $clsid) -Force
        attrib +h +s $newPath
        
        Write-Host "[+] Folder je uspešno ZAKLJUČAN i sakriven!" -ForegroundColor Green
        Write-Host "Da biste ga otključali, pokrenite istu komandu sa parametrom -Unlock" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Greška pri zaključavanju/otključavanju: $($_.Exception.Message)" -ForegroundColor Red
}