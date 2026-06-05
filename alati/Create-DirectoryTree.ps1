# Create-DirectoryTree.ps1 - Generisanje tekstualne mape strukture foldera (Tree view)
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [int]$MaxDepth = 3
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


if (-not (Test-Path $Path)) {
    Write-Host "Putanja ne postoji!" -ForegroundColor Red
    return
}

Write-Host "Generišem stablo (Tree View) foldera za putanju: $Path" -ForegroundColor Cyan
Write-Host "Maksimalna dubina prikaza: $MaxDepth`n" -ForegroundColor DarkGray

function Show-Tree {
    param(
        [string]$dirPath,
        [string]$indent = "",
        [int]$depth = 1
    )
    
    if ($depth -gt $MaxDepth) { return }
    
    try {
        $items = Get-ChildItem -Path $dirPath -ErrorAction SilentlyContinue
        $dirs = $items | Where-Object { $_.PSIsContainer } | Sort-Object Name
        $files = $items | Where-Object { -not $_.PSIsContainer } | Sort-Object Name
        
        # Prvo ispisujemo foldere
        for ($i = 0; $i -lt $dirs.Count; $i++) {
            $d = $dirs[$i]
            if ($d.Name -match '^\b(node_modules|\.git|dist|build)\b') { continue }
            
            $isLast = ($i -eq ($dirs.Count - 1) -and $files.Count -eq 0)
            $connector = if ($isLast) { "└── " } else { "├── " }
            
            Write-Host "${indent}${connector}" -NoNewline -ForegroundColor DarkGray
            Write-Host "$($d.Name)/" -ForegroundColor Green
            
            # Rekurzivni poziv za podfoldere
            $nextIndent = $indent + (if ($isLast) { "    " } else { "│   " })
            Show-Tree -dirPath $d.FullName -indent $nextIndent -depth ($depth + 1)
        }
        
        # Ispisujemo fajlove u trenutnom folderu
        for ($i = 0; $i -lt $files.Count; $i++) {
            $f = $files[$i]
            $isLast = ($i -eq ($files.Count - 1))
            $connector = if ($isLast) { "└── " } else { "├── " }
            
            Write-Host "${indent}${connector}" -NoNewline -ForegroundColor DarkGray
            Write-Host $f.Name -ForegroundColor White
        }
    } catch {}
}

# Prikaz korenskog foldera
Write-Host "Folder: $( (Get-Item $Path).Name )/" -ForegroundColor Yellow
Show-Tree -dirPath $Path -indent "" -depth 1
Write-Host ""