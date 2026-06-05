# Start-DevEnvironment.ps1 - Pokretanje kompletnog programerskog okruženja
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location),
    [Parameter(Mandatory = $false)]
    [string]$LocalUrl = "http://localhost:3000"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


Write-Host "Pokrećem razvojno okruženje za projekat u: $Path..." -ForegroundColor Cyan

# 1. Otvaranje VS Code-a
Write-Host "Otvaram VS Code..." -ForegroundColor DarkGray
if (Get-Command code -ErrorAction SilentlyContinue) {
    Start-Process code -ArgumentList "`"$Path`""
} else {
    Write-Host "  [-] VS Code ('code' CLI) nije pronađen u PATH-u." -ForegroundColor Yellow
}

# 2. Provera i pokretanje Docker Desktopa
Write-Host "Proveravam Docker..." -ForegroundColor DarkGray
$dockerProcess = Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue
if (-not $dockerProcess) {
    # Pokušaj pronalaženja putanje za Docker
    $dockerPaths = @(
        "C:\Program Files\Docker\Docker\Docker Desktop.exe",
        "$env:LOCALAPPDATA\Docker\Docker Desktop.exe"
    )
    $launched = $false
    foreach ($p in $dockerPaths) {
        if (Test-Path $p) {
            Write-Host "Pokrećem Docker Desktop..." -ForegroundColor Yellow
            Start-Process $p
            $launched = $true
            break
        }
    }
    if (-not $launched) { Write-Host "  [-] Docker Desktop nije instaliran na standardnim lokacijama." -ForegroundColor DarkGray }
} else {
    Write-Host "  [+] Docker Desktop je već pokrenut." -ForegroundColor Green
}

# 3. Otvaranje lokalnog URL-a u pretraživaču
Write-Host "Otvaram URL u pretraživaču: $LocalUrl..." -ForegroundColor DarkGray
try {
    Start-Process $LocalUrl
} catch {}

# 4. Pokretanje dev servera (NPM) u novoj konzoli
if (Test-Path (Join-Path $Path "package.json")) {
    Write-Host "Pronađen package.json. Pokrećem 'npm run dev' u novom prozoru..." -ForegroundColor Yellow
    # Pokretanje novog PowerShell prozora koji izvršava komandu
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd `"$Path`"; npm run dev"
}

Write-Host "`nRazvojno okruženje uspešno pokrenuto!" -ForegroundColor Green