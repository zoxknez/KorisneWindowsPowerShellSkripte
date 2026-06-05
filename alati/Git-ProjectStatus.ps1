# Git-ProjectStatus.ps1 - Skeniranje Git statusa na više projekata odjednom
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

Write-Host "Skeniram Git projekte u: $Path...`n" -ForegroundColor Cyan

try {
    $subdirs = Get-ChildItem -Path $Path -Directory -Force -ErrorAction SilentlyContinue
    $gitProjects = @()
    
    foreach ($dir in $subdirs) {
        $gitPath = Join-Path $dir.FullName ".git"
        if (Test-Path $gitPath) {
            # Idemo u taj folder i proveravamo status
            Push-Location $dir.FullName
            
            $status = git status --short 2>$null
            $branch = git branch --show-current 2>$null
            
            $hasChanges = if ($status) { "IZMENJENO (Neupisano)" } else { "Čisto" }
            $color = if ($status) { "Yellow" } else { "Green" }
            
            Pop-Location
            
            Write-Host "Projekat: " -NoNewline -ForegroundColor White
            Write-Host "$($dir.Name.PadRight(20))" -ForegroundColor Cyan -NoNewline
            Write-Host " | Grana: $($branch.PadRight(15))" -ForegroundColor Gray -NoNewline
            Write-Host " | Status: " -NoNewline -ForegroundColor White
            Write-Host "$hasChanges" -ForegroundColor $color
            
            if ($status) {
                # Prikaz kratkih izmena
                $status | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
            }
        }
    }
} catch {
    Write-Host "Greška tokom skeniranja projekata: $($_.Exception.Message)" -ForegroundColor Red
}